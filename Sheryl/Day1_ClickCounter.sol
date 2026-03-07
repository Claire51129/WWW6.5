// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter {
    // State Variable - Store click counts
    uint256 public counter;
    //Function - Increasing the Counter
    function click() public {
        counter++;
    }
    //Function - Reset the counter to zero
    function reset() public {
        counter = 0;
    }
    //Function - Decrease the counter
    function decrease() public {
        if (counter > 0) {
            counter = counter - 1;
        } 
    }
    //Function - Return the current count
    function getCounter() public view returns (uint256){
        return counter;
    }
    //Function - Click multiple times
    function clickMultiple(uint256 times) public {
        counter = counter + times;
    }
}
