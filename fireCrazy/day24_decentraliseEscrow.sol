// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 增强型去中心化托管合约
 * @notice 实现买卖双方交易安全保障，包含仲裁机制与超时退款功能
 */
contract EnhancedSimpleEscrow {
    // --- 业务状态 ---
    enum EscrowState { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, DISPUTED, CANCELLED }
    EscrowState public state;

    // --- 角色与变量 ---
    address public buyer;
    address public seller;
    address public arbiter;
    
    uint256 public amount;
    uint256 public depositTime;
    uint256 public deliveryTimeout;

    // --- 事件 ---
    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed seller, uint256 amount);
    event DisputeRaised(address indexed initiator);
    event DisputeResolved(address indexed winner, uint256 amount);
    event EscrowCancelled(uint256 amount);

    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        require(_seller != address(0), "Invalid seller address");
        require(_arbiter != address(0), "Invalid arbiter address");
        
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        deliveryTimeout = _deliveryTimeout;
        state = EscrowState.AWAITING_PAYMENT;
    }

    // 强制使用 deposit 函数，拒绝直接转账
    receive() external payable {
        revert("Use deposit() function");
    }

    /**
     * @dev 买家存入资金
     */
    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer can deposit");
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid or wrong state");
        require(msg.value > 0, "Must send ETH");

        amount = msg.value;
        depositTime = block.timestamp;
        state = EscrowState.AWAITING_DELIVERY;

        emit PaymentDeposited(buyer, amount);
    }

    /**
     * @dev 买家确认收货，资金释放给卖家
     */
    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer can confirm");
        require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery stage");

        state = EscrowState.COMPLETE;
        uint256 payment = amount;
        amount = 0; // 清空余额防止重入

        (bool success, ) = payable(seller).call{value: payment}("");
        require(success, "Transfer to seller failed");

        emit DeliveryConfirmed(seller, payment);
    }

    /**
     * @dev 提起争议（买家或卖家均可发起）
     */
    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Only involved parties");
        require(state == EscrowState.AWAITING_DELIVERY, "Cannot dispute at this stage");

        state = EscrowState.DISPUTED;
        emit DisputeRaised(msg.sender);
    }

    /**
     * @dev 仲裁员裁决争议
     */
    function resolveDispute(address winner) external {
        require(msg.sender == arbiter, "Only arbiter can resolve");
        require(state == EscrowState.DISPUTED, "Not in dispute");
        require(winner == buyer || winner == seller, "Invalid winner address");

        state = EscrowState.COMPLETE;
        uint256 payment = amount;
        amount = 0;

        (bool success, ) = payable(winner).call{value: payment}("");
        require(success, "Transfer to winner failed");

        emit DisputeResolved(winner, payment);
    }

    /**
     * @dev 超时自动退款（若卖家未交付且未进入争议状态）
     */
    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer can cancel");
        require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery stage");
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout period not reached");

        state = EscrowState.CANCELLED;
        uint256 refund = amount;
        amount = 0;

        (bool success, ) = payable(buyer).call{value: refund}("");
        require(success, "Refund to buyer failed");

        emit EscrowCancelled(refund);
    }
}
