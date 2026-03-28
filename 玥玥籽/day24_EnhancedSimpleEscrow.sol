// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EnhancedSimpleEscrow {

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

    struct RefundProposal {
        uint256 refundPercent;
        bool pending;
    }
    RefundProposal public refundProposal;

    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(address indexed initiator);
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);
    event EscrowCancelled(address indexed initiator);
    event DeliveryTimeoutReached(address indexed buyer);
    event PartialRefundProposed(address indexed seller, uint256 refundPercent);
    event PartialRefundExecuted(uint256 buyerAmount, uint256 sellerAmount);

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller");
        _;
    }

    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only arbiter");
        _;
    }

    modifier inState(EscrowState _state) {
        require(state == _state, "Invalid state for this action");
        _;
    }

    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        require(_seller != address(0) && _arbiter != address(0), "Invalid address");
        require(_seller != msg.sender, "Buyer and seller cannot be same");
        require(_deliveryTimeout > 0, "Timeout must be positive");
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        deliveryTimeout = _deliveryTimeout;
        state = EscrowState.AWAITING_PAYMENT;
    }

    function deposit() external payable onlyBuyer inState(EscrowState.AWAITING_PAYMENT) {
        require(msg.value > 0, "Amount must be positive");
        amount = msg.value;
        state = EscrowState.AWAITING_DELIVERY;
        depositTime = block.timestamp;
        emit PaymentDeposited(buyer, amount);
    }

    function confirmDelivery() external onlyBuyer inState(EscrowState.AWAITING_DELIVERY) {
        state = EscrowState.COMPLETE;
        payable(seller).transfer(amount);
        emit DeliveryConfirmed(buyer, seller, amount);
    }

    function raiseDispute() external inState(EscrowState.AWAITING_DELIVERY) {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        state = EscrowState.DISPUTED;
        emit DisputeRaised(msg.sender);
    }

    function resolveDispute(bool releaseToSeller) external onlyArbiter inState(EscrowState.DISPUTED) {
        state = EscrowState.COMPLETE;
        if (releaseToSeller) {
            payable(seller).transfer(amount);
            emit DisputeResolved(arbiter, seller, amount);
        } else {
            payable(buyer).transfer(amount);
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }

    function cancelAfterTimeout() external onlyBuyer inState(EscrowState.AWAITING_DELIVERY) {
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");
        state = EscrowState.CANCELLED;
        payable(buyer).transfer(address(this).balance);
        emit EscrowCancelled(buyer);
        emit DeliveryTimeoutReached(buyer);
    }

    function cancelMutual() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(
            state == EscrowState.AWAITING_DELIVERY || state == EscrowState.AWAITING_PAYMENT,
            "Cannot cancel in current state"
        );
        EscrowState prev = state;
        state = EscrowState.CANCELLED;
        if (prev == EscrowState.AWAITING_DELIVERY) {
            payable(buyer).transfer(address(this).balance);
        }
        emit EscrowCancelled(msg.sender);
    }

    function proposePartialRefund(uint256 _refundPercent) external onlySeller inState(EscrowState.AWAITING_DELIVERY) {
        require(_refundPercent > 0 && _refundPercent < 100, "Percent must be 1-99");
        refundProposal = RefundProposal({
            refundPercent: _refundPercent,
            pending: true
        });
        emit PartialRefundProposed(seller, _refundPercent);
    }

    function acceptPartialRefund() external onlyBuyer inState(EscrowState.AWAITING_DELIVERY) {
        require(refundProposal.pending, "No pending refund proposal");

        uint256 buyerAmount = (amount * refundProposal.refundPercent) / 100;
        uint256 sellerAmount = amount - buyerAmount;

        refundProposal.pending = false;
        state = EscrowState.COMPLETE;

        if (buyerAmount > 0) payable(buyer).transfer(buyerAmount);
        if (sellerAmount > 0) payable(seller).transfer(sellerAmount);

        emit PartialRefundExecuted(buyerAmount, sellerAmount);
    }

    function cancelRefundProposal() external onlySeller {
        require(refundProposal.pending, "No pending proposal");
        refundProposal.pending = false;
    }

    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;
        return (depositTime + deliveryTimeout) - block.timestamp;
    }

    receive() external payable {
        revert("Direct payments not allowed, use deposit()");
    }
}
