// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox {
  // 这里引入了一个新的变量 private 内部才能读取或者修改
    string private metadata; 

    event MetadataUpdated(address indexed owner);

    // 刚才是 base 这里是 premium 这里区分不同的藏宝盒
    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }
    // external 外部调用 传入 metadata
    function setMetadata(string calldata _metadata) external onlyOwner {
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }

    function getMetadata() external view onlyOwner returns (string memory) {
        return metadata;
    }
}
