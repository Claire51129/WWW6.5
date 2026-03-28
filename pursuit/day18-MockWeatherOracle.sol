/** Oracle预言机——将现实世界数据加入合约
1. **`MockWeatherOracle.sol`** – 模拟 Chainlink 风格的预言机，随机生成降雨值。
2. **`CropInsurance.sol`** – 一个智能合约 :
    - 让农民支付溢价（以 ETH 计），
    - 监测降雨量，
    - 如果降雨量太低，则会自动支付。
 */


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; // AggregatorV3Interface: 这是 Chainlink 的标准预言机接口——用于获取价格信息或在我们的例子中模拟降雨等数据。
import "@openzeppelin/contracts/access/Ownable.sol"; // Ownable: OpenZeppelin 的一个助手，它为我们提供了所有权功能——包括  owner() 和onlyOwner 修饰符。——授予部署者管理员访问权限
// 编译后，在file > .deps里可以看到引用的合约

contract MockWeatherOracle is AggregatorV3Interface, Ownable {
    uint8 private _decimals; // 定义数据的精度。我们的是 0 ，因为降雨量以整毫米为单位
    string private _description; // Feed 的文字标签（如名称）
    uint80 private _roundId; // 用于模拟不同的数据更新周期（每一轮都是新的读数）
    uint256 private _timestamp; // 记录上次更新发生的时间
    uint256 private _lastUpdateBlock; // 跟踪上次更新发生时的块，用于添加随机性

    constructor() Ownable(msg.sender) { // 将部署者设置为管理员（部署合约的人）
        _decimals = 0; // Rainfall in whole millimeters
        _description = "MOCK/RAINFALL/USD";
        _roundId = 1;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number; // block.number 是一个全局变量，它代表了当前区块在区块链上的序号（高度）
    }

    // 以下函数来自Chainlink接口（Interface）。注意接口中没有 'virtual'，也没有花括号逻辑。本合约要实现它，必须重复一遍，写上 'override'（相当于保险栓），赋予花括号逻辑。注意接口原本的内容不可修改：接口的内容是死的，接口的实现是活的。
    function decimals() external view override returns (uint8) {
        return _decimals;
    } 
    // Chainlink 需要这个。它告诉应用程序预期的小数位数。我们返回0 。

    function description() external view override returns (string memory) {
        return _description;
    } 
    //提供人类可读的源描述。

    function version() external pure override returns (uint256) {
        return 1;
    } 
    // 这是我们模拟的1 版本。这主要是信息性的。

    function getRoundData(uint80 _roundId_)
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
    }
    /** 
    访问历史数据——用户输入指定轮次，它返回该轮次的数据：
    - 您请求的轮次 ID
    - 在真正的预言机中，会去查找历史档案。在这里的模拟器中，是现场调用了合约内部的随机数生成函数，给出了一个模拟的降雨值。
    - 两次相同的时间戳（在真正的预言机中，数据搜集和达成节点共识需要时间，因此`startedAt` 和 `updatedAt`很可能不同。我们在这里简化它——在模拟器里，我们假设数据生成和更新是同一时间。）
    - `answeredInRound` 的轮次 ID 相同。（在 Chainlink 体系中，这表示该数据是在哪一轮被最终确认的（通常等于 roundId）。预言机不是“一锤子买卖”，而是一个不断投票的过程。在去中心化网络中可能出现节点延迟，如果某一轮数据流产，会返回0；如果数据被延迟确认，则可能出现answeredInRound=roundId+1.）
     */

    /** CropInsurance 合约不调用getRoundData函数为什么这里还要实现它？
    1. 接口的“全家桶”协议（强制性） 
    接口（Interface）约束——
        AggregatorV3Interface 规定了 5 个函数，getRoundData 是其中之一。
        既然你的 MockWeatherOracle 声明了自己 is AggregatorV3Interface（我要做标准预言机），那么你就必须实现所有规定的函数。
        规则：在 Solidity 中，如果你少写了接口里的任何一个函数，编译器会认为你的合约是“残缺的”（Abstract），从而拒绝部署。
    2. 给“其他人”和“链下工具”用的 
    智能合约不是孤岛。虽然 CropInsurance 现在不查历史，但：
        前端网页：保险公司的官网可能需要展示“过去 7 天的降雨趋势图”，这时候网页程序（如 Ethers.js）就会调用 getRoundData 来抓取历史数据。
        其他合约：未来可能有另一个“农业贷款合约”上线，它需要根据去年的降雨记录来评估给农民的贷款额度，它就会调用这个函数。
        审计与透明度：任何人（包括农民）都可以随时通过这个函数核实：当初触发赔付的那一刻，预言机到底录入了什么值。

    3. 标准化与可替换性（插拔式设计） 
    这是区块链工程中最核心的思想。
    想象一下，如果以后你想把 MockWeatherOracle 换成 Chainlink 官方的真实预言机合约：
        官方合约肯定实现了 getRoundData。
        如果你的 Mock 合约不实现它，那么你的测试环境和生产环境就不对等。
        标准化 确保了你的 CropInsurance 合约无论接入谁的预言机，只要对方符合 AggregatorV3Interface 标准，代码一行都不用改，直接就能跑。
    在编写 MockWeatherOracle 时，你不是在为 CropInsurance 量身定做工具，而是在模拟一个标准的服务端点。    
     */

    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }
    /** 获取最新数据。它返回：
    - 当前轮次 ID
    - 随机降雨量值
    - 时间戳
    - 轮次 ID 确认
    此函数是 `CropInsurance` 合约将调用的函数，以获取当前降雨量。
     */

    // Function to get current rainfall with random variation
    function _rainfall() public view returns (int256) {
        // Use block information to generate pseudo-random variation
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.coinbase,
            blocksSinceLastUpdate
        ))) % 1000; // Random number between 0 and 999

        // Return random rainfall between 0 and 999mm
        return int256(randomFactor);
    }
    /** 以下是随机降雨背后的魔力：
    1. 我们计算自上次更新以来经过的区块数。
    2. 区块链是确定性的。为了让结果看起来“随机”，开发者找了三个随时间变化的变量：
        - `block.timestamp` — 当前区块的时间戳（秒）
        - `block.coinbase` — 挖出这个块的矿工（或验证者）地址
        - `blocksSinceLastUpdate` — 距离上次更新过去了多少个块
    3. abi.encodePacked 把这些不同类型的数据“打包”挤在一起，变成一串紧凑的字节码。
    4. 对上述打包的字节码使用安全哈希函数`keccak256`进行哈希处理。——“粉碎”
    5. % 1000：哈希值太大了，我们只需要 0 到 999 之间的数字。取模运算（除以 1000 取余数）能确保结果永远落在 [0, 999] 范围内。
    6. int256(...)：因为接口 AggregatorV3Interface 要求返回 int256，所以最后要把这个正整数强制转换成带符号整数，以符合“合同标准”。
    因此，每次调用此函数时，您都会得到一个新的伪随机降雨值——介于 **0 到 999mm** 之间。
    注意：这不是安全随机性。但对于模拟预言机来说，这完全没问题。
     */

    // Function to update random rainfall
    function _updateRandomRainfall() private {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }
    /** 一个辅助函数，用于：
        - 增加轮数（模拟新数据）
        - 记录新数据的创建时间
        这将在现实生活中由 Chainlink 节点完成。在这里，我们手动模拟它。
     */
    /** 为什么要先写一个private函数，而不是将逻辑直接放进下面的函数里？
        考虑代码复用（其他函数也需要调用这个函数）和安全性/防御性编程（读写分离，人为疏忽等）
    */

    // Function to force update rainfall (anyone can call)
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
    /** 用户可以通过“获取最新降雨量”等 UI 按钮调用此函数来更新“预言机”数据，这对于测试或模拟新的一天很有用。
     */
}


