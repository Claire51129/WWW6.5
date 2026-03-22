// 数字计数器
// SPDX-License-Identifier: MIT

// 在solidity开始读取合约前，需告诉它应该使用哪个编译器版本：
pragma solidity ^0.8.0;

contract ClickCounter {

    uint256 public counter;    //创建名为counter的状态变量——存储点击次数，状态变量默认初始化为0

// 函数：增加计数器
    function click() public {    
        counter++;
    }

}


// 许可，solidity版本控制、状态变量、函数
// MIT：指麻省理工学院许可证，是最宽松的开源许可证之一，任何人都可以使用、修改和共享合同，允许商业使用。如有问题，作者不承担责任
// SPDX代表软件包数据交换，这只是代码中指示许可证的正式方式
// 合约是Solidity代码的基本单位，合约名称遵循大驼峰命名法，一个文件通常一个主合约
// uint256：一种表示无符号整数的数据类型，意味着它只能存储正数（0及以上）
// public: 使任何人都可以访问该变量。solidity自动创建一个getter公共函数，允许用户检查计数器的当前值，无需单独的函数。
// counter++：每次函数运行时将计数器增加一个单位
// 数据类型：除uint256，还有int、bool、address、string等
// 可见性修饰符：public、private、internal、external 控制访问权限
// 函数修饰符：view（只读）、pure（不读不写）、payable（接收ETH）
