// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 通过编写该合约，学习gas优化

contract GasEffeicientVoting{
    
    // 总的合约数量，使用uint8, 2^8 = 256个
    uint8 public proposalCount;

    // 紧凑型结构体定义
    struct Proposal{
        bytes32 name;  // use bytes32 而不是长度不确定的string
        uint32 voteCount; // 0~42亿
        uint32 startTime; // 可以安全的支持秒级时间戳
        uint32 endTime;
        bool executed;  // 执行状态
    }

    //使用mapping 代替动态数组；因为前面我们已经确认了总合约数量最多是2^8个
    //所以可以使用一个8bit的整数作为合约id
    mapping(uint8 => Proposal) public proposals;

    // 使用uint256位图来记录每个合约的投票
    // map：投票用户地址-》投票的bitmap
    mapping(address => uint256) private voterRegistry;

    // 记录每个合约对应的投票总票数，map：proposalId-》voteCount
    mapping(uint8 => uint32) public proposalVoterCount;

    // 事件
    event ProposalCreated(uint8 indexed proposalId,bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);


    // 创建合约函数
    function createProposal(bytes32 _name, uint32 _duration) external{
        require(_duration>0, "Duration must be >0");

        uint8 proposalId = proposalCount; // 默认值为0，每创建一个合约占用一个坑
        proposalCount++;  // 计数增加

        Proposal memory newProposal = Proposal({
            name: _name,
            voteCount:0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + _duration,
            executed: false
        });

        proposals[proposalId] = newProposal;

        emit ProposalCreated(proposalId, _name);
    }

    function vote(uint8 _proposalId) external {
        require(_proposalId < proposalCount, "Invalid proposal");

        // precheck
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[_proposalId].startTime);
        require(currentTime <= proposals[_proposalId].endTime);

        // 检查用户之前是否已经投过票
        uint256 voterData = voterRegistry[msg.sender];
        uint256 mask = 1 << _proposalId;  // 左移运算
        require((voterData & mask) == 0, "You Already Voted");  // 与运算

        // 记录投票
        voterRegistry[msg.sender] = voterData | mask;  // 或运算

        // update vote count
        proposals[_proposalId].voteCount++;
        proposalVoterCount[_proposalId]++;

        emit Voted(msg.sender, _proposalId);
    }

    // 执行合约
    function executeProposal(uint8 _proposalId) external {
        require(_proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[_proposalId].endTime, "Not ended");
        require(!proposals[_proposalId].executed, "Already executed");
        
        proposals[_proposalId].executed = true;
        emit ProposalExecuted(_proposalId);
    }

    // 检查投票状态
    function hasVoted(address _voter, uint8 _proposalId) external view returns (bool) {
        return (voterRegistry[_voter] & (1 << _proposalId)) != 0;
    }
    
    // 获取提案详情
    function getProposal(uint8 _proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed
    ) {
        Proposal memory p = proposals[_proposalId];
        return (p.name, p.voteCount, p.startTime, p.endTime, p.executed);
    }

}

/**
Q：
1. solidity中函数的执行是否可能会被中断？比如像投票这里的在web2的业务开发中，可能需要使用事务来保证数据的一致性.

 */