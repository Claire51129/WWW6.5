// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";


contract DecentralizedGovernance is ReentrancyGuard {
    using SafeCast for uint256; //只要我有 uint256，让我自动访问 SafeCast 功能
    //IERC20 public governanceToken;
    struct Proposal {
    uint256 id; //用于跟踪的唯一 ID 号
    string description;
    uint256 deadline;
    uint256 votesFor; //有多少票投了赞成票
    uint256 votesAgainst; //有多少票投了反对票
    bool executed; //一个布尔值（true/false），用于跟踪提案是否已执行
    address proposer;
    bytes[] executionData; //如果提案通过，将在其他合约上调用的实际数据有效负载
    address[] executionTargets; //这些有效负载发送到的合约地址列表
    uint256 executionTime;
    }
    mapping(uint256 => Proposal) public proposals; //每个 Proposal 结构都通过其唯一 ID 存储和访问
    mapping(uint256 => mapping(address => bool)) public hasVoted; //第一个键是 proposalId,第二个关键是选民的地址voter's address,跟踪特定用户是否已经对特定提案进行了投票

    IERC20 public governanceToken; //governanceToken 是代表投票权的 ERC-20 代币 你拥有的代币越多 ，您的投票权重就越强这个代币可以是任何东西——它可以是自定义 DAO 代币、包装质押代币，甚至是真实 DAO 中的 UNI（Uniswap）或 COMP（Compound）之类的东西
    uint256 public nextProposalId; //跟踪当有人创建新提案时将分配的下一个 ID from 0 ++
    uint256 public votingDuration; //以秒为单位
    uint256 public timelockDuration; //提案获胜后实际执行之前的等待期
    address public admin; //存储了管理员地址 ——部署合约的钱包
    uint256 public quorumPercentage = 5; //了提案必须参与的总票数的最小百分比才能有效
    uint256 public proposalDepositAmount = 10; //用户在创建提案时必须锁定多少个治理令牌governance tokens 充当垃圾邮件过滤器spam filter 押金 
    event ProposalCreated(uint256 id, string description, address proposer, uint256 depositAmount); // 提案创建
    event Voted(uint256 proposalId, address voter, bool support, uint256 weight); //投票Voted //使用了多少投票权 （代币权重）
    event ProposalExecuted(uint256 id, bool passed);//提案已执行
    event QuorumNotMet(uint256 id, uint256 votesTotal, uint256 quorumNeeded); //法定人数未满足
    event ProposalDepositPaid(address proposer, uint256 amount); //提案定金已付
    event ProposalDepositRefunded(address proposer, uint256 amount); //提案定金已退还
    event TimelockSet(uint256 duration); //时间锁 管理员更改时间锁持续时间-此事件宣布新的时间锁时间 
    event ProposalTimelockStarted(uint256 proposalId, uint256 executionTime); //哪个提案正在进入时间锁 公示,何时有资格执行

    modifier onlyAdmin() {
    require(msg.sender == admin, "Only admin can call this");
    _;
    }

    constructor(address _governanceToken, uint256 _votingDuration, uint256 _timelockDuration) {
    governanceToken = IERC20(_governanceToken); //治理投票的 ERC-20 代币的地址 锁定了哪个代币实现控制了 DAO
    votingDuration = _votingDuration; //每个提案将保持开放投票的秒数
    timelockDuration = _timelockDuration; //强制等待时间
    admin = msg.sender;
    emit TimelockSet(_timelockDuration);
    }
    //更新仲裁百分比允许管理员更改仲裁百分比
    function setQuorumPercentage(uint256 _quorumPercentage) external onlyAdmin {
    require(_quorumPercentage <= 100, "Quorum percentage must be between 0 and 100");
    quorumPercentage = _quorumPercentage;
    }
    //更新提案存款金额 允许管理员更改用户必须存入的代币数量才能创建提案
    function setProposalDepositAmount(uint256 _proposalDepositAmount) external onlyAdmin {
    proposalDepositAmount = _proposalDepositAmount;
    }
    //更新时间锁持续时间提案通过和执行之间的等待期
    function setTimelockDuration(uint256 _timelockDuration) external onlyAdmin {
    timelockDuration = _timelockDuration;
    emit TimelockSet(_timelockDuration);
    }

    function createProposal(
    string calldata _description, //描述提案内容的简短文本
    address[] calldata _targets, //该提案将与之交互的合约地址（如果通过）
    bytes[] calldata _calldatas //将发送到每个目标的实际函数调用数据（例如打包成字节的函数调用）
    ) external returns (uint256) {
    require(governanceToken.balanceOf(msg.sender) >= proposalDepositAmount, "Insufficient tokens for deposit");
    require(_targets.length == _calldatas.length, "Targets and calldatas length mismatch"); //确保目标和调用数据匹配 确保列表的长度相同

    governanceToken.transferFrom(msg.sender, address(this), proposalDepositAmount); //收取提案押金
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

    nextProposalId++; //更新提案计数器
    return nextProposalId - 1; // current proposal ID
    }

    function vote(uint256 proposalId, bool support) external {
    Proposal storage proposal = proposals[proposalId]; //加载提案
    require(block.timestamp < proposal.deadline, "Voting period over"); //确保投票仍然开放
    require(governanceToken.balanceOf(msg.sender) > 0, "No governance tokens"); //确保用户持有治理代币
    require(!hasVoted[proposalId][msg.sender], "Already voted"); //防止重复投票

    uint256 weight = governanceToken.balanceOf(msg.sender); //计算投票权

    if (support) { //用户是支持还是反对该提案
        proposal.votesFor += weight;
    } else {
        proposal.votesAgainst += weight;
    }

    hasVoted[proposalId][msg.sender] = true; //将用户标记为已投票

    emit Voted(proposalId, msg.sender, support, weight);
    }
    //敲定提案

    function finalizeProposal(uint256 proposalId) external {
    Proposal storage proposal = proposals[proposalId]; ////加载提案
    require(block.timestamp >= proposal.deadline, "Voting period not yet over"); //确保投票结束
    require(!proposal.executed, "Proposal already executed"); //确保尚未最终确定
    require(proposal.executionTime == 0, "Execution time already set"); //确保它尚未进入时间锁

    uint256 totalSupply = governanceToken.totalSupply(); //总共有多少个代币 （totalSupply
    uint256 totalVotes = proposal.votesFor + proposal.votesAgainst; //投了多少票 （totalVotes）
    uint256 quorumNeeded = (totalSupply * quorumPercentage) / 100; //需要多少票数（法定人数）
    //如果提案获得通过并达到法定人数->进入时间锁定期 
    if (totalVotes >= quorumNeeded && proposal.votesFor > proposal.votesAgainst) {
        proposal.executionTime = block.timestamp + timelockDuration; //executionTime 设置为 now + timelockDuration
        emit ProposalTimelockStarted(proposalId, proposal.executionTime);
        } else {
        //如果提案失败立即将其标记为已执行 （不会发生next action
        proposal.executed = true;
        emit ProposalExecuted(proposalId, false);
        if (totalVotes < quorumNeeded) {
            emit QuorumNotMet(proposalId, totalVotes, quorumNeeded); //发出一个额外的事件 QuorumNotMet 来解释它失败的确切原因
        }
        // Deposit is NOT refunded here for failed proposals.
        }
    }

    function executeProposal(uint256 proposalId) external nonReentrant {
    Proposal storage proposal = proposals[proposalId]; //加载提案
    require(!proposal.executed, "Proposal already executed");
    require(proposal.executionTime > 0 && block.timestamp >= proposal.executionTime, "Timelock not yet expired"); //确保时间锁结束 必须设置时间锁执行时间（意味着提案通过投票） && 当前时间必须在执行时间之后

    proposal.executed = true; // set executed early to prevent reentrancy 在执行任何其他作之前将提案标记为已执行

    bool passed = proposal.votesFor > proposal.votesAgainst; //检查提案是否实际通过

    if (passed) {
        //循环遍历所有目标合约
        for (uint256 i = 0; i < proposal.executionTargets.length; i++) {
            (bool success, bytes memory returnData) = proposal.executionTargets[i].call(proposal.executionData[i]);
            require(success, string(returnData));
            //任何调用失败 ，则整个执行将恢复 
        }
        emit ProposalExecuted(proposalId, true); //发出一个事件 ，将提案标记为已通过并已执行
        governanceToken.transfer(proposal.proposer, proposalDepositAmount); //退还提议者的代币押金（
        emit ProposalDepositRefunded(proposal.proposer, proposalDepositAmount);
    } else {
        emit ProposalExecuted(proposalId, false);
        // Deposit is NOT refunded here for failed proposals; it was not refunded in finalizeProposal either.
    }
    }
    //检查提案结果

    function getProposalResult(uint256 proposalId) external view returns (string memory) {
    Proposal storage proposal = proposals[proposalId]; //加载提案
    require(proposal.executed, "Proposal not yet executed"); //确保它已经执行

    uint256 totalSupply = governanceToken.totalSupply(); //计算所需的总票数和法定人数
    uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
    uint256 quorumNeeded = (totalSupply * quorumPercentage) / 100;

    if (totalVotes < quorumNeeded) {
        return "Proposal FAILED - Quorum not met";
    } else if (proposal.votesFor > proposal.votesAgainst) {
        return "Proposal PASSED";
    } else {
        return "Proposal REJECTED"; //如果被拒绝
    }
    }
    function getProposalDetails(uint256 proposalId) external view returns (Proposal memory) {
    return proposals[proposalId]; //允许任何人查找有关特定提案的完整信息
    }
    //委托投票允许代币持有者将投票权委托给专业的治理参与者
    mapping(address => address) public delegates;
    event DelegateChanged(address indexed delegator, address indexed delegatee);
    function delegate(address delegatee) external {
    delegates[msg.sender] = delegatee;
    emit DelegateChanged(msg.sender, delegatee);
    }
    function getVotingPower(address voter) public view returns (uint256) {
    uint256 power = governanceToken.balanceOf(voter);

    // 加上委托给该地址的投票权
    // 这里需要遍历或使用更复杂的数据结构
    return power;
    }

}