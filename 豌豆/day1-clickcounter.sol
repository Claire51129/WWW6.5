// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter {
    // 状态变量 - 存储点击次数
    uint256 public counter;

    // 函数 - 增加计算器
    function click() public {
        counter++;
    }

// 1.重置计算器为0
function reset() public {
    counter = 0;
}

// 2.减少计算器（不能为负数）
function descrease() public {
    require(counter > 0, "Counter cannot go negative");
    counter--;
}

// 3.显示返回当前技术值（view 修饰符）
function getCounter() public view returns (uint256) {
    return counter;
}

// 4.一次增加多次计数
function clickMultiple(uint256 times) public {
    counter +=times; //直接加法，Solidity 0.8.x 会自动检查溢出
}

}