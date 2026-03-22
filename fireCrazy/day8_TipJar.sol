// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    address public owner; 
    
    // 汇率账本：货币代码 => 兑换 1 单位该货币需要的 Wei 数量
    mapping(string => uint256) public conversionRates; 
    string[] public supportedCurrencies; // 支持的货币列表

    // 统计数据
    uint256 public totalTipsReceived; // 总共收到了多少 Wei
    mapping(address => uint256) public tipperContributions; // 每个人打赏了多少
    mapping(string => uint256) public tipsPerCurrency; // 每种法币名义上收到了多少

    // 保安亭
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action"); 
        _;
    }

    // 部署时，把自己设为社长，并初始化几个常见汇率
    constructor() {
        owner = msg.sender;
        // 注意：这里的数字都已经转换成了 Wei 的精度
        addCurrency("USD", 5 * 10**14); 
        addCurrency("EUR", 6 * 10**14);
    }

    // --- 核心功能 1：录入/更新汇率 ---
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Conversion rate must be greater than 0");
        
        // 检查货币是否已经存在（使用 keccak256 魔法比较字符串）
        bool currencyExists = false;
        for (uint i = 0; i < supportedCurrencies.length; i++) {
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }
        
        // 如果是新货币，加入列表
        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }
        
        // 更新汇率账本
        conversionRates[_currencyCode] = _rateToEth;
    }

    // 计算法币对应的 Wei 数量
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return _amount * conversionRates[_currencyCode]; 
    }

    // --- 核心功能 2：打赏通道 ---
    
    // 通道 A：直接打赏 ETH
    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0");
        tipperContributions[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }

    // 通道 B：按法币金额打赏（强制匹配系统）
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");
        
        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        
        // 保安检查：你发送的真钱 (msg.value) 必须和算出来的 Wei 完全一致！ 
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");
        
        tipperContributions[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount; // 记录名义上的法币数字
    }

    // --- 管理员功能 (文档后半部分) ---

    // 提现全部打赏
    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance; // 获取合约里的所有钱 
        require(contractBalance > 0, "No tips to withdraw");
        
        // 再次使用最安全的 call 方法发钱给社长
        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Transfer failed");
        
        totalTipsReceived = 0; // 重置记账本
    }

    // 权力交接：转移社长身份
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address"); // 防止把合约变成无主孤儿
        owner = _newOwner;
    }
}
