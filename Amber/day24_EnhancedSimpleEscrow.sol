// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EnhancedSimpleEscrow - 安全增强版托管合约（带防重入）
contract EnhancedSimpleEscrow {

    /// @dev 托管状态枚举
    enum EscrowState { 
        AWAITING_PAYMENT, 
        AWAITING_DELIVERY, 
        COMPLETE, 
        DISPUTED, 
        CANCELLED 
    }

    address public immutable buyer;
    address public immutable seller;
    address public immutable arbiter;

    uint256 public amount;
    EscrowState public state;
    uint256 public depositTime;
    uint256 public deliveryTimeout;

    /// @dev 简易防重入锁
    bool private locked;

    /// ===== 修饰器 =====
    modifier nonReentrant() {
        require(!locked, "Reentrancy detected");
        locked = true;
        _;
        locked = false;
    }

    /// ===== 事件 =====
    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(address indexed initiator);
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);
    event EscrowCancelled(address indexed initiator);
    event DeliveryTimeoutReached(address indexed buyer);

    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        require(_deliveryTimeout > 0, "Invalid timeout");

        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;

        state = EscrowState.AWAITING_PAYMENT;
        deliveryTimeout = _deliveryTimeout;
    }

    /// 禁止直接转账
    receive() external payable {
        revert("Direct payments not allowed");
    }

    /// ===== 核心功能 =====

    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");
        require(msg.value > 0, "Zero amount");

        amount = msg.value;
        depositTime = block.timestamp;
        state = EscrowState.AWAITING_DELIVERY;

        emit PaymentDeposited(buyer, amount);
    }

    function confirmDelivery() external nonReentrant {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Invalid state");

        state = EscrowState.COMPLETE;

        _safeTransfer(seller, amount);

        emit DeliveryConfirmed(buyer, seller, amount);
    }

    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(state == EscrowState.AWAITING_DELIVERY, "Invalid state");

        state = EscrowState.DISPUTED;

        emit DisputeRaised(msg.sender);
    }

    function resolveDispute(bool releaseToSeller) external nonReentrant {
        require(msg.sender == arbiter, "Only arbiter");
        require(state == EscrowState.DISPUTED, "No dispute");

        state = EscrowState.COMPLETE;

        if (releaseToSeller) {
            _safeTransfer(seller, amount);
            emit DisputeResolved(arbiter, seller, amount);
        } else {
            _safeTransfer(buyer, amount);
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }

    function cancelAfterTimeout() external nonReentrant {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Invalid state");
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");

        state = EscrowState.CANCELLED;

        _safeTransfer(buyer, address(this).balance);

        emit EscrowCancelled(buyer);
        emit DeliveryTimeoutReached(buyer);
    }

    function cancelMutual() external nonReentrant {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(
            state == EscrowState.AWAITING_PAYMENT ||
            state == EscrowState.AWAITING_DELIVERY,
            "Cannot cancel"
        );

        EscrowState prev = state;
        state = EscrowState.CANCELLED;

        if (prev == EscrowState.AWAITING_DELIVERY) {
            _safeTransfer(buyer, address(this).balance);
        }

        emit EscrowCancelled(msg.sender);
    }

    /// ===== 工具函数 =====

    function _safeTransfer(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}("");
        require(success, "Transfer failed");
    }

    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;

        return (depositTime + deliveryTimeout) - block.timestamp;
    }
}
