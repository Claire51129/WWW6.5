// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入基类
import "./day17_storagelayout.sol";

/**
 * @title day17_logicv1
 * @dev 业务逻辑合约 V1 版本。
 *      文件名: day17_logicv1.sol
 *      合约名: day17_logicv1
 */
contract day17_logicv1 is day17_storagelayout {
    
    // 添加订阅计划
    function addPlan(uint8 _planId, uint256 _price, uint256 _duration) external {
        require(msg.sender == owner, "Only owner can add plans");
        require(_price > 0, "Price must be greater than 0");
        
        planPrices[_planId] = _price;
        planDuration[_planId] = _duration;
    }
    
    // 用户订阅
    function subscribe(uint8 _planId) external payable {
        require(planPrices[_planId] > 0, "Plan does not exist");
        require(msg.value >= planPrices[_planId], "Insufficient payment");
        
        Subscription storage sub = subscriptions[msg.sender];
        
        // 如果已过期，重新计算；如果未过期，累加时间
        if (sub.expiry > block.timestamp) {
            sub.expiry += planDuration[_planId];
        } else {
            sub.expiry = block.timestamp + planDuration[_planId];
        }
        
        sub.planId = _planId;
        sub.paused = false;
        
        // 这里可以将多余的钱退还，或者将钱转入所有者地址
        // 为简化演示，暂不处理转账逻辑
    }
    
    // 检查用户是否活跃
    function isActive(address _user) external view returns (bool) {
        Subscription storage sub = subscriptions[_user];
        return (sub.expiry > block.timestamp && !sub.paused);
    }
    
    // 获取所有者 (用于测试)
    function getOwner() external view returns (address) {
        return owner;
    }
}