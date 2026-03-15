// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "./Day14_BaseDepositBox.sol";  // 导入母合约（抽象合约）

contract BasicDepositBox is BaseDepositBox{  // 继承BaseDepositBox
  constructor(address initialOwner) BaseDepositBox(initialOwner) {}  // 加构造函数传参给母合约
    // is: 继承，拿到母合约所有功能
    // 这是个具体合约，可以部署

    function getBoxType() external pure override returns(string memory){  // 返回盒子类型
        // external: 只能外部调用
        // pure: 不读也不写链上数据
        // override: 重写母合约/接口的函数
        // returns(string memory): 返回字符串
        return "Basic";  // 这个盒子是基础款
    }
    
    // 其他函数都从BaseDepositBox继承来了：
    // - getOwner()
    // - transferOwnership() 
    // - storeSecret()
    // - getSecret()
    // - getDepositTime()
}