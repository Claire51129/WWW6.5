//它就像一本说明书，告诉“身体”该怎么干活。
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayou.sol";

contract SubscriptionStorage is SubscriptionStorageLayout {
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;
    }

//你可以在不触及用户数据或要求人们重新部署的情况下修复错误、添加功能或重构代码;逻辑升级
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
    }

//请求转发员”或“自动调度中心”的角色，fallback() 充当了“前台接待”或“转发器”，负责将所有它处理不了的请求通过 delegatecall 指令转发给后台的逻辑合约
    fallback() external payable {
        address impl = logicContract;// logicContract是逻辑合约的意思，确保已设置逻辑合约，将其存储在 impl 中。
        require(impl != address(0), "Logic contract not set");

        assembly {  //负责把玩家的要求从身体（代理合约）搬到大脑（逻辑合约），再把结果搬回来
            calldatacopy(0, 0, calldatasize())//将输入数据（函数签名 + 参数）复制到内存槽 0。
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            //let result：这是一个记事本。它用来记录这次转发是成功（1）还是失败（0）
            //delegatecall(...)：这是最神奇的魔法口令。它的意思是“委派调用”，即请别人帮忙算账，但钱还是存在自己的口袋里
            //gas()：这是给“大脑”干活用的体力值
            //impl：这是**“大脑”的地址**
            //0, calldatasize()：这是告诉大脑：“活儿都在这里”
            //0, 0：这是在说：“先别管结果有多长”。
            returndatacopy(0, 0, returndatasize())//将逻辑合约执行返回的任何内容复制到内存中

            switch result
            case 0 { revert(0, returndatasize()) }
            //“如果‘大脑’（逻辑合约）干活时出错了，那就把错误信息原封不动地扔回给用户，并停止所有动作
            //这一行开头的 case 0 表示：“如果刚才那个小本子上记的是 0”，也就是大脑刚才干活失败/报错了
            default { return(0, returndatasize()) }
            //default：在汇编的 switch 语句里，它代表除此之外的其他情况
            //把大脑算好的结果，原封不动地还给用户
        }
    }

    receive() external payable {}
    //一个安全网，允许代理接受原始 ETH 转账。
}
