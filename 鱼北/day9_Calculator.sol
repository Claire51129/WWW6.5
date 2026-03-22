// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入 ScientificCalculator 合约
import "./day9_ScientificCalculator.sol";

// 主计算器合约
contract day9_Calculator {

    // 合约拥有者
    address public owner;

    // ScientificCalculator 合约地址
    address public scientificCalculatorAddress;

    // 构造函数
    constructor(){
        owner = msg.sender;
    }

    // 只有 owner 可以调用
    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can do this action");
        _;
    }

    // 设置 ScientificCalculator 地址
    function setScientificCalculator(address _address) public onlyOwner{
        scientificCalculatorAddress = _address;
    }

    //基础数学函数
    // 加
    function add(uint256 a, uint256 b) public pure returns(uint256){
        uint256 result = a + b;
        return result;
    }

    // 减
    function subtract(uint256 a, uint256 b) public pure returns(uint256){
        uint256 result = a - b;
        return result;
    }

    // 乘
    function multiply(uint256 a, uint256 b) public pure returns(uint256){
        uint256 result = a * b;
        return result;
    }

    // 除（要求除数不为0）
    function divide(uint256 a, uint256 b) public pure returns(uint256){
        require(b != 0, "Cannot divide by zero");
        uint256 result = a / b;
        return result;
    }

    // 调用 ScientificCalculator 的 power 函数
    function calculatePower(uint256 base, uint256 exponent) public view returns(uint256){

        // 连接到另一个合约
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);

        // 调用函数
        uint256 result = scientificCalc.power(base, exponent);
        return result;
    }

    // 使用低级调用 squareRoot()
    function calculateSquareRoot(uint256 number) public returns(uint256){

        // 编码函数调用
        bytes memory data = abi.encodeWithSignature("squareRoot(uint256)", number);

        // 进行低级调用
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);

        // 检查调用是否成功
        require(success, "External call failed");

        // 解码响应、返回结果
        uint256 result = abi.decode(returnData, (uint256));
        return result;
    }

}