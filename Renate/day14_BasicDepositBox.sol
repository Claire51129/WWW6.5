// SPDX-License-Identifier: MIT
// 合约采用MIT开源许可证协议

pragma solidity ^0.8.0; 
// 指定Solidity编译器版本：兼容0.8.x系列
import "./day14_BaseDepositBox.sol";
// 导入BaseDepositBox抽象基合约，继承其核心功能

// 基础存款盒合约（继承BaseDepositBox）
// 可直接部署的具体合约（非抽象合约）
contract BasicDepositBox is BaseDepositBox {
    // 获取存款盒类型（实现/重写父合约虚函数，pure函数无状态读写）
    function getBoxType() external pure override returns(string memory) {
        return "Basic"; // 返回类型标识：基础版存款盒
    }
}