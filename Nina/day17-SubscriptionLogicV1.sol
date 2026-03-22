/* 第一版逻辑合约 */

 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17-SubscriptionStorageLayout.sol";

contract SubscriptionLogicV1 is SubscriptionStorageLayout {

    // 添加新套餐
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    // 用户订阅
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");

        Subscription storage s = subscriptions[msg.sender]; // 修改持久化数据：这里的 s 是一个指针（Pointer），它直接指向了存在区块链硬盘上的那个 subscriptions[msg.sender]。函数执行完后，这些修改会永远保存在链上。
        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId];
        } else {
            s.expiry = block.timestamp + planDuration[planId];
        }

        s.planId = planId;
        s.paused = false;
    }

    // 检查活跃状态
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user]; // 只读且省钱：这里的 s 是一个副本（Copy）。它把链上的数据“复印”了一份，放在内存里。在 view 函数中，读取到内存通常比直接操作存储指针更符合逻辑且有时更安全。
        return (block.timestamp < s.expiry && !s.paused);
    }
}

/** 逻辑合约A已部署。
    代理合约B已部署。
    CONTRACT = A
    At Address = B: 在B（代理合约）这个address运行 A contract（逻辑合约）。（不再点击deploy）

    下方 "Deployed Contracts" 列表里多了一个新条目。
    你会看到一个长得像 SubscriptionLogicV1 的实例。
    当你点击这些按钮时，请求是发往 代理合约地址 的。
    代理合约会通过fallback()和delagatecall去逻辑合约里找代码执行请求，数据保存在代理合约中。
*/