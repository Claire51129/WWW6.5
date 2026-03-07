// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SaveMyName {
    // 永久存储在区块链上的合约
    string name;
    string bio;
    uint age;
    
    // 添加/更新数据
    function add(string memory _name, string memory _bio, uint _age) public {
        name = _name;
        bio = _bio;
        age = _age;
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
        return (name, bio);
    }

    //只返回名字
    function getName() public view returns (string memory) {
        return name;
    }

    //只返回简介
    function getbio()public view returns(string memory){
        return bio;
    }

    //只更新姓名
    function updatename(string memory _newName) public {
        name = _newName;
    }

    //返回年龄
    function getAge()public view returns (uint256) {
        return age;
    }
}  