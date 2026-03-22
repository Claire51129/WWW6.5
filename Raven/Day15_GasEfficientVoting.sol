// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
contract GasEfficientVoting {
	// 8-bit(1-byte): 256 proposals at max
	uint8 public proposalCount;
	struct Proposal {
		bytes32 name; // Same as uint256 in size, fixed-sized compared with string
		uint32 voteCount; // 4-bytes: support ~4.3 billion votes
		uint32 startTime;
		uint32 endTime;
		bool executed; // 1-bit
	}
	mapping(uint8 => Proposal) public proposals;
	// Each bit in the uint256 represents a vote for a specific proposal
	mapping(address => uint256) public voterRegistry;
	mapping(uint8 => uint32) public proposalVoterCount;
	event ProposalCreated(uint8 indexed proposalId, bytes32 name);
	event Voted(address indexed voter, uint8 indexed proposalId);
	event ProposalExecuted(uint8 indexed proposalId);
	function createProposal(bytes32 _name, uint32 _duration) external {
		require(_duration > 0, "Duration should be positive");
		uint8 proposalId = proposalCount;
		proposalCount++;
		// Assign and pack struct(13 bytes) into a uint256 memory(32 bytes)
		Proposal memory newProposal = Proposal({
			name: _name,
			voteCount: 0,
			startTime: uint32(block.timestamp),
			endTime: uint32(block.timestamp) + _duration,
			executed: false
		});
		proposals[proposalId] = newProposal;
		emit ProposalCreated(proposalId, _name);
	}
	function vote(uint8 proposalId) external {
		require(proposalId < proposalCount, "Invalid proposal");
		require(uint32(block.timestamp) >= proposals[proposalId].startTime, "Vote has not started");
		require(uint32(block.timestamp) <= proposals[proposalId].endTime, "Vote has ended");
		uint256 voterData = voterRegistry[msg.sender];
		// Shift 1 to left for proposalId bits
		uint256 mask = 1 << proposalId;
		// Bitwise AND
		// proposalId-th bit should be empty(0)
		require((voterData & mask) == 0, "Already voted");
		// Bitwise OR
		// Write proposalId-th bit to 1, the other bits unchanged
		voterRegistry[msg.sender] = voterData | mask;
		proposals[proposalId].voteCount++;
		proposalVoterCount[proposalId]++;
		emit Voted(msg.sender, proposalId);
	}
	function executeProposal(uint8 proposalId) external {
		require(proposalId < proposalCount, "Invalid proposal");
		require(uint32(block.timestamp) > proposals[proposalId].endTime, "Vote has not ended");
		require(!proposals[proposalId].executed, "Already executed");
		proposals[proposalId].executed = true;
		emit ProposalExecuted(proposalId);
	}
	function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
		return ((voterRegistry[voter] & (1 << proposalId)) != 0);
	}
	function getProposal(uint8 proposalId) external view returns (
		bytes32 name,
		uint32 voteCount,
		uint32 startTime,
		uint32 endTime,
		bool executed,
		bool active
	) {
		require(proposalId < proposalCount, "Invalid proposal");
		Proposal storage proposal = proposals[proposalId];
		return (
			proposal.name,
			proposal.voteCount,
			proposal.startTime,
			proposal.endTime,
			proposal.executed,
			(uint32(block.timestamp) >= proposal.startTime && uint32(block.timestamp) <= proposal.endTime)
		);
	}
}