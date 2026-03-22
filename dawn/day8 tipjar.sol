// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    address public owner;//记录钱包所有者的钱包地址
    mapping(string => uint256) public conversionRates;//这是一块汇率牌，映射左边的货币名称与右边的兑换ETH的数字比例。
    string[] public supportedCurrencies;
    uint256 public totalTipsReceived;
    mapping(address => uint256) public tipperContributions;
    mapping(string => uint256) public tipsPerCurrency;
    event Tipreceived(address indexed tipper, string currency,uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        addCurrency("ETH", 1 ether);
    }
    
    // 添加支持的货币
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {//需要提供货币名字和汇率，然后只允许老板操作。
        bool exists = false;//先设条件判决结果，这个货币不存在。
        for (uint i = 0; i < supportedCurrencies.length; i++) {//开启循环，将支持的货币名单从第零行翻到最后一行，每翻一行I加一。
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {//如果两个字符串相等
                exists = true;
                break;//打断循环
            }
        }
        
        if (!exists) {
            supportedCurrencies.push(_currencyCode);//就把新的货币填入名单最后一行。
        }
        
        conversionRates[_currencyCode] = _rateToEth;//把货币的汇率登记上去
    }
    
    // 货币转换为ETH
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        uint256 rate = conversionRates[_currencyCode];
        require(rate > 0, "Currency not supported");
        return (_amount * 1 ether) / rate;//这个是一个只看不改的功能，如果去查汇率牌的汇率查不到等于零就报错，不支持该货币。如果查得到就报出来，结果是数量乘以ETH除以汇率就等于这个货币当前的ETH值。
    }
    
    // 直接ETH小费
    function tipInEth() public payable {
        require(msg.value > 0, "Must send ETH");
        
        totalTipsReceived += msg.value;
        tipperContributions[msg.sender] += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
        emit Tipreceived(msg.sender, "ETH", msg.value);//这里可以投ETH的小费，payable就是直接打赏ETH，然后这个打赏值必须大于0，否则是提示必须发送ETH，然后会把发送的价值加到总小费里面、加到小费贡献值里面、加到每个货币的小费窗口。
    }
    
    // 其他货币小费
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");
        
        totalTipsReceived += ethAmount;
        tipperContributions[msg.sender] += ethAmount;
        tipsPerCurrency[_currencyCode] += _amount;
        emit Tipreceived(msg.sender, "_currenyCode", _amount);//这里输入其她货币的数额以及币种，然后去调用汇率计算器算出来的ETH必须跟我们塞入的货币算出的ETH必须相等，相等了之后才分三条路记账。
    }
    
    // 提取小费
    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");//只有所有人才能按的操作，要确定这一个存钱罐里的钱赋值到这个合同存款里，需要这个合同存款的数额大于0，否则提示没有小费可以取出。
        
        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Transfer failed");//把合约里面所有的钱打包寄给owner，如果失败的话，就报错退回。
    }
    
    // 转移所有权
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;//owner把所有权转给新的owner，只有owner可以操作，同时需要新的钱包地址不等于0。
    }
    
    // 查询函数
    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
    }
    
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    function getTipperContribution(address _tipper) public view returns (uint256) {
        return tipperContributions[_tipper];
    }
    
    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];
    }
    
    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        return conversionRates[_currencyCode];
    }

}