// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day9-ScientificCalculator.sol";


contract Calculator {
    address public  owner;
    address public scientificCalculatorAddress;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }


    function setScientificCalculator(address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    } 

    function add(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a + b;
        return result;
    }

    function sub(uint256 a, uint256 b) public pure returns (uint256) {
        require(a >= b, "Subtraction underflow: a must be >= b");
        uint256 result = a - b;
        return result;
    }

    function mul(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a * b;
        return result;
    }

    function div(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "Cannot divide by zero");
        uint256 result = a / b;
        return result;
    }

    function calculatePower(uint256 base, uint256 exponent) public view returns (uint256) {
        // 地址强制类型转换：以太坊地址转换成一个可用的合约对象
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        // 调用函数
        uint256 result = scientificCalc.power(base, exponent);
        return result;
    }
}