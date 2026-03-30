// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title 去中心化托管合约
 * @dev 实现了基于状态机的交易担保、争议解决及超时退款机制
 */
contract DecentralisedEscrow {
    // --- 类型定义 ---
    enum EscrowState { 
        AWAITING_PAYMENT,   // 等待付款
        AWAITING_DELIVERY,  // 等待交付
        COMPLETE,           // 完成
        DISPUTED,           // 争议中
        CANCELLED           // 已取消
    }

    // --- 状态变量 ---
    address public buyer;
    address public seller;
    address public arbiter;
    uint256 public amount;
    EscrowState public state;
    
    uint256 public depositTime;
    uint256 public deliveryTimeout;

    // --- 事件 ---
    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(address indexed raisedBy);
    event DisputeResolved(address indexed winner, uint256 amount);
    event EscrowCancelled(address indexed canceledBy);
    event DeliveryTimeoutReached(address indexed buyer);

    // --- 修饰符 ---
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this");
        _;
    }

    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only arbiter can call this");
        _;
    }

    modifier inState(EscrowState _state) {
        require(state == _state, "Invalid state for this action");
        _;
    }

    /**
     * @param _seller 卖家地址
     * @param _arbiter 仲裁者地址（中立第三方）
     * @param _deliveryTimeout 交付超时时间（秒）
     */
    constructor(
        address _seller,
        address _arbiter,
        uint256 _deliveryTimeout
    ) {
        require(_seller != address(0), "Invalid seller address");
        require(_arbiter != address(0), "Invalid arbiter address");
        
        buyer = msg.sender; // 部署者默认为买家
        seller = _seller;
        arbiter = _arbiter;
        deliveryTimeout = _deliveryTimeout;
        state = EscrowState.AWAITING_PAYMENT;
    }

    /**
     * @dev 买家存入资金，启动托管
     */
    function deposit() external payable onlyBuyer inState(EscrowState.AWAITING_PAYMENT) {
        require(msg.value > 0, "Must send some ETH");
        amount = msg.value;
        depositTime = block.timestamp;
        state = EscrowState.AWAITING_DELIVERY;
        
        emit PaymentDeposited(buyer, amount);
    }

    /**
     * @dev 买家确认收到货物，资金释放给卖家
     */
    function confirmDelivery() external onlyBuyer inState(EscrowState.AWAITING_DELIVERY) {
        state = EscrowState.COMPLETE;
        
        uint256 payment = amount;
        amount = 0; // 防止重入风险
        
        (bool success, ) = payable(seller).call{value: payment}("");
        require(success, "Transfer to seller failed");
        
        emit DeliveryConfirmed(buyer, seller, payment);
    }

    /**
     * @dev 买家或卖家在交付阶段提起争议
     */
    function raiseDispute() external inState(EscrowState.AWAITING_DELIVERY) {
        require(msg.sender == buyer || msg.sender == seller, "Only parties can raise dispute");
        state = EscrowState.DISPUTED;
        
        emit DisputeRaised(msg.sender);
    }

    /**
     * @dev 仲裁者解决争议，指定获胜方获得资金
     */
    function resolveDispute(address winner) external onlyArbiter inState(EscrowState.DISPUTED) {
        require(winner == buyer || winner == seller, "Winner must be buyer or seller");
        state = EscrowState.COMPLETE;
        
        uint256 payment = amount;
        amount = 0;
        
        (bool success, ) = payable(winner).call{value: payment}("");
        require(success, "Dispute resolution transfer failed");
        
        emit DisputeResolved(winner, payment);
    }

    /**
     * @dev 如果超过交付时限卖家未交付，买家可撤回资金
     */
    function cancelAfterTimeout() external onlyBuyer inState(EscrowState.AWAITING_DELIVERY) {
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not yet reached");
        
        state = EscrowState.CANCELLED;
        uint256 refund = amount;
        amount = 0;
        
        (bool success, ) = payable(buyer).call{value: refund}("");
        require(success, "Refund failed");
        
        emit DeliveryTimeoutReached(buyer);
        emit EscrowCancelled(buyer);
    }

    /**
     * @dev 获取剩余交付时间（秒）
     */
    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        
        uint256 deadline = depositTime + deliveryTimeout;
        if (block.timestamp >= deadline) return 0;
        return deadline - block.timestamp;
    }

    // 防止直接转账入合约
    receive() external payable {
        revert("Use deposit() function to fund escrow");
    }
}