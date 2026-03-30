// SPDX-License-Identifier: MIT
// 代码开源协议：MIT协议，大家可以随便用。

pragma solidity ^0.8.20;
// 这个合约需要用Solidity 0.8.20及以上版本编译。

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// 导入ERC20接口，用于操作代币的转账、余额查询。

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// 导入重入攻击防护，防止黑客在转账过程中反复调用合约。

contract MiniDexPair is ReentrancyGuard {
// 定义一个合约叫"迷你DEX交易对"，它继承自ReentrancyGuard（防重入保护）。

    address public immutable tokenA;
    // 交易对中的第一个代币地址。immutable表示部署后不能改，节省gas。

    address public immutable tokenB;
    // 交易对中的第二个代币地址。immutable表示部署后不能改。

    uint256 public reserveA;
    // 资金池中tokenA的储备量（当前合约持有的tokenA数量）。

    uint256 public reserveB;
    // 资金池中tokenB的储备量（当前合约持有的tokenB数量）。

    uint256 public totalLPSupply;
    // LP代币的总供应量。LP代币代表流动性提供者的份额。

    mapping(address => uint256) public lpBalances;
    // 每个地址持有的LP代币数量。LP代币记录谁提供了多少流动性。

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpMinted);
    // 添加流动性事件：谁，添加了多少tokenA，多少tokenB，获得了多少LP代币。

    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpBurned);
    // 移除流动性事件：谁，取回了多少tokenA，多少tokenB，销毁了多少LP代币。

    event Swapped(address indexed user, address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount);
    // 兑换事件：谁，用什么代币换了什么代币，各换了多少。

    constructor(address _tokenA, address _tokenB) {
        // 构造函数，部署时运行一次。设置两个代币的地址。

        require(_tokenA != _tokenB, "Identical tokens");
        // 检查：两个代币地址不能相同（不能是同一个代币对）。

        require(_tokenA != address(0) && _tokenB != address(0), "Zero address");
        // 检查：两个代币地址都不能是0地址。

        tokenA = _tokenA;
        // 设置tokenA地址。

        tokenB = _tokenB;
        // 设置tokenB地址。
    }

    // 实用工具
    function sqrt(uint y) internal pure returns (uint z) {
        // 平方根函数（巴比伦算法/牛顿迭代法）。
        // internal：只能被合约内部调用。pure：不读取也不修改状态。

        if (y > 3) {
            // 如果y大于3
            z = y;
            // z初始等于y
            uint x = y / 2 + 1;
            // x = y/2 + 1
            while (x < z) {
                // 当x小于z时循环
                z = x;
                // z更新为x
                x = (y / x + x) / 2;
                // 牛顿迭代公式：x_new = (y/x_old + x_old) / 2
            }
        } else if (y != 0) {
            // 如果y是1,2,3
            z = 1;
            // 平方根是1
        }
        // 如果y=0，z默认就是0
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        // 取最小值函数。返回a和b中较小的那个。

        return a < b ? a : b;
        // 如果a小于b，返回a，否则返回b（三元运算符）。
    }

    function _updateReserves() private {
        // 更新储备量函数。从合约实际余额读取最新的储备。
        // private：只能被合约内部调用。

        reserveA = IERC20(tokenA).balanceOf(address(this));
        // 读取合约当前持有的tokenA余额，更新reserveA。

        reserveB = IERC20(tokenB).balanceOf(address(this));
        // 读取合约当前持有的tokenB余额，更新reserveB。
    }

    function addLiquidity(uint256 amountA, uint256 amountB) external nonReentrant {
        // 添加流动性函数。用户同时存入两种代币，获得LP代币。
        // nonReentrant防止重入攻击。

        require(amountA > 0 && amountB > 0, "Invalid amounts");
        // 检查：两种代币的数量都必须大于0。

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        // 从调用者钱包转出amountA个tokenA到合约。

        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
        // 从调用者钱包转出amountB个tokenB到合约。

        uint256 lpToMint;
        // 声明变量，记录要铸造多少LP代币。

        if (totalLPSupply == 0) {
            // 如果这是第一次添加流动性（LP总供应量为0）
            lpToMint = sqrt(amountA * amountB);
            // LP代币数量 = sqrt(数量A × 数量B)
            // 这是Uniswap V2的公式，确保初始价格 = amountA/amountB
        } else {
            // 如果不是第一次添加
            lpToMint = min(
                (amountA * totalLPSupply) / reserveA,
                (amountB * totalLPSupply) / reserveB
            );
            // 根据你添加的两种代币数量，分别计算应该获得的LP代币数量，取较小值
            // 公式：LP = min(添加的A × 总LP ÷ 池子A, 添加的B × 总LP ÷ 池子B)
            // 这样可以确保添加的比例和现有池子比例一致
        }

        require(lpToMint > 0, "Zero LP minted");
        // 检查：铸造的LP代币数量必须大于0。

        lpBalances[msg.sender] += lpToMint;
        // 增加调用者的LP代币余额。

        totalLPSupply += lpToMint;
        // 增加LP代币总供应量。

        _updateReserves();
        // 更新储备量（从合约余额读取最新值）。

        emit LiquidityAdded(msg.sender, amountA, amountB, lpToMint);
        // 发出添加流动性事件。
    }

    function removeLiquidity(uint256 lpAmount) external nonReentrant {
        // 移除流动性函数。销毁LP代币，取回两种代币。

        require(lpAmount > 0 && lpAmount <= lpBalances[msg.sender], "Invalid LP amount");
        // 检查：要销毁的LP数量必须大于0，且不超过调用者的LP余额。

        uint256 amountA = (lpAmount * reserveA) / totalLPSupply;
        // 计算能取回多少tokenA：
        // 公式 = (你销毁的LP ÷ 总LP) × 池子里tokenA的总量
        // 你占的份额比例 × tokenA总量

        uint256 amountB = (lpAmount * reserveB) / totalLPSupply;
        // 计算能取回多少tokenB：
        // 公式 = (你销毁的LP ÷ 总LP) × 池子里tokenB的总量

        lpBalances[msg.sender] -= lpAmount;
        // 减少调用者的LP余额。

        totalLPSupply -= lpAmount;
        // 减少LP总供应量。

        IERC20(tokenA).transfer(msg.sender, amountA);
        // 把tokenA转给调用者。

        IERC20(tokenB).transfer(msg.sender, amountB);
        // 把tokenB转给调用者。

        _updateReserves();
        // 更新储备量（从合约余额读取最新值）。

        emit LiquidityRemoved(msg.sender, amountA, amountB, lpAmount);
        // 发出移除流动性事件。
    }

    function getAmountOut(uint256 inputAmount, address inputToken) public view returns (uint256 outputAmount) {
        // 计算兑换输出量的函数。给定输入数量和输入代币，返回能换出多少输出代币。

        require(inputToken == tokenA || inputToken == tokenB, "Invalid input token");
        // 检查：输入代币必须是tokenA或tokenB中的一个。

        bool isTokenA = inputToken == tokenA;
        // 判断输入的是不是tokenA。

        (uint256 inputReserve, uint256 outputReserve) = isTokenA ? (reserveA, reserveB) : (reserveB, reserveA);
        // 根据输入代币类型，设置输入储备和输出储备。
        // 如果输入tokenA，则输入储备=reserveA，输出储备=reserveB
        // 如果输入tokenB，则输入储备=reserveB，输出储备=reserveA

        uint256 inputWithFee = inputAmount * 997;
        // 扣除0.3%手续费。997/1000 = 0.997，即扣除0.3%后的输入量。
        // 注意：这里用乘法代替除法，后面会处理。

        uint256 numerator = inputWithFee * outputReserve;
        // 分子 = (输入量 × 997) × 输出储备

        uint256 denominator = (inputReserve * 1000) + inputWithFee;
        // 分母 = (输入储备 × 1000) + (输入量 × 997)

        outputAmount = numerator / denominator;
        // 输出量 = 分子 ÷ 分母
        // 公式等价于：输出 = (输入 × 997 × 输出储备) ÷ (输入储备 × 1000 + 输入 × 997)
    }

    function swap(uint256 inputAmount, address inputToken) external nonReentrant {
        // 兑换函数。用户用inputAmount个inputToken换取输出代币。

        require(inputAmount > 0, "Zero input");
        // 检查：输入数量必须大于0。

        require(inputToken == tokenA || inputToken == tokenB, "Invalid token");
        // 检查：输入代币必须是tokenA或tokenB中的一个。

        address outputToken = inputToken == tokenA ? tokenB : tokenA;
        // 确定输出代币：如果输入tokenA，输出就是tokenB；反之亦然。

        uint256 outputAmount = getAmountOut(inputAmount, inputToken);
        // 调用getAmountOut计算能换出多少输出代币。

        require(outputAmount > 0, "Insufficient output");
        // 检查：输出数量必须大于0。

        IERC20(inputToken).transferFrom(msg.sender, address(this), inputAmount);
        // 从调用者钱包转出inputAmount个输入代币到合约。

        IERC20(outputToken).transfer(msg.sender, outputAmount);
        // 把计算出的outputAmount个输出代币转给调用者。

        _updateReserves();
        // 更新储备量（从合约余额读取最新值）。

        emit Swapped(msg.sender, inputToken, inputAmount, outputToken, outputAmount);
        // 发出兑换事件。
    }

    // 查看函数
    function getReserves() external view returns (uint256, uint256) {
        // 查看当前储备量。

        return (reserveA, reserveB);
        // 返回(reserveA, reserveB)
    }

    function getLPBalance(address user) external view returns (uint256) {
        // 查看某个地址持有的LP代币数量。

        return lpBalances[user];
        // 返回用户的LP余额。
    }

    function getTotalLPSupply() external view returns (uint256) {
        // 查看LP代币总供应量。

        return totalLPSupply;
        // 返回总供应量。
    }
}
// 合约结束