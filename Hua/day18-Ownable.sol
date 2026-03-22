// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address private _owner;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    constructor(address initialOwner) {
        _owner = initialOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }
}
