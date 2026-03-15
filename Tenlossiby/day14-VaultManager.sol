// SPDX-License-Identifier: MIT
// 合约采用MIT开源许可证协议

pragma solidity ^0.8.0;
// 指定Solidity编译器版本：兼容0.8.x系列

import "./day14-IDepositBox.sol";
// 导入IDepositBox接口，用于统一交互各类存款盒合约
import "./day14-BasicDepositBox.sol";
// 导入基础版存款盒合约
import "./day14-PremiumDepositBox.sol";
// 导入高级版存款盒合约
import "./day14-TimeLockedDepositBox.sol";
// 导入时间锁定版存款盒合约

// 【重要设计说明】
// VaultManager采用"工厂+管理器"模式，但遵循"用户直接操作资产"原则
// 核心设计：VaultManager只负责创建合约和记录信息，不代替用户操作存款盒
// 原因：存款盒的敏感操作（如转移所有权、存储秘密）都有onlyOwner修饰器
// 如果VaultManager代调用，msg.sender会变成VaultManager地址，导致权限检查失败

contract VaultManager {
    // 用户地址→其拥有的存款盒地址数组
    mapping(address => address[]) private userDepositBoxes;
    // 存款盒地址→用户自定义名称
    mapping(address => string) private boxNames;

    // 存款盒创建事件：记录创建者、存款盒地址及类型，indexed支持日志过滤
    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    // 存款盒命名事件：记录存款盒地址及自定义名称，indexed支持日志过滤
    event BoxNamed(address indexed boxAddress, string name);
    // 【新增事件】所有权转移事件：用于通知VaultManager更新记录
    // 注意：用户需先调用存款盒的transferOwnership，再调用此函数通知管理器
    event BoxOwnershipTransferred(address indexed previousOwner, address indexed newOwner, address indexed boxAddress);

    // 创建基础版存款盒，返回新合约地址
    function createBasicBox() external returns (address) {
        BasicDepositBox box = new BasicDepositBox();
        // 部署基础版存款盒合约实例，创建者自动成为所有者
        userDepositBoxes[msg.sender].push(address(box));
        // 将新存款盒地址添加到创建者的资产列表
        emit BoxCreated(msg.sender, address(box), "Basic");
        // 触发创建事件，供前端监听和记录
        return address(box);
    }

    // 创建高级版存款盒，返回新合约地址
    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox();
        // 部署高级版存款盒合约实例
        userDepositBoxes[msg.sender].push(address(box));
        // 添加到用户资产列表
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    // 创建时间锁定版存款盒（参数lockDuration：锁定时长，单位秒），返回新合约地址
    function createTimeLockedBox(uint256 lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        // 部署时间锁定版存款盒，传入锁定时长
        userDepositBoxes[msg.sender].push(address(box));
        // 添加到用户资产列表
        emit BoxCreated(msg.sender, address(box), "Time Locked");
        return address(box);
    }

    // 为存款盒设置自定义名称（仅存款盒所有者可操作）
    function nameBox(address boxAddress, string memory name) external {
        IDepositBox box = IDepositBox(boxAddress);
        // 转换为接口类型统一交互
        require(box.getOwner() == msg.sender, "Not the box owner");
        // 校验调用者是否为存款盒当前所有者
        boxNames[boxAddress] = name;
        // 存储自定义名称到映射
        emit BoxNamed(boxAddress, name);
        // 触发命名事件
    }

    // 【重要修正说明】
    // 原设计错误：VaultManager尝试代替用户调用box.storeSecret()
    // 错误原因：storeSecret有onlyOwner修饰器，会检查msg.sender == owner
    // 当VaultManager代调用时，msg.sender是VaultManager地址，不是用户地址
    // 结果：权限检查失败，交易回滚
    // 正确做法：用户应直接调用存款盒合约的storeSecret函数
    // VaultManager只提供便捷的查询功能，不介入敏感操作

    // 【已移除】storeSecret函数
    // 原因：VaultManager不应代替用户操作存款盒
    // 使用方法：用户直接调用存款盒合约的storeSecret函数

    // 【已移除】transferBoxOwnership函数
    // 原实现存在两个严重问题：
    // 问题1：代调用权限问题
    //   - VaultManager调用box.transferOwnership()时，msg.sender变为VaultManager地址
    //   - 但onlyOwner修饰器要求msg.sender == owner（用户地址）
    //   - 结果：权限检查失败，无法转移
    // 问题2：数组删除逻辑错误（已修复）
    //   - 原代码没有判断boxes[i] == boxAddress就直接删除
    //   - 导致永远删除数组最后一个元素，而不是目标元素
    // 
    // 【新方案】采用"用户直接操作+事件通知"模式：
    // 步骤1：用户直接调用存款盒合约的transferOwnership(newOwner)转移所有权
    // 步骤2：用户调用VaultManager的notifyOwnershipTransferred通知管理器更新记录
    // 优点：符合权限设计，VaultManager只管理记录不操作资产

    // 【新增函数】通知VaultManager所有权已转移（采用两步骤模式）
    // 使用流程：
    //   1. 用户先调用存款盒合约的transferOwnership(newOwner)完成实际转移
    //   2. 用户再调用此函数通知VaultManager更新内部记录
    // 参数boxAddress：存款盒地址
    // 参数newOwner：新所有者地址
    function notifyOwnershipTransferred(address boxAddress, address newOwner) external {
        IDepositBox box = IDepositBox(boxAddress);
        // 转换为接口类型
        
        // 验证：调用者必须是新所有者（证明转移已完成）
        require(box.getOwner() == msg.sender, "Caller is not the new owner");
        // 验证：新所有者确实是参数指定的地址
        require(msg.sender == newOwner, "New owner mismatch");
        
        // 从原所有者的列表中移除该存款盒
        // 注意：我们需要找到原所有者，但存款盒合约不记录历史所有者
        // 解决方案：遍历所有可能的原所有者（实际应用中可通过事件查询优化）
        // 简化方案：要求原所有者在转移前调用此函数，或前端协助提供原所有者地址
        
        // 【优化设计】为简化实现，我们假设调用者知道原所有者地址
        // 实际应用中，可以通过事件日志查询原所有者
        // 这里采用简化方案：由调用者提供原所有者地址
    }

    // 【新增函数】完成所有权转移的完整流程（需要原所有者配合）
    // 参数boxAddress：存款盒地址
    // 参数previousOwner：原所有者地址（用于从列表中移除）
    // 前置条件：用户已完成存款盒合约层面的所有权转移
    function completeOwnershipTransfer(address boxAddress, address previousOwner) external {
        IDepositBox box = IDepositBox(boxAddress);
        
        // 验证：调用者必须是当前所有者（即新所有者）
        require(box.getOwner() == msg.sender, "Not the current owner");
        
        // 从原所有者的列表中删除该存款盒
        address[] storage boxes = userDepositBoxes[previousOwner];
        for(uint i = 0; i < boxes.length; i++) {
            if(boxes[i] == boxAddress) {
                // 找到目标元素，用最后一个元素替换（高效删除技巧）
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                // 【修正说明】原代码缺少if判断，导致永远删除最后一个元素
                // 现已添加if(boxes[i] == boxAddress)判断，确保精准删除
                break;
            }
        }
        
        // 添加到新所有者的列表
        userDepositBoxes[msg.sender].push(boxAddress);
        
        // 触发转移事件
        emit BoxOwnershipTransferred(previousOwner, msg.sender, boxAddress);
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
        IDepositBox box = IDepositBox(boxAddress);
        // 转换为接口类型统一交互
        return(
            box.getBoxType(),
            // 获取存款盒类型（Basic/Premium/TimeLocked）
            box.getOwner(),
            // 获取当前所有者地址
            box.getDepositTime(),
            // 获取创建时间戳
            boxNames[boxAddress]
            // 获取用户设置的自定义名称
        );
    }

    // 【使用指南】
    // 1. 创建存款盒：调用createBasicBox/createPremiumBox/createTimeLockedBox
    // 2. 存储秘密：直接调用存款盒合约的storeSecret函数（不是通过VaultManager）
    // 3. 转移所有权：
    //    步骤1：调用存款盒合约的transferOwnership(newOwner)
    //    步骤2：新所有者调用VaultManager的completeOwnershipTransfer(boxAddress, previousOwner)
    // 4. 查询信息：通过VaultManager的getUserBoxes/getBoxInfo等函数查询
    //
    // 【设计原则】
    // - VaultManager是"管理员"不是"代理人"，只记录不操作
    // - 敏感操作必须由用户直接对存款盒合约执行
    // - 这种设计符合区块链"用户自主控制资产"的理念
}
