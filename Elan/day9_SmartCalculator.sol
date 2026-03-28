// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartCalculator {
    // 状态变量：存储最后一次计算的结果
    int256 public lastResult;

    // 事件：记录每次运算的操作和结果
    event CalculationPerformed(string operation, int256 a, int256 b, int256 result);

    // 加法
    function add(int256 a, int256 b) public returns (int256) {
        lastResult = a + b;
        emit CalculationPerformed("Addition", a, b, lastResult);
        return lastResult;
    }

    // 减法
    function subtract(int256 a, int256 b) public returns (int256) {
        lastResult = a - b;
        emit CalculationPerformed("Subtraction", a, b, lastResult);
        return lastResult;
    }

    // 乘法
    function multiply(int256 a, int256 b) public returns (int256) {
        lastResult = a * b;
        emit CalculationPerformed("Multiplication", a, b, lastResult);
        return lastResult;
    }

    // 除法 (包含错误检查)
    function divide(int256 a, int256 b) public returns (int256) {
        // 使用 require 防止除以零导致的合约崩溃
        require(b != 0, "Cannot divide by zero");
        lastResult = a / b;
        emit CalculationPerformed("Division", a, b, lastResult);
        return lastResult;
    }

    // 清零函数
    function clear() public {
        lastResult = 0;
    }
}
