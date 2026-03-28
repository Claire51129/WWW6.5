//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract GasEfficientVoting {
    //uint8 is 1 byte, it's more gas efficient when
    //the variable is state variable & it can be packed w/ other small var
    //eg 3 uint8 var can be packed into 1 storage slot
    uint8 public proposalCount;

    //一个storage slot = 32bytes
    //slot越多需要的gas越多
    struct Proposal{
        //需要两个slot 
        bytes32 name; //32bytes是固定大小 更省gas string是动态类的
        uint32 voteCount;//4bytes
        uint32 startTime;//4bytes
        uint32 endTime;//4bytes
        bool executed; //1byte

     }


    //store all proposals
    mapping(uint8 => Proposal) public proposals;
    //记录谁都投了啥
    mapping(address =>uint256) private voterRegistry;
    //store votes for each proposal
    mapping(uint8 => uint32)public proposalVoterCount;


    //向大家广播新的proposal被创建啦
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    //向大家广播谁投了什么proposal
    event Voted(address indexed voter, uint8 indexed proposalId);
    //向大家广播某个proposal被执行啦
    event ProposalExecuted(uint8 indexed proposalId);

    //创建proposal， proposal名，投票持续多久 外部可调用
    function createProposal(bytes32 _name, uint32 duration) external{
        require(duration > 0, "duration should be more than 0"); //in seconds
        uint8 proposalId = proposalCount; //第一次创建proposal时proposalCount 默认是 0
        proposalCount++;

        Proposal memory newProposal = Proposal({
            name: _name,
            voteCount: 0,
            startTime: uint32(block.timestamp), //区块链现在的时间
            endTime: uint32(block.timestamp) + duration,
            executed: false //刚创建还未执行

        
        });
        //把newProposal这张临时卡store到proposals这个链上柜子里 proposals作为state var本来就住在柜子里
        proposals[proposalId] = newProposal;
        emit ProposalCreated(proposalId,_name);

    }


    function vote(uint8 proposalId) external{
        require(proposalId < proposalCount, "invalid proposal");
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "voting has not started");
        require(currentTime <= proposals[proposalId].endTime, "voting has ended");
        
        uint256 voterData = voterRegistry[msg.sender];
        // 做一张只对准某个位置的proposalId的位置的小卡片
        //正常写 mapping(address => mapping(uint8 => bool)) voted; 给每个voter和proposal单独记录投票状态
        //// mask 用来只检查/修改proposalId对应的那一位
        uint256 mask = 1 << proposalId;
        require((voterRegistry[msg.sender] & mask) == 0, "already voted"); 
        voterRegistry[msg.sender] = voterData | mask;
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;

        emit Voted(msg.sender, proposalId);


    }

    function executeProposal(uint8 proposalId) external{
        require(proposalId < proposalCount,"invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed,"already executed");
        proposals[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }


//view： read only 
    function hasVoted(address voter, uint8 proposalId) external view returns(bool){
        return (voterRegistry[voter] & (1 << proposalId)) != 0 ;

    }

//查询proposal详情
    function getProposal(uint8 proposalId) external view returns(
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active
    ){
        //查询这个proposal是否存在
        require(proposalId < proposalCount, "invalid proposal");

        //要从这个mapping里调取这个编号的proposal storage：链上真实存在
        Proposal storage proposal = proposals[proposalId];//后面可以简化写法
        return(
            proposal.name,
            proposal.voteCount,
            proposal.startTime,
            proposal.endTime,
            proposal.executed,
            //现在的时间如果在开始和结束之间就说明这个proposal是active的状态
            (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)
    );

        
    }








}


