
//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0; // solidit version

contract ClickCounter{
    //state variable
    uint256 public counter; //uint:unassigned integer >=0

    //function increase by 1 per click
    function click() public {
        counter++;
    }


}