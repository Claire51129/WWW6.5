// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DecentralizedGovernance is ReentrancyGuard {
    using SafeCast for uint256;

struct Proposal {
    uint256 id;//提案ID
    string description;
    uint256 deadline;//投票结束时的时间戳标记
    uint256 votesFor;
    uint256 votesAgainst;
    bool executed;//跟踪提案是否已执行
    address proposer;//创建提案的人的地址
    bytes[] executionData;//如果提案通过，将在其他合约上调用的实际数据有效负载
    address[] executionTargets;//这些有效负载应发送到的合约地址列表
    uint256 executionTime;//时间锁后提案可以正式执行的未来时间戳
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;//跟踪特定用户是否已经对特定提案进行了投票

    IERC20 public governanceToken;//代表投票权的 ERC-20 代币
    uint256 public nextProposalId;//当有人创建新提案时将分配的下一个 ID
    uint256 public votingDuration;//每个提案开放投票的时间 
    uint256 public timelockDuration;//提案获胜后实际执行之前的等待期
    address public admin;
    uint256 public quorumPercentage = 5;//提案必须参与的总票数的最小百分比才能有效
    uint256 public proposalDepositAmount = 10;//押金，用户在创建提案时必须锁定多少个治理令牌governance tokens

    event ProposalCreated(uint256 id, string description, address proposer, uint256 depositAmount);
    event Voted(uint256 proposalId, address voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 id, bool passed);
    event QuorumNotMet(uint256 id, uint256 votesTotal, uint256 quorumNeeded);
    event ProposalDepositPaid(address proposer, uint256 amount);
    event ProposalDepositRefunded(address proposer, uint256 amount);//提案定金已退还
    event TimelockSet(uint256 duration);
    event ProposalTimelockStarted(uint256 proposalId, uint256 executionTime);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor(
        address _governanceToken,
        uint256 _votingDuration,
        uint256 _timelockDuration,
        uint256 _quorumPercentage,
        uint256 _proposalDepositAmount
    ) {
        require(_governanceToken != address(0), "Invalid token");
        require(_votingDuration > 0, "Invalid duration");
        require(_quorumPercentage > 0 && _quorumPercentage <= 100, "Invalid quorum");

        governanceToken = IERC20(_governanceToken);//哪个代币控制了 DAO
        votingDuration = _votingDuration;
        timelockDuration = _timelockDuration;
        admin = msg.sender;
        quorumPercentage = _quorumPercentage;
        proposalDepositAmount = _proposalDepositAmount;
    }

    // 创建提案
    function createProposal(
    string calldata _description,
    address[] calldata _targets,// 该提案将与之交互的合约地址（如果通过）
    bytes[] calldata _calldatas// 将发送到每个目标的实际函数调用数据
    ) external returns (uint256) {
    //检查用户是否有足够的令牌
    require(governanceToken.balanceOf(msg.sender) >= proposalDepositAmount, "Insufficient tokens for deposit");
    //每个目标合约必须有一个相应的函数调用 （calldata）
    require(_targets.length == _calldatas.length, "Targets and calldatas length mismatch");
    //收取提案押金
    governanceToken.transferFrom(msg.sender, address(this), proposalDepositAmount);
    emit ProposalDepositPaid(msg.sender, proposalDepositAmount);
    //保存新提案
    proposals[nextProposalId] = Proposal({
        id: nextProposalId,
        description: _description,
        deadline: block.timestamp + votingDuration,
        votesFor: 0,
        votesAgainst: 0,
        executed: false,
        proposer: msg.sender,
        executionData: _calldatas,
        executionTargets: _targets,
        executionTime: 0
    });

    emit ProposalCreated(nextProposalId, _description, msg.sender, proposalDepositAmount);

    nextProposalId++;
    return nextProposalId - 1;
    }

