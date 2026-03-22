// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    // 1. 极简的计数器
    uint8 public proposalCount;

    // 2. 完美打包的结构体（俄罗斯方块）
    struct Proposal {
        bytes32 name;       
        uint32 voteCount;   
        uint32 startTime;   
        uint32 endTime;     
        bool executed;      
    }

    // 3. 告别数组，使用字典
    mapping(uint8 => Proposal) public proposals;
    
    // 4. 终极杀招：用 1 个 uint256 存 256 次投票记录
    mapping(address => uint256) private voterRegistry;
    
    // 5. 记录每个提案的投票总人数（可选功能）
    mapping(uint8 => uint32) public proposalVoterCount;

    // 6. 大喇叭
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);

    // ==========================================
    // 核心功能 1：创建提案
    // ==========================================
    function createProposal(bytes32 name, uint32 duration) external {
        require(duration > 0, "Duration must be > 0"); 
        
        uint8 proposalId = proposalCount; 
        proposalCount++; 

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

    // ==========================================
    // 核心功能 2：投票（位运算魔法）
    // ==========================================
    function vote(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting not started");
        require(currentTime < proposals[proposalId].endTime, "Voting ended");

        uint256 voterData = voterRegistry[msg.sender];
        uint256 mask = 1 << proposalId;
        
        require((voterData & mask) == 0, "Already voted");

        voterRegistry[msg.sender] = voterData | mask;
        
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;
        
        emit Voted(msg.sender, proposalId);
    }

    // ==========================================
    // 核心功能 3：执行提案
    // ==========================================
    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed, "Already executed");

        proposals[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }

    // ==========================================
    // 辅助功能：查询
    // ==========================================
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }

    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active
    ) {
        require(proposalId < proposalCount, "Invalid proposal");
        Proposal storage proposal = proposals[proposalId];
        
        return (
            proposal.name,
            proposal.voteCount,
            proposal.startTime,
            proposal.endTime,
            proposal.executed,
            (block.timestamp >= proposal.startTime && block.timestamp < proposal.endTime)
        );
    }
}
