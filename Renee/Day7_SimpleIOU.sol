// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleIOU {
    //State Variables
    address public owner;
    mapping ( address => bool ) public registeredFriends;
    address[] friendList;
    mapping ( address => uint256 ) public balances;
    //nested mapping: debts[debtor][creditor] = amount ————debtor owes creditor the amount of money
    mapping ( address => mapping ( address => uint256 ) ) public debts;

    constructor() {
        owner = msg.sender;
        //register the owner as a friend
        registeredFriends[owner] = true;
        friendList.push(owner);
    }      

    //modifiers: Controlling Access
      modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can perform this action.");
        _;
      }
      modifier onlyRegistered() {
        require(registeredFriends[msg.sender] == true, "You are not registered.");
        _;
      }

    //functions
    function addFriend(address _friend) public onlyOwner {
        require(_friend != address(0), "Invalid address. Friend address cannot be zero.");
        require(registeredFriends[_friend] == false, "Friend already registered.");

        friendList.push(_friend);
        registeredFriends[_friend] == true;
    }

    function depositIntoWallet() public payable onlyRegistered {
        require(msg.value > 0, "Must send ETH."); //msg.value & msg.sender are global variables.
        balances[msg.sender] += msg.value;
    }

    function recordDebt(address _debtor, uint256 _amount) public onlyRegistered {
    //when a friend owes the msd.sender money, call this function to record it.
        require(_debtor != address(0), "Invalid address.");
        require(registeredFriends[_debtor] == true, "Address not registered.");
        require(_amount > 0, "Amount must be greater than zero.");
        debts[_debtor][msg.sender] += _amount;
    }

    function payFromWallet(address _creditor, uint256 _amount) public onlyRegistered {
     //when the msg.sender needs to paid her creditor back, call this function to pay it.
        require(_creditor != address(0), "Invalid address.");
        require(registeredFriends[_creditor] == true, "Creditor not registered.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(debts[msg.sender][_creditor] >= _amount, "Debt amount incorrect.");
        require(balances[msg.sender] >= _amount, "Insufficient balance.");

        balances[msg.sender] -= _amount;
        balances[_creditor] += _amount;
        debts[msg.sender][_creditor] -= _amount;
    }

    function transferEther(address payable _to, uint256 _amount) public onlyRegistered {
    //send ETH using transfer(), a built-in Solidity method to directly send ETH to wallets address
        require(_to != address(0), "Invalid address.");
        require(registeredFriends[_to] == true, "Recipient not registered.");
        require(balances[msg.sender] >= _amount, "Insufficient balance.");

        balances[msg.sender] -= _amount;
        _to.transfer(_amount); // money is taken from the conract caller
        balances[_to] += _amount;
    }

    function transferEtherViaCall(address payable _to, uint256 _amount) public onlyRegistered {
    //send ETH using call(), a more flexible method can send ETH to a contract address
        require(_to != address(0), "Invalid address.");
        require(registeredFriends[_to] == true, "Recipient not registered.");
        require(balances[msg.sender] >= _amount, "Insufficient balance.");

        balances[msg.sender] -= _amount;

        (bool success, ) = _to.call{value: _amount}(""); //call() is a low-level function that gives you more control than transfer()
        balances[_to] += _amount;
        require(success, "Transfer failed.");
    }

    function withdraw(uint256 _amount) public onlyRegistered {
        require(balances[msg.sender] >= _amount, "Insufficient balance.");

        balances[msg.sender] -= _amount;

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdraw failed.");
    }

    function checkBalance() public view onlyRegistered returns(uint256) {
        return balances[msg.sender];
    }
}