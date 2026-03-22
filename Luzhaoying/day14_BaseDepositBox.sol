// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//导入接口
import "./day14_IDepositBox.sol";

//基础型抽象合约:所有特定类型的存款箱——如基础型、高级型和时间锁型——都建立在这个合约之上
//关键字 abstract 表示这个合约不能直接部署。它是充当其他合约构建的模板或地基
abstract contract BaseDepositBox is IDepositBox {
    //这些变量都是 private，表示它们只能在内部访问。如果有人想读取它们，必须通过我们提供的公共getter 函数来查
    address private owner;
    string private secret;
    uint256 private depositTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the box owner");
        _;
    }
//金库在创建时自动设置所有权和时间跟踪
    constructor() {
        owner = msg.sender;
        depositTime = block.timestamp;
    }
//返回金库的当前所有者
    function getOwner() public view override returns (address) {
        return owner;
    }
//允许当前所有者将所有权移交给其他人
    function transferOwnership(address newOwner) external virtual  override onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
//所有者将字符串存储在金库中的方式
    function storeSecret(string calldata _secret) external virtual override onlyOwner {
        secret = _secret;
        emit SecretStored(msg.sender);
    }
//允许所有者检索存储的秘密
    function getSecret() public view virtual override onlyOwner returns (string memory) {
        return secret;
    }
//返回金库部署的时间
    function getDepositTime() external view virtual  override returns (uint256) {
        return depositTime;
    }
}
