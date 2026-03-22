// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
如何在不牺牲功能的前提下，节省每一个可能的 Gas 单位？
Gas优化的版本
- ✅ 用户仍然可以创建提案
- ✅ 用户可以投票
- ✅ 我们追踪投票历史
- ✅ 提案可以被执行
- ✅ 事件被触发以保持透明度

但关键在于：我们通过做出更智能的存储和逻辑决策，使所有操作**更快、更便宜**。
*/

contract GasEfficientVoting{
      
   //提案个数
   uint8 public proposalCount;

   //提案结构体
   struct Proposal{
      bytes32 name;
      uint32 voteCount;
      uint32 startTime;
      uint32 endTime;
      bool executed;
   }

   //提案映射而非数组
   /*
   我们使用映射而不是数组来存储提案。
   映射为我们提供了对每个提案的**直接访问（O(1)）**，无需像数组那样进行迭代或边界检查。
   另外，我们使用 uint8 作为键（key)——更小的键意味着更小的存储占用。
   */
   mapping(uint8 => Proposal) public proposals;
  
   //使用位图的投票者注册表
   /*
   而是将投票者的所有历史记录压缩到**一个 `uint256` 中**：
   每一个**位（bit）**代表他们是否对该提案投了票。
   位 0 = 对提案 0 投了票
   位 1 = 对提案 1 投了票  ……以此类推，最多支持 256 个提案。
   这让我们能够：
   每个地址只需一个存储槽即可存储所有投票
   使用位运算 `AND` 检查某人是否投过票
   使用位运算 `OR` 记录投票
   */
   mapping(address => uint256) private voterRegistry;
  
  //提案投票者计数
  /*跟踪每个提案有多少投票者投了票。
   可选但对分析或用户界面很有用。
   同样，我们使用 `uint32`——范围绰绰有余，Gas 消耗更低。
  */
   mapping(uint8 => uint32) public proposalVoterCount;

   //proposals[8]
   event ProposalCreated(uint8 indexed proposalId, bytes32 name);
   event Voted(address indexed voter, uint8 indexed proposalId);
   event ProposalExecuted(uint8 indexed proposalId);

   //创建提案
     
   function createProposal(bytes32 name, uint32 duration) external {
       require(duration > 0, "Duration must be > 0");
       
       /*
       使用一个简单的计数器（uint8）而不是推送到数组。
       数组需要动态调整大小和额外的 Gas 进行边界管理——这种方式更精简。
       */
       uint8 proposalId = proposalCount;
       proposalCount++;
      
      //构建使用memeory
       Proposal memory newProposal = Proposal({
           name: name,
           voteCount: 0,
           startTime: uint32(block.timestamp),
           endTime: uint32(block.timestamp) + duration,
           executed: false
       });
       
       //赋值给存储storage
       proposals[proposalId] = newProposal;

       emit ProposalCreated(proposalId, name);
   }
   
     
   function vote(uint8 proposalId) external {
       require(proposalId < proposalCount, "Invalid proposal");

       uint32 currentTime = uint32(block.timestamp);
       require(currentTime >= proposals[proposalId].startTime, "Voting not started");
       require(currentTime <= proposals[proposalId].endTime, "Voting ended");

       uint256 voterData = voterRegistry[msg.sender];// 获取你名下的那排“开关”
       uint256 mask = 1 << proposalId;  //将数字 1 的二进制位，向左移动 proposalId 位。
       require((voterData & mask) == 0, "Already voted");//位运算 AND 检查该位是否已在用户的注册表中设置

       voterRegistry[msg.sender] = voterData | mask;//记录投票
       //位运算OR 将位置 proposalId 处的位设置为 1，标记投票。

       proposals[proposalId].voteCount++;
       proposalVoterCount[proposalId]++;

       emit Voted(msg.sender, proposalId);
   }

   //执行提案
   /*
   - 任何人都可以**在**投票期结束后执行提案。
   - 它确保：
    - 提案存在
    - 投票窗口已结束
    - 提案尚未被执行
   */
   function executeProposal(uint8 proposalId) external {
      require(proposalId < proposalCount, "Invalid proposal");
      require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
      require(!proposals[proposalId].executed, "Already executed");

      proposals[proposalId].executed = true;
      emit ProposalExecuted(proposalId);
    }

    /*
    创建一个像 vote() 函数中那样的位掩码。
    检查该位是否在投票者的注册表中设置。
    如果投票者已经对该提案投过票，则返回 true。
    */  
   function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
       return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }

    /*
    - 检查提案是否存在。
    - 返回其所有字段，**外加**一个额外的 `active` 标志，指示投票当前是否正在进行。
    - 这对于 UI/UX 很有用——让前端知道是否应该显示“投票”按钮。
    */
      
function getProposal(uint8 proposalId) external view returns (
    bytes32 name,
    uint32 voteCount,
    uint32 startTime,
    uint32 endTime,
    bool executed,
    bool active
) {
    require(proposalId < proposalCount, "Invalid proposal");

    Proposal storage proposal = proposals[proposalId];

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