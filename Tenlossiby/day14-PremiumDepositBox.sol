//SPDX-License-Identifier: MIT
// SPDX许可证标识符，指定代码使用MIT开源许可证

pragma solidity ^0.8.0; 
// 指定Solidity编译器版本为0.8.0或更高

import "./day14-BaseDepositBox.sol";
// 导入BaseDepositBox抽象合约，本合约将继承其功能

contract PremiumDepositBox is BaseDepositBox{
// 定义PremiumDepositBox合约，继承自BaseDepositBox
// Premium（高级版）在基础版功能上增加了元数据存储功能

    string private metadata;
    // 私有变量：存储额外的元数据信息（如描述、标签等）
    // private表示只能在合约内部访问
    
    event MetadataUpdated(address indexed owner);
    // 元数据更新事件，当元数据被修改时触发
    // indexed表示可以按owner地址搜索事件

    function getBoxType() external pure override returns(string memory){
    // 获取存款盒类型函数，重写父合约的虚函数
    // override表示重写父合约中的函数
    // external表示只能从外部调用（与BasicDepositBox、TimeLockedDepositBox保持一致）
    // 【修正说明】之前使用public，现改为external以统一风格
    // pure表示不读取也不修改状态
        return "Premium";
        // 返回"Premium"表示这是高级版存款盒
    } 

    function setMetadata(string calldata _metadata) external onlyOwner{
    // 设置元数据函数，只有所有者可以调用
    // external表示只能从外部调用
    // calldata表示数据存储在调用数据中，节省gas
    // onlyOwner修饰器确保只有合约所有者可以执行
        metadata = _metadata;
        // 将传入的元数据存储到状态变量
        emit MetadataUpdated(msg.sender);
        // 触发元数据更新事件，记录操作
    }

    function getMetadata() external view onlyOwner returns(string memory){
    // 获取元数据函数，只有所有者可以查看
    // external表示只能从外部调用
    // view表示不修改状态，只读取数据
    // onlyOwner修饰器限制访问权限
        return metadata;
        // 返回存储的元数据
    }


}
