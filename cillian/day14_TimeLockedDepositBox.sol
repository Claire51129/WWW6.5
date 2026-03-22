// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入抽象母合约
import "./day14_BaseDepositBox.sol";

/**
 * @dev TimeLockedDepositBox 是一个带有“时间锁”功能的子合约。
 * 即使是主人，在锁定期结束前也无法提取秘密。
 */
contract TimeLockedDepositBox is BaseDepositBox {
    // 子合约特有的私有变量：记录解锁的具体时间戳
    uint256 private unlockTime;

    /**
     * @notice 构造函数
     * @param lockDuration 锁定的持续时间（秒）
     * @dev 当部署此子合约时，会计算出未来的解锁时刻。
     */
    constructor(uint256 lockDuration) {
        unlockTime = block.timestamp + lockDuration;
    }

    // 函数修改器：校验当前时间是否已超过解锁时间。
    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Box is still time-locked");
        _;
    }

    /**
     * @notice 实现母接口规定的类型获取功能
     * @return 返回 "TimeLocked" 标识这是一个定时锁保险箱
     */
    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }

    /**
     * @notice 重写母类的读取秘密功能
     * @dev 关键点：
     * 1. 同时使用了母类的 onlyOwner 和本类的 timeUnlocked 修改器，实现双重权限检查。
     * 2. 使用了 super.getSecret()，意思是：先执行完我这边的检查，然后去调用“母类”里已经写好的那个 getSecret 逻辑。
     */
    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
        return super.getSecret();
    }

    /**
     * @notice 查看具体的解锁时间戳
     */
    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }

    /**
     * @notice 查看剩余的锁定时间（秒）
     * @return 如果已解锁返回 0，否则返回距离解锁还剩多少秒
     */
    function getRemainingLockTime() external view returns (uint256) {
        if (block.timestamp >= unlockTime) return 0;
        return unlockTime - block.timestamp;
    }

}