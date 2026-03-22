// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Day17_Assembly {
    function assemblyAdd(uint256 x, uint256 y) public pure returns (uint256 result) {
        assembly {
            result := add(x, y)
        }
    }

    function assemblyLoad(uint256[] memory data) public pure returns (uint256 result) {
        assembly {
            // Load the length of the array (first 32 bytes)
            let length := mload(data)
            // Load the first element (next 32 bytes)
            result := mload(add(data, 0x20))
        }
    }
}
