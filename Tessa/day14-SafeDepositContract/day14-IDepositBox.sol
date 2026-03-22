//【接口】保险箱的规则说明书：任何保险箱都必须有这些功能
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

interface IDepositBox {    //接口：只写规则，不写实现

    function getOwner() external view returns(address);    //获取主人：查询保险箱主人是谁。external-外部调用
    function transferOwnership(address newOwner)external;    //转移所有权
    function storeSecret(string calldata secret)external;    //存秘密：往保险箱里放“秘密”
    function getSecret() external view returns (string memory);    //取秘密：打开保险箱看秘密。view-只读
    function getBoxType() external pure returns(string memory);    //获取箱子类型：basic、premium、timelocked。pure-不读不写
    function getDepositTime() external view returns(uint256);    //获取存入时间：什么时候创建这个箱子
}