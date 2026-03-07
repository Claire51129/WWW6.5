// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract PollStation{

    string[] public candidateNames;
    mapping(string => uint256) voteCount;
    mapping (address => bool) hasVoted;

    // 内部函数，判断候选人是否存在
    function candidateExists(string memory _candidateName) internal view returns (bool) {
        for (uint i = 0; i<candidateNames.length; i++) {
            if (keccak256(bytes(candidateNames[i])) == keccak256(bytes(_candidateName))){
                return true;
            }
        }
        return false;
    }

    function addCandidateNames(string memory _candidateName) public{
        require(!candidateExists(_candidateName), "candidate already exists");

        candidateNames.push(_candidateName);
        voteCount[_candidateName] = 0;
    }

    function getcandidateNames() public view returns (string[] memory){
        return candidateNames;
    }

    function vote(string memory _candidateName) public{
        require(!hasVoted[msg.sender],"You have already voted");
        require(candidateExists(_candidateName),"Candidate does not exist");

        voteCount[_candidateName]+=1;

        hasVoted[msg.sender] = true;
    }

    function getVote(string memory _candidateName) public view returns (uint256){
        require(candidateExists(_candidateName),"Candidate does not exist");

        return voteCount[_candidateName];
    }

}