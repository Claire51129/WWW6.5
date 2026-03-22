// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// 科学计算器
contract ScientificCalculator{

    // 计算幂次(power乘方)
    function power(uint256 base, uint256 exponent)public pure returns(uint256){ // base为底数，exponent为指数，pure为不改变区块链状态
        if(exponent ==0)return 1;
        else return (base ** exponent);    // **为乘方符号
    }

    // 计算平方根
    function squareRoot(int256 number)public pure returns(int256){
        require(number >= 0, "Cannot calculate square root of negative number");
        if(number == 0)return 0;

        int256 result = number/2;
        for(uint256 i = 0; i<10; i++){    //重复计算10次，让答案越来越接近真实平方根
            result = (result + number / result)/2;    // 数字算法(牛顿法)——不断修正答案
        }

        return result;

    }
}