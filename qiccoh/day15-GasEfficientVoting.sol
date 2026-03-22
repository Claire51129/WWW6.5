// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// Gas 优化--用户交互的合约,以节省gas
contract GasEfficientVoting {
    
    // uint8 只占1个字节(8位 000 ) 0-225 节省存储空间
    uint8 public proposalCount;
    
    // 更少的存储槽意味着更低的 Gas---Solidity 将结构体数据打包存储在 32 字节的块中
    struct Proposal {
        bytes32 name;          //bytes32 比 string 便宜
        uint32 voteCount;      //足矣支撑4.3亿votes
        uint32 startTime;      // Unix timestamp (supports dates until year 2106)
        uint32 endTime;        // Unix timestamp
        bool executed;         // 一个字节表示
    }
    
    // 映射为我们提供了对每个提案的直接访问,不需要迭代
    // Proposal-->对象
    mapping(uint8 => Proposal) public proposals;
    
    //一个地址:有uint256  有32个字节 256位数 可以表示256个提案
    // 每个地址对提案1-256号的投票情况
    mapping(address => uint256) private voterRegistry;
    
    // 每个提案 总投票数
    mapping(uint8 => uint32) public proposalVoterCount;
    
    // 事件 个人投票情况
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);
    
// 传入数据必须是bytes32格式，十分的不方便
    function createProposal(bytes32 name, uint32 duration) external {
        // 持续时间>0
        require(duration > 0, "Duration must be > 0");
        
        // 生成提案号码
        uint8 proposalId = proposalCount;
        proposalCount++;
        
        // memory 内存用后即废 更便宜 
        // 创建一个对象 Proposal ,并存储到newProposal里面
        Proposal memory newProposal = Proposal({
            // 初始化提案内容
            name: name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + duration,
            executed: false//是否执行 是false
        });
        // proposalId-->key  ,newProposal--->words(创建提案内容)
        proposals[proposalId] = newProposal;
        // 事件弹出--提案序号,名字被创建
        emit ProposalCreated(proposalId, name);
    }
    
// 投票---> 防止一个人投多次(voterData & mask) == 0
    function vote(uint8 proposalId) external {
        // proposalCount-->用完后自加,永远大于创建的提案数量
        require(proposalId < proposalCount, "Invalid proposal");
        
        // 现在的时间在开始和结束之间
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting ended");
        
        // 传输当前地址的投票数据给voterData-->返回32位的uint256数
        uint256 voterData = voterRegistry[msg.sender];
        // 神奇!创建一个掩码,把1先左移动proposalId 位置.===把第proposalId位改为1
        // `````返回proposalId的数 它只关心 某个特定提案，其他提案不影响`````
        uint256 mask = 1 << proposalId;
        // voterData & mask 两个的二进制数不一样 ,没投过
        // 那如果是  voterData = 00001010（第1号和第3号提案投过）
// mask     = 00000010（第1号提案的开关）
// & 结果   = 00000010 → 不等于0 → 已经投过第1号提案.牛 只关心mask位的值是否一致 其它不考虑
        require((voterData & mask) == 0, "Already voted");
        
        // 把voterData和mask 加在一起 形成新的uint256码存进去
        voterRegistry[msg.sender] = voterData | mask;
        
        // 每个提案的投票值+1
        proposals[proposalId].voteCount++;
        // 和上面有什么不同呢? 我感觉并没有被限制
        proposalVoterCount[proposalId]++;
        // 触发投票事件
        emit Voted(msg.sender, proposalId);
    }
    

    // 在投票期结束后执行提案
    function executeProposal(uint8 proposalId) external {
        //提案存在
        require(proposalId < proposalCount, "Invalid proposal");
        //投票窗口已经结束
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
       // 没执行过
        require(!proposals[proposalId].executed, "Already executed");
        
        proposals[proposalId].executed = true;
        // 接下来可以写执行的具体措施

        emit ProposalExecuted(proposalId);
        
    }
    
    
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        // 检查 投票者是否在 proposalId 这个提案中投过票 投过就返回true
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }
    
//   返回提案的状态
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active
    ) {
        require(proposalId < proposalCount, "Invalid proposal");
        // storage 引用的是链上的原始数据，直接读取存储槽，高效且不会复制数据
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