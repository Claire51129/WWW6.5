// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract PollStation {
    string[] public candidateNames;
    mapping(string => uint256) voteCount;

    function addCandidateNames(string memory _candidateNames) public {
        candidateNames.push(_candidateNames);
    }

    function getcandidateNames() public view returns (string[] memory) {
        return candidateNames;
    }

    function vote(string memory _candidateNames) public returns (uint256) {
        voteCount[_candidateNames]++;
        return voteCount[_candidateNames];
    }
}