// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract ClickCounter{

    uint256 public counter ;

    function click() public 
    {
        counter ++;
    }
    // 1. 重置计数器为0
    function reset() public {
        counter = 0;
    }

    // 2. 减少计数器（不能为负数）
    function decrease() public {
        require(counter > 0, "Counter cannot go negative");
        counter--;
    }

    // 3. 显式返回当前计数值（view 修饰符）
    function getCounter() public view returns (uint256) {
        return counter;
    }

    // 4. 一次增加多次计数
    function clickMultiple(uint256 times) public {
        counter += times; // 直接加法，Solidity 0.8.x 会自动检查溢出
    }
    //commit again version with the right naming?
   
}