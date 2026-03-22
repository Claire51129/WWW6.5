// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    uint8 public proposalCount;

    struct Proposal {
        bytes32 name;      // 比 string 省 Gas，固定长度直接存储
        uint32 voteCount;  // 42亿上限够用了，只占 4 字节
        uint32 startTime;  // 时间戳用 uint32 可以用到 2106 年
        uint32 endTime;
        bool executed;     // 布尔值占 1 字节
    }

    mapping(uint8 => Proposal) public proposals;
    mapping(address => uint256) private voterRegistry;

    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    mapping(uint8 => uint32) public proposalVoterCount;
    function createProposal(bytes32 _name, uint32 _duration) external {
        require(_duration > 0, "Duration must be > 0");
        uint8 proposalID = proposalCount;
        proposalCount++;

        Proposal memory newProposal = Proposal({
            name: _name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + _duration,
            executed: false
        });
        proposals[proposalID] = newProposal;
        emit ProposalCreated(proposalID, _name);
    }
    
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);
    
    function vote(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal ID");
        uint256 voterData = voterRegistry[msg.sender];
        uint256 mask = 1 << proposalId;
        require((voterData & mask) == 0, "Already voted");
        voterRegistry[msg.sender] = voterData | mask;
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;
        emit Voted(msg.sender, proposalId);
    }

    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }

    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed, "Already executed");

        proposals[proposalId].executed = true;
        
        emit ProposalExecuted(proposalId);
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
            (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)
        );
    }
    
    
}
