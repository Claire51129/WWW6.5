// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox {//创建一个新合约，继承 BaseDepositBox 的所有逻辑
    string private metadata;//引入新的状态变量metadata，只能在此合约里调用

    event MetadataUpdated(address indexed owner);

    constructor(address initialOwner) BaseDepositBox(initialOwner) {}

    //识别金库类型
    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }

    //只有主人能设置额外资料
    function setMetadata(string calldata _metadata) external onlyOwner {
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }

    //只有主人能查看额外资料
    function getMetadata() external view onlyOwner returns (string memory) {
        return metadata;
    }
}