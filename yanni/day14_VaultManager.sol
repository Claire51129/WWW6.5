// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day14_IDepositBox.sol";
import "./day14_BasicDepositBox.sol";
import "./day14_PremiumDepositBox.sol";
import "./day14_TimeLockedDepositBox.sol";

contract VaultManager {
    // 用户拥有的箱子列表
    mapping(address => address[]) private userDepositBoxes;

    // 箱子名字
    mapping(address => string) private boxNames;

    // 保存箱子在数组中的索引，用于 O(1) 删除
    mapping(address => mapping(address => uint256)) private boxIndex;

    // Events
    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    event BoxNamed(address indexed boxAddress, string name);
    event BoxOwnershipTransferred(address indexed oldOwner, address indexed newOwner, address indexed boxAddress);

    // 创建 Basic 箱子
    function createBasicBox() external returns (address) {
        BasicDepositBox box = new BasicDepositBox();
        _addBox(msg.sender, address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    // 创建 Premium 箱子
    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox();
        _addBox(msg.sender, address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    // 创建 TimeLocked 箱子
    function createTimeLockedBox(uint256 lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        _addBox(msg.sender, address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }

    // 内部函数，添加箱子到用户列表，并记录索引
    function _addBox(address owner, address boxAddr) internal {
        require(owner != address(0) && boxAddr != address(0), "Invalid address");
        boxIndex[owner][boxAddr] = userDepositBoxes[owner].length;
        userDepositBoxes[owner].push(boxAddr);
    }

    // 给箱子命名
    function nameBox(address boxAddress, string calldata name) external {
        require(boxAddress != address(0), "Invalid box address");
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }

    // 存储机密信息
    function storeSecret(address boxAddress, string calldata secret) external {
        require(boxAddress != address(0), "Invalid box address");
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.storeSecret(secret);
    }

    // 转让箱子所有权，O(1) 删除旧所有者
    function transferBoxOwnership(address boxAddress, address newOwner) external {
        require(boxAddress != address(0) && newOwner != address(0), "Invalid address");

        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        // 更新箱子合约所有权
        box.transferOwnership(newOwner);

        // 从旧所有者数组 O(1) 删除
        _removeBox(msg.sender, boxAddress);

        // 添加到新所有者数组
        _addBox(newOwner, boxAddress);

        emit BoxOwnershipTransferred(msg.sender, newOwner, boxAddress);
    }

    // 内部函数 O(1) 删除箱子
    function _removeBox(address owner, address boxAddr) internal {
        uint256 index = boxIndex[owner][boxAddr];
        uint256 lastIndex = userDepositBoxes[owner].length - 1;

        if (index != lastIndex) {
            address lastBox = userDepositBoxes[owner][lastIndex];
            userDepositBoxes[owner][index] = lastBox;
            boxIndex[owner][lastBox] = index;
        }

        userDepositBoxes[owner].pop();
        delete boxIndex[owner][boxAddr];
    }

    // 获取用户拥有的箱子
    function getUserBoxes(address user) external view returns (address[] memory) {
        return userDepositBoxes[user];
    }

    // 获取箱子名字
    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    // 获取箱子详细信息
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