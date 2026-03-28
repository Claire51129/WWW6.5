// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Mini {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract MiniDexPair {
    address public token0;
    address public token1;

    uint256 public reserve0;
    uint256 public reserve1;

    mapping(address => uint256) public liquidityBalance;
    uint256 public totalLiquidity;

    event LiquidityAdded(address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidityMinted);
    event LiquidityRemoved(address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidityBurned);
    event Swapped(address indexed user, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);

    constructor(address _token0, address _token1) {
        require(_token0 != _token1, "Identical tokens");
        require(_token0 != address(0) && _token1 != address(0), "Zero address");

        token0 = _token0;
        token1 = _token1;
    }

    function addLiquidity(uint256 amount0, uint256 amount1) external returns (uint256 liquidity) {
        require(amount0 > 0 && amount1 > 0, "Invalid amounts");

        IERC20Mini(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20Mini(token1).transferFrom(msg.sender, address(this), amount1);

        if (totalLiquidity == 0) {
            liquidity = _sqrt(amount0 * amount1);
        } else {
            uint256 liquidity0 = (amount0 * totalLiquidity) / reserve0;
            uint256 liquidity1 = (amount1 * totalLiquidity) / reserve1;
            require(liquidity0 == liquidity1, "Wrong ratio");
            liquidity = liquidity0;
        }

        require(liquidity > 0, "Zero liquidity");

        liquidityBalance[msg.sender] += liquidity;
        totalLiquidity += liquidity;

        reserve0 += amount0;
        reserve1 += amount1;

        emit LiquidityAdded(msg.sender, amount0, amount1, liquidity);
    }

    function removeLiquidity(uint256 liquidity) external returns (uint256 amount0, uint256 amount1) {
        require(liquidity > 0, "Zero liquidity");
        require(liquidityBalance[msg.sender] >= liquidity, "Not enough LP");

        amount0 = (liquidity * reserve0) / totalLiquidity;
        amount1 = (liquidity * reserve1) / totalLiquidity;

        liquidityBalance[msg.sender] -= liquidity;
        totalLiquidity -= liquidity;

        reserve0 -= amount0;
        reserve1 -= amount1;

        IERC20Mini(token0).transfer(msg.sender, amount0);
        IERC20Mini(token1).transfer(msg.sender, amount1);

        emit LiquidityRemoved(msg.sender, amount0, amount1, liquidity);
    }

    function swap(address tokenIn, uint256 amountIn) external returns (uint256 amountOut) {
        require(amountIn > 0, "Zero input");
        require(tokenIn == token0 || tokenIn == token1, "Invalid token");

        bool isToken0In = tokenIn == token0;

        address inputToken = isToken0In ? token0 : token1;
        address outputToken = isToken0In ? token1 : token0;

        uint256 reserveIn = isToken0In ? reserve0 : reserve1;
        uint256 reserveOut = isToken0In ? reserve1 : reserve0;

        IERC20Mini(inputToken).transferFrom(msg.sender, address(this), amountIn);

        // 简化版 constant product: x * y = k
        uint256 k = reserveIn * reserveOut;
        uint256 newReserveIn = reserveIn + amountIn;
        uint256 newReserveOut = k / newReserveIn;

        amountOut = reserveOut - newReserveOut;
        require(amountOut > 0, "Zero output");
        require(amountOut < reserveOut, "Insufficient liquidity");

        IERC20Mini(outputToken).transfer(msg.sender, amountOut);

        if (isToken0In) {
            reserve0 = newReserveIn;
            reserve1 = newReserveOut;
        } else {
            reserve1 = newReserveIn;
            reserve0 = newReserveOut;
        }

        emit Swapped(msg.sender, inputToken, amountIn, outputToken, amountOut);
    }

    function getReserves() external view returns (uint256, uint256) {
        return (reserve0, reserve1);
    }

    function getPriceToken0InToken1() external view returns (uint256) {
        require(reserve0 > 0, "No reserve0");
        return (reserve1 * 1e18) / reserve0;
    }

    function getPriceToken1InToken0() external view returns (uint256) {
        require(reserve1 > 0, "No reserve1");
        return (reserve0 * 1e18) / reserve1;
    }

    function _sqrt(uint256 y) internal pure returns (uint256 z) {
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