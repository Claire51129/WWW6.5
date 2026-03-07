// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollStation{
    string[] public candidateNames;
    mapping(string => uint256) public voteCount;

    // 记录用户的投票记录，每个用户仅能为一个人投票
    mapping(address => string) private voteFor;

    // 事件记录
    event CandidateAdded(string candidateName);
    event Voted(address indexed voter, string candidateName, uint256 totalVotes);

    // 修改器：检查候选人是否存在
    modifier candidateExists(string memory _candidateName) {
        require(_candidateExists(_candidateName), "Candidate does not exist");
        _;
    }

    // 1. 向投票中添加候选人
    function addCandidate(string memory _candidateName) public {
        require(bytes(_candidateName).length > 0, "Candidate name cannot be empty");

        // 检查候选人是否已存在
        for(uint i = 0; i < candidateNames.length; i++) {
            if (keccak256(bytes(candidateNames[i])) == keccak256(bytes(_candidateName))) {
                revert("Candidate already exists");
            }
        }

        candidateNames.push(_candidateName);
        voteCount[_candidateName] = 0;

        emit CandidateAdded(_candidateName);
    }

    // 2. 检索候选人列表
    function getCandidateNames() public view returns (string[] memory) {
        return candidateNames;
    }

    // 3. 为候选人投票
    function vote(string memory _candidateName) public candidateExists(_candidateName) {
        // 修复1：检查空字符串
        require(bytes(_candidateName).length > 0, "You cannot vote for no one");

        // 修复2：检查用户是否已投票（字符串比较）
        require(bytes(voteFor[msg.sender]).length == 0, "You can only vote for one time");

        voteCount[_candidateName] += 1;
        voteFor[msg.sender] = _candidateName;

        emit Voted(msg.sender, _candidateName, voteCount[_candidateName]);
    }

    // 4. 检查候选人收到的总票数
    function getVoteCount(string memory _candidateName) public view candidateExists(_candidateName) returns (uint256) {
        return voteCount[_candidateName];
    }

    // 5. 查询我为谁投了票
    function getMyVote() public view returns (string memory) {
        string memory myVote = voteFor[msg.sender];
        require(bytes(myVote).length > 0, "You haven't voted yet");
        return myVote;
    }

    // 6. 查询指定地址为谁投了票
    function getVoteFor(address _voter) public view returns (string memory) {
        string memory vote = voteFor[_voter];
        require(bytes(vote).length > 0, "This address hasn't voted yet");
        return vote;
    }

    // 7. 获取所有候选人及其票数
    function getAllCandidatesWithVotes() public view returns (string[] memory, uint256[] memory) {

        uint256 count = candidateNames.length;
        string[] memory names = new string[](count);
        uint256[] memory votes = new uint256[](count);

        for(uint i = 0; i < count; i++) {
            names[i] = candidateNames[i];
            votes[i] = voteCount[candidateNames[i]];
        }

        return (names, votes);
    }

    // 8. 获取候选人总数
    function getCandidateCount() public view returns (uint256) {
        return candidateNames.length;
    }

    // 9. 检查候选人是否存在（内部函数）
    function _candidateExists(string memory _candidateName) internal view returns (bool) {
        for(uint i = 0; i < candidateNames.length; i++) {
            if (keccak256(bytes(candidateNames[i])) == keccak256(bytes(_candidateName))) {
                return true;
            }
        }
        return false;
    }

    // 10. 公共的候选人存在性检查
    function checkCandidateExists(string memory _candidateName) public view returns (bool) {
        return _candidateExists(_candidateName);
    }
}
