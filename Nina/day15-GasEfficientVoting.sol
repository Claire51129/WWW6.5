// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    
    // 存储变量 - 提案总数
    // Use uint8 for small numbers instead of uint256
    uint8 public proposalCount;
    // 为什么是 `uint8`？我们可能不会有超过 255 个提案（uint8即2^8，范围是0~255. uint256即2^256. ）。使用 `uint256` 会提供远远超出所需的范围，浪费 31 个额外的存储字节。这一微小改变减少了读取和写入此变量的 Gas 使用量。
		/* 
		1. 为什么“浪费 31 字节”听起来很严重？
		在 Solidity 中，最小的存储单位是 Slot（存储槽），每个 Slot 固定为 32 字节（256 位）。
			- 如果你定义一个独立的 uint256，它正好填满一个 Slot。
			- 如果你定义一个独立的 uint8，它只占 1 字节，但 EVM 仍然会为它分配一整个 32 字节的 Slot，剩下的 31 字节会被填零（Padding）。
		纠正一个常见的误解：
		如果这个变量是独立定义的全局变量，uint8 不仅不省钱，反而可能更贵。因为 EVM 原生处理的是 32 字节数据，为了操作那个 uint8，它需要额外的指令来清理高位的零。
		2. 什么时候 uint8 才是真正的“救星”？
		答案是：当多个变量可以挤进同一个 Slot 时（变量打包 Variable Packing）。
		即下方的struct:
			如果用 uint256：每个成员都要占一个 Slot，一个 Proposal 结构体就要占 5 个 Slot。
			使用小类型（如 uint32, bool）：Solidity 编译器会将它们紧凑地排列，让这四个成员合起来只占 1 个 Slot。
			结果： 整个结构体从 5 个 Slot 变成了 2 个 Slot。由于写入一个新 Slot 的成本极高（约 20,000 Gas），这种“打包”直接省掉了 60% 以上的存储费用。
		3. 避坑指南
		作为入门者，请记住以下三条金律：
		（1）在 Memory（函数内部局部变量）中：永远用 uint256。因为它不需要存入区块链，且 EVM 处理 32 字节速度最快。
		（2）在 Storage（全局变量）中：只有当你确定有多个小变量可以凑满 32 字节并能放在一起定义时，才使用 uint8 等小类型。
		（3）安全性优先：使用 uint8 时必须确定数据永远不会溢出。如果提案真的到了第 256 个，合约就会报错（或者在旧版本里发生溢出）。
		*/
		
		
	// 提案结构体
    // Compact struct using minimal space types
    struct Proposal {
        bytes32 name;          // Use bytes32 instead of string to save gas // 32字节。固定大小，比 string 便宜（如果用 string，因为它长度不固定，Solidity 必须额外拿出一个抽屉存长度，再在另一个地方存内容。用 bytes32 就像直接把数据塞进抽屉，一步到位。）
        uint32 voteCount;      // Supports up to ~4.3 billion votes // 4字节。足以支持2^32即 42 亿次投票，节省 Gas
        uint32 startTime;      // Unix timestamp (supports dates until year 2106) 
        uint32 endTime;        // Unix timestamp 
        bool executed;         // Execution status // 1字节。
    }
	// 结构体打包技巧：Solidity 将结构体数据存储在 32 字节的块中。通过仔细选择类型（uint32、bool、bytes32），减少了浪费的空间——更少的存储槽意味着更低的 Gas。
		
    
	// 提案映射 - 提案Id到结构体的映射
    // Using a mapping instead of an array for proposals is more gas efficient for access
    mapping(uint8 => Proposal) public proposals;
    // 我们使用映射而不是数组来存储提案。映射为我们提供了对每个提案的**直接访问（O(1)）**，无需像数组那样进行迭代或边界检查。
            /*Solidity 中 Mapping（映射） 与 Array（数组） 在底层存储逻辑上的本质区别：
            1. 为什么 Mapping 的访问是 O(1)？
            在数组中，如果你想找一个特定 ID 的提案，你可能需要遍历，或者至少 EVM 要计算 < 基地址 + 索引 * 元素大小 >。
            而在 Mapping 中，位置是这样计算的 < 存储位置 = keccak256(abi.encode(key, slot)) > 
                这意味着无论你有 10 个提案还是 1 万个提案，找到某个提案的位置只需要进行一次哈希运算。它不需要像动态数组那样去维护“长度”变量，也不需要为了寻找元素而扫描内存，这种“直达”的方式就是 O(1) 直接访问。
            2. “无需边界检查”省了什么钱？
            数组（Array）：当你访问 proposals[i] 时，Solidity 为了安全，会自动生成一段机器码来检查 i 是否小于 proposals.length。如果越界，直接报错。这段隐形的检查代码每次执行都要花一点点 Gas。
            映射（Mapping）：它在逻辑上是“无限大”的。你访问任何 key，如果没有对应值，它就返回该类型的默认值（比如 false 或 0）。它不执行边界检查，因此在访问时比数组更“轻量”。*/
    // 另外，我们使用 uint8 作为键（key)——更小的键意味着更小的存储占用。
            /* uint8 作为键（Key）真的省钱吗？这里需要辩证地看待：
                - 对于 Mapping 的存储空间来说：其实不省钱。因为无论你的 key 是 uint8 还是 uint256，它最终都会被哈希运算成一个 32 字节（256 位） 的值来决定存储位置。在存储抽屉里，它占用的坑位大小是一样的。
                - 对于 Gas 消耗来说：省钱。
                    （1）输入成本：当你调用函数传入 uint8 时，交易的 calldata 较小，这能省一点点上传费。
                    （2）计算成本：虽然哈希运算本身差不多，但在打包和解包（Packing/Unpacking）过程中，小类型的数据处理有时能配合上文提到的“变量打包”技术。
                    （3）内存占用：在函数运行期间，uint8 在栈（Stack）上占用的空间较少，虽然现代 EVM 对此优化得很好，但原则上保持类型精简是好习惯。
                特别提醒：虽然 Mapping 性能好，但它有一个致命弱点：无法遍历。你不能问 Mapping “请给我所有的提案”。如果你需要展示提案列表，你通常需要结合一个 uint8[] 数组来记录所有的 ID。*/
    
	    
    // 使用位图的投票者注册表 - 投票者地址到位图的映射
    // Single-slot packed user data
    // Each address occupies one storage slot in this mapping
    // We pack multiple voting flags into a single uint256 for gas efficiency
    // Each bit in the uint256 represents a vote for a specific proposal
    mapping(address => uint256) private voterRegistry;
    /* 这是合约变得非常巧妙的地方。我们没有使用：mapping(address => mapping(uint8 => bool)) voted;
    而是将投票者的所有历史记录压缩到一个 uint256 中：每一个位（bit）代表他们是否对该提案投了票。位 0 = 对提案 0 投了票，位 1 = 对提案 1 投了票……以此类推，最多支持 256 个提案。
    这让我们能够：
	    - 每个地址只需一个存储槽即可存储所有投票
			- 使用位运算 `AND` 检查某人是否投过票
			- 使用位运算 `OR` 记录投票
		比起为每个用户使用多个映射和多个存储槽要便宜得多。*/
		/* 这是这份代码中最令人拍案叫绝的优化技巧：位图（Bitmap）。
		在 Solidity 入门阶段，理解“位运算”可能有点烧脑，但一旦掌握，你就能写出极其节省 Gas 的代码。我们把这个 uint256 想象成一排 256 个开关。
		1. 为什么传统的 mapping 贵？
		如果按照直觉写：mapping(address => mapping(uint8 => bool)) voted。（uint8是proposalCount的类型）
			- 当用户投给提案 A，合约要新开一个存储槽记录 true。
			- 当用户投给提案 B，合约又要开一个新槽记录 true。
		代价： 每投一个不同的提案，用户都要支付约 20,000 Gas 的新存储开销。
		2. 位图是如何工作的？
		一个 uint256 在二进制下有 256 位（全是 0 或 1）。我们可以把每一位看作一个“投票记录”：
			- 二进制状态： 0000...0000 (初始状态，一个票都没投)
			- 投给提案 0： 把最后一位变 1 → ...0001
			- 投给提案 1： 把倒数第二位变 1 → ...0011
			- 核心优势： 一个用户投前 256 个提案，全部挤在同一个存储槽（Slot）里。除了第一次投票比较贵（初始化槽），之后的投票都只是修改同一个槽里的数字，Gas 费会大幅下降。*/
    
    
    // 提案投票者计数 - 提案Id到投票者数量的映射
    // Count total voters for each proposal (optional)
    mapping(uint8 => uint32) public proposalVoterCount;
    // - 跟踪每个提案有多少投票者投了票。
	// - 可选但对分析或用户界面很有用。
	// - 同样，我们使用 `uint32`——范围绰绰有余，Gas 消耗更低。
    
    /** proposals结构体中已经记录了voteCount，为什么还需要声明proposalVoterCount这个状态变量？
        1. 访问成本：独立 Mapping  vs. 结构体 Slot
        当你访问数据时，EVM 的收费逻辑是看它需要“搬运”多少数据：
            - 访问 proposals[id].voteCount：
            由于 voteCount 和 startTime、endTime、executed 被打包在**同一个 32 字节的存储槽（Slot）**中，当你读取 voteCount 时，EVM 实际上必须把这整个槽的所有数据都搬出来。
            - 访问 proposalVoterCount[id]：
            这是一个独立的 mapping(uint8 => uint32)。它的存储槽里只存了这一个数字（剩下的空间填零）。
        意义： 如果一个外部合约（比如一个计票器合约）只想知道票数，读取后者会更加“干净”，且在某些复杂的计算场景下，能避免不必要的内存加载开销。

        2. 写入成本的微妙平衡
        在 vote 函数中：
            proposals[proposalId].voteCount++; // 修改 Slot A
            proposalVoterCount[proposalId]++;  // 修改 Slot B
        你可能会觉得这多花了一次写入费。但实际上，如果你的前端页面（如投票看板）需要频繁查询“当前所有提案的票数总和”，遍历 proposals 映射并解析每个结构体是非常昂贵的。
        维护这个独立的 proposalVoterCount 映射，可以理解为为了“读”得爽，牺牲了一点点“写”的成本。这种模式在 Web3 中被称为“索引优化”。

        3. 数据索引（Indexing）与解耦
        这种设计在更复杂的系统中非常常见：
            数据隔离：proposals 存储的是提案的核心静态信息（名字、起止时间）。
            状态隔离：proposalVoterCount 存储的是提案的动态统计数据。
        如果未来你想升级合约，只改变统计逻辑而不动提案的基础信息，这种解耦会让你更容易进行逻辑拆分。

        4. 真实世界中的理由：易用性
        在 Solidity 中，由于 proposals 是一个复杂的 mapping 返回 struct，自动生成的 getter 函数（即点击 Remix 上的 proposals 按钮）要求你输入 ID 后返回一长串数据。
        而 proposalVoterCount 的 getter 函数非常简单，直接返回一个数字。对于很多简单的链下集成工具或简单的 DAO 仪表盘来说，这种直接返回单一数值的变量要友好得多。
     */
    
    //事件
    // Events
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);
    // - `indexed` 允许您更有效地过滤日志（例如，显示某人投过票的所有提案）。
		// 	- 我们保持这些事件最小化——触发巨大的日志会消耗 Gas。    
    

    
    // === Core Functions ===
    
    /**
     * @dev Create a new proposal
     * @param name The proposal name (pass as bytes32 for gas efficiency)
     * @param duration Voting duration in seconds
     */
    function createProposal(bytes32 name, uint32 duration) external {
        require(duration > 0, "Duration must be > 0");
        
        // Increment counter - cheaper than .push() on an array
        uint8 proposalId = proposalCount;
        proposalCount++;
        /*取号：程序查看当前的 proposalCount ，并把这个值赋给一个临时变量 proposalId。第一个提案的 ID 是 0。
        跳号：全局计数器 proposalCount +1。
        为什么先取号，再跳号 - 从0开始 - 原因是：
            （1）节省空间：正如我们之前聊过的位图（Bitmap），第 0 位是有效位。如果从 1 开始，uint256 的第一位（Bit 0）就永远空着，浪费了。
            （2）符合数组逻辑：在编程中，proposals[0] 通常是第一个元素。
            （3）Gas 效率：虽然微乎其微，但处理 0 通常是 EVM 的原生状态。*/
        /*这在存储中是怎么发生的？这是一个从 Stack（栈） 到 Storage（硬盘） 的交互过程：
            proposalCount 住在“硬盘”里（Storage），修改它很贵（约 5,000 Gas）。
            proposalId 住在“内存”里（Stack），它是临时的，修改它几乎免费。*/

        /*为什么proposalId在stack不在memory？
        在 Solidity 中：
            值类型 (Value Types)：uint, int, address, bool, bytes1 到 bytes32。它们默认都待在 Stack。
            引用类型 (Reference Types)：struct, array, mapping。它们必须明确指定待在 Memory 还是 Storage。
        stack比memory更快更便宜。如果强行把 uint8 放进 Memory，反而会浪费 Gas：
            分配开销：在 Memory 中开辟空间需要 MLOAD / MSTORE 指令。
            存取速度：从 Stack 读取数据是 3 Gas，而从 Memory 读取需要更多的计算和偏移量定位。*/

        
        // Use a memory struct and then assign to storage
        // 在内存(memory)中创建提案 - 在链下构建数据结构然后只写入存储一次会更便宜
        Proposal memory newProposal = Proposal({
            name: name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });
        // 赋值给存储(storage) - 现在我们已经组装好提案，我们使用它的 ID 将其放入 proposals 映射中
        proposals[proposalId] = newProposal;
        /* 不推荐的写法：
            proposals[proposalId].name = name;      // 第 1 次去保险箱
            proposals[proposalId].voteCount = 0;    // 第 2 次去保险箱
            proposals[proposalId].startTime = ...;  // 第 3 次去保险箱
            proposals[proposalId].endTime = ...;    // 第 4 次去保险箱
        */
        
        emit ProposalCreated(proposalId, name);
    }
    

    /**
     * @dev Vote on a proposal
     * @param proposalId The proposal ID
     */
    function vote(uint8 proposalId) external {
        // Require valid proposal
        require(proposalId < proposalCount, "Invalid proposal");
        
        // Check proposal voting period
        uint32 currentTime = uint32(block.timestamp); 
            /* 为什么创建局部变量？
            （1）节省读取成本（避免重复调用）
            创建变量后，你只读取一次 block.timestamp 并将其存入 Stack（栈）。后续的两次比较（>= 和 <=）都是直接从极快的栈中读取数据。
             2）类型对齐（Type Casting）
            在声明变量时做了强制转换：uint32(block.timestamp)。
                默认类型：block.timestamp 的默认类型是 uint256。
                结构体类型：你的 Proposal 结构体中，startTime 和 endTime 为了节省存储空间，被定义成了 uint32。
            通过先转换成 uint32 存入局部变量，后续的 require 比较就是在两个 同类型（uint32） 之间进行的。这避免了 EVM 在每次比较时都默默地进行隐式类型提升（从 uint32 提到 uint256），从而节省了计算 Gas。。
            （3）逻辑的一致性（Atomic Time）
            虽然在一个交易执行期间 block.timestamp 通常保持不变，但养成**“一次读取，多次使用”**的习惯可以确保逻辑的严密性。
            如果在极其复杂的合约逻辑中，你在函数开头读一次时间，结尾读一次时间，虽然极罕见，但在某些特定的侧链或未来可能的 EVM 并行执行环境下，保持一个**快照（Snapshot）**数值会让逻辑更安全。
             */
        require(currentTime >= proposals[proposalId].startTime, "Voting not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting ended");
        
        // Check if already voted using bit manipulation (gas efficient) 
        uint256 voterData = voterRegistry[msg.sender];
        uint256 mask = 1 << proposalId;
        require((voterData & mask) == 0, "Already voted");
        // 位掩码(Bitmask)检查该用户是否已为该提案投票
            // - `1 << proposalId` 创建一个二进制掩码. '1'的二进制是 '000001' ，proposalId是几，就把1向左移几位。例如，如 proposalId 为 2 则被左移为 `000100`。
            // - 位运算 AND 检查该位是否已在用户的注册表中设置。如果已设置，则用户已投过票。
                /* & 与运算的逻辑是：只有两个数字对应的位置都是 1，结果才为 1。
                   现在我们在检查该用户是否为第X个提案投过票，mask中X位为1。
                   如果用户投过票，则voterData中X位也为1，(voterData & mask) 为1，未通过检查，提示“已投过票”；
                   如果用户未投过票，则voterData中X位为0，(voterData & mask) 为0，通过检查，继续运行下方逻辑。
                如果不制作掩码，只用voterData判断，那么哪怕用户为其他提案投过票，其值也不为0，用户也不能为此提案投票。*/
        
        // Record vote using bitwise OR
        voterRegistry[msg.sender] = voterData | mask;
        // 使用位运算(bitwise )OR 记录投票
            // - 位运算OR 将位置 proposalId 处的位设置为 1，标记投票。
                /* | 或运算的规则是：只要有一个是 1，结果就是 1。
                   能进入这行代码的前提是 voterData 中第X位为0，而 mask 中仅第X位为1。 通过或运算，在保留了原 voterData 中所有的1的基础上，给第X位也赋值1，以此标记新的投票。*/
        
        // Update proposal vote count
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;
        
        emit Voted(msg.sender, proposalId);
    }
    
    /**
     * @dev Execute a proposal after voting ends
     * @param proposalId The proposal ID
     */
    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed, "Already executed");
        
        proposals[proposalId].executed = true;
        
        emit ProposalExecuted(proposalId);
        
        // In a real contract, execution logic would happen here
    }
    


    // === View Functions ===
    
    /**
     * @dev Check if an address has voted for a proposal
     * @param voter The voter address
     * @param proposalId The proposal ID
     * @return True if the address has voted
     */
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }
    // - 创建一个像 `vote()` 函数中那样的位掩码。
    // - 检查该位是否在投票者的注册表中设置。
    // - 如果投票者已经对该提案投过票，则返回 `true`。
    //节省 Gas 的读取：只需一次存储访问(storage access)和一次位运算(bitwise operation)。【我们不需要为了确认“某一个”提案的状态而专门去跑一趟“硬盘”。我们跑一趟“硬盘”，拿回来一整包（256个）状态，然后在“手里”用飞快的位运算把我们要的那一个“过滤”出来。】
    
    /**
     * @dev Get detailed proposal information
     * Uses calldata for parameters and memory for return values
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
        /** 存储指针（Storage Pointer）
            不需要将存储里的所有数据（name, voteCount, startTime 等）全部拷贝一份到内存（Memory）里。
            只是定义了一个指针，告诉 EVM：“以后我说 proposal，你就去 proposals[proposalId] 那个位置找。”——几乎零成本。它不发生数据迁移，只是引用的建立。
            注意：这里的mutability是view，我们只在storage读取数据，不做修改。
         */
        
        return (
            proposal.name,
            proposal.voteCount,
            proposal.startTime,
            proposal.endTime,
            proposal.executed,
            (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime) // 外加一个额外的 active 标志，指示投票当前是否正在进行。这对于 UI/UX 很有用——让前端知道是否应该显示“投票”按钮。
        );
    }
    
    /**
     * @dev Convert string to bytes32 (helper for frontend integration)
     * Note: This is a pure function that doesn't use state, so it's gas-efficient
     */

}

