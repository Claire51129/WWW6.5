//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PollStation {
    string[] public candidateNames;
    mapping(string => uint256) voteCount;
    mapping(address => bool) haveVoted;

    function addCandidateNames(string memory _candidateNames) public {
        candidateNames.push(_candidateNames);
        voteCount[_candidateNames] = 0;
    }

    function getCandidateNames() public view returns (string[] memory) {
        return candidateNames;
    }

    function vote(string memory _candidateNames) public {
        require(!haveVoted[msg.sender], "You have already voted");
        bool candidateExists = false;
        for(uint i = 0; i < candidateNames.length; i++){
            if(keccak256(bytes(candidateNames[i])) == keccak256(bytes(_candidateNames))) {
                voteCount[candidateNames[i]] += 1;
                haveVoted[msg.sender] = true;
                candidateExists = true;
                break;
            }
        }
        require(candidateExists, "Candidate does not exist");
    }

    function getVote(string memory _candidateNames) public view returns (uint256) {
        return voteCount[_candidateNames];
    }
}
