// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator {

    //幂运算
    //base 底数 exponent 指数 return base^exponent
    function power(uint256 base, uint256 exponent) public pure returns(uint256) {
        return base ** exponent;
    }

    //计算平方根
    // number 要计算平方根的数字 return 平方根结果
    function squareRoot(uint256 number) public pure returns(uint256) {
        if(number <= 1) return number;  // 0 或 1 直接返回

        uint256 result = number / 2;
        uint256 last;

        // 迭代直到收敛
        do {
            last = result;
            result = (result + number / result) / 2;
        } while (result != last);

        return result;
    }
} 