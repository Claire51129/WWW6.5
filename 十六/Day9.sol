// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract BaseAccess {
    address public owner;

    error NotOwner();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function getContractType() public virtual view returns (string memory) {
        return "Base Access Control";
    }
}

contract SavingsVault is BaseAccess {
    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    error InsufficientBalance();

    function getContractType() public override pure returns (string memory) {
        return "Shiliu's Premium Savings Vault";
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] < _amount) revert InsufficientBalance();
        
        balances[msg.sender] -= _amount;
         (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");
    }
}
