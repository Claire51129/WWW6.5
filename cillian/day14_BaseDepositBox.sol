// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_IDepositBox.sol";

/**
 * @dev BaseDepositBox 是一个抽象母合约。
 * 它实现了 IDepositBox 母接口的基本功能, 没有把接口里规定的所有功能都写完整。
 * 它留下母合约中的getBoxType()未完成。
 * 标记为 abstract 是因为它是为了被其他合约继承而设计的，不能直接部署。
 */
abstract contract BaseDepositBox is IDepositBox {
    // 私有变量：仅限本母合约内部访问
    address private owner;        // 保险箱主人地址
    string private secret;        // 存储的秘密内容
    uint256 private depositTime;  // 初始存入/创建的时间戳

    // 事件：用于在区块链上记录重要动作，方便前端监听
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the box owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        depositTime = block.timestamp;
    }

    // override 表示实现了母接口 IDepositBox 中的同名函数
    function getOwner() public view override returns (address) {
        return owner;
    }

    // virtual 表示该函数允许在未来的子合约中被进一步重写（Override）
    function transferOwnership(address newOwner) external virtual override onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // 存储秘密
    function storeSecret(string calldata _secret) external virtual override onlyOwner {
        secret = _secret;
        emit SecretStored(msg.sender);
    }

    // 读取秘密内容
    function getSecret() public view virtual override onlyOwner returns (string memory) {
        return secret;
    }

    // 获取保险箱创建的时间
    function getDepositTime() external view virtual override returns (uint256) {
        return depositTime;
    }

}