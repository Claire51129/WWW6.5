
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19; //此行锁定要使用 Solidity 版本 0.8.19 或更高版本编译的合约，但 不是 0.9.0 或更高版本。它确保兼容性并避免未来版本的中断性更改。
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";// Chainlink 的标准预言机接口——用于获取价格信息或在我们的例子中模拟降雨等数据
import "@openzeppelin/contracts/access/Ownable.sol";
contract MockWeatherOracle is AggregatorV3Interface, Ownable {
    uint8 private _decimals; //数据的精度,降雨量以整毫米为单位
    string private _description; //Feed 的文字标签（如名称）
    uint80 private _roundId; //于模拟不同的数据更新周期（每一轮都是新的读数）
    uint256 private _timestamp; //记录上次更新发生的时间
    uint256 private _lastUpdateBlock; //跟踪上次更新发生时的block，用于添加随机性
    constructor() Ownable(msg.sender) {
    _decimals = 0;
    _description = "MOCK/RAINFALL/USD";
    _roundId = 1; //从第 1 轮开始
    _timestamp = block.timestamp; 
    _lastUpdateBlock = block.number;
    }
    function decimals() external view override returns (uint8) {
    return _decimals;
    }
    function description() external view override returns (string memory) {
    return _description; //人类可读的源描述
    }
    function version() external pure override returns (uint256) {
    return 1;
    }
    function getRoundData(uint80 _roundId_)
    external
    view
    override
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound){
    return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_); // answeredInRound 的轮次 ID 相同
    //在真正的预言机中，startedAt 和 updatedAt可能不同。我们在这里简化它
    }
    function latestRoundData()
    external
    view
    override
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound){
    return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }
    // 唯一区别在于_roundId_和_roundId
    //场景 A：即时报价（使用 latestRoundData）如果你在写一个保险合约，规定“如果现在降雨量超过 100ml 就赔付”，你只需要调用 latestRoundData()。它反应的是当下的现实
    //场景 B：时间敏感性验证（使用 getRoundData）假设用户在 1 小时前提交了一个申请，你想核实 1 小时前的那一刻 降雨量是多少，而不是现在的。此时你就需要根据当时的 roundId 去调用 getRoundData(_roundId)。
    function _rainfall() public view returns (int256) {
    uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;//自上次更新以来经过的区块数
    uint256 randomFactor = uint256(keccak256(abi.encodePacked( //使用安全哈希函数keccak256进行哈希处理
        block.timestamp, //当前时间
        block.coinbase, // 矿工地址（一些熵）
        blocksSinceLastUpdate
    ))) % 1000; //使用 % 1000将结果转换为 0-999 之间的整数

    return int256(randomFactor);
    }
    function _updateRandomRainfall() private {
    _roundId++;
    _timestamp = block.timestamp;
    _lastUpdateBlock = block.number;
    } //更新id用于模拟新的数据
    function updateRandomRainfall() external {
    _updateRandomRainfall(); //任何人都可以调用的 public 函数来更新“预言机”数据
}




}