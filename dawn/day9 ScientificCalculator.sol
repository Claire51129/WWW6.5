// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator {
    // 幂运算: base^exponent
    function power(uint256 base, uint256 exponent) public pure returns (uint256) {
        uint256 result = 1;
        for (uint256 i = 0; i < exponent; i++) {
            result *= base;
        }
        return result;
    }//进行乘方,递进来底数和exonent指数,PURE是指递进来的数字做成数学计算，先准备一个结果等于一，然后开启循环指数是几就循环几次，每次就把结果乘以底数，最后把答案算出来。
    
    // 平方根(整数)
    function squareRoot(uint256 number) public pure returns (uint256) {
        if (number == 0) return 0;
        
        uint256 z = (number + 1) / 2;
        uint256 y = number;
        
        while (z < y) {
            y = z;
            z = (number / z + z) / 2;
        }
        return y;
    }//这里是用SOLIDIDY实现整数平方根函数进行迭代,当Z不再比Y小时，就取Y作为最终结果。
}