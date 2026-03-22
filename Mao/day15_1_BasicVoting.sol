// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
*通用投票合约（未经优化）:将消耗大量gas
这个合约旨在实现一个去中心化的简单投票系统，主要包含以下功能：
提议创建 (createProposal)：任何人都可以发起一个提案，并设定投票持续时间。
状态存储：需要记录提案的名字、票数、起止时间和是否已执行。
投票限制 (vote)：
必须在指定时间内投票。
每个地址对每个提案只能投一票（防止女巫攻击或重复投票）。
执行结果 (executeProposal)：投票结束后，标记提案为已完成，触发后续逻辑。

为什么消耗大量gas?
在以太坊上，存储（Storage）操作是最昂贵的。
A. 结构体布局未优化 (Storage Slot Packing)
Solidity 的存储插槽是 32 字节。
uint256 占用一整个插槽（32 字节）。 $32$ 字节 $\times 8$ 位/字节 $= 256$ 位。
在你的 struct 中，voteCount, startTime, endTime 都是 uint256，这会占用 3 个独立的插槽。
bool executed 虽然只占 1 字节，但因为它前后都是 uint256，它也会霸占一整个插槽。
浪费点：对于投票时间来说，uint64 已经足够支撑到几千年后了。

B. 频繁的 Storage 写入
每次调用 createProposal，由于使用了 proposals.push(...)，合约需要初始化所有字段并写入磁盘。
proposal.voteCount++ 是一次昂贵的 SSTORE 操作。

C. 字符串存储 (string name)
string 是动态大小的，存储成本很高。如果提案名字很长，Gas 消耗会急剧上升。

D. 映射逻辑的成本
mapping(address => mapping(uint => bool)) 虽然逻辑清晰，但这种嵌套映射在写入时会触发多次哈希计算和存储分配。

E. 默认值与冗余检查
proposal.executed = false：在 Solidity 中，默认值就是 false，手动赋值会多花 Gas。
require(block.timestamp >= proposal.startTime)：在 createProposal 里，startTime 就是当前时间，如果用户立即投票，这个检查几乎总是通过的，但每次都要读取存储。
*/

contract BaiscVoting {
    struct Proposal{
        string name;
        uint256 voteCount;
        uint256 startTime;
        uint256 endTime;
        bool executed;
    }
    Proposal[] public proposals;
    mapping(address => mapping(uint => bool)) public hasVoted;

    function createProposal(string memory name, uint duration) public {
        proposals.push(Proposal({
            name: name,
            voteCount: 0,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            executed: false
        }));
    }

    function vote(uint proposalId) public {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.startTime, "Too early");
        require(block.timestamp <= proposal.endTime, "Too late");
        require(!hasVoted[msg.sender][proposalId], "Already voted");

        hasVoted[msg.sender][proposalId] = true;
        proposal.voteCount++;
    }

    function executeProposal(uint proposalId) public {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Too early");
        require(!proposal.executed, "Already executed");

        proposal.executed = true;
        // Some execution logic here
    }

}