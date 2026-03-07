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
        return (name, bio);
    }

    // 添加一个getName()函数,只返回姓名(提示:单返回值不需要括号)
    function getName() public view returns (string memory) {
        return name;
    }

    // 添加一个getBio()函数,只返回简介
     function getBio() public view returns (string memory) {
        return bio;
    }

    // 添加一个updateName(string memory _newName)函数,只更新姓名
    function updateName(string memory _newName) public {
        name = _newName;
    }

    // 添加一个age状态变量(uint类型)和相应的函数
    uint public age;
    function updateAge(uint _newAge) public {
        age = _newAge;
    }

    // 为什么字符串参数要用memory,但uint参数不需要?
    // 因为字符串是一个动态数组,需要在内存中分配空间,而uint是一个固定大小的类型,不需要在内存中分配空间
}