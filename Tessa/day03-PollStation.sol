// 一个公开的投票箱：解析数组和映射在实际合约中的应用
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PollStation{    //投票站合约（一个链上的投票系统）

    string[] public candidateNames;    //string表示文字；[]表示数组
    mapping(string => uint256) voteCount;

    //添加候选人
    function addCandidateNames(string memory _candidateNames) public{
        candidateNames.push(_candidateNames);    //push()表示：在数组最后添加一个元素
        voteCount[_candidateNames] = 0;   //在映射里初始化票数，新候选人从0票开始
    }

    //获取所有候选人名字
    function getcandidateNames() public view returns (string[] memory){ //view只读取，不修改数据，不花钱；string[]说明返回一个名字数组
        return candidateNames;   // 把候选人数组返回
    }

    //投票
    function vote(string memory _candidateNames) public{   //投票输入候选人名字
        voteCount[_candidateNames] += 1;    //该候选人票数+1
    }

    //查询票数
    function getVote(string memory _candidateNames) public view returns (uint256){   //只是告诉系统规则，该函数将会返回一个非负数数据，eg“我等会儿给你一个数字”
        return voteCount[_candidateNames];   // 真正返回数据
    }

}


// 数组array：专门用来装一排有顺序的东西，比如把所有投票候选人的名字挨个列出来存着；
// 映射mapping：专门干“一对一查找”的活【对应】，比如把你的钱包地址和你投的候选人绑在一起，差的时候输地址就能立刻知道你投了谁；mapping像一本字典，输入一个东西，就能找到对应的值
// 使用场景：链上投票、调研、统计类合约、覆盖道、网络金融、社区治理等；
// 区块链合约核心价值：“不可篡改、公开可验证”