// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SaveMyName {
    // 状态变量 - 永久存储在区块链上
    string name;
    string bio;

    // 添加/更新数据
    function add(string memory _name, string memory _bio) public {
        name = _name;
        bio = _bio;
    }

    // 只读函数 - 检索数据
    function retrieve() public view returns (string memory, string memory) {
        return (name, bio);
    }

    // 组合函数 - 保存并立即返回
    function saveAndRetrieve(string memory _name, string memory _bio)
        public returns (string memory, string memory) {
            name = _name;
            bio = _bio;
            return (name,bio);
        }
}