// 用智能合约代替“中立第三方”。
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;   //pragma:提前说明规则

/// @title EnhancedSimpleEscrow - 具有超时、取消和事件的安全托管合约
contract EnhancedSimpleEscrow {   //增强版的简单托管合约[中立保险箱]，里面增加超时处理、取消功能、事件日志
    enum EscrowState { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, DISPUTED, CANCELLED }   //在定义“托管交易可能会处于哪些状态”：等待付款、等待交付、完成、争议中、已取消

    //定义参与者；immutable=部署时定下来，以后不能改
    address public immutable buyer;   //买家地址
    address public immutable seller;   //卖家地址
    address public immutable arbiter;   //仲裁人地址(如果买家和卖家发生争议，由这个角色来拍板决定钱归谁)

    uint256 public amount;    //定义交易数据；amount表示托管的金额；“买家总共存进来了多少钱”
    EscrowState public state;   //定义state，类型是刚才那个EscrowState；用来记录当前托管交易处于哪个状态
    uint256 public depositTime;   //定义depositTime，表示买家存款的时间
    uint256 public deliveryTimeout; // 存款后的持续时间（以秒为单位）；从存款开始，到超时为止，要等多久；“我付钱后最多等这么久。”

    event PaymentDeposited(address indexed buyer, uint256 amount);   //买家已存款，记录两件事：哪个买家存的，存了多少钱
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);   //买家确认已收到货/服务，记录：买家是谁、卖家是谁、这次金额是多少
    event DisputeRaised(address indexed initiator);   //有人发起了争议；initiator=发起人，也就是到底是买家先喊“有问题”，还是卖家先喊“有问题”
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);   //争议已解决，记录哪个仲裁人处理的、最后钱给了谁、给了多少钱
    event EscrowCancelled(address indexed initiator);   //托管被取消了，记录谁触发了取消动作
    event DeliveryTimeoutReached(address indexed buyer);   //已经达到交付超时时间了(主要是给大家一个明确记录，这次取消，是因为“等太久了”)

    //构造函数(初始化函数)
    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) {
        require(_deliveryTimeout > 0, "Delivery timeout must be greater than zero");   //超时时间必须大于0
        buyer = msg.sender;   //默认由买家来创建托管合约：“谁部署了这个合约，谁就是买家。”
        seller = _seller;   //卖家地址：“卖家是谁，由部署时指定”
        arbiter = _arbiter;   //仲裁人地址：“仲裁人是谁，也是在创建时设定”
        state = EscrowState.AWAITING_PAYMENT;    //初始状态设为等待付款
        deliveryTimeout = _deliveryTimeout;    //交付等待时间
    }

    // 当有人不调用任何函数，只是直接往合约地址打ETH时，就会进入这里
    receive() external payable {   //external：只能从合约外部调用；payable这个入口本来是可以接收ETH的
        revert("Direct payments not allowed");   //不允许(未经调用任何函数)直接付款，立刻回退
    }

    // 存款：让买家把钱正式存进托管合约里
    function deposit() external payable {   //payable函数意味着接收ETH
        require(msg.sender == buyer, "Only buyer can deposit");   //只有买家才能存钱
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");   //必须是等待付款状态→只能在还没付款的时候付款一次
        require(msg.value > 0, "Amount must be greater than zero");   //msg.value就是这次调用函数时一并带来的钱

        amount = msg.value;   //把这次收到的钱寄到amount里
        state = EscrowState.AWAITING_DELIVERY;   //状态改成“等待交付”
        depositTime = block.timestamp;   //记录存款时间；block.timestamp=区块链记录下的当前时间
        emit PaymentDeposited(buyer, amount);   //发出时间，告诉外界：这笔托管的款已经成功存进来了
    }

    // 确认交付
    function confirmDelivery() external {   //买家确认：我已经收到货/服务了
        require(msg.sender == buyer, "Only buyer can confirm");   //检查：只有买家可以确认交付
        require(state == EscrowState.AWAITING_DELIVERY, "Not in delivery state");   //检查：必须处于"等待交付"状态

        state = EscrowState.COMPLETE;  //把状态改成：完成(表示这笔托管交易已经成功走完流程了)
        (bool success, ) = payable(seller).call{value: amount}("");   //把钱转给卖家
        require(success, "Transfer to seller failed");   
        emit DeliveryConfirmed(buyer, seller, amount);   //发出事件，记录：卖家确认了、卖家收款了、金额是多少
    }

    // 发起争议
    function raiseDispute() external {   //作用：如果交易过程中出了问题，可以发起争议
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");   //只有买卖双方可发起争议；||means"或者"
        require(state == EscrowState.AWAITING_DELIVERY, "Can't dispute now");   //检查是否是等待交付状态，否则不能发起争议

        state = EscrowState.DISPUTED;   //把状态改成“争议中”
        emit DisputeRaised(msg.sender);   //发出事件，记录是谁发起了争议
    }

    // 仲裁解决争议
    function resolveDispute(bool _releaseToSeller) external {   //作用：由仲裁人决定钱最后归谁
        require(msg.sender == arbiter, "Only arbiter can resolve");   //只有仲裁人才能解决争议
        require(state == EscrowState.DISPUTED, "No dispute to resolve");   //状态检查：必须处于disputed状态

        state = EscrowState.COMPLETE;   //状态改成complete，“这单交易流程已经处理完了”
        if (_releaseToSeller) {   //做判断：如果是true,说明裁定——钱应该给卖家
            (bool success, ) = payable(seller).call{value: amount}("");   //把托管的钱给卖家
            require(success, "Transfer to seller failed");   
            emit DisputeResolved(arbiter, seller, amount);    //发出事件，记录仲裁结果：仲裁人是谁、钱给了卖家、金额是多少
        } else {   //否则：钱不给卖家，而是退给买家
            (bool success, ) = payable(buyer).call{value: amount}("");    //把钱退给买家
            require(success, "Refund to buyer failed");
            emit DisputeResolved(arbiter, buyer, amount);   //事件记录：这次仲裁后，钱给了买家。
        }
    }

    // 超时后取消(防止“钱一直被锁在合约里出不来”)
    function cancelAfterTimeout() external {   //定义cancelAfterTimeout()；作用：如果买家等太久了，还没完成交付，就可以在超时后取消交易并退款。
        require(msg.sender == buyer, "Only buyer can trigger timeout cancellation");   //检查:只有买家能触发这个"超时取消"
        require(state == EscrowState.AWAITING_DELIVERY, "Cannot cancel in current state");   //当前必须是“等待交付”状态
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached");   //当前时间必须大于等于存款时间 + 超时时长

        state = EscrowState.CANCELLED;   //把状态修改成“已取消”
        (bool success, ) = payable(buyer).call{value: address(this).balance}("");   //把合约里的余额全部推给买家
        require(success, "Transfer to buyer failed");
        emit EscrowCancelled(buyer);   //发出取消事件，表示这笔托管被取消了
        emit DeliveryTimeoutReached(buyer);   //额外发出一个事件，说明这次取消的原因是：交付超时
    }

    // 取消交易
    function cancelMutual() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");  //只有买卖双方可调用此函数
        require(    //只有下面两种状态下，才允许取消：
            state == EscrowState.AWAITING_DELIVERY || state == EscrowState.AWAITING_PAYMENT,   //还没付款 或者 已经付款在等交付
            "Cannot cancel now"
        );

        EscrowState previousState = state;   //新建了一个临时变量 previousState，把当前状态先保存起来
        state = EscrowState.CANCELLED;   //把当前状态改成：已取消

        if (previousState == EscrowState.AWAITING_DELIVERY) {   //判断：如果取消前的状态是“等待交付”，说明买家之前已经付过钱了
            (bool success, ) = payable(buyer).call{value: address(this).balance}("");  //把合约里的钱退回给买家
            require(success, "Refund to buyer failed");
        }

        emit EscrowCancelled(msg.sender);   //发出事件，记录是谁触发了取消
    }

    // 查看剩余时间
    function getTimeLeft() external view returns (uint256) {   //定义 getTimeLeft(),作用：查看距离超时还剩多少秒
        if (state != EscrowState.AWAITING_DELIVERY) return 0;   //如果当前不是“等待交付”状态，就直接返回 0
        if (block.timestamp >= depositTime + deliveryTimeout) return 0;   //如果当前时间已经超过了“存款时间 + 超时时长”，那也返回 0
        return (depositTime + deliveryTimeout) - block.timestamp;   //如果前两个条件都没触发，那就返回：到期时间 - 当前时间(秒为单位)
    }
}




// 托管闭环：资金锁定 → 履约 → 释放 / 退款 / 仲裁
// enum: 列出几种固定选项
// event: 事件可以理解成“上链广播记录”。每次发生重要动作，合约就会发出一个事件，让外面的人可以查到。
// indexed: 可以简单理解成：让这个字段以后更方便被搜索。
// require: 必须满足这个条件，不满足就报错并停止执行。
// msg.sender: 当前是谁在调用这个函数
// revert: 撤销这次操作并报错
// payable: 这个函数允许接收 ETH; 如果一个函数没有 payable，你却试图给它转 ETH，交易会失败

