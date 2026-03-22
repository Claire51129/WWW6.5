// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract GasEfficientVoting {
    uint8 public proposalCount;

    struct Proposal {
        bytes32 name; //string动态长度
        uint32 voteCount;//最大值为42亿（2的32次方）
        uint32 startTime;//可以用到2106年
        uint32 endTime;
        bool executed;

    }

    mapping(uint8 => Proposal) public proposals;
    mapping(address => uint256) private voterRegistry;
    //mapping(address => mapping(uint8 => bool)) 防重复投票：
    //记录某个用户（address）是否已经对某个特定问题（uint8）投过票（bool）。
    mapping(uint8 => uint32) public proposalVoterCount;

    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);

    function createProposal(bytes32 name, uint32 duration) external {
    //external意味着函数是对外开放的窗口，给合约外部的人调用
    //external 不能给内部函数以及继承合约使用，public可以
    //传入name时，EVM会直接从交易数据包里读取折32个字节，不会在内存里重新开辟空间去存它
    //如果改成public，EVM会强制把name和duration拷贝一份存入Memory

    require(duration > 0, "Duration must be > 0");

    uint8 proposalId = proposalCount;
    //proposalCount定义在函数的外面，是状态变量，在storage储存
    //proposalId定义在函数内部，是局部变量，在Memory或者Stack储存
    proposalCount++;

    Proposal memory newProposal = Proposal({
        //左边的Proposal类型申明，之前定义的struct Proposal结构，右边的Proposal填表动作
        //针对struct，array，string复杂的类型必须告诉编译器存储位置
        name: name,
        voteCount: 0,
        startTime: uint32(block.timestamp),
        endTime: uint32(block.timestamp) + duration,
        executed: false
    });
    
    proposals[proposalId] = newProposal;
    emit ProposalCreated(proposalId, name);

    }

    function vote(uint8 proposalId) external{
        require(proposalId < proposalCount, "Invalid proposal");

        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting ended");

        uint256 voterData = voterRegistry[msg.sender];
        uint256 mask = 1 << proposalId;
        // <<把数字1的二进制位向左移动proposalId个位置
        require((voterData & mask) == 0, "Already voted");
        // 调用vote（2），uint256最末端的1向左移动2位，require voterData & mask结果只取决第二位
        voterRegistry[msg.sender] = voterData | mask;
        //位运算，每个位置上是1，叠加还是1；一个1，一个0，叠加是1；2个都是0，叠加是0；
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;

        emit Voted(msg.sender, proposalId);
    }

    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed, "Already executed");

        proposals[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }

    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        return (voterRegistry[voter] & (1 << proposalId)) != 0;

        //1<<prposalId是本次运行，所以他的值肯定是1，拿这个针去看voterRegistry同样位置的是不是1，如果不是1，说明之前没有登记，所以还没有投票成功
    }

    function getProposal(uint8 proposalId) external view returns(
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        // uint32 算数字，bytes32存的容器
        bool executed,
        bool active
    ){
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