// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 手动定义必要的 ERC20 接口，无需 import 外部库
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

/**
 * @title 自动化做市商 (AMM) 极简打卡版
 */
contract AutomatedMarketMaker {
    IERC20 public tokenA;
    IERC20 public tokenB;

    uint256 public reserveA;
    uint256 public reserveB;
    uint256 public totalLiquidity; // 代替 ERC20 的 totalSupply
    mapping(address => uint256) public liquidityBalances; // 代替 ERC20 的 balance

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    // 1. 添加流动性
    function addLiquidity(uint256 amountA, uint256 amountB) external returns (uint256 liquidity) {
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        if (totalLiquidity == 0) {
            liquidity = sqrt(amountA * amountB);
        } else {
            liquidity = min(
                (amountA * totalLiquidity) / reserveA,
                (amountB * totalLiquidity) / reserveB
            );
        }

        require(liquidity > 0, "Insufficient liquidity");

        totalLiquidity += liquidity;
        liquidityBalances[msg.sender] += liquidity;
        
        reserveA += amountA;
        reserveB += amountB;
    }

    // 2. 交换逻辑 (A 换 B)
    function swapAforB(uint256 amountAIn, uint256 minBOut) external returns (uint256 amountBOut) {
        uint256 amountAInWithFee = (amountAIn * 997) / 1000;
        amountBOut = (reserveB * amountAInWithFee) / (reserveA + amountAInWithFee);
        
        require(amountBOut >= minBOut, "Slippage too high");

        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        reserveA += amountAIn;
        reserveB -= amountBOut;
    }

    // 工具函数
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

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
