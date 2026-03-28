//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Automated Market Maker with Liquidity Token
contract AutoMatedMarketMaker is ERC20 {
    IERC20 public tokenA;
    IERC20 public tokenB;
    

    uint256 public reserveA;
    uint256 public reserveB;

    address public owner;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);

    constructor(address _tokenA, address _tokenB, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    ///@notice Add liquidity to the pool
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");
        
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        uint256 liquidity;
        if (totalSupply() == 0) {
            liquidity = sqrt(amountA * amountB);
        } else {
            liquidity = min(
              (amountA * totalSupply()) / reserveA, 
              (amountB * totalSupply()) / reserveB
              );
        }
        _mint(msg.sender, liquidity);

        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    ///@notice Remove liquidity from the pool
    function removeLiquidity(uint256 liquidityToRemove) external returns (uint256 amountAOut, uint256 amountBOut) {
        require(liquidityToRemove > 0, "Liquidity to remove must be greater than zero");
        require(balanceOf(msg.sender) >= liquidityToRemove, "Not enough liquidity tokens");

        uint256 totalLiquidity = totalSupply();
        require(totalLiquidity > 0, "No liquidity in the pool");

        amountAOut = (liquidityToRemove * reserveA) / totalLiquidity;
        amountBOut = (liquidityToRemove * reserveB) / totalLiquidity;

        require(amountAOut > 0 && amountBOut > 0, "Output amounts must be greater than zero");

        reserveA -= amountAOut;
        reserveB -= amountBOut;
        _burn(msg.sender, liquidityToRemove);

        tokenA.transfer(msg.sender, amountAOut);
        tokenB.transfer(msg.sender, amountBOut);

        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut);
        return (amountAOut, amountBOut);
    }

    ///@notice Swap tokens in the pool
    function swapAForB(uint256 amountAIn, uint256 minBOut) external {
      require(amountAIn > 0, "Amount in must be greater than zero");
      require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

      uint256 amountAInWithFee = (amountAIn * 997) / 1000; 
      uint256 amountBOut = (amountAInWithFee * reserveB) / (reserveA + amountAInWithFee);

      require(amountBOut >= minBOut, "Insufficient output amount");

      tokenA.transferFrom(msg.sender, address(this), amountAIn);
      tokenB.transfer(msg.sender, amountBOut);

      reserveA += amountAInWithFee;
      reserveB -= amountBOut;

      emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    ///@notice Swap tokens in the pool
    function swapBForA(uint256 amountBIn, uint256 minAOut) external {
      require(amountBIn > 0, "Amount in must be greater than zero");
      require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

      uint256 amountBInWithFee = (amountBIn * 997) / 1000;
      uint256 amountAOut = (amountBInWithFee * reserveA) / (reserveB + amountBInWithFee);

      require(amountAOut >= minAOut, "Insufficient output amount");

      tokenB.transferFrom(msg.sender, address(this), amountBIn);
      tokenA.transfer(msg.sender, amountAOut);

      reserveB += amountBInWithFee;
      reserveA -= amountAOut;

      emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }

    ///@notice View the current reserves of the pool
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    /// @dev Utility: Return the minimum of two numbers
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /// @dev Utility: Babylonian square root function
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