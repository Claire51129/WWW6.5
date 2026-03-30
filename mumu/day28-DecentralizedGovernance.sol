// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DecentralizedGovernance is ReentrancyGuard {
    // 治理代币
    IERC20 public governanceToken; 

    struct Proposal {
        address proposer; // 提案人地址
        string description;
        uint256 forVotes; // 赞同票数
        uint256 againstVotes;  // 反对票数
        uint256 startTime;
        uint256 endTime;
        bool executed;  // 是否执行
        bool canceled;  // 提案被取消
        uint256 timelockEnd; // 提案锁定期
    }

    // map[proposalId] 2 提案
    mapping(uint256 => Proposal) public proposals;
    // map[proposalId][userAddress] -> isVoted
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // 下一个提案id
    uint256 public nextProposalId;
    // 投票时长
    uint256 public votingDuration;
    // 锁定时长
    uint256 public timelockDuration;
    // 管理者
    address public admin;
    // 法定人数百分比
    uint256 public quorumPercentage;
    // 提案押金金额
    uint256 public proposalDepositAmount;

    // 创建提案事件
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description);
    // 投票事件
    event Voted(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);
    // 执行提案事件
    event ProposalExecuted(uint256 indexed proposalId);
    // 未到达法定人数
    event QuorumNotMet(uint256 indexed proposalId);
    // 锁定提案事件
    event ProposalTimelockStarted(uint256 indexed proposalId);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor(
        address _governanceToken, // 治理代币合约地址
        uint256 _votingDuration,
        uint256 _timelockDuration,
        uint256 _quorumPercentage,
        uint256 _proposalDepositAmount
    ) {
        require(_governanceToken != address(0), "Invalid token");
        require(_votingDuration > 0, "Invalid duration");
        require(_quorumPercentage > 0 && _quorumPercentage <= 100, "Invalid quorum");

        governanceToken = IERC20(_governanceToken);
        votingDuration = _votingDuration;
        timelockDuration = _timelockDuration;
        admin = msg.sender;
        quorumPercentage = _quorumPercentage;
        proposalDepositAmount = _proposalDepositAmount;
    }

    // 创建提案
    function createProposal(string memory description) external returns (uint256) {
        require(bytes(description).length > 0, "Empty description");

        // 收取提案押金
        if (proposalDepositAmount > 0) {
            governanceToken.transferFrom(msg.sender, address(this), proposalDepositAmount);
        }

        uint256 proposalId = nextProposalId++;

        proposals[proposalId] = Proposal({
            proposer: msg.sender,
            description: description,
            forVotes: 0,
            againstVotes: 0,
            startTime: block.timestamp,
            endTime: block.timestamp + votingDuration,
            executed: false,
            canceled: false,
            timelockEnd: 0
        });

        emit ProposalCreated(proposalId, msg.sender, description);
        return proposalId;
    }

    // 投票
    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];

        require(block.timestamp >= proposal.startTime, "Not started");
        require(block.timestamp <= proposal.endTime, "Ended");
        require(!proposal.executed, "Already executed");
        require(!proposal.canceled, "Canceled");
        require(!hasVoted[proposalId][msg.sender], "Already voted");

        // 获取投票者的治理代币数量
        uint256 weight = governanceToken.balanceOf(msg.sender);
        require(weight > 0, "No voting power");

        hasVoted[proposalId][msg.sender] = true;

        if (support) {
            proposal.forVotes += weight;
        } else {
            proposal.againstVotes += weight;
        }

        emit Voted(proposalId, msg.sender, support, weight);
    }

    // 完成提案（进入时间锁或取消）
    function finalizeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];

        require(block.timestamp > proposal.endTime, "Voting not ended");
        require(!proposal.executed, "Already executed");
        require(!proposal.canceled, "Canceled");

        uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
        uint256 totalSupply = governanceToken.totalSupply();
        uint256 quorumRequired = (totalSupply * quorumPercentage) / 100;

        if (totalVotes >= quorumRequired && proposal.forVotes > proposal.againstVotes) {
            if (timelockDuration > 0) {
                proposal.timelockEnd = block.timestamp + timelockDuration;
                emit ProposalTimelockStarted(proposalId);
            } else {
                proposal.executed = true;
                _refundDeposit(proposalId);
                emit ProposalExecuted(proposalId);
            }
        } else {
            // 取消提案
            proposal.canceled = true;
            emit QuorumNotMet(proposalId);
        }
    }

    // 执行提案
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];

        require(proposal.timelockEnd > 0, "No timelock set");
        require(block.timestamp >= proposal.timelockEnd, "Timelock not ended");
        require(!proposal.executed, "Already executed");
        require(!proposal.canceled, "Canceled");

        proposal.executed = true;
        _refundDeposit(proposalId);

        emit ProposalExecuted(proposalId);
    }

    // 退还押金
    function _refundDeposit(uint256 proposalId) internal {
        if (proposalDepositAmount > 0) {
            Proposal storage proposal = proposals[proposalId];
            (bool success, ) = address(governanceToken).call(
                abi.encodeWithSelector(IERC20.transfer.selector, proposal.proposer, proposalDepositAmount)
            );
            require(success, "Transfer failed");
        }
    }

    // 获取提案结果
    function getProposalResult(uint256 proposalId) external view returns (
        bool passed,
        uint256 forVotes,
        uint256 againstVotes,
        bool executed
    ) {
        Proposal memory proposal = proposals[proposalId];
        passed = proposal.forVotes > proposal.againstVotes;
        return (passed, proposal.forVotes, proposal.againstVotes, proposal.executed);
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

/**

DAO: decentralized autonomous organization（去中心化自治组织）
- 是一种通过智能合约运行、由社区成员共同治理，也是就是拥有治理代币的成员进行投票决定
- 治理代币：governanceToken

主要流程：
    创建提案 -> 投票期 -> 计票 -> 时间锁 -> 执行

创建提案：需要收取提案押金。提案结束后再返还
--当提案被取消时：在这种情况下，押金  不予退还——它保留在合同中，作为对失败想法的惩罚。

加权投票机制：
    基于代币持有量的加权投票，以确保利益相关者的话语权
- 持币投票：代币数量=投票权重
- 投票需要去重
- 实时权重：基于当前的余额
- 所有投票公开可查

法定人数机制：
（1）总投票数 >= 法定人数
（2）赞成票 > 反对票

时间锁保护
（1）缓冲期：给社区时间审查提案
（2）退出机会：不同意者可以退出
（3）安全保障：防止闪电攻击
（4）透明执行：执行时间可预期

 */