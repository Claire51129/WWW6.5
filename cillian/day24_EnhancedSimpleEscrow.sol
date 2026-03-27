// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title EnhancedSimpleEscrow (增强型简单托管合约)
 * @dev 这是一个具有超时退款、争议仲裁、取消交易功能的第三方托管合约。
 */
contract EnhancedSimpleEscrow {
    // 定义托管交易的 5 种状态
    enum EscrowState { 
        AWAITING_PAYMENT,  // 等待买家付款
        AWAITING_DELIVERY, // 买家已付款，等待卖家发货（资金锁在合约中）
        COMPLETE,          // 交易完成（资金已转给卖家）
        DISPUTED,          // 产生争议（等待仲裁者处理）
        CANCELLED          // 交易取消（资金退回买家或未发生）
    }

    // 参与者地址，使用 immutable（不可变）以节省 Gas 并增加安全性
    address public immutable buyer;    // 买家
    address public immutable seller;   // 卖家
    address public immutable arbiter;  // 仲裁者（类似于法官，处理纠纷）

    uint256 public amount;            // 托管的金额
    EscrowState public state;         // 当前合同状态
    uint256 public depositTime;       // 买家存钱的时间戳
    uint256 public deliveryTimeout;   // 约定的收货超时时间（单位：秒）

    // --- 事件 (用于记录链上动作) ---
    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(address indexed initiator);
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);
    event EscrowCancelled(address indexed initiator);
    event DeliveryTimeoutReached(address indexed buyer);

    /**
     * @dev 构造函数：初始化买卖双方和仲裁者
     * @param _seller 卖家地址
     * @param _arbiter 仲裁者地址
     * @param _deliveryTimeout 超时时长（例如：86400 代表 1 天）
     */
    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        require(_deliveryTimeout > 0, "Delivery timeout must be greater than zero");
        buyer = msg.sender; // 部署合约的人默认为买家
        seller = _seller;
        arbiter = _arbiter;
        state = EscrowState.AWAITING_PAYMENT;
        deliveryTimeout = _deliveryTimeout;
    }

    /**
     * @dev 禁止直接向合约转账，必须通过特定的 deposit 函数，以防止逻辑混乱
     */
    receive() external payable {
        revert("Direct payments not allowed");
    }

    /**
     * @notice 买家存钱进入托管合约
     */
    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer can deposit");
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");
        require(msg.value > 0, "Amount must be greater than zero");

        amount = msg.value;
        state = EscrowState.AWAITING_DELIVERY; // 状态转为：等待发货
        depositTime = block.timestamp;          // 记录存款时间，开始计算超时
        emit PaymentDeposited(buyer, amount);
    }

    /**
     * @notice 买家确认收货，资金释放给卖家
     */
    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer can confirm");
        require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery state");

        state = EscrowState.COMPLETE;
        // 【关键】将合约中的钱转给卖家
        payable(seller).transfer(amount);
        emit DeliveryConfirmed(buyer, seller, amount);
    }

    /**
     * @notice 提交争议（买家没收到货，或者卖家发了货但买家不点确认）
     */
    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(state == EscrowState.AWAITING_DELIVERY, "Can't dispute now");

        state = EscrowState.DISPUTED; // 状态转为：争议中
        emit DisputeRaised(msg.sender);
    }

    /**
     * @notice 仲裁者裁决争议
     * @param _releaseToSeller 如果为 true 则钱给卖家，否则钱退给买家
     */
    function resolveDispute(bool _releaseToSeller) external {
        require(msg.sender == arbiter, "Only arbiter can resolve");
        require(state == EscrowState.DISPUTED, "No dispute to resolve");

        state = EscrowState.COMPLETE;
        if (_releaseToSeller) {
            payable(seller).transfer(amount);
            emit DisputeResolved(arbiter, seller, amount);
        } else {
            payable(buyer).transfer(amount);
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }

    /**
     * @notice 超过约定时间卖家未发货，买家强制取消并退款
     */
    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer can trigger timeout cancellation");
        require(state == EscrowState.AWAITING_DELIVERY, "Cannot cancel in current state");
        // 判断是否已经过了约定的超时时间
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");
        state = EscrowState.CANCELLED;
        // 把钱退给买家
        payable(buyer).transfer(address(this).balance);
        emit EscrowCancelled(buyer);
        emit DeliveryTimeoutReached(buyer);
    }

    /**
     * @notice 双方协商一致取消交易
     */
    function cancelMutual() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(
            state == EscrowState.AWAITING_DELIVERY || state == EscrowState.AWAITING_PAYMENT,
            "Cannot cancel now"
        );

        EscrowState previousState = state;
        state = EscrowState.CANCELLED;

        // 如果买家已经存了钱，取消时要退款
        if (previousState == EscrowState.AWAITING_DELIVERY) {
            payable(buyer).transfer(address(this).balance);
        }

        emit EscrowCancelled(msg.sender);
    }

    /**
     * @notice 辅助函数：查看距离超时还剩多少秒
     */
    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;
        return (depositTime + deliveryTimeout) - block.timestamp;
    }
}