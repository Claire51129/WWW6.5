// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ==========================================
// 1. 骨架：所有抽屉的摆放图纸 (Storage Layout)
// ==========================================
contract SubscriptionStorageLayout {
    address public logicContract; // 0号抽屉：放当前大脑的地址
    address public owner;         // 1号抽屉：放老板的地址

    // 2号抽屉：定义“订阅单”长什么样
    struct Subscription {
        uint8 planId;      // 套餐编号（比如 1、2、3）
        uint256 expiry;    // 会员到期时间戳
        bool paused;       // 账户是否被冻结
    }

    // 3、4、5号抽屉：三大账本
    mapping(address => Subscription) public subscriptions; // 记每个人的订阅单
    mapping(uint8 => uint256) public planPrices;           // 记每个套餐卖多少钱
    mapping(uint8 => uint256) public planDuration;         // 记每个套餐包含多少天
}

// ==========================================
// 2. 外壳：永远不死的代理合约 (Proxy)
// ==========================================
contract SubscriptionStorage is SubscriptionStorageLayout {
    // 保安：只有老板能按升级按钮
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // 开机程序：出厂时写下老板名字，并装上第一个大脑（V1）
    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;
    }

    // 升级按钮：老板专属，把 0号抽屉里的大脑换成新大脑
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
    }

    // 左门卫（万能路由）：接待所有听不懂的指令
    fallback() external payable {
        address impl = logicContract; // 看一眼 0号抽屉，现在用的是哪个大脑
        require(impl != address(0), "Logic contract not set");

        assembly {
            // 抄下用户的要求
            calldatacopy(0, 0, calldatasize())
            // 灵魂附体，让大脑在家里干活
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            // 抄下大脑干完活的留言
            returndatacopy(0, 0, returndatasize())
            // 成功就送客，失败就骂人
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    // 右门卫：防止有人纯打钱报错
    receive() external payable {}
}

// ==========================================
// 3. 大脑 V1：初创公司的初代逻辑
// ==========================================
// 铁律：大脑必须继承骨架，保证抽屉顺序一模一样！
contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    
    // 老板上架新套餐
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;       // 设定价格
        planDuration[planId] = duration;  // 设定时长
    }

    // 用户花钱买订阅 (payable表示要收钱)
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan"); // 防呆：套餐必须存在
        require(msg.value >= planPrices[planId], "Insufficient payment"); // 防呆：钱必须给够

        // 从账本里拿出当前用户的订阅单
        Subscription storage s = subscriptions[msg.sender];

        // 核心逻辑：续费还是新办？
        if (block.timestamp < s.expiry) {
            // 如果还没过期，直接在旧日期上加时间（续费）
            s.expiry += planDuration[planId];
        } else {
            // 如果过期了或新来的，从今天算起加上套餐时间（新办）
            s.expiry = block.timestamp + planDuration[planId];
        }
        
        s.planId = planId; // 记录买了哪个套餐
        s.paused = false;  // 保证账户是解冻状态
    }

    // 查房：查这人是不是有效会员
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];
        // 必须“没过期” 并且 “没被冻结”，才是 true
        return (block.timestamp < s.expiry && !s.paused);
    }
}

// ==========================================
// 4. 大脑 V2：公司做大后升级的新逻辑
// ==========================================
contract SubscriptionLogicV2 is SubscriptionStorageLayout {
    
    // ----------- 完美抄袭 V1 的部分 -----------
    // (在真实的开发里，我们会直接让 V2 继承 V1，这里为了让你看懂，全抄一遍)
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");

        Subscription storage s = subscriptions[msg.sender];
        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId];
        } else {
            s.expiry = block.timestamp + planDuration[planId];
        }
        s.planId = planId;
        s.paused = false;
    }

    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }

    // ----------- 新增的 V2 专属功能 -----------
    
    // 冻结账户：把用户的 paused 标志改成 true
    function pauseAccount(address user) external {
        subscriptions[user].paused = true;
    }

    // 解冻账户：改回 false
    function resumeAccount(address user) external {
        subscriptions[user].paused = false;
    }
}
