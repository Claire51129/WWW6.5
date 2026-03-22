
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "./Day14-BaseDepositBox.sol";

//basic子合约 没有额外的新功能 只是声明这个是基础版
contract BasicDepositBox is BaseDepositBox{
    constructor(address _owner, address _manager) BaseDepositBox(_owner, _manager) {}

    function getBoxType() external pure override returns(string memory){
        return "Basic";
    }
}
