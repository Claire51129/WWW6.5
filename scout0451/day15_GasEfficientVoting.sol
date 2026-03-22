//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract GasEfficientVoting{

    //uint8代替uint256节省存储字节
    uint8 public proposalCount;
    
    //结构体数据存储在32字节块中
    struct Proposal{
        bytes32 name;       //固定大小，便宜
        uint32 voteCount;
        uint32 startTime;
        uint32 endTime;
        bool executed;
    }

    //映射代替数组，对每个提案直接访问
    mapping(uint8 => Proposal) public proposals;
   
   //投票者所有记录压缩在uint256
    mapping(address => uint256)private voterRegistry;
    mapping(uint8 =>uint32)public proposalVoterCount;

    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);

    function createProposal(bytes32 _name, uint32 duration) external{
        require(duration > 0, "Durations should be more than 0");
        
        //数组需要动态调整大小和额外的 Gas 进行边界管理
        uint8 proposalId = proposalCount;
        proposalCount++;
        
        //在链下构建数据结构然后只写入存储一次
        Proposal memory newProposal = Proposal({
            name: _name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });
        proposals[proposalId] = newProposal;
        emit ProposalCreated(proposalId, _name);
    }

    function vote(uint8 proposalId) external{
        require(proposalId < proposalCount, "Invalid Proposal");
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting has not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting has ended");

        uint256 voterData = voterRegistry[msg.sender];
        
        //1 << proposalId 创建一个二进制掩码
        uint256 mask = 1 << proposalId;
        
        //& mask：用这个掩码去 “碰” 总状态==0表示没投票
        require((voterRegistry[msg.sender] & mask) == 0, "Already voted");
        voterRegistry[msg.sender] = voterData | mask;
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;

        emit Voted(msg.sender, proposalId);

    }

    function executeProposal(uint8 proposalId) external{
        require(proposalId < proposalCount, "Invalid Proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended ");
        require(!proposals[proposalId].executed, "Already executed");
        proposals[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }

    function hasVoted(address voter, uint8 proposalId)external view returns(bool){
        
        //只需一次存储访问(storage access)和一次位运算(bitwise operation)
        return(voterRegistry[voter] & (1 << proposalId) != 0);
    }

      
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active        //投票当前是否正在进行。
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