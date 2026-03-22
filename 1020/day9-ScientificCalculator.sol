//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator{
    //新知识：pure 不读，不可写，不读取或更改区块链上的任何内容。它只是进行数学运算；view：只读，不可写
    //计算指数
    function power(uint256 base,uint256 exponent)public pure returns(uint256){
    if(exponent==0)return 1;
    else return (base**exponent);
    }
    //估算平方根：$$x_{n+1} = \frac{1}{2}(x_n + \frac{a}{x_n})$$
    function squareRoot(uint256 number) public pure returns(uint256){
    require(number>=0,"Cannot calculate square root of negative number");
    if (number==0) return 0;
    uint256 result=number/2;
    for(uint256 i=0;i<10;i++){
        result=(result+number/result)/2;
    }
    return result;
    }
}