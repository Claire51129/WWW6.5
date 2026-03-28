// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


/// @title Automated Market Maker with Liquidity Token
contract AutomatedMarketMaker is ERC20 {
    // 两个变量存储 AMM 将管理的 ERC-20 代币的地址
    IERC20 public tokenA;
    IERC20 public tokenB;
// 整个 AMM 逻辑 —— 兑换、价格、LP 份额 —— 都依赖于知道池中每种代币的数量。
    uint256 public reserveA;
    uint256 public reserveB;

    address public owner;
// 添加代币
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    // 移除池中流动性
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
//    兑换
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);
/**
- AMM 支持哪些代币
- LP 代币的名称
- 谁部署了合约
1. `_tokenA`：第一种 ERC-20 代币的地址（例如 DAI）
2. `_tokenB`：第二种 ERC-20 代币的地址（例如 USDC）
3. `_name`：LP 代币名称（例如 “DAI-USDC LP Token”）
4. `_symbol`：LP 代币符号（例如 “DAIUSDC-LP”）
**/
    constructor(address _tokenA, address _tokenB, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }


    /// 添加流动性 – 喂入池子
    /**
     允许用户通过存入等值金额的 Token A 和 Token B 来向池子添加流动性
     这些 LP 代币就像一张证明你为池子做出了贡献的“收据”，也是你在池子里的代币份额的声明
     **/
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");
// 将代币转入池子
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);
// 计算要铸造的 LP 代币
        uint256 liquidity;
        if (totalSupply() == 0) {
            liquidity = sqrt(amountA * amountB);
        } else {
            liquidity = min(
                amountA * totalSupply() / reserveA,
                amountB * totalSupply() / reserveB
            );
        }

        _mint(msg.sender, liquidity);

        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
    }

    //移除流动性 – 提取你的份额
    function removeLiquidity(uint256 liquidityToRemove) external returns (uint256 amountAOut, uint256 amountBOut) {
        require(liquidityToRemove > 0, "Liquidity to remove must be > 0");
        require(balanceOf(msg.sender) >= liquidityToRemove, "Insufficient liquidity tokens");

        uint256 totalLiquidity = totalSupply();
        require(totalLiquidity > 0, "No liquidity in the pool");

        amountAOut = liquidityToRemove * reserveA / totalLiquidity;
        amountBOut = liquidityToRemove * reserveB / totalLiquidity;

        require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves for requested liquidity");

        reserveA -= amountAOut;
        reserveB -= amountBOut;

        _burn(msg.sender, liquidityToRemove);

        tokenA.transfer(msg.sender, amountAOut);
        tokenB.transfer(msg.sender, amountBOut);

        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);
        return (amountAOut, amountBOut);
    }

    /// 用 A 交换 B
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
        require(amountAIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        uint256 amountAInWithFee = amountAIn * 997 / 1000;
        uint256 amountBOut = reserveB * amountAInWithFee / (reserveA + amountAInWithFee);

        require(amountBOut >= minBOut, "Slippage too high");

        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        reserveA += amountAInWithFee;
        reserveB -= amountBOut;

        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    ///  用 B 交换 A —— 反向交易
    function swapBforA(uint256 amountBIn, uint256 minAOut) external {
        require(amountBIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        uint256 amountBInWithFee = amountBIn * 997 / 1000;
        uint256 amountAOut = reserveA * amountBInWithFee / (reserveB + amountBInWithFee);

        require(amountAOut >= minAOut, "Slippage too high");

        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        reserveB += amountBInWithFee;
        reserveA -= amountAOut;

        emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }

   
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

// 辅助函数 – 小工具，大用途
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
//  sqrt(): 巴比伦平方根算法
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
