//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./day9_ScientificCalculator.sol";

contract Calculator {

    address public owner;//计算器拥有者
    address public scientificCalculatorAddress;//科学计算器合约地址.存放已部署的 ScientificCalculator 地址的地方

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    //ScientificCalculator 合约部署完成后将它的地址复制并粘贴到这里。这个函数会保存该地址，以便之后可以调用它的函数。
    function setScientificCalculator(address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    }

    function add(uint256 a,uint256 b) public pure returns(uint256){
        uint256 result = a + b;
        return result;
    }

    function subtract(uint256 a,uint256 b) public pure returns(uint256){
        require(a >= b, "Subtraction would result in negative value");
        uint256 result = a - b;
        return result;
    }

    function multiply(uint256 a,uint256 b) public pure returns (uint256) {
        uint256 result = a * b;
        return result;       
    }

    function divide(uint256 a,uint256 b) public pure returns (uint256) {
        require(b != 0, "Cannot divide by zero");
        uint256 result = a / b;
        return result;
    }

    //调用科学计算器合约的幂运算函数，高级调用
    //使用view修饰符，因为我们只是调用外部合约的函数，并不修改当前合约的状态变量。
    function calculatePower(uint256 base,uint256 exponent) public view returns(uint256){
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        uint256 result = scientificCalc.power(base, exponent);
        return result;
    }

    //调用科学计算器合约的平方根函数，低级调用
    //没用view修饰符
    function calculateSquareRoot(uint256 number) public returns(uint256){
        require(number >= 0, "Cannot calculate square root of negative number");
        //ABI 代表**应用程序二进制接口** 。你可以把它看作是合同的"通信协议"——它定义了当一方合同调用另一方时数据必须如何结构化。
        //在使用高级函数调用（如 `otherContract.someFunction()`）时，Solidity 会为你处理 ABI 编码。但使用低级调用时， **必须手动处理** 。
        //### **`abi.encodeWithSignature` 构建了 EVM 在调用特定函数时期望的确切二进制格式。
        //"squareRoot(int256)" 是完整的函数签名（名称+参数类型）。number 是我们作为参数传递的值。
        //结果是字节数组 (bytes memory)，其中包含在区块链上调用该函数所需的所有信息。
        bytes memory data = abi.encodeWithSignature("squareRoot(int256)", int256(number));//使用ABI编码函数调用数据，指定函数签名和参数
        //.call(data) 将这些数据发送到存储在 scientificCalculatorAddress 中的地址。
        //- 它返回两件事：
            //- `success`（一个布尔值，告诉我们调用是否成功）
            //- `returnData`（一个字节数组，包含函数返回的内容）
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);//使用call函数调用外部合约，传递编码后的数据，并获取调用结果
        //始终检查通话是否成功。如果出现错误（签名错误、地址错误、函数未找到等）， success将为假——我们将停止执行并显示一条有用的错误消息。
        require(success, "External call failed");//检查调用是否成功，如果失败则抛出错误
        //将原始返回数据解码回可用值 — 在这个例子中，是一个 uint256
        uint256 result = abi.decode(returnData, (uint256)); //解码返回数据，获取函数的返回值，这里我们期望返回一个uint256类型的结果
        return result; 

    }


}