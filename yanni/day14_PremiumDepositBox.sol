// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_BaseDepositBox.sol";

//通过声明 PremiumDepositBox 为 BaseDepositBox 的子类来扩展它
contract PremiumDepositBox is BaseDepositBox {
    //metadata只有此合约内的函数可以读取或修改它
    string private metadata;

    //事件
    event MetadataUpdated(address indexed owner);

    //识别金库类型
    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }

    //允许所有者将注释、类别或标签附加到金库
    function setMetadata(string calldata _metadata) external onlyOwner {
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }

    //允许所有者检索他们之前存储的元数据
    function getMetadata() external view onlyOwner returns (string memory) {
        return metadata;
    }
}
