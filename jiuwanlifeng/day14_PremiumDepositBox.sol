// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    导入 BaseDepositBox 抽象合约
*/
import "./day14_BaseDepositBox.sol";

/*
    PremiumDepositBox 合约

    这是一个“高级金库”类型。
    它继承 BaseDepositBox，因此自动拥有：

    - owner 所有权控制
    - secret 存储
    - depositTime 记录
    - transferOwnership 功能
    - onlyOwner 权限控制

    Premium 金库比 Basic 金库多了一个功能：
    可以存储 metadata（元数据）
*/
contract PremiumDepositBox is BaseDepositBox {

    // 存储额外的元数据信息
    string private metadata;

    /*
        当 metadata 更新时触发的事件
        indexed 可以方便前端查询日志
    */
    event MetadataUpdated(address indexed owner);

    /*
        返回金库类型

        pure 表示：
        不读取区块链状态
        不修改区块链状态

        override 表示：
        这是对接口函数的实现
    */
    function getBoxType() public pure override returns (string memory) {
        return "Premium";
    }

    /*
        设置 metadata

        calldata 用于外部函数参数
        onlyOwner 限制只有金库所有者可以修改
    */
    function setMetadata(string calldata _metadata) external onlyOwner {

        // 更新 metadata
        metadata = _metadata;

        // 触发事件
        emit MetadataUpdated(msg.sender);
    }

    /*
        获取 metadata

        view 表示只读取区块链数据
        onlyOwner 确保只有 owner 可以查看
    */
    function getMetadata() external view onlyOwner returns (string memory) {
        return metadata;
    }

}