// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ==================== 内联 Ownable 合约 ====================
// 直接内联，无需外部依赖
// 实现了基本的访问控制功能，只有合约所有者能执行特定操作
contract Ownable {
    // 存储合约所有者地址，private 表示只有本合约内部可以访问
    address private _owner;

    // 所有权转移事件indexed 可以让前端按地址筛选事件
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // 构造函数：部署时设置初始所有者
    // initialOwner: 初始所有者地址
    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }

    // 修饰器：限制只有所有者可以调用
    // _ 表示被修饰函数的代码将插入到这里
    modifier onlyOwner() {
        _checkOwner();  // 检查调用者是否是所有者
        _;              // 执行被修饰的函数体
    }

    // 获取当前所有者地址
    // public: 任何人都可以调用
    // view: 不修改状态，只读取
    // virtual: 允许子合约重写
    function owner() public view virtual returns (address) {
        return _owner;
    }

    // 内部函数：检查调用者是否是所有者
    // internal: 只能在本合约和子合约中调用
    function _checkOwner() internal view virtual {
        // require 检查条件，不满足则回滚交易并返回错误信息
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    // 内部函数：转移所有权
    // newOwner: 新所有者地址
    function _transferOwnership(address newOwner) internal virtual {
        // 记录旧所有者地址
        address oldOwner = _owner;
        // 更新所有者
        _owner = newOwner;
        // 触发所有权转移事件
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// ==================== Mock VRF 协调器接口 ====================
// 模拟 Chainlink VRF Coordinator 接口
// 用于本地测试环境，无需连接真实的 Chainlink 网络
interface IMockVRFCoordinator {
    // 请求随机数（模拟 VRF 请求）
    // keyHash: VRF 密钥哈希，用于标识 VRF 服务
    // subId: 订阅 ID，用于计费
    // requestConfirmations: 请求确认数，等待多少个区块确认
    // callbackGasLimit: 回调函数 gas 限制
    // numWords: 请求的随机数数量
    // 返回: requestId 请求 ID，用于追踪
    function requestRandomWords(
        bytes32 keyHash,
        uint256 subId,
        uint16 requestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);
}

// ==================== VRF 消费者接口 ====================
// 定义 VRF 回调函数接口
// 任何想要接收 VRF 随机数的合约都必须实现此接口
interface IVRFConsumer {
    // VRF 回调函数
    // requestId: 请求 ID
    // randomWords: 随机数数组
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) external;
}

// ==================== Mock VRF 协调器实现 ====================
// 模拟 Chainlink VRF Coordinator 的行为
// 注意：此合约仅用于本地测试，使用伪随机数生成，不安全！
contract MockVRFCoordinator is IMockVRFCoordinator {
    // 请求 ID 计数器，每次请求时递增
    uint256 private _requestIdCounter;
    
    // 记录请求对应的消费者合约地址
    // mapping: 键值对存储，key 是 requestId，value 是消费者地址
    mapping(uint256 => address) public requestToConsumer;
    
    // 随机数请求事件，前端可以监听此事件
    event RandomWordsRequested(
        bytes32 keyHash,
        uint256 requestId,
        uint256 preSeed,
        uint256 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords,
        address sender
    );
    
    // 请求随机数
    // 这是模拟的 VRF 请求，不会真正调用 Chainlink 网络
    function requestRandomWords(
        bytes32 keyHash,
        uint256 subId,
        uint16 requestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external override returns (uint256 requestId) {
        // 递增请求 ID 计数器
        requestId = ++_requestIdCounter;
        // 记录哪个合约发起了请求
        requestToConsumer[requestId] = msg.sender;
        
        // 触发事件，通知前端有随机数请求
        emit RandomWordsRequested(
            keyHash,
            requestId,
            uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))), // 预种子
            subId,
            requestConfirmations,
            callbackGasLimit,
            numWords,
            msg.sender
        );
        
        return requestId;
    }
    
    // 模拟 VRF 回调 - 任何人都可以调用此函数来触发随机数回调
    // 在真实环境中，这是由 Chainlink 节点自动调用的
    // requestId: 请求 ID
    // randomWords: 随机数数组
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) external {
        // 查找发起请求的消费者合约
        address consumer = requestToConsumer[requestId];
        // 确保请求存在
        require(consumer != address(0), "Request not found");
        
        // 调用消费者的回调函数，传入随机数
        IVRFConsumer(consumer).fulfillRandomWords(requestId, randomWords);
    }
    
    // 生成伪随机数数组（仅用于测试）
    // numWords: 需要生成的随机数数量
    // seed: 种子值
    // 返回: 随机数数组
    function generateRandomWords(uint32 numWords, uint256 seed) public view returns (uint256[] memory) {
        // 创建动态数组，长度为 numWords
        uint256[] memory randomWords = new uint256[](numWords);
        // 循环生成随机数
        for (uint32 i = 0; i < numWords; i++) {
            // 使用 keccak256 哈希多个区块参数生成伪随机数
            // 注意：这种方式不安全，矿工可以操控
            randomWords[i] = uint256(keccak256(abi.encodePacked(
                block.timestamp,      // 当前区块时间戳
                block.number,         // 当前区块号
                msg.sender,           // 调用者地址
                seed,                 // 种子
                i                     // 索引
            )));
        }
        return randomWords;
    }
}

