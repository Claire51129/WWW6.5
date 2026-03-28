// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract OptimizedDAO is ReentrancyGuard {
    // ===========================
    // ======= 数据存储 ===========
    // ===========================

    ERC20Votes public governanceToken;
    address public admin;

    uint256 public votingDuration;        // 投票持续时间（秒）
    uint256 public timelockDuration;      // 时间锁（秒）
    uint256 public quorumPercentage;      // 法定投票比例（百分比）
    uint256 public proposalDepositAmount; // 提案押金
    uint256 public proposalThreshold;     // 提案门槛（最小持币量）
    uint256 public nextProposalId;

    // ===========================
    // ======= 结构体拆分 ========
    // ===========================

    // 核心信息
    struct ProposalCore {
        address proposer;
        string description;
        uint256 startTime;
        uint256 endTime;
        bool executed;
        bool canceled;
        uint256 snapshotBlock;
    }

    // 投票信息
    struct ProposalVote {
        uint256 forVotes;
        uint256 againstVotes;
    }

    // 执行信息
    struct ProposalExecution {
        uint256 timelockEnd;
        address target;
        uint256 value;
        bytes data;
    }

    // ===========================
    // ======= Mappings ==========
    // ===========================

    mapping(uint256 => ProposalCore) public proposalCore;
    mapping(uint256 => ProposalVote) public proposalVotes;
    mapping(uint256 => ProposalExecution) public proposalExec;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // ===========================
    // ======= 事件定义 ==========
    // ===========================

    event ProposalCreated(uint256 indexed id, address proposer);
    event Voted(uint256 indexed id, address voter, bool support, uint256 weight);
    event ProposalFinalized(uint256 indexed id, bool passed);
    event ProposalExecuted(uint256 indexed id);
    event ProposalCanceled(uint256 indexed id);

    // ===========================
    // ======= 构造函数 ==========
    // ===========================

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

    // ===========================
    // ======= 创建提案 ==========
    // ===========================

    function createProposal(
        string memory description,
        address target,
        uint256 value,
        bytes memory data
    ) external returns (uint256) {
        require(bytes(description).length > 0, "Empty description");
        require(governanceToken.balanceOf(msg.sender) >= proposalThreshold, "Not enough tokens");

        if (proposalDepositAmount > 0) {
            require(
                governanceToken.transferFrom(msg.sender, address(this), proposalDepositAmount),
                "Deposit failed"
            );
        }

        uint256 id = nextProposalId++;

        proposalCore[id] = ProposalCore({
            proposer: msg.sender,
            description: description,
            startTime: block.timestamp,
            endTime: block.timestamp + votingDuration,
            executed: false,
            canceled: false,
            snapshotBlock: block.number
        });

        proposalVotes[id] = ProposalVote({forVotes: 0, againstVotes: 0});

        proposalExec[id] = ProposalExecution({
            timelockEnd: 0,
            target: target,
            value: value,
            data: data
        });

        emit ProposalCreated(id, msg.sender);
        return id;
    }

    // ===========================
    // ======= 投票函数 ==========
    // ===========================

    function vote(uint256 id, bool support) external {
        ProposalCore storage pCore = proposalCore[id];
        ProposalVote storage pVote = proposalVotes[id];

        require(block.timestamp >= pCore.startTime, "Not started");
        require(block.timestamp <= pCore.endTime, "Voting ended");
        require(!pCore.executed && !pCore.canceled, "Invalid state");
        require(!hasVoted[id][msg.sender], "Already voted");

        uint256 weight = governanceToken.getPastVotes(msg.sender, pCore.snapshotBlock);
        require(weight > 0, "No voting power");

        hasVoted[id][msg.sender] = true;

        if (support) {
            unchecked { pVote.forVotes += weight; }
        } else {
            unchecked { pVote.againstVotes += weight; }
        }

        emit Voted(id, msg.sender, support, weight);
    }

    // ===========================
    // ======= 完成提案 ==========
    // ===========================

    function finalizeProposal(uint256 id) external {
        ProposalCore storage pCore = proposalCore[id];
        ProposalVote storage pVote = proposalVotes[id];
        ProposalExecution storage pExec = proposalExec[id];

        require(block.timestamp > pCore.endTime, "Voting not ended");
        require(!pCore.executed && !pCore.canceled, "Invalid state");
        require(pExec.timelockEnd == 0, "Already finalized");

        uint256 totalVotes = pVote.forVotes + pVote.againstVotes;
        uint256 totalSupply = governanceToken.getPastTotalSupply(pCore.snapshotBlock);
        uint256 quorum = (totalSupply * quorumPercentage) / 100;

        bool passed = totalVotes >= quorum && pVote.forVotes > pVote.againstVotes;

        if (passed) {
            if (timelockDuration > 0) {
                pExec.timelockEnd = block.timestamp + timelockDuration;
            } else {
                _execute(id);
            }
        } else {
            pCore.canceled = true;
            emit ProposalCanceled(id);
        }

        emit ProposalFinalized(id, passed);
    }

    // ===========================
    // ======= 执行提案 ==========
    // ===========================

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

        pCore.executed = true;

        (bool success, ) = pExec.target.call{value: pExec.value}(pExec.data);
        require(success, "Execution failed");

        _refundDeposit(id);

        emit ProposalExecuted(id);
    }

    // ===========================
    // ======= 押金退款 ==========
    // ===========================

    function _refundDeposit(uint256 id) internal {
        if (proposalDepositAmount > 0) {
            ProposalCore storage pCore = proposalCore[id];
            require(governanceToken.transfer(pCore.proposer, proposalDepositAmount), "Refund failed");
        }
    }

    // ===========================
    // ======= 管理员函数 ========
    // ===========================

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
