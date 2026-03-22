// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// 导入科学计算器
import "./day9-ScientificCalculator.sol";

contract Calculator{

    address public owner;    //记录合约主人
    address public scientificCalculatorAddress;    //记录科学计算器地址 ps:区块链上每个合约都有地址

    constructor(){
        owner = msg.sender;    //owner是部署合约的人
    }

    modifier onlyOwner() {    //只有owner可以使用某些功能 如以下功能
        require(msg.sender == owner, "Only owner can do this action");
        _;
    }

    //设置科学计算器（仅owner权限）
    function setScientificCalculator(address _address)public onlyOwner{
        scientificCalculatorAddress = _address;
    }

    //加法
    function add(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a+b;
        return result;
    }

    //减法
    function subtract(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a-b;
        return result;
    }

    //乘法
    function multiply(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a*b;
        return result;
    }

    //除法，且检查除数不等于0
    function divide(uint256 a, uint256 b)public pure returns(uint256){
        require(b!=0, "Cannot divide by zero");
        uint256 result = a/b;
        return result;
    }

    //直接调用科学计算器：power
    function calculatrPower(uint256 base, uint256 exponent)public view returns(uint256){

    ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);    // 找到科学计算器位置

    //external call 向外部请求执行代码
    uint256 result = scientificCalc.power(base, exponent);    //让科学计算器帮忙算

    return result;

    }

    //低级调用/底层call：平方根运算
    function calculatrSquareRoot(uint256 number)public returns (uint256){
        require(number >=0 , "Cannot cansulate square root of negative number");

        bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);    //低级调用：写信寄给另一个合约——写信→寄信→收到回信→读回信
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);    //①把函数名打包②发给另一个合约③得到结果
        require(success, "External call failed");
        uint256 result = abi.decode(returnData, (uint256));    //abi.decode像把回信翻译成人能读的数字
        return result;
    }


}



// 1 合约模块化
// 2 合约间可相互调用
// 3 两种合约调用方式：直接调用&低级调用
// 4 ABI编码（encoding）：合约通信方式——所有web3交互的底层机制
// 5 牛顿迭代法计算平方根