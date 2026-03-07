// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PollStation {
    string[] public candidateNames;
    mapping(string => uint256) private voteCount;
    // 跟踪候选人是否存在
    mapping(string => bool) private candidateExists;
    // 跟踪用户是否已经投票
    mapping(address => bool) private voted;

    function addCandidateNames(string memory _candidateName) public {
        candidateNames.push(_candidateName);
        voteCount[_candidateName] = 0;
        candidateExists[_candidateName] = true;
    }

    function getCandidateNames() public view returns (string[] memory) {
        return candidateNames;
    }

    function vote(string memory _candidateName) public {
        // 防止多次投票
        require(!voted[msg.sender], "Already voted");
        // 确保用户不能为不存在的候选人投票
        require(candidateExists[_candidateName], "Candidate does not exist");
        voteCount[_candidateName] += 1;
        voted[msg.sender] = true;
    }

    function getVote(string memory _candidateName) public view returns (uint256) {
        return voteCount[_candidateName];
    }

}
