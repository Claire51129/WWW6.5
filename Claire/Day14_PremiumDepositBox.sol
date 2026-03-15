// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "./Day14_BaseDepositBox.sol";  // 导入母合约（抽象合约）

contract PremiumDepositBox is BaseDepositBox{  
    constructor(address initialOwner) BaseDepositBox(initialOwner) {}  // 加构造函数传参给母合约
    // 继承母合约，高级存款箱
    // is: 继承，拿到母合约所有功能

    string private metadata;  // 私有变量：额外的元数据（比如描述、链接等）
    event MetadataUpdated(address indexed owner);  // 事件：元数据更新了

    function getBoxType() override public pure returns(string memory){  // 返回盒子类型
        // override: 重写母合约/接口的函数
        // pure: 不读不写链上数据
        return "Premium";  // 这个盒子是高级款
    } 

    function setMetadata(string calldata _metadata) external onlyOwner{  // 设置元数据
        // calldata: 只读输入参数
        // onlyOwner: 只有主人能调用（来自母合约的修饰符）
        metadata = _metadata;  // 存元数据
        emit MetadataUpdated(msg.sender);  // 发事件：元数据更新了
    }

    function getMetadata() external view onlyOwner returns(string memory){  // 查看元数据
        // view: 只读
        // onlyOwner: 只有主人能看
        return metadata;  // 返回存的元数据
    }
}