//最普通的保险箱
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import {BaseDepositBox} from "./day14-BaseDepositBox.sol";

contract BasicDepositBox is BaseDepositBox{    //继承：拥有basedeposit全部功能

    function getBoxType() external pure override returns(string memory){
        return "Basic";
    }
}


// override 覆盖母类函数
// inheritance 继承