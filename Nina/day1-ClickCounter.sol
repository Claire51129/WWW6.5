//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter {
    //状态变量-存储点击次数
    uint256 public counter;

    //函数-增加计数器
    function click() public {
        counter++;
    }

    //递减函数：带安全检查
    function decrease() public {
        //在减法之前，必须确保counter大于0
        //如果counter是0，调用这个函数会报错并撤回交易（防止变成负数）
        require(counter > 0,"Counter already at zero");
        counter--;
    }

    //一次增加多数，times是用户输入参数
    function clickMultiple(uint256 times) public{
        counter+=times;
    }
}

