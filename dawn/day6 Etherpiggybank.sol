// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherPiggyBank {
    address public bankmanager;
    address[] members;
    mapping (address => bool) public registeredmembers;
    mapping (address => uint256) balance;

    constructor () {
        bankmanager = msg.sender;
    }

    modifier onlybankmanager() {
        require (msg.sender == bankmanager, "not the bank manager");
        _;
    }

    modifier onlyregisteredmember() {
        require(registeredmembers[msg.sender], "not a registered member");
        _;
    }

    function addmembers(address _member) public onlybankmanager {
        require (! registeredmembers [_member], "already registered");
        registeredmembers[_member] = true;
        members.push(_member);
    }

    function getmembers() public view returns (address[] memory) {
        return members;
    }

    function deposit(uint256 _amount) public onlyregisteredmember {
        balance[msg.sender] += _amount;
    }

    function depositamountether () public payable onlyregisteredmember {
        balance[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public onlyregisteredmember {
        require(balance[msg.sender] >= _amount, "insufficient balance");
        balance[msg.sender] -= _amount;
    }

}