// ==================== FairChainLottery 彩票合约 ====================
// 去中心化彩票合约 - Mock VRF 版本
// 用于本地测试环境，演示彩票逻辑
// 注意：此合约使用伪随机数，仅用于学习和测试！
contract FairChainLottery is Ownable, IVRFConsumer {
    // 彩票状态枚举
    // OPEN: 开放参与
    // CLOSED: 关闭，等待开启
    // CALCULATING: 正在计算获胜者
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    
    // 当前彩票状态，public 自动生成 getter 函数
    LOTTERY_STATE public lotteryState;

    // 参与者数组，payable 表示可以接收 ETH
    // 存储所有参与彩票的地址
    address payable[] public players;
    
    // 最近的获胜者地址
    address public recentWinner;
    
    // 参与费用（wei 单位）
    uint256 public entryFee;

    // Mock VRF 配置参数
    uint256 public subscriptionId;        // 订阅 ID
    bytes32 public keyHash;               // VRF 密钥哈希
    uint32 public callbackGasLimit = 100000;  // 回调 gas 限制，默认 100000
    uint16 public requestConfirmations = 3;   // 确认数，默认 3 个区块
    uint32 public numWords = 1;               // 请求的随机数数量，默认 1 个
    uint256 public latestRequestId;           // 最新的请求 ID
    
    // VRF 协调器合约接口
    IMockVRFCoordinator public vrfCoordinator;

    // 事件定义，前端可以监听这些事件
    event LotteryStarted();                                    // 彩票开启事件
    event LotteryEnded(uint256 requestId);                     // 彩票结束事件
    event WinnerPicked(address indexed winner, uint256 amount); // 获胜者选出事件
    event PlayerEntered(address indexed player, uint256 amount); // 玩家参与事件

    // 构造函数：初始化合约
    // _vrfCoordinator: VRF 协调器合约地址
    // _subscriptionId: 订阅 ID
    // _keyHash: VRF 密钥哈希
    // _entryFee: 参与费用
    constructor(
        address _vrfCoordinator,
        uint256 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) Ownable(msg.sender) {  // 调用父合约构造函数，设置所有者为部署者
        // 初始化 VRF 协调器接口
        vrfCoordinator = IMockVRFCoordinator(_vrfCoordinator);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        // 初始状态为关闭
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    // 参与彩票函数
    // payable: 允许接收 ETH
    function enter() public payable {
        // 检查彩票是否开放
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        // 检查发送的 ETH 是否足够
        require(msg.value >= entryFee, "Not enough ETH");
        // 将参与者添加到数组
        players.push(payable(msg.sender));
        // 触发参与事件
        emit PlayerEntered(msg.sender, msg.value);
    }

    // 开始彩票（仅所有者可以调用）
    // onlyOwner 修饰器限制只有所有者可以调用
    function startLottery() external onlyOwner {
        // 检查当前状态是否为关闭
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        // 设置状态为开放
        lotteryState = LOTTERY_STATE.OPEN;
        // 触发开启事件
        emit LotteryStarted();
    }

    // 结束彩票并请求随机数（仅所有者可以调用）
    function endLottery() external onlyOwner {
        // 检查彩票是否开放
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        // 检查是否有参与者
        require(players.length > 0, "No players in lottery");
        // 设置状态为计算中
        lotteryState = LOTTERY_STATE.CALCULATING;

        // 向 VRF 协调器请求随机数
        latestRequestId = vrfCoordinator.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        
        // 触发结束事件
        emit LotteryEnded(latestRequestId);
    }

    // VRF 回调函数 - 由 MockVRFCoordinator 调用
    // 这是 VRF 返回随机数时调用的函数
    // 第一个参数是 requestId，这里用 _ 表示我们不使用它
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) external override {
        // 检查状态是否为计算中
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");
        // 检查调用者是否是 VRF 协调器（防止恶意调用）
        require(msg.sender == address(vrfCoordinator), "Only coordinator can fulfill");

        // 使用随机数计算获胜者索引
        // randomWords[0] % players.length 确保索引在有效范围内
        uint256 winnerIndex = randomWords[0] % players.length;
        // 获取获胜者地址
        address payable winner = players[winnerIndex];
        // 记录获胜者
        recentWinner = winner;

        // 获取合约当前余额（即奖金总额）
        uint256 prizeAmount = address(this).balance;
        
        // 重置参与者数组，清空所有参与者
        players = new address payable[](0);
        // 设置状态为关闭，准备下一轮
        lotteryState = LOTTERY_STATE.CLOSED;

        // 发送奖金给获胜者
        // call{value: ...} 是推荐的 ETH 发送方式
        (bool sent, ) = winner.call{value: prizeAmount}("");
        // 确保发送成功
        require(sent, "Failed to send ETH to winner");
        
        // 触发获胜者事件
        emit WinnerPicked(winner, prizeAmount);
    }

    // 获取所有参与者地址
    // view: 不修改状态
    // returns (address payable[] memory): 返回参与者数组
    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
    
    // 获取合约当前余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    // 获取参与者数量
    function getPlayerCount() external view returns (uint256) {
        return players.length;
    }
}

