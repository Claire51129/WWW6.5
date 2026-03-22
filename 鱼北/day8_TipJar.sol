//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    address public owner;
    
    uint256 public totalTipsReceived;
    
    // 货币转换汇率
    mapping(string => uint256) public conversionRates;

    // 记录每个地址打赏数量
    mapping(address => uint256) public tipPerPerson;

    // 支持的货币列表及每种货币收到多少
    string[] public supportedCurrencies;  
    mapping(string => uint256) public tipsPerCurrency;
    
    // 构造函数，部署者为合约owner，添加支持的货币和汇率
    constructor() {
        owner = msg.sender;
        addCurrency("USD", 5 * 10**14);  // 1 USD = 0.0005 ETH
        addCurrency("EUR", 6 * 10**14);  // 1 EUR = 0.0006 ETH
        addCurrency("JPY", 4 * 10**12);  // 1 JPY = 0.000004 ETH
        addCurrency("INR", 7 * 10**12);  // 1 INR = 0.000007ETH
    }
    
    // 限制只有owner可执行
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    // 添加或更新支持的货币
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {

        // 验证汇率为正
        require(_rateToEth > 0, "Conversion rate must be greater than 0");

        // 创建布尔变量来检查货币是否存在
        bool currencyExists = false;

        // 循环浏览已添加货币列表并比较
        for (uint i = 0; i < supportedCurrencies.length; i++) {
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }

        // 如新，添加到supportedCurrencies列表，更新或设置汇率
        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }
        conversionRates[_currencyCode] = _rateToEth;
    }
    
    // 将某种货币金额转换为ETH，检查货币是否支持，根据汇率计算ETH数
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;

        // 如果前端需要显示 ETH，可以再除以 10^18 转成人类可读的 ETH
    }
    
    // 直接使用ETH打赏，金额需为正
    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0");

        // 记录打赏人贡献、更新打赏、记录ETH打赏金额
        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }

    // 用外币打赏，检查币种是否支持，金额需为正
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");

        // 转换为ETH
        uint256 ethAmount = convertToEth(_currencyCode, _amount);

        // 用户发送的ETH需等于计算后的ETH
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");

        // 记录打赏人贡献、更新打赏、记录该货币打赏金额
        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    // 提现：获取余额，要求为正，使用call转账，提现后重置
    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");
        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Transfer failed");
        totalTipsReceived = 0;
    }

    // 转移合约所有权，地址不为空
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    // 获取支持的货币列表
    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
    }
    
    // 获取当前余额
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    // 查询某地址打赏了多少
    function getTipperContribution(address _tipper) public view returns (uint256) {
        return tipPerPerson[_tipper];
    }
    
    // 查询某种货币收到的打赏
    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];
    }

    // 查询某种货币汇率，需为支持的货币
    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }
}