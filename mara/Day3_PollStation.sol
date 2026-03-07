// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
contract PollStation {
    string[] public candidates;
    mapping(string => uint256) public votes;
    function addCandidateNames (string memory _name) public {
        candidates.push(_name);
        votes[_name] = 0;
    }
    function getCandidateNames() public view returns (string[] memory) {
        return candidates;
    }
    function vote(string memory _name) public {
        votes[_name] += 1;
    }
    function getVote(string memory _name) public view returns (uint256) {
        return votes[_name];
    }
}