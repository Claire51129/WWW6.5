// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MiniDexPair is ReentrancyGuard {

    uint256 public constant MINIMUM_LIQUIDITY = 1000;

    address public immutable token0;
    address public immutable token1;

    uint256 public reserve0;
    uint256 public reserve1;
    uint256 public totalLPSupply;

    mapping(address => uint256) public lpBalances;

    event LiquidityAdded(address indexed provider, uint256 amount0, uint256 amount1, uint256 lpMinted);
    event LiquidityRemoved(address indexed provider, uint256 amount0, uint256 amount1, uint256 lpBurned);
    event Swap(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);

    constructor(address _token0, address _token1) {
        require(_token0 != address(0) && _token1 != address(0), "Zero address");
        require(_token0 != _token1, "Identical tokens");
        token0 = _token0;
        token1 = _token1;
    }

    function addLiquidity(uint256 amount0, uint256 amount1) external nonReentrant {
        require(amount0 > 0 && amount1 > 0, "Amounts must be > 0");

        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), amount1);

        uint256 lpToMint;
        if (totalLPSupply == 0) {
            lpToMint = sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            lpBalances[address(0)] += MINIMUM_LIQUIDITY;
            totalLPSupply += MINIMUM_LIQUIDITY;
        } else {
            lpToMint = min(
                (amount0 * totalLPSupply) / reserve0,
                (amount1 * totalLPSupply) / reserve1
            );
        }

        require(lpToMint > 0, "Insufficient liquidity minted");
        lpBalances[msg.sender] += lpToMint;
        totalLPSupply += lpToMint;

        _updateReserves();
        emit LiquidityAdded(msg.sender, amount0, amount1, lpToMint);
    }

    function removeLiquidity(uint256 lpAmount) external nonReentrant {
        require(lpAmount > 0 && lpBalances[msg.sender] >= lpAmount, "Invalid LP amount");

        uint256 amount0Out = (lpAmount * reserve0) / totalLPSupply;
        uint256 amount1Out = (lpAmount * reserve1) / totalLPSupply;

        lpBalances[msg.sender] -= lpAmount;
        totalLPSupply -= lpAmount;

        IERC20(token0).transfer(msg.sender, amount0Out);
        IERC20(token1).transfer(msg.sender, amount1Out);

        _updateReserves();
        emit LiquidityRemoved(msg.sender, amount0Out, amount1Out, lpAmount);
    }

    function swap(uint256 amountIn, address tokenIn) external nonReentrant {
        require(amountIn > 0, "Amount must be > 0");
        require(tokenIn == token0 || tokenIn == token1, "Invalid token");
        require(reserve0 > 0 && reserve1 > 0, "No liquidity");

        address tokenOut = tokenIn == token0 ? token1 : token0;
        uint256 amountOut = getAmountOut(amountIn, tokenIn);
        require(amountOut > 0, "Insufficient output");

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenOut).transfer(msg.sender, amountOut);

        _updateReserves();
        emit Swap(msg.sender, tokenIn, amountIn, tokenOut, amountOut);
    }

    function getAmountOut(uint256 amountIn, address tokenIn) public view returns (uint256) {
        require(tokenIn == token0 || tokenIn == token1, "Invalid token");
        (uint256 reserveIn, uint256 reserveOut) = tokenIn == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
        uint256 amountInWithFee = amountIn * 997;
        return (amountInWithFee * reserveOut) / (reserveIn * 1000 + amountInWithFee);
    }

    function getReserves() external view returns (uint256, uint256) {
        return (reserve0, reserve1);
    }

    function getLPBalance(address user) external view returns (uint256) {
        return lpBalances[user];
    }

    function _updateReserves() private {
        reserve0 = IERC20(token0).balanceOf(address(this));
        reserve1 = IERC20(token1).balanceOf(address(this));
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

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
