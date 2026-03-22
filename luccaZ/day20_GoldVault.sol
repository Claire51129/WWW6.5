//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GoldVault {
  mapping(address => uint256) public goldBalance;

  //reentrancy lock setup
  uint256 private _status; //store lock status(1 = not entered, 2 = entered)
  uint256 private constant _NOT_ENTERED = 1; //constant means value cannot be changed after deployment
  uint256 private constant _ENTERED = 2;

  constructor() {
    _status = _NOT_ENTERED;
  }

  //custom non reentrant modifier
  modifier nonReentrant() {
    require(_status != _ENTERED, "Reentrant call detected"); //already entered, prevent reentrancy
    _status = _ENTERED; //set lock before function execution
    _;
    _status = _NOT_ENTERED; //reset lock after function execution
  }

  function deposit() external payable {
    require(msg.value > 0, "Deposit must be more than 0");
    goldBalance[msg.sender] += msg.value; //update user's gold balance
  }

  function vulnerableWithdraw() external {
    uint256 amount = goldBalance[msg.sender];
    require(amount > 0, "No gold to withdraw");
    (bool sent, ) = msg.sender.call{value: amount}(""); //send gold to user
    require(sent, "ETH transfer failed");

    goldBalance[msg.sender] = 0; 
  }

  function safeWithdraw() external nonReentrant {
    uint256 amount = goldBalance[msg.sender];
    require(amount > 0, "No gold to withdraw");
    goldBalance[msg.sender] = 0; //update balance before sending to prevent reentrancy
    (bool sent, ) = msg.sender.call{value: amount}(""); //send gold to user
    require(sent, "ETH transfer failed");
  }
}