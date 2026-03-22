// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Day14_IDepositBox.sol";
import "./Day14_BasicDepositBox.sol";
import "./Day14_PremiumDepositBox.sol";
import "./Day14_TimeLockedDepositBox.sol";

contract VaultManager {
    mapping(address => address[]) private userDepositBoxes;
    mapping(address => string) private boxNames;

    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    event BoxNamed(address indexed boxAddress, string name);

    modifier onlyBoxOwner(address boxAddress) {
       bool owned = false;
        for (uint i = 0; i < userDepositBoxes[msg.sender].length; i++) {
            if (userDepositBoxes[msg.sender][i] == boxAddress) {
                owned = true;
                break;
            }
        }
        require(owned, "Box not owned by sender");
        _;
    }

    function createBasicBox() external returns (address) {
        BasicDepositBox box = new BasicDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    function createTimeLockedBox(uint256 lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }

    function nameBox(address boxAddress, string calldata name) external onlyBoxOwner(boxAddress) {
        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }

    function storeSecret(address boxAddress, string calldata secret) external onlyBoxOwner(boxAddress) {
        IDepositBox box = IDepositBox(boxAddress);
        box.storeSecret(secret);
    }

    function transferBoxOwnership(address boxAddress, address newOwner) external onlyBoxOwner(boxAddress){
        IDepositBox box = IDepositBox(boxAddress);
        box.transferOwnership(newOwner);

        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; i < boxes.length; i++) {
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
        address owner,
        uint256 depositTime,
        string memory name
    ) {
        IDepositBox box = IDepositBox(boxAddress);
        return (
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxNames[boxAddress]
        );
    }
}
