// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Vote {
    string[] candidateNames;
    mapping(string => uint256) voteCount;
    mapping(address => bool) hasVoted;
    mapping(address => string) votedCandidate;


    //添加候选人
    function addCandidateNames(string memory _candidateNames) public {
        candidateNames.push(_candidateNames);
        voteCount[_candidateNames] = 0;
    }

    //检索候选人
    function getcandidateNames() public view returns (string[] memory) {
        return candidateNames;
    }

    

    //为候选人投票 先判断是否投过票和是否存在候选人
    function vote(string memory _candidateNames) public returns (address) {
        require(!hasVoted[msg.sender], "You have already voted");
        require(isCandidate(_candidateNames), "Candidate does not exist");
        voteCount[_candidateNames] += 1;
        hasVoted[msg.sender] = true;
        votedCandidate[msg.sender] = _candidateNames;
        return msg.sender;
    }
    //可显示地址版本 存疑 还是只在log显示 不在部署按钮下方显示
    // event Voted(address voter, string candidate);
    // function vote(string memory _candidateNames) public {
    //     require(!hasVoted[msg.sender], "You have already voted");
    //     require(isCandidate(_candidateNames), "Candidate does not exist");
    //     voteCount[_candidateNames] += 1;
    //     hasVoted[msg.sender] = true;
    //     votedCandidate[msg.sender] = _candidateNames;
    //     emit Voted(msg.sender, _candidateNames);
    // }

    // Check if candidate exists
    function isCandidate(string memory _candidateNames) public view returns (bool) {
        for (uint i = 0; i < candidateNames.length; i++) {
            if (keccak256(bytes(candidateNames[i])) == keccak256(bytes(_candidateNames))) {
                return true;
            }
        }
        return false;
    }


    //检查候选人的票数
    function getVote(string memory _candidateNames) public view returns (uint256) {
        return voteCount[_candidateNames];
    }


    // Get voted candidate for an address
    function getVotedCandidate(address _voter) public view returns (string memory) {
        return votedCandidate[_voter];
    }



}
