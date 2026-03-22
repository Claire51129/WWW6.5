// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./day9_ScientificCalculator.sol";

contract Calculator
{
    address public owner;
    address public scientificCalculatorAddress;

    constructor()
    {
        owner=msg.sender;
    }

    modifier onlyOwner()
    {
        require(msg.sender==owner,"Only owner can perform this action");
        _;
    }

    //部署ScientificCalculator后保存地址在这里
    function setScientificCalculator(address _address)public onlyOwner
    {
        scientificCalculatorAddress=_address;
    }

    function add(uint256 a, uint256 b) public pure returns (uint256) 
    {
        uint256 result = a + b;
        return result;
    }

    function subtract(uint256 a, uint256 b) public pure returns (uint256) 
    {
        uint256 result = a - b;
        return result;
    }

    function multiply(uint256 a, uint256 b) public pure returns (uint256) 
    {
        uint256 result = a * b;
        return result;
    }

    function divide(uint256 a, uint256 b) public pure returns (uint256) 
    {
        require(b != 0, "Cannot divide by zero");
        uint256 result = a / b;
        return result;
    }

    function calculatePower(uint256 base,uint256 exponent)public view returns(uint256)
    {
        ScientificCalculator scientificCalc=ScientificCalculator(scientificCalculatorAddress);
        //将以太坊地址scientificCalculatorAddress转换为合约对象scientificCalc用以调用
        uint256 result=scientificCalc.power(base,exponent);
        return result;
    }

    function calculateSquareRoot(uint256 number)public returns(uint256)
    {
        require(number>=0, "Cannot calculate square root of negative number");

        bytes memory data=abi.encodeWithSignature("squareRoot(int256)",number);
        //函数的二进制格式
        (bool success,bytes memory returnData)=scientificCalculatorAddress.call(data);
        //将数据发送到scientificCalculatorAddress的地址，返回success和return data
        require(success,"External call failed");
        uint256 result=abi.decode(returnData,(uint256));//将return data解码回可用值 

        return result;
    }
}