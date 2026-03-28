// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    uint8 public proposalCount;
    struct Proposal {
        bytes32 name;
        uint32 voteCount;
        uint32 startTime;
        uint32 endTime;
        bool executed;
    }

    mapping(uint8 => Proposal) public proposals;
    mapping(address => uint256) private voterRegistry;
    mapping(uint8 => uint32) public proposalVoterCount;

    event ProposalCreated(uint8 indexed proposalID, bytes32 indexed name);
    event Voted(address indexed voter, uint8 indexed proposalID);
    event ProposalExecuted(uint8 indexed proposalID);

    function createProposal(bytes32 _name, uint32 duration) external {
        require(duration > 0, "Duration should be more than zero");
        uint8 proposalID = proposalCount; // Fixed spelling
        proposalCount++;
        
        proposals[proposalID] = Proposal({
            name: _name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });
        
        emit ProposalCreated(proposalID, _name);
    }

    function vote(uint8 proposalID) external {
        require(proposalID < proposalCount, "Invalid Proposal");
        
        // Use storage to save gas on multiple reads
        Proposal storage p = proposals[proposalID]; 
        uint32 currentTime = uint32(block.timestamp);
        
        require(currentTime >= p.startTime, "Vote has not started");
        require(currentTime <= p.endTime, "Vote has ended");

        // Bitwise check for "Already Voted"
        uint256 mask = 1 << proposalID;
        require((voterRegistry[msg.sender] & mask) == 0, "Already voted");

        voterRegistry[msg.sender] |= mask; // Efficiently update registry
        p.voteCount++;
        proposalVoterCount[proposalID]++;

        emit Voted(msg.sender, proposalID);
    }

    function executeProposal(uint8 proposalID) external {
        require(proposalID < proposalCount, "Invalid Proposal");
        require(block.timestamp > proposals[proposalID].endTime, "Voting not ended");
        require(!proposals[proposalID].executed, "Already executed"); // Fixed typo 'propoals'

        proposals[proposalID].executed = true;
        emit ProposalExecuted(proposalID);
    }

    function hasVoted(address voter, uint8 proposalID) external view returns(bool) {
        // Parentheses added for clarity/safety
        return (voterRegistry[voter] & (1 << proposalID)) != 0;
    }

    function getProposal(uint8 proposalId) external view returns(
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active
    ) {
        require(proposalId < proposalCount, "Invalid proposal");
        Proposal storage p = proposals[proposalId]; // Changed instance name to 'p'
        return (
            p.name,
            p.voteCount,
            p.startTime,
            p.endTime,
            p.executed,
            (block.timestamp >= p.startTime && block.timestamp <= p.endTime)
        );
    }
}
