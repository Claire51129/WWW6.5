// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 
import "./Day14_IDepositBox.sol";  // 导入接口，必须实现接口里的所有函数

abstract contract BaseDepositBox is IDepositBox {  // 抽象合约，继承IDepositBox接口
    // abstract: 抽象合约，可以有不实现的函数
    // is IDepositBox: 继承接口，必须实现或标记为virtual

    address private owner;  // 私有变量：盒子主人地址
    string private secret;  // 私有变量：存的秘密
    uint256 private depositTime;  // 私有变量：存秘密的时间

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);  // 事件：主人换了
    event SecretStored(address indexed owner);  // 事件：存了秘密

   constructor(address initialOwner){  // 加参数
    require(initialOwner != address(0), "Owner cannot be zero address");
    owner = initialOwner;  // 用传入的地址
    depositTime = block.timestamp;
}//已修改

    modifier onlyOwner(){  // 修饰符：只有主人能执行
        require(owner == msg.sender, "Not the owner");  // 检查调用者是不是主人
        _;  // 检查通过，继续执行原函数
    }

    function getOwner() public view override returns (address){  // 查看主人地址
        // override: 重写接口里的函数
        // view: 只读
        return owner;  // 返回主人地址
    }

    function transferOwnership(address newOwner) external virtual override onlyOwner{  // 转让所有权
        // external: 只能外部调用
        // virtual: 子合约可以重写
        // override: 重写接口里的函数
        // onlyOwner: 只有当前主人能调用
        require(newOwner != address(0), "Invalid Address");  // 新地址不能是0地址
        emit OwnershipTransferred(owner, newOwner);  // 发事件：主人换了
        owner = newOwner;  // 更新主人地址
    }

    function storeSecret(string calldata _secret) external virtual override onlyOwner{  // 存秘密
        // calldata: 只读输入参数
        secret = _secret;  // 把秘密存起来
        emit SecretStored(msg.sender);  // 发事件：存了秘密
    }

    function getSecret() public view virtual override onlyOwner returns (string memory){  // 取秘密
        // memory: 返回数据存在内存
        return secret;  // 返回存的秘密
    }

    function getDepositTime() external view virtual override onlyOwner returns (uint256) {  // 查看存秘密时间
        return depositTime;  // 返回时间戳
    }
}