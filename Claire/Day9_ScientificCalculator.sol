//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ScientificCalculator{
//我们正在创建一个名为 ScientificCalculator 的新合约。
//在这个合约中，我们将首先编写一个用于计算幂的函数。
    function power(uint256 base, 
    uint256 exponent)public pure returns(uint256){
    //输入：底数、指数
    //返回：base的exponent次方
        if(exponent == 0)return 1;//任何数的0次方=1
        else return (base ** exponent);
    }//否则直接算 base的exponent次方

    function squareRoot(int256 number)public pure returns(int256){
    //输入：一个数
    //返回：它的平方根，returns在这里宣布类型
        require(number >= 0, 
        //要求数字大于0
        "Cannot calculate square root of negative number");
        if(number == 0)return 0;
   //0的平方根=0
        int256 result = number/2;
        //先猜一个数：number的一半
        for(uint256 i = 0; i<10; i++){
            result = (result + number / result)/2;
        }//牛顿迭代法：重复10次，越来越准
         //每次用公式算出更接近的值

        return result;
//返回结果
    }
}