//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "./Day14_BaseDepositBox.sol";

contract Day14_PremiumDepositBox is Day14_BaseDepositBox {
    
    string private metadata;
    event MetadataUpdated(address indexed owner);

    function getBoxType() external pure override returns(string memory){
        return "Premium";
    }

    function setMetadata(string calldata _metadata) external onlyOwner{
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }

    function getMeta() external view onlyOwner returns(string memory) {
        return metadata;
    }
}