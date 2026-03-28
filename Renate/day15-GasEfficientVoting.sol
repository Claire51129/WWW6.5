//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// GasEfficientVoting - 一个优化 Gas 消耗的投票合约
// 使用紧凑的数据类型和位运算来降低存储成本
contract GasEfficientVoting{

    // 提案计数器，使用 uint8 节省存储空间（最多支持 255 个提案）
    uint8 public proposalCount;

    // Proposal 结构体 - 使用紧凑的数据类型优化 Gas
    // bytes32: 存储提案名称（比 string 更省 Gas）
    // uint32: 投票计数和时间戳（足够支持到 2106 年）
    struct Proposal{
        bytes32 name;           // 提案名称（32字节）
        uint32 voteCount;       // 投票总数
        uint32 startTime;       // 投票开始时间
        uint32 endTime;         // 投票结束时间
        bool executed;          // 是否已执行
    }

    // 提案 ID 到提案信息的映射
    mapping(uint8 => Proposal) public proposals;

    // 选民注册表 - 使用位运算技巧来节省存储
    // 每个地址用一个 uint256 存储，可以记录该地址对 256 个提案的投票状态
    // 第 n 位为 1 表示该地址已对第 n 个提案投过票
    mapping(address => uint256)private voterRegistry;

    // 记录每个提案的独立投票人数（防止重复投票统计）
    mapping(uint8 =>uint32)public proposalVoterCount;

    // 事件定义
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);

    // 创建新提案
    // _name: 提案名称（bytes32 格式）
    // duration: 投票持续时间（秒）
    function createProposal(bytes32 _name, uint32 duration) external{
        require(duration > 0, "Durations should be more than 0");

        // 获取当前提案 ID 并递增计数器
        uint8 proposalId = proposalCount;
        proposalCount++;

        // 创建新提案结构体
        Proposal memory newProposal = Proposal({
            name: _name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });

        // 存储提案
        proposals[proposalId] = newProposal;
        emit ProposalCreated(proposalId, _name);
    }

    // 对指定提案进行投票
    // proposalId: 要投票的提案 ID
    function vote(uint8 proposalId) external{
        // 验证提案存在
        require(proposalId < proposalCount, "Invalid Proposal");

        uint32 currentTime = uint32(block.timestamp);
        // 验证投票时间窗口
        require(currentTime >= proposals[proposalId].startTime, "Voting has not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting has ended");

        // 获取选民当前投票数据
        uint256 voterData = voterRegistry[msg.sender];

        // 创建位掩码 - 将 1 左移 proposalId 位
        // 例如 proposalId = 3，则 mask = 0b1000 (二进制)
        uint256 mask = 1 << proposalId;

        // 检查是否已经投过票（位与运算）
        // 如果对应位已经是 1，说明已投票
        require((voterRegistry[msg.sender] & mask) == 0, "Already voted");

        // 使用位或运算设置对应位为 1，记录投票
        voterRegistry[msg.sender] = voterData | mask;

        // 增加提案的投票计数
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;

        emit Voted(msg.sender, proposalId);
    }

    // 执行提案（仅在投票结束后）
    // proposalId: 要执行的提案 ID
    function executeProposal(uint8 proposalId) external{
        require(proposalId < proposalCount, "Invalid Proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended ");
        require(!proposals[proposalId].executed, "Already executed");

        // 标记提案为已执行
        proposals[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }

    // 查询指定选民是否已对某个提案投票
    // voter: 选民地址
    // proposalId: 提案 ID
    // 返回: true 表示已投票，false 表示未投票
    function hasVoted(address voter, uint8 proposalId)external view returns(bool){
        // 使用位与运算检查对应位是否为 1
        return(voterRegistry[voter] & (1 << proposalId) != 0);
    }


    // 获取提案详细信息
    // proposalId: 提案 ID
    // 返回: 提案名称、投票数、开始时间、结束时间、执行状态、是否活跃
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active
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
            (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)
        );
    }
}
