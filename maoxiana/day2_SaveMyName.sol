// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract SaveMyName {
 
    //状态变量 这里默认内部变量 默认存储在 storage 中（永久存在区块链上，很贵）
    string name;
    string bio;
    string gender;
    uint256 age;

    //函数 存储姓名和简介
    //_name 和 _bio是函数参数，作为临时输入，通常存放在 memory 中（只在调用时存在，便宜），函数结束临时输入销毁
    //uint256，不需要加 memory,Solidity 中，只有引用类型（string, bytes, array, struct）需要指定 memory
    function add(string memory _name,string memory _bio,string memory _gender,uint256 _age) public{
        name = _name;
        bio = _bio;
        gender = _gender;
        age = _age;
    }
    //retrieve()检索函数——从区块链获取数据
    function retrieve() public view returns (string memory , string memory,string memory,uint256 ) {
        return (name,bio,gender,age);        
    }

}

