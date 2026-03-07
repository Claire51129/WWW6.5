// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter {
    uint256 public clickCount;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function click() public {
        clickCount += 1;
    }

    function reset() public {
        require(msg.sender == owner, "Only the owner can reset the counter");
        clickCount = 0;
    }

    // decrease, make sure it doesn't go below 0
    function decrease() public {
        if (clickCount > 0) {
            clickCount -= 1;
        }
    }

    // clickMultiple, takes a number and increases the click count by that number
    function clickMultiple(uint256 _numClicks) public {
        clickCount += _numClicks;
    }
}