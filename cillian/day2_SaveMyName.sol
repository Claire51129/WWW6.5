//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract SaveMyName{

    //状态变量-字符串
    string name;
    string bio;

    //函数，存储用户输入数据
    function add(string memory _name, string memory _bio) public {
        name = _name;
        bio = _bio;
    }

    //函数，读取并返回数据
    function retrieve() public view returns(string memory, string memory){
        return(name,bio);
    }

}