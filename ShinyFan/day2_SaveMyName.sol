// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SaveMyName{
    string name;
    string bio;
    //均为状态变量

    function add(string memory _name, string memory _bio) public{
        name = _name;
        bio = _bio;
        //_代表这不是状态变量，这是一个函数参数，同样改成newname也是一种函数参数
    }

    function retrieve() public view returns(string memory, string memory){
        return (name, bio);
        //retrieve是将数据拿回来，只读，如果不写view就是浪费钱，因为只读，也没add
    }
}