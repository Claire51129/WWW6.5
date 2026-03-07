// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollStation {

    string[] candidateNames;
    mapping (string => bool) isCandidate;
    mapping (string => uint256) voteCount;
    mapping (address => bool) isVoted;

    // 添加候选人姓名
    function addCandidateNames (string memory _name) public {
        candidateNames.push(_name); //添加候选人
        voteCount[_name] = 0; //初始化候选人票数
        isCandidate[_name] = true; //用于判断候选人是否存在
    }    

    // 检索候选人列表
    function getCandidateNames () public view returns (string[] memory) {
        return candidateNames;
    }

    // 为候选人投票篇
    function voteForCandidate(string memory _name) public {
        if (!hasVoted(msg.sender)) { //若候选人已经投票，则isVoted[_voter] = true，取非不进判断
            require(validCandidate(_name)); //判断候选人是否存在
            voteCount[_name] += 1;
            isVoted[msg.sender] = true; //判断候选人是否投票
        }
    }

    // 检查候选人的票数
    function getVoteCount(string memory _name) public view returns (uint256) {
        return voteCount[_name];
    }

    // 检查候选人是否存在
    function validCandidate(string memory _name) private view returns (bool) {
        return isCandidate[_name];
    }

    // 检查投票人是否重复投票
    function hasVoted(address _voter) private view returns (bool) {
        return isVoted[_voter];
    }
}

