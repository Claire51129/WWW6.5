// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract GasEfficientVoting {
    //直接定义一个proposalCount，不用再多一步来读取和更新数组length
    uint8 public proposalCount;

    //结构体中存储的类型从string和uint256变为bytes32和uint32，节省slot
    struct Proposal {
        bytes32 name;
        uint32 voteCount;
        uint32 startTime;
        uint32 endTime;
        bool executed;
    }

    //将uint8的proposalId映射至Proposal，避免数组太消耗gas
    mapping(uint8 => Proposal) public proposals;

    //用bit记录用户地址是否给某proposal投过票
    mapping(address => uint256) private voterRegistry;

    //统计某proposal的票数
    mapping(uint8 => uint32) public proposalVoterCount;
    
    //用event来记录重要事件，比storage更省gas
    event CreateProposal(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);

    function createProposal(bytes32 name, uint32 duration) external{
        require(duration > 0, "Invalid duration");
        uint8 proposalId = proposalCount;
        proposalCount ++;
        Proposal memory newProposal = Proposal({
            name: name,
            voteCount: 0,
            startTime: uint32(block.timestamp),     //用uint32来记录当前时间戳，便宜
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });
        proposals[proposalId] = newProposal;
        emit CreateProposal(proposalId, name);
    }

    function vote(uint8 proposalId) external {
        require(proposalId < proposalCount,"Invalid proposal");
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime ,"Vote not start yet");
        require(currentTime <= proposals[proposalId].endTime,"Vote has ended");
        uint256 voterData = voterRegistry[msg.sender];      //获取用户的投票信息
        uint256 mask = 1 << proposalId;     //新建一个mask，将对应proposalId的位置设为1
        require((voterData & mask) == 0,"Already voted");       //如果voterData对应mask为1的位置也是1，则用户已投票，不能重复投票
        voterRegistry[msg.sender] = voterData | mask;       //若用户还未投票，将voterData对应mask为1的位置改为1，标记为已投票
        proposals[proposalId].voteCount ++;     //票数+1
        proposalVoterCount[proposalId] ++;      //投票人数+1，如果后面设计投票权重，则voteCount和voterCount会不一样
        emit Voted(msg.sender,proposalId);
    }

    function executedProposal(uint8 proposalId) external {
        require(proposalId < proposalCount,"Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime,"Vote has not ended yet");
        require(!proposals[proposalId].executed, "Already executed");
        proposals[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }

    //前面voterRegistry设为了private，故此处需要一个view函数来查看用户对某proposal的投票情况
    function hasVoted(address voter, uint8 proposalId) external view returns(bool) {
        return(voterRegistry[voter] & (1 << proposalId)) != 0;
    }

    function getProposal(uint8 proposalId) external view returns(
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active     //检查当前投票是否正在进行中
    ){
        require(proposalId < proposalCount,"Invalid proposal");
        //创建一个变量 proposal，它直接指向 storage 中的 proposals[proposalId]
        Proposal storage proposal = proposals[proposalId];
        return(
            proposal.name,
            proposal.voteCount,
            proposal.startTime,
            proposal.endTime,
            proposal.executed,
            (block.timestamp <= proposal.startTime && block.timestamp >= proposal.endTime)
        );
    }
}