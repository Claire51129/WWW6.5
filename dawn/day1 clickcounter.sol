// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract clickcounter {
    //
    uint256 public counter;

    //
    function click()public {
        counter++;
    }
    //
    function reset()public {
        counter = 0;
    }

    //
    function decrease()public {
        require(counter > 0, "counter is already zero");
        counter--;
    }

    //
    function getcounter()public view returns(uint256) {
        return counter;
    }

    //
    function clickmultiple(uint256 times)public  {
        counter += times;
}
}