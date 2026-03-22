// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// 管理员权限系统（银行的管理员规则——只有校长才能打开学校保险箱）
contract Ownable {
    address private owner;    // 保存管理员的钱包地址（设置他人不可见）

    // 事件广播：管理员换人
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {    //合约创建时自动运行
        owner = msg.sender;    //谁创建这个合约，谁就是管理员；msg.sender=当前操作的人
        emit OwnershipTransferred(address(0), msg.sender);    //广播：管理员从空地址→新管理员
    }


    modifier onlyOwner() {    // 权限控制：只有管理员才能进入
        require(msg.sender == owner, "Only owner can perform this action");    //检查是否是管理员，否则“交易失败”
        _;    // 继续执行函数
    }


    function ownerAddress() public view returns (address) {    // 查看管理员是谁
        return owner;
    }

    function transferOwnership(address _newOwner) public onlyOwner {    // 更换管理员
        require (_newOwner !=address(0), "Invalid address");    // 检查是否为空地址
        address previous = owner;    // 保存：旧管理员地址
        owner = _newOwner;    // 更新：管理员换人
        emit OwnershipTransferred(previous, _newOwner);    // 广播：管理员更换成功

    }
}



// 1 合约继承：VaultMaster → Ownable
// 2 权限控制：onlyOwner
// 3 ETH操作： payable, msg.value, call{caule:amount}