/*在以太坊上，最昂贵的操作是“存储”（Storage）。代码中的所有技巧几乎都是为了减少对存储槽（Storage Slot，每个 32 字节）的操作次数。

以下是代码中四个核心优化点的深度解析：

1. 变量打包（Variable Packing）
    Solidity 的存储就像一排柜子，每个柜子（Slot）正好能放 32 字节。
        非优化做法：如果你全部用 uint256，每个变量都会独占一个柜子。
        代码做法：通过减小类型大小，让多个变量挤在一个柜子里。
    struct Proposal {
        bytes32 name;      // 占用 1 个槽 (32 bytes)
        uint32 voteCount;  // 4 bytes \
        uint32 startTime;  // 4 bytes  | 这四个变量加起来共 13 bytes
        uint32 endTime;    // 4 bytes  | 它们会被“打包”进同一个 32 字节的槽中
        bool executed;     // 1 byte  /
    }
    结果：原本需要 5 次昂贵的存储写入，现在只需 2 次。

2. 位掩码技术（Bitmasking）
    这是代码中最硬核的优化。通常我们会用 mapping(address => mapping(uint256 => bool)) 来记录谁投过票。但这样每次投票都要新开一个存储位置。
    代码方案：用一个 uint256（256 位）代表一个用户的所有投票状态。
        第 0 位代表 Proposal 0，第 1 位代表 Proposal 1...
        1 << proposalId：创建一个只有第 proposalId 位是 1 的数字。
        voterData | mask：使用位运算“或”，将对应位置改为 1，表示已投票。
    优势：在同一个 uint256 槽位内，用户前 256 次投票都只是在修改同一个 Slot，而不是开辟新 Slot。这能省下巨额 Gas。

3. 数据类型的选择：bytes32 vs string；uint8 vs uint256
    string：是动态长度的，Solidity 处理它需要复杂的逻辑（包括存储长度、分配空间等）。
    bytes32：是定长的，直接填满一个 Slot。
    提示：只要你的字符串长度不超过 31 个字符（剩下 1 字节存长度），永远优先使用 bytes32。

4. 内存与存储的权衡（Memory vs Storage）
    在 createProposal 函数中，注意这一行：
        Proposal memory newProposal = Proposal({ ... });
        proposals[proposalId] = newProposal;
    这里先在 Memory（临时、便宜）中构建完整个结构体，最后一次性写入 Storage（持久、昂贵）。这比直接逐个修改 proposals[proposalId].name = ... 要省钱，因为减少了对状态变量的反复读写次数。
*/