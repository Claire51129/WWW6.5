// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-BaseDepositBox.sol";
contract TimeLockedDepositBox is BaseDepositBox {
    uint256 private unlockTime; 
    //时间锁功能

    constructor(address initialOwner, uint256 lockDuration) BaseDepositBox(initialOwner) {
        unlockTime = block.timestamp + lockDuration;
    }

    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Box is still time-locked");
        _;
    }

    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }

    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
        return super.getSecret(); //基础合约中检索实际秘密
        //onlyOwner：只有金库所有者可以查看秘密。 timeUnlocked：只有在解锁时间过去后
    }

    function getUnlockTime() external view returns (uint256) {
        return unlockTime; //盒子解锁的确切时间戳
    }

    function getRemainingLockTime() external view returns (uint256) {
        if (block.timestamp >= unlockTime) return 0;
        return unlockTime - block.timestamp;
        //返回金库可打开所需的剩余秒数。
    }
}