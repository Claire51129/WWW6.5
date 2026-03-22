//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar{
    address public owner;
    mapping(string => uint256) public conversionRates;
    string[] public supportedCurrencies;
    uint256 public totalTipsReceived;
    mapping(address => uint256) public tipPerContributions;
    mapping(string => uint256) public tipPerCurrency;

     //构造函数.
    //1 ETH = 1,000,000,000,000,000,000 wei = 10^18 wei
    constructor(){
        owner=msg.sender;
        addCurrency("USD",5*10**14);// 1 USD = 0.0005 ETH
        addCurrency("EUR",6*10**14);// 1 EUR = 0.0006 ETH
        addCurrency("JPY",4*10**12);// 1 JPY = 0.000004 ETH
        addCurrency("GBP",7*10**14);// 1 INR = 0.000007ETH
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    //设置货币转换-addcurrency（）
    function addCurrency (string memory _currencyCode, uint256 _rateToEth) public onlyOwner{
        require(_rateToEth>0, "Conversion rate must be greater than 0");
    //检查货币是否已经存在
        bool currencyExists=false;
    //避免两次添加相同的货币
    for (uint i = 0; i < supportedCurrencies.length; i++) {
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
    }
    }
//存储货币和汇率
   if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }
    //更新或设置转化率
    conversionRates[_currencyCode]=_rateToEth;
    }


    //转换为ETH（以wei为单位）
    function convertToEth(string memory _currencyCode, 
    uint256 _amount) public view returns (uint256){
        require(conversionRates[_currencyCode]>0, "Currency not supported");
        uint256 ethAmount=_amount*conversionRates[_currencyCode];
        return ethAmount;
        }

    //使用ETH打赏
    function tipInEth() public payable{
        require(msg.value>0,"TIp amount must be greater than o");
        tipPerContributions[msg.sender]+=msg.value;
        totalTipsReceived+=msg.value;
        tipPerCurrency["ETH"]+=msg.value;
    }
    //使用ETH以外的法币打赏
    function tipInCurrency(string memory _currencyCode,uint256 _amount) public payable{
        require(conversionRates[_currencyCode]>0,"Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");

        uint256 ethAmount=convertToEth(_currencyCode,_amount);
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");
        tipPerContributions[msg.sender]+=msg.value;
        totalTipsReceived+=msg.value;
        tipPerCurrency["_currencyCode"]+=_amount;
    }
    //提现小费
    function withdrawTips() public onlyOwner{
        uint256 contractBalance = address (this).balance;
        require(contractBalance>0,"No tips to withdraw");
        (bool success,)=payable(owner).call{value:contractBalance}("");
        require(success,"Transfer failed");
        totalTipsReceived=0;
        }
    //转让所有权
    function transferOwnership(address _newOwner) public onlyOwner{
    require(_newOwner!=address(0),"Invalid address");
    owner=_newOwner;
    }
    //读取储存在合约中的数据（view）
    //读取某人给的小费总数（wei为单位）——输入个人地址返回总贡献
    function getTipperContribution(address _tipper) public view returns(uint256){
        return tipPerContributions[_tipper];}

    function getSupportedCurencies() public view returns(string [] memory){
        return supportedCurrencies;}

    function getcontractBalance() public view returns(uint256){
        return address(this).balance;
    }
    function gettipInCurrency(string memory _currencyCode) public view returns(uint256){
        return tipPerCurrency[_currencyCode];
    }
    //检查货币兑换汇率
    function getConversionRate(string memory _currencyCode) public view returns(uint256){
        require(conversionRates[_currencyCode]>0,"Currency not supported");
        return conversionRates[_currencyCode];
    
    }
}