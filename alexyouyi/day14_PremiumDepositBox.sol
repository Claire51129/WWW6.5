//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./day14_BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox {

    constructor(address initialOwner) BaseDepositBox(initialOwner) {
    }

    string private metadata;
    event MetadataUpdated(address indexed owner);

    function getBoxType() public pure override returns (string memory) {
        return "Premium";
    }

    function setMetadata(string calldata _metadata, address caller) external onlyOwner(caller) {
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }

    function getMetadata(address caller) external view onlyOwner(caller) returns (string memory) {
        return metadata;
    }
    
}