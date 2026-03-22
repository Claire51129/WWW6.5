//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

//多币种打赏与汇率换算、统计与提现
//Solidity 仅适用于整数，本合约的单位使用wei，如果用eth为单位，小数位数后的都会损失
contract TipJar {
    address public owner;
    uint256 public totalTipsReceived;

    mapping(string => uint256) public conversionRates;//货币兑换率
    mapping(address => uint256) public tipPerPerson; //每个人的总金额
    string[] public supportedCurrencies;//支持的货币列表
    mapping(string => uint256) public tipsPerCurrency; //每种货币的总金额

    constructor() {
            owner = msg.sender;
            //1 eth = 10**18 wei
            addCurrency("USD",5 * 10**14); //1美元=0.0005以太
            addCurrency("EUR",6 * 10**14); //1欧元=0.0006以太
            addCurrency("JPY",4 * 10**12); //1日元=0.000004以太
            addCurrency("INR",7 * 10**12); //1英镑=0.000007以太

    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function addCurrency(string memory _currencyCode,uint256 _rateToEth) public onlyOwner {
        require(_rateToEth >0,"Conversion rate must be greater than 0");
        bool currencyExists = false; //检查货币是否已经存在
        for (uint i = 0;i<supportedCurrencies.length;i++){
            //比较字符串是否相等，使用keccak256哈希函数进行比较
            //在 Solidity 中，不能像在 JavaScript 或 Python 中那样直接使用 == 比较两个字符串。这是因为 Solidity 中的字符串是存储在内存中的复杂类型，而不是原始值。
            //使用 bytes(...)然后将这些字节传递给 keccak256() — 的内置加密哈希函数。这为我们提供了每个字符串的唯一指纹
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))){
                currencyExists = true;
                break;//脱离本循环
            }
        }
        if (!currencyExists){
            supportedCurrencies.push(_currencyCode); //如果货币不存在，则添加到支持的货币列表中
        }
        conversionRates[_currencyCode] = _rateToEth; //设置货币兑换率，已存在的更新兑换率


    }

    //转换货币金额为以太金额 单位wei
    function convertToEth(string memory _currencyCode,uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        uint256 ethAmount = _amount * conversionRates[_currencyCode]; //根据兑换率计算以太金额
        return ethAmount;
    }

    //直接使用以太币 单位wei
    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0");
        tipPerPerson[msg.sender] += msg.value; //更新每个人的金额
        totalTipsReceived += msg.value; //更新总金额
        tipsPerCurrency["ETH"] += msg.value; //更新以太币的总金额
    }

    //使用其他货币
    function tipInCurrency(string memory _currencyCode,uint256 _amount) public payable{
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");
        uint256 ethAmount = convertToEth(_currencyCode, _amount); //将货币金额转换为以太金额
        //函数检查msg.value 即随交易发送的实际 ETH是否与预期金额匹配。
        //确保收到的 ETH 完全符合我们根据货币输入的预期金额。这是一个安全措施，防止用户发送错误的金额或试图利用合约的漏洞。
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount"); //确保发送的以太金额与转换后的金额匹配
        tipPerPerson[msg.sender] += ethAmount; //更新每个人的金额
        tipsPerCurrency[_currencyCode] += _amount; //更新每种货币的总金额
        totalTipsReceived += ethAmount; //更新总金额
    }
    
    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance; //获取合约中的以太金额
        require(contractBalance > 0, "No tips to withdraw");
        (bool success,) = payable(owner).call{value: contractBalance}(""); //将合约中的以太金额转移给所有者
        require(success, "Transfer failed"); //确保转账成功
        totalTipsReceived = 0; //重置总金额
        /*for (uint i = 0;i<supportedCurrrencies.length;i++){
            tipsPerCurrency[supportedCurrrencies[i]] = 0; //重置每种货币的总金额
        }*/
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner; //转移合约所有权
    }

    function getSupportedCurrencies() public view  returns (string[] memory) {
        return supportedCurrencies; //返回支持的货币列表   
        
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance; //返回合约中的以太金额
    }

    function getTipperContribution(address _tipper) public view returns (uint256) {
        return tipPerPerson[_tipper]; //返回指定地址的贡献金额
    }

    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode]; //返回指定货币的总金额
    }

    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode]; //返回指定货币的兑换率
    }

}