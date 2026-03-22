// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ScientificCalculator 合约，科学计算器
contract ScientificCalculator{

    // 计算幂运算
    function power(uint256 base, uint256 exponent) public pure returns(uint256){

        if(exponent == 0){
            return 1;
        }

        return base ** exponent;
    }


    // 计算平方根（牛顿法）
    function squareRoot(uint256 number) public pure returns(uint256){

        // 检查输入不为负
        require(number >= 0, "Cannot calculate square root of negative number");

        // 如果输入是0，返回0
        if(number == 0){
            return 0;
        }

        // 粗略估计
        uint256 result = number / 2;

        // 十次精炼
        for(uint256 i = 0; i < 10; i++){
            result = (result + number / result) / 2;
        }

        // 返回结果
        return result;
    }

}