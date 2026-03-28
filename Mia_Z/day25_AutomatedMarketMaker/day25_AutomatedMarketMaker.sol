// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


/// @title Automated Market Maker with Liquidity Token
contract AutomatedMarketMaker is ERC20 {
    using SafeERC20 for IERC20;

    IERC20 public tokenA;
    IERC20 public tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    address public owner;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);
    event Sync(uint256 reserveA, uint256 reserveB);

    constructor(address _tokenA, address _tokenB, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        require(_tokenA != address(0) && _tokenB != address(0), "Zero token");
        require(_tokenA != _tokenB, "Same token");
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    /// @notice Add liquidity to the pool
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");

        tokenA.safeTransferFrom(msg.sender, address(this), amountA);
        tokenB.safeTransferFrom(msg.sender, address(this), amountB);

        uint256 liquidity;
        if (totalSupply() == 0) {
            liquidity = sqrt(amountA * amountB);
        } else {
            liquidity = min(
                amountA * totalSupply() / reserveA,
                amountB * totalSupply() / reserveB
            );
        }
        require(liquidity > 0, "Insufficient liquidity minted");

        _mint(msg.sender, liquidity);

        _sync();

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

        require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves for requested liquidity");

        _burn(msg.sender, liquidityToRemove);

        tokenA.safeTransfer(msg.sender, amountAOut);
        tokenB.safeTransfer(msg.sender, amountBOut);

        _sync();

        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);
        return (amountAOut, amountBOut);
    }

    /// @notice Swap token A for token B
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
        require(amountAIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        uint256 amountBOut = getAmountOut(amountAIn, reserveA, reserveB);

        require(amountBOut >= minBOut, "Slippage too high");

        tokenA.safeTransferFrom(msg.sender, address(this), amountAIn);
        tokenB.safeTransfer(msg.sender, amountBOut);

        _sync();

        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    /// @notice Swap token B for token A
    function swapBforA(uint256 amountBIn, uint256 minAOut) external {
        require(amountBIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        uint256 amountAOut = getAmountOut(amountBIn, reserveB, reserveA);

        require(amountAOut >= minAOut, "Slippage too high");

        tokenB.safeTransferFrom(msg.sender, address(this), amountBIn);
        tokenA.safeTransfer(msg.sender, amountAOut);

        _sync();

        emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }

    /// @notice View the current reserves
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    /// @notice Quote: given an input amount and pair reserves, return output amount (0.3% fee)
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256 amountOut) {
        require(amountIn > 0, "Amount must be > 0");
        require(reserveIn > 0 && reserveOut > 0, "Insufficient reserves");
        uint256 amountInWithFee = amountIn * 997 / 1000;
        amountOut = reserveOut * amountInWithFee / (reserveIn + amountInWithFee);
    }

    /// @notice Quote: input tokenA -> output tokenB (0.3% fee)
    function quoteAforB(uint256 amountAIn) external view returns (uint256 amountBOut) {
        return getAmountOut(amountAIn, reserveA, reserveB);
    }

    /// @notice Quote: input tokenB -> output tokenA (0.3% fee)
    function quoteBforA(uint256 amountBIn) external view returns (uint256 amountAOut) {
        return getAmountOut(amountBIn, reserveB, reserveA);
    }

    /// @notice Sync reserves to actual token balances
    function sync() external {
        _sync();
    }

    function _sync() internal {
        reserveA = tokenA.balanceOf(address(this));
        reserveB = tokenB.balanceOf(address(this));
        emit Sync(reserveA, reserveB);
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
