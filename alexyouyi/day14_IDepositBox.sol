//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDepositBox{
    function getOwner() external view returns (address);
    function transferOwnership(address newOwner, address caller) external;
    function storeSecret(string calldata secret, address caller) external;
    function getSecret(address caller) external view returns (string memory);
    function getBoxType() external pure returns (string memory);
    function getDepositTime() external view returns (uint256);
    
}