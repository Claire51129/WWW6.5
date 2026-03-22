//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

interface IDepositBox {

    function getOwner() external view returns(address); //返回存款箱的当前所有者。
    function transferOwnership(address newOwner)external; //所有权转移.
    function storeSecret(string calldata secret)external; //允许存款箱的所有者存储一个秘密字符串。
    function getSecret() external view returns (string memory); //返回存储的秘密字符串。
    function getBoxType() external pure returns(string memory); //存款箱的类型
    function getDepositTime() external view returns(uint256); //返回最后一次存储秘密的时间戳。

}