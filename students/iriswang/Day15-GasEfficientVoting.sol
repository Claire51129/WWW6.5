// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    // 提案总数（用8位整数省gas）
    uint8 public proposalCount;

    //提案结构体————小变量挤在一个槽里（省存储）
    struct Proposal{
        bytes32 name; //提案名称（32字节，定长） 
        uint32 voteCount; // 该提案当前得票数（4字节）
        uint32 startTime; //投票开始时间戳（4字节）
        uint32 endTime; //投票结束时间戳（4字节）
        bool executed; // 是否已执行 1字节）
         // 注意：上面的四个小字段（voteCount,startTime,endTime,executed）被Solidity自动打包在同一个存储槽中，节省gas。
         string ipfsHash; // 新增IPFS 哈希，存储描述信息（动态字符串）
    }



 // 按提案编号查找具体提案信息（就像按序号查字典）
    mapping(uint8 => Proposal) public proposals;
    // 核心优化：记录每个地址对每个提案是否投过票
    // 每个地址对应一个uint256，这个数的每一位（bit）代表一个提案（共256位）
    // 例如：位0=提案0，位1=提案1，... 1表示已投票，0表示未投票
    mapping(address => uint256) private voterRegistry;
    // 每个提案的总投票人数（方便统计，不用遍历所有地址）
    mapping(uint8 => uint32) public proposalVoterCount;
    // 事件：用于在链上记录重要操作，方便外部应用监听
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);
 // 创建新提案（调用者提供名称和投票持续时间）
 function createProposal(bytes32 name, uint32 duration, string memory _ipfsHash) external{
    uint8 proposalId = proposalCount; // 新提案编号=当前总数（从0开始）
    proposalCount++;

    proposals[proposalId] = Proposal({
        name: name,
        voteCount:0,
        startTime: uint32(block.timestamp),
        endTime: uint32(block.timestamp + duration),
        executed: false,
        ipfsHash: _ipfsHash
    });
    emit ProposalCreated(proposalId, name); // 触发事件，记录提案创建
 }
 // 为制定提案投票
 function vote (uint8 proposalId) external{
    //前置检查：提案是否存在、是否在投票时间内、是否尚未执行
    require(proposalId < proposalCount, "Invalid proposal");
    require(block.timestamp >= proposals[proposalId].startTime, "Not Started");
    require(block.timestamp <= proposals[proposalId].endTime, "Ended");
    require(!proposals[proposalId].executed, "Already executed");

// 获取调用者的投票记录（32字节整数，每位代表一个提案）
        uint256 voterData = voterRegistry[msg.sender];
        // 构造掩码：只有第 proposalId 位为1，其余为0（例如 proposalId=3，则 mask= 1<<3 = 8）
        uint256 mask = 1 << proposalId;
        // 检查是否已对该提案投票：通过按位与，如果结果不为0，说明该位已为1，即已投票
        require((voterData & mask) == 0, "Already voted");
        // 更新投票记录：将对应的位置为1（按位或）
        voterRegistry[msg.sender] = voterData | mask;
         // 更新提案的得票数和投票人数统计
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;
emit Voted(msg.sender, proposalId); // 触发投票时间
 }
  // 投票结束后执行提案（任何人都可以调用，仅标记为已执行）
  function executeProposal(uint8 proposalId) external{
    require(proposalId < proposalCount, "Invalid proposal");
    require(block.timestamp > proposals[proposalId].endTime, "Not ended");
    require(!proposals[proposalId].executed, "Already executed");
    proposals[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }
    // 查询某地址是否对某提案投过票
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }
    // 获取提案详细信息
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        string memory ipfsHash
        ) {
        Proposal memory p = proposals[proposalId];
        return (p.name, p.voteCount, p.startTime, p.endTime, p.executed, p.ipfsHash);
    }
}
