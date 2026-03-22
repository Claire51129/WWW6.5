// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入抽象母合约
import "./day14_BaseDepositBox.sol";

/**
 * @dev PremiumDepositBox 是一个功能增强型的子合约。
 * 它不仅继承了 BaseDepositBox 的所有基础功能（存取秘密、所有权转让），
 * 还额外增加了自定义元数据（Metadata）的存储功能。
 */
contract PremiumDepositBox is BaseDepositBox {
    // 子合约特有的私有变量：用于存储额外的元数据（例如保险箱的描述、颜色或备注）
    string private metadata;

    // 子合约特有的事件：当元数据更新时在链上抛出，方便前端追踪
    event MetadataUpdated(address indexed owner);

    /**
     * @notice 实现母接口规定的类型获取功能
     * @return 返回 "Premium" 标识这是一个高级版保险箱
     */
    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }

    /**
     * @notice 设置保险箱的元数据
     * @param _metadata 新的描述信息
     * @dev 注意：这里直接使用了母类中定义的 onlyOwner 修改器。
     * 即使这个修改器没写在当前文件里，子类也能直接“继承”并使用它。
     */
    function setMetadata(string calldata _metadata) external onlyOwner {
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }

    /**
     * @notice 获取保险箱的元数据
     * @return 返回存储的元数据字符串
     * @dev 同样使用了继承自母类的 onlyOwner，确保只有主人能看备注。
     */
    function getMetadata() external view onlyOwner returns (string memory) {
        return metadata;
    }
    
}