//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    // 合约的拥有者（管理员）地址
    address public owner;
    
    // 记录收到的打赏总金额
    uint256 public totalTipsReceived;
    
    // 汇率映射表：记录法币（如USD）到ETH的汇率
    // 例如，若 1 USD = 0.0005 ETH，则此处存储的数值为 5 * 10^14（单位为wei）
    mapping(string => uint256) public conversionRates;

    // 记录每个地址对应的打赏金额
    mapping(address => uint256) public tipPerPerson;
    
    // 当前支持的代币/货币列表
    string[] public supportedCurrencies;  // List of supported currencies
    
    // 记录每种货币对应的累计打赏总数
    mapping(string => uint256) public tipsPerCurrency;
    
    // 构造函数：部署智能合约时仅执行一次的初始化逻辑
    constructor() {
        owner = msg.sender; // 将合约部署操作的调用者设定为合约所有者(owner)
        // 初始化预设的各货币对ETH的转换汇率
        addCurrency("USD", 5 * 10**14);  // 1 USD = 0.0005 ETH
        addCurrency("EUR", 6 * 10**14);  // 1 EUR = 0.0006 ETH
        addCurrency("JPY", 4 * 10**12);  // 1 JPY = 0.000004 ETH
        addCurrency("INR", 7 * 10**12);  // 1 INR = 0.000007 ETH
    }
    
    // 自定义修饰符（modifier）：用于函数执行前校验前置条件
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action"); // 限制仅合约管理员可调用
        _; // 执行被修饰函数的后续逻辑
    }
    
    // 增加或更新支持的币种及对应汇率（Add or update a supported currency）
    // 该函数挂载onlyOwner修饰符，仅管理员可修改系统汇率
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Conversion rate must be greater than 0");
        bool currencyExists = false;
        for (uint i = 0; i < supportedCurrencies.length; i++) {
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }
        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }
        conversionRates[_currencyCode] = _rateToEth;
    }
    
    // 核心换算模块：根据法币代码和金额，计算对应的ETH数量（单位为wei）
    // 'view' 标识该函数仅读取链上状态（conversionRates），不修改任何状态变量
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        uint256 ethAmount = _amount * conversionRates[_currencyCode]; // 按汇率转换为Wei单位
        return ethAmount;
        // 前端展示可读的ETH数值时，需将结果除以 10^18：If you ever want to show human-readable ETH in your frontend, divide the result by 10^18
    }
    
    // 直接发送ETH进行打赏（Send a tip in ETH directly）
    // payable 关键字：标记函数可接收随交易发送的以太币（金额通过msg.value获取）
    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0"); // msg.value 为交易附带的ETH金额（单位：wei）
        tipPerPerson[msg.sender] += msg.value; // 累加该地址的累计打赏额度
        totalTipsReceived += msg.value; // 累加合约收到的打赏总金额
        tipsPerCurrency["ETH"] += msg.value; // 累加ETH币种的累计打赏金额
    }
    
    // 根据指定货币类型计算所需ETH金额，并完成打赏
    // 参数说明：_currencyCode为法币代码，_amount为该法币的打赏金额
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");
        
        // 预计算该法币金额对应的wei数量
        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        
        // 安全校验：确保用户发送的ETH金额（wei）与换算结果一致，避免金额错误
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");
        
        tipPerPerson[msg.sender] += msg.value; // 记录该地址的累计打赏金额
        totalTipsReceived += msg.value; // 汇总到合约总打赏金额
        tipsPerCurrency[_currencyCode] += _amount; // 按法币类型统计累计打赏金额
    }

    // 提现函数：管理员提取合约内所有ETH资产至自己的地址
    function withdrawTips() public onlyOwner {
        // address(this).balance：获取合约当前的ETH余额（即合约内的可用资金）
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw"); // 确保合约内有可提现的资金
        
        // 将owner地址转为payable类型，通过底层call方法转账（避免transfer的gas限制问题）
        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Transfer failed"); // 转账失败则回滚交易，保障资金安全
        
        totalTipsReceived = 0; // 提现完成后重置累计打赏总金额
    }
  
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
    }
    

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
   
    function getTipperContribution(address _tipper) public view returns (uint256) {
        return tipPerPerson[_tipper];
    }
    

    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];
    }

    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }
}