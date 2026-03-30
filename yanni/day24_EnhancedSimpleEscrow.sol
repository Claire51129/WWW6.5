// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EnhancedSimpleEscrow - 带超时、争议处理的托管合约
contract EnhancedSimpleEscrow {

    // 托管状态
    enum EscrowState {
        AWAITING_PAYMENT,   // 等待付款
        AWAITING_DELIVERY,  // 等待交付
        COMPLETE,           // 完成
        DISPUTED,           // 争议中
        CANCELLED           // 已取消
    }

    // 角色
    address public immutable buyer;
    address public immutable seller;
    address public immutable arbiter;

    // 金额与状态
    uint256 public amount;
    EscrowState public state;

    // 时间控制
    uint256 public depositTime;
    uint256 public deliveryTimeout;

    // 事件（记录发生了什么）
    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(address indexed initiator);
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);
    event EscrowCancelled(address indexed initiator);
    event DeliveryTimeoutReached(address indexed buyer);

    // 构造函数
    constructor(
        address _seller,
        address _arbiter,
        uint256 _deliveryTimeout
    ) {
        require(_deliveryTimeout > 0, "Timeout must be > 0");

        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;

        state = EscrowState.AWAITING_PAYMENT;
        deliveryTimeout = _deliveryTimeout;
    }

    // 禁止直接转账
    receive() external payable {
        revert("Direct payments not allowed");
    }

    // 买家存钱
    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");
        require(msg.value > 0, "Amount must be > 0");

        amount = msg.value;
        state = EscrowState.AWAITING_DELIVERY;
        depositTime = block.timestamp;

        emit PaymentDeposited(buyer, amount);
    }

    // 确认收货 → 给卖家钱
    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");

        state = EscrowState.COMPLETE;
        payable(seller).transfer(amount);

        emit DeliveryConfirmed(buyer, seller, amount);
    }

    // 发起争议
    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(state == EscrowState.AWAITING_DELIVERY, "Can't dispute");

        state = EscrowState.DISPUTED;
        emit DisputeRaised(msg.sender);
    }

    // 仲裁解决
    function resolveDispute(bool releaseToSeller) external {
        require(msg.sender == arbiter, "Only arbiter");
        require(state == EscrowState.DISPUTED, "No dispute");

        state = EscrowState.COMPLETE;

        if (releaseToSeller) {
            payable(seller).transfer(amount);
            emit DisputeResolved(arbiter, seller, amount);
        } else {
            payable(buyer).transfer(amount);
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }

    // 超时退款
    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");
        require(
            block.timestamp >= depositTime + deliveryTimeout,
            "Timeout not reached"
        );

        state = EscrowState.CANCELLED;
        payable(buyer).transfer(address(this).balance);

        emit EscrowCancelled(buyer);
        emit DeliveryTimeoutReached(buyer);
    }

    // 双方取消,||或者的意思
    function cancelMutual() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(
            state == EscrowState.AWAITING_PAYMENT ||
            state == EscrowState.AWAITING_DELIVERY,
            "Cannot cancel"
        );

        EscrowState previousState = state;
        state = EscrowState.CANCELLED;

        if (previousState == EscrowState.AWAITING_DELIVERY) {
            payable(buyer).transfer(address(this).balance);
        }

        emit EscrowCancelled(msg.sender);
    }

    //  查看剩余时间
    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;

        return (depositTime + deliveryTimeout) - block.timestamp;
    }
}