// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Day17-SubscriptionStorageLayout.sol";

//代理合约
contract SubscriptionStorage is SubscriptionStorageLayout {

     constructor(address _logicContract) {
        //合约部署者设置成owner 
        owner = msg.sender;
        logicContract = _logicContract;

    }

    modifier onlyOwner() {

        //只有owner才能操作
        require(msg.sender == owner, "Not owner");
        _;

    }

   
    //升级函数 把代理以后转发到的新逻辑地址换掉
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;

    }


    // fallback()调用了一个本合约不存在的函数 
    //这是一个给外部调用的特殊函数 payable它可以收钱
    fallback() external payable {
        address impl = logicContract; //逻辑合约的地址 constructor里写了
        require(impl != address(0), "logic contract not set");

        //把别人发来的数据完整复制
        assembly {
            //把calldata里的内容复制到内存里 calldatacopy(内存从哪开始放, calldata从哪开始拿, 复制多少字节)
            calldatacopy(0, 0, calldatasize())
            //let 变量名 := 值 新建一个叫result的assembly变量
            //delegatecall() 借用别人的代码执行但是用的是自己的存储和上下文
            //gas():把当前剩下的gas给这次调用用
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            //返回执行结果
            returndatacopy(0, 0, returndatasize())

            switch result
            //失败了 把逻辑合约的报错原封不动传回给用
            case 0 { revert(0, returndatasize()) }
            //default就是成功了
            default { return(0, returndatasize()) }

        }

    }
     
    //代理可以直接接收eth
    receive() external payable {}

}

