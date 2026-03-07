//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollStation {
    //候选人列表
    string[] candidateNames;

    //候选人票数
    mapping(string => uint) voteCount;

    //防止重复投票
    mapping (address => bool) hasVoted;

    //添加候选人
    function addCandidateNames(string memory _candidateName) public {
        require(!ifCandidateExist(_candidateName), "Candidate Already Exist");
        candidateNames.push(_candidateName);
    }
    
    //获取所有候选人
    function getAllCandidateNames() public view returns(string[] memory) {
        return candidateNames;
    }

    //投票
    function vote(string memory _candidateName) public {
        require(!hasVoted[msg.sender], "Already voted");
        require(ifCandidateExist(_candidateName), "Invalid Candidate");

        hasVoted[msg.sender] = true;
        voteCount[_candidateName] ++;
    }

    //判断候选人是否已经存在
    function ifCandidateExist(string memory _candidate) private view returns (bool) {
        for(uint i=0; i<candidateNames.length;i++) {
            if (keccak256(bytes(candidateNames[i])) == keccak256(bytes(_candidate))) {
                return true;
            }
        }
        return false;
    }

    //查询某个候选人的票数
    function getVotes(string memory _candidateName) public view returns (uint){
        return voteCount[_candidateName];
    }

}