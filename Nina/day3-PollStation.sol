//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PollStation{

    //声明candidateNames状态变量为string数组格式。当一个状态变量被声明为 public 时，Solidity 会自动为它创建一个同名的 Getter 函数；对于数组来说，输入uint256输出string，即可以查询第几位候选人的名字（始于0）。
    //声明voteCount状态变量为uint256格式且由string格式的数据映射
    string[] public candidateNames;
    mapping(string=>uint256) voteCount;

    //用户可公开调用addCandidateNames函数将候选人名字添加至candidateNames数组末尾，该候选人名字所映射的voteCount初始为0
    function addCandidateNames(string memory _candidateNames) public{
        candidateNames.push(_candidateNames);
        voteCount[_candidateNames]=0;
    }

    //用户可公开调用getCandidateNames函数查询到候选人名字数组
    function getCandidateNames() public view returns (string[] memory){
        return candidateNames;
    }

    //用户可公开调用vote函数，使某候选人票数+1
    function vote(string memory _candidateNames) public{
        voteCount[_candidateNames]+=1;
    }

    //用户可公开调用getVote函数查询到某位候选人的票数
    function getVote(string memory _candidateNames) public view returns (uint256){
        return voteCount [_candidateNames];
    }
}