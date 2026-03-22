//第一个逻辑合约，这个合约处理：添加新套餐、用户订阅、检查活跃状态
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayou.sol";

contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    //套餐编号，套餐价格，套餐持续时间
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");//套餐是否有效
        require(msg.value >= planPrices[planId], "Insufficient payment");//用户是否发送了足够的 ETH

        Subscription storage s = subscriptions[msg.sender];//获取调用者的订阅记录
        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId];
        } else {
            s.expiry = block.timestamp + planDuration[planId];
        }//如果你已经是会员（还没过期）：系统就在你原来的到期时间上往后加时间
        //如果你是新会员（或者已经过期了）：系统就从现在这一秒 (block.timestamp) 开始计算

        s.planId = planId;//记录选择的套餐
        s.paused = false;
        //你的账号状态是正常的，不是暂停的 (s.paused = false)。即使你之前暂停了账号，只要一交钱续费，系统会自动帮你恢复正常
    }
 
 //判断一个玩家的会员状态现在是否还有效
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];
        //根据你提供的玩家地址 (user)，去大账本里把这个人的会员信息卡取出来，暂时放在机器的脑子里（Memory）这张卡上写着他的到期时间和是否被暂停了。
        return (block.timestamp < s.expiry && !s.paused);
        //检查有没有过期且有没有被暂停，双重保障
    }
}
