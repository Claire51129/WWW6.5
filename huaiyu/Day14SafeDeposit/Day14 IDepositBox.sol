//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

//金库接口，IDepositBox 是一个 Solidity interface，只定义函数签名，不包含实现；用于其他合约或外部调用方与实现该接口的合约交互。
interface IDepositBox {
    function getOwner() external view returns(address);
    function transferOwnership(address newOwner) external;
    function storeSecret(string calldata secret) external;
    function getSecret() external view returns (string memory);
    function getBoxType() external pure returns (string memory);
    function getDepositTime() external view returns (uint256);
}