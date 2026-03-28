// SPDX-License-Identifier: MIT                                 
pragma solidity ^0.8.20;                                       

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol"; // 导入投票代币工具
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";       // 导入安全锁，防止重复攻击

contract OptimizedDAO is ReentrancyGuard {                       // 创建DAO合约，带安全防护


ERC20Votes public governanceToken;                                // 治理代币（有投票权）
address public admin;                                            // 管理员

uint256 public votingDuration;        // 投票持续时间（秒）
uint256 public timelockDuration;      // 执行等待时间（秒）
uint256 public quorumPercentage;      // 投票通过最低比例（%）
uint256 public proposalDepositAmount; // 提交提案需要押金
uint256 public proposalThreshold;     // 提交提案最少持币数量
uint256 public nextProposalId;        // 下一个提案编号


// 结构体拆分
struct ProposalCore {                                             // 提案基本信息
    address proposer;                                             // 提案人
    string description;                                           // 提案内容
    uint256 startTime;                                            // 投票开始时间
    uint256 endTime;                                              // 投票结束时间
    bool executed;                                                // 是否已执行
    bool canceled;                                                // 是否已取消
    uint256 snapshotBlock;                                        // 投票权重快照区块
}

// 投票信息
struct ProposalVote {                                             // 投票数据
    uint256 forVotes;                                            // 赞成票数
    uint256 againstVotes;                                         // 反对票数
}

// 执行信息
struct ProposalExecution {                                       // 提案执行内容
    uint256 timelockEnd;                                         // 时间锁结束时间
    address target;                                              // 要调用的目标合约
    uint256 value;                                               // 转账ETH数量
    bytes data;                                                  // 调用数据
}


// Mappings
mapping(uint256 => ProposalCore) public proposalCore;            // 提案编号 => 核心信息
mapping(uint256 => ProposalVote) public proposalVotes;           // 提案编号 => 投票信息
mapping(uint256 => ProposalExecution) public proposalExec;       // 提案编号 => 执行信息
mapping(uint256 => mapping(address => bool)) public hasVoted;    // 记录谁投过票


//事件定义
event ProposalCreated(uint256 indexed id, address proposer);     // 提案创建
event Voted(uint256 indexed id, address voter, bool support, uint256 weight); // 投票
event ProposalFinalized(uint256 indexed id, bool passed);         // 投票结束
event ProposalExecuted(uint256 indexed id);                      // 提案执行
event ProposalCanceled(uint256 indexed id);                      // 提案取消


//构造函数 
constructor(                                                      // 部署合约时初始化
    address _token,                                              // 治理代币地址
    uint256 _votingDuration,                                     // 投票时长
    uint256 _timelockDuration,                                   // 执行等待时间
    uint256 _quorumPercentage,                                   // 最低通过比例
    uint256 _proposalDepositAmount,                              // 提案押金
    uint256 _proposalThreshold                                   // 提案最低持币量
) {
    require(_token != address(0), "Invalid token");              // 代币地址不能为空
    require(_votingDuration > 0, "Invalid voting duration");     // 投票时长必须大于0
    require(_quorumPercentage > 0 && _quorumPercentage <= 100, "Invalid quorum"); // 比例合法

    governanceToken = ERC20Votes(_token);                        // 设置治理代币
    votingDuration = _votingDuration;                            // 保存投票时长
    timelockDuration = _timelockDuration;                        // 保存执行等待时间
    quorumPercentage = _quorumPercentage;                       // 保存通过比例
    proposalDepositAmount = _proposalDepositAmount;             // 保存押金
    proposalThreshold = _proposalThreshold;                     // 保存最低持币量
    admin = msg.sender;                                          // 部署者是管理员
}


//创建提案 
function createProposal(                                         // 用户提交提案
    string memory description,                                   // 提案内容
    address target,                                              // 目标合约
    uint256 value,                                               // 转账ETH
    bytes memory data                                            // 调用数据
) external returns (uint256) {
    require(bytes(description).length > 0, "Empty description"); // 提案内容不能为空
    require(governanceToken.balanceOf(msg.sender) >= proposalThreshold, "Not enough tokens"); // 持币达标

    if (proposalDepositAmount > 0) {                             // 如果需要押金
        require(
            governanceToken.transferFrom(msg.sender, address(this), proposalDepositAmount),
            "Deposit failed"                                      // 收取押金
        );
    }

    uint256 id = nextProposalId++;                               // 生成新提案编号

    proposalCore[id] = ProposalCore({                            // 保存提案核心信息
        proposer: msg.sender,
        description: description,
        startTime: block.timestamp,
        endTime: block.timestamp + votingDuration,
        executed: false,
        canceled: false,
        snapshotBlock: block.number
    });

    proposalVotes[id] = ProposalVote({forVotes: 0, againstVotes: 0}); // 初始化投票

    proposalExec[id] = ProposalExecution({                       // 保存执行信息
        timelockEnd: 0,
        target: target,
        value: value,
        data: data
    });

    emit ProposalCreated(id, msg.sender);                        // 广播：提案创建
    return id;
}


// 投票函数
function vote(uint256 id, bool support) external {               // 投票：支持/反对
    ProposalCore storage pCore = proposalCore[id];               // 获取提案信息
    ProposalVote storage pVote = proposalVotes[id];             // 获取投票数据

    require(block.timestamp >= pCore.startTime, "Not started"); // 投票未开始
    require(block.timestamp <= pCore.endTime, "Voting ended");  // 投票已结束
    require(!pCore.executed && !pCore.canceled, "Invalid state"); // 状态合法
    require(!hasVoted[id][msg.sender], "Already voted");         // 不能重复投票

    uint256 weight = governanceToken.getPastVotes(msg.sender, pCore.snapshotBlock); // 获取投票权重
    require(weight > 0, "No voting power");                     // 必须有投票权

    hasVoted[id][msg.sender] = true;                            // 标记已投票

    if (support) {                                              // 支持
        unchecked { pVote.forVotes += weight; }
    } else {                                                    // 反对
        unchecked { pVote.againstVotes += weight; }
    }

    emit Voted(id, msg.sender, support, weight);                // 广播：投票成功
}


//完成提案 
function finalizeProposal(uint256 id) external {                // 结束投票，统计结果
    ProposalCore storage pCore = proposalCore[id];
    ProposalVote storage pVote = proposalVotes[id];
    ProposalExecution storage pExec = proposalExec[id];

    require(block.timestamp > pCore.endTime, "Voting not ended"); // 投票必须结束
    require(!pCore.executed && !pCore.canceled, "Invalid state");
    require(pExec.timelockEnd == 0, "Already finalized");

    uint256 totalVotes = pVote.forVotes + pVote.againstVotes;   // 总票数
    uint256 totalSupply = governanceToken.getPastTotalSupply(pCore.snapshotBlock); // 总代币
    uint256 quorum = (totalSupply * quorumPercentage) / 100;    // 最低通过票数

    bool passed = totalVotes >= quorum && pVote.forVotes > pVote.againstVotes; // 是否通过

    if (passed) {                                                // 通过
        if (timelockDuration > 0) {                              // 有等待时间
            pExec.timelockEnd = block.timestamp + timelockDuration;
        } else {                                                 // 无等待，直接执行
            _execute(id);
        }
    } else {                                                     // 未通过
        pCore.canceled = true;
        emit ProposalCanceled(id);
    }

    emit ProposalFinalized(id, passed);                          // 广播：投票结束
}


//执行提案
function executeProposal(uint256 id) external nonReentrant {     // 执行通过的提案
    ProposalCore storage pCore = proposalCore[id];
    ProposalExecution storage pExec = proposalExec[id];

    require(!pCore.executed && !pCore.canceled, "Invalid state");
    require(pExec.timelockEnd > 0, "No timelock set");
    require(block.timestamp >= pExec.timelockEnd, "Timelock active"); // 等待时间结束

    _execute(id);                                                // 执行
}

function _execute(uint256 id) internal {                         // 内部执行函数
    ProposalCore storage pCore = proposalCore[id];
    ProposalExecution storage pExec = proposalExec[id];

    pCore.executed = true;                                       // 标记已执行

    (bool success, ) = pExec.target.call{value: pExec.value}(pExec.data); // 调用执行
    require(success, "Execution failed");                        // 执行成功

    _refundDeposit(id);                                          // 退还押金

    emit ProposalExecuted(id);                                   // 广播：执行成功
}


//  押金退款
function _refundDeposit(uint256 id) internal {                  // 退还提案押金
    if (proposalDepositAmount > 0) {
        ProposalCore storage pCore = proposalCore[id];
        require(governanceToken.transfer(pCore.proposer, proposalDepositAmount), "Refund failed");
    }
}


//管理员函数 
function setQuorum(uint256 _q) external onlyAdmin {            // 修改最低通过比例
    require(_q > 0 && _q <= 100, "Invalid quorum");
    quorumPercentage = _q;
}

function setThreshold(uint256 _t) external onlyAdmin {          // 修改提案最低持币量
    proposalThreshold = _t;
}

modifier onlyAdmin() {                                          // 管理员权限
    require(msg.sender == admin, "Not admin");
    _;
}
}
//这是一个去中心化自治组织（DAO）
//持币用户可以提交提案、投票决定项目方向
//投票通过后等待一段时间自动执行
//提交提案要押押金，执行成功后退还