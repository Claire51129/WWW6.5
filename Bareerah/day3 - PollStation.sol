// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollStation {
    string[] public candidateNames;
    mapping(string => uint256) voteCount;
    mapping(address => bool) public hasVoted;
    
    function addCandidateNames(string memory _candidateNames) public {
        candidateNames.push(_candidateNames);
    }
    
    function getcandidateNames() public view returns (string[] memory) {
        return candidateNames;
    }

    function isExist(string memory _candidateNames) private view returns (bool) {
        for(uint i = 0; i < candidateNames.length; i++){
            if(keccak256(bytes(candidateNames[i])) == keccak256(bytes(_candidateNames))){
                return true;
            }
        }
        return false;
    }
    
    function vote(string memory _candidateNames) public {
        require(isExist(_candidateNames), "This candidate is NOT exists!");
        require(!hasVoted[msg.sender], "Already voted!");
        voteCount[_candidateNames]++;
        hasVoted[msg.sender] = true;
    }
    
    function getVote(string memory _candidateNames) public view returns (uint256) {
        return voteCount[_candidateNames];
    }
}