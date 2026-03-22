//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ScientificCalculator{

    /**
     * @notice 计算基数的指定次幂（base^exponent）
     * @dev pure函数：仅依赖入参完成纯逻辑计算，无区块链状态读写
     * @param base 基数（非负整数）
     * @param exponent 指数（非负整数）
     * @return 幂运算结果（base的exponent次方）
     */
    function power(uint256 base, uint256 exponent)public pure returns(uint256){
        if(exponent == 0)return 1; // 数学规则：任何非零数的0次方结果为1
        else return (base ** exponent); // Solidity中'**'是指数运算符，等价于数学中的次方运算
    }

    /**
     * @notice 采用牛顿迭代法逼近计算非负整数的平方根
     * @dev pure函数：仅依赖入参完成纯逻辑计算，无区块链状态读写
     * @dev 补充：Solidity不支持浮点数运算，因此通过牛顿法迭代逼近获取整数近似值
     * @param number 待计算平方根的非负整数
     * @return 平方根的近似整数结果（迭代收敛值）
     */
    function squareRoot(int256 number)public pure returns(int256){
        require(number >= 0, "Cannot calculate square root of negative number"); // 数学约束：负数无实数平方根
        if(number == 0)return 0; // 0的平方根为0

        int256 result = number/2; // 初始化迭代初始值（取输入值的1/2作为初始近似值）
        // 迭代次数限制：避免无限循环导致Gas耗尽（Solidity中无限循环会触发交易失败）
        // 说明：限制10轮迭代虽无法得到绝对精确值，但足以体现牛顿法的收敛过程
        for(uint256 i = 0; i<10; i++){
            result = (result + number / result)/2; // 牛顿迭代法核心公式：x(n+1) = (x(n) + S/x(n))/2
        }

        return result; // 返回迭代收敛后的平方根近似值
    }
}