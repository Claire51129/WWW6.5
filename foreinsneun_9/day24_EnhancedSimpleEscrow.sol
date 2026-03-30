// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract EnhancedSimpleEscrow {
    enum EscrowState {
        AWAITING_PAYMENT,
        AWAITING_DELIVERY,
        COMPLETE,
        DISPUTED,
        CANCELLED
    }
    address public buyer;
    address public seller;
    address public arbiter;
    uint256 public amount;
    EscrowState public state;
    uint256 public depositTime;
    uint256 public deliveryTimeout;
    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(address indexed raisedBy);
    event DisputeResolved(address indexed winner, uint256 amount);
    event EscrowCancelled(address indexed canceledBy);
    event DeliveryTimeoutReached(address indexed buyer);
    event MutualCancellation(address indexed buyer, address indexed seller);
    constructor(
        address _seller,
        address _arbiter,
        uint256 _deliveryTimeout
    ) {
        require(_seller != address(0), "Invalid seller");
        require(_arbiter != address(0), "Invalid arbiter");
        require(_deliveryTimeout > 0, "Invalid timeout");
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        deliveryTimeout = _deliveryTimeout;
        state = EscrowState.AWAITING_PAYMENT;
    }
    receive() external payable {
        revert("Use deposit() function");
    }
    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_PAYMENT, "Wrong state");
        require(msg.value > 0, "Must send ETH");
        amount = msg.value;
        depositTime = block.timestamp;
        state = EscrowState.AWAITING_DELIVERY;
        emit PaymentDeposited(buyer, amount);
    }
    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");
        state = EscrowState.COMPLETE;
        payable(seller).transfer(amount);
        emit DeliveryConfirmed(buyer, seller, amount);
    }
    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Only parties");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");
        state = EscrowState.DISPUTED;
        emit DisputeRaised(msg.sender);
    }
    function resolveDispute(address winner) external {
        require(msg.sender == arbiter, "Only arbiter");
        require(state == EscrowState.DISPUTED, "Not disputed");
        require(winner == buyer || winner == seller, "Invalid winner");
        state = EscrowState.COMPLETE;
        payable(winner).transfer(amount);
        emit DisputeResolved(winner, amount);
    }
    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");
        require(
            block.timestamp >= depositTime + deliveryTimeout,
            "Timeout not reached"
        );
        state = EscrowState.CANCELLED;
        payable(buyer).transfer(amount);
        emit DeliveryTimeoutReached(buyer);
        emit EscrowCancelled(buyer);
    }
    function cancelMutual() external {
        require(msg.sender == buyer || msg.sender == seller, "Only parties");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");
        state = EscrowState.CANCELLED;
        payable(buyer).transfer(amount);
        emit MutualCancellation(buyer, seller);
        emit EscrowCancelled(msg.sender);
    }
    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) {
            return 0;
        }
        uint256 deadline = depositTime + deliveryTimeout;
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }
    function getEscrowInfo() external view returns (
        address _buyer,
        address _seller,
        address _arbiter,
        uint256 _amount,
        EscrowState _state,
        uint256 _timeLeft
    ) {
        uint256 timeLeft = 0;
        if (state == EscrowState.AWAITING_DELIVERY) {
            uint256 deadline = depositTime + deliveryTimeout;
            if (block.timestamp < deadline) {
                timeLeft = deadline - block.timestamp;
            }
        }
        return (buyer, seller, arbiter, amount, state, timeLeft);
    }
}