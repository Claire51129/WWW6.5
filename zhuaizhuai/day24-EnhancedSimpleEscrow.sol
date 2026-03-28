// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EnhancedSimpleEscrow - 具有超时、取消和事件的安全托管合约
contract EnhancedSimpleEscrow {

    // 托管状态枚举（状态机核心）
    enum EscrowState { 
        AWAITING_PAYMENT,   // 等待买家付款
        AWAITING_DELIVERY,  // 已付款，等待交付
        COMPLETE,           // 完成交易
        DISPUTED,           // 争议中
        CANCELLED           // 已取消
    }

    address public immutable buyer;   // 买家（部署合约的人）
    address public immutable seller;  // 卖家
    address public immutable arbiter; // 仲裁者（第三方）

    uint256 public amount; // 托管金额
    EscrowState public state; // 当前状态
    uint256 public depositTime; // 存款时间
    uint256 public deliveryTimeout; // 超时时间（秒）

    // ===== 事件 =====
    event PaymentDeposited(address indexed buyer, uint256 amount); // 存款事件
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount); // 确认收货
    event DisputeRaised(address indexed initiator); // 发起争议
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount); // 争议解决
    event EscrowCancelled(address indexed initiator); // 取消
    event DeliveryTimeoutReached(address indexed buyer); // 超时

    // ===== 构造函数 =====
    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {

        require(_deliveryTimeout > 0, "Delivery timeout must be greater than zero"); // 超时时间必须大于0

        buyer = msg.sender; // 部署者是买家
        seller = _seller; // 设置卖家
        arbiter = _arbiter; // 设置仲裁者

        state = EscrowState.AWAITING_PAYMENT; // 初始状态：等待付款

        deliveryTimeout = _deliveryTimeout; // 设置交付超时时间
    }

    // 禁止直接转账（防止绕过逻辑）
    receive() external payable {
        revert("Direct payments not allowed"); // 拒绝直接发送ETH
    }

    // ===== 买家存钱 =====
    function deposit() external payable {

        require(msg.sender == buyer, "Only buyer can deposit"); // 只有买家可以存钱
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid"); // 必须在未付款状态
        require(msg.value > 0, "Amount must be greater than zero"); // 金额必须 > 0

        amount = msg.value; // 记录金额
        state = EscrowState.AWAITING_DELIVERY; // 状态变为等待交付
        depositTime = block.timestamp; // 记录时间

        emit PaymentDeposited(buyer, amount); // 触发事件
    }

    // ===== 买家确认收货 =====
    function confirmDelivery() external {

        require(msg.sender == buyer, "Only buyer can confirm"); // 只有买家确认
        require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery state"); // 必须在交付阶段

        state = EscrowState.COMPLETE; // 状态改为完成

        payable(seller).transfer(amount); // 把钱转给卖家

        emit DeliveryConfirmed(buyer, seller, amount); // 触发事件
    }

    // ===== 发起争议 =====
    function raiseDispute() external {

        require(msg.sender == buyer || msg.sender == seller, "Not authorized"); // 买家或卖家都可以
        require(state == EscrowState.AWAITING_DELIVERY, "Can't dispute now"); // 只能在交付阶段

        state = EscrowState.DISPUTED; // 状态改为争议中

        emit DisputeRaised(msg.sender); // 触发事件
    }

    // ===== 仲裁解决争议 =====
    function resolveDispute(bool _releaseToSeller) external {

        require(msg.sender == arbiter, "Only arbiter can resolve"); // 只有仲裁者
        require(state == EscrowState.DISPUTED, "No dispute to resolve"); // 必须有争议

        state = EscrowState.COMPLETE; // 结束状态

        if (_releaseToSeller) {
            payable(seller).transfer(amount); // 钱给卖家
            emit DisputeResolved(arbiter, seller, amount);
        } else {
            payable(buyer).transfer(amount); // 钱退给买家
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }

    // ===== 超时取消（买家退款） =====
    function cancelAfterTimeout() external {

        require(msg.sender == buyer, "Only buyer can trigger timeout cancellation"); // 只有买家
        require(state == EscrowState.AWAITING_DELIVERY, "Cannot cancel in current state"); // 必须在交付阶段

        require(
            block.timestamp >= depositTime + deliveryTimeout, 
            "Timeout not reached"
        ); // 必须达到超时

        state = EscrowState.CANCELLED; // 状态改为取消

        payable(buyer).transfer(address(this).balance); // 把所有钱退给买家

        emit EscrowCancelled(buyer); // 触发取消事件
        emit DeliveryTimeoutReached(buyer); // 触发超时事件
    }

    // ===== 双方协商取消 =====
    function cancelMutual() external {

        require(msg.sender == buyer || msg.sender == seller, "Not authorized"); // 买家或卖家都可以触发

        require(
            state == EscrowState.AWAITING_DELIVERY || 
            state == EscrowState.AWAITING_PAYMENT,
            "Cannot cancel now"
        ); // 只能在未完成前

        EscrowState previousState = state; // 记录旧状态

        state = EscrowState.CANCELLED; // 设置为取消

        if (previousState == EscrowState.AWAITING_DELIVERY) {
            payable(buyer).transfer(address(this).balance); // 如果已经付款，退款给买家
        }

        emit EscrowCancelled(msg.sender); // 触发事件
    }

    // ===== 查询剩余时间 =====
    function getTimeLeft() external view returns (uint256) {

        if (state != EscrowState.AWAITING_DELIVERY) return 0; // 非交付状态直接返回0

        if (block.timestamp >= depositTime + deliveryTimeout) return 0; // 已超时

        return (depositTime + deliveryTimeout) - block.timestamp; // 返回剩余秒数
    }
}
