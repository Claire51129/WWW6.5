// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//具有超时、取消和事件的安全托管合约
contract EnhancedSimpleEscrow {
    //托管状态管理
    enum EscrowState { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, DISPUTED, CANCELLED }

    address public immutable buyer;//买家，发送eth
    address public immutable seller;//卖家，交付物品/服务
    address public immutable arbiter;//仲裁人，解决争议的受信任第三方

    uint256 public amount;
    EscrowState public state;
    uint256 public depositTime;// 跟踪买家何时付款
    uint256 public deliveryTimeout; // 存款后的持续时间（以秒为单位）

    //事件
    event PaymentDeposited(address indexed buyer, uint256 amount);//锁定金额
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);//确认收到产品
    event DisputeRaised(address indexed initiator);//当买家或卖家提出争议时触发
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);//当仲裁人解决争议并转移资金时触发
    event EscrowCancelled(address indexed initiator);//托管取消
    event DeliveryTimeoutReached(address indexed buyer);//在买家支付窗口到期后取消时触发

    //设置托管
    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        require(_deliveryTimeout > 0, "Delivery timeout must be greater than zero");
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        state = EscrowState.AWAITING_PAYMENT;
        deliveryTimeout = _deliveryTimeout;//设置超时窗口
    }

    //一开始状态为等待付钱，阻止随机转账
    receive() external payable {
        revert("Direct payments not allowed");
    }

    //将金额存到合约里
    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer can deposit");//设定只要买家可以存入金额
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");//修改状态为可以付款
        require(msg.value > 0, "Amount must be greater than zero");

        amount = msg.value;
        state = EscrowState.AWAITING_DELIVERY;//修改状态为等待收货
        depositTime = block.timestamp;
        emit PaymentDeposited(buyer, amount);
    }

    //确定收货
    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer can confirm");
        require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery state");//确保前面步骤已经完成，到了等待收货的状态

        //修改状态为完成
        state = EscrowState.COMPLETE;
        payable(seller).transfer(amount);
        emit DeliveryConfirmed(buyer, seller, amount);
    }

    //买家或卖家标记问题
    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(state == EscrowState.AWAITING_DELIVERY, "Can't dispute now");//争议只能在等待交付阶段出发

        //进入争议状态
        state = EscrowState.DISPUTED;
        //发出争议事件
        emit DisputeRaised(msg.sender);
    }

    
    //仲裁人决定结果
    function resolveDispute(bool _releaseToSeller) external {
        require(msg.sender == arbiter, "Only arbiter can resolve");
        require(state == EscrowState.DISPUTED, "No dispute to resolve");//处于争议状态

        //关闭托管状态
        state = EscrowState.COMPLETE;
        //根据决定释放资金
        if (_releaseToSeller) {
            payable(seller).transfer(amount);
            emit DisputeResolved(arbiter, seller, amount);
        } else {
            payable(buyer).transfer(amount);
            emit DisputeResolved(arbiter, buyer, amount);
        }
    }

    //如果卖家延迟，买家取消
    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer can trigger timeout cancellation");
        require(state == EscrowState.AWAITING_DELIVERY, "Cannot cancel in current state");
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");

        state = EscrowState.CANCELLED;
        payable(buyer).transfer(address(this).balance);
        emit EscrowCancelled(buyer);
        emit DeliveryTimeoutReached(buyer);
    }

    //任何一方在完成前取消
    function cancelMutual() external {
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

    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) return 0;
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;
        return (depositTime + deliveryTimeout) - block.timestamp;
    }
}
