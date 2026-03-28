//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

contract SubscriptionStorageProxy is SubscriptionStorageLayout {
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    constructor(address _logicContract) {
        owner = msg.sender;
        LogicContract = _logicContract;
    }

    function upgradeTo(address newLogic) external onlyOwner {
        // require(msg.sender == owner, "Only owner can upgrade logic contract");
        LogicContract = newLogic;
    }

    fallback() external payable {
        address impl = LogicContract;
        require(impl != address(0), "Logic contract not set");

        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {
        // Allow the contract to receive Ether
    }
    
    
    
}