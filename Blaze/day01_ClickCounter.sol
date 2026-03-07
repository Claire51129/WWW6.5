// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter {
    // 状态变量 - 存储点击次数
    uint256 public counter;

    // 函数 - 增加计数器
    function click() public {
        counter++;
    }

    // 函数 - 计数器重置为0
    function reset() public {
        counter = 0;
    }

    //使计数器减1
    function decrease() public {
        require(counter > 0, "Counter is already at 0");
        counter -= 1;
    }

    //返回当前计数
    function getCounter() public view returns (uint256) {
        return counter;
    }
    
    //一次增加多次
    function clickMultiple(uint256 times) public {
        counter += times;
    }


}