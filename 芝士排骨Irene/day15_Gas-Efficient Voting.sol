// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Gas 优化投票合约 - 通过位运算、存储打包等技巧大幅降低 gas 消耗
contract GasEfficientVoting {

    // 提案计数器
    // uint8 只占 1 字节，uint256 占 32 字节，省了 31 字节的存储空间
    uint8 public proposalCount;

    // 提案结构体 - 精心设计字段大小，让多个字段挤进同一个 32 字节存储槽
    struct Proposal {
        bytes32 name;       // 提案名称，固定 32 字节（比 string 便宜，string 是动态类型需要额外存储）
        uint32 voteCount;   // 得票数，4 字节，最大值约 42 亿（足够了）
        uint32 startTime;   // 投票开始时间，4 字节，时间戳够用到 2106 年
        uint32 endTime;     // 投票结束时间，4 字节
        bool executed;      // 是否已执行，1 字节
        // voteCount(4) + startTime(4) + endTime(4) + executed(1) = 13 字节
        // 这四个字段打包进同一个 32 字节槽位，读写一次搞定
        // 如果都用 uint256，就需要 4 个槽位，gas 贵 3-4 倍
    }

    // 提案 ID => 提案详情
    // 用 mapping 而非数组，查找是 O(1) 常数时间，不需要遍历
    mapping(uint8 => Proposal) public proposals;

    // 投票记录
    // 每个地址对应一个 uint256（256 位），每一位代表一个提案的投票状态
    mapping(address => uint256) private voterRegistry;

    // 每个提案的投票人数统计
    mapping(uint8 => uint32) public proposalVoterCount;

    // 事件
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);  // 提案创建
    event Voted(address indexed voter, uint8 indexed proposalId);    // 投票
    event ProposalExecuted(uint8 indexed proposalId);                // 提案执行

    // 创建提案
    function createProposal(bytes32 name, uint32 duration) external {
        uint8 proposalId = proposalCount;  // 当前计数值作为新提案的 ID
        proposalCount++;                    // 计数器 +1，下次创建用下一个 ID

        // 在内存中构建提案对象
        Proposal memory newProposal = Proposal({
            name: name,
            voteCount: 0,                                   // 初始票数为 0
            startTime: uint32(block.timestamp),              // 创建即开始
            endTime: uint32(block.timestamp + duration),     // 开始时间 + 持续时间 = 结束时间
            executed: false                                  // 初始未执行
        });

        // 从 memory 写入 storage，永久保存到链上
        proposals[proposalId] = newProposal;
        emit ProposalCreated(proposalId, name);
    }

    // 投票（核心：位运算）
    function vote(uint8 proposalId) external {
        // 四重检查
        require(proposalId < proposalCount, "Invalid proposal");                      // 提案必须存在
        require(block.timestamp >= proposals[proposalId].startTime, "Not started");   // 投票已开始
        require(block.timestamp <= proposals[proposalId].endTime, "Ended");           // 投票未结束
        require(!proposals[proposalId].executed, "Already executed");                  // 提案未执行

        // 读取该用户的投票位图（一个 256 位的数字）
        uint256 voterData = voterRegistry[msg.sender];

        // 构造掩码：把第 proposalId 位设为 1，其余全是 0
        uint256 mask = 1 << proposalId;

        // 用 & (按位与) 检查该位是否已经是 1
        // 如果 voterData 的第 3 位已经是 1，说明已投过票
        require((voterData & mask) == 0, "Already voted");

        // 用 | (按位或) 把该位设为 1，标记已投票
        voterRegistry[msg.sender] = voterData | mask;

        // 更新提案得票数和投票人数
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;

        emit Voted(msg.sender, proposalId);
    }

    // 执行提案 - 投票结束后才能执行
    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");                  // 提案必须存在
        require(block.timestamp > proposals[proposalId].endTime, "Not ended");    // 投票时间必须已结束
        require(!proposals[proposalId].executed, "Already executed");              // 不能重复执行

        proposals[proposalId].executed = true;  // 标记为已执行
        emit ProposalExecuted(proposalId);
    }

    // 查询某人是否对某提案投过票
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        // 读取该用户的投票位图，用 & 检查对应位是否为 1
        // != 0 表示该位为 1，即已投票
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }

    // 获取提案详情 - 一次性返回所有字段
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed
    ) {
        // 从 storage 读到 memory，然后返回
        Proposal memory p = proposals[proposalId];
        return (p.name, p.voteCount, p.startTime, p.endTime, p.executed);
    }
}