
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**

    @title EnhancedSimpleEscrow - 具有超时、取消和事件的安全托管合约
- 使用枚举来管理合约状态
- 使用 `block.timestamp` 处理超时
- 实现争议解决工作流程
- 使用像 `require()` 这样的修饰符进行严格的访问控制
- 并使你的合约通过清晰的事件和只读函数为前端做好准备
 */

contract EnhancedSimpleEscrow {
    enum EscrowState { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, DISPUTED, CANCELLED }

    address public immutable buyer;
    address public immutable seller;
    address public immutable arbiter;

    uint256 public amount;
    EscrowState public state;
    uint256 public depositTime;
    uint256 public deliveryTimeout; // 存款后的持续时间（以秒为单位）

    // 存入ETH给合约托管事件
    event PaymentDeposited(address indexed buyer, uint256 amount);
    // 确认收货事件
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    // 发起争议
    event DisputeRaised(address indexed initiator);
    // 争议解决
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);
    // 交易取消
    event EscrowCancelled(address indexed initiator);
    // 触发交易超时
    event DeliveryTimeoutReached(address indexed buyer);

    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        require(_deliveryTimeout > 0, "Delivery timeout must be greater than zero");
        buyer = msg.sender; // 部署合约的人为买家？
        seller = _seller;
        arbiter = _arbiter;
        state = EscrowState.AWAITING_PAYMENT;  // 初始化为等待支付
        deliveryTimeout = _deliveryTimeout;  // 约定一个超时时间
    }

    // 不接受直接转账
    receive() external payable {
        revert("Direct payments not allowed");
    }

    // 只有买家可以存入ETH
    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer can deposit");
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");
        require(msg.value > 0, "Amount must be greater than zero");

        amount = msg.value;
        state = EscrowState.AWAITING_DELIVERY;  // 等待商品｜服务
        depositTime = block.timestamp;  // 记录付款时间
        emit PaymentDeposited(buyer, amount);
    }

    // 确认收货
    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer can confirm");
        require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery state");

        state = EscrowState.COMPLETE;
        // payable(seller).transfer(amount);
        (bool success, ) = payable(seller).call{value: amount}("");
        require(success, "Transfer failed");
        emit DeliveryConfirmed(buyer, seller, amount);
    }

    // 发起争议
    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(state == EscrowState.AWAITING_DELIVERY, "Can't dispute now");

        state = EscrowState.DISPUTED;
        emit DisputeRaised(msg.sender);
    }

    // 解决争议，只有仲裁者可以执行
    function resolveDispute(bool _releaseToSeller) external {
        require(msg.sender == arbiter, "Only arbiter can resolve");
        require(state == EscrowState.DISPUTED, "No dispute to resolve");

        state = EscrowState.COMPLETE;
        if (_releaseToSeller) {
            // payable(seller).transfer(amount);
            (bool success, ) = payable(seller).call{value: amount}("");
            require(success, "Transfer failed");
            emit DisputeResolved(arbiter, seller, amount);
        } else {
            // payable(buyer).transfer(amount);
            (bool success, ) = payable(buyer).call{value: amount}("");
            require(success, "Transfer failed");
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }

    // 超时后，买家可以取消交易
    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer can trigger timeout cancellation");
        require(state == EscrowState.AWAITING_DELIVERY, "Cannot cancel in current state");
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");

        state = EscrowState.CANCELLED;
        // payable(buyer).transfer(address(this).balance);
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Transfer failed");
        emit EscrowCancelled(buyer);
        emit DeliveryTimeoutReached(buyer);
    }

    // 手动取消交易（任何一方都能在完成前取消）
    function cancelMutual() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(
            state == EscrowState.AWAITING_DELIVERY || state == EscrowState.AWAITING_PAYMENT,
            "Cannot cancel now"
        );

        EscrowState previousState = state;
        state = EscrowState.CANCELLED;

        if (previousState == EscrowState.AWAITING_DELIVERY) {
            // payable(buyer).transfer(address(this).balance);
            (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
            require(success, "Transfer failed");
        }

        emit EscrowCancelled(msg.sender);
    }

    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;
        return (depositTime + deliveryTimeout) - block.timestamp;
    }
}



/**
用户角色：
（1）买家 buyer
- 存入资金托管
- 确认收到商品/服务
- 超时可取消
- 提起争议
（2）卖家 seller
- 提供商品/服务
- 交付完成后等待确认
- 可以提起争议
- 同意取消交易
（3）仲裁者 arbiter：
-决定资金归属，维护交易公平

超时机制：
（1）基于区块时间戳
（2）仅买家可以执行
（3）必须在等待交付状态
（4）自动退款
 */