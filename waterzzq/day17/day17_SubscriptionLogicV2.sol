// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day17_SubscriptionStorageLayout.sol";

// 第二版逻辑：在V1基础上加暂停/恢复功能
contract SubscriptionLogicV2 is SubscriptionStorageLayout {
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this!");
        _;
    }

    function initialize() external {
        require(owner == address(0), "Already initialized!");
        owner = msg.sender;
    }

    // 【V1的功能全部保留】
    function addPlan(uint8 planId, uint256 price, uint256 duration) external onlyOwner {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "This plan doesn't exist!");
        require(msg.value >= planPrices[planId], "Not enough ETH!");

        Subscription storage s = subscription[msg.sender];
        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId];
        } else {
            s.expiry = block.timestamp + planDuration[planId];
        }
        s.planId = planId;
        s.paused = false;
    }

    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscription[user];
        return (block.timestamp < s.expiry && !s.paused);
    }

    // 【V2新增：暂停用户订阅】
    function pauseAccount(address user) external onlyOwner {
        subscription[user].paused = true;
    }

    // 【V2新增：恢复用户订阅】
    function resumeAccount(address user) external onlyOwner {
        subscription[user].paused = false;
    }
}