//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { SubscriptionStorageLayout } from "./day17_SubscriptionStorageLayout.sol";
//this one is the proxy contract, it will delegate calls to the logic contract and store the state variables

contract SubscriptionStorage is SubscriptionStorageLayout {
  modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;
  }

  constructor(address _logicContract) {
    owner = msg.sender;
    logicContract = _logicContract;
  }

  function upgradeTo(address _newLogicContract) external onlyOwner {
    logicContract = _newLogicContract;
  }

  //triggered when a function is called that doesn't exist in the proxy contract
  fallback() external payable {
    address impl = logicContract;
    require(impl != address(0), "Logic contract not set"); //check if the logic contract is set
    assembly {
      calldatacopy(0, 0, calldatasize()) //copy the calldata to memory
      let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0) //delegatecall to the logic contract
      returndatacopy(0, 0, returndatasize()) //copy the returndata from the logic contract to memory
      switch result
      case 0 { revert(0, returndatasize()) } //if the delegatecall failed, revert with the returndata from the logic contract
      default { return(0, returndatasize()) } //otherwise, return the returndata from the logic contract
    }
  }
  receive() external payable {} //accept ether
}