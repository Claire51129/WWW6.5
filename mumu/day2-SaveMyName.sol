// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 无继承合约
// 保存名字和个人简介
contract SaveMyName{
    string name;
    string bio;

    // 年龄
    uint age; 

    // add 添加/更新数据
    function add(string memory _name, string memory _bio) public {
        name = _name;
        bio = _bio;
    }


    // retrieve - view 只读函数，不修改状态
    function retrieve() public view returns (string memory, string memory){
        return (name, bio);
    }

    // saveAndRetrieve 保存并立即返回
    function saveAndRetrieve(string memory _name, string memory _bio) 
        public returns (string memory, string memory) {
            name = _name;
            bio = _bio;
            return (name, bio);
    }

    // getName
    function getName() public view returns (string memory){
        return name;
    }

    // getBio
    function getBio() public view returns (string memory){
        return bio;
    }

    // updateName
    function updateName(string memory _newName) public {
        name = _newName;
    }

    function updateBio(string memory _bio) public {
        bio = _bio;
    }

    function updateAge(uint _age) public {
        age = _age;
    }

    function getAge() public view returns (uint){
        return age;
    }
}

/*
为什么字符串参数需要使用memory修饰符，但是uint参数不需要呢？
因为string是引用类型，由于大小不定，需要指定其存储位置；uint是值类型，由于值类型大小固定，而且所占内存比较小，所以编译器有固定的处理方式

引用类型需要关心的存储位置（Data Loaction）有以下三种：
    - storage：持久化存储在链上
    - memory：runtime中的临时内存（内存or栈上）
    - calldata：只读的临时参数区，常用于external函数参数
核心原则：值类型永远不需要指定location，引用类型在非状态变量时必须指定。
记忆口诀：
    状态变量在仓库（storage）
    函数参数看用途：
    要修改，用内存（memory）
    只读取，用calldata省费用
    局部变量想清楚：
    新数据，内存放（memory）
    老数据，仓库指（storage引用）

    值类型不用写，写了反而错
    引用类型必须写，不写编译错
 */