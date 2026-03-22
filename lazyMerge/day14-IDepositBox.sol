//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

interface IDepositBox {

    // 这里是接口，定义好所有的规则

    // 返回当前所有者
    function getOwner() external view returns(address);
    // 修改所有者
    function transferOwnership(address newOwner)external;
    // 保存密码
    function storeSecret(string calldata secret)external;
    // 查询存储密码
    function getSecret() external view returns (string memory);
    // 查询存储密码的创建时间
    function getDepositTime() external view returns(uint256);
    // 查询存储密码的类型
    function getBoxType() external pure returns(string memory);
}