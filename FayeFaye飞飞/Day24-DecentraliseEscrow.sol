// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnhancedSimpleEscrow {
    enum EscrowState {
        AWAITING_PAYMENT,
        AWAITING_DELIVERY,
        COMPLETE,
        DISPUTED,
        CANCELLED
    }
    
    address public buyer;
    address public seller;
    address public arbiter;
    uint256 public amount;
    EscrowState public state;
    uint256 public depositTime;
    uint256 public deliveryTimeout;
    
    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(address indexed raisedBy);
    event DisputeResolved(address indexed winner, uint256 amount);
    event EscrowCancelled(address indexed canceledBy);
    event DeliveryTimeoutReached(address indexed buyer);
    event MutualCancellation(address indexed buyer, address indexed seller);
    
    constructor(
        address _seller,
        address _arbiter,
        uint256 _deliveryTimeout
    ) {
        require(_seller != address(0), "Invalid seller");
        require(_arbiter != address(0), "Invalid arbiter");
        require(_deliveryTimeout > 0, "Invalid timeout");
        
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        deliveryTimeout = _deliveryTimeout;
        state = EscrowState.AWAITING_PAYMENT;
    }
    
    // 阻止直接ETH转账
    receive() external payable {
        revert("Use deposit() function");
    }
    
    // 买家存款
    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_PAYMENT, "Wrong state");
        require(msg.value > 0, "Must send ETH");
        
        amount = msg.value;
        depositTime = block.timestamp;
        state = EscrowState.AWAITING_DELIVERY;
        
        emit PaymentDeposited(buyer, amount);
    }
    
    // 买家确认交付
    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");
        
        state = EscrowState.COMPLETE;
        (bool success, ) = payable(seller).call{value: amount}("");
         require(success, "Transfer to seller failed");
        
        emit DeliveryConfirmed(buyer, seller, amount);
    }
    
    // 提起争议
    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Only parties");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");
        
        state = EscrowState.DISPUTED;
        emit DisputeRaised(msg.sender);
    }
    
    // 仲裁者解决争议
    function resolveDispute(address winner) external {
        require(msg.sender == arbiter, "Only arbiter");
        require(state == EscrowState.DISPUTED, "Not disputed");
        require(winner == buyer || winner == seller, "Invalid winner");
        
        state = EscrowState.COMPLETE;
        (bool success, ) = payable(winner).call{value: amount}("");
         require(success, "Transfer to winner failed");
        
        emit DisputeResolved(winner, amount);
    }
    
    // 超时后取消
    function cancelAfterTimeout() external {
        require(msg.sender == buyer, "Only buyer");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");
        require(
            block.timestamp >= depositTime + deliveryTimeout,
            "Timeout not reached"
        );
        
        state = EscrowState.CANCELLED;
        (bool success, ) = payable(buyer).call{value: amount}("");
         require(success, "Refund to buyer failed");
        
        emit DeliveryTimeoutReached(buyer);
        emit EscrowCancelled(buyer);
    }
    
    // 双方同意取消
    function cancelMutual() external {
        require(msg.sender == buyer || msg.sender == seller, "Only parties");
        require(state == EscrowState.AWAITING_DELIVERY, "Wrong state");
        
        // 简化版本：任何一方都可以取消
        // 生产版本应该需要双方签名
        state = EscrowState.CANCELLED;
        (bool success, ) = payable(buyer).call{value: amount}("");
         require(success, "Refund to buyer failed");
        
        emit MutualCancellation(buyer, seller);
        emit EscrowCancelled(msg.sender);
    }
    
    // 获取剩余时间
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
    
    // 获取合约信息
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