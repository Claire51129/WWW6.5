// SPDX-License-Identifier: MIT
// 合约采用MIT开源许可证协议

pragma solidity ^0.8.0;
// 指定Solidity编译器版本：兼容0.8.x系列

import "./day14_IDepositBox.sol";
// 导入IDepositBox接口，用于统一交互各类存款盒合约
import "./day14_BasicDepositBox.sol";
// 导入基础版存款盒合约
import "./day14_PremiumDepositBox.sol";
// 导入高级版存款盒合约
import "./day14_TimeLockedDepositBox.sol";
// 导入时间锁定版存款盒合约

// 存款盒管理器合约（工厂+管理模式）
// 核心功能：创建各类存款盒、管理用户存款盒资产、维护存款盒元信息
contract VaultManager {
    // 用户地址→其拥有的存款盒地址数组
    mapping(address => address[]) private userDepositBoxes;
    // 存款盒地址→用户自定义名称
    mapping(address => string) private boxNames;

    // 存款盒创建事件：记录创建者、存款盒地址及类型，indexed支持日志过滤
    event BoxCreated(address indexed owner, address indexed boxAdress, string boxType);
    // 存款盒命名事件：记录存款盒地址及自定义名称，indexed支持日志过滤
    event BoxNamed(address indexed boxAdress, string name);

    // 创建基础版存款盒，返回新合约地址
    function createBasicBox() external returns (address) {
        BasicDepositBox box = new BasicDepositBox(); // 部署基础版存款盒合约实例
        userDepositBoxes[msg.sender].push(address(box)); // 新增至用户存款盒列表
        emit BoxCreated(msg.sender, address(box), "Basic"); // 触发创建事件
        return address(box);
    }

    // 创建高级版存款盒，返回新合约地址
    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox(); // 部署高级版存款盒合约实例
        userDepositBoxes[msg.sender].push(address(box)); // 新增至用户存款盒列表
        emit BoxCreated(msg.sender, address(box), "Premium"); // 触发创建事件
        return address(box);
    }

    // 创建时间锁定版存款盒（参数lockDuration：锁定时长，单位秒），返回新合约地址
    function createTimeLockedBox(uint256 lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration); // 部署时间锁定版存款盒
        userDepositBoxes[msg.sender].push(address(box)); // 新增至用户存款盒列表
        emit BoxCreated(msg.sender, address(box), "Time Locked"); // 触发创建事件
        return address(box);
    }

    // 为存款盒设置自定义名称（仅存款盒所有者可操作）
    function nameBox(address boxAddress, string memory name) external {
        IDepositBox box = IDepositBox(boxAddress); // 转换为接口类型统一交互
        require(box.getOwner() == msg.sender, "Not the box owner"); // 校验存款盒所有权
        boxNames[boxAddress] = name; // 存储自定义名称
        emit BoxNamed(boxAddress, name); // 触发命名事件
    }

    // 向指定存款盒存储私密信息（仅存款盒所有者可操作）
    function storeSecret(address boxAddress, string calldata secret) external {
        IDepositBox box = IDepositBox(boxAddress); // 转换为接口类型统一交互
        require(box.getOwner() == msg.sender, "Not the box owner"); // 校验存款盒所有权
        box.storeSecret(secret); // 调用存款盒接口存储秘密
    }

    // 转移存款盒所有权（仅当前所有者可操作）
    function transferBoxOwnership(address boxAddress, address newOwner) external {
        IDepositBox box = IDepositBox(boxAddress); // 转换为接口类型统一交互
        require(box.getOwner() == msg.sender, "Not the box owner"); // 校验存款盒所有权
        
        box.transferOwnership(newOwner); // 调用存款盒接口转移所有权
        
        // 修复：精准找到并删除原所有者列表中的目标存款盒地址
        address[] storage boxes = userDepositBoxes[msg.sender];
        for(uint i = 0; i < boxes.length; i++){
            // 先匹配目标存款盒地址，再执行删除逻辑
            if(boxes[i] == boxAddress){
                boxes[i] = boxes[boxes.length - 1]; // 替换目标元素为最后一个元素
                boxes.pop(); // 删除最后一个重复元素（高效删除数组元素）
                break; // 找到并删除后退出循环（此时i++已执行，无不可达警告）
            }
        }
        userDepositBoxes[newOwner].push(boxAddress); // 新增至新所有者列表
    }

    // 获取指定用户的所有存款盒地址（view函数仅读取状态）
    function getUserBoxes(address user) external view returns(address[] memory) {
        return userDepositBoxes[user];
    }

    // 获取存款盒的自定义名称（view函数仅读取状态）
    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    // 获取存款盒完整信息：类型、所有者、创建时间、自定义名称
    function getBoxInfo(address boxAddress) external view returns(
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ) {
        IDepositBox box = IDepositBox(boxAddress); // 转换为接口类型统一交互
        return(
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxNames[boxAddress]
        );
    }
}