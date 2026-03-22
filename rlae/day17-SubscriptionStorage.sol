// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 
import "./day17-SubscriptionStorageLayout.sol";
//通过导入和继承这个布局，两个合约可以共享和操作相同的数据，前提是它们的内存布局顺序相同
//**继承**自 `SubscriptionStorageLayout`，意味着它现在拥有：

//- `logicContract`（指向当前逻辑的指针）
//- `owner`
//- 所有的映射（`subscriptions`, `planPrices`, `planDuration`）
contract SubscriptionStorage is SubscriptionStorageLayout{
    modifier onlyOwner(){
        require(msg.sender ==  owner, "you are not owner");
        _;
    }
    constructor (address _logicContract){
        owner = msg.sender;
        logicContract = _logicContract;
    }
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
        //可以在不触及用户数据或要求人们重新部署的情况下修复错误、添加功能或重构代码。
    }
    //每次用户尝试与我们其他合约中的函数,此代理合约中不存在的函数,(如 subscribe() 或 isActive())交互时，都会触发这个函数
    fallback() external payable{
        address impl =logicContract;//设置逻辑合约存储在 impl 中
        require(impl != address(0), "invalid address");

        assembly {
            calldatacopy(0,0,calldatasize()) //将输入数据（函数签名 + 参数）复制到内存槽 0
            let result := delegatecall(gas(),impl,0, calldatasize(),0,0) //在逻辑合约（impl）上运行这个输入，在 A 里 delegatecall B，B 的代码会在 **A 的存储空间（Storage）**里运行。
            returndatacopy(0, 0, returndatasize()) //逻辑合约执行返回的任何内容复制到内存
            switch result
            case 0 { revert(0, returndatasize()) } //逻辑调用失败，我们回退（revert）并返回错误
            default { return(0, returndatasize()) } //将结果返回给原始调用者——就像代理自己执行了它一样

        }
    }
    receive() external payable {}
}