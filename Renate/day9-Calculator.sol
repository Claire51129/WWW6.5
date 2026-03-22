//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./day9_ScientificCalculator.sol";

contract Calculator{

    address public owner; // 合约所有者地址（部署者）
    address public scientificCalculatorAddress; // 外部科学计算器合约（ScientificCalculator）的部署地址

    constructor(){
        owner = msg.sender; // 将合约部署者设置为合约所有者
    }

    // 权限修饰符：仅合约所有者（owner）可调用被该修饰符标记的函数
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this action");
         _;  // 执行被修饰函数的核心逻辑（修饰符的占位符）
    }

    // 设置外部科学计算器合约的部署地址
    // 说明：只有知晓外部合约的有效地址，才能发起跨合约调用（合约间通信）
    function setScientificCalculator(address _address)public onlyOwner{
        scientificCalculatorAddress = _address;
        }

    // 基础加法运算
    // pure 函数特性：既不读取也不修改区块链状态，仅依赖入参计算
    // 补充：pure函数本地调用无Gas消耗，链上执行仍需支付基础Gas（仅无状态读写的Gas成本）
    function add(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a+b;
        return result;
    }

    // 基础减法运算（pure函数：无状态读写，仅依赖入参计算）
    function subtract(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a-b;
        return result;
    }

    // 基础乘法运算（pure函数：无状态读写，仅依赖入参计算）
    function multiply(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a*b;
        return result;
    }

    // 基础除法运算（pure函数：无状态读写，仅依赖入参计算）
    function divide(uint256 a, uint256 b)public pure returns(uint256){
        require(b!= 0, "Cannot divide by zero"); // 安全校验：除数不能为0
        uint256 result = a/b;
        return result;
    }

    // 幂运算（高级计算功能）：通过跨合约调用实现（体现合约组合式编程特性）
    // view函数：仅读取状态（scientificCalculatorAddress），不修改链上数据
    function calculatePower(uint256 base, uint256 exponent)public view returns(uint256){

    // 跨合约调用方式1（实例化合约对象）：通过外部合约地址创建接口实例
    ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);

    // 调用外部合约的power函数完成幂运算
    uint256 result = scientificCalc.power(base, exponent);

    return result;

}

    // 平方根运算（高级计算功能）：演示底层call方法实现跨合约调用
    function calculateSquareRoot(uint256 number)public returns (uint256){
        require(number >= 0 , "Cannot calculate square root of negative number"); // 修正：负数无平方根

        // 步骤1：编码目标函数签名和参数（函数签名无空格，格式为"函数名(参数类型)"）
        bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);
        
        // 步骤2：发起底层call调用，向外部合约地址发送编码后的调用数据
        // call返回值：success（调用是否成功）、returnData（外部合约返回的原始字节数据）
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        require(success, "External call failed"); // 安全校验：确保跨合约调用执行成功
        
        // 步骤3：解码返回的字节数据为uint256类型（还原为可读的数值结果）
        uint256 result = abi.decode(returnData, (uint256));
        return result;
    }

    
}