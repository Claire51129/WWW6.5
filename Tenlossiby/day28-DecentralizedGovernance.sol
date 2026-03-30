// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 OpenZeppelin 合约
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title 去中心化治理合约
/// @title Decentralized Governance
/// @dev 一个基于代币持有量的 DAO 治理合约
/// @dev 支持创建提案、投票、执行提案等功能
/// @dev 包含时间锁机制，确保提案有足够时间被审查
contract DecentralizedGovernance is ReentrancyGuard {
    
    // ==================== 状态变量 ====================
    
    /// @notice 治理代币合约接口
    /// @dev 用于确定投票权（1 代币 = 1 票）
    IERC20 public governanceToken;
    
    /// @notice 提案总数计数器
    /// @dev 每次创建新提案时递增
    uint256 public proposalCount;

    // ==================== 常量配置 ====================
    
    /// @notice 投票期时长
    /// @dev 提案创建后的投票持续时间
    uint256 public constant VOTING_PERIOD = 3 days;
    
    /// @notice 时间锁定期时长
    /// @dev 提案通过后到可以执行的等待时间
    /// @dev 给用户时间审查通过的提案并采取行动
    uint256 public constant TIMELOCK_PERIOD = 2 days;
    
    /// @notice 法定人数百分比
    /// @dev 提案通过所需的最小投票参与率
    /// @dev 10 表示需要至少 10% 的总代币供应量参与投票
    uint256 public constant QUORUM_PERCENTAGE = 10;
    
    /// @notice 创建提案所需的押金
    /// @dev 100 个代币（假设 18 位小数）
    /// @dev 用于防止垃圾提案，提案成功执行后退还
    uint256 public constant PROPOSAL_DEPOSIT = 100 * 10**18;

    // ==================== 数据结构 ====================
    
    /// @notice 提案结构体
    /// @dev 存储提案的所有信息
    struct Proposal {
        uint256 id;                    // 提案唯一标识符
        address proposer;              // 提案创建者地址
        string description;            // 提案描述文本
        uint256 deadline;              // 投票截止时间戳
        uint256 votesFor;              // 赞成票总数
        uint256 votesAgainst;          // 反对票总数
        bool executed;                 // 是否已执行
        bool cancelled;                // 是否已取消
        uint256 executionTime;         // 可执行时间（通过 + 时间锁）
        bytes[] executionData;         // 要执行的调用数据数组
        address[] executionTargets;    // 要调用的目标合约地址数组
        mapping(address => bool) hasVoted;  // 记录谁已经投过票
    }
    
    /// @notice 提案映射表
    /// @dev 提案 ID => 提案信息
    mapping(uint256 => Proposal) public proposals;

    // ==================== 事件 ====================
    
    /// @notice 提案创建事件
    /// @param proposalId 提案 ID
    /// @param proposer 提案创建者
    /// @param description 提案描述
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description);
    
    /// @notice 投票事件
    /// @param proposalId 提案 ID
    /// @param voter 投票者地址
    /// @param support 是否赞成（true=赞成，false=反对）
    /// @param weight 投票权重（代币数量）
    event Voted(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);
    
    /// @notice 提案执行事件
    /// @param proposalId 被执行的提案 ID
    event ProposalExecuted(uint256 indexed proposalId);
    
    /// @notice 提案取消事件
    /// @param proposalId 被取消的提案 ID
    event ProposalCancelled(uint256 indexed proposalId);

    // ==================== 构造函数 ====================
    
    /// @notice 创建治理合约
    /// @param _governanceToken 治理代币合约地址
    /// @dev 治理代币用于确定投票权
    constructor(address _governanceToken) {
        governanceToken = IERC20(_governanceToken);
    }

    // ==================== 核心功能 ====================
    
    /// @notice 创建新提案
    /// @param _description 提案描述
    /// @param _targets 要调用的目标合约地址数组
    /// @param _data 每个目标合约的调用数据数组
    /// @return 新创建的提案 ID
    /// @dev 需要支付 PROPOSAL_DEPOSIT 押金防止垃圾提案
    /// @dev targets 和 data 数组长度必须相同
    function createProposal(
        string memory _description,
        address[] memory _targets,
        bytes[] memory _data
    ) external returns (uint256) {
        // 1. 收取押金防止垃圾提案
        // 提案者需要授权合约转移其代币
        require(
            governanceToken.transferFrom(msg.sender, address(this), PROPOSAL_DEPOSIT),
            "Deposit failed"
        );
        
        // 2. 创建提案
        proposalCount++;
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.id = proposalCount;
        newProposal.proposer = msg.sender;
        newProposal.description = _description;
        // 设置投票截止时间为当前时间 + 投票期
        newProposal.deadline = block.timestamp + VOTING_PERIOD;
        newProposal.executionTargets = _targets;
        newProposal.executionData = _data;
        
        // 触发提案创建事件
        emit ProposalCreated(proposalCount, msg.sender, _description);
        return proposalCount;
    }

    /// @notice 对提案进行投票
    /// @param _proposalId 要投票的提案 ID
    /// @param _support 是否赞成（true=赞成，false=反对）
    /// @dev 投票权重 = 投票者持有的治理代币数量
    /// @dev 每个地址只能投一次票
    function vote(uint256 _proposalId, bool _support) external {
        Proposal storage proposal = proposals[_proposalId];
        
        // 1. 验证检查
        // 检查投票期是否未结束
        require(block.timestamp < proposal.deadline, "Voting period ended");
        // 检查用户是否未投过票
        require(!proposal.hasVoted[msg.sender], "Already voted");
        // 检查提案是否未被执行
        require(!proposal.executed, "Already executed");
        
        // 2. 获取投票者的代币余额作为投票权重
        // 1 代币 = 1 票，代币越多投票权越大
        uint256 weight = governanceToken.balanceOf(msg.sender);
        require(weight > 0, "No voting power");
        
        // 3. 记录投票
        proposal.hasVoted[msg.sender] = true;
        
        // 根据支持/反对分别累加票数
        if (_support) {
            proposal.votesFor += weight;
        } else {
            proposal.votesAgainst += weight;
        }
        
        // 触发投票事件
        emit Voted(_proposalId, msg.sender, _support, weight);
    }

    /// @notice 最终确定提案（进入时间锁）
    /// @param _proposalId 要最终确定的提案 ID
    /// @dev 任何人都可以调用，不限于提案创建者
    /// @dev 检查投票结果和法定人数
    function finalize(uint256 _proposalId) external {
        Proposal storage proposal = proposals[_proposalId];
        
        // 检查投票期已结束
        require(block.timestamp >= proposal.deadline, "Voting still active");
        // 检查提案未被执行
        require(!proposal.executed, "Already executed");
        
        // 计算法定人数
        // 法定人数 = 总供应量 × 法定人数百分比 / 100
        uint256 totalSupply = governanceToken.totalSupply();
        uint256 quorumRequired = (totalSupply * QUORUM_PERCENTAGE) / 100;
        uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
        
        // 检查是否达到法定人数（足够多的人参与了投票）
        require(totalVotes >= quorumRequired, "Quorum not met");
        // 检查赞成票是否多于反对票
        require(proposal.votesFor > proposal.votesAgainst, "Proposal rejected");
        
        // 设置执行时间（当前时间 + 时间锁定期）
        proposal.executionTime = block.timestamp + TIMELOCK_PERIOD;
    }

    /// @notice 执行已通过时间锁的提案
    /// @param _proposalId 要执行的提案 ID
    /// @dev 使用 nonReentrant 防止重入攻击
    /// @dev 执行所有预设的合约调用
    function execute(uint256 _proposalId) external nonReentrant {
        Proposal storage proposal = proposals[_proposalId];
        
        // 检查提案已通过 finalize（executionTime > 0）
        require(proposal.executionTime > 0, "Not finalized");
        // 检查时间锁已过期
        require(block.timestamp >= proposal.executionTime, "Timelock active");
        // 检查提案未被执行
        require(!proposal.executed, "Already executed");
        
        // 标记提案为已执行
        proposal.executed = true;
        
        // 执行所有预设的调用
        // 遍历所有目标地址和调用数据
        for (uint256 i = 0; i < proposal.executionTargets.length; i++) {
            // 使用 low-level call 执行调用
            (bool success, ) = proposal.executionTargets[i].call(proposal.executionData[i]);
            require(success, "Execution failed");
        }
        
        // 将押金退还给提案创建者
        governanceToken.transfer(proposal.proposer, PROPOSAL_DEPOSIT);
        
        // 触发提案执行事件
        emit ProposalExecuted(_proposalId);
    }
}

