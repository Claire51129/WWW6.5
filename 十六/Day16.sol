// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault_V1 (Implementation)
 */
contract Vault_V1 {
    uint256 public value;

    function setValue(uint256 _value) public {
        value = _value;
    }
}

/**
 * @title Vault_V2 (Upgraded Implementation)
 */
contract Vault_V2 {
    uint256 public value;

    function setValue(uint256 _value) public {
        value = _value * 2;
    }

    function resetValue() public {
        value = 0;
    }
}

/**
 * @title Vault_Proxy
 */
contract Vault_Proxy {
    // Storage slot 0: implementation address
    // Storage slot 1: admin address
    // WARNING: Storage collision must be avoided in production using EIP-1967
    address public implementation;
    address public admin;

    constructor(address _implementation) {
        implementation = _implementation;
        admin = msg.sender;
    }

    modifier olyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    function upgrade(address _newImplementation) external olyAdmin {
        implementation = _newImplementation;
    }

    fallback() external payable {
        address _impl = implementation;
        assembly {
            // Copy msg.data
            calldatacopy(0, 0, calldatasize())

            // Execute delegatecall
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)

            // Copy return data
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}
