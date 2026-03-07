//许可证声明
//SPDX-License-Identifier:MIT   
  //SPDX许可证标识符：SPDX代表软件包数据交换，这只是在代码中指示许可证的正式方式
              //MIT“MIT” 是指麻省理工学院许可证，这是最宽松的开源许可证之一。这意味着：任何人都可以使用、修改和共享合同。代码的使用方式没有限制。如果出现问题，作者不承担任何责任。

//编译器版本 指定使用0.8.x版本的Solidity编译器。^符号表示兼容0.8.0到0.8.99之间的任何版本,但不包括0.9.0。
pragma solidity ^0.8.0;

//合约声明
contract ClickCounter {
    //状态变量声明 - 存储点击次数 公开的无符号256位整数变量counter
    uint256 public counter;

    //函数 - 增加计数器  定义一个公共函数click()。每次调用时,将counter的值加1。++是递增运算符,等同于counter = counter + 1
    function click() public {
        counter ++;
    }
    
    //函数 - 将计数器重置为0
    function reset() public {
        counter = 0;
    }
    
    //函数 - 使计数器减1(提示:注意不要让它变成负数!)
    function decrease() public {
        //counter > 0 的情况下才能-1，而不是>=0
        require(counter > 0 ,"counter can not be less than 0");
        counter -- ;
    }

    //函数 - 明确返回当前计数(提示:使用view修饰符)  view 的意思是：只读取状态变量，不修改区块链数据
    function getCouner() public view returns (uint256) {
        return counter;
    }

    //函数,一次增加多次
    function clickMultiple(uint256 times) public {
        counter += times;
    }
    
}
