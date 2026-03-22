// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ScientificCalculator 合约
// 负责处理高级数学运算
contract ScientificCalculator{

    // 计算幂运算
    // 例如 2^3 = 8
    function power(uint256 base, uint256 exponent) public pure returns(uint256){

        // 任何数的0次方都是1
        if(exponent == 0){
            return 1;
        }

        // 使用 ** 进行幂运算
        return base ** exponent;
    }


    // 计算平方根
    // 使用 Newton Method（牛顿迭代法）
    function squareRoot(uint256 number) public pure returns(uint256){

        // 如果输入是0
        if(number == 0){
            return 0;
        }

        // 初始猜测值
        uint256 result = number / 2;

        // 循环逼近平方根
        for(uint256 i = 0; i < 10; i++){
            result = (result + number / result) / 2;
        }

        // 返回结果
        return result;
    }

}