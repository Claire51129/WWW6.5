// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//change 其他货币-->ETH

contract TipJar{
    address public owner;
    mapping(string => uint256) public conversionRates;
    string[] public supportedCurrencies;
    uint256 public totalTipsReceived;
    mapping (address => uint256) public tipperContributions;
    mapping(string => uint256) public tipsPerCurrency;

    modifier onlyOwner(){
        require(msg.sender==owner, "Only owner can perform this action");
        _;
    }
         bool currencyExists =false;
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner{
        require(_rateToEth>0,"Conversion rate must be greater than 0");
        for(uint i=0; i< supportedCurrencies.length; i++){//循环check 是否有货币重合
            if(keccak256(bytes(supportedCurrencies[i]))==keccak256(bytes(_currencyCode))){
                //现有货币是否=输入货币，将输入值转为bytes，传递给哈希函数
                currencyExists=true;
                break;
            }
        }
        if (!currencyExists){//if !currencyExists=true;--> currencyExists=false
        //当（）的值为true时，if函数运行；而初始状态：currencyExists=false；因此要+！
            supportedCurrencies.push(_currencyCode);
        }
        conversionRates[_currencyCode] =_rateToEth;
    }
    constructor(){
        owner=msg.sender;
        addCurrency("USD", 5*10**14);//0.0005ETH;每一次addcurrency，跑一次function;10**14=10^14 wei
        addCurrency("EUR", 6*10**14);
        addCurrency("JPY", 4*10**12);//0.000005ETH
        addCurrency("GBP", 7*10**14);
    }
    function convertToEth(string memory _currencyCode, uint256 _amount)public view returns(uint256){
        require(conversionRates[_currencyCode]>0, "currency not supported");

        uint256 ethAmount= _amount * conversionRates[_currencyCode];
        return ethAmount;
    }

    function tipInEth()public payable{
        require(msg.value>0, "tip amount must be greater than 0");

        tipperContributions[msg.sender] += msg.value;
        totalTipsReceived +=msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }

    function tipInCurrencry(string memory _currencyCode, uint256 _amount) public payable{
        require(conversionRates[_currencyCode] >0, "currency not supported");
        require(_amount > 0, "Amount must be grester than 0");
        uint256 ethAmount= convertToEth(_currencyCode, _amount);
        require(msg.value == ethAmount,"Sent ETH doesn't match the converted amount");
        tipperContributions[msg.sender] +=msg.value;
        totalTipsReceived +=msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    function withdrawTips() public onlyOwner{
        uint256 contractBalance = address(this).balance; //获取当前余额
        require(contractBalance>0, "No tips to withdraw");
        (bool success,) =payable (owner).call{value:contractBalance} ("");//发送全部余额
        require(success, "transfer failed");
        totalTipsReceived=0; //余额归0
    }

    function transferOwnerShip(address _newOwner) public onlyOwner{
        require(_newOwner != address(0), "Invalid address");
        owner=_newOwner;
    }

    function getSupportedCurrencies() public view returns (string[] memory){
        return supportedCurrencies;
    }

    function getContractBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getTipperContribution(address _tipper) public view returns(uint256) {
        return tipperContributions[_tipper];
    }

    function getTipsInCuttency(string memory _currencyCode) public view returns (uint256){
        return tipsPerCurrency[_currencyCode];
    }

    function getConversionRate(string memory _currencyCode) public view returns (uint256){
        require(conversionRates[_currencyCode]>0, "currency not supported");
        return conversionRates[_currencyCode];
    }


}


