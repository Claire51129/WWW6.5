// 链上投票班级系统：1创建提案→2大家投票→3投票结束后结算→4如果通过→5执行提案
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";   //导入IER20接口(让合约知道ERC20代币一般都有哪些标准功能)
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";   //导入安全工具ReentrancyGuard

contract DecentralizedGovernance is ReentrancyGuard {   //去中心化治理系统合约继承了 ReentrancyGuard 的功能
    IERC20 public governanceToken;   //它代表一个 ERC20治理代币合约

    struct Proposal {   //打包好的资料盒子proposal
        address proposer;   //提案发起人的地址
        string description;    //提案描述
        uint256 forVotes;   //赞成票总数
        uint256 againstVotes;   //反对票总数
        uint256 startTime;    //投票开始时间
        uint256 endTime;    //结束时间
        bool executed;    //提案是不是已经执行了，true=已经执行；false=还没执行
        bool canceled;    //提案是不是已经取消了，true=已取消，false=没去夏普
        uint256 timelockEnd;    //时间锁结束时间。
    }   //如果提案通过了，但设置了时间锁，那么要等到这个时间到了，才能真正执行。

    mapping(uint256 => Proposal) public proposals;   //用一个映射 proposals 来保存所有提案；uint256 = 提案编号，Proposal = 这个编号对应的提案内容
    mapping(uint256 => mapping(address => bool)) public hasVoted;   //记录某个地址有没有给某个提案投过票；外层 key：proposalId，内层 key：address，结果是 true / false。这样可以防止一个人重复投票

    uint256 public nextProposalId;   //下一个提案要用的 ID(初始为0)
    uint256 public votingDuration;   //投票持续时长
    uint256 public timelockDuration;   //时间锁持续时长；提案通过后，要再等多久才能执行。
    address public admin;   //管理员地址(管理员可修改系统参数)
    uint256 public quorumPercentage;   //法定人数百分比
    uint256 public proposalDepositAmount;   //创建提案时要交的押金数量

    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description);   //定义一个事件：提案创建时发出通知
    event Voted(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);   //投票时发出的事件，记录：哪个提案、谁投票了、投赞成还是反对、票重是多少
    event ProposalExecuted(uint256 indexed proposalId);    //提案执行时发出的事件
    event QuorumNotMet(uint256 indexed proposalId);   //提案没达到法定人数时发出的事件。
    event ProposalTimelockStarted(uint256 indexed proposalId);    //提案通过后进入时间锁时发出的事件

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");   //检查是不是管理员
        _;   //“前面的检查通过后，再去执行真正的函数内容。”
    }

    constructor(   //初始化函数
        address _governanceToken,   //部署时传入治理代币地址
        uint256 _votingDuration,   //部署时传入投票时长
        uint256 _timelockDuration,   //部署时传入时间锁时长
        uint256 _quorumPercentage,   //部署时传入法定人数百分比
        uint256 _proposalDepositAmount   //部署时传入提案押金数量
    ) {
        require(_governanceToken != address(0), "Invalid token");   //地址不能为0
        require(_votingDuration > 0, "Invalid duration");
        require(_quorumPercentage > 0 && _quorumPercentage <= 100, "Invalid quorum");   //检查法定人数百分比必须在 1 到 100 之间。

        governanceToken = IERC20(_governanceToken);   //把传进来的代币地址，保存到 governanceToken 变量里
        votingDuration = _votingDuration;   //保存投票时长。
        timelockDuration = _timelockDuration;    //保存时间锁时长。
        admin = msg.sender;
        quorumPercentage = _quorumPercentage;   //保存法定人数百分比
        proposalDepositAmount = _proposalDepositAmount;   //保存提案押金金额
    }

    // 创建提案
    function createProposal(string memory description) external returns (uint256) {   //定义一个外部函数：createProposal；description = 提案描述，uint256 = 新提案的 ID
        require(bytes(description).length > 0, "Empty description");   //检查提案描述不能为空。

        // 收取提案押金
        if (proposalDepositAmount > 0) {   //如果提案押金大于 0，就要收押金。否则不用
            governanceToken.transferFrom(msg.sender, address(this), proposalDepositAmount);   //从提案发起人地址，把押金代币转到本合约地址。
        }

        uint256 proposalId = nextProposalId++;   //创建一个新的提案 ID。先把当前 nextProposalId 赋值给 proposalId，然后 nextProposalId 自增 1

        proposals[proposalId] = Proposal({   //把这个新提案的信息，存进 proposals 映射里
            proposer: msg.sender,   //发起人=当前调用人
            description: description,   //提案描述就是用户传进来的文字。
            forVotes: 0,   //赞成票一开始是 0。
            againstVotes: 0,   //反对票一开始是 0。
            startTime: block.timestamp,   //投票开始时间设为当前区块时间。也就是从现在开始投票。
            endTime: block.timestamp + votingDuration,   //投票结束时间 = 当前时间 + 投票持续时长。
            executed: false,   //刚创建时，还没执行。
            canceled: false,   //刚创建时，也没取消
            timelockEnd: 0   //时间锁结束时间一开始先设成 0。(还没进入时间锁)
        });   //提案内容写入完成。

        emit ProposalCreated(proposalId, msg.sender, description);   //发出“提案已创建”的事件通知。
        return proposalId;   //把新提案 ID 返回出去。
    }

    // 投票
    function vote(uint256 proposalId, bool support) external {   //定义投票函数。proposalId=你给哪个提案投票；support=你投赞成还是反对(true = 赞成,false = 反对)
        Proposal storage proposal = proposals[proposalId];   //取出这个提案，并用 proposal 这个名字来代表它

        require(block.timestamp >= proposal.startTime, "Not started");   //检查投票是不是已经开始了。
        require(block.timestamp <= proposal.endTime, "Ended");   //检查投票是不是还没结束。
        require(!proposal.executed, "Already executed");   //检查这个提案是否还没执行。
        require(!proposal.canceled, "Canceled");   //检查这个提案没有被取消
        require(!hasVoted[proposalId][msg.sender], "Already voted");   //检查当前地址之前没投过票

        uint256 weight = governanceToken.balanceOf(msg.sender);   //读取当前投票人持有多少治理代币。这个数量就是他的投票权重。(这就是 DAO 常见的“按持币数量投票”。)
        require(weight > 0, "No voting power");   //检查这个人必须有治理代币.如果 1 个都没有，就没有投票权。

        hasVoted[proposalId][msg.sender] = true;   //把这个人的投票记录记下来，表示他已经投过了。

        if (support) {   //如果 support 是 true，说明投的是赞成票
            proposal.forVotes += weight;   //把他的票重加到赞成票里。
        } else {   //否则，就是反对票。
            proposal.againstVotes += weight;   //把他的票重加到反对票里。
        }   //投票分支结束。

        emit Voted(proposalId, msg.sender, support, weight);   //发出投票事件通知，告诉外界：谁对哪个提案投了什么票，票重是多少
    }

    // 完成提案（进入时间锁或取消）-通过or失败
    function finalizeProposal(uint256 proposalId) external {   //定义函数 finalizeProposal(作用:在投票结束后，来“结算”这个提案)
        Proposal storage proposal = proposals[proposalId];   //先取出这个提案

        require(block.timestamp > proposal.endTime, "Voting not ended");   //要求当前时间必须已经超过投票结束时间。即“投票还没结束时，不能结算”
        require(!proposal.executed, "Already executed");   //如果已经执行过，就不能再结算了。
        require(!proposal.canceled, "Canceled");   //如果已经取消了，也不能再结算。

        uint256 totalVotes = proposal.forVotes + proposal.againstVotes;   //计算总投票数 = 赞成票 + 反对票。
        uint256 totalSupply = governanceToken.totalSupply();   //读取治理代币的总发行量。比如整个系统一共有多少代币
        uint256 quorumRequired = (totalSupply * quorumPercentage) / 100;   //算出法定人数需要多少票。

        if (totalVotes >= quorumRequired && proposal.forVotes > proposal.againstVotes) {   //检查1总投票数有没有达到法定人数，2赞成票是不是比反对票多，都满足才算提案通过
            if (timelockDuration > 0) {   //如果设置了时间锁时长，大于 0，说明提案不能立刻执行
                proposal.timelockEnd = block.timestamp + timelockDuration;   //把时间锁结束时间设成：当前时间 + 时间锁时长；“提案通过了，但还要等这么久。”
                emit ProposalTimelockStarted(proposalId);   //发出“提案进入时间锁”的事件。
            } else {   //否则，说明没有设置时间锁，可以直接执行。
                proposal.executed = true;   //把提案标记成已执行。
                _refundDeposit(proposalId);   //退还提案押金给提案发起人(因为提案走到了成功流程里)
                emit ProposalExecuted(proposalId);   //发出提案已执行事件。
            }   //时间锁 / 直接执行 分支结束。
        } else {   //如果没有通过上面的条件，说明提案失败(可能参与人数不足或反对派更多等)
            proposal.canceled = true;   //把提案标记为已取消
            emit QuorumNotMet(proposalId);   //发出“没达到法定人数”的事件
        }   //通过 / 失败 分支结束；else 不只是法定人数不够，还包括“虽然人数够了，但反对票更多”的情况
    }    //finalizeProposal 函数结束

    // 执行提案
    function executeProposal(uint256 proposalId) external {   //定义执行提案函数(给“已经通过并进入时间锁的提案”准备)。
        Proposal storage proposal = proposals[proposalId];    //取出提案

        require(proposal.timelockEnd > 0, "No timelock set");   //检查这个提案必须已经设置过时间锁。如果 timelockEnd 还是 0，说明它没进入时间锁流程
        require(block.timestamp >= proposal.timelockEnd, "Timelock not ended");   //检查当前时间必须已经到达或超过时间锁结束时间。
        require(!proposal.executed, "Already executed");    //不能重复执行
        require(!proposal.canceled, "Canceled");    //被取消的提案不能执行

        proposal.executed = true;    //把提案标记为已执行
        _refundDeposit(proposalId);    //退还提案押金

        emit ProposalExecuted(proposalId);    //发出已执行事件
    }

    // 退还押金
    function _refundDeposit(uint256 proposalId) internal {    //内部函数 _refundDeposit
        if (proposalDepositAmount > 0) {   //如果押金本来就大于 0，才需要退。
            Proposal storage proposal = proposals[proposalId];   //取出提案
            governanceToken.transfer(proposal.proposer, proposalDepositAmount);   //把押金代币从合约转回给提案发起人。
        }   //退押金逻辑结束。
    }    //内部函数结束。

    // 获取提案结果
    function getProposalResult(uint256 proposalId) external view returns (   //定义一个查看函数 getProposalResult
        bool passed,   //返回值 1：这个提案是否通过
        uint256 forVotes,    //返回值 2：赞成票数
        uint256 againstVotes,   //返回值 3：反对票数
        bool executed   //返回值 4：是否已经执行
    ) {    //返回值列表写完，进入函数体。
        Proposal memory proposal = proposals[proposalId];   //把提案读出来，放到内存里。
        passed = proposal.forVotes > proposal.againstVotes;   //判断提案是否通过：只看赞成票是否大于反对票。
        return (passed, proposal.forVotes, proposal.againstVotes, proposal.executed);   //把结果返回出去。
    }

    // 管理员设置参数
    function setQuorumPercentage(uint256 _newQuorum) external onlyAdmin {   //定义管理员函数：修改法定人数比例。
        require(_newQuorum > 0 && _newQuorum <= 100, "Invalid quorum");   //检查新比例必须合法，在 1 到 100 之间。
        quorumPercentage = _newQuorum;    //更新法定人数比例。
    }

    // 管理员修改提案押金数量
    function setProposalDepositAmount(uint256 _newAmount) external onlyAdmin {
        proposalDepositAmount = _newAmount;   //把押金金额改成新的值。
    }
}





// 下划线_是很多程序员喜欢的习惯，表示：这是内部辅助函数，不是给外部用户直接调用的主功能。
// proposal是“提案盒子”，每个盒子都装着：谁发起、内容是什么、赞成多少、反对多少、什么时候开始和结束、有没有执行/取消
// 投票权重来自代币余额：谁的币多，谁票更重(DAO里常见的Token Voting)
// quorum是“最低参与门槛”：不是说赞成票多就一定通过，还得看总参与人数够不够
// timelock是“冷静期”：提案通过后不立刻执行，先等一会儿，让社区有缓冲时间



