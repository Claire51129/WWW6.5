// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    uint256 public proposalCount;

    struct Proposal {
        bytes32 name;
        uint32 voteCount;
        uint32 startTime;
        uint32 endTime;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256=>uint256)) private voterRegistry;

    event ProposalCreated(uint256 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint256 indexed proposalId);
    event ProposalExecuted(uint256 indexed proposalId);

    function createdProposal(string memory _name, uint32 duration) external {
        require(duration > 0, "Duration must be > 0");
        uint256 proposalId = proposalCount;
        unchecked {
            proposalCount++;
        }
        
        bytes32 name = bytes32(bytes(_name));

        Proposal memory newProposal = Proposal({
            name: name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });
        proposals[proposalId] = newProposal;
        emit ProposalCreated(proposalId, name);
    }

    function vote(uint256 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting ended");

        uint256 bucket = proposalId/256;
        uint256 bitIndex = proposalId%256;
        uint256 voterData = voterRegistry[msg.sender][bucket];
        uint256 mask = 1 << bitIndex;
        require((voterData & mask) == 0, "Already voted");

        voterRegistry[msg.sender][bucket] = voterData | mask;

        unchecked {
            proposals[proposalId].voteCount++;
        }

        emit Voted(msg.sender, proposalId);
    }

    function executeProposal(uint256 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed, "Already executed");

        proposals[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }

    function hasVoted(address voter, uint256 proposalId) external view returns(bool){
        uint256 bucket = proposalId / 256;
        uint256 bitIndex = proposalId % 256;
        uint256 voteData = voterRegistry[voter][bucket];
        uint256 mask = 1 << bitIndex;
        return (voteData | mask) != 0;
    }

    function getProposal(uint256 proposalId) external view returns(bytes32 name, uint32 voteCount, uint32 startTime,
    uint32 endTime, bool executed, bool active) {
        require(proposalId < proposalCount, "Invalid proposal");

        Proposal storage proposal = proposals[proposalId];
        return (proposal.name, proposal.voteCount, proposal.startTime, proposal.endTime, proposal.executed,
        (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime));
    }
}