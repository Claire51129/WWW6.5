// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    
    // 用uint8代替uint256存储小数字，节省gas
    uint8 public proposalCount;
    
    // 使用最小空间类型的紧凑结构体
    struct Proposal {
        bytes32 name;          // 用bytes32代替string，节省gas
        uint32 voteCount;      // 支持最多约43亿票
        uint32 startTime;      // Unix时间戳（支持到2106年）
        uint32 endTime;        // Unix时间戳
        bool executed;         // 是否已执行
    }
    
    // 用mapping代替数组存储提案，访问更省gas
    mapping(uint8 => Proposal) public proposals;
    
    // 单槽打包的用户投票数据
    // 每个地址在这个mapping中占用一个存储槽
    // 把多个投票标记打包进一个uint256，节省gas
    // uint256中的每个bit代表对某个提案的投票
    mapping(address => uint256) private voterRegistry;
    
    // 记录每个提案的总投票人数（可选）
    mapping(uint8 => uint32) public proposalVoterCount;
    
    // 事件
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);
    
    // === 核心函数 ===
    
    /**
     * 创建新提案
     * name: 提案名称（传入bytes32更省gas）
     * duration: 投票持续时间（秒）
     */
    function createProposal(bytes32 name, uint32 duration) external {
        require(duration > 0, "Duration must be > 0");
        
        // 递增计数器，比数组的.push()更省gas
        uint8 proposalId = proposalCount;
        proposalCount++;
        
        // 先用memory创建struct，再存入storage，更省gas
        Proposal memory newProposal = Proposal({
            name: name,
            voteCount: 0,
            startTime: uint32(block.timestamp),  // 转换为uint32节省空间
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });
        
        proposals[proposalId] = newProposal;
        
        emit ProposalCreated(proposalId, name);
    }
    
    /**
     * 对提案进行投票
     * proposalId: 提案编号
     */
    function vote(uint8 proposalId) external {
        // 检查提案是否有效
        require(proposalId < proposalCount, "Invalid proposal");
        
        // 检查投票时间是否有效
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting ended");
        
        // 用位运算检查是否已投票（省gas）
        uint256 voterData = voterRegistry[msg.sender];  // 读取投票记录
        uint256 mask = 1 << proposalId;                 // 找到对应提案的开关位置
        require((voterData & mask) == 0, "Already voted"); // 检查是否已投过
        
        // 用位运算记录投票
        voterRegistry[msg.sender] = voterData | mask;  // 打开对应开关
        
        // 更新提案投票数
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;
        
        emit Voted(msg.sender, proposalId);
    }
    
    /**
     * 投票结束后执行提案
     * proposalId: 提案编号
     */
    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed, "Already executed");
        
        proposals[proposalId].executed = true;
        
        emit ProposalExecuted(proposalId);
        
        // 真实合约里，这里会写具体的执行逻辑
    }
    
    // === 查询函数 ===
    
    /**
     * 查询某个地址是否对某个提案投过票
     * voter: 投票人地址
     * proposalId: 提案编号
     * 返回：true表示已投票
     */
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }
    
    /**
     * 获取提案详细信息
     * 参数用calldata，返回值用memory，更省gas
     */
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,       // 提案名称
        uint32 voteCount,   // 投票数
        uint32 startTime,   // 开始时间
        uint32 endTime,     // 结束时间
        bool executed,      // 是否已执行
        bool active         // 是否正在投票中
    ) {
        require(proposalId < proposalCount, "Invalid proposal");
        
        Proposal storage proposal = proposals[proposalId];
        
        return (
            proposal.name,
            proposal.voteCount,
            proposal.startTime,
            proposal.endTime,
            proposal.executed,
            // 当前时间在开始和结束之间，说明正在投票
            (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)
        );
    }
}
