//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./day14_IDepositBox.sol";

abstract contract BaseDepositBox is IDepositBox{
    address private owner;
    string private secret;
    uint256 private depositTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecretStored(string secret, uint256 timestamp);

    constructor(address initialOwner) {
        require(initialOwner != address(0), "Initial owner cannot be the zero address");
        owner = initialOwner;
        depositTime = block.timestamp;
    }

    modifier onlyOwner(address caller) {
        require(caller == owner, "Only the owner can call this function");
        _;
    }

    function getOwner() public view override returns (address) {
        return owner;
    }

    function transferOwnership(address newOwner, address caller) external virtual override onlyOwner(caller) {
        require(newOwner != address(0), "New owner cannot be the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function storeSecret(string calldata _secret, address caller) external virtual override onlyOwner(caller) {
        secret = _secret;
        emit SecretStored(_secret, block.timestamp);
    }

    function getSecret(address caller) public view virtual override onlyOwner(caller) returns (string memory) {
        return secret;
    }

    function getDepositTime() external view virtual override returns(uint256) {
        return depositTime;
    }
    
}