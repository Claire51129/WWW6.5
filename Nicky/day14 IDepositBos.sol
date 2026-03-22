// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDepositBox { // interface:只规定合约提供哪些function及function 特征，不包含具体的实现代码
    function getOwner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function storeSecret(string calldata secret) external;
    function getSecret() external view returns (string memory);
    function getBoxType() external pure returns (string memory);
    function getDepositTime() external view returns (uint256);
}