// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PollStation{

    string[] public candidateNames;
    mapping(string => uint256) voteCount;

    // 记录某个名字是否是合法候选人
    mapping(string => bool) public isCandidate;
    //记录某个地址是否已经投过票
    mapping(address => bool) public hasVoted;

    // 事件：方便前端监听投票行为
    event Voted(address indexed voter, string candidate);
    event CandidateAdded(string candidate);

    function addCandidateNames(string memory _candidateNames) public{
        // 防止重复添加同一个候选人
        require(!isCandidate[_candidateNames], "Candidate already exists");

        candidateNames.push(_candidateNames);
        voteCount[_candidateNames] = 0;

        // 标记为合法候选人
        isCandidate[_candidateNames] = true;

        emit CandidateAdded(_candidateNames);
    }

    function getCandidateNames() public view returns (string[] memory){
        return candidateNames;
    }

    function vote(string memory _candidateNames) public{

        // 检查是否已经投过票
        require(!hasVoted[msg.sender], "You have already voted!");

        // 检查候选人是否存在
        require(isCandidate[_candidateNames], "Invalid candidate name!");
        
        voteCount[_candidateNames]+=1;

        // 标记该用户已投票
        hasVoted[msg.sender] = true;

        //发出事件
        emit Voted(msg.sender, _candidateNames);
    }

    function getVote(string memory _candidateNames) public view returns (uint256){
        return voteCount[_candidateNames];
    }

    // 查看自己是否投过票
    function checkMyVoteStatus() public view returns (bool) {
        return hasVoted[msg.sender];
    }
}