//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract GasEfficientVoting{ //高效省gas合约！

    uint8 public proposalCount;
    struct Proposal{  //先整个结构体，下面的几个类型的变量加一起只占一个槽位（柜子），要是用uint256，一个变量就得一个槽位了
        bytes32 name;  
        uint32 voteCount;
        uint32 startTime;
        uint32 endTime;
        bool executed;
    }

    mapping(uint8 => Proposal) public proposals;
    mapping(address => uint256)private voterRegistry;
    mapping(uint8 =>uint32)public proposalVoterCount;

    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);

    function createProposal(bytes32 _name, uint32 duration) external{
        require(duration > 0, "Durations should be more than 0");
        uint8 proposalId = proposalCount;
        proposalCount++;
        Proposal memory newProposal = Proposal({ //先存在memory里再通过push存进永久变量，省省省！
            name: _name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });
        proposals[proposalId] = newProposal;
        emit ProposalCreated(proposalId, _name);
    }

    function vote(uint8 proposalId) external{
        require(proposalId < proposalCount, "Invalid Proposal");
        uint32 currentTime = uint32(block.timestamp); //调用block.timestamp全局变量也废gas，需要多次用它的话，可以赋值给currentTime，这样就只用调用一次，省gas
        require(currentTime >= proposals[proposalId].startTime, "Voting has not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting has ended");

        //这个地方非常精妙！通过位运算，将对所有提案的投票情况放进了一个槽位中，多快好省，得知道很多东西还能串联起来才会想到这个办法呀
        uint256 voterData = voterRegistry[msg.sender];
        uint256 mask = 1 << proposalId; //proposalId转为二进制编码，存进mask，方便接下来进行位运算
        require((voterRegistry[msg.sender] & mask) == 0, "Already voted");
        voterRegistry[msg.sender] = voterData | mask; //位运算OR记录投票
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;

        emit Voted(msg.sender, proposalId);

    }

    function executeProposal(uint8 proposalId) external{
        require(proposalId < proposalCount, "Invalid Proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended ");
        require(!proposals[proposalId].executed, "Already executed");
        proposals[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }

    function hasVoted(address voter, uint8 proposalId)external view returns(bool){
        return(voterRegistry[voter] & (1 << proposalId) != 0);
    }

      
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active
        ) 
   {
    require(proposalId < proposalCount, "Invalid proposal");

    Proposal storage proposal = proposals[proposalId];
    return(
        proposal.name,
        proposal.voteCount,
        proposal.startTime,
        proposal.endTime,
        proposal.executed,
        (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)
    );

    }
}