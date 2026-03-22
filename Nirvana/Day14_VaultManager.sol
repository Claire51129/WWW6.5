// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day14_IDepositBox.sol";
import "./Day14_BasicDepositBox.sol";
import "./Day14_PremiumDepositBox.sol";
import "./Day14_TimeLockedDepositBox.sol";

contract VaultManager {
    
    mapping(address => address[]) private userDepositBoxes;
    mapping(address => string) private boxNames;

    event BoxCreated(address indexed owner, address indexed boxAdress, string boxType);
    event BoxNamed(address indexed boxAdress, string name);

    function createBasicBox() external returns (address) {
        Day14_BasicDepositBox box= new Day14_BasicDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    function createPremiumBox() external returns(address) {
        Day14_PremiumDepositBox box = new Day14_PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    function createTimeLockedBox(uint256 lockDuration) external returns(address) {
        Day14_TimeLockedDepositBox box = new Day14_TimeLockedDepositBox(lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender,address(box),"Time Locked");
        return address(box);
    }

    function nameBox(address boxAddress, string memory name) external{
        Day14_IDepositBox box = Day14_IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }

    function storeSecret(address boxAddress, string calldata secret) external {
        Day14_IDepositBox box = Day14_IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender,"Not the box owner");
        box.storeSecret(secret);
    }

    function transferBoxOwnership(address boxAddress, address newOwner) external {
        Day14_IDepositBox box = Day14_IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        box.transferOwnership(newOwner);
        
        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; 1 < boxes.length; i++ ){
             boxes[i] = boxes[boxes.length -1];
             boxes.pop();
             break;
        }
        userDepositBoxes[msg.sender].push(boxAddress);
    }

    function getUserBoxes(address user) external view returns(address[] memory) {
        return userDepositBoxes[user];
    }

    function getBoxName(address boxAddress) external view returns(string memory) {
        return boxNames[boxAddress];
    }

    function getBoxInfo(address boxAddress) external view returns (
    string memory boxType,
    address owner,
    uint256 depositTime,
    string memory name
)  {
    Day14_IDepositBox box = Day14_IDepositBox(boxAddress);
    return (
        box.getBoxType(),
        box.getOwner(),
        box.getDepositTime(),
        boxNames[boxAddress]
    );
    }


}