/** 关于uint80：我以为都是2的指数幂。

不，Solidity 支持所有从 uint8 到 uint256 且步长为 8 的类型（即 uint8, uint16, uint24, ... uint256）。

1. 为什么以 8 为增量？ 
以太坊的底层设计是面向字节的。在计算机世界中，1 个字节等于 8 位（1 Byte = 8 bits）。
    内存对齐：计算机处理数据时，按字节寻址是最自然、最高效的方式。
    数据紧凑性：如果支持 uint7 或 uint9，硬件和编译器在处理这些“不对齐”的位数时会变得异常复杂且缓慢。
    一致性：Solidity 的类型系统反映了底层存储的结构。既然最小的可寻址单位是 1 字节（8 位），那么所有大一点的类型自然就是 8 的倍数（2 字节、3 字节……直到 32 字节）。

2. 为什么不是 2 的指数幂（16, 32, 64...）？
虽然很多编程语言（如 C 或 Java）主要使用 16、32、64 位，但 Solidity 提供 24、40、48 等类型是为了极致的存储压缩（Storage Packing）。
在以太坊上，存储（Storage）是最昂贵的资源。
    EVM 的一个存储插槽（Slot）固定是 256 位（32 字节）。
    如果你有三个变量，大小分别是 80 位、80 位、96 位，它们加起来正好是 $80 + 80 + 96 = 256$ 位。
    结果：这三个变量可以“挤”进同一个存储插槽中，只收你一份钱。如果只能用 128 或 256 位，你就必须支付更多的 Gas 费。

总结一下：
    8 的倍数：是为了和底层“字节”单位对齐，方便计算。
    非 2 的幂（如 uint80）：是为了让你在有限的 256 位空间里，像玩俄罗斯方块一样，灵活地拼凑数据以节省昂贵的 Gas。
*/
