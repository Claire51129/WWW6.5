// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    导入 BaseDepositBox 抽象合约
*/
import "./day14_BaseDepositBox.sol";

/*
    TimeLockedDepositBox

    这是一个带时间锁的金库。

    功能：
    - 可以存储 secret
    - 只有 owner 可以访问
    - 在 unlockTime 之前无法读取 secret

    继承 BaseDepositBox，因此自动获得：

    - owner 管理
    - secret 存储
    - depositTime 记录
    - onlyOwner 权限控制
*/
contract TimeLockedDepositBox is BaseDepositBox {

    // 解锁时间（Unix 时间戳）
    uint256 private unlockTime;

    /*
        构造函数

        参数：
        lockDuration = 锁定持续时间（秒）

        unlockTime = 当前时间 + 锁定时间
    */
    constructor(uint256 lockDuration){
        unlockTime = block.timestamp + lockDuration;
    }

    /*
        修饰符：timeUnlocked

        只有在时间锁结束后才允许执行函数
    */
    modifier timeUnlocked(){
        require(block.timestamp >= unlockTime, "Box is still locked");
        _;
    }

    /*
        返回金库类型
    */
    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }

    /*
        获取 secret

        条件：
        - 必须是 owner
        - 必须已经解锁
    */
    function getSecret()
        public
        view
        override
        onlyOwner
        timeUnlocked
        returns (string memory)
    {
        // 调用父合约 BaseDepositBox 的 getSecret()
        return super.getSecret();
    }

    /*
        返回解锁时间
    */
    function getUnlockTime() external view returns(uint256){
        return unlockTime;
    }

    /*
        返回剩余锁定时间

        如果已经解锁返回 0
    */
    function getRemainingLockTime() external view returns(uint256){

        if(block.timestamp >= unlockTime) {
            return 0;
        }

        return unlockTime - block.timestamp;
    }

}