//修一个省gas的提案投票合约
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    
    uint8 public proposalCount;
// 谁家的256自己拿走
    struct Proposal {
        bytes32 name;          // 便宜
        uint32 voteCount;      // 42亿
        uint32 startTime;      // Unix
        uint32 endTime;        
        bool executed;         
    }
    
    mapping(uint8 => Proposal) public proposals; //映射就够了
    mapping(address => uint256) private voterRegistry; //uint256 all in one    
    mapping(uint8 => uint32) public proposalVoterCount;
    
    // 事件就够了
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);
    
    /**
     * @dev Create a new proposal
     * @param name The proposal name (pass as bytes32 for gas efficiency)
     * @param duration Voting duration in seconds
     */

// 函数 1.创建提案
    function createProposal(bytes32 name, uint32 duration) external {
        require(duration > 0, "Duration must be > 0");
        
        uint8 proposalId = proposalCount;
        proposalCount++; //唯一ID
        
        Proposal memory newProposal = Proposal({
            name: name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });
        
        proposals[proposalId] = newProposal;  //赋值
        
        emit ProposalCreated(proposalId, name);
    }
    
    /**
     * @dev Vote on a proposal
     * @param proposalId The proposal ID
     */

//函数2. vote
    function vote(uint8 proposalId) external {
    
        require(proposalId < proposalCount, "Invalid proposal");
        
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting ended");
        
        uint256 voterData = voterRegistry[msg.sender];
        uint256 mask = 1 << proposalId;
        require((voterData & mask) == 0, "Already voted");
        
        voterRegistry[msg.sender] = voterData | mask;
        
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;
        
        emit Voted(msg.sender, proposalId);
    }
    
    /**
     * @dev Execute a proposal after voting ends
     * @param proposalId The proposal ID
     */

//函数3 执行提案
    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed, "Already executed");
        
        proposals[proposalId].executed = true;
        
        emit ProposalExecuted(proposalId);
        
    }
        
    /**
     * @dev Check if an address has voted for a proposal
     * @param voter The voter address
     * @param proposalId The proposal ID
     * @return True if the address has voted
     */

//函数4：检查投票了没有
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }
    
    /**
     * @dev Get detailed proposal information
     * Uses calldata for parameters and memory for return values
     */

//函数5：提案存在了没有
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
    
    /**
     * @dev Convert string to bytes32 (helper for frontend integration)
     * Note: This is a pure function that doesn't use state, so it's gas-efficient
     */

}
