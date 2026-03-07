//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherPiggyBank {
    //there should be a bank manager who has the certain permissions
    //there should be an array for all members registered and a mapping whther they are registered or not
    //a mapping with there balances
    address public bankManager;
    address[] members;
    mapping(address => bool) public registeredMembers;
    mapping(address => uint256) balance;
    //add limits to withdraw amount
    mapping(address => uint256) maxWithdrawAmount;
    //add approval system, small amount -> withdraw, large amount -> need apporoval
    struct WithdrawalRequest {
      uint256 amount;
      bool exists;
    }
    mapping(address => WithdrawalRequest) public pendingWithdrawals;
    uint256 public directWithdrawLimit = 0.1 ether;

    constructor(){
        bankManager = msg.sender;
        members.push(msg.sender);
        registeredMembers[msg.sender] = true;
    }

    modifier onlyBankManager(){
        require(msg.sender == bankManager, "Only bank manager can perform this action.");
        _;
    }

    modifier onlyRegisteredMember(){
        require(registeredMembers[msg.sender], "Member not registerd.");
        _;
    }

    function addMembers(address _member) public onlyBankManager {
      require(_member != address(0), "Invalid address!");
      require(_member != msg.sender, "Bank Manager is already a member.");
      require(!registeredMembers[_member], "Member already registered.");
      registeredMembers[_member] = true;
      members.push(_member);
    }

    function getMembers() public view returns(address[] memory) {
      return members;
    }

    //deposit amount 
    // function depositAmount(uint256 _amount) public onlyRegisteredMember{
    //     require(_amount > 0, "Invalid amount");
    //     balance[msg.sender] = balance[msg.sender]+_amount;
   
    // }

    //deposit in Ether
    //payable means this function is allowed to receive Ether
    function depositeAmountEther() public payable onlyRegisteredMember {
      require(msg.value > 0, "Invalid amount.");
      balance[msg.sender] = balance[msg.sender] + msg.value;
    }

    //simulate amount
    //function withdrawAmount(uint256 _amount) public onlyRegisteredMember {
    //  require(_amount > 0, "Invalid amount.");
    //  require(balance[msg.sender] >= _amount, "Insufficient balance.");
    //  balance[msg.sender] = balance[msg.sender] - _amount;
    //}

  function withdrawAmountEther(uint256 _amount) public onlyRegisteredMember {
    require(_amount > 0, "Invalid amount.");
    require(balance[msg.sender] >= _amount, "Insufficient balance.");

    // If amount is larger than direct limit → must request approval
    require(_amount <= directWithdrawLimit, "Amount requires manager approval.");

    // Also enforce per‑member max limit
    require(_amount <= maxWithdrawAmount[msg.sender], "Exceeds withdrawal limit.");

    balance[msg.sender] -= _amount;

    (bool success, ) = payable(msg.sender).call{value: _amount}("");
    require(success, "Ether transfer failed.");
  }

//add request withdrawal function for user who withdraw large amount
  function requestWithdrawal(uint256 _amount) public onlyRegisteredMember {
    require(_amount > 0, "Invalid amount.");
    require(balance[msg.sender] >= _amount, "Insufficient balance.");
    require(_amount > directWithdrawLimit, "Use direct withdrawal for small amounts.");
    require(_amount <= maxWithdrawAmount[msg.sender], "Exceeds withdrawal limit.");
    require(!pendingWithdrawals[msg.sender].exists, "Pending request exists.");

    pendingWithdrawals[msg.sender] = WithdrawalRequest({
      amount: _amount,
      exists: true
    });
  }

//add apprive withdrawal function for bank manager
  function approveWithdrawal(address _member) public onlyBankManager {
    require(pendingWithdrawals[_member].exists, "No pending request.");
    uint256 amount = pendingWithdrawals[_member].amount;

    balance[_member] -= amount;
    delete pendingWithdrawals[_member];

    (bool success, ) = payable(_member).call{value: amount}("");
    require(success, "Ether transfer failed.");
  }


  function getBalance(address _member) public view returns (uint256) {
    require(_member != address(0), "Invalid address.");
    return balance[_member];
  }

  function setLimit(address _member, uint256 _amount) public onlyBankManager {
    require(_amount > 0, "Invalid amount.");
    require(_member != address(0), "Invalid address.");
    require(registeredMembers[_member], "Not registered member.");
    maxWithdrawAmount[_member] = _amount;
  }
}