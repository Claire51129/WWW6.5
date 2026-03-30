// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


/// @title Automated Market Maker with Liquidity Token
contract AutomatedMarketMaker is ERC20 { // 自动化做市商
    IERC20 public tokenA;
    IERC20 public tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    address public owner;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);

    constructor(address _tokenA, address _tokenB, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    /// @notice Add liquidity to the pool
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");

        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        uint256 liquidity;
        uint256 totalLiquidity = totalSupply();
        if (totalLiquidity == 0) {
            liquidity = sqrt(amountA * amountB); //用于第一个添加流动性的人，公平地设定初始 LP 代币数量。—— 定价
        } else {
            liquidity = min(
                amountA * totalLiquidity / reserveA,
                amountB * totalLiquidity / reserveB
            ); // 相当于 min(amountA/reserveA,amountB/reserveB)*totalLiquidity. 当有人向已有流动性池添加代币时，我们希望根据哪个代币贡献较少来铸造 LP 代币 —— 确保池子的平衡与公平。
        }

        _mint(msg.sender, liquidity);

        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
    }

    /// @notice Remove liquidity from the pool
    function removeLiquidity(uint256 liquidityToRemove) external returns (uint256 amountAOut, uint256 amountBOut) {
        require(liquidityToRemove > 0, "Liquidity to remove must be > 0");
        require(balanceOf(msg.sender) >= liquidityToRemove, "Insufficient liquidity tokens");

        uint256 totalLiquidity = totalSupply();
        require(totalLiquidity > 0, "No liquidity in the pool");

        amountAOut = liquidityToRemove * reserveA / totalLiquidity;
        amountBOut = liquidityToRemove * reserveB / totalLiquidity;

        require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves for requested liquidity"); // 防止计算因四舍五入出现灰尘值，如果任何输出为 0，则拒绝交易 —— 避免出错或浪费提款。

        reserveA -= amountAOut;
        reserveB -= amountBOut;

        _burn(msg.sender, liquidityToRemove);

        tokenA.transfer(msg.sender, amountAOut);
        tokenB.transfer(msg.sender, amountBOut);

        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);
        return (amountAOut, amountBOut);
    }

    /// @notice Swap token A for token B
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
        require(amountAIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        uint256 amountAInWithFee = amountAIn * 997 / 1000; // 从输入代币中扣除 0.3% 手续费。比如输入 100 Token A，只用 99.7 参与交换。剩余的 0.3 保留在池子里，奖励流动性提供者。这个小额手续费可以防止滥用（如掉期合约），并让池子随时间增长，这有利于 LP。
        uint256 amountBOut = reserveB * amountAInWithFee / (reserveA + amountAInWithFee); 
        /** 确保交易后 x * y = k 大致保持不变. (x + dx) * (y - dy) = k，则 dy = y * dx / (x + dx).
            
            “大致”：
            （1）手续费让 $k$ 变大了：由于我们是用 amountAInWithFee（扣了 0.3% 的金额）来计算的，但用户实际存入的是全额 amountAIn。这意味着交易后的新乘积 $k_{new}$ 实际上会比旧的 $k_{old}$ 稍微大一点点。这对流动性提供者（LP）是好事，因为池子里的总价值增加了。
            （2）整数除法的精度损失：Solidity 不支持小数。在做 (y * dx) / (x + dx) 时，计算结果会向下取整（Floor）。冷知识：向下取整其实也是一种安全机制。它确保了用户拿走的 Token B 永远比理论值少那么一点点，从而保证合约里的钱永远够赔， $k$ 只增不减。
        
            “滑点”：
            代码通过这个特定的数学比例公式，倒推出了为了维持乘积不变，用户“有权”拿走的资产数量 dy。
            实际支付的平均单价为 P = dy/dx = y/(x+dx).
                如果你投入的 dx 极小，价格接近 y/x。
                如果你投入的 dx 极大，分母变大，你得到的 dy 增加速度会放缓，这就是**滑点**。
         */

        require(amountBOut >= minBOut, "Slippage too high"); // 检查**实际输出**是否符合用户期望。`minBOut` 是用户设置的最小可接受 Token B 数量。

        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        reserveA = tokenA.balanceOf(address(this)); 
        /** reserveA += amountAInWithFee：这让0.3%手续费成为躺在合约里的“死钱”了。
            reserveA += amountAIn：【凭据记账】让手续费金额也进到reserve里，同时k值增加，表示池子在赚钱，LP提取流动性时可以提取出更多，实现LP收益。
            现代码（模拟Uniswap V2）：【实地盘点】合约不相信参数，只相信自己金库里现有的代币总数。自动包含手续费，且能捕获任何通过非合约函数路径进入的资金。
                场景 A：通缩型代币 (Fee-on-transfer Tokens)
                    很多代币（如早期的 SAFEMOON）在转账时会扣除 5% 的燃烧费。用户调用 swap(100)，你记录 reserveA += 100。但实际上合约只收到了 95 个。
                场景 B：恶意直接转账 (Direct Transfer Attack)
                    有人直接向合约地址 transfer 了 1000 个 TokenA，而不通过本合约函数。使用 reserveA += amountAIn，reserve 变量完全感知不到这 1000 个币——这 1000 个币变成了“幽灵资金”，无法参与定价，也无法被 LP 取走。
                场景 C：精度误差与重入
                    在复杂的 DeFi 交互中，多次乘除法的精度损失可能导致 reserve 变量与 balance 产生微小偏差（1 wei 的差别）。balanceOf 每次都会将这种微小偏差清零，防止误差随时间累积。
            理论上每一次更新reserveA/B变量都通过balanceOf是更准确的。
         */
        reserveB -= amountBOut;

        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    /// @notice Swap token B for token A
    function swapBforA(uint256 amountBIn, uint256 minAOut) external {
        require(amountBIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        uint256 amountBInWithFee = amountBIn * 997 / 1000;
        uint256 amountAOut = reserveA * amountBInWithFee / (reserveB + amountBInWithFee);

        require(amountAOut >= minAOut, "Slippage too high");

        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        reserveB += amountBIn;
        reserveA -= amountAOut;

        emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }

    /// @notice View the current reserves
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    /// @dev Utility: Return the smaller of two values
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /// @dev Utility: Babylonian square root
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
