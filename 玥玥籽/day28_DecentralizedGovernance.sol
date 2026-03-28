// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

abstract contract ReentrancyGuard {
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract DecentralizedGovernance is ReentrancyGuard {

    IERC20 public governanceToken;

    struct Proposal {
        address proposer;
        string description;
        string tag;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 startTime;
        uint256 endTime;
        bool executed;
        bool canceled;
        uint256 timelockEnd;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(string => uint256) public tagQuorumOverride;

    uint256 public nextProposalId;
    uint256 public votingDuration;
    uint256 public timelockDuration;
    address public admin;
    uint256 public quorumPercentage;
    uint256 public proposalDepositAmount;

    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description, string tag);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId);
    event ProposalCanceled(uint256 indexed proposalId);
    event QuorumNotMet(uint256 indexed proposalId);
    event ProposalTimelockStarted(uint256 indexed proposalId, uint256 timelockEnd);

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
        require(_votingDuration > 0, "Invalid duration");
        require(_quorumPercentage > 0 && _quorumPercentage <= 100, "Invalid quorum");

        governanceToken = IERC20(_governanceToken);
        votingDuration = _votingDuration;
        timelockDuration = _timelockDuration;
        admin = msg.sender;
        quorumPercentage = _quorumPercentage;
        proposalDepositAmount = _proposalDepositAmount;
    }

    function createProposal(string memory description, string memory tag) external returns (uint256) {
        require(bytes(description).length > 0, "Empty description");

        if (proposalDepositAmount > 0) {
            governanceToken.transferFrom(msg.sender, address(this), proposalDepositAmount);
        }

        uint256 proposalId = nextProposalId++;
        proposals[proposalId] = Proposal({
            proposer: msg.sender,
            description: description,
            tag: tag,
            forVotes: 0,
            againstVotes: 0,
            startTime: block.timestamp,
            endTime: block.timestamp + votingDuration,
            executed: false,
            canceled: false,
            timelockEnd: 0
        });

        emit ProposalCreated(proposalId, msg.sender, description, tag);
        return proposalId;
    }

    // ─── 投票 ──────────────────────────────────────────────────────
    function vote(uint256 proposalId, bool support) external {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp >= p.startTime, "Not started");
        require(block.timestamp <= p.endTime, "Voting ended");
        require(!p.executed && !p.canceled, "Proposal inactive");
        require(!hasVoted[proposalId][msg.sender], "Already voted");

        uint256 weight = governanceToken.balanceOf(msg.sender);
        require(weight > 0, "No voting power");

        hasVoted[proposalId][msg.sender] = true;
        if (support) {
            p.forVotes += weight;
        } else {
            p.againstVotes += weight;
        }

        emit Voted(proposalId, msg.sender, support, weight);
    }

    function finalizeProposal(uint256 proposalId) external {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp > p.endTime, "Voting not ended");
        require(!p.executed && !p.canceled, "Already finalized");

        uint256 totalVotes = p.forVotes + p.againstVotes;
        uint256 totalSupply = governanceToken.totalSupply();

        uint256 effectiveQuorum = tagQuorumOverride[p.tag] > 0
            ? tagQuorumOverride[p.tag]
            : quorumPercentage;

        uint256 quorumRequired = (totalSupply * effectiveQuorum) / 100;

        if (totalVotes >= quorumRequired && p.forVotes > p.againstVotes) {
            bool isEmergency = keccak256(bytes(p.tag)) == keccak256(bytes("emergency"));
            if (timelockDuration > 0 && !isEmergency) {
                p.timelockEnd = block.timestamp + timelockDuration;
                emit ProposalTimelockStarted(proposalId, p.timelockEnd);
            } else {
                p.executed = true;
                _refundDeposit(proposalId);
                emit ProposalExecuted(proposalId);
            }
        } else {
            p.canceled = true;
            emit QuorumNotMet(proposalId);
        }
    }

    function executeProposal(uint256 proposalId) external {
        Proposal storage p = proposals[proposalId];
        require(p.timelockEnd > 0, "No timelock set");
        require(block.timestamp >= p.timelockEnd, "Timelock not ended");
        require(!p.executed && !p.canceled, "Already finalized");

        p.executed = true;
        _refundDeposit(proposalId);
        emit ProposalExecuted(proposalId);
    }

    function _refundDeposit(uint256 proposalId) internal {
        if (proposalDepositAmount > 0) {
            governanceToken.transfer(proposals[proposalId].proposer, proposalDepositAmount);
        }
    }

    function setTagQuorum(string memory tag, uint256 _quorum) external onlyAdmin {
        require(_quorum > 0 && _quorum <= 100, "Invalid quorum");
        tagQuorumOverride[tag] = _quorum;
    }

    function setQuorumPercentage(uint256 _newQuorum) external onlyAdmin {
        require(_newQuorum > 0 && _newQuorum <= 100, "Invalid quorum");
        quorumPercentage = _newQuorum;
    }

    function setProposalDepositAmount(uint256 _newAmount) external onlyAdmin {
        proposalDepositAmount = _newAmount;
    }

    function getProposalResult(uint256 proposalId) external view returns (
        bool passed, uint256 forVotes, uint256 againstVotes, bool executed
    ) {
        Proposal memory p = proposals[proposalId];
        return (p.forVotes > p.againstVotes, p.forVotes, p.againstVotes, p.executed);
    }
}
