// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EnhancedSimpleEscrow - 具有超时、取消和事件的安全托管合约（区块链版淘宝担保）
contract EnhancedSimpleEscrow {
    // ==================== 交易状态枚举：控制整个交易流程 ====================
    enum EscrowState { 
        AWAITING_PAYMENT,  // 0: 等待买家付款（初始状态）
        AWAITING_DELIVERY, // 1: 买家已付款，等待收货确认
        COMPLETE,          // 2: 交易完成，钱已打给卖家
        DISPUTED,          // 3: 交易有纠纷，等待仲裁
        CANCELLED         // 4: 交易取消，钱已退给买家
    }

    // ==================== 状态变量：存储所有交易数据 ====================
    address public immutable buyer;    // 买家地址（部署时确定，不可改）
    address public immutable seller;   // 卖家地址（部署时确定，不可改）
    address public immutable arbiter;  // 仲裁员地址（部署时确定，不可改）

    uint256 public amount;             // 交易金额（买家付的钱）
    EscrowState public state;          // 当前交易状态
    uint256 public depositTime;        // 买家付款的时间戳
    uint256 public deliveryTimeout;    // 收货超时时间（秒，比如7天=604800秒）

    // ==================== 事件：记录所有操作，链上可查、透明 ====================
    event PaymentDeposited(address indexed buyer, uint256 amount); // 买家付款
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount); // 买家确认收货
    event DisputeRaised(address indexed initiator); // 发起纠纷
    event DisputeResolved(address indexed arbiter, address indexed recipient, uint256 amount); // 解决纠纷
    event EscrowCancelled(address indexed initiator); // 交易取消
    event DeliveryTimeoutReached(address indexed buyer); // 超时自动取消

    // ==================== 构造函数：部署合约时初始化 ====================
    constructor(
        address _seller,        // 卖家地址
        address _arbiter,       // 仲裁员地址
        uint256 _deliveryTimeout // 收货超时时间（秒，比如7天=604800）
    ) {
        require(_deliveryTimeout > 0, "Delivery timeout must be greater than zero");

        buyer = msg.sender; // 部署合约的人就是买家
        seller = _seller;
        arbiter = _arbiter;
        state = EscrowState.AWAITING_PAYMENT; // 初始状态：等付款
        deliveryTimeout = _deliveryTimeout;
    }

    // ==================== 禁止直接转账：防止乱打钱 ====================
    receive() external payable {
        revert("Direct payments not allowed");
    }

    // ==================== 功能1：买家付款（核心功能） ====================
    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer can deposit"); // 只有买家能付钱
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid"); // 必须是等付款状态
        require(msg.value > 0, "Amount must be greater than zero"); // 必须付大于0的钱

        amount = msg.value; // 记录交易金额
        state = EscrowState.AWAITING_DELIVERY; // 状态改成等收货
        depositTime = block.timestamp; // 记录付款时间
        emit PaymentDeposited(buyer, amount); // 触发付款事件
    }

    // ==================== 功能2：买家确认收货，打钱给卖家 ====================
    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer can confirm"); // 只有买家能确认
        require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery state"); // 必须是等收货状态

        state = EscrowState.COMPLETE; // 状态改成交易完成

        // ✅ 用call替代弃用的transfer，加require保证转账成功（零警告）
        (bool success, ) = payable(seller).call{value: amount}("");
        require(success, "Failed to send ETH to seller");

        emit DeliveryConfirmed(buyer, seller, amount); // 触发确认收货事件
    }

    // ==================== 功能3：买卖双方发起纠纷 ====================
    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized"); // 只有买卖双方能发起
        require(state == EscrowState.AWAITING_DELIVERY, "Can't dispute now"); // 必须是等收货状态

        state = EscrowState.DISPUTED; // 状态改成纠纷中
        emit DisputeRaised(msg.sender); // 触发纠纷事件
    }

    // ==================== 功能4：仲裁员解决纠纷，决定钱给谁 ====================
    function resolveDispute(bool _releaseToSeller) external {
        require(msg.sender == arbiter, "Only arbiter can resolve"); // 只有仲裁员能解决
        require(state == EscrowState.DISPUTED, "No dispute to resolve"); // 必须是纠纷状态

        state = EscrowState.COMPLETE; // 状态改成交易完成

        if (_releaseToSeller) {
            // 钱给卖家
            (bool success, ) = payable(seller).call{value: amount}("");
            require(success, "Failed to send ETH to seller");
            emit DisputeResolved(arbiter, seller, amount);
        } else {
            // 钱退给买家
            (bool success, ) = payable(buyer).call{value: amount}("");
            require(success, "Failed to send ETH to buyer");
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }

    // ==================== 功能5：买家超时未确认，自动取消交易，退钱 ====================
    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer can trigger timeout cancellation"); // 只有买家能触发
        require(state == EscrowState.AWAITING_DELIVERY, "Cannot cancel in current state"); // 必须是等收货状态
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached"); // 必须超时

        state = EscrowState.CANCELLED; // 状态改成取消

        
        (bool success, ) = payable(buyer).call{value: address(this).balance}("");
        require(success, "Failed to refund buyer");

        emit EscrowCancelled(buyer); // 触发取消事件
        emit DeliveryTimeoutReached(buyer); // 触发超时事件
    }

    // ==================== 功能6：买卖双方同意，取消交易，退钱 ====================
    function cancelMutual() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized"); // 只有买卖双方能发起
        require(
            state == EscrowState.AWAITING_DELIVERY || state == EscrowState.AWAITING_PAYMENT,
            "Cannot cancel now"
        ); // 只能在等付款/等收货状态取消

        EscrowState previousState = state;
        state = EscrowState.CANCELLED; // 状态改成取消

        if (previousState == EscrowState.AWAITING_DELIVERY) {
            // 如果已经付款，把钱退给买家
            (bool success, ) = payable(buyer).call{value: address(this).balance}("");
            require(success, "Failed to refund buyer");
        }

        emit EscrowCancelled(msg.sender); // 触发取消事件
    }

    // ==================== 功能7：查询剩余收货时间（秒） ====================
    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) return 0; // 不是等收货状态，返回0
        if (block.timestamp >= depositTime + deliveryTimeout) return 0; // 超时，返回0

        // 返回剩余时间：超时时间 - 当前时间
        return (depositTime + deliveryTimeout) - block.timestamp;
    }
}