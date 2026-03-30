// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title DecentralizedGovernance
 * @dev 构建完整的DAO治理系统：提案、投票、法定人数检查与时间锁执行
 * 文件名: day28_governance.sol
 */
contract day28_governance is ReentrancyGuard {
    IERC20 public governanceToken; // 治理代币（用于加权投票）
    
    struct Proposal {
        address proposer;       // 提案人
        string description;     // 提案描述
        uint256 forVotes;       // 赞成票权重
        uint256 againstVotes;   // 反对票权重
        uint256 startTime;      // 投票开始时间
        uint256 endTime;        // 投票结束时间
        bool executed;          // 是否已执行
        bool canceled;          // 是否已取消
        uint256 timelockEnd;    // 时间锁到期时间戳（0表示未进入时间锁）
    }
    
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted; // 记录用户是否已投过票
    
    uint256 public nextProposalId;
    uint256 public votingDuration;      // 投票持续时间
    uint256 public timelockDuration;    // 时间锁持续时间
    uint256 public quorumPercentage;    // 法定人数百分比 (如 4 代表 4%)
    uint256 public proposalDepositAmount; // 创建提案需缴纳的押金
    
    address public admin; // 治理合约管理员（用于调整参数）
    
    // 事件
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);
    event ProposalTimelockStarted(uint256 indexed proposalId, uint256 availableAt);
    event ProposalExecuted(uint256 indexed proposalId);
    event QuorumNotMet(uint256 indexed proposalId);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }
    
    constructor(
        address _governanceToken,
        uint256 _votingDuration,
        uint256 _timelockDuration,
        uint256 _quorumPercentage,
        uint256 _proposalDepositAmount
    ) {
        require(_governanceToken != address(0), "Invalid token");
        require(_quorumPercentage > 0 && _quorumPercentage <= 100, "Invalid quorum");
        
        governanceToken = IERC20(_governanceToken);
        votingDuration = _votingDuration;
        timelockDuration = _timelockDuration;
        quorumPercentage = _quorumPercentage;
        proposalDepositAmount = _proposalDepositAmount;
        admin = msg.sender;
    }
    
    // --- 核心功能 ---

    /**
     * @dev 创建提案
     * 用户需要转入押金以防止垃圾提案
     */
    function createProposal(string memory description) external returns (uint256) {
        require(bytes(description).length > 0, "Empty description");
        
        // 收取提案押金（需先approve）
        if (proposalDepositAmount > 0) {
            require(governanceToken.transferFrom(msg.sender, address(this), proposalDepositAmount), "Deposit failed");
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
    
    /**
     * @dev 投票
     * 权重 = 投票时用户的代币余额
     */
    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];
        
        require(block.timestamp <= proposal.endTime, "Voting ended");
        require(!proposal.executed && !proposal.canceled, "Proposal finalized or canceled");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        
        uint256 weight = governanceToken.balanceOf(msg.sender);
        require(weight > 0, "No voting power");
        
        hasVoted[proposalId][msg.sender] = true;
        
        if (support) {
            proposal.forVotes += weight;
        } else {
            proposal.againstVotes += weight;
        }
        
        emit Voted(proposalId, msg.sender, support, weight);
    }
    
    /**
     * @dev 结算提案：检查法定人数并开启时间锁
     */
    function finalizeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        
        require(block.timestamp > proposal.endTime, "Voting not ended");
        require(proposal.timelockEnd == 0, "Already finalized");
        require(!proposal.canceled, "Canceled");
        
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
        uint256 totalSupply = governanceToken.totalSupply();
        uint256 quorumRequired = (totalSupply * quorumPercentage) / 100;
        
        // 检查法定人数且赞成票 > 反对票
        if (totalVotes >= quorumRequired && proposal.forVotes > proposal.againstVotes) {
            proposal.timelockEnd = block.timestamp + timelockDuration;
            emit ProposalTimelockStarted(proposalId, proposal.timelockEnd);
        } else {
            proposal.canceled = true;
            // 失败的提案不退押金或由社区决定，此处演示简单处理
            emit QuorumNotMet(proposalId);
        }
    }
    
    /**
     * @dev 执行提案
     * 必须在时间锁结束后执行
     */
    function executeProposal(uint256 proposalId) external nonReentrant {
        Proposal storage proposal = proposals[proposalId];
        
        require(proposal.timelockEnd > 0, "Proposal not passed");
        require(block.timestamp >= proposal.timelockEnd, "In timelock");
        require(!proposal.executed, "Already executed");
        
        proposal.executed = true;
        
        // 提案通过并执行后，退还押金给提案人
        if (proposalDepositAmount > 0) {
            require(governanceToken.transfer(proposal.proposer, proposalDepositAmount), "Refund failed");
        }
        
        emit ProposalExecuted(proposalId);
        
        // 在实际DAO中，此处通常会通过 abi.call 执行具体的目标合约操作
    }

    // --- 管理函数 ---

    function updateParams(uint256 _votingDuration, uint256 _timelockDuration, uint256 _quorum) external onlyAdmin {
        votingDuration = _votingDuration;
        timelockDuration = _timelockDuration;
        quorumPercentage = _quorum;
    }
}