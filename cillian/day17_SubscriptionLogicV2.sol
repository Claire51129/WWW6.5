// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

/**
 * @title SubscriptionLogicV2
 * @dev 订阅系统逻辑实现合约（V2 升级版）。
 * 相比 V1，新增了对订阅状态的开关控制（暂停/恢复）。
 * 注意：由于是通过代理合约 delegatecall 调用，此合约的变量布局必须与 V1 及 Storage 合约完全一致。
 */
contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    
    /**
     * @notice 配置订阅套餐
     * @dev 管理员功能，定义不同等级的收费标准和有效时长
     */
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    /**
     * @notice 用户支付并订阅
     * @dev 逻辑包含：验证套餐、处理支付、计算到期时间（支持续费）
     */
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");

        // 使用 storage 关键字直接修改代理合约中的持久化存储
        Subscription storage s = subscriptions[msg.sender];
        if (block.timestamp < s.expiry) {
            // 续费场景：在当前到期日基础上叠加时长
            s.expiry += planDuration[planId];
        } else {
            // 新购或过期重购场景：从当前区块时间开始计算
            s.expiry = block.timestamp + planDuration[planId];
        }

        s.planId = planId;
        s.paused = false; // 购买后自动确保状态为开启
    }

    /**
     * @notice 视图函数：检查用户会员资格是否依然有效
     * @return bool 有效则返回 true（未过期且未暂停）
     */
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }

    /**
     * @notice 暂停账户订阅
     * @dev 新增功能：手动将 paused 状态置为 true。
     * 场景：用户主动申请冻结，或管理员因风险管控临时关闭服务。
     */
    function pauseAccount(address user) external {
        subscriptions[user].paused = true;
    }

    /**
     * @notice 恢复账户订阅
     * @dev 将 paused 状态置回 false。
     */
    function resumeAccount(address user) external {
        subscriptions[user].paused = false;
    }
}