// ==================== 合约设计要点说明 ====================
//
// 1. DAO 治理核心概念:
//    - 去中心化自治组织（DAO）: 由代码和代币持有者共同管理的组织
//    - 提案（Proposal）: 社区成员提出的改进或行动建议
//    - 投票权（Voting Power）: 由治理代币持有量决定
//    - 法定人数（Quorum）: 提案通过所需的最小参与率
//    - 时间锁（Timelock）: 提案通过后到执行的延迟期
//
// 2. 提案生命周期:
//    
//    创建提案 → 投票期（3天） → 最终确定 → 时间锁（2天） → 执行
//       ↓
//    支付押金
//
//    各阶段说明:
//    - 创建: 支付押金，设置提案内容和执行操作
//    - 投票期: 代币持有者投票（赞成/反对）
//    - 最终确定: 检查是否达到法定人数和多数赞成
//    - 时间锁: 给用户时间审查和准备（如需要退出）
//    - 执行: 执行提案中的操作，退还押金
//
// 3. 投票机制:
//    - 1 代币 = 1 票（线性投票）
//    - 代币余额快照在投票时获取
//    - 每个地址只能投一次票
//    - 投票不可撤销或更改
//
// 4. 使用流程:
//    创建提案:
//    1. 准备提案描述和执行操作（targets + data）
//    2. 授权合约使用押金: governanceToken.approve(govAddress, 100e18)
//    3. 调用 createProposal(description, targets, data)
//    
//    投票:
//    1. 持有治理代币
//    2. 调用 vote(proposalId, support) 投票
//    
//    执行提案:
//    1. 等待投票期结束
//    2. 任何人调用 finalize(proposalId) 进入时间锁
//    3. 等待时间锁过期（2天）
//    4. 任何人调用 execute(proposalId) 执行
//
// 5. 安全机制:
//    - ReentrancyGuard: 防止执行阶段的重入攻击
//    - 时间锁: 给用户时间审查通过的提案
//    - 押金机制: 防止垃圾提案
//    - 法定人数: 确保足够参与度
//    - 多数决: 需要赞成票多于反对票
//
// 6. 与真实 DAO 的区别:
//    - 本合约使用简单的时间锁
//    - 真实 DAO（如 Compound、Uniswap）有更复杂的委托投票机制
//    - 真实 DAO 通常有提案阈值（需要持有一定数量代币才能提案）
//    - 真实 DAO 可能有投票委托（delegation）功能
//
// 7. 潜在问题:
//    - 没有取消提案的功能
//    - 投票期间代币转移不影响已投票数（可能被利用）
//    - 没有紧急暂停功能
//    - 执行失败时押金仍会被退还
//
// 8. 关键知识点:
//    - DAO 治理模型
//    - 时间锁安全机制
//    - 低级别调用（low-level call）
//    - 代币治理模式
//
