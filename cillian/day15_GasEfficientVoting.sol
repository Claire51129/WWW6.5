// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {

    // 提案总数计数器
    uint8 public proposalCount;

    // 提案的数据结构
    struct Proposal {
        bytes32 name;      // 提案名称（固定 32 字节，省 Gas）
        uint32 voteCount;  // 累计票数
        uint32 startTime;  // 投票开始时间戳
        uint32 endTime;    // 投票结束时间戳
        bool executed;     // 是否已执行
    }

    // 提案 ID 到提案详情的映射 
    mapping(uint8 => Proposal) public proposals;
    // 核心位图：记录每个地址在所有提案中的投票状态（1个 uint256 存 256 个开关）
    mapping(address => uint256) private voterRegistry;
    // 记录每个提案对应的投票总人数
    mapping(uint8 => uint32)public proposalVoterCount;

    // 当新提案创建时触发
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    // 当有人投票成功时触发
    event Voted(address indexed voter, uint8 indexed proposalId);
    // 当提案被正式执行时触发
    event ProposalExecuted(uint8 indexed proposalId);

    // 创建新提案，输入名称和持续时长
    function createProposal(bytes32 _name, uint32 duration) external {
        require(duration > 0, "Durations must be more than 0");

        // 确定ID并自增
        uint8 proposalId = proposalCount;
        proposalCount++;

        Proposal memory newProposal = Proposal({ // 这个结构体先在内存里组装，最后再通过映射存储到区块链上，省gas
            name: _name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });
        proposals[proposalId] = newProposal;

        emit ProposalCreated(proposalId, _name); // 触发事件：通知外部系统（如网页）某个 ID 的提案已成功创建
    }

    // 核心投票逻辑，使用位运算检查并记录投票状态
    function vote(uint8 proposalId) external {

        // 检查：确保输入的提案 ID 在已创建的范围内（防止访问不存在的提案）
        require(proposalId < proposalCount, "Invalid Proposal");
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting has not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting has ended");

        // 从状态变量中读取当前投票者的位图数据（记录了该地址所有的投票历史）
        uint256 voterData = voterRegistry[msg.sender];
        // 核心位运算：将 1 左移 proposalId 位，生成一个只有该 ID 位置为 1 的“掩码”
        uint256 mask = 1 << proposalId;
        // 检查：通过“按位与”运算检查掩码位。如果结果不为 0，说明该用户已经投过这个 ID 的票
        require((voterRegistry[msg.sender] & mask) == 0, "Already voted");

        // 将旧的投票记录(voterData)与代表当前提案位置的掩码(mask)进行合并
        voterRegistry[msg.sender] = voterData | mask; // 只要对应的位是 1，就保持为 1；原来是 0 的位置，如果是当前提案，则变为 1

        // 增加该提案在结构体中的总票数
        proposals[proposalId].voteCount++;
        // 增加该提案在独立映射中的投票人数统计
        proposalVoterCount[proposalId]++;
        // 触发事件：在区块链日志中记录本次投票行为，方便前端查询
        emit Voted(msg.sender, proposalId);
        
    }

    // 在投票结束后，将提案标记为已执行状态
    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid Proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended ");
        require(!proposals[proposalId].executed, "Already executed");

        // 状态变更：将该提案的 executed 属性设置为 true，正式关闭该提案
        proposals[proposalId].executed = true;
        // 触发事件：在区块链日志中记录该提案已执行，方便外部应用（如 DAO 管理后台）追踪
        emit ProposalExecuted(proposalId);
    }

    // 查询某个地址是否已经投过某个特定提案的票
    function hasVoted(address voter, uint8 proposalId) external view returns(bool) {
        return(voterRegistry[voter] & (1 << proposalId) != 0);
    }

    // 获取提案的完整详情，并实时返回该提案是否处于活跃（可投票）状态
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active
    ){
        require(proposalId < proposalCount, "Invalid proposal");

        Proposal storage proposal = proposals[proposalId]; //使用 storage 避免将整个结构体拷贝到内存, 可以直接从原位读取
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