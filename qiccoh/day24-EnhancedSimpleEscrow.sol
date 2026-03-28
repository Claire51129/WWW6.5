
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//中间人代管资金: 具有超时、取消和事件的安全托管合约
contract EnhancedSimpleEscrow {
    
    // 状态枚举
    enum EscrowState { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, DISPUTED, CANCELLED }
     EscrowState public state;


    address public immutable buyer;
    address public immutable seller;
    address public immutable arbiter;//仲裁人

    uint256 public amount;//是锁定在托管中的 ETH

   
    uint256 public depositTime;//跟踪买家何时付款
    uint256 public deliveryTimeout; // 卖家交付的窗口期

    // 存款、确认、争议、取消
    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(address indexed initiator);
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);
    event EscrowCancelled(address indexed initiator);
    event DeliveryTimeoutReached(address indexed buyer);


/**
- **卖家的**地址（交付商品或服务的人）
- **仲裁人的**地址（可以解决争议的中立第三方）
- **交付超时**——卖家在买家可以取消之前必须交付的时间/**/
    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        require(_deliveryTimeout > 0, "Delivery timeout must be greater than zero");
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        state = EscrowState.AWAITING_PAYMENT;
        deliveryTimeout = _deliveryTimeout;
        //它只在买家将 ETH 存入合约之后开始计时
    }
// 阻止任何人试图发送的任何 ETH
    receive() external payable {
        revert("Direct payments not allowed");
    }
// solidity:发钱就要,不让它收,那就要receive拒绝
    function deposit() external payable {
        //  步骤 1：只有买家可以存款
        require(msg.sender == buyer, "Only buyer can deposit");
         //  步骤 2：只有在尚未付款时
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");
        // 步骤 3：ETH 必须大于零
        require(msg.value > 0, "Amount must be greater than zero");
        //  步骤 4：锁定资金
        amount = msg.value;
        // 步骤 5：更改合约状态
        state = EscrowState.AWAITING_DELIVERY;//等待
        depositTime = block.timestamp;
        emit PaymentDeposited(buyer, amount);
    }



// 买家标记交易完成
    function confirmDelivery() external {
        //  步骤 1：只有买家可以存款
        require(msg.sender == buyer, "Only buyer can confirm");
        //  步骤 2：只有在交付期
        require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery state");
// 状态改为完成态
        state = EscrowState.COMPLETE;
        // 步骤 4：将资金释放给卖家
        payable(seller).transfer(amount);
        emit DeliveryConfirmed(buyer, seller, amount);
    }
// 买家或卖家标记问题
    function raiseDispute() external {
        // 步骤 1：只有买家或卖家可以调用此函数
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
    //    步骤 2：只在交付阶段
        require(state == EscrowState.AWAITING_DELIVERY, "Can't dispute now");
// 步骤 3：进入争议状态
        state = EscrowState.DISPUTED;
        emit DisputeRaised(msg.sender);
    }
// 仲裁人决定结果
    function resolveDispute(bool _releaseToSeller) external {
        // 1. ✅ 只有仲裁人可以调用此函数
        require(msg.sender == arbiter, "Only arbiter can resolve");
        //  只有在我们处于争议中时才允许
        require(state == EscrowState.DISPUTED, "No dispute to resolve");
// 🏁 将托管标记为完成
        state = EscrowState.COMPLETE;
        //  💸 根据决定释放资金
        if (_releaseToSeller) {
            // true:卖家获得前
            payable(seller).transfer(amount);
            emit DisputeResolved(arbiter, seller, amount);
        } else {
            // 退钱给买家
            payable(buyer).transfer(amount);
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }
// 如果卖家延迟，买家取消
    function cancelAfterTimeout() external {
        // 步骤 1：只有买家可以取消
        require(msg.sender == buyer, "Only buyer can trigger timeout cancellation");
        // 发货期
        require(state == EscrowState.AWAITING_DELIVERY, "Cannot cancel in current state");
        // 检查超时是否已过  
        /**
        - `depositTime` 是买家存入 ETH 的时间。
        - `deliveryTimeout` 是卖家必须交付的约定持续时间
        **/
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");
// 步骤 4：取消托管
        state = EscrowState.CANCELLED;
        // 步骤 5：退款给买家
        payable(buyer).transfer(address(this).balance);
        emit EscrowCancelled(buyer);
        // 步骤 6：发出取消和超时事件
        emit DeliveryTimeoutReached(buyer);
    }


// 任何一方在完成前取消
    function cancelMutual() external {
        // 步骤 1：只有买家或卖家可以取消
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
    //    步骤 2：只能在正确的时间使用
        require(
            state == EscrowState.AWAITING_DELIVERY || state == EscrowState.AWAITING_PAYMENT,
            "Cannot cancel now"
        );
/**
- 等待买家存款（`AWAITING_PAYMENT`）
- 或等待卖家交付（`AWAITING_DELIVERY`）
**/
        
        //  步骤 3：存储之前的状态
        EscrowState previousState = state;
        //  步骤 4：取消托管
        state = EscrowState.CANCELLED;
        // 步骤 5：退款给买家（如果需要）
        // 如果买家已经存入了 ETH，我们退款
        if (previousState == EscrowState.AWAITING_DELIVERY) {
            payable(buyer).transfer(address(this).balance);
        }

        emit EscrowCancelled(msg.sender);
    }
// 查看剩余多少时间
    function getTimeLeft() external view returns (uint256) {
        // 步骤 1：如果我们不在等待交付，提前退出
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        // 步骤 2：如果超时已经过去，返回 0
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;
       
       
        return (depositTime + deliveryTimeout) - block.timestamp;
    }
}

