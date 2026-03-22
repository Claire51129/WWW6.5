// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//Chainlink 的标准预言机接口——用于获取价格信息或在我们的例子中模拟降雨等数据
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
//OpenZeppelin 的一个助手，它为我们提供了所有权功能——包括  owner() 和onlyOwner 修饰符
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockWeatherOracle is AggregatorV3Interface, Ownable {//可以继承多个合约，接口放左边，权限/功能合约放右边
    uint8 private _decimals;//小数位数
    string private _description;//描述文字
    uint80 private _roundId;//模拟不同的数据更新周期。如：第一次播报、第二次播报
    uint256 private _timestamp;//记录上次更新的时间
    uint256 private _lastUpdateBlock;//跟踪上次更新发生时的块，用于添加随机性

    constructor() Ownable(msg.sender) {//将部署合约者设置为管理员
        _decimals = 0; //小数为0，降雨不需要小数，例如342毫米
        _description = "MOCK/RAINFALL/USD";//用来标记是什么数据
        _roundId = 1;//从第一轮开始
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;//区块链号码
    }

    //因为用了Chainlink接口，以下为使用接口必须写要求重写的函数
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function description() external view override returns (string memory) {
        return _description;
    }

    function version() external pure override returns (uint256) {//不读不储存数据，只返回数字的就用pure
        return 1;
    }
    
    //获取某一轮的数据
    function getRoundData(uint80 _roundId_)
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
        //这里用int256是因为Chainlink接口规定的，这个接口不止可以用在降雨，也可以用在温度，温度就有负数
    {
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
        //返回：第几轮，降雨量，时间戳，第几轮回答的
    }

    //获取最新数据
    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    //随机生成降雨量
    function _rainfall() public view returns (int256) {
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;//计算距离上次更新过了多少区块
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(//randomFactor是随机因子
            block.timestamp,
            block.coinbase,
            blocksSinceLastUpdate
        ))) % 1000; // 将以上三个信息整合打包转换成一个哈希值   % 1000保证数值再0-999之间

        return int256(randomFactor);
    }

    //更新随机降雨量
    function _updateRandomRainfall() private {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    // 强制跟新降雨量 任何人都可以调用
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}