    // 投票
    function vote(uint256 proposalId, bool support) external {
    Proposal storage proposal = proposals[proposalId];
    require(block.timestamp < proposal.deadline, "Voting period over");
    //确保用户持有治理代币
    require(governanceToken.balanceOf(msg.sender) > 0, "No governance tokens");
    //防止重复投票
    require(!hasVoted[proposalId][msg.sender], "Already voted");
    //计算投票权重
    uint256 weight = governanceToken.balanceOf(msg.sender);

    if (support) {
        proposal.votesFor += weight;
    } else {
        proposal.votesAgainst += weight;
    }

    hasVoted[proposalId][msg.sender] = true;

    emit Voted(proposalId, msg.sender, support, weight);
    }

    // 完成提案（进入时间锁或取消）
    function finalizeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.deadline, "Voting period not yet over");
        require(!proposal.executed, "Proposal already executed");//避免双重执行
        require(proposal.executionTime == 0, "Execution time already set");

        uint256 totalSupply = governanceToken.totalSupply();//总共有多少个代币 
        uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
        uint256 quorumNeeded = (totalSupply * quorumPercentage) / 100;//需要多少票数（法定人数）

        if (totalVotes >= quorumNeeded && proposal.votesFor > proposal.votesAgainst) {
            proposal.executionTime = block.timestamp + timelockDuration;//提案进入时间锁定期 
            emit ProposalTimelockStarted(proposalId, proposal.executionTime);
        } else {
            proposal.executed = true;//如果提案失败，将其标记为已执行 
            emit ProposalExecuted(proposalId, false);
            if (totalVotes < quorumNeeded) {
                emit QuorumNotMet(proposalId, totalVotes, quorumNeeded);
            }
            // Deposit is NOT refunded here for failed proposals.
        }
    }

    // 执行提案
    function executeProposal(uint256 proposalId) external nonReentrant {
    Proposal storage proposal = proposals[proposalId];
    require(!proposal.executed, "Proposal already executed");//确保它尚未执行
    require(proposal.executionTime > 0 && block.timestamp >= proposal.executionTime, "Timelock not yet expired");

    proposal.executed = true; // set executed early to prevent reentrancy

    bool passed = proposal.votesFor > proposal.votesAgainst;//检查提案是否实际通过

    if (passed) {
        for (uint256 i = 0; i < proposal.executionTargets.length; i++) {
            //循环遍历所有目标合约，使用存储的 calldata 在每个目标上调用相应的函数
            (bool success, bytes memory returnData) = proposal.executionTargets[i].call(proposal.executionData[i]);
            require(success, string(returnData));
        }
        emit ProposalExecuted(proposalId, true);
        governanceToken.transfer(proposal.proposer, proposalDepositAmount);
        emit ProposalDepositRefunded(proposal.proposer, proposalDepositAmount);
    } else {
        emit ProposalExecuted(proposalId, false);
        // Deposit is NOT refunded here for failed proposals; it was not refunded in finalizeProposal either.
    }
    }

    // 退还押金
    function _refundDeposit(uint256 proposalId) internal {
        if (proposalDepositAmount > 0) {
            Proposal storage proposal = proposals[proposalId];
            governanceToken.transfer(proposal.proposer, proposalDepositAmount);
        }
    }

    // 获取提案结果
    function getProposalResult(uint256 proposalId) external view returns (string memory) {
    Proposal storage proposal = proposals[proposalId];
    require(proposal.executed, "Proposal not yet executed");

    uint256 totalSupply = governanceToken.totalSupply();
    uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
    uint256 quorumNeeded = (totalSupply * quorumPercentage) / 100;

    if (totalVotes < quorumNeeded) {
        return "Proposal FAILED - Quorum not met";
    } else if (proposal.votesFor > proposal.votesAgainst) {
        return "Proposal PASSED";
    } else {
        return "Proposal REJECTED";
    }
    }

    function getProposalDetails(uint256 proposalId) external view returns (Proposal memory) {
    return proposals[proposalId];
    }

    // 管理员设置参数
    function setQuorumPercentage(uint256 _newQuorum) external onlyAdmin {
        require(_newQuorum > 0 && _newQuorum <= 100, "Invalid quorum");
        quorumPercentage = _newQuorum;
    }

    function setProposalDepositAmount(uint256 _newAmount) external onlyAdmin {
        proposalDepositAmount = _newAmount;
    }
}
