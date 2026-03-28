// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
contract EnhancedSimpleEscrow {
	enum EscrowState { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, DISPUTED, CANCELLED }
	// Variables not mutable
	address public immutable buyer;
	address public immutable seller;
	address public immutable arbiter;
	uint256 public amount;
	EscrowState public state;
	uint256 public depositTime;
	// in seconds
	uint256 public deliveryTimeout;
    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(address indexed initiator);
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);
    event EscrowCancelled(address indexed initiator);
    event DeliveryTimeoutReached(address indexed buyer);
	constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
		require(_deliveryTimeout > 0, "Invalid delivery timeout");
		buyer = msg.sender;
		seller = _seller;
		arbiter = _arbiter;
		state = EscrowState.AWAITING_PAYMENT;
		deliveryTimeout = _deliveryTimeout;
	}
	// block receive()
	receive() external payable {
		revert("Direct payments not allowed");
	}
	// Only buyer can deposit
	function deposit() external payable {
		require(msg.sender == buyer, "Not buyer");
		require(state == EscrowState.AWAITING_PAYMENT, "Already paid");
		require(msg.value > 0, "Invalid amount");
		amount = msg.value;
		state = EscrowState.AWAITING_DELIVERY;
		depositTime = block.timestamp;
		emit PaymentDeposited(buyer, amount);
	}
	// Only buyer can confirm delivery
	function confirmDelivery() external {
		require(msg.sender == buyer, "Not buyer");
		require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery");
		state = EscrowState.COMPLETE;
		(bool success, ) = payable(seller).call{value:amount}("");
		require(success, "Fail to transfer");
		emit DeliveryConfirmed(buyer, seller, amount);
	}
	// Both buyer and seller can raise dispute
	function raiseDispute() external {
		require(msg.sender == buyer || msg.sender == seller, "Unauthorized");
		require(state == EscrowState.AWAITING_DELIVERY, "Cannot dispute");
		state = EscrowState.DISPUTED;
		emit DisputeRaised(msg.sender);
	}
	// Only arbiter can resolve dispute
	function resolveDispute(bool _releaseToSeller) external {
		require(msg.sender == arbiter, "Not arbiter");
		require(state == EscrowState.DISPUTED, "Not in dispute");
		state = EscrowState.COMPLETE;
		if (_releaseToSeller) {
			(bool success, ) = payable(seller).call{value:amount}("");
			require(success, "Fail to transfer");
			emit DisputeResolved(arbiter, seller, amount);
		} else {
			(bool success, ) = payable(buyer).call{value:amount}("");
			require(success, "Fail to transfer");
			emit DisputeResolved(arbiter, buyer, amount);
		}
	}
	// Only buyer can cancel after timeout
	function cancelAfterTimeout() external {
		require(msg.sender == buyer, "Not buyer");
		require(state == EscrowState.AWAITING_DELIVERY, "Cannot cancel");
		require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");
		state = EscrowState.CANCELLED;
		(bool success, ) = payable(buyer).call{value:amount}("");
		require(success, "Fail to transfer");
		emit EscrowCancelled(buyer);
		emit DeliveryTimeoutReached(buyer);
	}
	// Buyer or seller can cancel on their side without mutual agreement
	function cancelMutual() external {
		require(msg.sender == buyer || msg.sender == seller, "Unauthorized");
		require(state == EscrowState.AWAITING_DELIVERY || state == EscrowState.AWAITING_PAYMENT, "Cannot cancel");
		EscrowState previous = state;
		state = EscrowState.CANCELLED;
		if (previous == EscrowState.AWAITING_DELIVERY) {
			(bool success, ) = payable(buyer).call{value:amount}("");
			require(success, "Fail to transfer");
		}
		emit EscrowCancelled(msg.sender);
	}
	// Display time before timeout
	function getTimeLeft() external view returns (uint256) {
		if (state != EscrowState.AWAITING_DELIVERY) {
			return 0;
		}
		if (block.timestamp >= depositTime + deliveryTimeout) {
			return 0;
		}
		return (depositTime + deliveryTimeout - block.timestamp);
	}
}