// ==================== 合约设计要点说明 ====================
//
// 1. 与原版 day22 的区别:
//    - 原版: 使用 @chainlink/contracts 外部依赖
//    - 此版本: 所有依赖内联，无需 npm 包
//
// 2. Mock VRF 工作原理:
//    - 部署 MockVRFCoordinator 合约
//    - 部署 FairChainLottery，传入 MockVRFCoordinator 地址
//    - 调用 endLottery() 请求随机数
//    - 手动调用 MockVRFCoordinator.fulfillRandomWords() 触发回调
//    - 或者编写脚本自动触发回调
//
// 3. 安全警告:
//    - 此版本使用伪随机数，不安全！
//    - 生产环境必须使用真实的 Chainlink VRF
//    - 仅用于本地开发和测试
//
// 4. 使用流程:
//    1. 部署 MockVRFCoordinator
//    2. 部署 FairChainLottery，传入 MockVRFCoordinator 地址
//    3. startLottery() - 开启彩票
//    4. 用户调用 enter() 参与（需支付 entryFee）
//    5. endLottery() - 结束并请求随机数
//    6. MockVRFCoordinator.generateRandomWords() 生成随机数
//    7. MockVRFCoordinator.fulfillRandomWords() 触发回调
//    8. 奖金自动发送给获胜者
//
// 5. 关键知识点:
//    - enum: 枚举类型，定义有限的状态集合
//    - mapping: 键值对存储
//    - array: 数组存储
//    - event: 事件，用于前端监听
//    - modifier: 修饰器，复用代码逻辑
//    - interface: 接口，定义函数签名
//    - payable: 允许接收 ETH
//    - view/pure: 不修改状态的函数
//    - override: 重写父合约函数
//    - keccak256: 哈希函数，生成伪随机数
//    - abi.encodePacked: 编码多个参数
//
// 6. 测试建议:
//    - 使用 Hardhat 或 Foundry 进行测试
//    - 编写脚本自动化第 6-7 步
//    - 测试边界情况：无参与者、单参与者、多参与者
