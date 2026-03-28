// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// Inherited from ERC20 to issue liquidity token
contract AutomatedMarketMaker is ERC20 {
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
	// Add liquidity to pool
	function addLiquidity(uint256 amountA, uint256 amountB) external {
		require(amountA > 0 && amountB > 0, "Invalid amount");
		// transfer(): transfer token from this contract to user
		// transferFrom(): transfer token from user to this contract(need approval)
		tokenA.transferFrom(msg.sender, address(this), amountA);
		tokenB.transferFrom(msg.sender, address(this), amountB);
		uint256 liquidity;
		// First time to provide liquidity
		if (totalSupply() == 0) {
			liquidity = sqrt(amountA *amountB);
		} else {
		// Calculate liquidity according the less type of tokens
			liquidity = min(
				amountA * totalSupply() / reserveA,
				amountB * totalSupply() / reserveB
			);
		}
		// Issue liquidity token to provider
		_mint(msg.sender, liquidity);
		reserveA += amountA;
		reserveB += amountB;
		emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
	}
	// Withdraw liquidity from pool
	function removeLiquidity(uint256 liquidityToRemove) external returns (uint256 amountAOut, uint256 amountBOut) {
		require(liquidityToRemove > 0, "Invalid liquidity");
		require(balanceOf(msg.sender) >= liquidityToRemove, "Insufficient liquidity");
		uint256 totalLiquidity = totalSupply();
		require(totalLiquidity > 0, "No liquidity in the pool");
		// Give tokens according to liquidity proportion
		amountAOut = liquidityToRemove * reserveA / totalLiquidity;
		amountBOut = liquidityToRemove * reserveB / totalLiquidity;
		require(amountAOut > 0 && amountBOut > 0, "Insufficient reserve");
		reserveA -= amountAOut;
		reserveB -= amountBOut;
		// Burn collected liquidity tokens
		_burn(msg.sender, liquidityToRemove);
		tokenA.transfer(msg.sender, amountAOut);
		tokenB.transfer(msg.sender, amountBOut);
		emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);
		return (amountAOut, amountBOut);
	}
	// Swap tokenA to B
	function swapAforB(uint256 amountAIn, uint256 minBOut) external {
		require(amountAIn > 0, "Invalid amount");
		require(reserveA > 0 && reserveB > 0, "Insufficient reserve");
		// Charge service fee 3%
		uint256 amountAInFee = amountAIn * 997 / 1000;
		// tokenA * tokenB = k
		// k can change, but before and after exchange it should balance
		uint256 amountBOut = reserveB * amountAInFee / (reserveA + amountAInFee);
		require(amountBOut >= minBOut, "Slippage too high");
		tokenA.transferFrom(msg.sender, address(this), amountAIn);
		tokenB.transfer(msg.sender, amountBOut);
		// Should be amountAIn
		// Otherwise liquidity provider cannot share fees (k reamin strictly unchanged)
		reserveA += amountAInFee;
		reserveB -= amountBOut;
		emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
	}
	function swapBforA(uint256 amountBIn, uint256 minAOut) external {
		require(amountBIn > 0, "Invalid amount");
		require(reserveB > 0 && reserveA > 0, "Insufficient reserve");
		uint256 amountBInFee = amountBIn * 997 / 1000;
		uint256 amountAOut = reserveA * amountBInFee / (reserveB + amountBInFee);
		require(amountAOut >= minAOut, "Slippage too high");
		tokenB.transferFrom(msg.sender, address(this), amountBIn);
		tokenA.transfer(msg.sender, amountAOut);
		reserveB += amountBInFee;
		reserveA -= amountAOut;
		emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
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