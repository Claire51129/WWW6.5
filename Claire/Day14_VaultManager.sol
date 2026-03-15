// SPDX-License-Identifier: MIT
//VaultManager.sol
pragma solidity ^0.8.0;

// 导入所有类型的存款箱合约
import "./Day14_IDepositBox.sol";               // 接口
import "./Day14_BasicDepositBox.sol";            // 基础款
import "./Day14_PremiumDepositBox.sol";           // 高级款
import "./Day14_TimeLockedDepositBox.sol";        // 时间锁款

contract VaultManager{  // 保险箱管理器合约

    // 状态变量
    mapping(address => address[]) private userDepositBoxes;  // 每个用户拥有的盒子地址列表
    mapping(address => string)private boxNames;              // 每个盒子的自定义名称

    // 事件
    event BoxCreated(address indexed owner, address indexed boxAdress, string boxType);  // 盒子创建
    event BoxNamed(address indexed boxAdress, string name);  // 盒子命名

    // 创建基础款盒子
    function createBasicBox() external returns (address){
        BasicDepositBox box = new BasicDepositBox(msg.sender);  // 部署新盒子
        userDepositBoxes[msg.sender].push(address(box));  // 记录到用户列表
        emit BoxCreated(msg.sender, address(box), "Basic");  // 发事件
        return address(box);  // 返回盒子地址
    }

    // 创建高级款盒子
    function createPremiumBox() external returns (address){
        PremiumDepositBox box = new PremiumDepositBox(msg.sender);  // 部署新盒子
        userDepositBoxes[msg.sender].push(address(box));  // 记录
        emit BoxCreated(msg.sender, address(box), "Premium");  // 发事件
        return address(box);
    }

    // 创建时间锁盒子（需要锁定时长）
    function createTimeLockedBox(uint256 lockDuration) external returns (address){
        TimeLockedDepositBox box = new TimeLockedDepositBox(msg.sender,lockDuration);  // 部署带参数的盒子
        userDepositBoxes[msg.sender].push(address(box));  // 记录
        emit BoxCreated(msg.sender, address(box), "Time Locked");  // 发事件
        return address(box);
    }

    // 给盒子起名字
    function nameBox(address boxAddress, string memory name ) external{
        IDepositBox box = IDepositBox(boxAddress);  // 把地址转成接口类型
        require(box.getOwner() == msg.sender, "Not the box owner");  // 必须是盒子主人
        boxNames[boxAddress] = name;  // 存名字
        emit BoxNamed(boxAddress, name);  // 发事件
    }

    // 存秘密到指定盒子
    function storeSecret(address boxAddress, string calldata secret) external{
        IDepositBox box = IDepositBox(boxAddress);  // 转成接口
        require(box.getOwner() == msg.sender, "Not the box owner");  // 必须是主人
        box.storeSecret(secret);  // 调用盒子的存秘密函数
    }

    // 转移盒子所有权
    function transferBoxOwnership(address boxAddress, address newOwner)  external{
        IDepositBox box = IDepositBox(boxAddress);  // 转成接口
        require(box.getOwner() == msg.sender, "Not the box owner");  // 必须是原主人
        
        box.transferOwnership(newOwner);  // 调用盒子的转移所有权函数
        
        // 从原主人的列表中移除这个盒子
        address[] storage boxes = userDepositBoxes[msg.sender];  // 原主人的盒子列表
        for(uint i = 0; i < boxes.length; i++){
            if(boxes[i] == boxAddress){  // 找到要转移的盒子
                boxes[i] = boxes[boxes.length - 1];  // 用最后一个覆盖当前位置
                boxes.pop();  // 删除最后一个
                break;  // 停止循环
            }
        }
        
        userDepositBoxes[newOwner].push(boxAddress);  // 添加到新主人的列表
    }

    // 查看用户拥有的所有盒子
    function getUserBoxes(address user) external view returns(address[] memory){
        return userDepositBoxes[user];  // 返回盒子地址列表
    }

    // 查看盒子的自定义名称
    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];  // 返回名称
    }

    // 查看盒子的完整信息
    function getBoxInfo(address boxAddress)external view returns(
        string memory boxType,      // 盒子类型
        address owner,              // 主人地址
        uint256 depositTime,        // 存秘密时间
        string memory name          // 自定义名称
    ){
        IDepositBox box = IDepositBox(boxAddress);  // 转成接口
        return(
            box.getBoxType(),        // 调用盒子获取类型
            box.getOwner(),          // 调用盒子获取主人
            box.getDepositTime(),    // 调用盒子获取存秘密时间
            boxNames[boxAddress]     // 从管理器获取自定义名称
        );
    }
}