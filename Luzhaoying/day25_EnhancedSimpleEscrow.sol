// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//具有超时、取消和事件的安全托管合约
//- 持有 ETH 直到买家确认收货
//- 让任何一方在出现问题时提出争议
//- 允许中立的**仲裁人**介入并解决问题
//- 具有内置的**超时逻辑**，这样买家就不会永远被挂起
//- 支持相互取消，如果双方同意取消交易
//- 没有文书工作。没有等待。没有可疑的第三方

/// @title EnhancedSimpleEscrow - 具有超时、取消和事件的安全托管合约
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

    // 错误定义 (Solidity 0.8.4+ 推荐做法，比字符串更省 Gas)
    error DirectPaymentsNotAllowed();
    error OnlyBuyer();
    error AlreadyPaid();
    error AmountMustBeGreaterThanZero();
    error NotInDeliveryState();
    error NotAuthorized();
    error CantDisputeNow();
    error OnlyArbiter();
    error NoDisputeToResolve();
    error TimeoutNotReached();
    error CannotCancelNow();
    error TransferFailed();

    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        require(_deliveryTimeout > 0, "Delivery timeout must be greater than zero");
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        state = EscrowState.AWAITING_PAYMENT;
        deliveryTimeout = _deliveryTimeout;
    }

    receive() external payable {
        revert DirectPaymentsNotAllowed();
    }

    // 内部函数：安全转账，替代 transfer
    function _safeTransfer(address recipient, uint256 _amount) internal {
        // 如果金额为 0，直接返回，避免不必要的调用
        if (_amount == 0) return;

        (bool success, ) = recipient.call{value: _amount}("");
        if (!success) {
            revert TransferFailed();
        }
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

        state = EscrowState.COMPLETE;
        // 优化：使用 _safeTransfer 替代 transfer
        _safeTransfer(seller, amount);
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

        state = EscrowState.COMPLETE;
        address recipient = _releaseToSeller ? seller : buyer;
        
        // 优化：使用 _safeTransfer
        _safeTransfer(recipient, amount);
        emit DisputeResolved(arbiter, recipient, amount);
    }

    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer can trigger timeout cancellation");
        require(state == EscrowState.AWAITING_DELIVERY, "Cannot cancel in current state");
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");

        state = EscrowState.CANCELLED;
        // 优化：使用 address(this).balance 确保提取所有资金（防止重入攻击导致余额变化）
        uint256 balance = address(this).balance;
        _safeTransfer(buyer, balance);
        
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
        state = EscrowState.CANCELLED;

        // 优化：逻辑更清晰，且使用 _safeTransfer
        if (previousState == EscrowState.AWAITING_DELIVERY) {
            uint256 balance = address(this).balance;
            _safeTransfer(buyer, balance);
        }
        // 如果是 AWAITING_PAYMENT，余额为 0，无需转账

        emit EscrowCancelled(msg.sender);
    }

    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;
        return (depositTime + deliveryTimeout) - block.timestamp;
    }
}