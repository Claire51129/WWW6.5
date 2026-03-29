// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract OptimizedDAO is ReentrancyGuard {
    // ===== 数据存储 =====

    ERC20Votes public governanceToken; // 治理代币（必须支持历史投票权）
    address public admin; // 管理员

    uint256 public votingDuration;        // 投票持续时间（秒）
    uint256 public timelockDuration;      // 提案通过后的时间锁（秒）
    uint256 public quorumPercentage;      // 法定人数比例（百分比）
    uint256 public proposalDepositAmount; // 提案押金
    uint256 public proposalThreshold;     // 发起提案的最低持币门槛
    uint256 public nextProposalId;        // 下一个提案 ID

    // ===== 结构体 =====

    struct ProposalCore {
        address proposer;      // 提案发起人
        string description;    // 提案描述
        uint256 startTime;     // 投票开始时间
        uint256 endTime;       // 投票结束时间
        bool executed;         // 是否已执行
        bool canceled;         // 是否已取消
        uint256 snapshotBlock; // 快照区块，用来固定投票权
    }

    struct ProposalVote {
        uint256 forVotes;      // 赞成票
        uint256 againstVotes;  // 反对票
    }

    struct ProposalExecution {
        uint256 timelockEnd; // 时间锁结束时间
        address target;      // 执行目标地址
        uint256 value;       // 执行时附带的 ETH 数量
        bytes data;          // 调用数据
    }

    // ===== Mappings =====

    mapping(uint256 => ProposalCore) public proposalCore; // 提案 ID => 核心信息
    mapping(uint256 => ProposalVote) public proposalVotes; // 提案 ID => 投票统计
    mapping(uint256 => ProposalExecution) public proposalExec; // 提案 ID => 执行信息
    mapping(uint256 => mapping(address => bool)) public hasVoted; // 提案 ID => 地址 => 是否投过票

    // ===== 事件 =====

    event ProposalCreated(uint256 indexed id, address proposer);
    event Voted(uint256 indexed id, address voter, bool support, uint256 weight);
    event ProposalFinalized(uint256 indexed id, bool passed);
    event ProposalExecuted(uint256 indexed id);
    event ProposalCanceled(uint256 indexed id);

    // ===== 构造函数 =====

    constructor(
        address _token,
        uint256 _votingDuration,
        uint256 _timelockDuration,
        uint256 _quorumPercentage,
        uint256 _proposalDepositAmount,
        uint256 _proposalThreshold
    ) {
        require(_token != address(0), "Invalid token");
        require(_votingDuration > 0, "Invalid voting duration");
        require(_quorumPercentage > 0 && _quorumPercentage <= 100, "Invalid quorum");

        governanceToken = ERC20Votes(_token);
        votingDuration = _votingDuration;
        timelockDuration = _timelockDuration;
        quorumPercentage = _quorumPercentage;
        proposalDepositAmount = _proposalDepositAmount;
        proposalThreshold = _proposalThreshold;
        admin = msg.sender;
    }

    // ===== 创建提案 =====

    function createProposal(
        string memory description,
        address target,
        uint256 value,
        bytes memory data
    ) external returns (uint256) {
        require(bytes(description).length > 0, "Empty description");
        require(governanceToken.balanceOf(msg.sender) >= proposalThreshold, "Not enough tokens");

        // 如果设置了提案押金，先把押金转进合约
        if (proposalDepositAmount > 0) {
            require(
                governanceToken.transferFrom(msg.sender, address(this), proposalDepositAmount),
                "Deposit failed"
            );
        }

        uint256 id = nextProposalId++;

        // 记录提案核心信息
        proposalCore[id] = ProposalCore({
            proposer: msg.sender,
            description: description,
            startTime: block.timestamp,
            endTime: block.timestamp + votingDuration,
            executed: false,
            canceled: false,
            snapshotBlock: block.number
        });

        // 初始化投票统计
        proposalVotes[id] = ProposalVote({
            forVotes: 0,
            againstVotes: 0
        });

        // 保存后续执行所需的信息
        proposalExec[id] = ProposalExecution({
            timelockEnd: 0,
            target: target,
            value: value,
            data: data
        });

        emit ProposalCreated(id, msg.sender);
        return id;
    }

    // ===== 投票 =====

    function vote(uint256 id, bool support) external {
        ProposalCore storage pCore = proposalCore[id];
        ProposalVote storage pVote = proposalVotes[id];

        require(block.timestamp >= pCore.startTime, "Not started");
        require(block.timestamp <= pCore.endTime, "Voting ended");
        require(!pCore.executed && !pCore.canceled, "Invalid state");
        require(!hasVoted[id][msg.sender], "Already voted");

        // 用快照区块读取历史投票权，避免临时买币刷票
        uint256 weight = governanceToken.getPastVotes(msg.sender, pCore.snapshotBlock);
        require(weight > 0, "No voting power");

        hasVoted[id][msg.sender] = true;

        if (support) {
            unchecked {
                pVote.forVotes += weight;
            }
        } else {
            unchecked {
                pVote.againstVotes += weight;
            }
        }

        emit Voted(id, msg.sender, support, weight);
    }

    // ===== 完成提案 / 结算 =====

    function finalizeProposal(uint256 id) external {
        ProposalCore storage pCore = proposalCore[id];
        ProposalVote storage pVote = proposalVotes[id];
        ProposalExecution storage pExec = proposalExec[id];

        require(block.timestamp > pCore.endTime, "Voting not ended");
        require(!pCore.executed && !pCore.canceled, "Invalid state");
        require(pExec.timelockEnd == 0, "Already finalized");

        uint256 totalVotes = pVote.forVotes + pVote.againstVotes;

        // 读取快照时刻的总代币供应量
        uint256 totalSupply = governanceToken.getPastTotalSupply(pCore.snapshotBlock);

        // 计算法定人数门槛
        uint256 quorum = (totalSupply * quorumPercentage) / 100;

        // 通过条件：
        // 1. 总投票数达到法定人数
        // 2. 赞成票大于反对票
        bool passed = totalVotes >= quorum && pVote.forVotes > pVote.againstVotes;

        if (passed) {
            if (timelockDuration > 0) {
                // 提案通过，但先进入时间锁
                pExec.timelockEnd = block.timestamp + timelockDuration;
            } else {
                // 没有时间锁就直接执行
                _execute(id);
            }
        } else {
            // 未通过则取消
            pCore.canceled = true;
            emit ProposalCanceled(id);
        }

        emit ProposalFinalized(id, passed);
    }

    // ===== 执行提案 =====

    function executeProposal(uint256 id) external nonReentrant {
        ProposalCore storage pCore = proposalCore[id];
        ProposalExecution storage pExec = proposalExec[id];

        require(!pCore.executed && !pCore.canceled, "Invalid state");
        require(pExec.timelockEnd > 0, "No timelock set");
        require(block.timestamp >= pExec.timelockEnd, "Timelock active");

        _execute(id);
    }

    function _execute(uint256 id) internal {
        ProposalCore storage pCore = proposalCore[id];
        ProposalExecution storage pExec = proposalExec[id];

        // 先标记已执行，防止重入
        pCore.executed = true;

        // 调用目标合约
        (bool success, ) = pExec.target.call{value: pExec.value}(pExec.data);
        require(success, "Execution failed");

        // 执行成功后退押金
        _refundDeposit(id);

        emit ProposalExecuted(id);
    }

    // ===== 退还押金 =====

    function _refundDeposit(uint256 id) internal {
        if (proposalDepositAmount > 0) {
            ProposalCore storage pCore = proposalCore[id];
            require(
                governanceToken.transfer(pCore.proposer, proposalDepositAmount),
                "Refund failed"
            );
        }
    }

    // ===== 管理员函数 =====

    function setQuorum(uint256 _q) external onlyAdmin {
        require(_q > 0 && _q <= 100, "Invalid quorum");
        quorumPercentage = _q;
    }

    function setThreshold(uint256 _t) external onlyAdmin {
        proposalThreshold = _t;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }
}