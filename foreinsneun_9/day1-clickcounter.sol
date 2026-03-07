//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
contract ClickCounter {
    uint256 public counter;
    function click() public {
        counter ++;
    }
    function clickMultiple(uint256 times) public{
        counter += times;
    }
    function reset() public {
        counter = 0;
    }
    function decrease() public {
        if(counter>0){
            counter --;
        }
    }
}
contract BetweenAdditionAndSubstraction {
    uint256 public additionOps;
    uint256 public substractionOps;
    int public counter;
    function addition() public {
        counter ++;
        additionOps ++;
    }
    function substraction() public {
        counter --;
        substractionOps ++;
    }
}