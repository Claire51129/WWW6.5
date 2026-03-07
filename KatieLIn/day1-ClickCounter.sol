// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ClickCounter{

    uint256 public counter = 0 ;

    function click () public{

        counter++;
    }

    function reset () public {
        counter=0;
    }

    function decrease () public {
            require(counter > 0,"counter is already zero");
            counter--;
    }

    function getCounter() public view returns (uint256) {
        return counter;

    }

    function clickMultiple (uint256 times) public {
        require(times>0,"Time must be greater than 0");
        counter+=times;
    }
}

