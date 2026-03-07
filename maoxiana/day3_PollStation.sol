//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract PollStation {
    //数组是相同类型元素的列表。在 Solidity 中，数组可以保存数字、字符串、地址或其他数据类型。
    string[] public candidateNames; //候选人姓名列表 [] 代表array？
    //映射就像一个字典，它将键（在这种情况下是代表候选人姓名的 string）链接到值（代表其票数的 uint256）
    mapping (string => uint256) voteCounts; //投票计数，候选人姓名映射到票数?

    function addCandidateNames(string memory _candidateNames)  public{
        candidateNames.push(_candidateNames); //push()函数将新候选人姓名添加到候选人列表中
        voteCounts[_candidateNames] = 0; //初始化新候选人的票数为0
        
    }

    function getcandidateNames() public view returns (string[] memory) {
        return candidateNames; //返回候选人姓名列表
        
    }

    function vote(string memory _candidateNames)  public {
        require(voteCounts[_candidateNames] >= 0, "Candidate does not exist"); //检查候选人是否存在
        voteCounts[_candidateNames] += 1; //给候选人投票，票数加1
        
    }

    function getVotes(string memory _candidateNames) public view returns (uint256) {
        return voteCounts[_candidateNames]; //返回候选人的票数
    }


}