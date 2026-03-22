//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract GasEfficientVote{
    //use uint8 for small number instead of uint256, uint8 can indicate 0~255, because it's a 8-bit binary number.
    uint8 public proposalCount;

    //use bytes32 for name instead of string
    struct Proposal{
        bytes32 name;
        uint32 voteCount;
        uint32 startTime;
        uint32 endTime;
        bool executed;
    }

    //using a mapping istead of a struct array proposal[] to code the proposals
    mapping(uint8 => Proposal) proposals;
    //Don't use nested mapping such as mapping(address => maping(uint8 => bool)).
    //we use a 256-long binary number to express the situation of vote record
    mapping(address => uint256) VoterRegistery;
    
    //count the votes of each proposal
    mapping(uint8 => uint32) proposalVoteCount;

    //events
    event ProposalCreated(uint8 indexed proposalID, bytes32 name);
    event Vote(address indexed voter, uint8 indexed proposalID);
    event ProposalExcuted(uint8 indexed proposalID);

    //Core function
    function proposalCreate(bytes32 _name, uint32 _duration) external{
        require(_duration > 0, "Duration must be greater than 0");

        //get the number of this proposal
        uint8 proposalID = proposalCount;
        proposalCount++;

        //use memory instead of storage
        Proposal memory newProposal = Proposal ({
            name:_name,
            voteCount:0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) +_duration,
            executed:false
        });

        proposals[proposalID] = newProposal;
        emit ProposalCreated(proposalID, _name);
    }

    function vote(uint8 _proposalID) external{
        require(_proposalID < proposalCount, "Invalide proposal ID");
        //check the time 
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime > proposals[_proposalID].startTime, "Too early");
        require(currentTime < proposals[_proposalID].endTime, "Too late");

        uint256 voterData = VoterRegistery[msg.sender];
        uint256 mask = (1 <<_proposalID); // 1 <<_proposalID means turn proposalID into binary
        require((voterData&mask)==0,"Already Voted"); //Bitwise AND operation
        VoterRegistery[msg.sender] = voterData | mask;

        proposals[_proposalID].voteCount++;
        proposalVoteCount[_proposalID] ++;

        emit Vote(msg.sender, _proposalID);
    }

    function excuteProposal(uint8 _proposalID) external{
        require(_proposalID < proposalCount, "Invalide proposal ID");
        uint32 currentTime = uint32(block.timestamp);
        require(currentTime > proposals[_proposalID].endTime, "Vote does't end");
        require(!proposals[_proposalID].executed, "Already executed");
        proposals[_proposalID].executed = true;
        emit ProposalExcuted(_proposalID);
    }

    //view function
    function getVotes(uint8 _proposalID)external view returns(uint32){
        require(_proposalID < proposalCount, "Invalide proposal ID");
        return proposalVoteCount[_proposalID];
    }

    function hasVoted(address _voter, uint8 _proposalID) external view returns(bool){
        return (VoterRegistery[_voter] & (1 <<_proposalID)) !=0;
    }

    function getProposals(uint8 _proposalID)external view returns(
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active
    ){
        require(_proposalID < proposalCount, "Invalide proposal ID");
        Proposal storage proposal = proposals[_proposalID];
        return (
            proposal.name,
            proposal.voteCount,
            proposal.startTime,
            proposal.endTime,
            proposal.executed,
             (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)

        );

    }
}