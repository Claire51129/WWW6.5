// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title GasEfficientVoting
 * @dev 基于位运算的 Gas 高效投票合约
 * 核心优化：用 uint256 位图存储投票状态，替代双重 mapping
 */
contract GasEfficientVoting {
    // 提案总数（ID 从 0 开始自增）
    uint8 public proposalCount;

    // 提案结构体：存储提案核心信息
    struct Proposal {
        bytes32 name;        // 提案名（bytes32 比 string 更省 Gas）
        uint32 voteCount;    // 得票数
        uint32 startTime;    // 投票开始时间（Unix 时间戳）
        uint32 endTime;      // 投票结束时间
        bool executed;       // 是否已执行
    }

    // 提案 ID => 提案数据
    mapping(uint8 => Proposal) public proposals;
    // 地址 => 投票位图（核心 Gas 优化：每一位代表一个提案的投票状态）
    mapping(address => uint256) private voterRegistry;
    // 提案 ID => 投票人数（可选，用于统计）
    mapping(uint8 => uint32) public proposalVoterCount;

    // 事件定义：用于链下监听合约状态
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);

    /**
     * @dev 创建新提案
     * @param name 提案名称（bytes32 格式）
     * @param duration 投票持续时间（秒）
     */
    function createProposal(bytes32 name, uint32 duration) external {
        require(duration > 0, "Duration must be > 0");
        
        uint8 proposalId = proposalCount;
        proposalCount++; // 提案 ID 自增

        // 用 memory 创建临时提案，再存入 storage，减少 Gas 消耗
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
     * @dev 给指定提案投票
     * @param proposalId 提案 ID
     */
    function vote(uint8 proposalId) external {
        // 校验 1：提案 ID 有效
        require(proposalId < proposalCount, "Invalid proposal");
        // 校验 2：当前在投票期内
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting ended");
        // 校验 3：未给该提案投过票
        uint256 voterData = voterRegistry[msg.sender];
        uint256 mask = 1 << proposalId; // 生成对应提案的位掩码
        require((voterData & mask) == 0, "Already voted");

        // 标记为已投（位或运算）
        voterRegistry[msg.sender] = voterData | mask;
        // 增加提案票数
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;

        emit Voted(msg.sender, proposalId);
    }

    /**
     * @dev 执行投票通过的提案
     * @param proposalId 提案 ID
     */
    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed, "Already executed");

        proposals[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }

    /**
     * @dev 查询某地址是否给某提案投过票
     * @param voter 投票人地址
     * @param proposalId 提案 ID
     */
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        uint256 mask = 1 << proposalId;
        return (voterRegistry[voter] & mask) != 0;
    }

    /**
     * @dev 获取提案完整信息
     * @param proposalId 提案 ID
     */
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active // 是否在投票期
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