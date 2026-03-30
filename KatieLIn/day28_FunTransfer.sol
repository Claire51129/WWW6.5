// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FunTransfer {
    address public owner;
    uint256 public received;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        received += msg.value;
    }

    function receiveEther() external payable {
        received += msg.value;
    }

    function withdrawEther() external {
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}