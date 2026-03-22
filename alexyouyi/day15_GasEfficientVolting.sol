//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVolting{
    uint8 public proposalCount;
    struct Proposal{
        bytes32 name;
        uint32 voteCount;
        uint32 startTime;
        uint32 endTime;
        bool executed;
    }
    mapping(uint8 => Proposal) public proposals;
    mapping(address => uint256) private voteRegistry;
    mapping(uint8 => uint32) public proposalVoterCount;

    event ProposalCreated(uint8 indexed proposalID, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalID);
    event ProposalExecuted(uint8 indexed proposalID);

    function createProposal(bytes32 _name, uint32 _duration) external {
        require(_duration > 0, "Duration must be greater than zero");
        proposalCount++;
        Proposal memory newProposal = Proposal({
            name: _name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + _duration,
            executed: false
        });
        proposals[proposalCount] = newProposal;
        emit ProposalCreated(proposalCount, _name);
    }

    function vote(uint8 _proposalID) external {
        require( _proposalID < proposalCount, "Invalid proposal ID");
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[_proposalID].startTime, "Voting has not started");
        require(currentTime <= proposals[_proposalID].endTime, "Voting has ended");
       
        uint256 voterData = voteRegistry[msg.sender];
        uint256 mask = 1<<_proposalID;
        require(voteRegistry[msg.sender] & mask == 0, "Already voted for this proposal");
        voteRegistry[msg.sender] = voterData | mask;
        proposals[_proposalID].voteCount++;
        proposalVoterCount[_proposalID]++;
    }

    function executeProposal(uint8 _proposalID) external {
        require(_proposalID < proposalCount, "Invalid proposal ID");
        require(block.timestamp > proposals[_proposalID].endTime, "Voting is still active");
        require(!proposals[_proposalID].executed, "Proposal already executed");

        proposals[_proposalID].executed = true;
        emit ProposalExecuted(_proposalID);
    }

    function hasVoted(address _voter, uint8 _proposalID) external view returns (bool) {
        return (voteRegistry[_voter] & (1 << _proposalID) != 0);
    }

    function getProposal(uint8 _proposalID) external view returns (
        bytes32 name, 
        uint32 voteCount, 
        uint32 startTime, 
        uint32 endTime, 
        bool executed,
        bool active
        ) {
            require(_proposalID < proposalCount, "Invalid proposal");
            Proposal memory proposal = proposals[_proposalID];
            return (
                proposal.name,
                proposal.voteCount,
                proposal.startTime,
                proposal.endTime,
                proposal.executed,
                block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime
            );
        }
}