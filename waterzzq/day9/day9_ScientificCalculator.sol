// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator {
    function power(uint256 base, uint256 exponent) public pure returns(uint256) {
        // 特殊情况：任何数的0次方都是1
        if(exponent == 0) {
            return 1;
        }
        // Solidity内置幂运算符：**
        return (base ** exponent);
    }

    function squareRoot(int256 number) public pure returns(int256 result) {
        // 校验：不能对负数开平方
        require(number >= 0, "ScientificCalculator: Cannot calculate square root of negative number");

        // 初始化迭代值
        result = number;
        // 牛顿迭代公式：x(n+1) = (x(n) + number/x(n)) / 2
        while (result * result > number) {
            result = (result + number / result) / 2;
        }
    }
}
