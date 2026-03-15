//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Day9_ScientificCalculator.sol";
//我们使用一个 import 语句将 ScientificCalculator.sol 中的代码引入到这个文件中。
//这允许 Calculator 合约使用那个其他合约中的函数。
//`"./"` 部分告诉 Solidity：
// “查看与这个文件相同的目录（或文件夹）中，找到
//因此，为了让这个导入正常工作，这两个文件要在同一个文件夹中
contract Calculator{

    address public owner;
    address public scientificCalculatorAddress;
//定义几个状态变量来存储有用信息
    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this action");
         _; 
    }
//构造所有者
    function setScientificCalculator(address _address)public onlyOwner{
        scientificCalculatorAddress = _address;
        }
//主人设置科学计算器合约地址
    function add(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a+b;
        return result;
    }

    function subtract(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a-b;
        return result;
    }

    function multiply(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a*b;
        return result;
    }

    function divide(uint256 a, uint256 b)public pure returns(uint256){
        require(b!= 0, "Cannot divide by zero");
        uint256 result = a/b;
        return result;
    }
//加减乘除，都是pure（不读链上数据）只看输入的参数，只返回结果，不改变/读取任何链上东西
    function calculatePower(uint256 base, uint256 exponent)
    public view returns(uint256){
//把地址转成ScientificCalculator类型，
//它将一个普通的以太坊地址（scientificCalculatorAddress）转换成
//一个可用的合约对象——在这个例子中，是一个 ScientificCalculator。
    ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
//直接调用它的power函数
//这个过程称为地址强制类型转换 ——你将一个地址转换为一个合约引用，以便直接与之交互。
    //external call 
    //call就像手机，可以转钱、调用函数、上网（做其他事情）
    uint256 result = scientificCalc.power(base, exponent);
    //这向部署的 ScientificCalculator 合约发送一个只读调用，
    //要求它计算 base ** exponent
    return result;
}
//希望与另一个合约  **不导入其源代码**  进行交互——也许你只知道你想调用的函数的地址和名称。
//在这种情况下，你可以使用  **低级调用** 。它更灵活，但也更具风险，
//因为 Solidity 无法在编译时保护你免受错误的影响。
//ABI = Application Binary Interface（应用二进制接口）
//就是把"我要调用什么函数，传什么参数"打包成合约能懂的格式
    function calculateSquareRoot(uint256 number)public returns (uint256){
    //
        require(number >= 0 , "Cannot calculate square root of negative nmber");
//输入验证
        bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);
        //byte是电脑只能懂的字节
        //abi.encodeWithSignature是系统提供的函数，
        //abi.encodeWithSignature("函数名(参数类型)", 参数);
        //合约之间说话只能用byte，所以需要打包
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        //call(data)：把打包好的指令发给科学计算器合约，这一行是发起调用
        //用call调用data然后去赋值给左边的
        //左边是两个独立变量，接受两个返回值
        require(success, "External call failed");
        uint256 result = abi.decode(returnData, (uint256));
        return result;
    }

    
}