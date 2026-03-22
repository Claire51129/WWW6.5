// SPDX-License-Identifier: MIT
// 代码开源协议

pragma solidity ^0.8.19;
// 指定Solidity编译器版本

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// 导入 Chainlink 预言机接口
// 用于获取链下数据（天气、价格）

import "@openzeppelin/contracts/access/Ownable.sol";
// 导入 OpenZeppelin 的所有权管理
// 只有合约所有者可以调用某些函数

contract CropInsurance is Ownable {
// 定义一个合约，叫"农作物保险"
// is Ownable：继承所有权管理功能

    AggregatorV3Interface private weatherOracle;
    // 天气预言机接口（私有）
    // 用于获取降雨量数据
    
    AggregatorV3Interface private ethUsdPriceFeed;
    // ETH/USD 价格预言机接口（私有）
    // 用于获取 ETH 兑美元的价格

    uint256 public constant RAINFALL_THRESHOLD = 500;
    // 降雨量阈值常量（500毫米）
    // 如果降雨量低于500毫米，触发赔付
    
    uint256 public constant INSURANCE_PREMIUM_USD = 10;
    // 保险费用常量（10美元）
    // 农民需要支付10美元等值的ETH来购买保险
    
    uint256 public constant INSURANCE_PAYOUT_USD = 50;
    // 保险赔付常量（50美元）
    // 如果触发赔付，农民获得50美元等值的ETH

    mapping(address => bool) public hasInsurance;
    // 映射：地址 → 是否有保险
    // true = 已购买保险，false = 未购买
    
    mapping(address => uint256) public lastClaimTimestamp;
    // 映射：地址 → 最后一次索赔时间
    // 防止频繁索赔，每次索赔后需要等待24小时

    event InsurancePurchased(address indexed farmer, uint256 amount);
    // 事件：购买保险
    // farmer：农民地址，amount：支付的ETH金额
    
    event ClaimSubmitted(address indexed farmer);
    // 事件：提交索赔申请
    
    event ClaimPaid(address indexed farmer, uint256 amount);
    // 事件：已支付赔付
    // farmer：农民地址，amount：赔付的ETH金额
    
    event RainfallChecked(address indexed farmer, uint256 rainfall);
    // 事件：检查降雨量
    // farmer：农民地址，rainfall：当前降雨量

    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender) {
    // 构造函数：部署时自动执行
    // _weatherOracle：天气预言机地址
    // _ethUsdPriceFeed：ETH/USD价格预言机地址
    // payable：可以接收ETH（初始资金）
    // Ownable(msg.sender)：设置合约所有者为部署者
        
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        // 初始化天气预言机接口
        
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        // 初始化ETH/USD价格预言机接口
    }

    function purchaseInsurance() external payable {
    // 函数：购买保险
    // external payable：外部调用，可以附带ETH
        
        uint256 ethPrice = getEthPrice();
        // 获取当前ETH价格（美元）
        
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e18) / ethPrice;
        // 计算需要支付的ETH数量
        // INSURANCE_PREMIUM_USD = 10美元
        // * 1e18 是为了转换成 wei（1 ETH = 10^18 wei）
        // 除以 ethPrice 得到等值的ETH
        // 例如：ETH价格 = 2000美元，则 10 * 1e18 / 2000 = 5e15 wei = 0.005 ETH

        require(msg.value >= premiumInEth, "Insufficient premium amount");
        // 检查：支付的ETH是否足够（可以多付，但不找零）
        
        require(!hasInsurance[msg.sender], "Already insured");
        // 检查：这个农民还没有购买过保险

        hasInsurance[msg.sender] = true;
        // 标记该农民已购买保险
        
        emit InsurancePurchased(msg.sender, msg.value);
        // 发出购买保险事件
    }

    function checkRainfallAndClaim() external {
    // 函数：检查降雨量并索赔
    // 农民调用这个函数来检查是否触发赔付
        
        require(hasInsurance[msg.sender], "No active insurance");
        // 检查：必须有有效的保险
        
        require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 24h between claims");
        // 检查：距离上次索赔必须超过24小时
        // 防止频繁索赔

        (
            uint80 roundId,
            int256 rainfall,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = weatherOracle.latestRoundData();
        // 从天气预言机获取最新降雨量数据
        // roundId：轮次ID
        // rainfall：降雨量（带符号整数）
        // updatedAt：数据更新时间
        // answeredInRound：在哪一轮被回答

        require(updatedAt > 0, "Round not complete");
        // 检查：数据轮次已完成
        
        require(answeredInRound >= roundId, "Stale data");
        // 检查：数据不是过时的
        // answeredInRound >= roundId 表示数据是最新的

        uint256 currentRainfall = uint256(rainfall);
        // 将降雨量转换为无符号整数
        
        emit RainfallChecked(msg.sender, currentRainfall);
        // 发出降雨量检查事件

        if (currentRainfall < RAINFALL_THRESHOLD) {
        // 如果降雨量低于阈值（500毫米），触发赔付
        // 这意味着干旱，农作物受损
            
            lastClaimTimestamp[msg.sender] = block.timestamp;
            // 记录索赔时间
            
            emit ClaimSubmitted(msg.sender);
            // 发出索赔提交事件

            uint256 ethPrice = getEthPrice();
            // 获取当前ETH价格
            
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e18) / ethPrice;
            // 计算赔付的ETH数量
            // INSURANCE_PAYOUT_USD = 50美元
            // 除以当前ETH价格得到等值ETH

            (bool success, ) = msg.sender.call{value: payoutInEth}("");
            // 向农民发送ETH赔付
            // call{value: payoutInEth}：发送指定金额的ETH
            
            require(success, "Transfer failed");
            // 确保转账成功

            emit ClaimPaid(msg.sender, payoutInEth);
            // 发出赔付支付事件
        }
        // 如果降雨量 >= 500毫米，不触发赔付
        // 农民需要等待下次检查
    }

    function getEthPrice() public view returns (uint256) {
    // 函数：获取ETH当前价格（美元）
    // public view：公开只读函数
        
        (
            ,
            int256 price,
            ,
            ,
        ) = ethUsdPriceFeed.latestRoundData();
        // 从价格预言机获取最新ETH价格
        // 忽略其他返回值，只取price

        return uint256(price);
        // 将价格转换为无符号整数并返回
        // 例如：2000美元 → 返回 2000
    }

    function getCurrentRainfall() public view returns (uint256) {
    // 函数：获取当前降雨量（毫米）
    // public view：公开只读函数
        
        (
            ,
            int256 rainfall,
            ,
            ,
        ) = weatherOracle.latestRoundData();
        // 从天气预言机获取最新降雨量

        return uint256(rainfall);
        // 返回降雨量（0-999毫米）
    }

    function withdraw() external onlyOwner {
    // 函数：提取合约余额
    // onlyOwner：只有合约所有者能调用
        
        payable(owner()).transfer(address(this).balance);
        // 把合约里所有ETH转给所有者
        // owner()：继承自 Ownable，返回所有者地址
    }

    receive() external payable {}
    // receive函数：接收ETH时调用（无数据的情况）
    // 空实现，允许合约接收ETH

    function getBalance() public view returns (uint256) {
    // 函数：查看合约余额
    // public view：公开只读
        
        return address(this).balance;
        // 返回合约持有的ETH数量
    }
}