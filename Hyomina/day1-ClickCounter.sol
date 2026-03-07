// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter {
    // 状态变量 - 存储点击次数
    uint256 public counter;
    
    // 函数 - 增加计数器
    function click() public {
        counter++;
    }

    // 函数 - 重置为0
    function reset() public {
        counter=0;
    }

    // 函数 - 使计数器减1(提示:注意不要让它变成负数!)
    function decrease() public {
        require (counter>0,"Counter: cannot decrease below zero");
        counter-=1;
    }

    // 函数,明确返回当前计数(提示:使用view修饰符)
    function getCounter() public view returns (uint256) {
        return counter;
    }

   // 函数,明确返回当前计数(提示:使用view修饰符)
    function clickMultiple(uint256 times) public {
        require(times>0, "Counter must be greater than 0");
        counter+=times;
    }

}