// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19; //此行锁定要使用 Solidity 版本 0.8.19 或更高版本编译的合约，但 不是 0.9.0 或更高版本。它确保兼容性并避免未来版本的中断性更改。
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";// Chainlink 的标准预言机接口——用于获取价格信息或在我们的例子中模拟降雨等数据
import "@openzeppelin/contracts/access/Ownable.sol";

contract CropInsurance is Ownable{
    AggregatorV3Interface private weatherOracle;
    AggregatorV3Interface private ethUsdPriceFeed;

    uint256 public constant RAINFALL_THRESHOLD = 500;
    uint256 public constant INSURANCE_PREMIUM_USD = 10;
    uint256 public constant INSURANCE_PAYOUT_USD = 50;

    mapping(address => bool) public hasInsurance; // 是否有保险了
    mapping(address => uint256) public lastClaimTimestamp; //上次投保时间

    event InsurancePurchased(address indexed farmer, uint256 amount);
    event ClaimSubmitted(address indexed farmer);//发出 ClaimSubmitted事件
    event ClaimPaid(address indexed farmer, uint256 amount);
    event RainfallChecked(address indexed farmer, uint256 rainfall);

    //此特殊函数在部署合约时运行一次
    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender) {
        weatherOracle = AggregatorV3Interface(_weatherOracle); //这是我们的降雨预言机的地址
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed); //这是 Chainlink 价格馈送的地址
    }
    
    function purchaseInsurance() external payable {
    uint256 ethPrice = getEthPrice(); //使用 Chainlink 获取 ETH 的当前美元价格
    uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e18) / ethPrice; //将 10 美元的溢价转换为 ETH（乘以  1e18 以获得 wei 精度

    require(msg.value >= premiumInEth, "Insufficient premium amount"); //检查用户是否发送了足够的 ETH
    require(!hasInsurance[msg.sender], "Already insured"); //防止用户两次购买保险

    hasInsurance[msg.sender] = true; //用户标记为已投保
    emit InsurancePurchased(msg.sender, msg.value); //发出前端可以监听的事件
    }
    function checkRainfallAndClaim() external {
    require(hasInsurance[msg.sender], "No active insurance");
    require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 24h between claims"); //间强制执行1 天的冷却，以避免垃圾邮件
    (
        uint80 roundId,
        int256 rainfall,
        ,
        uint256 updatedAt,
        uint80 answeredInRound
    ) = weatherOracle.latestRoundData(); //使用 解构 来忽略不需要的值
    require(updatedAt > 0, "Round not complete");
    require(answeredInRound >= roundId, "Stale data");
    //确保预言机数据是最新且有效的
    uint256 currentRainfall = uint256(rainfall); //将降雨量转换为无符号格式， Chainlink 等预言机为了通用性，统一将数值定义为 int256（有符号整数）。通过 uint256(rainfall)，你是在告诉编译器：“我已经确认这个数值是安全的，请把它当作无符号整数来处理。”
    emit RainfallChecked(msg.sender, currentRainfall);
    if (currentRainfall < RAINFALL_THRESHOLD) {
        lastClaimTimestamp[msg.sender] = block.timestamp;
        emit ClaimSubmitted(msg.sender);
        uint256 ethPrice = getEthPrice();////使用 Chainlink 获取 ETH 的当前美元价格
        uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e18) / ethPrice;
        (bool success, ) = msg.sender.call{value: payoutInEth}("");
        //{value: payoutInEth}大括号语法，用于指定随调用发送的以太币数量（单位是 Wei）。
        //括号内是发送给目标地址的 数据（Payload）。因为这里只是简单的转账，不需要调用目标合约的任何函数，所以传空字符串 ""。
        //call 默认转发所有剩余 Gas,返回 false，由程序员决定如何处理
        require(success, "Transfer failed");
         emit ClaimPaid(msg.sender, payoutInEth);
         }
    }
    function getEthPrice() public view returns (uint256) {
    (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
    return uint256(price);
    }
    //这是 Solidity 的**解构赋值（Destructuring Assignment）**语法。latestRoundData() 函数会返回 5 个值：roundId, answer, startedAt, updatedAt, answeredInRound。通过留空，你可以告诉编译器：“除了第二个值（price），其他的我都不要。” 这样可以节省内存空间，让代码更简洁。
    function getCurrentRainfall() public view returns (uint256) {
    (, int256 rainfall, , , ) = weatherOracle.latestRoundData();
    return uint256(rainfall);
    }
    function withdraw() external onlyOwner {
    payable(owner()).transfer(address(this).balance); //让合约所有者提取所有收集的 ETH（例如，未使用的溢价）
    }
    receive() external payable {} //该函数允许合约无需调用函数接收 ETH。
    function getBalance() public view returns (uint256) {
    return address(this).balance;
    }

}

