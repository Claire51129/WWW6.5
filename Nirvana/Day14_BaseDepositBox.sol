//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 
import "./Day14_IDepositBox.sol";

abstract contract Day14_BaseDepositBox is Day14_IDepositBox {

    address private owner;
    string private secret;
    uint256 private depositTime;

    event OwnershipTransfer(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner);

    modifier onlyOwner() {
    require(msg.sender == owner, "Not the box owner");
    _;
    }

    constructor() {
        owner = msg.sender;
        depositTime = block.timestamp;
    }

    function getOwner() public view override returns(address){
        return owner;
    }

    function transferOwnership(address newOwner) external virtual override onlyOwner{
        require(newOwner != address(0), "Ownership cannot be transferred to zero address");
        emit OwnershipTransfer(owner, newOwner);
        owner = newOwner;
    }

    function storeSecret(string calldata _secret) external virtual override onlyOwner{
        secret = _secret;
        emit SecretStored(msg.sender);
    }

    function getSecret() public view virtual override onlyOwner returns(string memory){
        return secret;
    }

    function getDepositTime() external view virtual override onlyOwner returns(uint256){
        return depositTime;
    }

}