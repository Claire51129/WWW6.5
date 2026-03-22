// SPDX-License-Identifier: MIT
// 合约采用MIT开源许可证协议

pragma solidity ^0.8.0; 
// 指定Solidity编译器版本：兼容0.8.x系列
import "./day14_IDepositBox.sol";
// 导入IDepositBox接口，本合约实现该接口定义的核心功能

// 抽象存款盒基础合约（继承IDepositBox接口）
// 抽象合约特性：不可直接部署，仅作为基类供其他合约继承
abstract contract BaseDepositBox is IDepositBox {
    address private owner;       // 合约所有者地址（私有，仅内部可访问）
    string private secret;       // 存储的私密信息（私有）
    uint256 private depositTime; // 存款/合约创建时间戳（私有）

    // 所有权转移事件：记录新旧所有者，indexed支持日志过滤
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    // 秘密存储事件：记录存储者地址，indexed支持日志过滤
    event SecretStored(address indexed owner);

    // 构造函数：初始化所有者和存款时间戳
    constructor() {
        owner = msg.sender;      // 部署者为初始所有者
        depositTime = block.timestamp; // 记录部署时的区块时间戳
    }

    // 权限修饰器：仅合约所有者可调用被修饰函数
    modifier onlyOwner() {
        require(owner == msg.sender, "Not the owner"); // 校验调用者为所有者
        _; // 执行被修饰函数的核心逻辑
    }

    // 获取合约所有者地址（实现接口，view函数仅读取状态）
    function getOwner() public view override returns (address) {
        return owner;
    }

    // 转移合约所有权（实现接口，仅所有者可调用，external仅外部可调用，virtual支持重写）
    function transferOwnership(address newOwner) external virtual override onlyOwner {
        require(newOwner != address(0), "Invalid Address"); // 校验新地址非零
        emit OwnershipTransferred(owner, newOwner); // 触发所有权转移事件
        owner = newOwner; // 更新所有者地址
    }

    // 存储私密信息（实现接口，仅所有者可调用，calldata节省Gas，virtual支持重写）
    function storeSecret(string calldata _secret) external virtual override onlyOwner {
        secret = _secret; // 存储传入的私密信息
        emit SecretStored(msg.sender); // 触发秘密存储事件
    }

    // 获取存储的私密信息（实现接口，仅所有者可调用，view函数仅读取状态，virtual支持重写）
    function getSecret() public view virtual override onlyOwner returns (string memory) {
        return secret;
    }

    // 获取存款/合约创建时间戳（实现接口，仅所有者可调用，view函数仅读取状态，virtual支持重写）
    function getDepositTime() external view virtual override onlyOwner returns (uint256) {
        return depositTime;
    }
}