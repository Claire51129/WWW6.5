//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./day9-ScientificCalculator.sol";
contract Calculator{
    address public owner;//owner` 将存储部署此合约的地址。
    address public scientificCalculatorAddress;//存放已部署的 `ScientificCalculator` 地址的地方
    constructor(){
        owner=msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender==owner,"Only owner can perform this action.");
        _;
    }

    function setScientificCalculator(address _address) public onlyOwner{
        scientificCalculatorAddress = _address;
    }
    function add(uint256 a,uint256 b) public pure returns(uint256){
        return (a+b);
    }
    function substract(uint256 a,uint256 b) public pure returns(uint256){
        return (a-b);
    }
    function multiply(uint256 a,uint256 b) public pure returns(uint256){
        return(a*b);
    }
    function divide (uint256 a,uint256 b) public pure returns(uint256){
        require(b!=0,"Division by zero");
        return (a/b);
    }
    //新知识：调用外部函数
    function calculatePower(uint256 base,uint256 exponent) public view returns(uint256){
        //将以太坊地址转换成合约对象
        ScientificCalculator scientificCalc=ScientificCalculator(scientificCalculatorAddress);
        uint256 result=scientificCalc.power(base,exponent);
        return result;
    }
    //
    function calculateSquareRoot(uint256 number) public returns(uint256){
        require(number>=0,"Cann't calculate square root of negative number");
        bytes memory data=abi.encodeWithSignature("squareRoot(uint256)",number);
        //abi:应用程序二进制接口
        //abi.encodeWithSignature EVM虚拟机在调用特定函数时期望的确切的二进制格式
        (bool success,bytes memory returnDate)=scientificCalculatorAddress.call(data);
        //`.call(data)` 将这些数据发送到存储在 `scientificCalculatorAddress` 中的地址。
        //`success`（一个布尔值，告诉我们调用是否成功）
        // `returnData`（一个字节数组，包含函数返回的内容）
        require(success,"External call failed");
        uint256 result=abi.decode(returnDate,(uint256));//解码
        return result;
        
    }

}
