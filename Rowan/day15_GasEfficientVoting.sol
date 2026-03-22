// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {

    // 记录当前提案总数量
    // 使用 uint8 可以节省 gas（最多支持 255 个提案）
    uint8 public proposalCount;

    // 提案结构体
    struct Proposal {
        bytes32 name;      // 提案名称（使用 bytes32 比 string 更省 gas）
        uint32 voteCount;  // 投票数量
        uint32 startTime;  // 投票开始时间（Unix 时间戳）
        uint32 endTime;    // 投票结束时间
        bool executed;     // 提案是否已经执行
    }

    // 使用 mapping 存储提案
    // mapping 比动态数组更节省 gas 并且访问更快
    mapping(uint8 => Proposal) public proposals;

    // 投票者注册表
    // 每个地址对应一个 uint256
    // 每一位(bit)表示是否对某个提案投过票
    mapping(address => uint256) private voterRegistry;

    // 记录每个提案的投票人数
    mapping(uint8 => uint32) public proposalVoterCount;

    // 事件：创建提案
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);

    // 事件：用户投票
    event Voted(address indexed voter, uint8 indexed proposalId);

    // 事件：提案执行
    event ProposalExecuted(uint8 indexed proposalId);

    // 创建提案函数
    function createProposal(bytes32 _name, uint32 duration) external {

        // 投票持续时间必须大于 0
        require(duration > 0, "Durations should be more than 0");

        // 获取当前提案ID
        uint8 proposalId = proposalCount;

        // 提案数量 +1
        proposalCount++;

        // 在 memory 中创建新的提案
        Proposal memory newProposal = Proposal({
            name: _name,
            voteCount: 0,
            startTime: uint32(block.timestamp), // 当前区块时间
            endTime: uint32(block.timestamp) + duration, // 结束时间
            executed: false
        });

        // 将提案存入 mapping
        proposals[proposalId] = newProposal;

        // 触发创建提案事件
        emit ProposalCreated(proposalId, _name);
    }

    // 投票函数
    function vote(uint8 proposalId) external {

        // 检查提案是否存在
        require(proposalId < proposalCount, "Invalid Proposal");

        // 获取当前时间
        uint32 currentTime = uint32(block.timestamp);

        // 检查投票是否已经开始
        require(currentTime >= proposals[proposalId].startTime, "Voting has not started");

        // 检查投票是否已经结束
        require(currentTime <= proposals[proposalId].endTime, "Voting has ended");

        // 读取该用户的投票数据
        uint256 voterData = voterRegistry[msg.sender];

        // 创建位掩码
        // 例如 proposalId = 2
        // mask = 000100
        uint256 mask = 1 << proposalId;

        // 检查该用户是否已经投过票
        require((voterData & mask) == 0, "Already voted");

        // 记录投票（使用 OR 运算设置对应位）
        voterRegistry[msg.sender] = voterData | mask;

        // 增加投票数量
        proposals[proposalId].voteCount++;

        // 增加投票人数
        proposalVoterCount[proposalId]++;

        // 触发投票事件
        emit Voted(msg.sender, proposalId);
    }

    // 执行提案函数
    function executeProposal(uint8 proposalId) external {

        // 检查提案是否存在
        require(proposalId < proposalCount, "Invalid Proposal");

        // 投票必须结束才能执行
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended ");

        // 确保提案还没有被执行
        require(!proposals[proposalId].executed, "Already executed");

        // 标记提案为已执行
        proposals[proposalId].executed = true;

        // 触发执行事件
        emit ProposalExecuted(proposalId);
    }

    // 查询某个地址是否对某个提案投过票
    function hasVoted(address voter, uint8 proposalId) external view returns(bool){

        // 通过位运算检查对应 bit 是否为 1
        return ((voterRegistry[voter] & (1 << proposalId)) != 0);
    }

    // 获取提案详细信息
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active
    ){

        // 检查提案是否存在
        require(proposalId < proposalCount, "Invalid proposal");

        // 读取提案
        Proposal storage proposal = proposals[proposalId];

        // 返回提案信息
        return(
            proposal.name,
            proposal.voteCount,
            proposal.startTime,
            proposal.endTime,
            proposal.executed,

            // 判断投票是否仍然进行中
            (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)
        );
    }
}
