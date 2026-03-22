//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract ScientificCalculator {
   
   //幂运算
   //标记 pure 表示该函数不会读取或修改合约的状态变量，仅依赖于输入参数进行计算。这使得函数更高效，因为它不需要访问区块链上的存储数据。
   function power(uint256 base,uint256 exponent)public pure returns(uint256){
    if(exponent == 0)return 1; //任何数的0次幂都等于1
    else return (base ** exponent); //使用Solidity的幂运算符
   }

    //平方根运算
    function squareRoot(int256 number) public pure returns (int256){
        require(number >= 0, "Cannot calculate square root of negative number"); //平方根仅适用于非负数
        if (number == 0) return 0; //平方根为0的情况
        int256 result = number/2;
        for(uint256 i = 0;i<10;i++){ //迭代10次，增加精度
            result = (result + number / result) / 2; //牛顿迭代法，通过重复逼近来找到平方根
        }
        return result;
    } 

}