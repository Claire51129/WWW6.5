// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    // 使用uint8而不是uint256
    uint8 public proposalCount;
    bytes32 proposal = bytes32(keccak256(abi.encodePacked("Proposal 1")));

    //结构体打包
    struct Proposal {
        bytes32 name;      // 32 bytes 名称
        uint32 voteCount;   // 4 bytes  | 投票数
        uint32 startTime;   // 4 bytes  | 打包在同一槽位 开始时间
        uint32 endTime;     // 4 bytes  | 结束时间
        bool executed;      // 1 byte   | 执行状态
    }
    
    //映射代替数组(O(1)查找)
    mapping(uint8 => Proposal) public proposals; //将 uint8 类型的键映射到 Proposal 类型的值，且为公共变量
    
    //位运算存储投票状态
    mapping(address => uint256) private voterRegistry;//私有映射，用于存储投票者登记信息
    mapping(uint8 => uint32) public proposalVoterCount;//公共映射，记录提案的投票者数量
    
    // 事件
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);//当提案创建时触发，记录提案ID和名称
    event Voted(address indexed voter, uint8 indexed proposalId);// 当投票时触发，记录投票者地址和提案ID
    event ProposalExecuted(uint8 indexed proposalId);//当提案执行时触发，记录提案ID
    
    // 创建提案
    function createProposal(bytes32 name, uint32 duration) external {//定义cp的外部函数，用于创建提案。
        uint8 proposalId = proposalCount;//函数内将 proposalCount 赋值给 proposalId
        proposalCount++;//自增 proposalCount 
        
        Proposal memory newProposal = Proposal({ //在内存中创建一个新的 Proposal 结构体实例
            name: name,//设置提案名称
            voteCount: 0,//设置提案初始投票数为 0
            startTime: uint32(block.timestamp),//设置提案开始时间为当前区块时间戳
            endTime: uint32(block.timestamp + duration),//设置提案结束时间为当前区块时间戳加上持续时间
            executed: false//设置提案执行状态为 false
        });
        
        proposals[proposalId] = newProposal;//将新创建的提案存储到proposals映射中，以 proposalId 为键
        emit ProposalCreated(proposalId, name);//触发 ProposalCreated 事件，传递提案 ID 和名称
    }
    
    // 投票 (使用位运算)
    function vote(uint8 proposalId) external {//定义外部投票函数 vote
        require(proposalId < proposalCount, "Invalid proposal");//查提案 ID 是否有效
        require(block.timestamp >= proposals[proposalId].startTime, "Not started");//检查当前时间是否在提案开始之后
        require(block.timestamp <= proposals[proposalId].endTime, "Ended");//检查当前时间是否在提案结束之前
        require(!proposals[proposalId].executed, "Already executed");//检查提案是否未被执行 
        
        uint256 voterData = voterRegistry[msg.sender];//从 voterRegistry 中获取当前发送者的投票数据
        uint256 mask = 1 << proposalId;//创建一个掩码，用于记录投票情况，后续代码中用于检查用户是否已经投过票
        
        // 检查是否已投票
        require((voterData & mask) == 0, "Already voted");//若不为 0 则表示已投票，抛出 “Already voted” 错误
        
        // 记录投票
        voterRegistry[msg.sender] = voterData | mask;//在 voterRegistry 中记录当前投票者对该提案已投票
        proposals[proposalId].voteCount++;//对应提案的 voteCount（投票计数）增加 1
        proposalVoterCount[proposalId]++;//增加对应提案的总投票者数量 。
        
        emit Voted(msg.sender, proposalId);//触发 Voted 事件，记录投票者地址和提案 ID
    }
    
    // 执行提案
    function executeProposal(uint8 proposalId) external {//定义外部函数 executeProposal 用于执行提案
        require(proposalId < proposalCount, "Invalid proposal");//检查提案 ID 是否有效
        require(block.timestamp > proposals[proposalId].endTime, "Not ended");//检查当前时间是否在提案结束之后
        require(!proposals[proposalId].executed, "Already executed");//检查提案是否未被执行 
        
        proposals[proposalId].executed = true;//将指定提案的执行状态标记为已执行
        emit ProposalExecuted(proposalId);//触发 ProposalExecuted 事件，传递提案 ID
    }
    
    // 检查投票状态
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {  //定义外部只读函数 hasVoted，用于检查指定投票者是否对特定提案投过票
        return (voterRegistry[voter] & (1 << proposalId)) != 0;//通过位运算检查 voterRegistry 中对应位是否为 1，来判断是否投票 
    }
    
    // 获取提案详情
    function getProposal(uint8 proposalId) external view returns (  //定义外部只读函数 getProposal 获取提案详情
        bytes32 name,//声明要返回的提案名称变量
        uint32 voteCount,//声明要返回的提案投票数变量
        uint32 startTime,//声明要返回的提案开始时间变量
        uint32 endTime,//声明要返回的提案结束时间变量。
        bool executed//声明要返回的提案执行状态变量
    ) {
        Proposal memory p = proposals[proposalId];//在内存中创建变量 p，并从 proposals 映射中获取指定提案 ID 的提案信息
        return (p.name, p.voteCount, p.startTime, p.endTime, p.executed);//返回提案的相关信息，包括名称、投票数、开始时间、结束时间和执行状态
    }
}