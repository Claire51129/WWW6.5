//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./day14_BaseDepositBox.sol";

contract TimeLockedDepositBox is BaseDepositBox {

    uint256 private unlockTime;
    constructor(address initialOwner, uint256 lockDuration) BaseDepositBox(initialOwner) {
        unlockTime = block.timestamp + lockDuration;
    }

    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Deposit box is still locked");
        _;
    }

    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }

    function getSecret(address caller) public view override onlyOwner(caller) timeUnlocked returns (string memory) {
        return super.getSecret(caller);
    }

    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }

    function getTimeRemainingLockTime() external view returns (uint256) {
        if (block.timestamp >= unlockTime) {
            return 0;
        } else {
            return unlockTime - block.timestamp;
        }
    }

}