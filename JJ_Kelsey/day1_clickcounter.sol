//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ClickCounter {
    uint256 public counter;

    function click() public {
        counter++;
    }

    function reset() public {
        counter = 0;
    }

    function decrease() public {
        require(counter > 0, "Counter cannot be less than 0");
        counter -=1;
    }

    function getCounter() public view returns (uint256) {
        return counter;
    }
    function clickMultipler(uint256 times) public {
        counter += times;
    }

}