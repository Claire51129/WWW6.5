// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title DecentralizedGovernance
 * @notice 一个去中心化的治理合约。代币持有者可以创建提案、参与投票，并通过时间锁机制执行决策。
 * @dev 投票权重基于用户在调用 vote 函数时持有的治理代币余额。
 */
contract DecentralizedGovernance is ReentrancyGuard {
    IERC20 public governanceToken; // 用于投票的治理代币

    /**
     * @dev 提案结构体，记录提案生命周期内的所有核心状态
     */
    struct Proposal {
        address proposer;      // 发起人
        string description;    // 提案描述
        uint256 forVotes;      // 赞成票总权重
        uint256 againstVotes;  // 反对票总权重
        uint256 startTime;     // 投票开始时间戳
        uint256 endTime;       // 投票结束时间戳
        bool executed;         // 提案是否已最终执行
        bool canceled;         // 提案是否因未达法定人数或投票失败而作废
        uint256 timelockEnd;   // 时间锁结束的时间戳（0表示未进入时间锁）
    }

    // 状态变量
    mapping(uint256 => Proposal) public proposals; // 存储所有提案：ID => 详情
    mapping(uint256 => mapping(address => bool)) public hasVoted; // 防止重复投票：提案ID => 用户地址 => 是否已投

    uint256 public nextProposalId;       // 下一个提案的自增 ID
    uint256 public votingDuration;       // 投票持续时间（秒）
    uint256 public timelockDuration;     // 通过后到执行前的延迟时间（时间锁）
    address public admin;                // 管理员地址，用于调整核心治理参数
    uint256 public quorumPercentage;     // 法定人数百分比（需占总供应量的比例）
    uint256 public proposalDepositAmount;// 发起提案需要抵押的代币数量

    // 事件定义
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId);
    event QuorumNotMet(uint256 indexed proposalId);
    event ProposalTimelockStarted(uint256 indexed proposalId);

    /**
     * @dev 限制仅管理员（admin）可操作
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    /**
     * @param _governanceToken 治理代币地址
     * @param _votingDuration 投票时长
     * @param _timelockDuration 时间锁时长
     * @param _quorumPercentage 法定人数百分比 (1-100)
     * @param _proposalDepositAmount 发起提案需抵押的代币数
     */
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

    /**
     * @notice 发起一个新提案
     * @dev 如果设置了押金，会从用户地址转入合约，并在提案执行后退还
     * @param description 提案内容描述
     * @return proposalId 返回生成的提案 ID
     */
    function createProposal(string memory description) external returns (uint256) {
        require(bytes(description).length > 0, "Empty description");

        // 锁定押金，防止提案灌水
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

    /**
     * @notice 对提案进行投票
     * @param proposalId 提案 ID
     * @param support true 代表支持，false 代表反对
     */
    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];

        require(block.timestamp >= proposal.startTime, "Not started");
        require(block.timestamp <= proposal.endTime, "Ended");
        require(!proposal.executed, "Already executed");
        require(!proposal.canceled, "Canceled");
        require(!hasVoted[proposalId][msg.sender], "Already voted");

        // 获取用户当前的持币量作为投票权重
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
     * @notice 在投票结束后结算提案状态
     * @dev 检查是否满足法定人数（Quorum）及赞成票是否占优
     * @param proposalId 提案 ID
     */
    function finalizeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];

        require(block.timestamp > proposal.endTime, "Voting not ended");
        require(!proposal.executed, "Already executed");
        require(!proposal.canceled, "Canceled");

        uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
        uint256 totalSupply = governanceToken.totalSupply();
        uint256 quorumRequired = (totalSupply * quorumPercentage) / 100;

        // 只有达到法定人数且赞成票多于反对票才算通过
        if (totalVotes >= quorumRequired && proposal.forVotes > proposal.againstVotes) {
            if (timelockDuration > 0) {
                // 进入时间锁阶段
                proposal.timelockEnd = block.timestamp + timelockDuration;
                emit ProposalTimelockStarted(proposalId);
            } else {
                // 若无时间锁则直接执行
                proposal.executed = true;
                _refundDeposit(proposalId);
                emit ProposalExecuted(proposalId);
            }
        } else {
            // 未通过则标记为作废
            proposal.canceled = true;
            emit QuorumNotMet(proposalId);
        }
    }

    /**
     * @notice 执行已通过时间锁延迟的提案
     * @param proposalId 提案 ID
     */
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];

        require(proposal.timelockEnd > 0, "No timelock set");
        require(block.timestamp >= proposal.timelockEnd, "Timelock not ended");
        require(!proposal.executed, "Already executed");
        require(!proposal.canceled, "Canceled");

        proposal.executed = true;
        _refundDeposit(proposalId); // 成功后退还发起人押金

        emit ProposalExecuted(proposalId);
    }

    /**
     * @dev 内部函数：将提案押金退还给发起人
     */
    function _refundDeposit(uint256 proposalId) internal {
        if (proposalDepositAmount > 0) {
            Proposal storage proposal = proposals[proposalId];
            governanceToken.transfer(proposal.proposer, proposalDepositAmount);
        }
    }

    /**
     * @notice 外部查询接口：获取提案的实时投票结果
     */
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

    /**
     * @notice 管理员调整法定人数比例
     */
    function setQuorumPercentage(uint256 _newQuorum) external onlyAdmin {
        require(_newQuorum > 0 && _newQuorum <= 100, "Invalid quorum");
        quorumPercentage = _newQuorum;
    }

    /**
     * @notice 管理员调整提案押金数量
     */
    function setProposalDepositAmount(uint256 _newAmount) external onlyAdmin {
        proposalDepositAmount = _newAmount;
    }
}