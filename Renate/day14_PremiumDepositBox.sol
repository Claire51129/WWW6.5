// SPDX-License-Identifier: MIT
// 合约采用MIT开源许可证协议

pragma solidity ^0.8.0; 
// 指定Solidity编译器版本：兼容0.8.x系列
import "./day14_BaseDepositBox.sol";
// 导入BaseDepositBox抽象基合约，继承其核心存款盒功能

// 高级版存款盒合约（继承BaseDepositBox）
// 扩展功能：在基础版之上新增元数据存储/查询能力
contract PremiumDepositBox is BaseDepositBox {
    string private metadata; // 私有元数据（存储描述、标签等额外信息）

    // 元数据更新事件：记录操作所有者，indexed支持按地址过滤日志
    event MetadataUpdated(address indexed owner);

    // 获取存款盒类型（重写父合约函数，pure函数无状态读写）
    function getBoxType() override public pure returns(string memory) {
        return "Premium"; // 返回类型标识：高级版存款盒
    } 

    // 设置元数据（仅所有者可调用，calldata修饰参数节省Gas）
    function setMetadata(string calldata _metadata) external onlyOwner {
        metadata = _metadata; // 存储传入的元数据
        emit MetadataUpdated(msg.sender); // 触发元数据更新事件
    }

    // 获取元数据（仅所有者可调用，view函数仅读取状态）
    function getMetadata() external view onlyOwner returns(string memory) {
        return metadata;
    }
}