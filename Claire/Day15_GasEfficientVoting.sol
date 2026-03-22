// SPDX-License-Identifier: MIT
// 代码授权协议

pragma solidity ^0.8.0;
// 指定编译器版本

contract GasEfficientVoting {
// 省钱的投票系统（用二进制位记录投票，省gas）

	uint8 public proposalCount;
	// 提案总数，最多255个（uint8最大255）

	struct Proposal {
	// 提案结构体
		bytes32 name;
		// 提案名字（32字节）
		uint32 voteCount;
		// 得票数（32位整数，够用了）
		uint32 startTime;
		// 投票开始时间
		uint32 endTime;
		// 投票结束时间
		bool executed;
		// 是否已执行
	}

	mapping(uint8 => Proposal) public proposals;
	// 提案编号 → 提案详情

	mapping(address => uint256) private voterRegistry;
	// 【核心省钱技巧】每个人用一个uint256（256个二进制位）记录投过哪些提案
	// 比如：第0位=1表示投了提案0，第1位=1表示投了提案1...
	// 1个地址只用1个数字就能记录最多256个提案的投票情况，超级省gas！

	mapping(uint8 => uint32) public proposalVoterCount;
	// 每个提案有多少人投了票

	event ProposalCreated(uint8 indexed proposalId, bytes32 name);
	// 提案创建事件

	event Voted(address indexed voter, uint8 indexed proposalId);
	// 投票事件

	event ProposalExecuted(uint8 indexed proposalId);
	// 提案执行事件

	function createProposal(bytes32 _name, uint32 duration) external {
	// 创建新提案
		require(duration > 0, "Durations should be more than 0");
		// 投票时长必须大于0

		uint8 proposalId = proposalCount;
		// 新提案的编号 = 当前提案总数

		proposalCount++;
		// 提案总数+1

		Proposal memory newProposal = Proposal({
			name: _name,
			voteCount: 0,
			startTime: uint32(block.timestamp),
			endTime: uint32(block.timestamp) + duration,
			executed: false
		});
		// 创建新提案

		proposals[proposalId] = newProposal;
		// 存入mapping

		emit ProposalCreated(proposalId, _name);
		// 发出事件
	}

	function vote(uint8 proposalId) external {
	// 投票
		require(proposalId < proposalCount, "Invalid Proposal");
		// 提案必须存在

		uint32 currentTime = uint32(block.timestamp);
		// 当前时间

		require(currentTime >= proposals[proposalId].startTime, "Voting has not started");
		// 投票未开始不能投

		require(currentTime <= proposals[proposalId].endTime, "Voting has ended");
		// 投票已结束不能投

		uint256 voterData = voterRegistry[msg.sender];
		// 取出这个人的投票记录（一个数字，每个二进制位代表一个提案）

		// 【掩码详解】
		// 假设proposalId = 3
		// 1 << 3 意思是：把二进制数1向左移动3位
		// 1 (二进制) = 00000000...0000001
		// 左移3位后 = 00000000...0001000
		// 这样就得到了一个"掩码"，只有第3位是1，其他位都是0
		uint256 mask = 1 << proposalId;

		// 【& 按位与运算详解】
		// 用掩码检查这个人是否投过这个提案：
		// 例如：voterData = 000...001011 (表示投过提案0、1、3)
		//        mask      = 000...001000 (检查提案3)
		//        & 运算    = 000...001000 (结果不是0，说明投过了)
		// 如果没投过，那一位是0，&结果就是0
		require((voterRegistry[msg.sender] & mask) == 0, "Already voted");
		// 检查通过说明还没投过这个提案

		// 【| 按位或运算详解】
		// 记录这个人投了这个提案：
		// voterData = 000...001011 (已投0、1、3)
		// mask      = 000...010000 (现在投提案4)
		// | 运算    = 000...011011 (把第4位也变成1)
		voterRegistry[msg.sender] = voterData | mask;
		// 把这一位标记为1，表示投过了

		proposals[proposalId].voteCount++;
		// 这个提案的票数+1

		proposalVoterCount[proposalId]++;
		// 这个提案的投票人数+1

		emit Voted(msg.sender, proposalId);
		// 发出投票事件
	}

	function executeProposal(uint8 proposalId) external {
	// 执行提案
		require(proposalId < proposalCount, "Invalid Proposal");
		// 提案必须存在

		require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
		// 投票没结束不能执行

		require(!proposals[proposalId].executed, "Already executed");
		// 已经执行过的不能再执行

		proposals[proposalId].executed = true;
		// 标记为已执行

		emit ProposalExecuted(proposalId);
		// 发出执行事件
	}

	function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
	// 查询某人是否投过某提案
		// 用&运算检查对应位是不是1
		// (voterRegistry[voter] & (1 << proposalId)) != 0
		// 如果结果是0说明没投过，不是0说明投过了
		return (voterRegistry[voter] & (1 << proposalId)) != 0;
	}

	function getProposal(uint8 proposalId)
	// 获取提案详情
		external
		view
		returns (
			bytes32 name,
			uint32 voteCount,
			uint32 startTime,
			uint32 endTime,
			bool executed,
			bool active
		)
	{
		require(proposalId < proposalCount, "Invalid proposal");
		// 提案必须存在

		Proposal storage proposal = proposals[proposalId];
		// 取出提案

		return (
			proposal.name,
			proposal.voteCount,
			proposal.startTime,
			proposal.endTime,
			proposal.executed,
			(block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)
			// active = 是否在投票期内
		);
	}
}