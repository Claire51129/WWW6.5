// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter {

    // 状态变量counter（计数器）, 存储点击数
    uint256 public counter;

    // 函数，使计数器加一
    function click() public {
        counter++;
    }

    // 函数，将计数器重置为0
    function reset() public {
        counter = 0;
    }

    // 函数，将计数器减一，并防止下溢
    function decrease() public {
        require(counter > 0, "counter is already 0."); //require用来检查条件，在这里虽然已经定义counter是非负整数(unit)，但为了安全要防止“整数溢出”(integer overflow/underflow)
        counter--;
    }
    
    //函数，返回计数器数值，并用修饰符view告知编译器
    function getCounter() public view returns (uint256) { //使用view告诉区块链，我“只读不写”，就不用支付Gas费
        return counter;
    }

    //函数，可以自定义增加计数器的数值
    function clickMultiple(uint256 times) public { //对比counter，这里times为形式参数，只作临时传递，只在内存中运算，成本较低
        counter += times;
    }
}