// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollStation{
    string[] public candidateNames;
    mapping(string => uint256) public voteCount;
    mapping(address => string) public votedFor;
    mapping(address => bool) public voter;

    function addCandidatesNames(string memory _candidateNames) public {
        candidateNames.push(_candidateNames);
        voteCount[_candidateNames] = 0;
    }

    function vote(string memory _candidateNames) public {
        require(!voter[msg.sender], "You have already voted!");
        votedFor[msg.sender] = _candidateNames;
        voteCount[_candidateNames] += 1;
        voter[msg.sender] = true;
    }

    function getCandidateNames() public view returns (string[] memory) {
        return candidateNames;
    }

    function getVote(string memory _candidateNames) public view returns (uint256) {
        return voteCount[_candidateNames];
    }

    function getVotedFor(address _voter) public view returns (string memory) {
        return votedFor[_voter];
    }

    function myVoteFor() public view returns (string memory) {
        return votedFor[msg.sender];
    }
}