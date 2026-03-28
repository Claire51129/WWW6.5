// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Masterkey {
    // 1. 状态变量：记录谁是超级管理员
    address public admin;
    bool public isLocked; // 合约锁定状态
    string public secretData; // 受保护的数据

    // 2. 构造函数：部署时初始化管理员
    constructor() {
        admin = msg.sender;
        isLocked = false;
    }

    // 3. 自定义修饰器 (Modifier)：这就是“门卫”
    // 它会先检查条件，满足了才让代码继续执行
    modifier onlyAdmin() {
        require(msg.sender == admin, "You are not the admin!");
        _; // 这个下划线代表“执行被修饰函数剩下的代码”
    }

    // 另一个修饰器：检查合约是否处于锁定状态
    modifier whenNotLocked() {
        require(!isLocked, "The contract is currently locked.");
        _;
    }

    // 4. 管理员功能：更改管理员（转让钥匙）
    function transferOwnership(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "New admin cannot be zero address");
        admin = _newAdmin;
    }

    // 5. 管理员功能：一键锁定/解锁合约
    function toggleLock() public onlyAdmin {
        isLocked = !isLocked;
    }

    // 6. 受保护的功能：只有管理员在未锁定状态下才能修改数据
    function updateSecretData(string memory _newData) public onlyAdmin whenNotLocked {
        secretData = _newData;
    }
}
