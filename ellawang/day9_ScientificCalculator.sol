// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator { 
    
    // 技能 1：算幂（多少次方）
    function power(uint256 base, uint256 exponent) public pure returns (uint256) { 
        if (exponent == 0) return 1; 
        else return (base ** exponent); // 使用 Solidity 原生的 ** 符号算次幂
    }

    // 技能 2：用“牛顿逼近法”算平方根
    function squareRoot(uint256 number) public pure returns (uint256) { 
        require(number >= 0, "Cannot calculate square root of negative number"); 
        if (number == 0) return 0; 
        
        // 牛顿法公式循环 10 次，找出最接近的整数 
        uint256 result = number / 2;
        for (uint256 i = 0; i < 10; i++) { 
            result = (result + number / result) / 2;
        }
        return result; 
    }
}