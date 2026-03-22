// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    
    // 用uint8而不是uint256，只用1字节（1byte 0~255），适合存储小数字
    uint8 public proposalCount;
    
    // Solidity按32字节槽位存储数据,多个小变量可以打包到一个槽位，读写一个槽位 vs 三个槽位 = 节省约40,000 gas!
    struct Proposal {
        bytes32 name;          // 固定大小32字节,比string便宜，string (动态大小,昂贵)，每次读写都需要额外gas
        uint32 voteCount;      // 最大值42亿,通常够用
        uint32 startTime;      // 足够存储时间戳到2106年
        uint32 endTime;        // Unix timestamp
        bool executed;         // Execution status
    }
    
    // 映射代替数组(O(1)查找)
    mapping(uint8 => Proposal) public proposals;
    
    // !!!位运算存储投票状态:用一个uint256存储256个布尔值，
    mapping(address => uint256) private voterRegistry;
    
    // 每个提案一个bit
    mapping(uint8 => uint32) public proposalVoterCount;
    
    // 事件
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);
    

    
    // === Core Functions ===
    
    /**
     * @dev Create a new proposal
     * @param name The proposal name (pass as bytes32 for gas efficiency)
     * @param duration Voting duration in seconds
     */

     // 创建提案
    function createProposal(bytes32 name, uint32 duration) external {
        require(duration > 0, "Duration must be > 0");

        // 使用 proposalCount++ 来递增计数器比在数组上使用 .push() 更便宜（更节省gas费用）
        uint8 proposalId = proposalCount;
        proposalCount++;
        
        
        // 先在内存中创建一个结构体实例，然后将其赋值到存储中。这种方法比直接在存储中初始化结构体更节省gas费用。
        // 就像在纸上先画一个提案的草稿（在内存memory中创建一个新的提案）,这个草稿包含：名字、投票数(0)、开始时间(现在)、结束时间(现在+持续时间)、是否执行过(false)
        Proposal memory newProposal = Proposal({
            name: name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });
        
        // 把纸上的草稿贴到提案本子的第proposalId页上（把内存中的提案存到存储storege中）
        proposals[proposalId] = newProposal;
        
        // 广播告诉所有人："我刚刚在本子的第proposalId页上贴了一个新的提案，名字是name"
        emit ProposalCreated(proposalId, name);
    }
    

    // 使用位运算进行投票 
    function vote(uint8 proposalId) external {
        // 有效性检查
        require(proposalId < proposalCount, "Invalid proposal");
        
        // 是否在规定时间内投票
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting ended");
        
        // Check if already voted using bit manipulation (gas efficient)
        // 查看一个投票者的投票记录卡片（从存储中读取投票者的数据）
        uint256 voterData = voterRegistry[msg.sender];

        // 创建一个特殊的"标记"（位掩码），这个标记在proposalId位置上有一个1，其他位置都是0
        uint256 mask = 1 << proposalId;

        // 检查投票者是否已经投票：如果投票者的记录卡片和这个特殊标记"相交"（按位与运算）不为0，说明已经投票了
        require((voterData & mask) == 0, "Already voted");
        
        // 记录投票：用"或(OR)"运算在投票者的记录卡片上打一个标记（在proposalId位置上变成1）
        // 💡好处：一个uint256可以存储256个投票记录（每个提案占一个比特位），比存储256个布尔值更节省gas费用，查询和更新都很快
        voterRegistry[msg.sender] = voterData | mask;
        
        // 提案投票数+1
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;
        
        emit Voted(msg.sender, proposalId);
    }
    

    // 执行提案（在实际合约中，提案不会在真的在这里执行，需要添加执行提案的具体逻辑）
    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed, "Already executed");
        
        proposals[proposalId].executed = true;
        
        emit ProposalExecuted(proposalId);
    }
    
    // === View Functions ===
    
    // 检查投票者是否已经投票
    // voterRegistry[voter]：获取投票者的投票记录（一个uint256数字，每个比特位代表一个提案的投票状态）
    // (1 << proposalId)：创建一个特殊的"标记"（位掩码），这个标记在proposalId位置上有一个1，其他位置都是0
    // &（按位与运算）：检查投票者的记录中proposalId位置是否有1（是否已经投票）
    // != 0：如果结果不为0，说明已经投票了，返回true；否则返回false
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }
    
    // 获取提案详情（用view函数，只读）
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