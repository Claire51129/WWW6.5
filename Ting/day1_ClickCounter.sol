// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract ClickCounter{
    
    uint256 public counter;

    function click() public
    {
        counter++;
    }

    function reset() public
    {
        counter = 0;
    }

    function descrease() public
    {
        require(counter > 0,"error");
        counter --;
    }

    function getCounter() public view returns(uint256)
    {
        return counter;
    }

    function addMultiple(uint256 num) public
    {
        counter+=num;
    }

}