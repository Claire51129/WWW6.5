// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_2_BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox {
    // private，这意味着只有此合约内的函数可以读取或修改它。
    string private metadata;

    event MetadataUpdated(address indexed owner);

    constructor(address initialOwner) BaseDepositBox(initialOwner) {}
    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }
   // 仅所有者可修改 metadata 的函数（外部访问入口）
   // external：只能从合约外部调用（不能从内部调用）
    function setMetadata(string calldata _metadata) external onlyOwner {
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }
    // 仅所有者可读取 metadata 的函数（外部访问入口）
    function getMetadata() external view onlyOwner returns (string memory) {
        return metadata;
    }
}
