export const gasEstimates = {
    increment: 21000,
    reset: 21000,
    addData: 40000,
    retrieveData: 0,
    addCandidate: 50000,
    vote: 35000,
    placeBid: 45000,
    endAuction: 25000,
    addTreasure: 30000,
    approveWithdrawal: 40000,
    withdrawTreasure: 50000,
    resetWithdrawalStatus: 25000,
    transferOwnership: 35000,
    getTreasureDetails: 0,
    addMembers: 45000,
    depositAmountEther: 35000,
    withdrawAmount: 40000,
    getMembers: 0,
    addFriend: 45000,
    depositIntoWallet: 35000,
    recordDebt: 45000,
    payFromWallet: 50000,
    transferEther: 35000,
    transferEtherViaCall: 40000,
    withdraw: 35000,
    checkBalance: 0,
    addCurrency: 45000,
    tipInEth: 40000,
    tipInCurrency: 50000,
    withdrawTips: 35000,
    transferOwnership8: 35000,
    // Day 13 - MyToken
    transfer13: 35000,
    approve13: 30000,
    transferFrom13: 40000,
    getBalance13: 0,
    getAllowance13: 0,
    // Day 14 - SafeDeposit
    createBasicBox: 80000,
    createPremiumBox: 100000,
    createTimeLockedBox: 120000,
    storeSecret: 35000,
    getSecret: 0,
    transferOwnership14: 40000,
    setMetadata: 30000,
    getMetadata: 0,
    getUnlockTime: 0,
    getRemainingLockTime: 0,
    completeOwnershipTransfer: 45000,
    // Day 15 - GasEfficientVoting
    createProposal15: 60000,
    vote15: 40000,
    executeProposal15: 35000,
    // Day 16 - PluginStore
    setProfile16: 35000,
    registerPlugin16: 25000,
    runPlugin16: 45000,
    runPluginView16: 0,
    // Day 17 - UpgradeHub
    createPlan17: 45000,
    upgradeTo17: 35000,
    subscribe17: 50000,
    pauseSubscription17: 30000,
    resumeSubscription17: 30000,
    isSubscribed17: 0,  // 查询订阅状态（view函数，不消耗Gas）
    // Day 18 - OracleContract
    checkRainfall18: 0,        // 查询天气（view函数）
    purchaseInsurance18: 45000, // 购买保险
    claimPayout18: 50000,       // 申请赔付
    fastForwardTime18: 0,       // 快进时间（模拟操作）
    withdrawBalance18: 35000,   // 提取余额
    // Day 19 - SignThis
    generateSignature19: 0,     // 前端模拟签名（不消耗Gas）
    enterEvent19: 65000,        // 参与活动（写操作）
    checkEntered19: 0,          // 查看参与状态（view函数）
    getParticipants19: 0,        // 获取参与者列表（view函数）
    // Day 20 - ReentryAttack
    deposit20: 45000,
    vulnerableWithdraw20: 50000,
    safeWithdraw20: 35000,
    checkVaultStatus20: 0,  // view 函数
    // Day 21 - SimpleNFT
    mint21: 150000,
    transferFrom21: 80000,
    safeTransferFrom21: 85000,
    approve21: 45000,
    setApprovalForAll21: 35000,
    balanceOf21: 0,
    getApproved21: 0,
    ownerOf21: 0
};

export const ethPricePerGwei = 0.00000004;

export const conceptDefinitions = {
    function: {
        name: "函数交互",
        icon: "🎯",
        unlockAt: 1,
        message: "你刚刚调用了 Solidity 中的第一个函数！在区块链上，用户与合约的所有交互都是通过函数完成的。",
        code: `function click() public {\n    // 你的点击在这里触发\n}`
    },
    increment: {
        name: "自增操作",
        icon: "➕",
        unlockAt: 2,
        message: "你发现了 `++` 这个操作符的作用！它的意思是\"在原来的基础上加 1\"。",
        code: `count++;  // 等同于 count = count + 1;`
    },
    uint256: {
        name: "uint256 变量",
        icon: "🔢",
        unlockAt: 3,
        message: "你刚刚修改了一个 `uint256` 类型的变量。`uint` = 无符号整数（只能存正数），`256` = 能存超级大的数字。",
        code: `uint256 public count;  // 能存储超大数字`
    },
    contract: {
        name: "contract 结构",
        icon: "🏗️",
        unlockAt: 4,
        message: "欢迎来到你的第一个 `contract`！你现在看到的交互界面，就是这个\"合约\"的前端。没有它，就没有智能合约世界！",
        code: `contract ClickCounter {\n    uint256 public count;\n    \n    function click() public {\n        count++;\n    }\n}`
    },
    string: {
        name: "string 类型",
        icon: "📝",
        unlockAt: 1,
        message: "你刚刚使用了 `string` 类型！它可以存储文本数据，比如名字、描述等信息。",
        code: `string name;  // 存储文本数据\nstring bio;   // 存储简介`
    },
    private: {
        name: "private 变量",
        icon: "🔒",
        unlockAt: 2,
        message: "你发现了 `private` 关键字！表示这个变量只能在合约内部访问，外部无法直接读取。",
        code: `string private name;  // 只能在合约内部访问`
    },
    memory: {
        name: "memory 存储",
        icon: "💾",
        unlockAt: 3,
        message: "你使用了 `memory` 关键字！表示数据存储在内存中，只在函数执行期间存在，执行完毕后自动清除。",
        code: `function add(string memory _name) public {\n    // _name 存储在内存中，临时使用\n}`
    },
    view: {
        name: "view 函数",
        icon: "👁️",
        unlockAt: 4,
        message: "你调用了 `view` 函数！它只读取数据不修改状态，因此不消耗 Gas，这是优化合约的重要方法。",
        code: `function retrieve() public view returns (string memory) {\n    return name;  // 只读取，不修改\n}`
    },
    parameters: {
        name: "函数参数",
        icon: "📥",
        unlockAt: 5,
        message: "你使用了函数参数！参数让函数能够接收外部传入的数据，使函数更加灵活。",
        code: `function add(string memory _name, string memory _bio) public {\n    // _name 和 _bio 是参数\n}`
    },
    returns: {
        name: "返回值",
        icon: "📤",
        unlockAt: 6,
        message: "你使用了 `returns` 关键字！它定义了函数返回的数据类型，让函数能够向调用者返回结果。",
        code: `function retrieve() public view returns (string memory, string memory) {\n    return (name, bio);  // 返回多个值\n}`
    },
    array: {
        name: "数组类型",
        icon: "📋",
        unlockAt: 1,
        message: "你刚刚创建了数组！`candidateNames` 数组用来存储所有候选人的姓名。",
        code: `string[] public candidateNames;  // 声明字符串数组\ncandidateNames.push("Alice");  // 添加第一个候选人`
    },
    push: {
        name: "push 方法",
        icon: "➕",
        unlockAt: 2,
        message: "你使用了 `push` 方法！它在数组末尾添加新元素，每次添加候选人都会用到它。",
        code: `candidateNames.push("Alice");  // 添加 Alice 到数组末尾\ncandidateNames.push("Bob");    // 添加 Bob 到数组末尾`
    },
    mapping: {
        name: "映射类型",
        icon: "🗺️",
        unlockAt: 3,
        message: "你发现了 `mapping` 映射！它用候选人姓名作为键，票数作为值，存储投票结果。",
        code: `mapping(string => uint256) voteCount;  // 声明映射\nvoteCount["Alice"] = 0;  // 初始化票数为0`
    },
    compound_assignment: {
        name: "复合赋值",
        icon: "⚡",
        unlockAt: 4,
        message: "你使用了 `+=` 复合赋值运算符！每次投票都会将候选人的票数加1。",
        code: `voteCount["Alice"] += 1;  // 票数加1，等同于 voteCount["Alice"] = voteCount["Alice"] + 1;`
    },
    constructor: {
        name: "构造函数",
        icon: "🏗️",
        unlockAt: 1,
        message: "你刚刚调用了构造函数！它只在合约部署时执行一次，用于初始化合约的状态变量。",
        code: `constructor(string memory _item, uint _biddingTime) {\n    owner = msg.sender;\n    item = _item;\n    auctionEndTime = block.timestamp + _biddingTime;\n}`
    },
    msg_sender: {
        name: "msg.sender",
        icon: "📧",
        unlockAt: 2,
        message: "你使用了 `msg.sender`！它表示当前调用合约的地址，可以是用户钱包或其他合约。",
        code: `address public owner = msg.sender;  // 部署者成为所有者\nfunction bid() external {\n    bids[msg.sender] = amount;  // 记录竞拍者出价\n}`
    },
    block_timestamp: {
        name: "block.timestamp",
        icon: "⏰",
        unlockAt: 3,
        message: "你使用了 `block.timestamp`！它返回当前区块的时间戳（Unix时间，秒），常用于时间相关的逻辑。",
        code: `uint public auctionEndTime = block.timestamp + _biddingTime;  // 设置拍卖结束时间\nrequire(block.timestamp < auctionEndTime, "Auction has ended.");  // 检查时间`
    },
    require: {
        name: "条件检查",
        icon: "✅",
        unlockAt: 4,
        message: "你使用了 `require` 语句！它在条件不满足时回滚交易，是合约安全的重要机制。",
        code: `require(amount > 0, "Bid amount must be greater than zero.");\nrequire(block.timestamp < auctionEndTime, "Auction has already ended.");`
    },
    external: {
        name: "external 函数",
        icon: "🌐",
        unlockAt: 5,
        message: "你使用了 `external` 函数！它只能从合约外部调用，比 `public` 更节省 Gas。",
        code: `function bid(uint amount) external {\n    // 只能从外部调用，不能在合约内部调用\n}`
    },
    address_type: {
        name: "地址类型",
        icon: "🏠",
        unlockAt: 6,
        message: "你使用了 `address` 类型！它存储以太坊地址（钱包地址或合约地址），是区块链交互的核心。",
        code: `address public owner;  // 所有者地址\naddress private highestBidder;  // 最高出价者地址\nmapping(address => uint) public bids;  // 地址到出价的映射`
    },
    bool_type: {
        name: "布尔类型",
        icon: "🔘",
        unlockAt: 7,
        message: "你使用了 `bool` 类型！它只有 `true` 或 `false` 两个值，用于标记状态。",
        code: `bool public ended;  // 拍卖是否已结束\nended = true;  // 标记拍卖结束\nrequire(!ended, "Auction already ended.");  // 检查状态`
    },
    modifier: {
        name: "修饰符",
        icon: "🛡️",
        unlockAt: 1,
        message: "你使用了 `modifier`！它用于为函数添加前置条件检查，确保只有满足条件的调用者才能执行函数。",
        code: `modifier onlyOwner() {\n    require(msg.sender == owner, "Only owner");\n    _;  // 继续执行被修饰的函数\n}`
    },
    zero_address: {
        name: "零地址检查",
        icon: "⚠️",
        unlockAt: 2,
        message: "你检查了 `address(0)` 零地址！它表示一个无效的地址，通常用于检查地址参数是否有效。",
        code: `require(newOwner != address(0), "Invalid address");  // 确保不是零地址\naddress(0)  // 零地址，表示无效地址`
    },
    return_statement: {
        name: "返回语句",
        icon: "↩️",
        unlockAt: 3,
        message: "你了解了返回语句的用法！继续解锁更多概念吧！",
        code: `function withdrawTreasure(uint256 amount) public {\n    if (msg.sender == owner) {\n        return;  // 所有者提前退出，不执行后续逻辑\n    }\n    \n    require(allowance > 0, "No allowance");\n    treasureAmount -= allowance;\n}`
    },
    address_mapping_balance: {
        name: "地址映射余额",
        icon: "💰",
        unlockAt: 1,
        message: "你刚刚使用了地址映射来存储每个用户的余额！mapping(address => uint256) 是存储用户资产的核心数据结构。",
        code: `mapping(address => uint256) balance;\n\nbalance[0x123...] = 1000000;  // 存储余额\nuint256 amount = balance[msg.sender];  // 读取余额`
    },
    payable: {
        name: "可支付函数",
        icon: "💵",
        unlockAt: 2,
        message: "你使用了 `payable` 关键字！它让函数能够接收以太币，这是处理资金交易的关键。",
        code: `function deposit() public payable {\n    // 这个函数可以接收以太币\n    require(msg.value > 0, "Must send ETH");\n    balance[msg.sender] += msg.value;\n}`
    },
    msg_value: {
        name: "发送金额",
        icon: "💳",
        unlockAt: 3,
        message: "你使用了 `msg.value`！它表示调用函数时发送的以太币数量（以wei为单位），是获取转账金额的标准方式。",
        code: `function deposit() public payable {\n    uint256 amount = msg.value;  // 获取发送的ETH数量\n    balance[msg.sender] += amount;\n}`
    },
    wei_unit: {
        name: "Wei 单位",
        icon: "⚖️",
        unlockAt: 4,
        message: "你了解了以太币的最小单位 wei！1 ETH = 10^18 wei，这是以太坊计价的基础单位。",
        code: `// 以太币单位\n1 wei = 0.000000000000000001 ETH\n1 gwei = 0.000000001 ETH\n1 ETH = 1000000000000000000 wei\n\nbalance[msg.sender] += 1000000000000000000;  // 增加 1 ETH`
    },
    ether_deposit_withdraw: {
        name: "存取逻辑",
        icon: "🏦",
        unlockAt: 5,
        message: "你掌握了以太币的存取核心逻辑！检查余额、增减余额、验证输入，这是任何金融合约的基础。",
        code: `function deposit() public payable {\n    require(msg.value > 0, "Invalid amount");\n    balance[msg.sender] += msg.value;\n}\n\nfunction withdraw(uint256 amount) public {\n    require(amount > 0, "Invalid amount");\n    require(balance[msg.sender] >= amount, "Insufficient balance");\n    balance[msg.sender] -= amount;\n}`
    },
    withdraw_pattern: {
        name: "提现模式 (Withdraw)",
        icon: "🏧",
        unlockAt: 7,
        message: "你掌握了提现模式！与其主动将资金发送给用户（易受攻击），不如让用户自己来提取他们的资金，这是智能合约安全的核心原则之一。",
        code: `function withdraw(uint256 _amount) public {\n    require(balances[msg.sender] >= _amount);\n    balances[msg.sender] -= _amount;\n    (bool success, ) = payable(msg.sender).call{value: _amount}("");\n    require(success);\n}`
    },
    nested_mapping: {
        name: "嵌套映射",
        icon: "🗂️",
        unlockAt: 1,
        message: "你掌握了如何使用嵌套映射 (mapping in mapping)！这是处理复杂关系（如“谁欠谁多少钱”）的终极武器。",
        code: `mapping(address => mapping(address => uint256)) public debts;`
    },
    address_payable: {
        name: "Payable 地址",
        icon: "💸",
        unlockAt: 2,
        message: "你使用了 address payable！只有标记为 payable 的地址才能接收 Ether，否则编译器会报错保护资金安全。",
        code: `address payable user = payable(msg.sender);`
    },
    debt_tracking: {
        name: "债务追踪",
        icon: "📊",
        unlockAt: 3,
        message: "区块链就是一本账本！你刚刚在链上永久记录了一笔债权关系，且任何人无法抵赖。",
        code: `debts[debtor][msg.sender] += amount;`
    },
    internal_transfer: {
        name: "内部记账转账",
        icon: "🔄",
        unlockAt: 4,
        message: "你完成了一次“内部转账”！这并没有发生真实的链上交易，只是在合约账本里扣减了一个人的余额并增加给另一个人，非常省 Gas。",
        code: `balances[msg.sender] -= amount;\nbalances[creditor] += amount;`
    },
    transfer_method: {
        name: "transfer() 转账",
        icon: "📤",
        unlockAt: 5,
        message: "你使用了经典的 .transfer() 方法。它会自动在转账失败时触发 revert，是最简单安全的转账方式。",
        code: `payable(to).transfer(amount);`
    },
    call_method: {
        name: "call() 转账",
        icon: "📡",
        unlockAt: 6,
        message: "你使用了更强大的 .call() 方法！它是目前以太坊开发中最推荐的转账方式，因为它允许你灵活处理 Gas 限制和错误结果。",
        code: `(bool success, ) = to.call{value: amount}("");\nrequire(success, "Transfer failed");`
    },
    modifier_onlyOwner: {
        name: "onlyOwner 修饰符",
        icon: "🛡️",
        unlockAt: 1,
        message: "你发现了 `onlyOwner`！这是一个自定义修饰符，专门用来限制只有管理员（合约拥有者）才能执行特定的函数（如提现、改汇率）。",
        code: `modifier onlyOwner() {\n    require(msg.sender == owner, "Only owner can perform this action");\n    _;\n}`
    },
    payable_tip: {
        name: "payable 支付关键字",
        icon: "💰",
        unlockAt: 2,
        message: "你成功进行了一次带钱的交互！在 Solidity 中，只有标记为 `payable` 的函数才能接收随交易发送的以太币。",
        code: `function tipInEth() public payable {\n    // 带有 payable 才能收钱\n}`
    },
    msg_value_tip: {
        name: "msg.value 发送金额",
        icon: "💸",
        unlockAt: 3,
        message: "你发送了 ETH！`msg.value` 是一个全局变量，代表了你在调用这个函数时额外付出的金钱（单位是 wei）。",
        code: `tipPerPerson[msg.sender] += msg.value;\ntotalTipsReceived += msg.value;`
    },
    address_balance: {
        name: "合约余额查询",
        icon: "🏦",
        unlockAt: 4,
        message: "想要知道存钱柜里有多少钱？`address(this).balance` 会返回当前智能合约在链上的全部实时余额。",
        code: `uint256 contractBalance = address(this).balance;\nrequire(contractBalance > 0, "No tips to withdraw");`
    },
    call_withdraw: {
        name: "底层 call 转账",
        icon: "📡",
        unlockAt: 5,
        message: "管理员提现成功！使用 `.call{value: ...}(\"\")` 是目前以太坊开发中推荐的由合约向外部地址转账的最灵活方式。",
        code: `(bool success, ) = payable(owner).call{value: contractBalance}("");\nrequire(success, "Transfer failed");`
    },
    mapping_rates: {
        name: "法币汇率映射",
        icon: "💹",
        unlockAt: 6,
        message: "智能合约也能换钱！这里使用了 `mapping(string => uint256)` 来存储不同法币（字符串）对应的 ETH 汇率（数字）。",
        code: `mapping(string => uint256) public conversionRates;

conversionRates["USD"] = 5 * 10**14;`
    },
    pure_function: {
        name: "Pure 纯函数",
        icon: "⚡",
        unlockAt: 1,
        message: "你使用了 `pure` 函数！pure函数不读取也不修改区块链状态，执行快速且不消耗Gas，适合简单的数学计算。",
        code: `function add(uint256 a, uint256 b) public pure returns(uint256) {
    return a + b;  // 纯计算，不访问状态
}`
    },
    view_function: {
        name: "View 视图函数",
        icon: "👁️",
        unlockAt: 2,
        message: "你使用了 `view` 函数！view函数可以读取状态变量但不修改它们，适合查询操作，不消耗Gas。",
        code: `function calculatePower(uint256 base, uint256 exponent) public view returns(uint256) {
    // 读取 scientificCalculatorAddress 状态变量
    ScientificCalculator calc = ScientificCalculator(scientificCalculatorAddress);
    return calc.power(base, exponent);
}`
    },
    cross_contract_call: {
        name: "跨合约调用",
        icon: "📡",
        unlockAt: 3,
        message: "你完成了跨合约调用！一个合约可以通过地址调用另一个合约的函数，实现合约间的组合与协作。",
        code: `// Calculator合约调用ScientificCalculator合约
ScientificCalculator scientificCalc = 
    ScientificCalculator(scientificCalculatorAddress);
uint256 result = scientificCalc.power(base, exponent);`
    },
    interface_call: {
        name: "接口方式调用",
        icon: "🔌",
        unlockAt: 4,
        message: "你使用了接口方式调用外部合约！通过创建接口实例，可以像调用本地函数一样调用外部合约。",
        code: `// 创建外部合约接口实例
ScientificCalculator scientificCalc = 
    ScientificCalculator(scientificCalculatorAddress);

// 调用外部合约函数
uint256 result = scientificCalc.power(base, exponent);`
    },
    low_level_call: {
        name: "底层 Call 调用",
        icon: "🔧",
        unlockAt: 5,
        message: "你使用了底层 `call` 方法！这是最灵活的跨合约调用方式，通过 `abi.encodeWithSignature` 编码函数调用。",
        code: `// 编码函数签名
bytes memory data = abi.encodeWithSignature(
    "squareRoot(int256)", number
);

// 发起底层call调用
(bool success, bytes memory returnData) = 
    scientificCalculatorAddress.call(data);

// 解码返回数据
uint256 result = abi.decode(returnData, (uint256));`
    },
    newton_iteration: {
        name: "牛顿迭代法",
        icon: "📐",
        unlockAt: 7,
        message: "你了解了牛顿迭代法！Solidity不支持浮点数，通过迭代逼近真实值是常用的数学算法实现方式。",
        code: `function squareRoot(int256 number) public pure returns(int256) {
    int256 result = number / 2;
    // 限制10轮，防止Gas耗尽
    for(uint256 i = 0; i < 10; i++) {
        result = (result + number / result) / 2;
    }
    return result;
}`
    },
    contract_composition: {
        name: "合约组合",
        icon: "🧩",
        unlockAt: 8,
        message: "恭喜你掌握了合约组合！合约可以像乐高积木一样组合复用，构建复杂的去中心化应用。",
        code: `// Calculator合约组合了ScientificCalculator合约
contract Calculator {
    address public scientificCalculatorAddress;
    
    // 通过接口调用外部合约功能
    function calculatePower(uint256 base, uint256 exponent) 
        public view returns(uint256) {
        ScientificCalculator calc = 
            ScientificCalculator(scientificCalculatorAddress);
        return calc.power(base, exponent);
    }
}`
    },
    // ========== Day 10 概念定义 ==========
    struct_definition: {
        name: "结构体定义",
        icon: "📦",
        unlockAt: 1,
        message: "你刚刚使用了 `struct` 结构体！它可以打包多个不同类型的变量，创建自定义数据类型。",
        code: `struct UserProfile {
    string name;       // 用户姓名
    uint256 weight;    // 用户体重
    bool isRegistered; // 是否已注册
}

// 创建结构体实例
UserProfile memory newUser = UserProfile({
    name: "张三",
    weight: 70,
    isRegistered: true
});`
    },
    array_in_mapping: {
        name: "映射中的数组",
        icon: "🗂️",
        unlockAt: 2,
        message: "你发现了 mapping 到数组的用法！这可以为每个用户存储一个运动记录列表。",
        code: `// mapping 到数组
mapping(address => WorkoutActivity[]) private workoutHistory;

// 添加新记录
workoutHistory[msg.sender].push(newWorkout);

// 获取记录数量
uint256 count = workoutHistory[msg.sender].length;`
    },
    multiple_mappings: {
        name: "多个映射组合",
        icon: "🗺️",
        unlockAt: 3,
        message: "你看到了多个映射如何协同工作！userProfiles、totalWorkouts、totalDistance 分别存储不同维度的数据。",
        code: `// 多个映射协同工作
mapping(address => UserProfile) public userProfiles;        // 用户资料
mapping(address => WorkoutActivity[]) private workoutHistory;  // 运动历史
mapping(address => uint256) public totalWorkouts;            // 运动次数
mapping(address => uint256) public totalDistance;            // 总距离

// 它们共同构建了完整的数据视图`
    },
    storage_keyword: {
        name: "storage 关键字",
        icon: "💾",
        unlockAt: 4,
        message: "你使用了 `storage` 关键字！它创建状态变量的引用，直接修改原数据而不是创建副本，非常节省 Gas。",
        code: `function updateWeight(uint256 _newWeight) public {
    // storage 关键字创建引用
    UserProfile storage profile = userProfiles[msg.sender];
    
    // 直接修改原数据，不创建副本
    profile.weight = _newWeight;
    
    // ❌ 如果用 memory，会创建副本，修改不会生效
    // UserProfile memory profile = userProfiles[msg.sender];
}`
    },
    event_logging: {
        name: "事件日志",
        icon: "📋",
        unlockAt: 1,
        message: "你触发了事件！事件记录在区块链日志中，前端可以监听事件来获取实时通知。",
        code: `// 定义事件
event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
event WorkoutLogged(address indexed user, string activityType, uint256 duration);

// 触发事件
emit UserRegistered(msg.sender, "张三", block.timestamp);
emit WorkoutLogged(msg.sender, "跑步", 1800);`
    },
    milestone_detection: {
        name: "里程碑检测",
        icon: "🏆",
        unlockAt: 5,
        message: "你完成了里程碑检测！通过条件判断检测用户是否达成特定目标，并触发相应奖励。",
        code: `// 运动次数里程碑
if (totalWorkouts == 10) {
    emit MilestoneAchieved(msg.sender, "10次运动达成！");
} else if (totalWorkouts == 50) {
    emit MilestoneAchieved(msg.sender, "50次运动大师！");
}

// 距离里程碑（跨越检测）
if (totalDistance >= 100000 && totalDistance - distance < 100000) {
    emit MilestoneAchieved(msg.sender, "100公里里程碑！");
}`
    },
    timestamp_usage: {
        name: "时间戳使用",
        icon: "⏰",
        unlockAt: 2,
        message: "你使用了 `block.timestamp`！它记录当前区块的时间戳，用于标记运动记录的时间。",
        code: `WorkoutActivity memory newWorkout = WorkoutActivity({
    activityType: "跑步",
    duration: 1800,
    distance: 5000,
    timestamp: block.timestamp  // 记录运动时间
});`
    },
    onlyRegistered_modifier: {
        name: "onlyRegistered 修饰符",
        icon: "🛡️",
        unlockAt: 1,
        message: "你使用了 `onlyRegistered` 修饰符！它确保只有注册用户才能调用特定函数，保护合约安全。",
        code: `// 定义修饰符
modifier onlyRegistered() {
    require(userProfiles[msg.sender].isRegistered, "User not registered");
    _;  // 继续执行函数
}

// 使用修饰符
function logWorkout(...) public onlyRegistered {
    // 只有注册用户才能执行
}`
    }
};

