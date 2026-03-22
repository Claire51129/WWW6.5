// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollStation {
    string[] public candidateNames;
    mapping(string => uint256) public voteCount;
    
    function addCandidate(string memory _candidateNames) public { //Infinite gas in the context of a function typically means that the function does not have a gas limit set, allowing it to consume as much gas as needed to execute. This can be risky and lead to high transaction costs or failed transactions if the gas runs out.
        candidateNames.push(_candidateNames);
        voteCount[_candidateNames] = 0; //initializes the vote count for a candidate to zero,_to distinguish a function parameter with a state variable because they share a similar names, the _ helps avoid confusion:
    }

    function vote(string memory _candidateNames) public {
        voteCount[_candidateNames]++;
    }

    function getCandidateNames() public view returns(string[] memory) {
        return candidateNames;
    }

    function getVote(string memory _candidateNames) public view returns(uint256) {
        return voteCount[_candidateNames];
    }

}
