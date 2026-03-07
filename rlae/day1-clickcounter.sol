// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract ClickCounter {
    uint256 public counter;
    uint256 constant times = 10;
    function click() public {
        counter++;
    }
    function reset() public {
        counter = 0;
    }
    function decrease() public {
        counter--;
    }
    function getCounter() public view returns (uint256) {
        return counter;
    }
    function clickMultiple() public {
        counter += times;
    }
}
