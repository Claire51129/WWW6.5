// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EnhancedSimpleEscrow - 安全增强版托管合约（带防重入）
contract EnhancedSimpleEscrow {

    // 托管流程的几种状态
    enum EscrowState { 
        AWAITING_PAYMENT,   // 等待买家付款
        AWAITING_DELIVERY,  // 已付款，等待交付 / 等待买家确认
        COMPLETE,           // 交易完成
        DISPUTED,           // 发生纠纷
        CANCELLED           // 已取消
    }

    // 三方角色
    address public immutable buyer;    // 买家：部署合约的人
    address public immutable seller;   // 卖家
    address public immutable arbiter;  // 仲裁人

    // 交易相关信息
    uint256 public amount;             // 托管金额
    EscrowState public state;          // 当前状态
    uint256 public depositTime;        // 买家付款时间
    uint256 public deliveryTimeout;    // 交付超时时间（秒）

    // 简单防重入锁
    bool private locked;

    // ========= 修饰器 =========

    // 防重入：
    // 进入函数时上锁，执行完再解锁
    modifier nonReentrant() {
        require(!locked, "Reentrancy detected");
        locked = true;
        _;
        locked = false;
    }

    // ========= 事件 =========

    // 买家已付款
    event PaymentDeposited(address indexed buyer, uint256 amount);

    // 买家确认交付，资金打给卖家
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);

    // 发起纠纷
    event DisputeRaised(address indexed initiator);

    // 仲裁结束，资金发给某一方
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);

    // 交易取消
    event EscrowCancelled(address indexed initiator);

    // 交付超时
    event DeliveryTimeoutReached(address indexed buyer);

    // ========= 构造函数 =========

    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        require(_deliveryTimeout > 0, "Invalid timeout");

        // 部署合约的人自动成为 buyer
        buyer = msg.sender;

        // 外部传入卖家和仲裁人地址
        seller = _seller;
        arbiter = _arbiter;

        // 初始状态：等待付款
        state = EscrowState.AWAITING_PAYMENT;

        // 设置超时秒数
        deliveryTimeout = _deliveryTimeout;
    }

    // 禁止别人直接往合约地址打钱
    // 必须通过 deposit() 付款，才能正确记录金额、时间和状态
    receive() external payable {
        revert("Direct payments not allowed");
    }


    // ========= 核心功能 =========

    /// @notice 买家付款，把钱存入托管合约
    function deposit() external payable {
        // 只有买家能付款
        require(msg.sender == buyer, "Only buyer");

        // 当前必须是“等待付款”状态
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");

        // 金额必须大于 0
        require(msg.value > 0, "Zero amount");

        // 记录付款金额
        amount = msg.value;

        // 记录付款时间
        depositTime = block.timestamp;

        // 状态切到“等待交付”
        state = EscrowState.AWAITING_DELIVERY;

        emit PaymentDeposited(buyer, amount);
    }

    /// @notice 买家确认交付完成，资金释放给卖家
    function confirmDelivery() external nonReentrant {
        // 只有买家能确认收货 / 确认交付
        require(msg.sender == buyer, "Only buyer");

        // 必须已经付款且正在等待交付
        require(state == EscrowState.AWAITING_DELIVERY, "Invalid state");

        // 先改状态，再转账（Checks-Effects-Interactions）
        state = EscrowState.COMPLETE;

        // 把托管金额转给卖家
        _safeTransfer(seller, amount);

        emit DeliveryConfirmed(buyer, seller, amount);
    }


    /// @notice 买家或卖家发起纠纷
    function raiseDispute() external {
        // 只有买家或卖家可以发起纠纷
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");

        // 只有在等待交付阶段才能发起纠纷
        require(state == EscrowState.AWAITING_DELIVERY, "Invalid state");

        // 状态切到纠纷中
        state = EscrowState.DISPUTED;

        emit DisputeRaised(msg.sender);
    }


    /// @notice 仲裁人解决纠纷，决定钱给卖家还是退给买家
    /// @param releaseToSeller true = 给卖家，false = 退买家
    function resolveDispute(bool releaseToSeller) external nonReentrant {
        // 只有仲裁人能处理纠纷
        require(msg.sender == arbiter, "Only arbiter");

        // 当前必须已经进入纠纷状态
        require(state == EscrowState.DISPUTED, "No dispute");

        // 仲裁后交易结束
        state = EscrowState.COMPLETE;

        if (releaseToSeller) {
            // 仲裁决定：给卖家
            _safeTransfer(seller, amount);
            emit DisputeResolved(arbiter, seller, amount);
        } else {
            // 仲裁决定：退给买家
            _safeTransfer(buyer, amount);
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }


    /// @notice 买家在超时后取消交易并退款
    function cancelAfterTimeout() external nonReentrant {
        // 只有买家能在超时后申请取消
        require(msg.sender == buyer, "Only buyer");

        // 当前必须处于等待交付状态
        require(state == EscrowState.AWAITING_DELIVERY, "Invalid state");

        // 必须已经超过付款时间 + 超时时长
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");

        // 状态改为已取消
        state = EscrowState.CANCELLED;

        // 把合约里的余额退回给买家
        _safeTransfer(buyer, address(this).balance);

        emit EscrowCancelled(buyer);
        emit DeliveryTimeoutReached(buyer);
    }


    /// @notice 取消交易（当前实现里：买家或卖家任一方都能调用）
    function cancelMutual() external nonReentrant {
        // 只有买家或卖家能调
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");

        // 只能在“未付款”或“已付款待交付”时取消
        require(
            state == EscrowState.AWAITING_PAYMENT ||
            state == EscrowState.AWAITING_DELIVERY,
            "Cannot cancel"
        );

        // 先记住取消前的状态
        EscrowState prev = state;

        // 改为已取消
        state = EscrowState.CANCELLED;

        // 如果之前已经付款，则把钱退给买家
        if (prev == EscrowState.AWAITING_DELIVERY) {
            _safeTransfer(buyer, address(this).balance);
        }

        emit EscrowCancelled(msg.sender);

    }



    // ========= 工具函数 =========

    /// @dev 安全转账函数：底层用 call 发送 ETH
    function _safeTransfer(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}("");
        require(success, "Transfer failed");

    }



    /// @notice 查看距离超时还剩多少秒
    function getTimeLeft() external view returns (uint256) {
        // 如果不在等待交付状态，直接返回 0
        if (state != EscrowState.AWAITING_DELIVERY) return 0;

        // 如果已经超时，也返回 0
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;

        // 否则返回剩余秒数
        return (depositTime + deliveryTimeout) - block.timestamp;
    }

}