// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    address public owner; // 管理员

    mapping(string => uint256) public conversionRates; // 操作记录
    string[] public supportedCurrencies;  // 支持的货币 u -> eth

    uint256 public totalTipsReceived; // 记录合约收到的所有小费总额（wei）


    mapping(address => uint256) public tipperContributions; // 记录每个地址累计支付的总 ETH（以 wei 计）
    mapping(string => uint256) public tipsPerCurrency; // 按法币种类统计用户指定的小费总额（以法币单位计，如美元金额）

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // 添加货币
    function addCurrency (string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        // 费率是否合法
        require(_rateToEth > 0, "must be greater than 0");

        // 用比较字符串的方法 检查货币是否存在
        bool currencyExists = false;
        // 这里不能用 = 因为会访问越界，导致交易回滚，这里会导致解析不通过 ！！！
        for(uint i = 0; i< supportedCurrencies.length; i++) {
            // keccak256 内置加密哈希函数
            if(keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }

        if(!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }

        conversionRates[_currencyCode] = _rateToEth;
    }

    constructor() {
        owner = msg.sender;

        addCurrency("USD", 5 * 10**14);
        addCurrency("EUR", 6 * 10**14);
        addCurrency("JPY", 4 * 10**12);
        addCurrency("GBP", 7 * 10**14);
        
    }

    // 在以太坊中，1 ETH = 10¹⁸ wei，wei 是以太坊中最小的单位。
    // 1 ETH = 1,000,000,000,000,000,000 wei = 10^18 wei

    // 转换成 wei 单位的  ETH
    // 任何少于 1 ETH 的东西都会四舍五入为 0 ——这是我们绝对不想要的。
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns(uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");

        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;
    }

    function tipInEth() public payable {
        // 防止用户发送 0 ETH 小费
        require(msg.value > 0, "must be greater than 0");

        tipperContributions[msg.sender] += msg.value;
        
        totalTipsReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }


    // 法币计价的小费支付
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");

        uint256  ethAmount = convertToEth(_currencyCode, _amount);
        // 这里不能用大于，要不就超额支付了，应该相等即可
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");

        tipperContributions[msg.sender] += ethAmount;
        totalTipsReceived += ethAmount;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    // 出金
    function withdrawTips() public onlyOwner {
        uint256 contractBalance  = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");

        (bool success,) = payable(owner).call{value: contractBalance}("");
        require(success, "failed");

        totalTipsReceived = 0;
    }

    // 转让所有权
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }


   
    function getSupportedCurrencies() public view returns(string[] memory) {
        return supportedCurrencies;
    }

    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
        
    }

    function getTipperContribution(address _tipper) public view returns(uint256) {
        return tipperContributions[_tipper];
    }
 }
