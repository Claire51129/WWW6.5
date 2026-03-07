// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract PollStation{
    string [] condidateNames;
    mapping (string=> uint256) voteCount;

    function addCondidateNames(string memory _condidateNames) public{
        condidateNames.push(_condidateNames);
        voteCount[_condidateNames]=0;
    }

    function getCondidateNames() public view returns(string[] memory){
        return condidateNames;
    }
    function vote(string memory _condidateNames) public{
        voteCount[_condidateNames]+=1;
    }
        
    function getVote(string memory _condidationNames) public view returns(uint256){
            return voteCount[_condidationNames];
    }

}