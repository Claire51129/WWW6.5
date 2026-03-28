// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 增强版托管合约
contract EnhancedSimpleEscrow {

    // 托管状态枚举 - 五个阶段覆盖交易的完整生命周期
    enum EscrowState {
        AWAITING_PAYMENT,   // 等待买家付款
        AWAITING_DELIVERY,  // 已付款，等待卖家发货/买家确认收货
        COMPLETE,           // 交易完成，钱已转给卖家
        DISPUTED,           // 出了纠纷，等待仲裁人裁决
        CANCELLED           // 交易取消，钱退给买家
    }

    // immutable：部署后不可修改，比普通状态变量更省 gas
    // 交易的三方角色在创建时就确定了，之后不会变
    address public immutable buyer;    // 买家（部署合约的人）
    address public immutable seller;   // 卖家
    address public immutable arbiter;  // 仲裁人（出纠纷时裁决的第三方）

    uint256 public amount;             // 托管金额
    EscrowState public state;          // 当前状态
    uint256 public depositTime;        // 买家付款的时间
    uint256 public deliveryTimeout;    // 发货超时时间（秒），超时未确认收货买家可以自动取消

    // 事件
    event PaymentDeposited(address indexed buyer, uint256 amount);                       // 买家付款
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount); // 确认收货
    event DisputeRaised(address indexed initiator);                                       // 发起纠纷
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);     // 纠纷裁决
    event EscrowCancelled(address indexed initiator);                                      // 交易取消
    event DeliveryTimeoutReached(address indexed buyer);                                   // 发货超时

    // 构造函数 - 买家部署合约，指定卖家、仲裁人和超时时间
    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        require(_deliveryTimeout > 0, "Delivery timeout must be greater than zero");
        buyer = msg.sender;            // 部署者就是买家
        seller = _seller;
        arbiter = _arbiter;
        state = EscrowState.AWAITING_PAYMENT;  // 初始状态：等待付款
        deliveryTimeout = _deliveryTimeout;
    }

    // 禁止直接转 ETH 到合约，必须通过 deposit 函数付款
    // 防止有人误操作直接往合约地址转钱
    receive() external payable {
        revert("Direct payments not allowed");
    }

    // 买家付款 - 把 ETH 锁进合约
    // 类比：在淘宝下单付款，钱进入支付宝托管
    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer can deposit");              // 只有买家能付款
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");      // 不能重复付款
        require(msg.value > 0, "Amount must be greater than zero");

        amount = msg.value;
        state = EscrowState.AWAITING_DELIVERY;  // 状态变为等待发货
        depositTime = block.timestamp;           // 记录付款时间，用于计算超时
        emit PaymentDeposited(buyer, amount);
    }

    // 买家确认收货 - 钱自动转给卖家
    // 类比：在淘宝点"确认收货"，支付宝把钱打给商家
    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer can confirm");               // 只有买家能确认
        require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery state");

        state = EscrowState.COMPLETE;               // 交易完成
        (bool success, ) = payable(seller).call{value: amount}("");
        require(success, "Transfer failed");            // 放款给卖家
        emit DeliveryConfirmed(buyer, seller, amount);
    }

    // 发起纠纷 - 买家或卖家都可以发起
    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");  // 买卖双方都可以
        require(state == EscrowState.AWAITING_DELIVERY, "Can't dispute now");    // 只有在等待发货时才能纠纷

        state = EscrowState.DISPUTED;
        emit DisputeRaised(msg.sender);
    }

    // 仲裁人裁决 - 决定钱归买家还是卖家
    function resolveDispute(bool _releaseToSeller) external {
        require(msg.sender == arbiter, "Only arbiter can resolve");  // 只有仲裁人能裁决
        require(state == EscrowState.DISPUTED, "No dispute to resolve");

        state = EscrowState.COMPLETE;
        if (_releaseToSeller) {
            (bool success1, ) = payable(seller).call{value: amount}("");
            require(success1, "Transfer failed");                        // 卖家胜诉，放款
            emit DisputeResolved(arbiter, seller, amount);
        } else {
            (bool success2, ) = payable(buyer).call{value: amount}("");
            require(success2, "Transfer failed");                        // 买家胜诉，退款
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }

    // 超时取消 - 卖家超时未发货，买家可以自动取消并拿回全款
    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer can trigger timeout cancellation");
        require(state == EscrowState.AWAITING_DELIVERY, "Cannot cancel in current state");
        // 当前时间必须超过 付款时间 + 超时时长
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");

        state = EscrowState.CANCELLED;
        (bool success, ) = payable(buyer).call{value: address(this).balance}("");
        require(success, "Transfer failed");  // 全额退给买家
        emit EscrowCancelled(buyer);
        emit DeliveryTimeoutReached(buyer);
    }

    // 协商取消 - 买卖双方任一方发起取消
    function cancelMutual() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(
            state == EscrowState.AWAITING_DELIVERY || state == EscrowState.AWAITING_PAYMENT,
            "Cannot cancel now"
        );

        EscrowState previousState = state;  // 记录取消前的状态
        state = EscrowState.CANCELLED;

        // 如果之前已付款，退钱给买家
        if (previousState == EscrowState.AWAITING_DELIVERY) {
            (bool success, ) = payable(buyer).call{value: address(this).balance}("");
            require(success, "Transfer failed");
        }

        emit EscrowCancelled(msg.sender);
    }

    // 查询距离超时还剩多少秒
    // 前端可以用这个做倒计时显示
    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) return 0;  // 不在等待发货状态，返回 0
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;  // 已超时，返回 0
        return (depositTime + deliveryTimeout) - block.timestamp;  // 计算剩余秒数
    }
}