// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day9_1ScientificCalculator.sol"; //"./" -- the same directory

contract Calculator { //basic arithmetic functions
    address public owner;
    address public scientificCalculatorAddress;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action.");
        _;
    }

    //Once the ScientificCalculator.sol is deployed, you can copy its address and pass it here to call its functions later.
    function setScientificCalculator(address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    }

    //basic math functions
    function add(uint256 a, uint b) public pure returns(uint256) {
        uint256 result = a + b;
        return result;
    }
    function subtract(uint256 a, uint b) public pure returns (uint256) {
        uint256 result = a - b;
        return result;
    }
    function multiply(uint256 a, uint b) public pure returns (uint256) {
        uint256 result = a * b;
        return result;
    }
    function divide(uint256 a, uint b) public pure returns (uint256) {
        require(b != 0, "Cannot divide by zero.");
        uint256 result = a / b;
        return result;
    }

    //a high-level call to connect to another contract
    function calculatePower(uint256 base, uint256 exponent) public view returns(uint256) {
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);//address casting: convert an address into a contract reference so you can call it directly.\
        uint256 result = scientificCalc.power(base, exponent);
        return result;
    }

    //a low-level call a function from another contract without using a direct import
    function calculateSquareRoot(uint256 number) public returns(uint256) {
        require(number >= 0, "Cannot calculate square root of negative numbers"); //这不和ScientificCalculator中的squareRoot函数重复了吗？要判断2次

        //没懂，好复杂的调用
        bytes memory data = abi.encodeWithSignature("squareRoot(uint256", number); //abi:Application Binary Interface
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        require(success, "External call failed.");

        uint256 result = abi.decode(returnData, (uint256));
        return result;
    }
}