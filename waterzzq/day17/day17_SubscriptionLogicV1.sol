// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入共享存储布局
import "./day17_SubscriptionStorageLayout.sol";

// 第一版逻辑：基础订阅功能
contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    // 只有所有者能调用的修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this!");
        _;
    }

    // 初始化：第一次部署时设置所有者
    function initialize() external {
        require(owner == address(0), "Already initialized!");
        owner = msg.sender;
    }

    // 新增订阅套餐：只有所有者能加
    function addPlan(uint8 planId, uint256 price, uint256 duration) external onlyOwner {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    // 用户订阅套餐：支付ETH订阅
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "This plan doesn't exist!");
        require(msg.value >= planPrices[planId], "Not enough ETH!");

        Subscription storage s = subscription[msg.sender];
        if (block.timestamp < s.expiry) {
            // 没到期：延长订阅时间
            s.expiry += planDuration[planId];
        } else {
            // 已到期：重新计算到期时间
            s.expiry = block.timestamp + planDuration[planId];
        }
        s.planId = planId;
        s.paused = false; // 订阅时自动取消暂停
    }

    // 检查订阅是否活跃：没到期 + 没暂停
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscription[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
}