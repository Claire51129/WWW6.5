// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DecentralizedGovernance {
    // 1. 提案结构体：记录一个提案的生老病死
    struct Proposal {
        address proposer;     // 提议者
        string description;   // 内容
        uint256 forVotes;      // 赞成票数
        uint256 againstVotes;  // 反对票数
        uint256 endTime;       // 投票截止时间
        bool executed;         // 是否已执行
        bool canceled;         // 是否已取消
        uint256 timelockEnd;   // 时间锁到期时间
    }

    IERC20 public govToken;    // 治理代币
    uint256 public quorumPercent; // 法定人数百分比 (如 20)
    uint256 public timelock;      // 时间锁时长 (如 2天)
    uint256 public deposit;       // 提议押金
    
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted; // 防止重复投票
    uint256 public proposalCount;

    constructor(address _token, uint256 _quorum, uint256 _timelock, uint256 _deposit) {
        govToken = IERC20(_token);
        quorumPercent = _quorum;
        timelock = _timelock;
        deposit = _deposit;
    }

    // 创建提案
    function createProposal(string memory _desc) external returns (uint256) {
        // 收取押金 (CEI模式：交互在后)
        govToken.transferFrom(msg.sender, address(this), deposit);
        
        uint256 id = proposalCount++;
        proposals[id] = Proposal({
            proposer: msg.sender,
            description: _desc,
            forVotes: 0,
            againstVotes: 0,
            endTime: block.timestamp + 3 days, // 假设投票期为3天
            executed: false,
            canceled: false,
            timelockEnd: 0
        });
        return id;
    }

    // 投票逻辑
    function vote(uint256 id, bool support) external {
        Proposal storage p = proposals[id];
        require(block.timestamp < p.endTime, "Voting ended");
        require(!hasVoted[id][msg.sender], "Already voted");

        uint256 weight = govToken.balanceOf(msg.sender); // 权重 = 持币量
        require(weight > 0, "No voting power");

        hasVoted[id][msg.sender] = true;
        if (support) p.forVotes += weight;
        else p.againstVotes += weight;
    }

    // 统计并进入时间锁
    function queueProposal(uint256 id) external {
        Proposal storage p = proposals[id];
        require(block.timestamp >= p.endTime, "Voting still active");
        
        uint256 totalVotes = p.forVotes + p.againstVotes;
        uint256 supply = govToken.totalSupply();
        
        // 检查法定人数和胜负
        if (totalVotes >= (supply * quorumPercent) / 100 && p.forVotes > p.againstVotes) {
            p.timelockEnd = block.timestamp + timelock; // 开启冷却期
        } else {
            p.canceled = true; // 失败
        }
    }
}
