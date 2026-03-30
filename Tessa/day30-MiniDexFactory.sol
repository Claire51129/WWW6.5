// // 迷你版去中心化交易所（Mini DEX）——MiniDexFactory：专门负责“创建新的交易对池子”的工厂(造游泳池的人)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";   ////这个合约有一个“主人/管理员”，只有 owner 才能执行某些特殊操作
import "./day30-MiniDexPair.sol";    // 假设MiniDexPair.sol在同一目录中(因为工厂等下要用它来 new MiniDexPair(...)，也就是创建新的池子)

contract MiniDexFactory is Ownable {   //它继承 Ownable，说明它有 owner 机制
    event PairCreated(address indexed tokenA, address indexed tokenB, address pairAddress, uint);   //创建交易对时发出通知,记录：tokenA&B、新池子地址、它在数组里的编号

    mapping(address => mapping(address => address)) public getPair;   //二维映射，相当于查询表，输入两种代币地址，得到它们对应的池子地址。如getPair[USDC][ETH] => 某个 Pair 地址，etPair[ETH][USDC] => 也是同一个 Pair 地址
    address[] public allPairs;    //定义一个地址数组，保存所有已经创建过的pair池子地址，类似“池子名单”

    constructor(address _owner) Ownable(_owner) {}    //部署工厂时，要传入一个owner地址，并把该地址交给ownable作为管理员(即这个工厂是谁的，一开始就确定了)

    // 创建交易对
    function createPair(address _tokenA, address _tokenB) external onlyOwner returns (address pair) {   //定义一个函数：创建新的交易对池子,输入_tokenA/B，输出新创建的池子地址 pair
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid token address");   //要求两个代币地址都不能是零地址
        require(_tokenA != _tokenB, "Identical tokens");    //要求两个代币不能是同一个
        require(getPair[_tokenA][_tokenB] == address(0), "Pair already exists");    //要求这对代币之前还没有对应池子(如果已经有了，就不能重复创建)

        // 为一致性排序代币——不管你传进来的是 A,B 还是 B,A，都统一排序成固定顺序
        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);   //如果 _tokenA 地址比 _tokenB 小，就让token0 = _tokenA，token1 = _tokenB，否则反过来

        pair = address(new MiniDexPair(token0, token1));   //直接部署一个新的 MiniDexPair 合约，传入两种币地址，然后拿到它的地址，保存到 pair。就像工厂里真正“造出了一个新池子”
        getPair[token0][token1] = pair;    //把正向查询记进去：token0 + token1 => 这个 pair 地址
        getPair[token1][token0] = pair;    //再把反向查询也记进去：token1 + token0 => 还是这个 pair 地址
        // 这样无论怎么输入顺序，都能查到同一个池子

        allPairs.push(pair);   //把这个新池子地址加入总名单数组
        emit PairCreated(token0, token1, pair, allPairs.length - 1);    //发出“池子创建成功”的事件。最后那个 allPairs.length - 1 表示：它在数组里的索引位置。比如这是第 1 个池子，那索引是 0
    }

    // 查看池子总数
    function allPairsLength() external view returns (uint) {   //定义一个只读函数，查看一共创建了多少个交易对池子
        return allPairs.length;    //返回数组长度
    }

    // 按编号查看池子地址
    function getPairAtIndex(uint index) external view returns (address) {   //定义一个函数，按索引查询某个池子地址，如index = 0，拿第一个池子，index = 1，拿第二个池子
        require(index < allPairs.length, "Index out of bounds");    //要求索引不能越界，例如池子只有0、1、2，你查3就会报错
        return allPairs[index];    //返回指定位置的池子地址
    }
}





// 该份factory合约不是交易池本身，而是专门负责“制造池子”(造池子的工厂)
// Q: 为什么池子里必须有两种币? A:因为这是“交易对池”，比如A/B 池子，就是：你可以拿 A 换 B，也可以拿 B 换 A，所以池子必须同时装着两边的币。
// LP：像“股份证明”。你给池子提供了资金，系统就给你记一个份额。以后别人来交易，池子收手续费，这些价值会体现在池子里。你拿 LP 赎回时，就能按比例拿走你的那部分。
// 为什么加流动性要讲比例？因为池子里两边币的比例决定价格。你突然只往里加很多 A，不加 B，价格结构就会被你破坏。所以系统要求新增流动性尽量按原池子比例来
// 为什么 swap 后价格会变？因为换币会改变池子里的储备数量。例如原来池子里 A=100, B=100，你拿 10A 换走一些 B，换完后，池子可能变成：A=110,B=91。A多了B少了，所以B变得更“贵”
// 为什么有手续费？因为流动性提供者不是白白借池子给别人用的。别人换币时，池子收一点手续费，算是给 LP 的奖励来源之一。这里写的是 0.3%。
// 为什么要防重入？因为合约里有转账操作。如果不防，有些恶意合约可能在收到钱时，立刻再次钻进函数里重复取钱。nonReentrant 就像：“这个房间一次只准一个人进，门锁没开完之前别人不能再进。”
// Factory 和 Pair 有什么区别？Factory：负责造池子、记池子列表，Pair：负责池子里的资金逻辑；Factory 像“开发商”，Pair 像“具体房子”
// 【一句话总结】MiniDexFactory 做什么？——它是工厂，负责：创建新的 Pair 池子、防止重复创建同一交易对、保存所有池子地址、方便查询已有池子
