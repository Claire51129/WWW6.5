// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter {
    // 状态变量 - 存储点击次数
    uint256 public counter;
    
    // 函数 - 增加计数器
    function click() public {
        counter++;
    }

    //函数 - 重制计数器
    function reset() public {
        counter = 0;
    }

    //函数 - 减少计数器
    function decrease() public {
        require(counter > 0, "Counter must be greater than 0");
        counter --;
    }

    //函数 - 返回当前计数
    function getCounter() public view returns (uint256) {
        return counter;
    }

    //函数 - 增加多次
    function clickMultiple(uint256 times) public {
        counter += times;
    }
}