// ========== Day 11 概念定义 ==========
export const day11ConceptDefinitions = {
    inheritance: {
        name: "合约继承",
        icon: "🧬",
        unlockAt: 1,
        message: "你刚刚体验了合约继承！VaultMaster 通过 `is Ownable` 继承了父合约的所有功能，这是代码复用的核心机制。",
        code: `// 父合约
contract Ownable {
    address private owner;
    // ...
}

// 子合约继承父合约
contract VaultMaster is Ownable {
    // 自动拥有 Ownable 的所有功能
    function withdraw() public onlyOwner {
        // 可以使用继承的 onlyOwner 修饰符
    }
}`
    },
    import_statement: {
        name: "导入语句",
        icon: "📥",
        unlockAt: 2,
        message: "你了解了 `import` 语句！它允许合约引用其他文件中的合约定义，是模块化开发的基础。",
        code: `// 导入外部合约
import "./Ownable.sol";

// 现在可以使用 Ownable 合约了
contract VaultMaster is Ownable {
    // ...
}`
    },
    constructor: {
        name: "构造函数",
        icon: "🏗️",
        unlockAt: 1,
        message: "你刚刚了解了构造函数！它在合约部署时自动执行一次，用于初始化关键状态变量。",
        code: `contract Ownable {
    address private owner;
    
    // 构造函数：部署时自动执行
    constructor() {
        owner = msg.sender;  // 设置部署者为所有者
    }
}`
    },
    private_visibility: {
        name: "私有可见性",
        icon: "🔒",
        unlockAt: 2,
        message: "你了解了 `private` 可见性！它确保变量只能在当前合约内部访问，提供最强的封装保护。",
        code: `contract Ownable {
    // private：只有当前合约可以访问
    address private owner;
    
    // public：任何人都可以访问
    function ownerAddress() public view returns (address) {
        return owner;  // 通过函数间接访问
    }
}`
    },
    event_logging: {
        name: "事件日志",
        icon: "📋",
        unlockAt: 1,
        message: "你触发了事件！事件是合约与前端通信的重要机制，记录关键操作到区块链日志中。",
        code: `// 定义事件
event DepositSuccessful(
    address indexed depositor,
    uint256 amount
);

// 触发事件
function deposit() public payable {
    emit DepositSuccessful(msg.sender, msg.value);
}`
    },
    indexed_parameter: {
        name: "索引参数",
        icon: "🏷️",
        unlockAt: 2,
        message: "你了解了 `indexed` 关键字！它允许前端按特定参数过滤事件日志，提高查询效率。",
        code: `// indexed 参数可以被过滤查询
event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
);

// 前端可以按地址过滤事件
// 例如：查找特定用户的所有转账记录`
    },
    transfer_ownership: {
        name: "所有权转移",
        icon: "🔑",
        unlockAt: 1,
        message: "你刚刚完成了所有权转移！这是合约管理的核心功能，确保合约可以安全地更换管理者。",
        code: `function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Invalid address");
    
    address oldOwner = owner;
    owner = newOwner;
    
    emit OwnershipTransferred(oldOwner, newOwner);
}`
    },
    onlyOwner_modifier: {
        name: "onlyOwner 修饰符",
        icon: "🛡️",
        unlockAt: 1,
        message: "你体验了 `onlyOwner` 修饰符的权限控制！它确保只有合约所有者才能执行敏感操作。",
        code: `// 定义修饰符
modifier onlyOwner() {
    require(msg.sender == owner, "Only owner");
    _;  // 继续执行被修饰的函数
}

// 使用修饰符保护函数
function withdraw() public onlyOwner {
    // 只有所有者可以执行
}`
    }
};

// ========== Day 13 概念定义 ==========
export const day13ConceptDefinitions = {
    constructor_mint: {
        name: "构造函数铸造",
        icon: "🪙",
        unlockAt: 1,
        message: "你了解了构造函数铸造机制！合约部署时，构造函数会自动执行，从 address(0) 铸造代币给部署者。",
        code: `constructor(uint256 _initialSupply){
    // 计算实际总供应量
    totalSupply = _initialSupply * (10 ** decimals);
    // 将所有代币分配给部署者
    balanceOf[msg.sender] = totalSupply;
    // 触发转账事件，from地址为0表示新铸造
    emit Transfer(address(0), msg.sender, _initialSupply);
}`
    },
    zero_address_mint: {
        name: "零地址铸造",
        icon: "📍",
        unlockAt: 1,
        message: "你了解了零地址的特殊含义！在 ERC20 中，Transfer(address(0), to, amount) 表示铸造新代币，Transfer(from, address(0), amount) 表示销毁代币。",
        code: `// 从零地址转出 = 铸造（创建新代币）
emit Transfer(address(0), msg.sender, amount);

// 转入零地址 = 销毁（永久移除代币）
emit Transfer(msg.sender, address(0), amount);`
    },
    internal_function: {
        name: "internal 函数",
        icon: "🔒",
        unlockAt: 2,
        message: "你了解了 internal 函数！它只能在合约内部调用，外部无法直接访问。这是代码封装的重要手段，_transfer 就是典型的内部函数。",
        code: `// internal 函数：只能在合约内部调用
function _transfer(address _from, address _to, uint256 _value) 
    internal virtual {
    // 实际执行转账逻辑
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
    emit Transfer(_from, _to, _value);
}

// public 函数调用 internal 函数
function transfer(address _to, uint256 _value) public returns (bool) {
    _transfer(msg.sender, _to, _value);  // 内部调用
    return true;
}`
    },
    virtual_function: {
        name: "virtual 函数",
        icon: "🧬",
        unlockAt: 3,
        message: "你了解了 virtual 关键字！它允许子合约重写（override）父合约的函数。这是实现 ERC20 扩展（如 ERC20Pausable、ERC20Votes）的基础机制。",
        code: `// 父合约：标记函数可被重写
contract MyToken {
    function _transfer(address _from, address _to, uint256 _value) 
        internal virtual {  // ← virtual 允许重写
        // 基础转账逻辑
    }
}

// 子合约：重写父合约函数
contract MyTokenWithFee is MyToken {
    function _transfer(address _from, address _to, uint256 _value) 
        internal override {  // ← override 重写
        // 自定义逻辑（如收取手续费）
        super._transfer(_from, _to, _value);  // 调用父函数
    }
}`
    }
};

