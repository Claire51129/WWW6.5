//  SPDX-License-Identifier:MIT
//许可协议
pragma solidity ^0.8.0;
//告知版本可用
contract ClickCounter{
    //定义点击计时器
    uint256 public counter ;
    //整型公开
    function click() public
    //点击作用定义
    {
        counter++;
        //递增
    }
}