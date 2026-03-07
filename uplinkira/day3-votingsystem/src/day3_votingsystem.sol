// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VotingSystem {
    string[] public candidateNames;
    mapping(string => uint256) public voteCount;
    mapping(string => bool) public candidateExists;

    function addCandidate(string memory _candidate) public {
        require(bytes(_candidate).length > 0, "Candidate name cannot be empty");
        require(!candidateExists[_candidate], "Candidate already exists");

        candidateExists[_candidate] = true;
        candidateNames.push(_candidate);
    }

    function vote(string memory _candidate) public {
        require(candidateExists[_candidate], "Unknown candidate");
        voteCount[_candidate] += 1;
    }

    function getCandidates() public view returns (string[] memory) {
        return candidateNames;
    }

    function getVotes(string memory _candidate) public view returns (uint256) {
        require(candidateExists[_candidate], "Unknown candidate");
        return voteCount[_candidate];
    }
}
