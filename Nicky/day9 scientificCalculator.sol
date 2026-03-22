// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator{
    function power(uint256 base, uint256 exponent) public pure returns (uint256){//pure 不读取或更改区块链的内容
        if (exponent==0) return 1;
        else return (base ** exponent); // base^ exponent
    }

    function squareRoot(uint256 number) public pure returns(uint256){
        require(number >=0, "cannot calcualte square root of negative number");
        if (number== 0) return 0;
        uint256 result = number / 2;
        for (uint256 i=0; i<10; i++){//i=次数，重复10次以内
            result =(result+number/result)/2;
        }
        return result;
    }

}