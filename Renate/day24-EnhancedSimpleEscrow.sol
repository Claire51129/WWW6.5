// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EnhancedSimpleEscrow - 具有超时/取消事件的安全托管合约
/// @dev 这是一个增强版的托管合约，支持超时取消、争议仲裁和双方协商取消
/// 用于买卖双方在不信任对方的情况下安全交易
contract EnhancedSimpleEscrow {
    
    // ==================== 枚举：托管状态 ====================
    /// @dev 定义托管合约的各种状态
    enum EscrowState { 
        AWAITING_PAYMENT,   // 等待买家付款
        AWAITING_DELIVERY,  // 等待卖家发货＆买家确认收货
        COMPLETE,           // 交易完成
        DISPUTED,           // 争议中
        CANCELLED           // 已取消
    }

    // ==================== 状态变量 ====================
    
    /// @notice 买家地址
    /// @dev immutable: 只能在构造函数中设置，之后不可更改，节省 gas
    address public immutable buyer;
    
    /// @notice 卖家地址
    /// @dev immutable: 只能在构造函数中设置
    address public immutable seller;
    
    /// @notice 仲裁者地址
    /// @dev 当买卖双方发生争议时，由仲裁者决定资金归属
    address public immutable arbiter;

    /// @notice 托管金额（wei）
    /// @dev 买家存入的金额，在交易完成或取消时释放
    uint256 public amount;
    
    /// @notice 当前托管状态
    /// @dev 使用枚举跟踪交易进度
    EscrowState public state;
    
    /// @notice 存款时间戳
    /// @dev 记录买家存款的时间，用于计算超时
    uint256 public depositTime;
    
    /// @notice 发货超时时间（秒）
    /// @dev 从存款开始计算，超过此时间买家可以取消交易
    uint256 public deliveryTimeout;

    // ==================== 事件 ====================
    /// @dev 事件用于前端监听，记录重要状态变更
    
    /// @notice 买家已存款事件
    /// @param buyer 买家地址
    /// @param amount 存款金额
    event PaymentDeposited(address indexed buyer, uint256 amount);
    
    /// @notice 买家确认收货事件
    /// @param buyer 买家地址
    /// @param seller 卖家地址
    /// @param amount 释放给卖家的金额
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    
    /// @notice 争议发起事件
    /// @param initiator 发起争议的地址（买家或卖家）
    event DisputeRaised(address indexed initiator);
    
    /// @notice 争议解决事件
    /// @param arbiter 仲裁者地址
    /// @param recipient 资金接收方
    /// @param amount 释放金额
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);
    
    /// @notice 托管取消事件
    /// @param initiator 发起取消的地址
    event EscrowCancelled(address indexed initiator);
    
    /// @notice 发货超时事件
    /// @param buyer 买家地址
    event DeliveryTimeoutReached(address indexed buyer);

    // ==================== 构造函数 ====================
    
    /// @notice 创建托管合约
    /// @param _seller 卖家地址
    /// @param _arbiter 仲裁者地址（可以是第三方服务或可信地址）
    /// @param _deliveryTimeout 发货超时时间（秒），必须大于 0
    /// @dev 买家是调用构造函数的地址（msg.sender）
    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        // 检查超时时间必须大于 0
        require(_deliveryTimeout > 0, "Delivery timeout must be greater than zero");
        
        // 设置各方地址
        buyer = msg.sender;     // 调用者就是买家
        seller = _seller;       // 指定的卖家
        arbiter = _arbiter;     // 指定的仲裁者
        
        // 初始状态：等待付款
        state = EscrowState.AWAITING_PAYMENT;
        
        // 设置超时时间
        deliveryTimeout = _deliveryTimeout;
    }

    // ==================== 接收函数 ====================
    
    /// @notice 拒绝直接转账
    /// @dev 防止用户误操作直接转账到合约，必须通过 deposit() 函数存款
    receive() external payable {
        revert("Direct payments not allowed");
    }

    // ==================== 核心功能函数 ====================
    
    /// @notice 买家存款到托管合约
    /// @dev 买家调用此函数并发送 ETH，进入等待发货状态
    /// 要求：
    /// - 只有买家可以调用
    /// - 状态必须是 AWAITING_PAYMENT
    /// - 金额必须大于 0
    function deposit() external payable {
        // 检查调用者是否是买家
        require(msg.sender == buyer, "Only buyer can deposit");
        
        // 检查当前状态是否是等待付款
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");
        
        // 检查存款金额是否大于 0
        require(msg.value > 0, "Amount must be greater than zero");

        // 记录存款金额
        amount = msg.value;
        
        // 更新状态为等待发货
        state = EscrowState.AWAITING_DELIVERY;
        
        // 记录存款时间（用于计算超时）
        depositTime = block.timestamp;
        
        // 触发存款事件
        emit PaymentDeposited(buyer, amount);
    }

    /// @notice 买家确认收货，释放资金给卖家
    /// @dev 买家收到商品后调用此函数，资金转给卖家，交易完成
    /// 要求：
    /// - 只有买家可以调用
    /// - 状态必须是 AWAITING_DELIVERY
    function confirmDelivery() external {
        // 检查调用者是否是买家
        require(msg.sender == buyer, "Only buyer can confirm");
        
        // 检查状态是否是等待发货
        require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery state");

        // 更新状态为完成
        state = EscrowState.COMPLETE;
        
        // 将资金转给卖家
        (bool sent, ) = payable(seller).call{value: amount}("");
        require(sent, "ETH transfer to seller failed");
        
        // 触发确认收货事件
        emit DeliveryConfirmed(buyer, seller, amount);
    }

    /// @notice 发起争议
    /// @dev 当买卖双方发生纠纷时，任何一方可以发起争议，进入仲裁流程
    /// 要求：
    /// - 买家或卖家可以发起
    /// - 状态必须是 AWAITING_DELIVERY
    function raiseDispute() external {
        // 检查调用者是否是买家或卖家
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        
        // 检查状态是否是等待发货
        require(state == EscrowState.AWAITING_DELIVERY, "Can't dispute now");

        // 更新状态为争议中
        state = EscrowState.DISPUTED;
        
        // 触发争议事件
        emit DisputeRaised(msg.sender);
    }

    /// @notice 仲裁者解决争议
    /// @param _releaseToSeller 是否将资金释放给卖家
    /// @dev 仲裁者根据证据决定资金归属
    /// true: 资金给卖家（买家已收货或不诚信）
    /// false: 资金退回买家（卖家未发货或商品有问题）
    /// 要求：
    /// - 只有仲裁者可以调用
    /// - 状态必须是 DISPUTED
    function resolveDispute(bool _releaseToSeller) external {
        // 检查调用者是否是仲裁者
        require(msg.sender == arbiter, "Only arbiter can resolve");
        
        // 检查状态是否是争议中
        require(state == EscrowState.DISPUTED, "No dispute to resolve");

        // 更新状态为完成
        state = EscrowState.COMPLETE;
        
        // 根据仲裁结果释放资金
        if (_releaseToSeller) {
            // 资金给卖家
            (bool sent, ) = payable(seller).call{value: amount}("");
            require(sent, "ETH transfer to seller failed");
            emit DisputeResolved(arbiter, seller, amount);
        } else {
            // 资金退回买家
            (bool sent, ) = payable(buyer).call{value: amount}("");
            require(sent, "ETH transfer to buyer failed");
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }

    /// @notice 超时后买家取消交易
    /// @dev 如果卖家在超时时间内未发货，买家可以取消并取回资金
    /// 要求：
    /// - 只有买家可以调用
    /// - 状态必须是 AWAITING_DELIVERY
    /// - 当前时间必须超过 depositTime + deliveryTimeout
    function cancelAfterTimeout() external {
        // 检查调用者是否是买家
        require(msg.sender == buyer, "Only buyer can trigger timeout cancellation");
        
        // 检查状态是否是等待发货
        require(state == EscrowState.AWAITING_DELIVERY, "Cannot cancel in current state");
        
        // 检查是否已超过超时时间
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");

        // 更新状态为已取消
        state = EscrowState.CANCELLED;
        
        // 将合约余额退回买家
        (bool sent, ) = payable(buyer).call{value: address(this).balance}("");
        require(sent, "ETH refund to buyer failed");
        
        // 触发取消事件
        emit EscrowCancelled(buyer);
        
        // 触发超时事件
        emit DeliveryTimeoutReached(buyer);
    }

    /// @notice 双方协商取消交易
    /// @dev 买卖双方同意取消交易，资金退回买家
    /// 适用场景：
    /// - 交易还未完成，双方同意取消
    /// - 买家还未付款，决定不买了
    /// 要求：
    /// - 买家或卖家可以发起
    /// - 状态必须是 AWAITING_DELIVERY 或 AWAITING_PAYMENT
    function cancelMutual() external {
        // 检查调用者是否是买家或卖家
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        
        // 检查状态是否可以取消
        require(
            state == EscrowState.AWAITING_DELIVERY || state == EscrowState.AWAITING_PAYMENT,
            "Cannot cancel now"
        );

        // 记录之前的状态
        EscrowState previousState = state;
        
        // 更新状态为已取消
        state = EscrowState.CANCELLED;

        // 如果已经存款，退回资金
        if (previousState == EscrowState.AWAITING_DELIVERY) {
            (bool sent, ) = payable(buyer).call{value: address(this).balance}("");
            require(sent, "ETH refund to buyer failed");
        }

        // 触发取消事件
        emit EscrowCancelled(msg.sender);
    }

    // ==================== 查询函数 ====================
    
    /// @notice 获取剩余超时时间
    /// @return 剩余秒数，如果已超时或不在等待发货状态则返回 0
    /// @dev 用于前端显示倒计时
    function getTimeLeft() external view returns (uint256) {
        // 如果不在等待发货状态，返回 0
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        
        // 如果已超时，返回 0
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;
        
        // 返回剩余时间
        return (depositTime + deliveryTimeout) - block.timestamp;
    }
}

