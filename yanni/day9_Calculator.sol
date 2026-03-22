// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day9_ScientificCalculator.sol";

//基础计算器，支持加减乘除，并调用 ScientificCalculator 进行幂和平方根运算
contract Calculator {

    address public owner;
    address public scientificCalculatorAddress;

    // 部署合约时设置拥有者
    constructor() {
        owner = msg.sender;
    }

    //仅允许拥有者执行
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this action");
        _;
    }

    //设置 ScientificCalculator 合约地址
    //_address ScientificCalculator 合约地址
    function setScientificCalculator(address _address) public onlyOwner {
        require(_address != address(0), "Invalid address");
        scientificCalculatorAddress = _address;
    }

    //加法
    function add(uint256 a, uint256 b) public pure returns(uint256) {
        return a + b;
    }

    //减法
    function subtract(uint256 a, uint256 b) public pure returns(uint256) {
        return a - b;
    }

    //乘法
    function multiply(uint256 a, uint256 b) public pure returns(uint256) {
        return a * b;
    }

    //除法（整数除法）
    function divide(uint256 a, uint256 b) public pure returns(uint256) {
        require(b != 0, "Cannot divide by zero");
        return a / b;
    }

    //幂运算，通过 ScientificCalculator 执行
    //base 底数 exponent 指数 return 幂运算结果
    function calculatePower(uint256 base, uint256 exponent) public view returns(uint256) {
        require(scientificCalculatorAddress != address(0), "ScientificCalculator not set");
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        return scientificCalc.power(base, exponent);
    }

    //平方根运算，通过低级调用 ScientificCalculator 执行
    //number 要计算平方根的数字 return 平方根结果
    function calculateSquareRoot(uint256 number) public returns (uint256) {
        require(scientificCalculatorAddress != address(0), "ScientificCalculator not set");

        bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        require(success, "External call failed");

        return abi.decode(returnData, (uint256));
    }
}