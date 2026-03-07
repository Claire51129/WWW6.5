// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 新增：记录谁部署了这个合约
contract ClickCounter {
    uint256 public counter;
    address public owner;  

    // 新增：部署时自动记录部署者地址
    constructor() {
        owner = msg.sender;
    }

    // 原有：点击+1
    function click() public {
        counter++;
    }

    // 挑战1：重置，只有部署者能调用
    function reset() public {
        require(msg.sender == owner, "Only owner can reset");
        counter = 0;
    }

    // 挑战2：减1，不能变负数
    function decrease() public {
        require(counter > 0, "Cannot go below zero");
        counter--;
    }

    // 挑战3：只读函数，不花gas
    function getCounter() public view returns (uint256) {
        return counter;
    }

    // 挑战4：一次加多次
    function clickMultiple(uint256 times) public {
        counter += times;
    }
}