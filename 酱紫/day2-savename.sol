// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SaveMyName {

    string name;
    string bio;
    uint256 age;        // 新增：年龄
    string occupation;  // 新增：职业

    // 更新添加功能，包含四个参数
    function add(string memory _name, string memory _bio, uint256 _age, string memory _occupation) public {
        name = _name;
        bio = _bio;
        age = _age;
        occupation = _occupation;
    }

    // 更新检索功能，返回四个值
    function retrieve() public view returns (string memory, string memory, uint256, string memory) {
        return (name, bio, age, occupation);
    }

    // 高效版本
    function saveAndRetrieve(string memory _name, string memory _bio, uint256 _age, string memory _occupation) public returns (string memory, string memory, uint256, string memory) {
        name = _name;
        bio = _bio;
        age = _age;
        occupation = _occupation;
        return (name, bio, age, occupation);
    }
}
