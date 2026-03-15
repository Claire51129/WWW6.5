// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {//创建一个叫TiJar的合约
	address public owner;
//记录合约主人地址
	uint256 public totalTipsReceived;
//收到的小费总额用整数类型
	// Example: if 1 USD = 0.0005 ETH, then the rate would be 5 * 10^14 wei per 1 unit of USD.
	mapping(string => uint256) public conversionRates;
//新增一个叫汇率转换的映射，把string类型映射到整数，货币代码映射到兑ETH的汇率
	// Total ETH contributed by each tipper (in wei)
	mapping(address => uint256) public tipPerPerson;
//新增一个叫tipPerPerson的映射，把每个人地址映射整数，每个人给了多少小费
	// List of supported currency codes (e.g., "USD", "EUR", "JPY")
	string[] public supportedCurrencies;
//新增一个数组叫支持的货币列表，用string类型
	// Total contributed per currency:
	// - For "ETH": amount is in wei
	// - For fiat codes: amount is in the original unit passed into tipInCurrency
	mapping(string => uint256) public tipsPerCurrency;
//新增一个映射叫tipsPerCurrency，string类型映射到整数，每种货币收到多少钱？
	constructor() {//构造函数，部署的时候自动执行
		owner = msg.sender;

		// Rates are expressed as: 1 unit of currency => X wei
		addCurrency("USD", 5 * 10 ** 14); // 1 USD = 0.0005 ETH
		addCurrency("EUR", 6 * 10 ** 14); // 1 EUR = 0.0006 ETH
		addCurrency("JPY", 4 * 10 ** 12); // 1 JPY = 0.000004 ETH
		addCurrency("INR", 7 * 10 ** 12); // 1 INR = 0.000007 ETH
		//预设四种货币的汇率，
	}

	modifier onlyOwner() {//修饰符只有所有者可以
		require(msg.sender == owner, "Only owner can perform this action");
		_;
	}

	// Add or update a supported currency conversion rate (to wei)
	function addCurrency(string memory _currencyCode, uint256 _rateToWei) 
	//wei是ETH最小的单位
	//新增一个addCurrency增加货币的功能，参数是存在memory的货币代码，
	//还有整数类型的_rateToWei也就是汇率
	public onlyOwner {
	//只有所有者可以新增货币类型
		require(_rateToWei > 0, "Conversion rate must be greater than 0");
//要求这个_rateToWei大于0，这个是汇率
		bool currencyExists = false;
		//布尔函数，检查货币是否已存在
		for (uint256 i = 0; i < supportedCurrencies.length; i++) {
		// for循环 = 一个个检查（开始；条件；每一圈做完之后）
		//创建计数器 i，从0开始，条件：只要 i 小于列表长度，就继续循环
		//列表有5个货币，i最大到4
		//i++ 每次循环结束，i 加1
			if (keccak256(bytes(supportedCurrencies[i]))//货币列表里的第i个
			//keccak256就是把任何内容变成唯一的固定长度的ID
			//byte把文字转成电脑能读的格式
			 == keccak256(bytes(_currencyCode))) {
			 //完全等于这个
				currencyExists = true;
				//这个函数就结果为true
				break;//找到了！后面的不用看了
			}
		}

		if (!currencyExists) {
		//如果货币不存在
			supportedCurrencies.push(_currencyCode);
			//把这个_currencyCode推进去supportedCurrencies这个数组
		}
		conversionRates[_currencyCode] = _rateToWei;
		//把__rateToWei赋值到在汇率转换映射里面包含的_currencyCode里面
	}

	// Convert a given amount of a supported currency into wei
	function convertToWei(string memory _currencyCode, 
	//新增一个功能convertToWei，算某金额货币换算ETH
	//参数是string类型，存在memory的货币代码
	uint256 _amount) public view returns (uint256) {
	//参数是整数的金额
	//公开，只查询，返回类型是整数类型
		uint256 rate = conversionRates[_currencyCode];
		//用_currencyCode这个查询conversionRates这个映射对应到的汇率
		require(rate > 0, "Currency not supported");
		//要求汇率大于0
		return _amount * rate;
    //返回金额*汇率的结果
		// If you ever want to show human-readable ETH in your frontend, divide by 10^18.
	}
	// Send a tip in ETH directly (msg.value is in wei)
	//直接以ETH发小费？
	
	function tipInEth() external payable {
	//新增一个tipInEth功能，external = 只能外部调用（合约内部不能调）
	//给别人
		require(msg.value > 0, "Tip amount must be greater than 0");
//要求当前这个金额大于0，msg.value = 这次交易转了多少钱（全局变量）
		tipPerPerson[msg.sender] += msg.value;
		//在这个人的记录上，加上他这次给的钱
		totalTipsReceived += msg.value;
//总共收了多少小费
		tipsPerCurrency["ETH"] += msg.value; // 每种货币收了多少ETH类型的钱的记录表
	}

	// Tip using a currency code; caller sends the exact converted wei as msg.value
	function tipInCurrency(string memory _currencyCode, 
	//新增一个功能
	uint256 _amount) external payable {
	//
		require(conversionRates[_currencyCode] > 0, "Currency not supported");
		//检查：这种货币支持吗
		require(_amount > 0, "Amount must be greater than 0");
    //检查：金额不能为0
		uint256 weiAmount = convertToWei(_currencyCode, _amount);
		//计算：X货币 = 多少wei
		require(msg.value == weiAmount, "Sent ETH doesn't match the converted amount");
    //检查：你付的ETH = 应付款吗
		tipPerPerson[msg.sender] += msg.value;
		//记账：这个人给了多少
		totalTipsReceived += msg.value;
    //记账：总计增加
		tipsPerCurrency[_currencyCode] += _amount; // original units
	}  //记账：这种货币收了XX（不是ETH数）

	function withdrawTips() external onlyOwner {
	//老板取走所有小费
		uint256 contractBalance = address(this).balance;
		//看看合约里有多少ETH
		require(contractBalance > 0, "No tips to withdraw");
    //没钱就不能取
		(bool success, ) = payable(owner).call{ value: contractBalance }("");
		//把全部ETH转给老板
    //success记录成功还是失败
		require(success, "Transfer failed");
    //转账失败就报错
		totalTipsReceived = 0;
	}  //把小费总额归零（账本清零）
//以下get函数都是用来查数据
	function transferOwnership(address _newOwner) external onlyOwner {
		require(_newOwner != address(0), "Invalid address");
		owner = _newOwner;
	}

	function getSupportedCurrencies() external view returns (string[] memory) {
		return supportedCurrencies;
	}

	function getContractBalance() external view returns (uint256) {
		return address(this).balance;
	}

	function getTipperContribution(address _tipper) external view returns (uint256) {
		return tipPerPerson[_tipper];
	}

	function getTipsInCurrency(string memory _currencyCode) external view returns (uint256) {
		return tipsPerCurrency[_currencyCode];
	}

	function getConversionRate(string memory _currencyCode) external view returns (uint256) {
		require(conversionRates[_currencyCode] > 0, "Currency not supported");
		return conversionRates[_currencyCode];
	}
}