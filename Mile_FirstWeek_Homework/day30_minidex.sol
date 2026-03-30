// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title MiniDEX
 * @dev 实现了基于恒定乘积公式 (x * y = k) 的去中心化交易所
 * 文件名: day30_minidex.sol
 */
contract day30_minidex is ReentrancyGuard {
    // 代币池结构
    struct Pool {
        uint256 reserve0;
        uint256 reserve1;
        uint256 totalLiquidity;
        mapping(address => uint256) lpBalances;
    }

    // 存储代币对池（为了简化，这里固定一对代币）
    IERC20 public token0;
    IERC20 public token1;
    
    uint256 public reserve0;
    uint256 public reserve1;
    uint256 public totalSupply; // 总 LP 供应量
    mapping(address => uint256) public balanceOf; // 用户的 LP 余额

    event LiquidityAdded(address indexed provider, uint256 amount0, uint256 amount1, uint256 lpTokens);
    event LiquidityRemoved(address indexed provider, uint256 amount0, uint256 amount1, uint256 lpTokens);
    event Swap(address indexed trader, address tokenIn, uint256 amountIn, uint256 amountOut);

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    // ================= 核心算法 =================

    /**
     * @dev 获取输出金额 (扣除 0.3% 手续费)
     * 公式: Δy = (y * Δx) / (x + Δx)
     */
    function getAmountOut(uint256 amountIn, uint256 resIn, uint256 resOut) public pure returns (uint256) {
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * resOut;
        uint256 denominator = (resIn * 1000) + amountInWithFee;
        return numerator / denominator;
    }

    // ================= 流动性管理 =================

    /**
     * @dev 添加流动性
     */
    function addLiquidity(uint256 amount0Desired, uint256 amount1Desired) external nonReentrant returns (uint256 lpTokens) {
        token0.transferFrom(msg.sender, address(this), amount0Desired);
        token1.transferFrom(msg.sender, address(this), amount1Desired);

        if (totalSupply == 0) {
            lpTokens = sqrt(amount0Desired * amount1Desired);
        } else {
            uint256 share0 = (amount0Desired * totalSupply) / reserve0;
            uint256 share1 = (amount1Desired * totalSupply) / reserve1;
            lpTokens = share0 < share1 ? share0 : share1;
        }

        require(lpTokens > 0, "Insufficient liquidity minted");
        
        balanceOf[msg.sender] += lpTokens;
        totalSupply += lpTokens;
        reserve0 += amount0Desired;
        reserve1 += amount1Desired;

        emit LiquidityAdded(msg.sender, amount0Desired, amount1Desired, lpTokens);
    }

    // ================= 交易功能 =================

    /**
     * @dev Token0 换 Token1
     */
    function swap0for1(uint256 amount0In, uint256 minAmount1Out) external nonReentrant {
        uint256 amount1Out = getAmountOut(amount0In, reserve0, reserve1);
        require(amount1Out >= minAmount1Out, "Slippage error");

        token0.transferFrom(msg.sender, address(this), amount0In);
        token1.transfer(msg.sender, amount1Out);

        reserve0 += amount0In;
        reserve1 -= amount1Out;

        emit Swap(msg.sender, address(token0), amount0In, amount1Out);
    }

    // ================= 工具函数 =================

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