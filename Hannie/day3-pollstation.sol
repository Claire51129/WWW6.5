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

    // 投票
    function vote(string memory _candidateNames) public {
        voteCount[_candidateNames]++;
    }

    // 查看某个候选人的票数
    function getVote(
        string memory _candidateNames
    ) public view returns (uint256) {
        return voteCount[_candidateNames];
    }
}
