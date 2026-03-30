// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title EnhancedSimpleEscrow
 * @notice 一个增强版的去中心化托管合约
 * @dev 买家、卖家、仲裁者三方参与，支持存款、交付确认、争议处理、超时取消、双方协商取消
 */
contract EnhancedSimpleEscrow {
    // 托管状态枚举
    enum EscrowState {
        AWAITING_PAYMENT,   // 等待买家付款
        AWAITING_DELIVERY,  // 已付款，等待卖家交付商品（或买家确认）
        COMPLETE,           // 交易完成
        DISPUTED,           // 争议中
        CANCELLED           // 已取消
    }

    // 参与者地址
    address public buyer;      // 买家
    address public seller;     // 卖家
    address public arbiter;    // 仲裁者

    uint256 public amount;           // 托管金额（wei）
    EscrowState public state;        // 当前状态
    uint256 public depositTime;      // 买家存款的时间戳
    uint256 public deliveryTimeout;  // 交付超时时间（秒），买家存款后必须在规定时间内确认交付

    // 事件
    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(address indexed raisedBy);
    event DisputeResolved(address indexed winner, uint256 amount);
    event EscrowCancelled(address indexed canceledBy);
    event DeliveryTimeoutReached(address indexed buyer);
    event MutualCancellation(address indexed buyer, address indexed seller);

    /**
     * @dev 构造函数，由买家部署时传入卖家、仲裁者地址以及交付超时时间
     * @param _seller 卖家地址
     * @param _arbiter 仲裁者地址
     * @param _deliveryTimeout 交付超时时间（秒）
     */
    constructor(
        address _seller,
        address _arbiter,
        uint256 _deliveryTimeout
    ) {
        require(_seller != address(0), "Invalid seller");
        require(_arbiter != address(0), "Invalid arbiter");
        require(_deliveryTimeout > 0, "Invalid timeout");

        buyer = msg.sender;           // 部署者即为买家
        seller = _seller;
        arbiter = _arbiter;
        deliveryTimeout = _deliveryTimeout;
        state = EscrowState.AWAITING_PAYMENT; // 初始状态等待付款
    }

    /**
     * @dev 禁止直接向合约发送ETH，必须调用 deposit()
     */
    receive() external payable {
        revert("Use deposit() function");
    }

    /**
     * @notice 买家存入资金
     * @dev 只有买家可调用，状态必须为 AWAITING_PAYMENT
     */
    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_PAYMENT, "Wrong state");
        require(msg.value > 0, "Must send ETH");

        amount = msg.value;
        depositTime = block.timestamp;
        state = EscrowState.AWAITING_DELIVERY; // 付款后进入等待交付状态

        emit PaymentDeposited(buyer, amount);
    }

    /**
     * @notice 买家确认收到货物，将资金释放给卖家
     * @dev 只有买家可调用，状态必须为 AWAITING_DELIVERY
     */
    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");

        state = EscrowState.COMPLETE;
        payable(seller).transfer(amount); // 将托管资金转给卖家

        emit DeliveryConfirmed(buyer, seller, amount);
    }

    /**
     * @notice 买家或卖家提出争议
     * @dev 只有在 AWAITING_DELIVERY 状态下才能提出争议
     */
    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Only parties");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");

        state = EscrowState.DISPUTED;
        emit DisputeRaised(msg.sender);
    }

    /**
     * @notice 仲裁者解决争议，将资金转给胜诉方
     * @param winner 胜诉方地址（必须是买家或卖家）
     */
    function resolveDispute(address winner) external {
        require(msg.sender == arbiter, "Only arbiter");
        require(state == EscrowState.DISPUTED, "Not disputed");
        require(winner == buyer || winner == seller, "Invalid winner");

        state = EscrowState.COMPLETE;
        payable(winner).transfer(amount); // 资金转给胜诉方

        emit DisputeResolved(winner, amount);
    }

    /**
     * @notice 买家在超时后取消托管，收回资金
     * @dev 只有在 AWAITING_DELIVERY 状态且超过交付期限才能调用
     */
    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");
        require(
            block.timestamp >= depositTime + deliveryTimeout,
            "Timeout not reached"
        );

        state = EscrowState.CANCELLED;
        payable(buyer).transfer(amount); // 资金退还给买家

        emit DeliveryTimeoutReached(buyer);
        emit EscrowCancelled(buyer);
    }

    /**
     * @notice 买卖双方协商一致取消托管，资金退还给买家
     * @dev 简化版本：任何一方都可以直接调用取消（生产环境建议使用签名确认）
     */
    function cancelMutual() external {
        require(msg.sender == buyer || msg.sender == seller, "Only parties");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");

        state = EscrowState.CANCELLED;
        payable(buyer).transfer(amount);

        emit MutualCancellation(buyer, seller);
        emit EscrowCancelled(msg.sender);
    }

    /**
     * @notice 获取距离超时还剩多少时间
     * @return 剩余秒数（如果已超时或不在等待交付状态则返回0）
     */
    function getTimeLeft() external view returns (uint256) {
        if (state != EscrowState.AWAITING_DELIVERY) {
            return 0;
        }

        uint256 deadline = depositTime + deliveryTimeout;
        if (block.timestamp >= deadline) {
            return 0;
        }

        return deadline - block.timestamp;
    }

    /**
     * @notice 获取托管合约的详细信息
     * @return _buyer 买家地址
     * @return _seller 卖家地址
     * @return _arbiter 仲裁者地址
     * @return _amount 托管金额（wei）
     * @return _state 当前状态
     * @return _timeLeft 距离超时的剩余时间（秒）
     */
    function getEscrowInfo() external view returns (
        address _buyer,
        address _seller,
        address _arbiter,
        uint256 _amount,
        EscrowState _state,
        uint256 _timeLeft
    ) {
        uint256 timeLeft = 0;
        if (state == EscrowState.AWAITING_DELIVERY) {
            uint256 deadline = depositTime + deliveryTimeout;
            if (block.timestamp < deadline) {
                timeLeft = deadline - block.timestamp;
            }
        }
        return (buyer, seller, arbiter, amount, state, timeLeft);
    }
}
