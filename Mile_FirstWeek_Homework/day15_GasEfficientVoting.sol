// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title day15_GasEfficientVoting
 * @dev Gas 优化投票系统 - 位运算与存储打包实战
 * 
 * 🌳 高级特性:
 * - 存储打包 (Storage Packing): 将小类型变量组合放入同一个 32 字节存储槽
 * - 位运算 (Bitwise Operations): 使用 uint256 作为位掩码记录投票状态，极大节省存储
 * - 类型优化: 使用 uint8, uint32 替代 uint256 减少 Gas 消耗
 * - 引用优化: 使用 storage 指针避免重复读取
 * 
 * ⚠️ 难度: ⭐⭐⭐⭐⭐ (极难 - 涉及底层存储布局与位操作)
 * 
 * 🎯 核心技能:
 * - struct 内存布局理解
 * - 位掩码 (Masking) 与 位移 (Shifting)
 * - Gas 成本分析与优化
 */
contract day15_GasEfficientVoting {
    
    // ✅ 优化点 1: 使用 uint8 代替 uint256
    // 理由: 提案数量不会超过 255，uint8 仅占 1 字节，节省存储和计算 Gas
    uint8 public proposalCount;
    
    // ✅ 优化点 2: 结构体存储打包 (Storage Packing)
    // EVM 存储槽为 32 字节 (256 bits)。
    // 布局策略:
    // Slot 1: bytes32 name (32 bytes) -> 独占一个槽
    // Slot 2: uint32 voteCount (4) + uint32 startTime (4) + uint32 endTime (4) + bool executed (1) + 填充 (19)
    //         总计: 4+4+4+1 = 13 bytes < 32 bytes -> 完美打包进第二个槽
    // 如果不这样排序，编译器可能会将它们分散到多个槽中，导致读取/写入 Gas 翻倍。
    struct Proposal {
        bytes32 name;       // 32 bytes (Slot 1)
        uint32 voteCount;   // 4 bytes  \
        uint32 startTime;   // 4 bytes   |
        uint32 endTime;     // 4 bytes   | -> 打包进 Slot 2
        bool executed;      // 1 byte   /
    }
    
    // ✅ 优化点 3: Mapping 代替 Array
    // 理由: 数组遍历是 O(N)，Mapping 查找是 O(1)。
    // 且不需要存储数组长度，进一步节省 Gas。
    mapping(uint8 => Proposal) public proposals;
    
    // ✅ 优化点 4: 位运算存储投票状态 (Bitmask)
    // 传统方式: mapping(address => mapping(uint8 => bool)) -> 每个投票关系占一个存储槽 (极贵!)
    // 优化方式: mapping(address => uint256) -> 一个地址的所有投票状态压缩在一个 uint256 中
    // 原理: uint256 有 256 位，每一位代表一个提案 ID 是否投过票 (1=已投, 0=未投)
    // 极限: 单个用户最多可参与 256 个提案的投票 (对于大多数场景足够)
    mapping(address => uint256) private voterRegistry;
    
    // 辅助计数：每个提案的投票人数 (非必须，但用于演示 uint32 优化)
    mapping(uint8 => uint32) public proposalVoterCount;
    
    // 事件 (Indexed 参数有助于链下查询过滤)
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);
    
    /**
     * @dev 创建新提案
     * @param name 提案名称 (使用 bytes32 节省存储，相比 string)
     * @param duration 投票持续时间 (秒)
     */
    function createProposal(bytes32 name, uint32 duration) external {
        // 获取当前 ID 并自增
        uint8 pid = proposalCount;
        proposalCount++;
        
        // 直接写入存储，利用结构体打包特性
        proposals[pid] = Proposal({
            name: name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp + duration),
            executed: false
        });
        
        emit ProposalCreated(pid, name);
    }
    
    /**
     * @dev 投票 (核心 Gas 优化逻辑)
     * @param proposalId 提案 ID
     * 
     * 🔑 位运算逻辑解析:
     * 1. mask = 1 << proposalId: 创建一个只有第 proposalId 位为 1 的二进制数
     *    例如 ID=2: 000...00100
     * 2. (data & mask) == 0: 检查该位是否为 0。如果是 0，说明没投过。
     * 3. data | mask: 将该位设置为 1，记录投票。
     */
    function vote(uint8 proposalId) external {
        // ✅ 优化点 5: 使用 storage 指针
        // 避免多次从 mapping 中读取 proposals[proposalId]，减少 SLOAD 操作
        Proposal storage p = proposals[proposalId];
        
        // 基础校验
        require(proposalId < proposalCount, "Invalid proposal ID");
        require(block.timestamp >= p.startTime, "Voting not started");
        require(block.timestamp <= p.endTime, "Voting ended");
        require(!p.executed, "Proposal already executed");
        
        // 获取用户当前的投票位图
        uint256 data = voterRegistry[msg.sender];
        
        // 创建掩码: 将 1 左移 proposalId 位
        // 如果 proposalId = 0, mask = ...0001
        // 如果 proposalId = 1, mask = ...0010
        uint256 mask = 1 << proposalId;
        
        // 检查是否已投票: 按位与 (&) 操作
        // 如果该位已经是 1，结果不为 0，说明投过了
        require((data & mask) == 0, "Already voted");
        
        // 记录投票: 按位或 (|) 操作，将该位设为 1
        voterRegistry[msg.sender] = data | mask;
        
        // 更新计数
        p.voteCount++;
        proposalVoterCount[proposalId]++;
        
        emit Voted(msg.sender, proposalId);
    }
    
    /**
     * @dev 执行提案
     * @param proposalId 提案 ID
     */
    function executeProposal(uint8 proposalId) external {
        // 使用 storage 指针优化读取
        Proposal storage p = proposals[proposalId];
        
        require(proposalId < proposalCount, "Invalid proposal ID");
        require(block.timestamp > p.endTime, "Voting still active");
        require(!p.executed, "Already executed");
        
        // 标记为已执行
        p.executed = true;
        
        emit ProposalExecuted(proposalId);
    }
    
    /**
     * @dev 查询用户是否对某提案投过票
     * @return bool true 表示已投
     */
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        // 位运算检查
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }
    
    /**
     * @dev 获取提案详细信息
     */
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed
    ) {
        // 使用 storage 指针一次性读取
        Proposal storage p = proposals[proposalId];
        return (p.name, p.voteCount, p.startTime, p.endTime, p.executed);
    }
}