//SPDX-Lisense-Identifier:MIT

//存储姓名和简介，一个函数存储，一个函数读取
//知识点：关键字view只读不费gas， 数据位置关键字 memory：内存 storage：存储
pragma solidity ^0.8.0;

contract SaveMyName{
    //定义状态变量name bio
    string name;
    string bio;

    //存储函数add
    function add(string memory _name, string memory _bio) public {
        name = _name;
        bio = _bio;
    }

    //读取姓名和简介
    function retrieve()public view returns(string memory,string memory){
         return (name,bio);
    }

}