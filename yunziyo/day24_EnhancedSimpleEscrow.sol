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
        require(_deliveryTimeout > 0, "Timeout must be > 0");
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        state = EscrowState.AWAITING_PAYMENT;
        deliveryTimeout = _deliveryTimeout;
    }

    receive() external payable {
        revert("Use deposit()");
    }

    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_PAYMENT, "Invalid state");
        require(msg.value > 0, "Value must be > 0");

        amount = msg.value;
        state = EscrowState.AWAITING_DELIVERY;
        depositTime = block.timestamp;
        emit PaymentDeposited(buyer, amount);
    }

    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Invalid state");

        state = EscrowState.COMPLETE;
        uint256 payment = amount;
        amount = 0;

        (bool success, ) = payable(seller).call{value: payment}("");
        require(success, "Transfer failed");

        emit DeliveryConfirmed(buyer, seller, payment);
    }

    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Unauthorized");
        require(state == EscrowState.AWAITING_DELIVERY, "Invalid state");

        state = EscrowState.DISPUTED;
        emit DisputeRaised(msg.sender);
    }

    function resolveDispute(bool _releaseToSeller) external {
        require(msg.sender == arbiter, "Only arbiter");
        require(state == EscrowState.DISPUTED, "No dispute");

        state = EscrowState.COMPLETE;
        uint256 payment = amount;
        amount = 0;

        address recipient = _releaseToSeller ? seller : buyer;
        (bool success, ) = payable(recipient).call{value: payment}("");
        require(success, "Transfer failed");

        emit DisputeResolved(arbiter, recipient, payment);
    }

    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Invalid state");
        require(block.timestamp >= depositTime + deliveryTimeout, "Too early");

        state = EscrowState.CANCELLED;
        uint256 refund = amount;
        amount = 0;

        (bool success, ) = payable(buyer).call{value: refund}("");
        require(success, "Transfer failed");

        emit EscrowCancelled(buyer);
        emit DeliveryTimeoutReached(buyer);
    }

    function cancelBeforePayment() external {
        require(msg.sender == buyer || msg.sender == seller, "Unauthorized");
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");

        state = EscrowState.CANCELLED;
        emit EscrowCancelled(msg.sender);
    }

    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        uint256 expiry = depositTime + deliveryTimeout;
        if (block.timestamp >= expiry) return 0;
        return expiry - block.timestamp;
    }
}
