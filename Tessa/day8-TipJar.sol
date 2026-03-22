// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    address public owner;

    uint256 public totalTipsReceived;

    // 汇率表(仅表头）
    mapping(string => uint256) public conversionRates;


    // 每个人打赏了多少钱： 钱包地址 对应 金额(eth)
    mapping(address => uint256) public tipPerPerson;
    string[] public supportedCurrencies; // 货币列表
    mapping(string => uint256) public tipsPerCurrency; // 每种货币打赏多少 eg: USD收到多少

    constructor() {    // 初始化-合约刚创建时自动运行，如开店第一天准备
        owner = msg.sender; // 调用者的钱包地址
        addCurrency("USD", 5 * 10**14); // 1 USD = 0.0005 ETH
        addCurrency("EUR", 6 * 10**14); // 1 EUR = 0.0006 ETH
        addCurrency("JPY", 4 * 10**12); // 1 JPY = 0.000004 ETH
        addCurrency("INR", 7 * 10**12); // 1 INR = 0.000007 ETH
    }

    modifier onlyOwner() {   // 权限控制：只有老板能做这件事eg取钱、添加货币等
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // 添加或更新货币 add or update a supported currency
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Conversion rate must be greater than 0");   // 检查汇率是否大于0
        bool currencyExists = false;  // 检查汇率是否已经存在
        for (uint i = 0; i < supportedCurrencies.length; i++) {   // 检查货币是否已经存在，如果不存在就加入列表；for为循环
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }
        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);   // 如果不存在就加入列表
        }
        conversionRates[_currencyCode] = _rateToEth;    //保存汇率
    }

    // 货币转换：把其它货币换算成ETH
    function converToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;
        // 如果要看到以太币in your frontend, 要把结果除以10^18
    }

    // 用ETH直接发送小费
    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0");    // require 为检查， 发送的ETH数量必须大于零
        tipPerPerson[msg.sender] += msg.value;    // 记录这个人打赏了多少
        totalTipsReceived += msg.value;      //   更新总数
        tipsPerCurrency["ETH"] += msg.value;       //  每种货币的ETH收到多少
    }

    // 用其他货币打赏
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supporter");    // 检查货币是否支持
        require(_amount >0, "Amount must be greater than 0");    // 检查金额是否大于0
        uint256 ethAmount = converToEth(_currencyCode, _amount);    //  计算ETH等值
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");    // 检查发送ETH是否正确
        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    // owner取钱
    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance;    // 检查合约余额
        require(contractBalance > 0, "No tips to withdraw");    
        (bool success, ) = payable(owner).call{value: contractBalance}("");    // 把所有钱转给owner
        require(success, "Transfer failed");
        totalTipsReceived = 0;
    }

    // owner权转让
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    // 查询支持货币
    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
    }


    // 查询余额
    function getContractBalance() public view returns (uint256){
        return address(this).balance;
    }


    // 查询某人打赏（贡献值）
    function getTipPerContribution(address _tipper) public view returns (uint256) {
        return tipPerPerson[_tipper];
    }


    function gerTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];
    }


    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }
}





// 1 创建一个打赏罐
// 2 支持多种货币(可直接转ETH，也可间接转USD,EUR,JPY,INR)
// 3 自动换算ETH
// 4 记录谁打赏了多少钱
// 5 老板可以取钱