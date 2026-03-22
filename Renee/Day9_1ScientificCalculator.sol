// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator {
    // advanced operations
    

    //指数power
    function power(uint256 base, uint256 exponent) public pure returns(uint256) {
        //pure: doesn't read/change anything on the blockchain
        if (exponent == 0) return 1;
            else return (base ** exponent);
    }

    //开平方根
    function squareRoot(uint256 number) public pure returns(uint256) {
        require(number >= 0, "Cannot calculate square root of negative numbers");
        if (number == 0) return 0; // 0的平方根为0

        //Newton's Method
        uint256 result = number/2;
        for (uint256 i = 0; i < 10; i++) {
            result = (number/result + result) / 2;
        }
        return result;
    }
}