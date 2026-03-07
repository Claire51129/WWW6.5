// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter{
    //状态变量-存储点击次数
    uint256 public counter;
    //0以及以上整数可以存储到256位  public意味着所有人都可以点这个按钮
    function click() public {
        counter++;
    }
        
}
