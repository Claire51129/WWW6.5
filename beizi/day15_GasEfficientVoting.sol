// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting{
    uint8 public proposalCount;//减少了读取和写入此变量的 Gas 使用量
    
    struct Proposal {
    bytes32 name;//固定大小，比 string 便宜
    uint32 voteCount;
    uint32 startTime;
    uint32 endTime;
    bool executed;
}

mapping(uint8 => Proposal) public proposals;//使用映射而不是数组来存储提案

 
mapping(address => uint256) private voterRegistry;//投票记录数据；之前是需要写清楚他是否投过某一个提案，改了之后只需要看0或者1就知道了不需要额外说明

 
mapping(uint8 => uint32) public  proposalVoterCount;//跟踪每个提案有多少投票者投了票

 
event ProposalCreated(uint8 indexed proposalId, bytes32 name);//有人提出提案时
event Voted(address indexed voter, uint8 indexed proposalId);//谁投了票，投给了哪一个提案
event ProposalExecuted(uint8 indexed proposalId);//提案完成

function createProposal(bytes32 name, uint32 duration) external{  //duration是持续时间（倒计时闹钟）；

require(duration > 0, "Duration must be > 0");

uint8 proposalId = proposalCount;
proposalCount++;//为这个提案生成一个唯一的 ID

//请按照 Proposal 的模板，在临时‘白板’（Memory）上填好一份新的提案数据，并把它暂时命名为 newProposal，Proposal 指Struct
Proposal memory newProposal = Proposal({
        name: name,
        voteCount: 0,
        startTime: uint32(block.timestamp),
        endTime: uint32(block.timestamp) + duration,
        executed: false
    });//将其一次性写入永久存储；填一张“新提案登记表”
proposals[proposalId] = newProposal;//把新创建的提案内容（newProposal）存入账本（proposals）中，并给它贴上这个新生成的编号（proposalId）作为标签

emit ProposalCreated(proposalId, name);
}

function vote(uint8 proposalId) external{
    
require(proposalId < proposalCount, "Invalid proposal");
uint32 currentTime = uint32(block.timestamp); 
require(currentTime >= proposals[proposalId].startTime, "Voting not started");
require(currentTime <= proposals[proposalId].endTime, "Voting ended");

//数字 1 就像是第一个开关被打开了，其他的开关都是关着的；<<：这个符号叫“左移操作符”。你可以把它想象成“向左跳”的指令；
//proposalId：这是提案的编号，它告诉数字 1 要向左跳几个格子；
uint256 voterData = voterRegistry[msg.sender];
uint256 mask = 1 << proposalId;
require((voterRegistry[msg.sender] & mask) == 0, "Already voted");//检查你投过票没

voterRegistry[msg.sender] = voterData | mask;//旧记录 (voterData)，或运算 (|)；把投票记录正式“写”入区块链的账簿里，完成更新。

proposals[proposalId].voteCount++;
proposalVoterCount[proposalId]++;

emit Voted(msg.sender, proposalId);
}
  //检查提案
function executeProposal(uint8 proposalId) external {
    require(proposalId < proposalCount, "Invalid proposal");
    require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
    require(!proposals[proposalId].executed, "Already executed");

    proposals[proposalId].executed = true;

    emit ProposalExecuted(proposalId);
}
//检查某个特定的用户是否已经为某个特定的提案投过票
  function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
    return (voterRegistry[voter] & (1 << proposalId)) != 0;
}

//提案详情查询窗口，它的作用是让外界（比如网页前端或钱包）能够一键获取某个提案的所有详细信息。
  
function getProposal(uint8 proposalId) external view returns (
    bytes32 name,
    uint32 voteCount,
    uint32 startTime,
    uint32 endTime,
    bool executed,
    bool active
) {
    require(proposalId < proposalCount, "Invalid proposal");

    Proposal storage proposal = proposals[proposalId];//从账本里面调取输入序号所对应的提案

    return (
        proposal.name,
        proposal.voteCount,
        proposal.startTime,
        proposal.endTime,
        proposal.executed,
        (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)//算了一下：“现在是不是在投票的时间范围内？
    );
}
}
