// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    //以 Gas 优化为核心
    // Use uint8 for small numbers instead of uint256
    uint8 public proposalCount; //不会有超过 255 个提案；使用 uint256 会提供远远超出所需的范围，浪费 31 个额外的存储字节。
    
    // Compact struct using minimal space types
    //更少的存储槽意味着更低的 Gas
    struct Proposal {
        bytes32 name;          // Use bytes32【固定大小】 instead of string to save gas
        uint32 voteCount;      // Supports up to ~4.3 billion votes
        uint32 startTime;      // Unix timestamp (supports dates until year 2106)
        uint32 endTime;        // Unix timestamp
        bool executed;         // Execution status
    }
    
    // Using a mapping instead of an array for proposals is more gas efficient for access
    mapping(uint8 => Proposal) public proposals;
    
    // Single-slot packed user data
    // Each address occupies one storage slot in this mapping
    // We pack multiple voting flags into a single uint256 for gas efficiency
    // Each bit in the uint256 represents a vote for a specific proposal
    //映射为我们提供了对每个提案的直接访问（O(1)），无需像数组那样进行迭代或边界检查
    //每个地址只需一个存储槽即可存储所有投票
    //使用位运算 `AND` 检查某人是否投过票
    //使用位运算 `OR` 记录投票
    mapping(address => uint256) private voterRegistry;
    
    // Count total voters for each proposal (optional)
    mapping(uint8 => uint32) public proposalVoterCount;
    
    // Events
    //indexed 允许有效地过滤日志
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);
    

    
    // === Core Functions ===
    
    /**
     * @dev Create a new proposal
     * @param name The proposal name (pass as bytes32 for gas efficiency)
     * @param duration Voting duration in seconds
     */
    function createProposal(bytes32 name, uint32 duration) external {
        require(duration > 0, "Duration must be > 0");
        
        // Increment counter - cheaper than .push() on an array
        uint8 proposalId = proposalCount;
        proposalCount++;
        
        // Use a memory struct and then assign to storage
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
    
    /**
     * @dev Vote on a proposal
     * @param proposalId The proposal ID
     */
    function vote(uint8 proposalId) external {
        // Require valid proposal
        require(proposalId < proposalCount, "Invalid proposal");
        
        // Check proposal voting period
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting ended");
        
        // Check if already voted using bit manipulation (gas efficient)
        uint256 voterData = voterRegistry[msg.sender];
        uint256 mask = 1 << proposalId;
        require((voterData & mask) == 0, "Already voted");
        
        // Record vote using bitwise OR
        voterRegistry[msg.sender] = voterData | mask;
        
        // Update proposal vote count
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;
        
        emit Voted(msg.sender, proposalId);
    }
    
    /**
     * @dev Execute a proposal after voting ends
     * @param proposalId The proposal ID
     */
    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed, "Already executed");
        
        proposals[proposalId].executed = true;
        
        emit ProposalExecuted(proposalId);
        
        // In a real contract, execution logic would happen here
    }
    
    // === View Functions ===
    
    /**
     * @dev Check if an address has voted for a proposal
     * @param voter The voter address
     * @param proposalId The proposal ID
     * @return True if the address has voted
     */
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }
    
    /**
     * @dev Get detailed proposal information
     * Uses calldata for parameters and memory for return values
     */
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