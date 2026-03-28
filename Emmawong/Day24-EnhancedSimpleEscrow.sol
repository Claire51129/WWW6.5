// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EnhancedSimpleEscrow {
    enum EscrowState { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, DISPUTED, CANCELLED }

    address public immutable buyer;
    address public immutable seller;
    address public immutable arbiter;

    uint256 public amount;
    EscrowState public state;
    uint256 public depositTime;
    uint256 public deliveryTimeout;

    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(address indexed initiator);
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);
    event EscrowCancelled(address indexed initiator);
    event DeliveryTimeoutReached(address indexed buyer);

    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        require(_deliveryTimeout > 0, "Timeout > 0");
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        deliveryTimeout = _deliveryTimeout;
        state = EscrowState.AWAITING_PAYMENT;
    }

    receive() external payable {
        revert("Direct payments not allowed");
    }

    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");
        require(msg.value > 0, "Amount > 0");

        amount = msg.value;
        state = EscrowState.AWAITING_DELIVERY;
        depositTime = block.timestamp;
        emit PaymentDeposited(buyer, amount);
    }

    // ✅ FIXED
    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");
        require(amount > 0, "No amount");

        state = EscrowState.COMPLETE;
        (bool success, ) = payable(seller).call{value: amount}("");
        require(success, "Transfer failed");
        emit DeliveryConfirmed(buyer, seller, amount);
    }

    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Not allowed");
        require(state == EscrowState.AWAITING_DELIVERY, "Can't dispute");
        state = EscrowState.DISPUTED;
        emit DisputeRaised(msg.sender);
    }

    // ✅ FIXED
    function resolveDispute(bool _releaseToSeller) external {
        require(msg.sender == arbiter, "Only arbiter");
        require(state == EscrowState.DISPUTED, "No dispute");
        require(amount > 0, "No amount");

        state = EscrowState.COMPLETE;
        if (_releaseToSeller) {
            (bool s, ) = payable(seller).call{value: amount}("");
            require(s, "Transfer failed");
            emit DisputeResolved(arbiter, seller, amount);
        } else {
            (bool s, ) = payable(buyer).call{value: amount}("");
            require(s, "Transfer failed");
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }

    // ✅ FIXED
    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");
        require(block.timestamp >= depositTime + deliveryTimeout, "Not timeout");
        require(amount > 0, "No amount");

        state = EscrowState.CANCELLED;
        (bool s, ) = payable(buyer).call{value: amount}("");
        require(s, "Transfer failed");
        emit EscrowCancelled(buyer);
        emit DeliveryTimeoutReached(buyer);
    }

    // ✅ FIXED
    function cancelMutual() external {
        require(msg.sender == buyer || msg.sender == seller, "Not allowed");
        require(
            state == EscrowState.AWAITING_PAYMENT ||
            state == EscrowState.AWAITING_DELIVERY,
            "Cannot cancel"
        );

        EscrowState prev = state;
        state = EscrowState.CANCELLED;

        if (prev == EscrowState.AWAITING_DELIVERY) {
            require(amount > 0, "No amount");
            (bool s, ) = payable(buyer).call{value: amount}("");
            require(s, "Transfer failed");
        }

        emit EscrowCancelled(msg.sender);
    }

    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        uint256 end = depositTime + deliveryTimeout;
        return block.timestamp >= end ? 0 : end - block.timestamp;
    }
}