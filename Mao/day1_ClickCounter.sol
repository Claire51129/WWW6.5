//SPDX-Lisense-Identifier:MIT


//编译器版本  `pragma`: 编译器指令关键字^0.8.0: 表示使用0.8.0或更高版本,但低于0.9.0
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//计数合约
contract ClickCounter {
   
    //uint256 无符号正数 public状态变量，自动生成getter函数
    uint256 public counter;

    //函数-增加计数器
    function click() public {
        counter++;
    }

   //函数-重置计数器
   function reset() public{
        counter = 0;
   }

   //函数-减数计数器
   function decrease() public{
       require(counter>=1 , "counter is already zero");
          counter--;
       
   }

   //函数-返回当前计数器
   function getCounter() public view returns (uint256) {
        return counter;
    }

   //函数-一次增加多次
    function clickMultiple(uint256 times) public {
        require(times > 0, "times must be greater than 0");
        counter += times;
    }

}