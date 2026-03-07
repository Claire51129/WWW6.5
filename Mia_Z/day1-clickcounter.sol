//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
contract ClickCounter{
    //state variable like uint8_t 
    uint256 public counter;
    //function like void
    //public表示任何人都可以调用此函数。
    function click() public{
        counter++;
    }

}