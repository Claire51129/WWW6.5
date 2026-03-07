// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PollStation{

    string[] public candidateNames;
    mapping (string => uint256) private voteCount;
    mapping (address =>bool) private hasVoted;

    function addCandidateNames (string memory _candidateNames) public {
        candidateNames.push(_candidateNames);
        voteCount[_candidateNames] =0;
    }

    function getcandidateNames() public view returns (string[] memory){
        return candidateNames;
    }

    function vote(string memory _candidateNames) public {
        require(!hasVoted[msg.sender],"you have already voted");
        require(isValidCandidate(_candidateNames),"Candidate does not exist");
       
        voteCount[_candidateNames] +=1;
        hasVoted[msg.sender]=true;
    }

    function getvoteCount(string memory _candidateNames) public view returns (uint256){
        return voteCount[_candidateNames];
    }

    function isValidCandidate(string memory _candidateNames) internal view returns (bool){
        for (uint i = 0; i <  candidateNames.length; i++){
            if (keccak256(bytes(candidateNames[i]))==keccak256(bytes(_candidateNames))){
                return true;
            }
        }
        return false;
    }
    
}