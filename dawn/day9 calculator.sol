// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day9 ScientificCalculator.sol";

contract Calculator {
    address public owner;
    address public scientificCalculatorAddress;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    // 设置科学计算器地址
    function setScientificCalculator(address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    }
    
    // 方式1: 高级调用 - power
    function power(uint256 base, uint256 exponent) public view returns (uint256) {
        require(scientificCalculatorAddress != address(0), "Calculator not set");
        
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        return scientificCalc.power(base, exponent);
    }
    
    // 方式2: 低级调用 - squareRoot
    function squareRoot(uint256 number) public view returns (uint256) {
        require(scientificCalculatorAddress != address(0), "Calculator not set");
        
        bytes memory data = abi.encodeWithSignature("squareRoot(uint256)", number);
        (bool success, bytes memory returnData) = scientificCalculatorAddress.staticcall(data);
        require(success, "Call failed");
        
        return abi.decode(returnData, (uint256));
    }
}