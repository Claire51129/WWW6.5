
// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    
    // Use uint8 for small numbers instead of uint256
    uint8 public proposalCount;//提案数量不会超过255
    
    // Compact struct using minimal space types
    struct Proposal {
        bytes32 name;          // Use bytes32 instead of string to save gas
        uint32 voteCount;      // 足以支持 42 亿次投票，节省 Gas
        uint32 startTime;      // Unix timestamp (supports dates until year 2106)
        uint32 endTime;        // Unix timestamp我们不需要纳秒级的精度
        bool executed;         // Execution status
    }
    
    // 映射为我们提供了对每个提案的直接访问，无需像数组那样进行迭代或边界检查
    mapping(uint8 => Proposal) public proposals;
    
    // 使用位图，将投票者的所有历史记录压缩到一个 uint256 中，位 0 = 对提案 0 投了票，位 1 = 对提案 1 投了票，以此类推，最多支持 256 个提案
    mapping(address => uint256) private voterRegistry;
    
    // 跟踪每个提案有多少投票者投了票
    mapping(uint8 => uint32) public proposalVoterCount;
    
    // Events
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);
    
    function createProposal(bytes32 name, uint32 duration) external {
        require(duration > 0, "Duration must be > 0");
        
        // 为这个提案生成一个唯一的 ID，使用一个简单的计数器（uint8）而不是推送到数组
        uint8 proposalId = proposalCount;
        proposalCount++;
        
        // 在内存(memory)中创建提案
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
    
    function vote(uint8 proposalId) external 
    {
        require(proposalId < proposalCount, "Invalid proposal");//检查提案是否存在
        
        // Check proposal voting period
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting ended");
        
        // 位掩码(Bitmask)检查是否已投票
        uint256 voterData = voterRegistry[msg.sender];
        uint256 mask = 1 << proposalId;//创建一个二进制掩码
        require((voterData & mask) == 0, "Already voted");//位运算 AND 检查该位是否已在用户的注册表中设置
        
        // Record vote using bitwise OR
        voterRegistry[msg.sender] = voterData | mask;//位运算(bitwise )OR 记录投票
        
        // Update proposal vote count
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;
        
        emit Voted(msg.sender, proposalId);
    }

    //确保任何人都可以在投票期结束后执行提案
    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed, "Already executed");
        
        proposals[proposalId].executed = true;
        
        emit ProposalExecuted(proposalId);
        
        // 在实际应用中，在这里添加提案的执行逻辑——也许是触发付款或 DAO 配置更改
    }
    
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) 
    {
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }
    // 节省 Gas 的读取：只需一次存储访问(storage access)和一次位运算(bitwise operation)
    
    //view
    //不需要 Gas 费的（链下调用）
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
