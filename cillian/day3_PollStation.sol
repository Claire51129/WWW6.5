//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract PollStation{

    //字符串数组-候选人名字列表，映射（数组=>非负整数）-候选人名字对应得票数
    string[] public candidateNames;
    mapping (string => uint256) voteCount;

    //函数，添加一个候选人名字，并使其初始投票值为0
    function addCandidateNames(string memory _candidateName) public{ //从solidity0.5.0版本开始，所有引用类型变量都要显式指出存储在哪里，memory就是临时存储，函数执行完即销毁
        candidateNames.push(_candidateName);
        voteCount[_candidateName] = 0;
    }

    //函数，获取候选人名字列表
    function getCandidateNames() public view returns(string[] memory){
        return candidateNames;
    }

    //函数，为某一候选人投一票
    function vote(string memory _candidateName) public{
        voteCount[_candidateName] += 1;
    }

    //函数，获取某一候选人得票数
    function getVote(string memory _candidateName) public view returns(uint256){ //这里返回的值不需要加memory，是因为unit256是固定数值，系统不需要提前腾出一块地方
        return voteCount[_candidateName];
    }

}

