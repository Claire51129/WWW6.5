//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract SaveMyName {
    string public name;
    string public info;
    uint public age;

    //定义一个事件，用来“广播”存入的信息
    event InfoSaved(string _name, string _info);

    //保存个人信息
    function save(string memory _name, string memory _info) public {
        name = _name;
        info = _info;
    }

    function save(string memory _name, string memory _info, uint _age) public {
        name = _name;
        info = _info;
        age = _age;
    }

    //获取个人信息
    function getInfos() public view returns (string memory, string memory) {
        return (name, info);
    }

    //新增信息返回个人信息
    function saveAndGetInfos(string memory _name, string memory _info) public returns(string memory, string memory) {
        name = _name;
        info = _info;
        //触发事件,也仅仅是在日志中打印info，依然无法在页面上展示结果
        emit InfoSaved(_name, _info);
        //直接return无法在页面上展示结果
        return (name, info);
    }

}