// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {

    uint8 public proposalCount;
    struct Proposal{
        bytes32 name;//byte32就是固定存32个字符，string是不固定长度花费gas多
        uint32 voteCount;
        uint32 startTime;
        uint32 endTime;
        bool executed;
    }

    mapping(uint8 => Proposal) public proposals;
    mapping(address =>uint256)private voterRegistry;
    mapping(uint8 =>uint256)public proposalVoterCount;//每个提案有多少票

    event ProposalCreated(uint8 indexed proposalId, bytes32 name);//提案创建事件
    event Voted(address indexed voter, uint8 indexed proposalId);//投票事件
    event ProposalExecuted(uint8 indexed proposalId);//提案执行事件

    function createProposal(bytes32 _name, uint32 duration) external{
        require(duration > 0, "Durations should be more than 0");
        uint8 proposalId = proposalCount;//保证每一个proposal有唯一的id，因为将proposalCount赋值给了id，每一个id拥有一个count（0、1、2、3......）
        proposalCount++;//每次创建自动+1
        Proposal memory newProposal = Proposal({//先临时储存，在链下构建数据结构之后一次性写入储存会更便宜
            name: _name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });

        proposals[proposalId] = newProposal;//将这个new的赋值给唯一的id
        emit ProposalCreated(proposalId, _name);//触发提案创建事件
    }

    //投票函数
    function vote(uint8 proposalId) external{
        require(proposalId < proposalCount, "Invalid Proposal");//如果id大于数量就代表这个proposal还没有被创建
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting has not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting has ended");

        //防止重复投票
        uint256 voterData = voterRegistry[msg.sender];
        uint256 mask = 1 << proposalId;//找到你要投的那一个
        require((voterRegistry[msg.sender] & mask) == 0, "Already voted");//检查这个是否已经投过
        voterRegistry[msg.sender] = voterData | mask;
        proposals[proposalId].voteCount++;//该提案投票数+1
        proposalVoterCount[proposalId]++;//总表里该提案投票数+1

        emit Voted(msg.sender, proposalId);

    }

       //执行提案
       function executeProposal(uint8 proposalId) external{
        require(proposalId < proposalCount, "Invalid Proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended ");//确保投票已经结束
        require(!proposals[proposalId].executed, "Already executed");//确保提案已经被执行
        proposals[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }

    //内部辅助函数
    function hasVoted(address voter, uint8 proposalId)external view returns(bool){
        return(voterRegistry[voter] & (1 << proposalId) != 0);
    }

      
    //内部辅助函数
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active
        ) //返回这些变量
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