// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract simpleIou {
    address public owner;
    mapping (address => bool) public registeredFriends;
    address[] public friendList;
    mapping (address => uint256) public balances;

    mapping(address => mapping (address => uint256)) public debts;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require (msg.sender == owner, "not the owner");
        _;
    }

    modifier onlyregistered() {
        require(registeredFriends[msg.sender], "not registered");
        _;
    }

    function addFriend(address _friend) public onlyOwner {
        require (!registeredFriends[_friend], "already registered");
        friendList.push(_friend);
    }

    function depositIntoWallet() public payable onlyregistered {
        balances[msg.sender] += msg.value;
    }

    function recordDebet(address _debetor,uint256 _amount) public onlyregistered {
        debts[_debetor][msg.sender] += _amount;
    }

    function payFormWallet(address _creditor, uint256 _amount) public onlyregistered {
        require(balances[msg.sender] >= _amount, "insufficient balance");
        require(debts[msg.sender] [_creditor] >= _amount, "no debt to pay");

        balances[msg.sender] -= _amount;
        balances[_creditor] += _amount;
        debts[msg.sender][_creditor] -= _amount;
    }

    function transdferEther(address payable _to, uint256 _amount) public onlyregistered {
        require(balances[msg.sender] >= _amount, "insufficient balance");
        balances[msg.sender] -= _amount;
        _to.transfer(_amount);
    }

    function transdferEtherViaCall(address payable _to, uint256 _amount) public onlyregistered {
        require(balances[msg.sender] >= _amount,"insufficient balance");
        balances[msg.sender] -= _amount;

        (bool success,) = _to.call{value:_amount} ("");
        require(success,"transfer failed");
    }

    function withdraw(uint256 _amount) public onlyregistered {
        require (balances[msg.sender] >= _amount, "insufficient balance");
        balances[msg.sender] -= _amount;

        (bool success,) = payable (msg.sender).call{value: _amount} ("");
        require (success, "transfer failed");
    }
}
