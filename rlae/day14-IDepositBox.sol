// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IDepositBox { 
    //接口,所需函数的简单规则手册。每个金库都必须遵守此规则。
    function getOwner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function storeSecret(string calldata secret) external; // 用于将字符串（我们的“秘密”）保存在金库中The calldata keyword indicates that the secret parameter is stored in calldata memory location. 
    function getSecret() external view returns (string memory); //检索存储的秘密
    function getBoxType() external pure returns (string memory); //哪种类型的存款箱
    function getDepositTime() external view returns (uint256); //返回存款箱的创建时间
}