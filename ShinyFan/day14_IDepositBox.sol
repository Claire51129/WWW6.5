//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

interface IDepositBox {

    function getOwner() external view returns(address);//返回存款箱的当前所有者地址
    function transferOwnership(address newOwner)external;//转让所有权
    function storeSecret(string calldata secret)external;//一个用于将字符串（我们的“秘密”）保存在金库中的函数  calldata：只读的临时数据
    function getSecret() external view returns (string memory);//检索储存的秘密
    function getBoxType() external pure returns(string memory);//检索存款箱类型
    function getDepositTime() external view returns(uint256);//返回存款箱的创建时间
}