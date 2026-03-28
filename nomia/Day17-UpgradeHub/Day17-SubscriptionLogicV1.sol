 // SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//导入统一的存储布局 逻辑合约在通过delegatecall执行时会按照和代理合约一样的变量顺序读写数据
import "./Day17-SubscriptionStorageLayout.sol";


contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;

    }

    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");

        Subscription storage s = subscriptions[msg.sender];
        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId];
        } else {
            s.expiry = block.timestamp + planDuration[planId];

        }

        s.planId = planId;
        s.paused = false;

    }

    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }

}

