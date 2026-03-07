// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
contract PollStation {
	string [] public candidateNames;
	mapping(string => uint256) voteCount;
	mapping(string => bool) isCandidate;
	mapping(address => bool) hasVoted;

	// Add _name to string
	// Initialise votes
	function addCandidate(string memory _name) public {
		candidateNames.push(_name);
		voteCount[_name] = 0;
		isCandidate[_name] = true;
	}
	// Check whether has voted already and candidate exists
	// Increment vote
	function vote(string memory _name) public {
		require(isCandidate[_name], "Candidate not exist");
		require(!hasVoted[msg.sender], "Already voted");
		voteCount[_name]++;
		hasVoted[msg.sender] = true;
	}
	// Get candidate string
	function getCandidate() public view returns (string [] memory) {
		return (candidateNames);
	}
	// Check whether candidate exists
	// Get vote of each candidate
	function getVote(string memory _name) public view returns (uint256) {
		require(isCandidate[_name], "Candidate not exist");
		return (voteCount[_name]);
	}
}