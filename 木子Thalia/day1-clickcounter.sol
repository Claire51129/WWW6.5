// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter {
    // 合约内容
    uint256 public counter;

    function click() public {
        counter++;
    }

    function reset() public {
        counter = 0;
    }

    function decrease() public {
        if (counter > 0) {
            counter --;
        }
    }

    function getCounter() public view returns (uint256){
        return counter;
    }

    function clickMultiple(uint256 times) public {
        require(times > 0, "times must be > 0");
        counter += times;
    }
}

