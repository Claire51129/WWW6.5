// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator {

    // 幂运算 幂运算符 **
    function power(uint256 base, uint256 exponent) public pure returns(uint256) {
        if(exponent == 0) return 1;
        else {
            return  base ** exponent;
        }
    }

    // 平方根运算
    // pure 代表只是进行数学运算，不读取或变更内容
    function squareRoot(int256 number) public pure returns(int256) {
        // 负数无平方根
        require(number >= 0, "Cannot calculate square root of negative number");
        if(number == 0) return 0;

        // 牛顿迭代法 返回近似整数平方根   
        int256 result = number/2;
        // https://zh.wikipedia.org/wiki/%E7%89%9B%E9%A1%BF%E6%B3%95
        // 别问我为什么是循环 10 次 公式写了就是 10 
        for(uint256 i = 0; i < 10; i++) {
            result = (result + number/result)/2;
        }
        return result;
    }
}