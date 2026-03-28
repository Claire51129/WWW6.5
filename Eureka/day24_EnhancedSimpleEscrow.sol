// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnhancedSimpleEscrow 
{   
    //托管状态管理
    enum EscrowState { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, DISPUTED, CANCELLED }

    address public immutable buyer;//买家
    address public immutable seller;//卖家
    address public immutable arbiter;//仲裁人

    uint256 public amount;//锁定在托管中的 ETH
    EscrowState public state;
    uint256 public depositTime;//跟踪买家何时付款
    uint256 public deliveryTimeout; // 存款后的持续时间（以秒为单位），卖家交付的窗口期

    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(address indexed initiator);//提出争议
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);//争议解决
    event EscrowCancelled(address indexed initiator);//取消
    event DeliveryTimeoutReached(address indexed buyer);//超时取消

    //买家部署合约
    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) 
    {
        require(_deliveryTimeout > 0, "Delivery timeout must be greater than zero");
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        state = EscrowState.AWAITING_PAYMENT;
        deliveryTimeout = _deliveryTimeout;
    }

    receive() external payable //拒绝直接发送ETH
    {
        revert("Direct payments not allowed");
    }

    function deposit() external payable //买家付款
    {
        require(msg.sender == buyer, "Only buyer can deposit");
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");
        require(msg.value > 0, "Amount must be greater than zero");

        amount = msg.value;
        state = EscrowState.AWAITING_DELIVERY;
        depositTime = block.timestamp;
        emit PaymentDeposited(buyer, amount);
    }

    function confirmDelivery() external //买家标记交易完成
    {
        require(msg.sender == buyer, "Only buyer can confirm");
        require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery state");

        state = EscrowState.COMPLETE;
        payable(seller).transfer(amount);
        emit DeliveryConfirmed(buyer, seller, amount);
    }

    function raiseDispute() external //提出争议
    {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(state == EscrowState.AWAITING_DELIVERY, "Can't dispute now");

        state = EscrowState.DISPUTED;
        emit DisputeRaised(msg.sender);
    }

    function resolveDispute(bool _releaseToSeller) external //仲裁争议
    {
        require(msg.sender == arbiter, "Only arbiter can resolve");
        require(state == EscrowState.DISPUTED, "No dispute to resolve");

        state = EscrowState.COMPLETE;//无论仲裁人做出什么决定，托管现在都是关闭的
        if (_releaseToSeller) //=true,卖家得到钱
        {
            payable(seller).transfer(amount);
            emit DisputeResolved(arbiter, seller, amount);
        } else 
        {
            payable(buyer).transfer(amount);
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }

    function cancelAfterTimeout() external //延迟发货，买家取消
    {
        require(msg.sender == buyer, "Only buyer can trigger timeout cancellation");
        require(state == EscrowState.AWAITING_DELIVERY, "Cannot cancel in current state");
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");

        state = EscrowState.CANCELLED;
        payable(buyer).transfer(address(this).balance);
        emit EscrowCancelled(buyer);
        emit DeliveryTimeoutReached(buyer);
    }

    function cancelMutual() external //取消交易
    {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(
            state == EscrowState.AWAITING_DELIVERY || state == EscrowState.AWAITING_PAYMENT,
            "Cannot cancel now"
        );

        EscrowState previousState = state;
        state = EscrowState.CANCELLED;

        if (previousState == EscrowState.AWAITING_DELIVERY) {
            payable(buyer).transfer(address(this).balance);
        }

        emit EscrowCancelled(msg.sender);
    }

    function getTimeLeft() external view returns (uint256) //检查剩余时间
    {
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;
        return (depositTime + deliveryTimeout) - block.timestamp;
    }
}
