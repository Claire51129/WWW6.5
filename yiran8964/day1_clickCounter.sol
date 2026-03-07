//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter{
    //状态变量 - 存储点击次数
    uint256 public counter;

    //函数 - 增加计数器
    function click() public {
        counter++;
    }

    //函数 - 重置计数器
    function reset() public {
        counter = 0;
    }

    //函数 - 减少计数器
    function decrease() public {
        if (counter > 0) {
            counter--;
        }
    }

    //函数 - 获取当前的计数结果
    function getCount() public view returns(uint256){
        return counter;
    }

    //函数 - 一次增加几个数
    function clickMultiple(uint256 times) public {
        counter = counter + times;
    }

}