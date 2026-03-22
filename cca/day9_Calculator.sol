//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import {ScientificCalculator} from "./day9_ScientificCalculator.sol";

contract Calculator{
    address public owner;
    address scientificCalculatorAddress;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function setScientificCalculator(address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    }//科学计算器部署完成后可以用以储存地址

    function add(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a + b;
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

    function calculatePower(uint256 base, uint256 exponent)public view returns(uint256){
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        /*这一行将一个普通的以太坊地址（scientificCalculatorAddress）转换成一个可用的合约对象 
        1.因为在开头导入(import)了另一个文件 所以可以直接直接使用ScientificCalcuator来创建一个合约对象
        声明后可以使用点号标记法发起调用;
        2.右侧ScientificCalculator()是具体的转换函数。它接收一个地址，封装成合约对象
       称为地址强制类型转换address casting ————将一个地址转换为一个合约引用，以便直接与之交互。*/
       uint256 result = scientificCalc.power(base,exponent);
       return result;
    }

    function calculateSquareRoot(uint256 number) public returns (uint256) {
    require(number >= 0, "Cannot calculate square root of negative number");

    bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);
    (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
    require(success, "External call failed");
    uint256 result = abi.decode(returnData,(uint256));
    return result;
}/*1.abi.encodeWithSignature函数用于将函数签名和参数编码成字节流
2.abi——application binary interface应用程序二进制接口 定义了当一方合同调用另一方时数据必须如何结构化
低级调用中需要手动告诉EVM要使用的函数以及传递的参数
squareRoot(int256)是一个函数签名 括号外是函数名 里面是传递的参数 可以看做一个公函表示要进行squareRoot业务
而后再targetAddress.call, .call就是快递员
3.返回值bytes 字节数组 所以接受后需要解码
*/
}