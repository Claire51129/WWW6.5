// 智能合约的Gas优化技巧
// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract GasEfficientVoting{    //投票系统（省gas版）

    uint8 public proposalCount;    //提案数：uint8最大=255，最多255个提案够用
    struct Proposal{    //一个投票项目（提案结构体）。这些变量排列后，可尽量塞进一个slot中，节省存储。
        bytes32 name;    //bytes32是固定32字节盒子，较string便宜
        uint32 voteCount;    //投票数：uint32最大42亿，完全够投票
        uint32 startTime;    //投票开始时间
        uint32 endTime;    //投票结束时间
        bool executed;    // 提案是否执行。true=已执行，false=未执行
    }

    mapping(uint8 => Proposal) public proposals;    // 提案ID→提案信息
    mapping(address => uint256)private voterRegistry;    //【重点】位图核心结构：记录每个用户投过哪些提案
    mapping(uint8 => uint32)public proposalVoterCount;    //记录每个提案有多少人投票

    //以下为事件日志，用于区块链记录操作，前端可以监听
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);

    //功能：创建一个提案
    function createProposal(bytes32 _name, uint32 duration) external{
        require(duration > 0, "Durations should be more than 0");    // 检查：投票事件必须大于0
        uint8 proposalId = proposalCount;    //获取提案编号
        proposalCount++;    //增加提案数，包含名字、票数、开始&结束时间、是否执行
        Proposal memory newProposal = Proposal({
            name: _name,
            voteCount: 0,
            startTime: uint32(block.timestamp),    //当前区块时间
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });
        proposals[proposalId] = newProposal;    //保存提案：存进mapping
        emit ProposalCreated(proposalId, _name);    //触发事件：创建提案
    }

    // 功能：给提案投票
    function vote(uint8 proposalId) external{
        require(proposalId < proposalCount, "Invalid Proposal");    //检查ID序号小于ID数量，防止投不存在的提案
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime,"Voting has not started");  //检查时间：投票必须已经开始
        require(currentTime <= proposals[proposalId].endTime, "Voting has ended");  //检查时间：投票必须没结束

        uint256 voterData = voterRegistry[msg.sender];   //读取投票数据：获取该投票这之前的投票记录
        uint256 mask = 1 << proposalId;   //创建位掩码（即创建一个开关）
        require((voterRegistry[msg.sender] & mask) == 0, "Already voted");  //检查开关是不是0，如为0即表示已经投过了
        voterRegistry[msg.sender] = voterData | mask;    //意为：打开这个开关
        proposals[proposalId].voteCount++;    //增加票数
        proposalVoterCount[proposalId]++;    //增加投票人数

        emit Voted(msg.sender,proposalId);   //触发事件：记录谁投票了
        
    }

    // 功能：执行提案——投票结束后执行提案
    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid Proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting is not ended");  //检查时间：投票必须已经结束
        require(!proposals[proposalId].executed, "Already executed");  //检查是否执行，防止重复执行
        proposals[proposalId].executed = true;    //标记执行
        emit ProposalExecuted(proposalId);
    }

    // 功能：查询是否投过（位运算原理）
    function hasVoted(address voter, uint8 proposalId)external view returns(bool){
        return(voterRegistry[voter] & (1 << proposalId) != 0);
    }


    // 功能：获取提案信息
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,    //票数
        uint32 startTime,
        uint32 endTime,
        bool executed,    //是否执行
        bool active    //是否进行中
        )
{
    require(proposalId < proposalCount, "Invalid proposal");

    Proposal storage proposal = proposals[proposalId];
    return(
        proposal.name,
        proposal.voteCount,
        proposal.startTime,
        proposal.endTime,
        proposal.executed,
        (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)   //active计算：现在是否在投票时间
        );

}
}


// 【学习目标1】精通Gas优化思维：能识别并修复合约中昂贵的存储逻辑，如将动态数组替换成映射Mapping以实现O(1)访问
// 【学习内容1】优化变量类型（如用 uint8 代替 uint256、bytes32 代替 string）减少存储开销。小盒装小物：不要到处用超大的 uint256。如果数字很小，用 uint8 这种小盒子更省钱；名字改用固定规格的 bytes32 盒子，比不确定的 string 便宜得多。
// 【学习目标2】掌握底层存储布局：通过结构体打包技巧，编写出存储效率更高的生产级合约。
// 【学习内容2】结构体打包 (Struct Packing)，利用 Solidity 32 字节存储槽的特性排列变量以节省空间。写结构体就像塞行李箱。合理排列布尔值和短整型，让它们挤在同一个 32 字节的格子里，能减少交纳给区块链的“摊位费”。
// 【学习目标3】位运算的运用：能熟练使用位掩码(Bitmask)和位运算符，在不损失功能的前提下大幅削减合约Gas占用。
// 【学习内容3】重点攻克位图 (Bitmaps)技术，使用位运算（AND/OR/位移）将 256 个投票状态压缩进一个 uint256 存储槽中，极大降低链上数据存取成本。不再给每个投票人开一排新柜子，而是用一串 256 个“开关”（位图）。一个 uint256 存储槽就能记住一个人对 256 个提案的投票记录，操作又快又便宜。
// 【uint整数大小】uint8最大值=255；uint16=65535；uint32=42亿；uint64=184亿；uint256=超级巨大，可涵盖所有