// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter {
    // 只要声明为 public，Solidity 就会自动创建一个“只读按钮”
    // 它在底层等同于一个 view 函数
    uint256 public counter;

    function click() public {
        counter++;
    }

    function reset() public {
        counter = 0;
    }

    function decrease() public {
        require(counter > 0, "Counter is already zero");
        counter--;
    }

    function clickMultiple(uint256 times) public {
        counter += times;
    }
}
