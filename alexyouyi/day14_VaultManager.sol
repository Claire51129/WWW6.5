//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_BasicDepositBox.sol";
import "./day14_IDepositBox.sol";
import "./day14_PremiumDepositBox.sol";
import "./day14_TimeLockedDepositBox.sol";

contract VaultManager{
    mapping(address => address[]) private userDepositBoxes;
    mapping(address => string) private boxNames;

    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    event BoxNamed(address indexed boxAddress, string name);

    function createBasicBox() external returns (address){
        BasicDepositBox newBox = new BasicDepositBox(msg.sender);
        userDepositBoxes[msg.sender].push(address(newBox));
        emit BoxCreated(msg.sender, address(newBox), "Basic");
        return address(newBox);
    }

    function createPremiumBox() external returns (address){
        PremiumDepositBox newBox = new PremiumDepositBox(msg.sender);
        userDepositBoxes[msg.sender].push(address(newBox));
        emit BoxCreated(msg.sender, address(newBox), "Premium");
        return address(newBox);
    }
    
    function createTimeLockedBox(uint256 lockDuration) external returns (address){
        TimeLockedDepositBox newBox = new TimeLockedDepositBox(msg.sender, lockDuration);
        userDepositBoxes[msg.sender].push(address(newBox));
        emit BoxCreated(msg.sender, address(newBox), "TimeLocked");
        return address(newBox);
    }

    function nameBox(address boxAddress, string memory name) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Only the owner can name the box");
        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }

    function storeSecret(address boxAddress, string calldata secret) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Only the owner can store a secret");
        box.storeSecret(secret, msg.sender);
    }

    function transferBoxOwnership(address boxAddress, address newOwner) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Only the owner can transfer ownership");
        box.transferOwnership(newOwner, msg.sender);
        address[] storage boxes = userDepositBoxes[msg.sender];
        for(uint256 i = 0; i < boxes.length; i++) {
            if (boxes[i] == boxAddress) {
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        }
        userDepositBoxes[newOwner].push(boxAddress);
    }

    function getUserBoxes(address user) external view returns (address[] memory) {
        return userDepositBoxes[user];
    }

    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    function getBoxInfo(address boxAddress) external view returns (
        string memory boxType, 
        string memory name, 
        uint256 depositTime,
        address owner
        ) {
        IDepositBox box = IDepositBox(boxAddress);
        return (
            box.getBoxType(),
            boxNames[boxAddress],
            box.getDepositTime(),
            box.getOwner()
        );
    }
}