export const getHint = (conceptKey) => {
    const hints = {
        function: "🎉 很棒！现在你了解了函数的作用。继续点击，看看还能发现什么？",
        increment: "🚀 太棒了！你已经掌握了自增操作。再试一次！",
        uint256: "📊 不错！你正在深入了解数据存储。继续探索！",
        contract: "🏆 恭喜！你已经完成了 Day 1 的所有核心概念！你可以查看完整的代码了。",
        string: "📝 不错！你学会了如何存储文本数据。继续探索更多概念！",
        private: "🔒 很好！你理解了访问控制的概念。继续学习！",
        memory: "💾 太棒了！你了解了数据存储位置的重要性。继续前进！",
        view: "👁️ 优秀！你掌握了只读函数的优化技巧。再接再厉！",
        parameters: "📥 很好！你学会了如何让函数接收外部数据。继续探索！",
        returns: "📤 太棒了！你已经完成了 Day 2 的所有核心概念！你可以查看完整的代码了。",
        array: "📋 不错！你学会了使用数组存储多个数据。继续探索！",
        mapping: "🗺️ 很棒！你掌握了映射的用法。再试试添加更多候选人！",
        push: "➕ 太棒了！你已经学会动态添加数据。试试投票功能吧！",
        compound_assignment: "⚡ 优秀！你掌握了复合赋值运算符。继续投票解锁更多概念！",
        constructor: "🏗️ 太棒了！你刚刚部署了一个拍卖合约！构造函数只执行一次，初始化了拍卖物品和结束时间。继续出价吧！",
        msg_sender: "📧 不错！你使用了 `msg.sender` 来记录竞拍者地址。继续出价解锁更多概念！",
        block_timestamp: "⏰ 很棒！你了解了如何使用时间戳来控制拍卖时间。继续探索！",
        require: "✅ 优秀！你掌握了条件检查机制，这是保证合约安全的重要工具！",
        external: "🌐 很好！你使用了 external 函数来节省 Gas。继续出价吧！",
        address_type: "🏠 太棒了！你了解了地址类型，这是区块链交互的核心！继续探索！",
        bool_type: "🔘 优秀！你完成了 Day 4 的所有核心概念！你可以查看完整的代码了！",
        modifier: "🛡️ 太棒了！你刚刚使用了修饰符！这是权限控制的重要工具。继续探索更多功能！",
        zero_address: "⚠️ 不错！你学会了检查零地址，这是防止错误的重要机制！继续前进！",
        return_statement: "↩️ 很棒！你了解了返回语句的用法！继续解锁更多概念吧！",
        address_mapping_balance: "💰 太棒了！你学会了使用地址映射来存储余额！继续探索吧！",
        payable: "💵 很好！你使用了 payable 关键字来接收以太币！继续学习！",
        msg_value: "💳 不错！你了解了 msg.value 的用法，可以获取发送的ETH数量！",
        wei_unit: "⚖️ 太棒了！你了解了以太币的 wei 单位！这是以太坊计价的基础！",
        ether_deposit_withdraw: "🏦 优秀！你完成了 Day 6 的所有核心概念！你可以查看完整的代码了！",
        nested_mapping: "🗂️ 很好！你了解了嵌套映射如何处理复杂关系。继续添加朋友或存款！",
        address_payable: "💸 不错！你知道了 payable 才能让地址收钱。试试记录一笔债务吧！",
        debt_tracking: "📊 优秀！你掌握了如何使用合约记录金融债权关系。尝试还债吧！",
        internal_transfer: "🔄 太棒了！内部记账转账非常节省 Gas。接下来试试真正的转账功能。",
        transfer_method: "📤 了解 transfer() 转账！这是安全但古老的方式。再试试用 call() 转账！",
        call_method: "📡 绝佳！call() 是现代 Solidity 推荐的转账方式。试试提取余额吧！",
        withdraw_pattern: "🏧 恭喜你！安全第一的提现模式是智能合约的基石！你已完成 Day 7 所有核心概念！",
        modifier_onlyOwner: "🛡️ 只有 Owner 能执行此操作！你体验到了 Solidity 中的权限控制。继续打赏解锁！",
        payable_tip: "💰 函数带了 payable 标签就可以收钱啦！试试用不同货币打赏！",
        msg_value_tip: "💸 你付出的每一份钱都存在了 msg.value 里。继续加油！",
        address_balance: "🏦 看到金库里的余额了吗？这正是通过 address(this).balance 查询到的！",
        call_withdraw: "📡 提现成功！call 是目前最推荐的发送 ETH 方式。继续探索！",
        mapping_rates: "💹 汇率表在映射中生效了！你已经掌握了 Day 8 的所有核心概念，点击查看完整代码吧！",
        pure_function: "⚡ 太棒了！你使用了 pure 函数！它不读取也不修改状态，执行快速且不消耗 Gas。继续完成更多运算！",
        view_function: "👁️ 很好！你使用了 view 函数！它可以读取状态但不修改，适合查询操作。继续探索跨合约调用！",
        cross_contract_call: "📡 优秀！你完成了跨合约调用！合约之间可以相互调用，实现功能组合。继续尝试底层 call！",
        interface_call: "🔌 太棒了！你使用了接口方式调用外部合约！这是最常见的跨合约调用方式。继续学习底层 call！",
        low_level_call: "🔧 绝佳！你使用了底层 call 方法！这是最灵活的调用方式。继续探索牛顿迭代法！",
        newton_iteration: "📐 恭喜你了解了牛顿迭代法！Solidity 不支持浮点数，迭代逼近是常用技巧。完成最后挑战！",
        contract_composition: "🧩 恭喜你！你掌握了合约组合！合约可以像乐高积木一样组合复用。你已完成 Day 9 所有核心概念！",
        // ========== Day 10 提示 ==========
        struct_definition: "📦 太棒了！你学会了使用结构体打包数据！👉 下一步：记录一次运动来看看时间戳如何工作！",
        array_in_mapping: "🗂️ 很好！你看到了映射到数组的用法！👉 下一步：查看统计数据来解锁 multiple_mappings！",
        multiple_mappings: "🗺️ 优秀！你了解了多个映射如何协同工作！👉 下一步：更新体重来解锁 storage_keyword！",
        storage_keyword: "💾 太棒了！你了解了 storage 的威力！👉 下一步：继续记录运动，达成里程碑来解锁 milestone_detection！",
        event_logging: "📋 不错！你触发了事件日志！👉 下一步：记录运动来查看运动历史如何存储！",
        milestone_detection: "🏆 恭喜！你达成了里程碑！👉 下一步：查看完整代码来复习所有知识！",
        timestamp_usage: "⏰ 很好！你学会了记录时间戳！👉 下一步：查看运动历史来解锁 array_in_mapping！",
        onlyRegistered_modifier: "🛡️ 太棒了！你了解了修饰符如何保护函数！👉 下一步：记录运动来解锁更多概念！",
        // ========== Day 11 提示 ==========
        inheritance: "🧬 太棒了！你体验了合约继承！VaultMaster 继承了 Ownable 的所有功能！👉 存入 ETH 来学习 import 机制！",
        import_statement: "📥 不错！你了解了导入语句！👉 继续操作来学习事件日志！",
        constructor: "🏗️ 太棒了！你了解了构造函数！👉 查看完整代码来学习 private 可见性！",
        private_visibility: "🔒 优秀！你学会了 private 变量的使用！",
        event_logging: "📋 很好！你触发了事件日志！👉 尝试转移所有权来解锁更多概念！",
        indexed_parameter: "🏷️ 不错！你了解了索引参数！",
        transfer_ownership: "🔑 很好！你了解了所有权转移！👉 尝试以用户身份提取来学习修饰符！",
        onlyOwner_modifier: "🛡️ 太棒了！你了解了 onlyOwner 修饰符！👉 查看完整代码来学习更多！",
        // ========== Day 13 提示 ==========
        constructor_mint: "🪙 欢迎来到 Day 13！你看到的是构造函数首次铸造的代币。注意事件日志中的 Transfer(address(0), ...)",
        zero_address_mint: "📍 address(0) (零地址) 表示新铸造的代币。在 ERC20 中，从零地址转出 = Mint，转入零地址 = Burn",
        internal_function: "🔒 你刚刚调用了 transfer()，它内部调用了 _transfer()。internal 函数只能在合约内部调用，外部无法直接访问",
        virtual_function: "🧬 注意到 _transfer 后面的 virtual 关键字了吗？它允许子合约重写此函数，这是 ERC20 扩展的基础！",
        // ========== Day 16 提示 ==========
        struct_definition: "🏗️ 你了解了结构体定义！PlayerProfile 将 name 和 avatar 组合在一起。👉 设置玩家资料来解锁映射存储！",
        mapping_storage: "🗺️ 你的资料已保存到 mapping！通过键值对高效存储。👉 注册 weapon 插件来学习插件系统！",
        plugin_registration: "🔌 插件注册成功！地址已存入 plugins[key]。👉 点击「调用」执行插件函数！",
        low_level_call: "⚡ 低级别调用成功！使用了 EVM 的 call 指令。👉 查看 ABI 编码可视化！",
        abi_encoding: "🔢 ABI 编码完成！函数选择器是 keccak256 哈希的前4字节。👉 切换 staticcall 模式查询数据！",
        staticcall: "👁️ 静态调用成功！不消耗 Gas 的只读操作。👉 尝试切换到 achievement 插件！",
        dynamic_delegation: "🔄 动态委托系统运行中！一个核心管理多个插件。👉 在不同插件间切换体验互操作！",
        contract_interop: "🌐 合约互操作掌握！多个合约无缝协作。🎉 你已掌握 Day 16 所有核心概念！",
        // ========== Day 18 提示 ==========
        oracle_interface: "🔌 太棒了！你了解了 Chainlink 预言机接口！AggregatorV3Interface 是标准接口。👉 查看 ETH/USD 价格面板学习价格预言机！",
        random_generation: "🎲 太棒了！你看到了伪随机数生成！👉 购买保险来体验价格转换！",
        eth_usd_oracle: "💰 太棒了！你使用了 ETH/USD 价格预言机！注意 Chainlink 返回 8 位小数精度。👉 购买保险体验价格转换！",
        purchase_insurance: "🛡️ 保险购买成功！支付保费获得保障。👉 当干旱发生时申请赔付体验参数化保险！",
        price_conversion: "🔄 太棒了！你了解了价格转换！1e26 = 1e18 × 1e8 抵消 Chainlink 精度。👉 申请赔付体验参数化保险！",
        parametric_payout: "💸 赔付成功！参数化保险自动执行无需审核。👉 了解冷却期机制防止滥用！",
        cooldown_mechanism: "⏱️ 你了解了冷却期机制！24小时内只能索赔一次。👉 快进时间或查看合约余额！",
        contract_balance: "🏦 你查看了合约余额！管理员可提取保险池资金。🎉 你已掌握 Day 18 所有核心概念！",
        // ========== Day 19 提示 ==========
        keccak256_hash: "🔐 你使用了 Keccak256 哈希算法！这是以太坊的标准哈希函数。👉 点击展开签名详情查看 R/S/V 组件！",
        ecdsa_signature: "🎯 你了解了 ECDSA 椭圆曲线签名！这是以太坊的数字签名算法。👉 点击生成签名来体验完整流程！",
        signature_rsv: "📝 你分解了签名的 R/S/V 组件！以太坊签名由 65 字节组成。👉 使用签名参与活动来解锁 ecrecover！",
        eip191_prefix: "📋 你了解了 EIP-191 签名前缀！这是以太坊个人签名的标准。👉 查看参与者列表完成所有概念！",
        ecrecover: "🔓 你使用了 ecrecover 函数！这是签名者恢复的核心。👉 查看参与者列表了解映射存储！",
        require_statement: "⚠️ 你使用了 require 验证语句！这是 Solidity 安全编程的基础。👉 查看参与者列表完成所有概念！",
        mapping_storage: "🗂️ 你使用了映射存储！mapping 是 Solidity 高效的键值对结构。🎉 你已掌握 Day 19 所有核心概念！",
        msg_sender: "👤 你使用了 msg.sender！这是 Solidity 的全局变量，表示当前调用者地址。👉 点击展开签名详情查看 R/S/V 组件！",
        // ========== Day 21 提示 ==========
        ierc721_interface: "🔌 你了解了ERC721标准接口！👉 点击铸造按钮创建你的第一个NFT！",
        mint_function: "🔨 你使用了铸造函数！👉 完成铸造查看计数器如何工作！",
        token_id_counter: "🔢 你了解了代币ID计数器！👉 查询地址余额了解持有情况！",
        token_uri: "🔗 你查看了Token URI！👉 选中一个NFT，尝试转移NFT！",
        balance_of: "📊 你查询了NFT余额！👉 查看代币授权状态了解approve机制！",
        transfer_from: "🔄 你执行了NFT转移！👉 尝试授权其他地址管理你的NFT！",
        approve_mechanism: "🔑 你使用了授权机制！👉 尝试设置操作员授权！",
        approval_for_all: "👥 你设置了操作员授权！👉 尝试使用安全转移功能！",
        safe_transfer: "🛡️ 你使用了安全转移！🎉 恭喜完成Day21所有学习！"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

export const getConceptExplanationHint = (conceptKey) => {
    const hints = {
        function: "📖 这是函数的基本概念，它是智能合约的基本构建模块。",
        increment: "📖 自增操作是编程中常见的操作，用于快速增加数值。",
        uint256: "📖 uint256 是 Solidity 中最常用的整数类型，了解它很重要。",
        contract: "📖 智能合约是区块链上的自动执行代码，理解它的结构很关键。",
        string: "📖 string 类型用于存储文本数据，是智能合约中常用的数据类型之一。",
        private: "📖 private 关键字限制变量的访问范围，提高合约的安全性。",
        memory: "📖 memory 数据位置用于临时存储，只在函数执行期间存在。",
        view: "📖 view 函数不修改状态，不消耗 Gas，是优化合约性能的重要方法。",
        parameters: "📖 函数参数让函数能够接收外部数据，使函数更加灵活和可复用。",
        returns: "📖 returns 关键字定义函数返回值，让函数能够向调用者返回结果。",
        array: "📖 数组是存储多个相同类型数据的容器，在 Solidity 中广泛使用。",
        mapping: "📖 映射是 Solidity 中的键值对存储结构，通过键快速查找对应的值。",
        push: "📖 push 方法是数组的常用操作，可以在数组末尾动态添加元素。",
        compound_assignment: "📖 复合赋值运算符将运算和赋值结合在一起，使代码更加简洁。",
        constructor: "📖 构造函数只在合约部署时执行一次，用于初始化合约的状态变量。",
        msg_sender: "📖 msg.sender 表示当前调用合约的地址，是区块链交互的核心。",
        block_timestamp: "📖 block.timestamp 返回当前区块的时间戳，常用于时间相关的逻辑。",
        require: "📖 require 语句在条件不满足时回滚交易，是保证合约安全的重要机制。",
        external: "📖 external 函数只能从合约外部调用，比 public 更节省 Gas。",
        address_type: "📖 address 类型存储以太坊地址，是区块链交互的核心数据类型。",
        bool_type: "📖 bool 类型只有 true 或 false 两个值，用于标记状态。",
        modifier: "📖 修饰符用于为函数添加前置条件检查，是权限控制的重要机制。",
        zero_address: "📖 零地址 address(0) 表示一个无效的地址，通常用于检查地址参数是否有效。",
        return_statement: "📖 return 语句让函数返回指定的值给调用者，是函数输出结果的方式。",
        address_mapping_balance: "📖 地址映射 mapping(address => uint256) 是存储用户资产的核心数据结构，通过地址快速查找对应的余额。",
        payable: "📖 payable 关键字让函数能够接收以太币，这是处理资金交易的关键特性。",
        msg_value: "📖 msg.value 表示调用函数时发送的以太币数量（以wei为单位），是获取转账金额的标准方式。",
        wei_unit: "📖 wei 是以太币的最小单位，1 ETH = 10^18 wei，这是以太坊计价的基础单位。",
        ether_deposit_withdraw: "📖 存取逻辑包括检查余额、增减余额、验证输入，这是任何金融合约的基础。",
        nested_mapping: "📖 嵌套映射 mapping(A => mapping(B => C)) 允许你在 Solidity 中创建像多维数组或字典中嵌套字典的复杂数据结构。",
        address_payable: "📖 payable 地址类型拥有 transfer 和 call 方法来发送 Ether。没有 fallback 且非 payable 的地址无法接收以太币。",
        debt_tracking: "📖 债务追踪展示了区块链账本的不变性和透明性，确保每一笔债权和债务都在链上清晰可查的特性。",
        internal_transfer: "📖 内部账本系统(Internal Accounting)只改变合约内存的数字而不进行链上交易转账，是处理多高频微支付的最佳实操。",
        transfer_method: "📖 .transfer() 将转账可用 gas 固定为 2300 防止重入，但当目标接收方智能合约的 fallback 逻辑超过一定 gas 时会导致资金卡死。",
        call_method: "📖 .call() 提供低级别的外部调用功能，转账时能够转发所有剩余 gas 或自定义数量的 gas 以保证外部操作能顺利执行并返回回调状态。",
        withdraw_pattern: "📖 提现优于发送。要求用户主动调用 withdraw()，避免了遍历用户数组发钱（可能超出 block gas 限制）以及转账失败阻塞整个合约的风险。",
        modifier_onlyOwner: "📖 修饰符（Modifier）允许你在不重复编写核心检查逻辑的情况下，重用访问控制代码。`_` 符号代表了目标函数体的执行位置。",
        payable_tip: "📖 `payable` 是一个函数可见性/状态修饰符。如果没有它，任何尝试向该函数发送 Ether 的交易都会被以太坊虚拟机拒绝并回滚。",
        msg_value_tip: "📖 `msg.value` 是当前交易附带的以太币数量，以 wei 为单位。它是智能合约处理实时支付的桥梁。",
        address_balance: "📖 合约不仅可以操作别人的钱，还可以管理属于它自己的钱。`address(this).balance` 让你能实时掌控合约金库的‘水位’。",
        call_withdraw: "📖 `.call()` 是一个底层原语。在转账时，它能够处理复杂的 Fallback 逻辑，并明确返回一个成功/失败的布尔值，比旧的 `transfer` 更具鲁活性。",
        mapping_rates: "📖 虽然以太坊没有内置汇率，但我们可以通过合约内部的映射来手动维护一组兑换比例，从而实现'打赏 1 美元 = 支付 X 数量 ETH'的功能。",
        pure_function: "📖 pure 函数承诺不读取也不修改区块链的状态变量。这意味着它的执行结果完全取决于输入参数，可以在本地快速计算，不需要消耗 Gas。",
        view_function: "📖 view 函数可以读取状态变量但不修改它们。由于不修改状态，view 函数也可以在本地执行，不消耗 Gas，适合用于查询操作。",
        cross_contract_call: "📖 跨合约调用是 Solidity 的核心特性之一。通过合约地址，一个合约可以调用另一个合约的函数，实现功能的组合和复用，就像乐高积木一样。",
        interface_call: "📖 接口方式调用是最常用的跨合约调用方法。通过创建外部合约的接口实例，可以像调用本地函数一样调用外部合约，代码清晰易读。",
        low_level_call: "📖 底层 call 方法提供了最大的灵活性。它通过 abi.encodeWithSignature 编码函数调用，可以调用任何函数，即使接口未知。但使用起来更复杂，需要手动处理返回值。",
        newton_iteration: "📖 牛顿迭代法是一种快速逼近方程根的算法。在 Solidity 中，由于不支持浮点数运算，我们使用整数运算通过多次迭代来逼近真实值。限制迭代次数可以防止 Gas 耗尽。",
        contract_composition: "📖 合约组合是 Solidity 的重要设计理念。通过将功能拆分到多个合约，可以实现代码复用、降低复杂度、提高可维护性。这是构建复杂 DApp 的基础。",
        // ========== Day 10 解释提示 ==========
        struct_definition: "📖 `struct` 结构体允许你定义自定义的数据类型，将多个不同类型的变量打包在一起。这是组织复杂数据的有效方式，让代码更加清晰和易于维护。",
        array_in_mapping: "📖 Solidity 允许将映射指向数组，如 `mapping(address => WorkoutActivity[])`。这样每个地址都有一个动态数组，非常适合存储用户的历史记录、交易列表等一对多的数据关系。",
        multiple_mappings: "📖 在实际应用中，经常使用多个 mapping 来存储不同维度的数据。比如一个 mapping 存用户资料，另一个存用户余额。通过同一个 key（如用户地址）可以关联访问多个数据结构。",
        storage_keyword: "📖 `storage` 和 `memory` 是 Solidity 中两个重要的数据位置关键字。`storage` 变量永久存储在区块链状态中，而 `memory` 变量只在函数执行期间临时存在。使用 `storage` 引用可以直接修改状态变量，节省 Gas。",
        event_logging: "📖 事件（Event）是 Solidity 的日志机制。通过 `emit` 触发事件，数据会被记录在区块链的交易日志中。前端可以监听事件来实现实时通知、记录历史等功能，事件是 DApp 前后端通信的重要桥梁。",
        milestone_detection: "📖 里程碑检测是游戏化应用的核心机制。通过条件判断（如 `if (count == 10)`）检测用户是否达成特定目标，并触发相应奖励或通知。这能激励用户持续使用产品。",
        timestamp_usage: "📖 `block.timestamp` 是当前区块的时间戳（Unix 时间，秒）。它常用于记录事件发生时间、设置时间限制、计算时间差等。注意它由矿工设置，存在约15秒的误差，不应用于精确计时。",
        onlyRegistered_modifier: "📖 修饰符（Modifier）是 Solidity 的复用机制，用于在函数执行前添加前置条件检查。`onlyRegistered` 确保只有满足条件的用户（已注册）才能调用函数。这简化了代码，避免了在每个函数中重复写检查逻辑。"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 11 概念解释提示 ==========
export const getDay11ExplanationHint = (conceptKey) => {
    const hints = {
        inheritance: "📖 合约继承是 Solidity 的核心特性之一。通过 `contract VaultMaster is Ownable`，子合约可以继承父合约的所有状态变量和函数，实现代码复用和模块化设计。",
        import_statement: "📖 `import` 语句用于导入其他合约文件，让你可以在当前合约中使用外部定义的合约。这是实现合约组合和代码复用的基础。",
        constructor: "📖 构造函数 `constructor()` 在合约部署时自动执行一次，用于初始化合约的状态变量。在 Ownable 中，它将合约部署者设置为初始所有者。",
        private_visibility: "📖 `private` 可见性修饰符表示变量只能在当前合约内部访问，即使是子合约也无法直接访问。这提供了最强的封装性，保护敏感数据。",
        event_logging: "📖 事件（Event）用于记录重要的合约操作到区块链日志中。前端可以监听事件来实现实时通知。`DepositSuccessful` 和 `WithdrawSuccessful` 记录了资金流动。",
        indexed_parameter: "📖 `indexed` 关键字标记事件参数，允许前端按该参数过滤和搜索事件日志。这在处理大量事件时非常有用，可以快速找到特定地址相关的事件。",
        transfer_ownership: "📖 `transferOwnership()` 函数实现了合约所有权的转移。只有当前所有者可以调用此函数，并且通常会检查新地址是否有效（非零地址）。",
        onlyOwner_modifier: "📖 `onlyOwner` 修饰符是权限控制的核心机制。它检查 `msg.sender` 是否等于 `owner`，如果不是则回滚交易。这是保护敏感操作（如提款）的标准做法。"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 12 概念定义 ==========
export const day12ConceptDefinitions = {
    erc20_standard: {
        name: "ERC20 标准",
        icon: "🪙",
        unlockAt: 1,
        message: "你了解了 ERC20 代币标准！它是以太坊上最通用的代币规范，定义了代币的基本功能接口。",
        code: `// ERC20 标准接口
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}`
    },
    mapping_nested: {
        name: "嵌套映射",
        icon: "🗂️",
        unlockAt: 2,
        message: "你发现了嵌套映射 mapping(address => mapping(address => uint256))！这是存储授权额度的核心数据结构。",
        code: `// 嵌套映射：记录每个地址授权给其他地址的额度
mapping(address => mapping(address => uint256)) public allowance;

// 示例：Alice 授权 Carol 使用 500 COM
allowance[Alice][Carol] = 500;  // Carol 可以使用 Alice 的 500 COM`
    },
    event: {
        name: "事件日志",
        icon: "📋",
        unlockAt: 3,
        message: "你触发了事件！Transfer 和 Approval 事件记录了代币的转移和授权操作，前端可以监听这些事件。",
        code: `// 定义事件
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);

// 触发事件
emit Transfer(msg.sender, _to, _value);
emit Approval(msg.sender, _spender, _value);`
    },
    transfer: {
        name: "转账函数",
        icon: "💸",
        unlockAt: 4,
        message: "你使用了 transfer 函数！它是 ERC20 最核心的功能，允许用户将自己的代币转给他人。",
        code: `// 转账函数：调用者将自己的代币转给他人
function transfer(address _to, uint256 _value) public returns (bool) {
    require(balanceOf[msg.sender] >= _value, "Not enough balance");
    _transfer(msg.sender, _to, _value);
    return true;
}`
    },
    approve: {
        name: "授权函数",
        icon: "✅",
        unlockAt: 5,
        message: "你使用了 approve 函数！它允许你授权他人使用你的代币，这是 DeFi 应用的基础机制。",
        code: `// 授权函数：允许 spender 使用调用者的代币
function approve(address _spender, uint256 _value) public returns (bool) {
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
}`
    },
    allowance: {
        name: "授权额度",
        icon: "🔍",
        unlockAt: 6,
        message: "你查询了 allowance！它返回被授权者可以使用的代币数量，是授权机制的重要组成部分。",
        code: `// 查询授权额度
function allowance(address _owner, address _spender) 
    public view returns (uint256) {
    return allowance[_owner][_spender];
}

// 使用场景：检查 Carol 还能使用 Alice 多少代币
uint256 remaining = allowance(Alice, Carol);  // 返回剩余额度`
    },
    transferFrom: {
        name: "代转账函数",
        icon: "🔄",
        unlockAt: 7,
        message: "你使用了 transferFrom 函数！它允许被授权者代替他人转账，实现了'第三方代付'功能。",
        code: `// 代转账函数：被授权者从他人账户转账
function transferFrom(address _from, address _to, uint256 _value) 
    public returns (bool) {
    require(balanceOf[_from] >= _value, "Not enough balance");
    require(allowance[_from][msg.sender] >= _value, "Allowance too low");
    
    allowance[_from][msg.sender] -= _value;  // 减少授权额度
    _transfer(_from, _to, _value);
    return true;
}`
    }
};

// ========== Day 12 提示 ==========
export const getDay12Hint = (conceptKey) => {
    const hints = {
        erc20_standard: "🪙 太棒了！你了解了 ERC20 代币标准！这是以太坊上最通用的代币规范。👉 查询 Alice 余额来学习 mapping 存储机制！",
        mapping_nested: "🗂️ 优秀！你了解了嵌套映射！这是 ERC20 授权机制的核心数据结构。👉 转账给 Bob 来学习事件和转账函数！",
        event: "📋 很好！你触发了事件日志！👉 继续探索更多功能！",
        transfer: "💸 太棒了！你使用了 transfer 函数！👉 授权给 Carol 来学习授权机制！",
        approve: "✅ 很好！你使用了 approve 函数！👉 查询 allowance 来学习授权额度查询！",
        allowance: "🔍 优秀！你了解了授权额度查询！👉 切换到 Carol 执行代转账来学习 transferFrom！",
        transferFrom: "🔄 太棒了！你使用了 transferFrom 函数！🎉 你已掌握 ERC20 全部核心功能！"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 13 概念解释提示 ==========
export const getDay13ExplanationHint = (conceptKey) => {
    const hints = {
        constructor_mint: "📖 构造函数铸造是 ERC20 代币的常见模式。合约部署时，构造函数自动执行，创建所有代币并分配给部署者。Transfer(address(0), ...) 事件表示这是铸造操作。",
        zero_address_mint: "📖 零地址 address(0) 在 ERC20 中有特殊含义。Transfer 事件中 from=address(0) 表示铸造（创建新代币），to=address(0) 表示销毁（移除代币）。这是行业标准约定。",
        internal_function: "📖 internal 是 Solidity 的可见性修饰符之一。与 public/external 不同，internal 函数只能在当前合约内部调用，不能从外部访问。这是代码封装的重要手段，_transfer 就是典型的内部辅助函数。",
        virtual_function: "📖 virtual 关键字标记函数可以被继承合约重写（override）。这是实现可扩展 ERC20（如带手续费的代币、可暂停代币）的基础。子合约使用 override 关键字重写，并用 super 调用父合约函数。"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 12 概念解释提示 ==========
export const getDay12ExplanationHint = (conceptKey) => {
    const hints = {
        erc20_standard: "📖 ERC20 是以太坊上最常用的代币标准，定义了代币的基本功能接口，包括转账、授权、查询余额等。所有符合 ERC20 标准的代币都可以在支持该标准的钱包和交易所中使用。",
        mapping_nested: "📖 嵌套映射 mapping(address => mapping(address => uint256)) 是 ERC20 中存储授权额度的核心数据结构。外层映射的 key 是代币持有者，内层映射的 key 是被授权者，value 是授权额度。",
        event: "📖 事件（Event）是 Solidity 的日志机制。ERC20 定义了 Transfer 和 Approval 两个标准事件，分别记录代币转移和授权操作。前端可以监听这些事件来实时更新界面。",
        transfer: "📖 transfer 函数是 ERC20 最核心的功能，允许代币持有者将自己的代币转给他人。函数会检查余额是否充足，然后更新双方余额并触发 Transfer 事件。",
        approve: "📖 approve 函数实现了授权机制，允许代币持有者授权他人使用自己的代币。这在 DeFi 应用中非常重要，比如授权 DEX 使用你的代币进行交易。",
        allowance: "📖 allowance 函数用于查询授权额度，返回被授权者还可以使用持有者的代币数量。在执行 transferFrom 之前，通常需要先检查 allowance 是否充足。",
        transferFrom: "📖 transferFrom 函数实现了代转账功能，允许被授权者代替持有者转账。这是 ERC20 的高级功能，常用于需要第三方代为执行转账的场景，如自动扣款、代理交易等。"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 14 概念定义 ==========
export const day14ConceptDefinitions = {
    interface_definition: {
        name: "接口定义",
        icon: "🔌",
        unlockAt: 1,
        message: "你了解了接口！接口定义了合约必须实现的功能规范，是实现多态和解耦的基础。",
        code: `// IDepositBox.sol - 定义存款盒的标准接口
interface IDepositBox {
    function storeSecret(string calldata secret) external;
    function getSecret() external view returns (string memory);
    function transferOwnership(address newOwner) external;
    function getBoxType() external view returns (string memory);
    function getOwner() external view returns (address);
}`
    },
    abstract_contract: {
        name: "抽象合约",
        icon: "🎭",
        unlockAt: 2,
        message: "你了解了抽象合约！抽象合约可以包含未实现的函数（纯虚函数），不能被直接部署，只能被继承。",
        code: `// BaseDepositBox.sol - 抽象基础合约
abstract contract BaseDepositBox is IDepositBox {
    string internal secret;
    address internal owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    // 纯虚函数：必须由子合约实现
    function getBoxType() public view virtual returns (string memory);
}`
    },
    inheritance: {
        name: "合约继承",
        icon: "🧬",
        unlockAt: 3,
        message: "你体验了合约继承！BasicDepositBox 继承了 BaseDepositBox 的所有功能，无需额外代码。",
        code: `// BasicDepositBox.sol - 简单继承
contract BasicDepositBox is BaseDepositBox {
    // 只继承父合约，不添加新功能
    
    function getBoxType() public view override returns (string memory) {
        return "Basic";
    }
}`
    },
    override_keyword: {
        name: "重写关键字",
        icon: "📝",
        unlockAt: 4,
        message: "你使用了 override 关键字！子合约使用 override 重写父合约的虚函数，实现自定义行为。",
        code: `// 父合约中的虚函数
function getBoxType() public view virtual returns (string memory);

// 子合约重写
function getBoxType() public view override returns (string memory) {
    return "Premium";  // 自定义实现
}`
    },
    virtual_function: {
        name: "虚函数",
        icon: "🔮",
        unlockAt: 5,
        message: "你了解了 virtual 关键字！它标记函数可以被继承合约重写，是实现多态的基础。",
        code: `// 父合约：标记函数可被重写
function storeSecret(string calldata _secret) 
    public virtual onlyOwner {
    secret = _secret;
}

// 子合约：重写并扩展功能
function storeSecret(string calldata _secret) 
    public override onlyOwner {
    // 自定义逻辑...
    secret = _secret;
}`
    },
    super_keyword: {
        name: "父类调用",
        icon: "⬆️",
        unlockAt: 6,
        message: "你使用了 super 关键字！super 调用父合约的函数，在重写时复用父类的逻辑。",
        code: `// TimeLocked 重写 getSecret
function getSecret() public view override onlyOwner timeUnlocked 
    returns (string memory) {
    // 可以在这里添加自定义逻辑
    return super.getSecret();  // 调用父合约的实现
}`
    },
    modifier_combination: {
        name: "修饰器组合",
        icon: "🔗",
        unlockAt: 7,
        message: "你体验了修饰器组合！多个修饰器可以组合使用，函数必须同时满足所有条件才能执行。",
        code: `// 修饰器组合：同时检查所有者和时间
function getSecret() public view 
    onlyOwner           // 检查1：必须是所有者
    timeUnlocked        // 检查2：必须已解锁
    returns (string memory) {
    return secret;
}`
    },
    factory_pattern: {
        name: "工厂模式",
        icon: "🏭",
        unlockAt: 8,
        message: "你体验了工厂模式！VaultManager 负责创建和管理所有存款盒，是创建型设计模式的经典应用。",
        code: `// VaultManager.sol - 工厂合约
contract VaultManager {
    function createBasicBox() public returns (address) {
        BasicDepositBox newBox = new BasicDepositBox();
        allBoxes.push(address(newBox));
        userBoxes[msg.sender].push(address(newBox));
        return address(newBox);
    }
}`
    },
    metadata_storage: {
        name: "元数据存储",
        icon: "🏷️",
        unlockAt: 9,
        message: "你使用了元数据功能！Premium 版本可以存储额外信息，展示了继承扩展的实际应用。",
        code: `// PremiumDepositBox - 扩展功能
contract PremiumDepositBox is BaseDepositBox {
    string private metadata;  // 额外状态变量
    
    function setMetadata(string calldata _metadata) public onlyOwner {
        metadata = _metadata;
    }
    
    function getMetadata() public view onlyOwner returns (string memory) {
        return metadata;
    }
}`
    },
    time_lock: {
        name: "时间锁定",
        icon: "⏰",
        unlockAt: 10,
        message: "你创建了时间锁定存款盒！解锁前无法取出秘密，展示了修饰器在权限控制中的强大作用。",
        code: `// TimeLockedDepositBox - 时间锁
contract TimeLockedDepositBox is BaseDepositBox {
    uint256 private unlockTime;
    
    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Still locked");
        _;
    }
    
    function getSecret() public view 
        override onlyOwner timeUnlocked returns (string memory) {
        return secret;
    }
}`
    }
};

// ========== Day 15 概念定义 ==========
export const day15ConceptDefinitions = {
    compact_datatype: {
        name: "紧凑数据类型",
        icon: "📦",
        unlockAt: 1,
        message: "你了解了紧凑数据类型！uint8、uint32 等小整数类型相比 uint256 可以节省大量存储空间和 Gas。",
        code: `// 使用紧凑数据类型优化存储
uint8 public proposalCount;       // 只占 1 字节 (0-255)
uint32 public voteCount;          // 只占 4 字节 (0-42亿)
// 相比 uint256 的 32 字节，节省了大量存储！`
    },
    uint8_uint32: {
        name: "小整数类型",
        icon: "🔢",
        unlockAt: 2,
        message: "你了解了 uint8 和 uint32！它们分别只需 1 字节和 4 字节，远小于 uint256 的 32 字节。",
        code: `// 紧凑整数类型对比
uint8  a;  // 1 字节:  0 - 255
uint16 b;  // 2 字节:  0 - 65535
uint32 c;  // 4 字节:  0 - 42亿
uint256 d; // 32 字节: 0 - 超大数字

// 根据需求选择合适的类型，节省 Gas！`
    },
    bytes32_string: {
        name: "bytes32 vs string",
        icon: "📝",
        unlockAt: 3,
        message: "你了解了 bytes32 和 string 的区别！bytes32 使用固定存储，更节省 Gas，适合存储短文本和哈希值。",
        code: `// bytes32 vs string 对比
string public name;           // 动态长度，存储成本高
bytes32 public proposalHash;  // 固定 32 字节，更省 Gas

// 对于固定长度的短文本，bytes32 更优！`
    },
    storage_optimization: {
        name: "存储优化",
        icon: "💾",
        unlockAt: 4,
        message: "你体验了存储优化！通过使用紧凑数据类型和合理的数据结构，可以大幅降低合约的存储成本。",
        code: `// 存储优化技巧
// 1. 使用最小够用的整数类型
uint8 count;  // 而非 uint256

// 2. 将多个小变量打包到同一槽位
uint8 a;  // 槽位 1 (前 1 字节)
uint8 b;  // 槽位 1 (第 2 字节)
address c;  // 槽位 1 (后 20 字节)

// 3. 使用位运算存储布尔数组
uint256 flags;  // 可存储 256 个布尔值`
    },
    bit_operation: {
        name: "位运算技巧",
        icon: "⚡",
        unlockAt: 5,
        message: "你了解了位运算的强大之处！通过位运算，1 个 uint256 可以存储 256 个提案的投票状态，节省约 40% Gas！",
        code: `// 位运算存储投票状态
uint256 public voterData;  // 选民的投票位图

// 检查是否对提案 n 投票
uint256 mask = 1 << n;
bool hasVoted = (voterData & mask) != 0;

// 记录投票
voterData = voterData | mask;  // 设置对应位为 1

// 1 个 uint256 存储 256 个提案状态！`
    },
    mapping_storage: {
        name: "映射存储",
        icon: "🗺️",
        unlockAt: 6,
        message: "你了解了映射的高效存储！mapping 是 Solidity 中最常用的数据结构，通过哈希表实现快速查找。",
        code: `// 映射存储投票记录
mapping(address => uint256) public voterRegistry;
// 地址 → 投票位图

mapping(uint256 => uint32) public proposalVotes;
// 提案ID → 投票数

// 映射提供 O(1) 时间复杂度的查找！`
    },
    mask_check: {
        name: "掩码检查",
        icon: "🎭",
        unlockAt: 7,
        message: "你了解了掩码检查的机制！通过与运算，可以快速检查某个位是否已设置，防止重复投票。",
        code: `// 掩码检查防止重复投票
uint256 mask = 1 << proposalId;
uint256 voterData = voterRegistry[msg.sender];

// 检查是否已投票
if ((voterData & mask) != 0) {
    revert("Already voted");
}

// 位运算检查高效且节省 Gas！`
    },
    timestamp_block: {
        name: "时间戳使用",
        icon: "⏰",
        unlockAt: 8,
        message: "你了解了 block.timestamp 的使用！它提供了当前区块的时间戳，常用于实现时间锁和投票截止。",
        code: `// 使用 block.timestamp 实现投票时间窗口
uint256 public startTime;
uint256 public duration;

modifier withinDeadline() {
    require(
        block.timestamp >= startTime &&
        block.timestamp <= startTime + duration,
        "Voting closed"
    );
    _;
}`
    },
    event_logging: {
        name: "事件日志",
        icon: "📋",
        unlockAt: 9,
        message: "你了解了事件日志的作用！事件记录在链上日志中，可供链下应用索引和监听，是实现前端通知的基础。",
        code: `// 事件记录提案状态变化
event ProposalCreated(
    uint256 indexed id,
    string name,
    uint256 endTime
);

event Voted(
    address indexed voter,
    uint256 indexed proposalId
);

// indexed 参数可被链下高效检索！`
    }
};

// ========== Day 15 提示 ==========
export const getDay15Hint = (conceptKey) => {
    const hints = {
        compact_datatype: "📦 太棒了！你了解了紧凑数据类型优化！uint8、uint32 相比 uint256 节省大量存储！👆 点击上方「存储可视化」区域学习更多！",
        uint8_uint32: "🔢 优秀！你了解了 uint8 和 uint32！它们分别只需 1 字节和 4 字节，远小于 uint256 的 32 字节！👝 创建提案查看 bytes32！",
        bytes32_string: "📝 很好！你了解了 bytes32 vs string！bytes32 固定 32 字节，比动态 string 更省 Gas！👝 继续创建提案或尝试投票学习位运算！",
        storage_optimization: "💾 太棒了！你体验了存储优化！通过紧凑数据类型和合理结构，大幅降低存储成本！⚡ 现在尝试投票来学习位运算！",
        bit_operation: "⚡ 太棒了！你了解了位运算的强大！1 个 uint256 存储 256 个投票状态，节省约 40% Gas！🗺️ 映射高效存储选民数据！⏰ 使用时间戳验证投票窗口！👉 尝试重复投票体验掩码检查！",
        mapping_storage: "🗺️ 优秀！你了解了映射的高效存储！mapping 通过哈希表实现 O(1) 查找，是 Solidity 最常用的数据结构！👉 继续探索其他功能！",
        mask_check: "🎭 很好！你体验了掩码检查！通过与运算快速检查位状态，防止重复投票！👉 等待提案结束执行提案学习事件日志！",
        timestamp_block: "⏰ 不错！你了解了 block.timestamp 的使用！它提供当前区块时间戳，用于实现时间锁和投票截止！👉 尝试重复投票或执行提案！",
        event_logging: "📋 恭喜！你了解了事件日志！事件记录在链上日志中，可供链下应用索引和监听！🎉 你已掌握 Day 15 所有核心概念！"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 15 概念解释提示 ==========
export const getDay15ExplanationHint = (conceptKey) => {
    const hints = {
        compact_datatype: "📖 紧凑数据类型是 Solidity Gas 优化的基础。uint8 只占 1 字节（存储范围 0-255），uint32 只占 4 字节（0-42亿），而 uint256 占 32 字节。根据数据范围选择最小够用的类型，可以显著降低存储成本。",
        uint8_uint32: "📖 uint8、uint16、uint32 等小整数类型相比 uint256 可以节省大量存储空间。当变量值范围有限时，应该优先使用这些紧凑类型。例如：提案数量（uint8）、投票数（uint32）都不需要 uint256 的巨大范围。",
        bytes32_string: "📖 bytes32 是固定长度的字节数组，始终占用 32 字节。string 是动态长度，存储成本更高且引入额外的 Gas 消耗。对于固定长度的短文本（如提案名称、哈希值），bytes32 是更优的选择。",
        storage_optimization: "📖 存储优化是智能合约 Gas 优化的核心。技巧包括：1. 使用最小够用的整数类型（uint8 而非 uint256）；2. 将多个小变量打包到同一存储槽位；3. 使用位运算存储布尔数组。这些优化可节省 30-50% 的存储成本。",
        bit_operation: "📖 位运算利用整数类型的二进制位存储多个布尔值。1 个 uint256 有 256 个位，可以存储 256 个布尔状态（如是否对某提案投票）。相比使用 mapping(uint256 => bool)，位运算节省约 40% 的 Gas。关键操作：左移(1<<n)生成掩码、与(&)检查、或(|)设置。",
        mapping_storage: "📖 mapping 是 Solidity 的哈希表实现，提供 O(1) 时间复杂度的查找。mapping(address => uint256) 存储地址到数据的映射，mapping(uint256 => uint32) 存储索引到数据的映射。mapping 是状态变量最常用的数据结构，高效且灵活。",
        mask_check: "📖 掩码（Mask）是位运算的核心概念。掩码是一个二进制数，只有特定位为 1。通过 & 运算检查位：(data & mask) != 0 表示该位已设置。通过 | 运算设置位：data | mask 将对应位设为 1。这种方法快速且节省 Gas。",
        timestamp_block: "📖 block.timestamp 是当前区块的时间戳（秒级）。它由矿工/验证者提供，可能有少许偏差（几秒到几分钟），但适合大多数场景。常用于实现时间锁、投票截止、合约到期等需要时间判断的功能。",
        event_logging: "📖 事件（Event）是 Solidity 的日志机制，记录在链上日志中（不占用状态存储）。事件可以有 indexed 参数（最多 3 个），可被链下应用高效检索。事件是实现前端通知、链下索引、历史记录查询的基础，是 DApp 交互的关键。"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 14 提示 ==========
export const getDay14Hint = (conceptKey) => {
    const hints = {
        interface_definition: "🔌 欢迎来到 Day 14！你了解了接口定义 - 它规定了所有存款盒必须实现的功能。👉 创建任意存款盒来解锁抽象合约！",
        abstract_contract: "🎭 太棒了！你了解了抽象合约 - 它实现了通用功能但不能直接部署。👉 创建 Basic 存款盒来学习合约继承！",
        inheritance: "🧬 优秀！你体验了合约继承！BasicDepositBox 继承了 BaseDepositBox 的所有功能。👉 创建 Premium 或 TimeLocked 来学习 override！",
        override_keyword: "📝 很好！你使用了 override 关键字重写父合约函数。👉 创建 TimeLocked 存款盒来学习 virtual 和修饰器组合！",
        virtual_function: "🔮 太棒了！你了解了 virtual 关键字 - 它允许子合约重写父函数。👉 在锁定期间尝试取秘密来体验修饰器组合！",
        super_keyword: "⬆️ 优秀！你使用了 super 调用父合约函数。👉 创建第2个存款盒来体验工厂模式！",
        modifier_combination: "🔗 太棒了！你体验了修饰器组合 - 需要同时满足 onlyOwner 和 timeUnlocked！👉 创建 Premium 存款盒来学习元数据存储！",
        factory_pattern: "🏭 优秀！你体验了工厂模式！VaultManager 负责创建和管理所有存款盒。👉 转移所有权并更新记录来完成体验！",
        metadata_storage: "🏷️ 很好！你使用了元数据功能！Premium 版本可以存储额外信息。👉 查看完整代码来复习所有知识点！",
        time_lock: "⏰ 太棒了！你创建了时间锁定存款盒！解锁前无法取出秘密。🎉 你已掌握抽象合约、接口与工厂模式！",
        store_secret: "🔐 太棒了！你成功存入了秘密！Secret 已被安全存储在合约中。👉 尝试取出秘密来体验访问控制！",
        get_secret: "🔓 不错！你取出了秘密！只有所有者才能访问存储的秘密。👉 尝试设置元数据或创建更多存款盒！",
        transfer_ownership: "🔑 很好！你转移了存款盒的所有权！新的所有者现在可以管理这个存款盒。👉 切换到新所有者完成转移流程！"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 14 概念解释提示 ==========
export const getDay14ExplanationHint = (conceptKey) => {
    const hints = {
        interface_definition: "📖 接口（Interface）是 Solidity 中定义合约规范的方式。它只声明函数签名，不包含实现。任何实现该接口的合约都必须提供所有函数的具体实现。接口实现了多态和解耦，让不同的合约可以以统一的方式交互。",
        abstract_contract: "📖 抽象合约（Abstract Contract）是不能被直接部署的合约，它通常包含一个或多个纯虚函数（没有实现的函数）。抽象合约用于定义子合约必须实现的接口，同时提供一些通用的实现代码，是代码复用的重要机制。",
        inheritance: "📖 合约继承是 Solidity 的核心特性之一。通过 `contract Child is Parent`，子合约可以继承父合约的所有状态变量和函数。继承实现了代码复用，让开发者可以基于现有合约构建更复杂的功能。",
        override_keyword: "📖 override 关键字用于显式声明子合约重写了父合约的虚函数。从 Solidity 0.6.0 开始，重写函数必须使用 override 关键字，这提高了代码的可读性和安全性，防止意外重写。",
        virtual_function: "📖 virtual 关键字标记函数可以被继承合约重写。父合约的函数默认不能被重写，必须显式标记为 virtual。这是 Solidity 的设计选择，防止意外的函数重写导致安全问题。",
        super_keyword: "📖 super 关键字用于调用父合约的函数。在重写函数时，super 让你可以复用父类的逻辑，然后添加或修改特定行为。这在需要扩展而非完全替换父类功能时非常有用。",
        modifier_combination: "📖 多个修饰器可以组合使用，函数必须同时满足所有修饰器的条件才能执行。修饰器按声明顺序执行，每个修饰器的 `_` 代表被修饰函数的代码。这是实现复杂权限控制的有效方式。",
        factory_pattern: "📖 工厂模式是一种创建型设计模式，使用专门的工厂合约来创建和管理其他合约。VaultManager 就是工厂合约，它负责创建存款盒并追踪所有权。工厂模式实现了创建逻辑与使用逻辑的分离。",
        metadata_storage: "📖 元数据存储展示了继承扩展的实际应用。PremiumDepositBox 在继承 BaseDepositBox 的基础上，添加了 metadata 状态变量和相关函数，实现了功能的扩展，而不影响基础功能。",
        time_lock: "📖 时间锁定是一种常见的 DeFi 安全机制。TimeLockedDepositBox 使用 block.timestamp 和修饰器实现时间锁，只有在指定时间后才能执行特定操作。这保护了用户资产，防止冲动操作。"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 16 概念定义 ==========
export const day16ConceptDefinitions = {
    struct_definition: {
        name: "结构体定义",
        icon: "🏗️",
        unlockAt: 1,
        message: "你了解了结构体定义！struct 允许你将多个相关数据组合成一个自定义类型。",
        code: `// 定义玩家资料结构体
struct PlayerProfile {
    string name;    // 玩家名称
    string avatar;  // 头像标识
}

// 创建结构体实例
PlayerProfile memory profile = PlayerProfile("Alice", "avatar1");`
    },
    mapping_storage: {
        name: "映射存储",
        icon: "🗺️",
        unlockAt: 2,
        message: "你了解了映射存储！mapping 是 Solidity 中最常用的键值对存储结构，提供 O(1) 查找效率。",
        code: `// 映射存储键值对
mapping(address => PlayerProfile) public profiles;
mapping(string => address) public plugins;

// 存储和读取
profiles[msg.sender] = PlayerProfile(name, avatar);
PlayerProfile memory p = profiles[user];`
    },
    plugin_registration: {
        name: "插件注册",
        icon: "🔌",
        unlockAt: 3,
        message: "你体验了插件注册！通过 mapping 将字符串标识符映射到合约地址，实现动态插件管理。",
        code: `// 注册插件
function registerPlugin(string memory key, address pluginAddress) external {
    plugins[key] = pluginAddress;
}

// 使用示例
registerPlugin("weapon", 0x1234...);`
    },
    low_level_call: {
        name: "低级别调用",
        icon: "⚡",
        unlockAt: 4,
        message: "你使用了低级别调用！call 是 EVM 的底层指令，允许动态调用任何合约函数。",
        code: `// 使用 call 动态调用插件
(bool success, ) = plugin.call(data);
require(success, "Plugin execution failed");

// call 可以修改状态，返回 (bool, bytes)`
    },
    abi_encoding: {
        name: "ABI编码",
        icon: "🔢",
        unlockAt: 4,
        message: "你了解了 ABI 编码！Solidity 使用 ABI 标准将函数调用编码为字节码，函数选择器是前4字节。",
        code: `// ABI 编码函数调用
bytes memory data = abi.encodeWithSignature(
    "setWeapon(address,string)", 
    user, 
    weapon
);

// 函数选择器: keccak256("setWeapon(address,string)")[0:4]`
    },
    staticcall: {
        name: "静态调用",
        icon: "👁️",
        unlockAt: 5,
        message: "你使用了静态调用！staticcall 保证被调用的合约不会修改状态，适合查询操作。",
        code: `// 使用 staticcall 进行只读调用
(bool success, bytes memory result) = plugin.staticcall(data);
require(success, "Call failed");

// 解码返回值
string memory value = abi.decode(result, (string));`
    },
    dynamic_delegation: {
        name: "动态委托",
        icon: "🔄",
        unlockAt: 6,
        message: "你体验了动态委托！一个核心合约可以管理多个插件，实现功能的模块化扩展。",
        code: `// PluginStore 作为核心，动态委托给不同插件
pluginStore.runPlugin("weapon", ...);
pluginStore.runPlugin("achievement", ...);

// 新增插件无需修改核心合约代码`
    },
    contract_interop: {
        name: "合约互操作",
        icon: "🌐",
        unlockAt: 7,
        message: "你掌握了合约互操作！多个合约通过标准接口无缝协作，构建复杂的去中心化应用。",
        code: `// 插件系统实现合约间的松耦合协作
// PluginStore (核心) → WeaponPlugin (功能)
//                    → AchievementPlugin (功能)

// 合约像乐高积木一样组合使用`
    }
};

// ========== Day 17 概念定义 ==========
export const day17ConceptDefinitions = {
    proxy_pattern: {
        name: "代理模式",
        icon: "📦",
        unlockAt: 1,
        message: "你了解了代理模式！这是可升级合约的核心架构，将数据存储与逻辑执行分离。",
        code: `// 代理合约存储数据，逻辑合约执行业务逻辑
// 用户调用 Proxy → Proxy 通过 delegatecall 调用 Logic
// 数据存储在 Proxy 中，Logic 只包含代码`
    },
    delegatecall: {
        name: "委托调用",
        icon: "🔄",
        unlockAt: 2,
        message: "你了解了 delegatecall！它在调用者（代理合约）的存储上下文中执行被调用合约（逻辑合约）的代码。",
        code: `// delegatecall 关键点：
// 1. 在代理合约的存储上下文中执行
// 2. msg.sender 保持为原始调用者
// 3. msg.value 保持不变
// 4. 代码在逻辑合约，数据在代理合约

assembly {
    let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
}`
    },
    storage_layout: {
        name: "存储布局",
        icon: "🔀",
        unlockAt: 3,
        message: "你了解了存储布局！代理合约和逻辑合约必须使用完全相同的存储变量顺序，否则升级后数据会错乱。",
        code: `// 存储布局必须一致！
contract SubscriptionStorageLayout {
    address public logicContract;  // slot 0
    address public owner;          // slot 1
    mapping(address => Subscription) public subscriptions;  // slot 2
    mapping(uint8 => uint256) public planPrices;           // slot 3
    mapping(uint8 => uint256) public planDuration;         // slot 4
    uint256[50] private __gap;     // 预留空间，防止未来冲突
}`
    },
    upgrade_mechanism: {
        name: "升级机制",
        icon: "🚀",
        unlockAt: 4,
        message: "你体验了合约升级！通过更新 logicContract 地址，可以替换业务逻辑而不丢失数据。",
        code: `// 升级逻辑合约
function upgradeTo(address _newLogic) external {
    require(msg.sender == owner, "Not owner");
    logicContract = _newLogic;  // 更新逻辑合约地址
}

// 升级后：
// - 数据保持不变（存储在代理合约）
// - 逻辑更新为新版本
// - 用户无感知切换`
    },
    logic_contract: {
        name: "逻辑合约",
        icon: "⚙️",
        unlockAt: 4,
        message: "你了解了逻辑合约！它只包含业务逻辑代码，不存储数据，可以被替换升级。",
        code: `// 逻辑合约 V1
contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    function subscribe(uint8 planId) external payable {
        // 业务逻辑...
    }
}

// 逻辑合约 V2（升级版本）
contract SubscriptionLogicV2 is SubscriptionStorageLayout {
    // 新增功能...
    function pauseSubscription() external { ... }
}`
    },
    fallback_function: {
        name: "回退函数",
        icon: "🔙",
        unlockAt: 5,
        message: "你了解了 fallback 函数！代理合约使用它捕获所有未匹配的函数调用，并通过 delegatecall 转发给逻辑合约。",
        code: `// fallback 函数处理所有未匹配的调用
fallback() external payable {
    address impl = logicContract;
    require(impl != address(0), "Not set");
    
    assembly {
        calldatacopy(0, 0, calldatasize())
        let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
        returndatacopy(0, 0, returndatasize())
        switch result
        case 0 { revert(0, returndatasize()) }
        default { return(0, returndatasize()) }
    }
}`
    },
    data_persistence: {
        name: "数据持久化",
        icon: "💾",
        unlockAt: 6,
        message: "你验证了数据持久化！升级合约后，之前创建的计划和订阅数据仍然保持不变。",
        code: `// 升级前：
// - 用户订阅了计划 1
// - 过期时间为 2024-12-31

// 升级后：
// - 订阅数据仍然存在
// - 过期时间不变
// - 可以查询到之前的订阅记录`
    },
    version_control: {
        name: "版本控制",
        icon: "📊",
        unlockAt: 7,
        message: "你体验了版本控制！V2 新增了暂停/恢复功能，展示了如何在升级中添加新特性。",
        code: `// V1 功能：
// - createPlan
// - subscribe
// - isSubscribed

// V2 新增：
// - pauseSubscription  ⭐ 新功能
// - resumeSubscription ⭐ 新功能

// 升级后，V1 和 V2 的数据格式兼容`
    }
};

// ========== Day 16 提示 ==========
export const getDay16Hint = (conceptKey) => {
    const hints = {
        struct_definition: "🏗️ 你了解了结构体定义！PlayerProfile 将 name 和 avatar 组合在一起。👉 设置玩家资料来解锁映射存储！",
        mapping_storage: "🗺️ 你的资料已保存到 mapping！通过键值对高效存储。👉 注册 weapon 插件来学习插件系统！",
        plugin_registration: "🔌 插件注册成功！地址已存入 plugins[key]。👉 点击「调用」执行插件函数！",
        low_level_call: "⚡ 低级别调用成功！使用了 EVM 的 call 指令。👉 查看 ABI 编码可视化！",
        abi_encoding: "🔢 ABI 编码完成！函数选择器是 keccak256 哈希的前4字节。👉 切换 staticcall 模式查询数据！",
        staticcall: "👁️ 静态调用成功！不消耗 Gas 的只读操作。👉 尝试切换到 achievement 插件！",
        dynamic_delegation: "🔄 动态委托系统运行中！一个核心管理多个插件。👉 在不同插件间切换体验互操作！",
        contract_interop: "🌐 合约互操作掌握！多个合约无缝协作。🎉 你已掌握 Day 16 所有核心概念！"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 16 概念解释提示 ==========
export const getDay16ExplanationHint = (conceptKey) => {
    const hints = {
        struct_definition: "📖 结构体(struct)允许你将多个相关的变量组合成一个自定义类型。PlayerProfile 包含 name 和 avatar 两个字段，可以像单个变量一样传递和存储。结构体是组织复杂数据的基础。",
        mapping_storage: "📖 映射(mapping)是哈希表结构，提供 O(1) 的读写效率。profiles 用 address 作为键存储玩家资料，plugins 用 string 作为键存储插件地址。mapping 是 Solidity 最常用的状态变量类型。",
        plugin_registration: "📖 插件注册将字符串标识符映射到合约地址，实现动态插件管理。这种设计模式被称为注册表模式(Registry Pattern)，允许运行时添加新功能而无需修改核心合约代码。",
        low_level_call: "📖 call 是 EVM 的低级别调用指令，允许你动态调用任何函数。它返回 (bool, bytes) 元组表示成功状态和返回值。call 非常灵活但不如普通调用安全，需要仔细检查返回值。",
        abi_encoding: "📖 ABI(Application Binary Interface)编码将函数签名和参数转换为字节码。函数选择器是函数签名的 keccak256 哈希的前4字节。abi.encodeWithSignature 自动处理编码过程。",
        staticcall: "📖 staticcall 与 call 类似，但被调用的合约不能修改状态(发送ETH、写存储等)。它适合查询操作，更安全且通常不消耗 Gas。staticcall 是 view 函数的底层实现。",
        dynamic_delegation: "📖 动态委托允许核心合约将操作转发给不同的插件合约，实现功能的模块化扩展。这种架构让系统可以灵活添加新功能，无需修改核心代码，是插件系统的基础。",
        contract_interop: "📖 合约互操作是 DeFi 和 DApp 的基础。通过标准接口和动态调用，不同合约可以像乐高积木一样组合使用。PluginStore 展示了如何通过统一接口协调多个独立合约。"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 17 提示 ==========
export const getDay17Hint = (conceptKey) => {
    const hints = {
        proxy_pattern: "📦 你了解了代理模式！这是可升级合约的核心架构。👉 点击 delegatecall 说明来学习委托调用！",
        delegatecall: "🔄 你了解了 delegatecall！它在代理合约的存储上下文中执行逻辑合约的代码。👉 点击存储布局说明了解变量顺序的重要性！",
        storage_layout: "🔀 你了解了存储布局！代理合约和逻辑合约必须使用相同的存储变量顺序。👉 切换到 Owner 身份，创建第一个订阅计划！",
        upgrade_mechanism: "🚀 你体验了合约升级！通过更新 logicContract 地址，可以替换业务逻辑而不丢失数据。👉 切换到 User 身份，执行订阅操作！",
        logic_contract: "⚙️ 你了解了逻辑合约！它只包含业务逻辑代码，不存储数据。👉 订阅后查看 fallback 如何工作！",
        fallback_function: "🔙 你了解了 fallback 函数！代理合约使用它捕获所有未匹配的函数调用。👉 升级合约后查看数据是否仍然存在！",
        data_persistence: "💾 你验证了数据持久化！升级合约后，之前的数据仍然保持不变。👉 使用 V2 新功能（暂停/恢复）来对比版本差异！",
        version_control: "📊 你体验了版本控制！V2 新增了暂停/恢复功能。🎉 你已掌握 Day 17 所有核心概念！"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 17 解释提示 ==========
export const getDay17ExplanationHint = (conceptKey) => {
    const hints = {
        proxy_pattern: "📖 代理模式(Proxy Pattern)是可升级合约的核心架构。代理合约负责存储所有数据和 ETH，逻辑合约只包含业务代码。用户始终与代理合约交互，代理通过 delegatecall 将调用转发给当前逻辑合约。",
        delegatecall: "📖 delegatecall 是 EVM 的特殊调用方式，它在调用者（代理合约）的存储上下文中执行被调用合约（逻辑合约）的代码。这意味着逻辑合约可以读写代理合约的存储，但代码来自逻辑合约。msg.sender 和 msg.value 保持不变。",
        storage_layout: "📖 存储布局一致性是可升级合约的关键。代理合约和逻辑合约必须继承相同的存储布局基础合约（如 SubscriptionStorageLayout），确保变量顺序完全一致。如果顺序不同，升级后数据会错位，导致严重错误。",
        upgrade_mechanism: "📖 升级机制通过更新代理合约中的 logicContract 地址实现。upgradeTo() 函数只有 owner 可以调用，更新后所有新调用都会使用新逻辑。旧数据保持不变，因为数据存储在代理合约中，不在逻辑合约里。",
        logic_contract: "📖 逻辑合约(Logic Contract)只包含业务逻辑代码，不存储任何状态数据。它可以被替换升级而不影响数据。V1 和 V2 都是逻辑合约，它们继承相同的存储布局，但实现不同的功能。",
        fallback_function: "📖 fallback 函数是代理合约的核心。当用户调用代理合约中不存在的函数时，fallback 会被触发。它使用 delegatecall 将调用转发给逻辑合约，并返回执行结果。这是实现透明代理的关键。",
        data_persistence: "📖 数据持久化是可升级合约的重要特性。由于所有数据都存储在代理合约中，升级逻辑合约不会影响已有数据。用户升级前创建的订阅、计划等数据在升级后仍然可以正常访问和使用。",
        version_control: "📖 版本控制展示了如何在升级中添加新功能。V2 在 V1 的基础上新增了 pauseSubscription 和 resumeSubscription 功能，但保持数据格式兼容。这展示了可升级合约的灵活性和扩展性。"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 18 概念定义 ==========
export const day18ConceptDefinitions = {
    oracle_interface: {
        name: "Chainlink接口",
        icon: "🔌",
        unlockAt: 1,
        message: "你了解了 Chainlink 预言机接口！AggregatorV3Interface 是 Chainlink 标准接口，让智能合约能够获取链外数据。",
        code: `interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}`
    },
    eth_usd_oracle: {
        name: "ETH/USD喂价",
        icon: "💰",
        unlockAt: 2,
        message: "你使用了 ETH/USD 价格预言机！Chainlink 返回的价格有 8 位小数精度，需要正确处理。",
        code: `function getEthPrice() public view returns (uint256) {
    (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
    // price = 300000000000 表示 $3000.00
    return uint256(price);
}`
    },
    random_generation: {
        name: "伪随机数生成",
        icon: "🎲",
        unlockAt: 3,
        message: "你看到了伪随机数生成！使用区块信息生成随机数，适合测试但不适合生产环境。",
        code: `function _rainfall() public view returns (int256) {
    uint256 randomFactor = uint256(keccak256(abi.encodePacked(
        block.timestamp,
        block.coinbase,
        block.number
    ))) % 1000;
    return int256(randomFactor);
}`
    },
    purchase_insurance: {
        name: "购买保险",
        icon: "🛡️",
        unlockAt: 4,
        message: "你购买了保险！支付保费后获得保障，当条件满足时可获得赔付。",
        code: `function purchaseInsurance() external payable {
    require(msg.value >= premiumInEth, "Insufficient premium");
    require(!hasInsurance[msg.sender], "Already insured");
    hasInsurance[msg.sender] = true;
    emit InsurancePurchased(msg.sender, msg.value);
}`
    },
    price_conversion: {
        name: "价格转换",
        icon: "🔄",
        unlockAt: 5,
        message: "你了解了价格转换！Chainlink 价格有 8 位小数，需要使用 1e26 来正确计算 ETH 数量。",
        code: `uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e26) / ethPrice;
// 1e26 = 1e18(wei精度) × 1e8(Chainlink精度)
// 例如: (10 * 1e26) / 300000000000 = 0.0033 ETH`
    },
    parametric_payout: {
        name: "参数化赔付",
        icon: "💸",
        unlockAt: 6,
        message: "你体验了参数化赔付！无需人工审核，条件满足自动赔付，这是区块链保险的核心优势。",
        code: `if (currentRainfall < RAINFALL_THRESHOLD) {
    // 自动执行赔付
    (bool success, ) = msg.sender.call{value: payoutInEth}("");
    require(success, "Transfer failed");
    emit ClaimPaid(msg.sender, payoutInEth);
}`
    },
    cooldown_mechanism: {
        name: "冷却期机制",
        icon: "⏱️",
        unlockAt: 7,
        message: "你了解了冷却期机制！24小时内只能索赔一次，防止滥用和频繁索赔。",
        code: `require(
    block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days,
    "Must wait 24h between claims"
);
lastClaimTimestamp[msg.sender] = block.timestamp;`
    },
    contract_balance: {
        name: "合约余额",
        icon: "🏦",
        unlockAt: 8,
        message: "你查看了合约余额！管理员可以提取合约中的 ETH，这是保险池资金管理的重要功能。",
        code: `function withdraw() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
}

function getBalance() public view returns (uint256) {
    return address(this).balance;
}`
    }
};

// ========== Day 19 概念定义 ==========
export const day19ConceptDefinitions = {
    keccak256_hash: {
        name: "Keccak256哈希算法",
        icon: "🔐",
        unlockAt: 1,
        message: "你使用了 Keccak256 哈希算法！这是以太坊标准的哈希函数，将任意数据转换为固定长度的哈希值。",
        code: `bytes32 messageHash = keccak256(abi.encodePacked(_user));
// Keccak256 是以太坊原生哈希函数
// 输入任意长度数据，输出 32 字节固定长度哈希`
    },
    ecdsa_signature: {
        name: "ECDSA椭圆曲线签名",
        icon: "🎯",
        unlockAt: 2,
        message: "你了解了 ECDSA 椭圆曲线签名！这是以太坊使用的数字签名算法，基于椭圆曲线密码学实现身份验证。",
        code: `// ECDSA = Elliptic Curve Digital Signature Algorithm
// 使用私钥签名，公钥验证
// 签名后得到 r, s, v 三个值`
    },
    signature_rsv: {
        name: "签名组件R/S/V",
        icon: "📝",
        unlockAt: 3,
        message: "你分解了签名的 R/S/V 组件！以太坊签名由 65 字节组成：r(32) + s(32) + v(1)。",
        code: `(bytes32 r, bytes32 s, uint8 v) = splitSignature(sig);
// r: 签名前32字节
// s: 签名中间32字节
// v: 最后1字节，用于恢复公钥`
    },
    eip191_prefix: {
        name: "EIP-191以太坊签名前缀",
        icon: "📋",
        unlockAt: 5,
        message: "你了解了 EIP-191 签名前缀！\\x19Ethereum Signed Message:\\n32 是以太坊个人签名的标准前缀，防止签名被滥用。",
        code: `bytes32 ethSignedMessageHash = keccak256(
    abi.encodePacked(
        "\\x19Ethereum Signed Message:\\n32",
        messageHash
    )
);
// 前缀确保签名只能用于以太坊消息`
    },
    ecrecover: {
        name: "签名者恢复函数",
        icon: "🔓",
        unlockAt: 5,
        message: "你使用了 ecrecover 函数！这是 Solidity 内置函数，通过签名数据恢复签名者的以太坊地址。",
        code: `address signer = ecrecover(
    ethSignedMessageHash,
    v,
    r,
    s
);
// ecrecover 是 EVM 内置函数
// 输入签名哈希和 r,s,v，返回签名者地址`
    },
    require_statement: {
        name: "Require验证语句",
        icon: "⚠️",
        unlockAt: 6,
        message: "你使用了 require 验证语句！这是 Solidity 中最常用的条件检查，不满足时回滚交易并显示错误消息。",
        code: `require(!hasEntered[msg.sender], "Already entered");
// 第一个参数：条件表达式
// 第二个参数：错误消息（可选）
// 条件为 false 时，交易回滚`
    },
    mapping_storage: {
        name: "映射存储",
        icon: "🗂️",
        unlockAt: 7,
        message: "你使用了映射存储！mapping 是 Solidity 中的键值对数据结构，用于高效存储用户状态。",
        code: `mapping(address => bool) public hasEntered;
// mapping(keyType => valueType)
// keyType: 地址类型
// valueType: 布尔类型（是否已参与）
hasEntered[userAddress] = true;  // 写入`
    },
    msg_sender: {
        name: "消息发送者",
        icon: "👤",
        unlockAt: 8,
        message: "你使用了 msg.sender！这是 Solidity 中的全局变量，表示当前交易的发送者地址。",
        code: `constructor() {
    organizer = msg.sender;
}
// msg.sender: 当前调用者地址
// 在构造函数中，部署者成为组织者`
    }
};

// ========== Day 18 提示 ==========
export const getDay18Hint = (conceptKey) => {
    const hints = {
        oracle_interface: "🔌 你了解了 Chainlink 预言机接口！AggregatorV3Interface 是标准接口。👉 查看 ETH/USD 价格面板学习价格预言机！",
        eth_usd_oracle: "💰 你使用了 ETH/USD 价格预言机！注意 Chainlink 返回 8 位小数精度。👉 购买保险体验价格转换！",
        random_generation: "🎲 你看到了伪随机数生成！使用区块信息生成随机降雨量。👉 更新天气数据体验随机性！",
        purchase_insurance: "🛡️ 保险购买成功！支付保费获得保障。👉 当干旱发生时申请赔付！",
        price_conversion: "🔄 你了解了价格转换！1e26 = 1e18 × 1e8 抵消 Chainlink 精度。👉 申请赔付体验参数化保险！",
        parametric_payout: "💸 赔付成功！参数化保险自动执行无需审核。👉 了解冷却期机制防止滥用！",
        cooldown_mechanism: "⏱️ 你了解了冷却期！24小时内只能索赔一次。👉 快进时间或查看合约余额！",
        contract_balance: "🏦 你查看了合约余额！管理员可提取保险池资金。🎉 你已掌握 Day 18 所有核心概念！"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 18 解释提示 ==========
export const getDay18ExplanationHint = (conceptKey) => {
    const hints = {
        oracle_interface: "📖 Chainlink 预言机接口(AggregatorV3Interface)是行业标准，定义了 latestRoundData() 等函数。它让智能合约能够安全地获取链外数据，如价格、天气等。接口标准化确保不同预言机可以互换使用。",
        eth_usd_oracle: "📖 ETH/USD 价格预言机返回的价格有 8 位小数精度。例如 $3000 返回 300000000000。这是因为金融数据通常需要高精度，而 Solidity 不支持浮点数。使用时需要注意精度转换。",
        random_generation: "📖 伪随机数生成使用区块信息（timestamp, coinbase, number）作为种子。这种方式适合测试和演示，但不适合生产环境，因为矿工可以影响结果。生产环境应使用 Chainlink VRF 等安全随机数方案。",
        purchase_insurance: "📖 购买保险函数检查用户支付足够的 ETH 且尚未投保。保费根据当前 ETH 价格动态计算，确保合约收到正确金额。投保状态存储在 hasInsurance 映射中，永久记录在区块链上。",
        price_conversion: "📖 价格转换公式 (USD × 1e26) / ETH价格 考虑了 Chainlink 的 8 位小数精度。1e26 = 1e18(wei精度) × 1e8(价格精度)。例如 $10 保费在 ETH $3000 时约为 0.0033 ETH。",
        parametric_payout: "📖 参数化保险(Parametric Insurance)是区块链保险的核心创新。传统保险需要人工审核理赔，而参数保险根据预设条件（如降雨量 < 500mm）自动赔付，无需信任第三方，大幅降低运营成本。",
        cooldown_mechanism: "📖 冷却期机制使用 block.timestamp 记录上次索赔时间，限制 24 小时内只能索赔一次。这是防止滥用的安全措施。在真实区块链上时间无法篡改，确保机制可靠。",
        contract_balance: "📖 合约余额管理是 DeFi 应用的基础。管理员可以提取合约中的 ETH，用于保险池资金管理。balance 操作需要注意重入攻击防护，使用 checks-effects-interactions 模式。"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 19 提示 ==========
export const getDay19Hint = (conceptKey) => {
    const hints = {
        keccak256_hash: "🔐 你使用了 Keccak256 哈希算法！这是以太坊标准的哈希函数，将任意数据转换为 32 字节哈希值。👉 点击展开签名详情查看 R/S/V 组件！",
        ecdsa_signature: "🎯 你了解了 ECDSA 椭圆曲线签名！这是以太坊使用的数字签名算法，基于椭圆曲线密码学。👉 点击生成签名来体验完整流程！",
        signature_rsv: "📝 你分解了签名的 R/S/V 组件！以太坊签名由 65 字节组成：r(32) + s(32) + v(1)。👉 使用签名参与活动来解锁 ecrecover！",
        eip191_prefix: "📋 你了解了 EIP-191 签名前缀！\\x19Ethereum Signed Message:\\n32 是以太坊个人签名的标准，防止签名被滥用。👉 查看参与者列表完成所有概念！",
        ecrecover: "🔓 你使用了 ecrecover 函数！这是 Solidity 内置函数，通过签名恢复签名者地址。👉 查看参与者列表了解映射存储！",
        require_statement: "⚠️ 你使用了 require 验证语句！这是 Solidity 安全编程的基础，不满足条件时回滚交易。👉 查看参与者列表完成所有概念！",
        mapping_storage: "🗂️ 你使用了映射存储！mapping 是 Solidity 高效的键值对结构，用于存储用户参与状态。🎉 你已掌握 Day 19 所有核心概念！",
        msg_sender: "👤 你使用了 msg.sender！这是 Solidity 的全局变量，表示当前交易的发送者地址。👉 点击展开签名详情查看 R/S/V 组件！"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 19 解释提示 ==========
export const getDay19ExplanationHint = (conceptKey) => {
    const hints = {
        keccak256_hash: "📖 Keccak256 是以太坊原生的哈希函数（SHA-3 算法变体）。它将任意长度的输入转换为 32 字节的固定长度输出。在签名验证中，我们需要先对用户地址进行哈希，生成唯一的消息标识。",
        ecdsa_signature: "📖 ECDSA（椭圆曲线数字签名算法）是以太坊使用的签名方案。它基于椭圆曲线密码学，使用私钥生成签名，任何人可以用公钥验证签名。签名过程不可逆，无法从签名推导出私钥。",
        signature_rsv: "📖 以太坊签名由 65 字节组成：r（32字节）+ s（32字节）+ v（1字节）。r 和 s 是签名曲线坐标，v 是恢复标识符（27 或 28）。通过 v 可以推导出对应的公钥地址。",
        eip191_prefix: "📖 EIP-191 定义了以太坊签名的标准格式：\\x19Ethereum Signed Message:\\n32 前缀。这个前缀确保签名只能用于以太坊消息，防止签名被滥用到其他区块链或应用中。",
        ecrecover: "📖 ecrecover 是 EVM 内置函数，用于从签名数据恢复签名者地址。它接受消息哈希和 r、s、v 作为参数，返回签名的公钥对应的地址。这是签名验证的核心函数。",
        require_statement: "📖 require 是 Solidity 中最常用的错误处理语句。第一个参数是布尔条件，第二个参数是可选的错误消息。当条件为 false 时，交易回滚，消耗所有 Gas。",
        mapping_storage: "📖 mapping 是 Solidity 中的键值对数据结构，类似于哈希表。mapping(address => bool) 表示地址到布尔值的映射。访问不存在的键会返回默认值（false），写入时会创建键值对。",
        msg_sender: "📖 msg.sender 是 Solidity 的全局变量，表示当前调用者的地址。在构造函数中，msg.sender 是合约的部署者，因此成为组织者。这是权限控制的基础。"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 20 概念定义 ==========
export const day20ConceptDefinitions = {
    reentrancy_attack: {
        name: "重入攻击",
        icon: "🔥",
        unlockAt: 1,
        message: "你了解了重入攻击！这是最著名的智能合约漏洞，攻击者通过递归调用窃取资金。",
        code: `// 重入攻击原理:
// 1. 攻击者存入 1 ETH
// 2. 调用 withdraw() 提款
// 3. 合约发送 ETH，触发攻击者的 receive()
// 4. receive() 再次调用 withdraw()
// 5. 重复直到资金耗尽！
receive() external payable {
    if (attackCount < 5) {
        targetVault.vulnerableWithdraw(); // 递归调用！
    }
}`
    },
    fallback_receive: {
        name: "回退函数",
        icon: "⚡",
        unlockAt: 2,
        message: "你使用了回退函数！receive() 在合约接收 ETH 时自动触发，是重入攻击的入口点。",
        code: `// receive() 函数 - 接收 ETH 时触发
receive() external payable {
    attackCount++;
    
    // 如果金库还有余额，继续攻击
    if (address(targetVault).balance >= 1 ether) {
        targetVault.vulnerableWithdraw(); // 再次提款！
    }
}`
    },
    vulnerable_withdraw: {
        name: "漏洞提款函数",
        icon: "🔴",
        unlockAt: 3,
        message: "你发现了漏洞提款函数！它先发送 ETH 后更新余额，让攻击者有机可乘。",
        code: `// ❌ 有漏洞的代码
function vulnerableWithdraw() external {
    uint256 amount = goldBalance[msg.sender];
    require(amount > 0, "Nothing");

    // ⚠️ 漏洞: 先发送 ETH
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "Failed");

    // ❌ 后更新余额 - 攻击者可以重入！
    goldBalance[msg.sender] = 0;
}`
    },
    deposit_function: {
        name: "存款函数",
        icon: "💰",
        unlockAt: 4,
        message: "你使用了存款函数！用户存入 ETH 增加余额，是攻击的前提条件。",
        code: `// 存款函数
function deposit() external payable {
    require(msg.value > 0, "Deposit > 0");
    goldBalance[msg.sender] += msg.value;
}

// 调用方式:
// vault.deposit{value: 1 ether}();`
    },
    checks_effects_interactions: {
        name: "CEI模式",
        icon: "✅",
        unlockAt: 5,
        message: "你了解了 CEI 模式！Checks-Effects-Interactions 是防止重入攻击的核心设计模式。",
        code: `// ✅ Checks-Effects-Interactions 模式
function safeWithdraw() external {
    // 1. Checks: 验证条件
    uint256 amount = goldBalance[msg.sender];
    require(amount > 0, "Nothing");

    // 2. Effects: 先更新状态 ✅
    goldBalance[msg.sender] = 0;

    // 3. Interactions: 最后外部调用 ✅
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "Failed");
}`
    },
    reentrancy_guard: {
        name: "重入锁",
        icon: "🔒",
        unlockAt: 6,
        message: "你使用了重入锁！nonReentrant 修饰符阻止函数在锁定期间被重入调用。",
        code: `// 重入锁实现
uint256 private _status;
uint256 private constant _NOT_ENTERED = 1;
uint256 private constant _ENTERED = 2;

modifier nonReentrant() {
    require(_status != _ENTERED, "Blocked!");
    _status = _ENTERED;      // 🔒 锁定
    _;
    _status = _NOT_ENTERED;  // 🔓 解锁
}

function safeWithdraw() external nonReentrant {
    // 函数体...
}`
    },
    contract_balance: {
        name: "合约余额",
        icon: "🏦",
        unlockAt: 7,
        message: "你查看了合约余额！address(this).balance 返回合约持有的 ETH 数量。",
        code: `// 查询合约余额
function getBalance() public view returns (uint256) {
    return address(this).balance;
}

// 在攻击合约中检查目标余额
if (address(targetVault).balance >= 1 ether) {
    // 继续攻击...
}`
    },
    code_comparison: {
        name: "代码对比",
        icon: "📜",
        unlockAt: 8,
        message: "你对比了漏洞代码和安全代码！理解差异是学习安全编程的关键。",
        code: `// ❌ 漏洞版本: 先发送 ETH，后更新余额
(bool sent, ) = msg.sender.call{value: amount}("");
goldBalance[msg.sender] = 0; // 攻击者已重入！

// ✅ 安全版本: 先更新余额，后发送 ETH
goldBalance[msg.sender] = 0; // 先更新！(nonReentrant 保护)
(bool sent, ) = msg.sender.call{value: amount}("");`
    }
};

// ========== Day 20 提示 ==========
export const getDay20Hint = (conceptKey) => {
    const hints = {
        reentrancy_attack: "🔥 你了解了重入攻击！这是最著名的智能合约漏洞。👉 存入ETH到金库开始攻击演示！",
        fallback_receive: "⚡ 你使用了回退函数！receive() 在接收ETH时触发，是重入攻击的入口点。👉 查看防护机制了解如何修复！",
        vulnerable_withdraw: "🔴 你发现了漏洞提款函数！它先发送ETH后更新余额。👉 查看防护机制了解如何修复！",
        deposit_function: "💰 你使用了存款函数！用户存入ETH增加余额。👉 现在尝试攻击漏洞版本！",
        checks_effects_interactions: "✅ 你了解了CEI模式！先更新状态再发送ETH是防止重入的关键。👉 尝试攻击安全版本！",
        reentrancy_guard: "🔒 你使用了重入锁！nonReentrant修饰符阻止函数重入调用。👉 查看代码对比巩固知识！",
        contract_balance: "🏦 你查看了合约余额！address(this).balance返回合约ETH数量。🎉 恭喜完成Day20全部学习！",
        code_comparison: "📜 你对比了漏洞代码和安全代码！理解差异是学习安全编程的关键。👉 切换到'金库管理员'查看金库状态！"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 20 解释提示 ==========
export const getDay20ExplanationHint = (conceptKey) => {
    const hints = {
        reentrancy_attack: "📖 重入攻击(Reentrancy Attack)是智能合约最著名的漏洞。攻击者利用合约在发送ETH后、更新状态前的窗口期，通过递归调用重复提款。2016年的The DAO攻击就是利用此漏洞，损失360万ETH，导致以太坊硬分叉。",
        fallback_receive: "📖 receive() 是 Solidity 的特殊函数，当合约接收 ETH 且没有附带数据时触发。在重入攻击中，攻击者的 receive() 函数会再次调用目标合约的提款函数，形成递归调用链。这是重入攻击的核心机制。",
        vulnerable_withdraw: "📖 漏洞提款函数违反了 Checks-Effects-Interactions 模式。它先执行外部调用（发送ETH），后更新状态（清零余额）。当外部调用触发攻击者的 receive() 时，余额还未更新，攻击者可以再次提款。",
        deposit_function: "📖 存款函数是重入攻击的前提条件。攻击者必须先存入一定数量的 ETH，获得提款资格。deposit() 使用 payable 修饰符接收 ETH，并使用 require 验证金额大于0。",
        checks_effects_interactions: "📖 CEI模式是 Solidity 安全编程的黄金法则。Checks（检查条件）→ Effects（更新状态）→ Interactions（外部调用）。关键是先更新状态再外部调用，这样即使被重入，状态已经是最新的，攻击者无法重复获利。",
        reentrancy_guard: "📖 重入锁(Reentrancy Guard)使用状态变量跟踪函数执行状态。_NOT_ENTERED(1) 表示未锁定，_ENTERED(2) 表示已锁定。modifier 在函数执行前锁定，执行后解锁。如果函数被重入调用，require 会阻止执行。OpenZeppelin 提供了标准实现。",
        contract_balance: "📖 address(this).balance 返回合约当前持有的 ETH 数量（以 wei 为单位）。在攻击合约中，它用于判断目标金库是否还有资金可以继续攻击。在管理函数中，它用于查询和提取合约资金。",
        code_comparison: "📖 通过对比漏洞代码和安全代码，可以清晰看到修复方法：1) 调整代码顺序，先更新状态再外部调用；2) 添加 nonReentrant 修饰符作为双重保护。理解这种差异对编写安全智能合约至关重要。",
        // ========== Day 21 解释提示 ==========
        ierc721_interface: "📖 IERC721 是 ERC721 代币标准的接口定义，规定了 NFT 合约必须实现的基本功能，包括 balanceOf、ownerOf、transferFrom、approve 等函数。符合此接口的合约可以在所有支持 ERC721 的平台上使用。",
        mint_function: "📖 铸造函数是创建新 NFT 的核心。它从 0 地址（address(0)）转移代币到新所有者，这是 ERC721 标准中表示铸造的特殊约定。每次铸造都会触发 Transfer 事件，from 为 0 地址。",
        token_id_counter: "📖 代币 ID 计数器用于生成唯一的 tokenId。通常从 1 开始递增，确保每个 NFT 都有唯一标识。计数器使用 uint256 类型，可以支持几乎无限数量的 NFT。",
        token_uri: "📖 Token URI 是 NFT 元数据的链接，通常指向 IPFS 上的 JSON 文件。元数据包含 NFT 的名称、描述、图片等信息。这使得 NFT 可以展示丰富的内容，而不仅仅是区块链上的数字。",
        balance_of: "📖 balanceOf 函数查询地址拥有的 NFT 数量。它使用 _balances 映射实现，时间复杂度为 O(1)。这是 ERC721 标准的基础查询功能，也是所有权管理的核心。",
        transfer_from: "📖 transferFrom 函数将 NFT 从一个地址转移到另一个地址。调用者必须是被授权者或代币所有者。转移时会清除原有的授权，防止授权滥用。",
        approve_mechanism: "📖 授权机制允许代币所有者授权其他地址管理特定代币。approve 授权单个代币，getApproved 查询授权状态。这是 NFT 交易市场的基础，允许第三方代为转移代币。",
        approval_for_all: "📖 操作员授权(setApprovalForAll)允许所有者一次性授权某个地址管理其所有代币。这比逐个授权更高效，常用于 NFT 交易平台的批量操作场景。",
        safe_transfer: "📖 安全转移(safeTransferFrom)在转移前检查接收方是否实现了 IERC721Receiver 接口。这防止 NFT 被意外发送到不支持 ERC721 的合约中而被锁定。这是 ERC721 标准的重要安全特性。"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 21 概念定义 ==========
export const day21ConceptDefinitions = {
    ierc721_interface: {
        name: "IERC721接口",
        icon: "🔌",
        unlockAt: 1,
        message: "你了解了ERC721标准接口！这是NFT合约必须实现的基本功能规范。",
        code: `interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
}`
    },
    mint_function: {
        name: "铸造函数",
        icon: "🔨",
        unlockAt: 2,
        message: "你使用了铸造函数！它从0地址创建新NFT，是代币生命周期的起点。",
        code: `function mint(address to, string memory uri) public {
    uint256 tokenId = _tokenIdCounter;
    _tokenIdCounter++;
    
    _owners[tokenId] = to;
    _balances[to] += 1;
    _tokenURIs[tokenId] = uri;
    
    // from 0 address = 铸造
    emit Transfer(address(0), to, tokenId);
}`
    },
    token_id_counter: {
        name: "代币ID计数器",
        icon: "🔢",
        unlockAt: 3,
        message: "你了解了代币ID计数器！它确保每个NFT都有唯一的标识符。",
        code: `uint256 private _tokenIdCounter = 1;

function mint(address to, string memory uri) public {
    uint256 tokenId = _tokenIdCounter;
    _tokenIdCounter++;  // 自动递增
    
    _owners[tokenId] = to;
    // ...
}`
    },
    token_uri: {
        name: "Token URI",
        icon: "🔗",
        unlockAt: 4,
        message: "你查看了Token URI！它指向NFT的元数据，通常存储在IPFS上。",
        code: `mapping(uint256 => string) private _tokenURIs;

function tokenURI(uint256 tokenId) public view returns (string memory) {
    require(_owners[tokenId] != address(0), "Token doesn't exist");
    return _tokenURIs[tokenId];
    // 返回如: ipfs://Qm...
}`
    },
    balance_of: {
        name: "余额查询",
        icon: "📊",
        unlockAt: 5,
        message: "你查询了NFT余额！balanceOf使用映射实现O(1)时间复杂度查询。",
        code: `mapping(address => uint256) private _balances;

function balanceOf(address owner) public view returns (uint256) {
    require(owner != address(0), "Zero address");
    return _balances[owner];  // O(1)查询
}`
    },
    transfer_from: {
        name: "代币转移",
        icon: "🔄",
        unlockAt: 6,
        message: "你执行了NFT转移！transferFrom需要授权或所有权验证。",
        code: `function transferFrom(address from, address to, uint256 tokenId) public {
    require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
    
    _transfer(from, to, tokenId);
}

function _transfer(address from, address to, uint256 tokenId) internal {
    delete _tokenApprovals[tokenId];  // 清除授权
    _balances[from] -= 1;
    _balances[to] += 1;
    _owners[tokenId] = to;
    emit Transfer(from, to, tokenId);
}`
    },
    approve_mechanism: {
        name: "授权机制",
        icon: "🔑",
        unlockAt: 7,
        message: "你使用了授权机制！approve允许其他地址管理你的特定代币。",
        code: `mapping(uint256 => address) private _tokenApprovals;

function approve(address to, uint256 tokenId) public {
    address owner = ownerOf(tokenId);
    require(msg.sender == owner || 
            isApprovedForAll(owner, msg.sender), "Not authorized");
    
    _tokenApprovals[tokenId] = to;
    emit Approval(owner, to, tokenId);
}`
    },
    approval_for_all: {
        name: "操作员授权",
        icon: "👥",
        unlockAt: 8,
        message: "你设置了操作员授权！setApprovalForAll允许地址管理你的所有代币。",
        code: `mapping(address => mapping(address => bool)) private _operatorApprovals;

function setApprovalForAll(address operator, bool approved) public {
    require(operator != msg.sender, "Self approval");
    _operatorApprovals[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
}`
    },
    safe_transfer: {
        name: "安全转移",
        icon: "🛡️",
        unlockAt: 9,
        message: "你使用了安全转移！safeTransferFrom检查接收方是否支持ERC721。",
        code: `function safeTransferFrom(address from, address to, uint256 tokenId) public {
    require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
    _safeTransfer(from, to, tokenId, "");
}

function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal {
    _transfer(from, to, tokenId);
    // 检查接收方是否支持 ERC721
    require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
}`
    }
};

// ========== Day 21 提示 ==========
export const getDay21Hint = (conceptKey) => {
    const hints = {
        ierc721_interface: "🔌 你了解了ERC721标准接口！👉 点击铸造按钮创建你的第一个NFT！",
        mint_function: "🔨 你使用了铸造函数！👉 完成铸造查看计数器如何工作！",
        token_id_counter: "🔢 你了解了代币ID计数器！👉 查询地址余额了解持有情况！",
        token_uri: "🔗 你查看了Token URI！👉 尝试铸造或转移NFT！",
        balance_of: "📊 你查询了NFT余额！👉 查看代币授权状态了解approve机制！",
        transfer_from: "🔄 你执行了NFT转移！👉 尝试授权其他地址管理你的NFT！",
        approve_mechanism: "🔑 你使用了授权机制！👉 尝试设置操作员授权！",
        approval_for_all: "👥 你设置了操作员授权！👉 尝试使用安全转移功能！",
        safe_transfer: "🛡️ 你使用了安全转移！🎉 恭喜完成Day21所有学习！"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// ========== Day 21 解释提示 ==========
export const getDay21ExplanationHint = (conceptKey) => {
    const hints = {
        ierc721_interface: "📖 IERC721 是 ERC721 代币标准的接口定义，规定了 NFT 合约必须实现的基本功能，包括 balanceOf、ownerOf、transferFrom、approve 等函数。符合此接口的合约可以在所有支持 ERC721 的平台上使用。",
        mint_function: "📖 铸造函数是创建新 NFT 的核心。它从 0 地址（address(0)）转移代币到新所有者，这是 ERC721 标准中表示铸造的特殊约定。每次铸造都会触发 Transfer 事件，from 为 0 地址。",
        token_id_counter: "📖 代币 ID 计数器用于生成唯一的 tokenId。通常从 1 开始递增，确保每个 NFT 都有唯一标识。计数器使用 uint256 类型，可以支持几乎无限数量的 NFT。",
        token_uri: "📖 Token URI 是 NFT 元数据的链接，通常指向 IPFS 上的 JSON 文件。元数据包含 NFT 的名称、描述、图片等信息。这使得 NFT 可以展示丰富的内容，而不仅仅是区块链上的数字。",
        balance_of: "📖 balanceOf 函数查询地址拥有的 NFT 数量。它使用 _balances 映射实现，时间复杂度为 O(1)。这是 ERC721 标准的基础查询功能，也是所有权管理的核心。",
        transfer_from: "📖 transferFrom 函数将 NFT 从一个地址转移到另一个地址。调用者必须是被授权者或代币所有者。转移时会清除原有的授权，防止授权滥用。",
        approve_mechanism: "📖 授权机制允许代币所有者授权其他地址管理特定代币。approve 授权单个代币，getApproved 查询授权状态。这是 NFT 交易市场的基础，允许第三方代为转移代币。",
        approval_for_all: "📖 操作员授权(setApprovalForAll)允许所有者一次性授权某个地址管理其所有代币。这比逐个授权更高效，常用于 NFT 交易平台的批量操作场景。",
        safe_transfer: "📖 安全转移(safeTransferFrom)在转移前检查接收方是否实现了 IERC721Receiver 接口。这防止 NFT 被意外发送到不支持 ERC721 的合约中而被锁定。这是 ERC721 标准的重要安全特性。"
    };
    return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释。";
};

// 保留原有的 getConceptExplanationHint 函数用于其他天数
export { getConceptExplanationHint as default };
