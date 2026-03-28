// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//这是一个使用位图(Bitmap)实现的高效投票合约示例。每个 uint256 槽位可以存储 256 个投票状态，极大地降低了 Gas 消耗。
contract GasEfficientVoting {
    // 使用位图存储投票状态：mapping(提案ID => mapping(组索引 => 位图数据))
    // 组索引计算方式：用户ID / 256
    mapping(uint256 => mapping(uint256 => uint256)) private voteBitmaps;

    event Voted(uint256 indexed proposalId, uint256 voterId);

    //@notice 执行投票.@param proposalId 提案的唯一标识.@param voterId 用户的数字 ID (需确保唯一且从 0 开始分配)
    function vote(uint256 proposalId, uint256 voterId) public {
        // 1. 计算该用户在哪个 uint256 组中
        uint256 bucket = voterId / 256;
        
        // 2. 计算在该 uint256 中的具体哪一位 (0-255)
        uint256 mask = 1 << (voterId % 256);

        // 3. 检查是否已经投过票
        require((voteBitmaps[proposalId][bucket] & mask) == 0, "Already voted");

        // 4. 记录投票：将对应位置设为 1
        voteBitmaps[proposalId][bucket] |= mask;

        emit Voted(proposalId, voterId);
    }

    //@notice 检查用户是否已投票.@return bool 是否已投票
    function hasVoted(uint256 proposalId, uint256 voterId) public view returns (bool) {
        uint256 bucket = voterId / 256;
        uint256 mask = 1 << (voterId % 256);
        return (voteBitmaps[proposalId][bucket] & mask) != 0;
    }
}