// ==================== 合约设计要点说明 ====================
//
// 1. 核心概念:
//    - 托管（Escrow）: 第三方保管资金，直到条件满足才释放
//    - 买家（Buyer）: 付款方，购买商品或服务
//    - 卖家（Seller）: 收款方，提供商品或服务
//    - 仲裁者（Arbiter）: 争议解决方，决定争议时的资金归属
//
// 2. 状态流转:
//    AWAITING_PAYMENT → deposit() → AWAITING_DELIVERY
//                              ↓
//                         cancelMutual()
//                              ↓
//                         CANCELLED
//    
//    AWAITING_DELIVERY → confirmDelivery() → COMPLETE
//                              ↓
//                         raiseDispute()
//                              ↓
//                         DISPUTED → resolveDispute() → COMPLETE
//                              ↓
//                         cancelAfterTimeout()
//                              ↓
//                         CANCELLED
//                              ↓
//                         cancelMutual()
//                              ↓
//                         CANCELLED
//
// 3. 安全机制:
//    - immutable: 关键地址不可更改，防止恶意修改
//    - 状态检查: 每个函数检查当前状态，防止非法操作
//    - 权限控制: require 检查调用者身份
//    - 超时机制: 防止卖家无限期不发货
//    - 拒绝直接转账: 防止误操作
//
// 4. 取消机制对比:
//    ┌─────────────────────┬────────────────────────┬─────────────────────┐
//    │     取消方式        │        触发条件        │      资金去向       │
//    ├─────────────────────┼────────────────────────┼─────────────────────┤
//    │   cancelAfterTimeout │ 买家 + 超时            │ 退回买家            │
//    │   cancelMutual       │ 买家或卖家 + 协商一致  │ 退回买家            │
//    └─────────────────────┴────────────────────────┴─────────────────────┘
//
// 5. 使用流程示例:
//    正常流程：
//    1. 买家部署合约，指定卖家、仲裁者和超时时间
//    2. 买家调用 deposit() 存入资金
//    3. 卖家发货
//    4. 买家收到货物，调用 confirmDelivery()
//    5. 资金转给卖家，交易完成
//    
//    争议流程：
//    1-3 同上
//    4. 发生争议，任意一方调用 raiseDispute()
//    5. 仲裁者调查后调用 resolveDispute(true/false)
//    6. 资金按仲裁结果分配
//    
//    超时取消：
//    1-2 同上
//    3. 卖家迟迟不发货，超过超时时间
//    4. 买家调用 cancelAfterTimeout()
//    5. 资金退回买家
//
// 6. 关键知识点:
//    - immutable: 不可变变量，节省 gas，增强安全
//    - enum: 枚举类型，定义有限状态集合
//    - block.timestamp: 当前区块时间戳（秒）
//    - indexed 事件参数: 可以通过该参数筛选事件
//    - receive(): 接收 ETH 的回调函数
//    - revert(): 回滚交易并返回错误信息
//
// 7. 与简单托管合约的区别:
//    - 增加超时机制，保护买家权益
//    - 增加争议仲裁，解决纠纷
//    - 增加双方协商取消，灵活处理
//    - 增加事件，便于前端监听
//    - 使用 immutable 优化 gas
