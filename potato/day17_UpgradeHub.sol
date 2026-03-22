// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionStorageLayout {
    address public logicContract;
    address public owner;
    
    struct Subscription {
        uint8 planId;
        uint256 expiry;
        bool paused;
    }
    
    mapping(address => Subscription) public subscriptions;
    mapping(uint8 => uint256) public planPrices;
    mapping(uint8 => uint256) public planDuration;
}

contract SubscriptionStorage is SubscriptionStorageLayout {
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;
    }
    
    // 升级逻辑合约
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
    }
    
    // 代理所有函数调用
    fallback() external payable {
        address impl = logicContract;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    
    receive() external payable {}
}

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
            s.expiry += planDuration[planId];  // 延长现有订阅
        } else {
            s.expiry = block.timestamp + planDuration[planId];  // 新订阅
        }
        
        s.planId = planId;
        s.paused = false;
    }
    
    function isActive(address user) external view returns (bool) {
        Subscription storage s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
}

contract SubscriptionLogicV2 is SubscriptionStorageLayout {
    // 继承V1的所有功能
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
        Subscription storage s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
    
    // V2 新增功能
    function pauseAccount(address user) external {
        subscriptions[user].paused = true;
    }
    
    function resumeAccount(address user) external {
        subscriptions[user].paused = false;
    }
    
    // 获取订阅详情
    function getSubscriptionDetails(address user) external view returns (uint8, uint256, bool) {
        Subscription storage s = subscriptions[user];
        return (s.planId, s.expiry, s.paused);
    }
}