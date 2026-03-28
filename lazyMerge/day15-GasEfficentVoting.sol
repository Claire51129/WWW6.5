// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    uint8  public proposalCount; // 这里使用了 uint8 来代替 uint256

    struct Proposal {
        bytes32 name; // bytes32 固定大小 代替 string，更便宜
        uint32 voteCount; // 更少的存储槽以为着更低的 GAS
        uint32 startTime; // timestamp
        uint32 endTime;
        bool executed;
    }

    mapping(uint8 => Proposal) public proposals; // 用映射来代替数组，（O(1)）

    mapping(address => uint256) private voterRegistry; // 这里每一个位（bit）代表对该提案是否投票
    mapping(uint8 => uint32) public proposalVoterCount; // 这里记录每个提案有多少投票

    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);

    // ethers.utils.formatBytes32String("ssss") 生成 bytes32
    // 0x7373737300000000000000000000000000000000000000000000000000000000
    function createProposal(bytes32 name, uint32 duration) external {
        require(duration > 0, "Duration must be > 0");

        uint8 proposalId  = proposalCount;
        proposalCount++;

        Proposal memory newProposal = Proposal({
            name: name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });

        proposals[proposalId] = newProposal;
        emit ProposalCreated(proposalId,name);
    }

      
    function vote(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");

        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting ended");

        uint256 voterData = voterRegistry[msg.sender];
        // 1 <<  创建一个二进制掩码 例如 000100  proposalId 为 2
        // 位运算 AND 检查该位是否已在用户的注册表中设置
        uint256 mask = 1 << proposalId; 
        require((voterData & mask) == 0, "Already voted");

        // 位运算OR 将位置 `proposalId` 处的位设置为 `1`，标记投票。
        voterRegistry[msg.sender] = voterData | mask;

        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;

        emit Voted(msg.sender, proposalId);
    }

      
    // 投票期结束后执行提案
    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed, "Already executed");

        proposals[proposalId].executed = true;

        emit ProposalExecuted(proposalId);
    }

    // 检查该位是否在投票者的注册表中设置  
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }

    // 检查提案是否存在  view
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
            (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)
        );
    }
}