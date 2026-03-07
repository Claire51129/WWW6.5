// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PollStation{
    string[] public candidateNames;
    mapping(string => uint256) public voteCount;
    mapping(string => bool) public isCandidateExists;

    function addCandidate(string memory _newName) public{
        // check: is name valid
        require(bytes(_newName).length > 0, "ERROR! Cannot be empty!");
        // check: is name already existed 
        require(!isCandidateExists[_newName], "ERROR! Already exists");
        // add new name to the list
        candidateNames.push(_newName);
        // update revelant 
        isCandidateExists[_newName] = true;
        // default value is zero, skip mannually set.
        // voteCount[_newName] = 0;
    }

    function vote(string memory targetName) public{
        // check: is name valid
        require(isCandidateExists[targetName], "ERROR! Not exist, add first!");
        voteCount[targetName]++;
    }

    // function getAllVoteResults() public view returns (string[] memory, uint256[] memory) {
    //     // create a temp uint list
    //     uint256[] memory counts = new uint256[](candidateNames.length);
        
    //     // go through each one
    //     for (uint256 i = 0; i < candidateNames.length; i++) {
    //         counts[i] = voteCount[candidateNames[i]];
    //     }
        
    //     return (candidateNames, counts);
    // }

    function getVote(string memory _name) public view returns(uint256){
        return voteCount[_name];
    }
}