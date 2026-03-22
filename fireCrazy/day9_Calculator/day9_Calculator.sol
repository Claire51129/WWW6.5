// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 【核心】：导入专家的说明书
import "./day9_ScientificCalculator.sol"; 

contract Calculator { 
    address public owner;
    address public scientificCalculatorAddress; // 存放专家合约的地址

    constructor() { 
        owner = msg.sender; 
    }

    modifier onlyOwner() { 
        require(msg.sender == owner, "Only owner can perform this action"); 
        _;
    }

    // 社长专用：录入专家合约的地址
    function setScientificCalculator(address _address) public onlyOwner { 
        scientificCalculatorAddress = _address;
    }

    // --- 基础前台业务（本地执行）--- 
    
    function add(uint256 a, uint256 b) public pure returns (uint256) { 
        uint256 result = a + b; 
        return result;
    }

    function subtract(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a - b; 
        return result;
    }

    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a * b;
        return result; 
    }

    function divide(uint256 a, uint256 b) public pure returns (uint256) { 
        require(b != 0, "Cannot divide by zero"); // 防止除以 0 
        uint256 result = a / b; 
        return result; 
    }

    // --- 高级业务（委派给专家）--- 

    // 方式一：高级调用（有说明书，直接让 Solidity 认脸）
    function calculatePower(uint256 base, uint256 exponent) public view returns (uint256) { 
        // 强制类型转换：把普通地址变成一个 ScientificCalculator 合约对象
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress); 
        
        // 直接下达指令
        uint256 result = scientificCalc.power(base, exponent);
        return result; 
    }

    // 方式二：低级调用（不需要说明书，自己写 ABI 密电码发过去）
    function calculateSquareRoot(uint256 number) public returns (uint256) { 
        require(number >= 0, "Cannot calculate square root of negative number");

        // 1. 打包密电码（编码）
        bytes memory data = abi.encodeWithSignature("squareRoot(uint256)", number);
        
        // 2. 从后门发送密电码 
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data); 
        
        // 3. 检查有没有送达 
        require(success, "External call failed"); 

        // 4. 破译回信（解码）
        uint256 result = abi.decode(returnData, (uint256)); 
        return result; 
    }
}
