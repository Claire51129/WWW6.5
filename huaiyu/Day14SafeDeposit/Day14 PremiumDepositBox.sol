//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./Day14 BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox {
    string private metadata;//metadata被标记为private，表示只有此合约内的函数可以读取或修改它

    event MetadataUpdated(address indexed owner);//MeradataUpdated事件

    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }

    function setMetadata(string calldata _metadata) external onlyOwner {
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }

    function getMetadata() external view onlyOwner returns (string memory) {
        return metadata;
    }
}