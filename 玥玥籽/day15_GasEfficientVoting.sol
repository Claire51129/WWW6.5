// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {

    uint8 public proposalCount;
    uint16 public minVotesRequired;

    struct Proposal {
        bytes32 name;
        uint32 voteCount;
        uint32 startTime;
        uint32 endTime;
        bool executed;
    }

    mapping(uint8 => Proposal) public proposals;

    mapping(address => uint256) private _voterBitmap;

    event ProposalCreated(uint8 indexed proposalId, bytes32 name, uint32 endTime);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId, uint32 voteCount);

    constructor(uint16 _minVotesRequired) {
        minVotesRequired = _minVotesRequired;
    }

    function createProposal(bytes32 _name, uint32 _durationSeconds) external {
        require(_durationSeconds > 0, "Duration must be positive");
        require(proposalCount < 255, "Max 255 proposals");

        uint8 id = proposalCount;
        proposalCount++;

        uint32 start = uint32(block.timestamp);
        uint32 end = start + _durationSeconds;

        proposals[id] = Proposal({
            name: _name,
            voteCount: 0,
            startTime: start,
            endTime: end,
            executed: false
        });

        emit ProposalCreated(id, _name, end);
    }

    function vote(uint8 _proposalId) external {
        require(_proposalId < proposalCount, "Proposal does not exist");

        uint32 ts = uint32(block.timestamp);
        require(ts >= proposals[_proposalId].startTime, "Voting not started yet");
        require(ts <= proposals[_proposalId].endTime, "Voting period has ended");

        uint256 bitmap = _voterBitmap[msg.sender];
        uint256 mask = 1 << _proposalId;
        require(bitmap & mask == 0, "Already voted on this proposal");

        _voterBitmap[msg.sender] = bitmap | mask;
        proposals[_proposalId].voteCount++;

        emit Voted(msg.sender, _proposalId);
    }

    function executeProposal(uint8 _proposalId) external {
        require(_proposalId < proposalCount, "Proposal does not exist");
        require(block.timestamp > proposals[_proposalId].endTime, "Voting still active");
        require(!proposals[_proposalId].executed, "Already executed");
        require(proposals[_proposalId].voteCount >= minVotesRequired, "Not enough votes");

        proposals[_proposalId].executed = true;
        emit ProposalExecuted(_proposalId, proposals[_proposalId].voteCount);
    }

    function hasVoted(address _voter, uint8 _proposalId) external view returns (bool) {
        return (_voterBitmap[_voter] & (1 << _proposalId)) != 0;
    }

    function getProposal(uint8 _proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool isActive
    ) {
        require(_proposalId < proposalCount, "Proposal does not exist");
        Proposal storage p = proposals[_proposalId];
        return (
            p.name,
            p.voteCount,
            p.startTime,
            p.endTime,
            p.executed,
            block.timestamp >= p.startTime && block.timestamp <= p.endTime
        );
    }
}
