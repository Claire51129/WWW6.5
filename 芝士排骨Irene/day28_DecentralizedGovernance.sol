// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// 去中心化治理合约
// 核心逻辑：持有治理代币的人可以提案、投票、执行决策
contract DecentralizedGovernance is ReentrancyGuard {

    IERC20 public governanceToken;  // 治理代币（持有它才有投票权）

    // 提案结构体
    struct Proposal {
        address proposer;       // 提案人
        string description;     // 提案描述
        uint256 forVotes;       // 赞成票（按代币数量加权）
        uint256 againstVotes;   // 反对票（按代币数量加权）
        uint256 startTime;      // 投票开始时间
        uint256 endTime;        // 投票结束时间
        bool executed;          // 是否已执行
        bool canceled;          // 是否已取消
        uint256 timelockEnd;    // 时间锁结束时间（通过后不能立刻执行，要等一段时间）
    }

    // 提案 ID => 提案详情
    mapping(uint256 => Proposal) public proposals;
    // 提案 ID => (投票者地址 => 是否已投票)，防止重复投票
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    uint256 public nextProposalId;          // 下一个提案 ID
    uint256 public votingDuration;          // 投票持续时间（秒）
    uint256 public timelockDuration;        // 时间锁时长（秒），通过的提案要等这么久才能执行
    address public admin;                    // 管理员
    uint256 public quorumPercentage;        // 法定人数比例（总投票数需达到总供应量的百分之几才有效）
    uint256 public proposalDepositAmount;   // 提案押金（防止垃圾提案，通过后退还）

    // 事件
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId);
    event QuorumNotMet(uint256 indexed proposalId);                // 未达法定人数
    event ProposalTimelockStarted(uint256 indexed proposalId);     // 进入时间锁

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    // 构造函数
    constructor(
        address _governanceToken,       // 治理代币地址
        uint256 _votingDuration,        // 投票时长
        uint256 _timelockDuration,      // 时间锁时长
        uint256 _quorumPercentage,      // 法定人数百分比（1-100）
        uint256 _proposalDepositAmount  // 提案押金数量
    ) {
        require(_governanceToken != address(0), "Invalid token");
        require(_votingDuration > 0, "Invalid duration");
        require(_quorumPercentage > 0 && _quorumPercentage <= 100, "Invalid quorum");

        governanceToken = IERC20(_governanceToken);
        votingDuration = _votingDuration;
        timelockDuration = _timelockDuration;
        admin = msg.sender;
        quorumPercentage = _quorumPercentage;
        proposalDepositAmount = _proposalDepositAmount;
    }

    // 创建提案 - 任何持币者都可以发起
    function createProposal(string memory description) external returns (uint256) {
        require(bytes(description).length > 0, "Empty description");

        // 收取提案押金
        if (proposalDepositAmount > 0) {
            governanceToken.transferFrom(msg.sender, address(this), proposalDepositAmount);
        }

        uint256 proposalId = nextProposalId++;  // 分配 ID 后自增

        proposals[proposalId] = Proposal({
            proposer: msg.sender,
            description: description,
            forVotes: 0,
            againstVotes: 0,
            startTime: block.timestamp,                      // 立即开始投票
            endTime: block.timestamp + votingDuration,       // 投票截止时间
            executed: false,
            canceled: false,
            timelockEnd: 0                                   // 还没进入时间锁
        });

        emit ProposalCreated(proposalId, msg.sender, description);
        return proposalId;
    }

    // 投票 - 持币者对提案投赞成或反对票
    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];

        require(block.timestamp >= proposal.startTime, "Not started");     // 投票已开始
        require(block.timestamp <= proposal.endTime, "Ended");             // 投票未结束
        require(!proposal.executed, "Already executed");                    // 提案未执行
        require(!proposal.canceled, "Canceled");                           // 提案未取消
        require(!hasVoted[proposalId][msg.sender], "Already voted");       // 没有重复投票

        // 投票权重 = 当前持有的治理代币数量
        uint256 weight = governanceToken.balanceOf(msg.sender);
        require(weight > 0, "No voting power");  // 没有代币就没有投票权

        hasVoted[proposalId][msg.sender] = true;  // 标记已投票

        // support = true 投赞成，false 投反对
        if (support) {
            proposal.forVotes += weight;
        } else {
            proposal.againstVotes += weight;
        }

        emit Voted(proposalId, msg.sender, support, weight);
    }

    // 提案定稿 - 投票结束后判断提案是否通过
    function finalizeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];

        require(block.timestamp > proposal.endTime, "Voting not ended");
        require(!proposal.executed, "Already executed");
        require(!proposal.canceled, "Canceled");

        // 计算是否达到法定人数
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
        uint256 totalSupply = governanceToken.totalSupply();
        uint256 quorumRequired = (totalSupply * quorumPercentage) / 100;

        if (totalVotes >= quorumRequired && proposal.forVotes > proposal.againstVotes) {
            // 提案通过
            if (timelockDuration > 0) {
                // 有时间锁：不能立刻执行，进入等待期
                // 时间锁的目的：给反对者一个缓冲期，如果通过了恶意提案
                // 持币者有时间卖币退出，避免被恶意治理伤害
                proposal.timelockEnd = block.timestamp + timelockDuration;
                emit ProposalTimelockStarted(proposalId);
            } else {
                // 没有时间锁：直接执行
                proposal.executed = true;
                _refundDeposit(proposalId);  // 退还提案押金
                emit ProposalExecuted(proposalId);
            }
        } else {
            // 提案未通过（未达法定人数或反对票更多）
            proposal.canceled = true;
            // 注意：未通过的提案押金不退还，这是防止垃圾提案的惩罚机制
            emit QuorumNotMet(proposalId);
        }
    }

    // 执行提案 - 时间锁结束后执行通过的提案
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];

        require(proposal.timelockEnd > 0, "No timelock set");               // 必须已进入时间锁
        require(block.timestamp >= proposal.timelockEnd, "Timelock not ended"); // 时间锁已到期
        require(!proposal.executed, "Already executed");
        require(!proposal.canceled, "Canceled");

        proposal.executed = true;
        _refundDeposit(proposalId);  // 退还提案押金给提案人

        emit ProposalExecuted(proposalId);
    }

    // 退还提案押金 - 内部函数
    function _refundDeposit(uint256 proposalId) internal {
        if (proposalDepositAmount > 0) {
            Proposal storage proposal = proposals[proposalId];
            governanceToken.transfer(proposal.proposer, proposalDepositAmount);
        }
    }

    // 查询提案结果
    function getProposalResult(uint256 proposalId) external view returns (
        bool passed,
        uint256 forVotes,
        uint256 againstVotes,
        bool executed
    ) {
        Proposal memory proposal = proposals[proposalId];
        passed = proposal.forVotes > proposal.againstVotes;
        return (passed, proposal.forVotes, proposal.againstVotes, proposal.executed);
    }

    // 管理员修改法定人数比例
    function setQuorumPercentage(uint256 _newQuorum) external onlyAdmin {
        require(_newQuorum > 0 && _newQuorum <= 100, "Invalid quorum");
        quorumPercentage = _newQuorum;
    }

    // 管理员修改提案押金数量
    function setProposalDepositAmount(uint256 _newAmount) external onlyAdmin {
        proposalDepositAmount = _newAmount;
    }
}