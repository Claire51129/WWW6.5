// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollStation {
    // 候选人列表(数组 - 可遍历)
    string[] public candidateNames;
    
    // 票数统计(映射 - 快速查询)
    mapping(string => uint256) voteCount;
    
    // 添加候选人
    function addCandidateNames(string memory _candidateNames) public {
        candidateNames.push(_candidateNames);
    }
    
    // 获取所有候选人
    function getcandidateNames() public view returns (string[] memory) {
        return candidateNames;
    }
    

    // 添加mapping(address => bool) public hasVoted,防止重复投票
    mapping(address => bool) public hasVoted;
    // 投票
    function vote(string memory _candidateNames) public {
        // 添加mapping(address => bool) public hasVoted,防止重复投票
        if (hasVoted[msg.sender]) {
            revert("You have already voted.");
        }

        // 修改vote函数,检查候选人是否存在
        if (voteCount[_candidateNames] == 0) {
            revert("Candidate does not exist.");
        }

        voteCount[_candidateNames]++;
        hasVoted[msg.sender] = true;


    }
    
    // 查看某个候选人的票数
    function getVote(string memory _candidateNames) public view returns (uint256) {
        return voteCount[_candidateNames];
    }

}