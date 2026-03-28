// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract EnhancedSimpleEscrow {
//开始写正式的托管合约啦，这是一个大盒子

    enum EscrowState {  //创建一个“状态清单”，标记现在托管走到哪一步了
        AWAITING_PAYMENT,  //等着买家付钱
        AWAITING_DELIVERY, //钱已付，等着买家确认收货
        COMPLETE, //交易完成，钱给卖家
        DISPUTED, // 出事了，双方吵架有纠纷
        CANCELLED //交易取消，钱退给买家
        
    }

    address public immutable buyer;//记录谁是【买家】，写死不能改
    address public immutable seller; //记录谁是【卖家】，写死不能改
    address public immutable arbiter;//记录谁是【中间人/裁判】，出问题他说了算
    uint256 public amount;    //记录这次托管要转多少钱
    EscrowState public state;    //记录现在交易处于哪个状态（上面那5种里的一种）
    uint256 public depositTime;// 记录买家是什么时候付的钱
    uint256 public deliveryTimeout;//设定一个超时时间，超时没确认收货就自动取消
    

    // 下面是一个安全锁，防止坏人重复多次把钱转走
    bool private locked;// 说人话：一把锁，true=锁住，false=打开，默认没锁
    

    //下面是一个通用安全规则，用到哪个函数就自动保护哪个函数
    modifier nonReentrant() {//定义“防重复进入”安全规则
        require(!locked, "Reentrancy detected"); //检查锁是不是开着，锁着就不让进
        locked = true;//一进来立刻锁上门
        _;
        //执行函数本来的功能
        locked = false;//执行完再把门打开
    }

    //下面是各种“通知消息”，发生什么事就广播什么消息
    event PaymentDeposited(address indexed buyer, uint256 amount);    //买家已付钱，记录买家地址和钱数
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);    //买家确认收货，钱转给卖家
    event DisputeRaised(address indexed initiator);    //有人发起纠纷（吵架了）
    event DisputeResolved(address indexed arbiter, address recipient, uint256 amount);   //中间人裁判完了，钱给谁
    event EscrowCancelled(address indexed initiator);  //托管取消了
    event DeliveryTimeoutReached(address indexed buyer); //超时啦，自动取消


    constructor(address _seller, address _arbiter, uint256 _deliveryTimeout) { //合约刚创建时执行一次，设定好三方角色和超时时间
        require(_deliveryTimeout > 0, "Invalid timeout");//必须设置大于0的超时时间，不然不让创建
        buyer = msg.sender;//谁部署这个合约，谁就是买家
        seller = _seller;//把传进来的地址设为卖家
        arbiter = _arbiter;//把传进来的地址设为中间人裁判
        state = EscrowState.AWAITING_PAYMENT;//一开始状态是：等待买家付钱
        deliveryTimeout = _deliveryTimeout; //把超时时间存起来
    }
       

    //不允许别人随便直接转钱进来
    receive() external payable {  // 这是系统默认收钱的入口
        revert("Direct payments not allowed");//直接转钱？不行！拒绝收款
    }

     //下面是真正能用的功能按钮
    function deposit() external payable {      //按钮1：买家付钱
        require(msg.sender == buyer, "Only buyer"); //只有买家能点这个按钮
        require(state == EscrowState.AWAITING_PAYMENT, "Already paid");//必须是“等待付款”状态才能付钱
        require(msg.value > 0, "Zero amount");//不能付0元，必须给钱
        amount = msg.value;//记录付了多少钱
        depositTime = block.timestamp;//记录付钱的时间
        state = EscrowState.AWAITING_DELIVERY;// 状态改成：等待买家确认收货
        emit PaymentDeposited(buyer, amount); // 广播：买家已付钱
       
    }

    function confirmDelivery() external nonReentrant { //按钮2：买家确认收货（带安全锁）
        require(msg.sender == buyer, "Only buyer");// 只有买家能点
        require(state == EscrowState.AWAITING_DELIVERY, "Invalid state");//必须是等待收货状态
        state = EscrowState.COMPLETE; //状态改成：交易完成
        _safeTransfer(seller, amount); //把钱安全转给卖家
        emit DeliveryConfirmed(buyer, seller, amount);//广播：交易完成，钱已给卖家
    }

    function raiseDispute() external {   //按钮3：发起纠纷（吵架）
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");//只有买家或卖家能发起纠纷
        require(state == EscrowState.AWAITING_DELIVERY, "Invalid state");   //必须是等待收货状态才能吵架
        state = EscrowState.DISPUTED; //状态改成：有纠纷
        emit DisputeRaised(msg.sender);// 广播：谁发起了纠纷
    }

    function resolveDispute(bool releaseToSeller) external nonReentrant {//按钮4：中间人裁判纠纷（带安全锁）
        require(msg.sender == arbiter, "Only arbiter");//只有中间人能裁判
        require(state == EscrowState.DISPUTED, "No dispute");//必须是有纠纷状态才能裁判
        state = EscrowState.COMPLETE;//裁判完就变成完成状态
        if (releaseToSeller) {//如果中间人判卖家赢 
            _safeTransfer(seller, amount);//钱给卖家
            emit DisputeResolved(arbiter, seller, amount); //广播：钱给卖家
        } else {//否则判买家赢
            _safeTransfer(buyer, amount);//钱退买家
            emit DisputeResolved(arbiter, buyer, amount);//广播：钱退买家
            
        }
    }

    function cancelAfterTimeout() external nonReentrant {//按钮5：超时自动取消（带安全锁）
        require(msg.sender == buyer, "Only buyer");//只有买家能点
        require(state == EscrowState.AWAITING_DELIVERY, "Invalid state");//必须是等待收货状态
        require(block.timestamp >= depositTime + deliveryTimeout, "Timeout not reached"); //必须超过设定的超时时间才能取消
        state = EscrowState.CANCELLED; //状态改成：已取消
        _safeTransfer(buyer, address(this).balance);//把合约里所有钱退给买家
        emit EscrowCancelled(buyer);//广播：托管已取消
        emit DeliveryTimeoutReached(buyer);//广播：超时啦
        
    }

    function cancelMutual() external nonReentrant {//按钮6：双方协商取消（带安全锁）
        
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");//买家或卖家都能发起
        
        require(//只能在没付钱或已付钱没收货时取消
            state == EscrowState.AWAITING_PAYMENT ||
            state == EscrowState.AWAITING_DELIVERY,
            "Cannot cancel"
        );
        

        EscrowState prev = state; //记住取消前是什么状态
        state = EscrowState.CANCELLED;//改成已取消状态
        if (prev == EscrowState.AWAITING_DELIVERY) {//如果已经付过钱了
            _safeTransfer(buyer, address(this).balance);//把钱退给买家
        }

        emit EscrowCancelled(msg.sender);//广播：已协商取消
        
    }


    //下面是辅助小工具

    function _safeTransfer(address to, uint256 value) internal {//安全转钱函数，保证钱一定能转成功
        (bool success, ) = to.call{value: value}("");// 尝试转钱给对方
        require(success, "Transfer failed");//转失败就报错，停止执行
        
    }

    function getTimeLeft() external view returns (uint256) {//小工具：查看还剩多少时间超时
        if (state != EscrowState.AWAITING_DELIVERY) return 0;//不是等待收货状态就返回0
        if (block.timestamp >= depositTime + deliveryTimeout) return 0; //已经超时也返回0
        return (depositTime + deliveryTimeout) - block.timestamp;//返回还剩多少秒超时
    }
}