// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting{
    uint8 public proposalCount;
    struct Proposal{
        bytes32 name;
        uint32 voteCount;
        uint32 startTime;
        uint32 endTime;
        bool executed;
    }

    mapping(uint8 => Proposal) public proposals;
    mapping(address => uint256)public voterRegistry;
    mapping(uint8 => uint32)public proposalVoterCount;

    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);


    function createProposal(bytes32 _name, uint32 duration) external{
        require(duration > 0,"Durations should be more than 0");
        uint8 proposalId = proposalCount;
        proposalCount ++;
        Proposal memory newProposal = Proposal({
            //用memory以在链下构建数据结构然后一次性写入storage
            //结构体初始化 花括号{}中用键值对赋值
            name: _name,
            voteCount : 0,
            startTime : uint32(block.timestamp),
            endTime : uint32(block.timestamp + duration),
            executed: false
            });
        proposals[proposalId] = newProposal;//所有在函数体之外声明的变量都是状态变量(state var)默认存在永久存储空间storage中

        emit ProposalCreated(proposalId , _name);
    }

    function vote(uint8 proposalId) external{
        //写错：require(proposals[proposalId], "Proposal doesn't exist");require需要一个布尔值 不存在隐式转换
        require(proposalId < proposalCount, "Invalid proposal");
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting has not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting has ended");

        uint256 voterdata = voterRegistry[msg.sender];
        uint256 mask = 1 << proposalId;
        //很关键！将投票历史压缩进一个整型变量中 使用左移运算符<<和用count更新的ProposalId来实现
        //相当于一个有特定编号孔洞的模版 用位运算符| &来检查
        require((voterdata & mask) == 0, "Already voted");//要括起来！
        proposals[proposalId].voteCount++;
        voterRegistry[msg.sender] = voterdata | mask;
        //OR来合并新旧运算 votedata是旧记录 mask是新投票的章子 OR相当于盖章

        emit Voted(msg.sender, proposalId);
    }
   
    function executeProposal(uint8 proposalId) external{
    require(proposalId < proposalCount, "Invalid proposal");
    require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
    require(!proposals[proposalId].executed, "Already executed");

    proposals[proposalId].executed = true;
    emit ProposalExecuted(proposalId);
   }

    function hasVoted(address voter, uint8 proposalId) external view returns(bool){
    return (voterRegistry[voter] & (1 << proposalId)) != 0;//此行一个判断式 返回布尔值 不等于零即为1-投过票返回true
   }
   
    function getProposal(uint8 proposalId) external view returns(
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active//指示投票当前是否正在进行
    ){
        require(proposalId < proposalCount, "Invalid proposal");

        Proposal storage proposal = proposals[proposalId];
        //storage 关键字用于局部变量时，它告诉编译器：“直接指向已经在合约存储中存在的数据，不要进行复制
        //memory才是复制一个副本
        return(        
            proposal.name,
            proposal.voteCount,
            proposal.startTime,
            proposal.endTime,
            proposal.executed,
            block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime
        );
    }
}