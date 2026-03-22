// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入科学计算器合约（路径要和文件名一致，同文件夹直接写文件名）
import "./day9_ScientificCalculator.sol";

/**
 * @title 基础计算器合约
 * @dev 实现加减乘除（基础功能），并调用科学计算器的高级功能
 */
contract Calculator {
    // 合约所有者（部署者）地址
    address public owner;
    // 科学计算器合约的地址（用来调用它的函数）
    address public scientificCalculatorAddress;

    // 构造函数：部署时设置所有者为部署者
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev 权限修饰符：仅所有者可调用
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Calculator: Only owner can call this function");
        _;
    }

    /**
     * @dev 设置科学计算器合约的地址（仅所有者可改）
     * @param _address 已部署的ScientificCalculator合约地址
     */
    function setScientificCalculator(address _address) public onlyOwner {
        // 校验：地址不能是0地址（无效地址）
        require(_address != address(0), "Calculator: Invalid address");
        scientificCalculatorAddress = _address;
    }

    // -------------------------- 基础计算功能 --------------------------
    /**
     * @dev 加法
     * @param a 第一个数
     * @param b 第二个数
     * @return 两数之和
     */
    function add(uint256 a, uint256 b) public pure returns(uint256) {
        return a + b;
    }

    /**
     * @dev 减法（防止负数，返回0如果a < b）
     * @param a 被减数
     * @param b 减数
     * @return 两数之差
     */
    function subtract(uint256 a, uint256 b) public pure returns(uint256) {
        if (a < b) {
            return 0;
        }
        return a - b;
    }

    /**
     * @dev 乘法
     * @param a 第一个数
     * @param b 第二个数
     * @return 两数之积
     */
    function multiply(uint256 a, uint256 b) public pure returns(uint256) {
        return a * b;
    }

    /**
     * @dev 除法（防止除以0）
     * @param a 被除数
     * @param b 除数
     * @return 两数之商（整数，向下取整）
     */
    function divide(uint256 a, uint256 b) public pure returns(uint256) {
        require(b != 0, "Calculator: Cannot divide by zero");
        return a / b;
    }

    // -------------------------- 调用科学计算器的高级功能 --------------------------
    /**
     * @dev 方式1：直接实例化合约调用幂运算
     * @param base 底数
     * @param exponent 指数
     * @return 幂运算结果
     */
    function calculatePower(uint256 base, uint256 exponent) public view returns(uint256) {
        // 校验：已设置科学计算器地址
        require(scientificCalculatorAddress != address(0), "Calculator: Scientific calculator address not set");
        // 实例化科学计算器合约
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        // 调用它的power函数
        return scientificCalc.power(base, exponent);
    }

    /**
     * @dev 方式2：底层call + ABI编码调用平方根
     * @param number 要开平方的数
     * @return 平方根结果
     */
    function calculateSquareRoot(uint256 number) public returns (uint256) {
        // 校验：已设置科学计算器地址
        require(scientificCalculatorAddress != address(0), "Calculator: Scientific calculator address not set");
        
        // 1. ABI编码：把函数名+参数转成字节（相当于给科学计算器发加密指令）
        // 注意：函数签名要和ScientificCalculator里的一致，参数类型是int256
        bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);
        
        // 2. 底层call调用：给科学计算器地址发指令
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        
        // 3. 校验调用是否成功
        require(success, "Calculator: Failed to call squareRoot function");
        
        // 4. 解码返回结果（把字节转回uint256）
        return abi.decode(returnData, (uint256));
    }
}