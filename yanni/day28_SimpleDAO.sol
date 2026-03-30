// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// 防重入攻击保护
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title 去中心化治理合约（DAO风格）
contract DecentralizedGovernance is ReentrancyGuard {
    IERC20 public governanceToken; // 治理代币，用于投票权重

    // ===== 提案结构体 =====
    struct Proposal {
        address proposer;    // 提案人
        string description;  // 提案内容描述
        uint256 forVotes;    // 支持票数
        uint256 againstVotes;// 反对票数
        uint256 startTime;   // 投票开始时间
        uint256 endTime;     // 投票结束时间
        bool executed;       // 提案是否已执行
        bool canceled;       // 提案是否被取消
        uint256 timelockEnd; // 时间锁结束时间
    }

    mapping(uint256 => Proposal) public proposals;                     // 提案ID -> 提案信息
    mapping(uint256 => mapping(address => bool)) public hasVoted;      // 提案ID -> 用户是否已投票

    uint256 public nextProposalId;     // 下一个提案ID
    uint256 public votingDuration;     // 投票持续时间
    uint256 public timelockDuration;   // 执行前时间锁
    address public admin;              // 管理员
    uint256 public quorumPercentage;   // 最低投票率门槛（百分比）
    uint256 public proposalDepositAmount; // 创建提案需要押金

    // ===== 事件 =====
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId);
    event QuorumNotMet(uint256 indexed proposalId);
    event ProposalTimelockStarted(uint256 indexed proposalId);

    // ===== 管理员权限修饰器 =====
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    // ===== 构造函数 =====
    constructor(
        address _governanceToken,
        uint256 _votingDuration,
        uint256 _timelockDuration,
        uint256 _quorumPercentage,
        uint256 _proposalDepositAmount
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

    // ===== 创建提案 =====
    function createProposal(string memory description) external returns (uint256) {
        require(bytes(description).length > 0, "Empty description");

        // 如果设置了押金，提案人需要支付押金
        if (proposalDepositAmount > 0) {
            governanceToken.transferFrom(msg.sender, address(this), proposalDepositAmount);
        }

        uint256 proposalId = nextProposalId++;
        proposals[proposalId] = Proposal({
            proposer: msg.sender,
            description: description,
            forVotes: 0,
            againstVotes: 0,
            startTime: block.timestamp,
            endTime: block.timestamp + votingDuration,
            executed: false,
            canceled: false,
            timelockEnd: 0
        });

        emit ProposalCreated(proposalId, msg.sender, description);
        return proposalId;
    }

    // ===== 投票 =====
    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];

        require(block.timestamp >= proposal.startTime, "Not started");
        require(block.timestamp <= proposal.endTime, "Ended");
        require(!proposal.executed, "Already executed");
        require(!proposal.canceled, "Canceled");
        require(!hasVoted[proposalId][msg.sender], "Already voted");

        uint256 weight = governanceToken.balanceOf(msg.sender); // 投票权重 = 持有代币数量
        require(weight > 0, "No voting power");

        hasVoted[proposalId][msg.sender] = true;

        if (support) {
            proposal.forVotes += weight; // 支持票加权
        } else {
            proposal.againstVotes += weight; // 反对票加权
        }

        emit Voted(proposalId, msg.sender, support, weight);
    }

    // ===== 完成提案（进入时间锁或取消） =====
    function finalizeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Voting not ended");
        require(!proposal.executed, "Already executed");
        require(!proposal.canceled, "Canceled");

        uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
        uint256 totalSupply = governanceToken.totalSupply();
        uint256 quorumRequired = (totalSupply * quorumPercentage) / 100;

        if (totalVotes >= quorumRequired && proposal.forVotes > proposal.againstVotes) {
            // 提案通过，设置时间锁
            if (timelockDuration > 0) {
                proposal.timelockEnd = block.timestamp + timelockDuration;
                emit ProposalTimelockStarted(proposalId);
            } else {
                proposal.executed = true;
                _refundDeposit(proposalId);
                emit ProposalExecuted(proposalId);
            }
        } else {
            // 未达到法定票数或未通过
            proposal.canceled = true;
            emit QuorumNotMet(proposalId);
        }
    }

    // ===== 执行提案 =====
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];

        require(proposal.timelockEnd > 0, "No timelock set");
        require(block.timestamp >= proposal.timelockEnd, "Timelock not ended");
        require(!proposal.executed, "Already executed");
        require(!proposal.canceled, "Canceled");

        proposal.executed = true;
        _refundDeposit(proposalId); // 退还提案押金
        emit ProposalExecuted(proposalId);
    }

    // ===== 内部函数：退还提案押金 =====
    function _refundDeposit(uint256 proposalId) internal {
        if (proposalDepositAmount > 0) {
            Proposal storage proposal = proposals[proposalId];
            governanceToken.transfer(proposal.proposer, proposalDepositAmount);
        }
    }

    // ===== 查看提案结果 =====
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

    // ===== 管理员设置参数 =====
    function setQuorumPercentage(uint256 _newQuorum) external onlyAdmin {
        require(_newQuorum > 0 && _newQuorum <= 100, "Invalid quorum");
        quorumPercentage = _newQuorum;
    }

    function setProposalDepositAmount(uint256 _newAmount) external onlyAdmin {
        proposalDepositAmount = _newAmount;
    }
}

//改进方案:混合或衰减机制
///1、Quadratic Voting（平方根投票）
///优点：减少大户权力集中，同时仍保留经济激励。
///2、时间锁定投票（Token Locking / Vesting）
///持币时间越长，权重越高，鼓励长期投资和治理参与。
///3、贡献权重叠加
///将社区贡献（代码、宣传、管理等）转化为治理权重，而不仅仅是代币数量。
///4、多代币 / 社区代币分层
///用一种基础代币参与投票，另一种用于经济收益，分开治理权力和经济利益。