// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PollStation{

    string [] public candidateNames;
    mapping (string => uint256) voteCount;

    function addCandidateNames(string memory newcandidateNames) public{
        candidateNames.push(newcandidateNames);
        voteCount[newcandidateNames] = 0;
    }

    function getcandidateNames()public view returns (string[] memory){
        return candidateNames;
    }

    function vote(string memory newcandidateNames) public{
        voteCount[newcandidateNames] +=1;
    }

    function getVotes(string memory newcandidateNames) public view returns (uint256){
        return voteCount[newcandidateNames];
    }

}