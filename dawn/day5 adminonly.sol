// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;

contract adminonly {
    address public owner;
    uint256 public treasureamount;

    mapping (address => uint256) public withdrawalallowance;

    mapping (address => bool) public haswithdrawn;

    constructor () {
        owner = msg.sender;
    }

    modifier onlyowner() {
        require (msg.sender == owner, "not the owner");
        _;
    }

    function addtreasure(uint256 amount) public onlyowner {
        treasureamount += amount;
    }

    function approvewithdrawal (uint256 amount) public {
        require(amount <= withdrawalallowance[msg.sender], "insufficient allowance");
        require(!haswithdrawn[msg.sender], "already withdrawn");

        haswithdrawn[msg.sender] = true;
        withdrawalallowance[msg.sender] -= amount;
    }

    function resetwithdrawalstatus(address user) public onlyowner {
        haswithdrawn[user] = false;
    }

    function transferOwnership (address newOwner) public onlyowner {
        owner = newOwner;
    }

    function gettreasuredetails() public view onlyowner returns (uint256) {
        return treasureamount;
    }
}