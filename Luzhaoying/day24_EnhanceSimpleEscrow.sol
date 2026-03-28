// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EnhancedSimpleEscrow - 具有超时、取消和事件的安全托管合约
contract EnhancedSimpleEscrow {
    enum EscrowState { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, DISPUTED, CANCELLED }

    address public immutable buyer;
    address public immutable seller;
    address public immutable arbiter;

    uint256 public amount;
    EscrowState public state;
    uint256 public depositTime;
    uint256 public deliveryTimeout; // 存款后的持续时间（以秒为单位）

    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(address indexed initiator);
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);
    event EscrowCancelled(address indexed initiator);
    event DeliveryTimeoutReached(address indexed buyer);

    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        require(_deliveryTimeout > 0, "Delivery timeout must be greater than zero");
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        state = EscrowState.AWAITING_PAYMENT;
        deliveryTimeout = _deliveryTimeout;
    }

    receive() external payable {
        revert("Direct payments not allowed");
    }

    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer can deposit");
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");
        require(msg.value > 0, "Amount must be greater than zero");

        amount = msg.value;
        state = EscrowState.AWAITING_DELIVERY;
        depositTime = block.timestamp;
        emit PaymentDeposited(buyer, amount);
    }

    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer can confirm");
        require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery state");

        // --- 优化开始: 使用 Checks-Effects-Interactions 模式 ---
        state = EscrowState.COMPLETE; // 1. 先更新状态 (Effect)

        // 2. 再进行外部调用 (Interaction)
        (bool success, ) = payable(seller).call{value: amount}("");
        require(success, "Transfer to seller failed");
        // --- 优化结束 ---

        emit DeliveryConfirmed(buyer, seller, amount);
    }

    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(state == EscrowState.AWAITING_DELIVERY, "Can't dispute now");

        state = EscrowState.DISPUTED;
        emit DisputeRaised(msg.sender);
    }

    function resolveDispute(bool _releaseToSeller) external {
        require(msg.sender == arbiter, "Only arbiter can resolve");
        require(state == EscrowState.DISPUTED, "No dispute to resolve");

        // --- 使用 Checks-Effects-Interactions 模式，防御重入攻击 ---
        state = EscrowState.COMPLETE; // 1. 先更新状态 (Effect)
        
        address recipient = _releaseToSeller ? seller : buyer;
        
        // 2. 再进行外部调用 (Interaction)
        (bool success, ) = payable(recipient).call{value: amount}("");
        require(success, "Transfer failed");
   

        emit DisputeResolved(arbiter, recipient, amount);
    }

    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer can trigger timeout cancellation");
        require(state == EscrowState.AWAITING_DELIVERY, "Cannot cancel in current state");
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");

        // --- 使用 Checks-Effects-Interactions 模式，防御重入攻击 ---
        state = EscrowState.CANCELLED; // 1. 先更新状态 (Effect)

        // 2. 再进行外部调用 (Interaction)
        (bool success, ) = payable(buyer).call{value: address(this).balance}("");
        require(success, "Refund to buyer failed");
        // --- 优化结束 ---

        emit EscrowCancelled(buyer);
        emit DeliveryTimeoutReached(buyer);
    }

    function cancelMutual() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(
            state == EscrowState.AWAITING_DELIVERY || state == EscrowState.AWAITING_PAYMENT,
            "Cannot cancel now"
        );

        EscrowState previousState = state;
        // --- 使用 Checks-Effects-Interactions 模式，防御重入攻击 ---
        state = EscrowState.CANCELLED; // 1. 先更新状态 (Effect)

        if (previousState == EscrowState.AWAITING_DELIVERY) {
            // 2. 再进行外部调用 (Interaction)
            (bool success, ) = payable(buyer).call{value: address(this).balance}("");
            require(success, "Refund to buyer failed");
        }
        // --- 优化结束 ---

        emit EscrowCancelled(msg.sender);
    }

    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;
        return (depositTime + deliveryTimeout) - block.timestamp;
    }
}

