//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract TipJar{
    address public owner;

    uint256 public totalTipReceived;

    //ETH
    mapping(address => uint256) public tipperContributions;
    //非ETH
    mapping(string => uint256) public conversionRates;
    string[] supportedCurrencies;
    mapping(string => uint256) public tipsPerCurrency;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner{
        require(_rateToEth > 0 ,"Conversion rate must be greater than 0");

        //检查货币是否存在
        /*Solidity 中的字符串是存储在内存中的复杂类型，而不是原始值不能用==,用byte()显式转换为byte（字节流）格式
        keccak是内置加密哈希函数 能接收任意长度的输入，并产生一个**固定为 32 字节（bytes32）**的哈希值
        相当于一段文本的唯一指纹
        还有因为复杂类型 所以string必须指定存储方式是storage memory or calldata*/
        bool currencyExists = false;
        for(uint i=0; i<supportedCurrencies.length; i++){
            if(keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))){
                currencyExists = true;
                break;
            }
        }
        if(!currencyExists){
            supportedCurrencies.push(_currencyCode);
        }
        conversionRates[_currencyCode] = _rateToEth;
    }

    constructor(){
        owner = msg.sender;

        addCurrency("USD", 5 * 10**14);
        addCurrency("EUR", 6 * 10**14);
        addCurrency("JPY", 4 * 10**12);
        addCurrency("GBP", 7 * 10**14);
    }//solidity仅适用于整数 用除法处理wei会失去所有小数点

    function convertToEth(string memory _currencyCode, uint256 _amount)public view returns(uint256){
        require(conversionRates[_currencyCode] >0 , "Currency not supported");

        return  _amount * conversionRates[_currencyCode];
    }
    //error：’判断条件写成supportedCurrencies[_currencyCode]‘ 数组只能通过索引访问不能这样看是否存在 之前是bool映射
    //而且哈希化查找“是否存在”很耗gas

    function tipInEth()public payable{
        require(msg.value > 0, "Tips must be greater than 0");

        tipperContributions[msg.sender] += msg.value;
        totalTipReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }

    function tipInCurrency(string memory _currencyCode, uint256 _amount)public payable{
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");

        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");

        tipperContributions[msg.sender] += msg.value;
        totalTipReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    function withdrawTips()public onlyOwner{
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");

        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Withdrawal failed");

        totalTipReceived = 0;

    }
    /*1.`.call{value: ...}`  被认为是最安全、最灵活的发送 ETH 的方式： 
        - 即使接收者是智能合约，它也能正常工作（由于 gas 限制，某些合约拒绝`.transfer()`
        - 它返回一个 `success` 标志，以便我们可以检查传输是否有效
        - 它避免了与旧方法相关的一些限制和风险
    2.合约可以独立存储余额 通过address(this).balance来查找余额
    address(this)是一个内置函数 指合约的地址*/

    function transferOwnership(address _newOwner) public onlyOwner{
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    function getSupportedCurrencies()view public returns(string[] memory){
        return supportedCurrencies;
    }

    function getContractBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getTipperContribution(address _tipper) public view returns(uint256){
        return tipperContributions[_tipper];
    }

    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];
    }

    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }

}
