// SPDX-License-Identifier: MIT
// 合约许可证声明：用的是MIT开源许可证（Solidity合约必须加这个，不然编译器会警告）

pragma solidity ^0.8.20;
// 指定编译器版本：兼容0.8.20及以上，不能用0.9.0+（版本不兼容容易出问题）

// 导入自己写的Ownable合约，复用里面的所有权管理功能（比如onlyOwner权限控制）
import "./day11_Ownable.sol";

// 简易资金保险库合约（继承Ownable做权限管控）
// 自己练手写的ETH托管小合约，核心功能：存ETH、查余额、只有合约主人能提ETH
contract VaultMaster is Ownable{

    // 存款成功事件（加了indexed的地址，后面查日志时能按地址过滤，超方便）
    event DepositSuccessful(address indexed account, uint256 value);
    // 提款成功事件（记录提了多少ETH到哪个地址，方便对账）
    event WithdrawSuccessful(address indexed reciepient, uint256 value);
    
    // 查合约当前的ETH余额（注意：返回值单位是wei，不是ETH哦！）
    // view函数特点：只读取链上数据，不修改，调用几乎不花Gas（本地调用完全免费）
    // address(this).balance 就是取当前合约地址里的ETH余额
    function getBalance()public view returns(uint256){
        return address(this).balance;
    }

    // 往合约里存ETH的函数
    // payable关键字是核心！没有这个，调用函数时转ETH会直接失败
    function deposit()public payable{
        // 防呆校验：必须存大于0的ETH，不然白忙活一场
        require(msg.value >0, "Enter a valid amount");
        // 触发存款事件，把谁存了多少ETH记录下来，后续能查
        emit DepositSuccessful(msg.sender, msg.value);
    }

    // 从合约里提ETH（只有合约主人能调，因为加了onlyOwner修饰符）
    function withdraw(address _to, uint256 _amount) public onlyOwner {
        // 先检查合约余额够不够提，不够的话直接报错回滚
        require(_amount <= getBalance(), "Insufficient balance");
        // 用call方法转ETH（比transfer好用，不会有Gas限制的坑）
        // 要先把_to转成payable地址才能转ETH，{value: _amount}指定转多少
        (bool success , ) = payable(_to).call{value: _amount}("");
        // 转钱失败的话必须回滚，不然合约扣了钱但对方没收到就惨了
        require(success, "Transfer Failed");
        // 触发提款事件，记录提币记录，方便后续核对
        emit WithdrawSuccessful(_to, _amount);
        
    }

}