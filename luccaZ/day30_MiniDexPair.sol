//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MiniDexPair is ReentrancyGuard {
  address public immutable tokenA;
  address public immutable tokenB;

  uint256 public reserveA;
  uint256 public reserveB;
  uint256 public totalLPSupply;

  mapping(address => uint256) public lpBalances;

  event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpMinted);
  event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpBurned);
  event Swapped(address indexed user, address indexed inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount);

  constructor(address _tokenA, address _tokenB) {
    require(_tokenA != address(0) && _tokenB != address(0), "Invalid token addresses");
    require(_tokenA != _tokenB, "Tokens must be different");
    tokenA = _tokenA;
    tokenB = _tokenB;
  }

  //Utilities
  function sqrt(uint y) internal pure returns (uint z) {
    if (y > 3) {
      z = y;
      uint x = y / 2 + 1;
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

  function _updateReserves() private {
    reserveA = IERC20(tokenA).balanceOf(address(this));
    reserveB = IERC20(tokenB).balanceOf(address(this));
  }

  function addLiquidity(uint256 amountA, uint256 amountB) external nonReentrant {
    require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");

    IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
    IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

    uint256 lpToMint;
    if (totalLPSupply == 0) {
      lpToMint = sqrt(amountA * amountB);
    } else {
      lpToMint = min(
        (amountA * totalLPSupply) / reserveA,
        (amountB * totalLPSupply) / reserveB
      );
    }

    require(lpToMint > 0, "LP tokens to mint must be greater than zero");

    lpBalances[msg.sender] += lpToMint;
    totalLPSupply += lpToMint;

    _updateReserves();

    emit LiquidityAdded(msg.sender, amountA, amountB, lpToMint);
  }

  function removeLiquidity(uint256 lpAmount) external nonReentrant {
    require(lpAmount > 0 && lpBalances[msg.sender] >= lpAmount, "Invalid LP amount");
    //calculate the ratio of the LP tokens being burned to the total supply
    //and use that to determine how much of each token to return to the user
    uint256 amountA = (lpAmount * reserveA) / totalLPSupply;
    uint256 amountB = (lpAmount * reserveB) / totalLPSupply;

    lpBalances[msg.sender] -= lpAmount;
    totalLPSupply -= lpAmount;

    IERC20(tokenA).transfer(msg.sender, amountA);
    IERC20(tokenB).transfer(msg.sender, amountB);

    _updateReserves();

    emit LiquidityRemoved(msg.sender, amountA, amountB, lpAmount);
  }

  function getAmountOut(uint256 inputAmount, address inputToken) public view returns (uint256) {
    require(inputToken == tokenA || inputToken == tokenB, "Invalid input token");

    bool isTokenA = inputToken == tokenA;
    //if input token is tokenA, then inputReserve is reserveA and outputReserve is reserveB
    (uint256 inputReserve, uint256 outputReserve) = isTokenA ? (reserveA, reserveB) : (reserveB, reserveA);

    //reserveA * reserveB = reserveA' * reserveB'
    //inputWithFee = inputAmount * 997 / 1000 (0.3% fee)
    //reserveA * reserveB = (reserveA + inputWithFee) * (reserveB - outputAmount)
    //reserveA * reserveB = reserveA * reserveB - reserveA * outputAmount + inputWithFee * reserveB - inputWithFee * outputAmount
    //0 = - reserveA * outputAmount + inputWithFee * reserveB - inputWithFee * outputAmount
    //outputAmount * (-reserveA - inputWithFee) + inputWithFee * reserveB = 0
    //outputAmount * (-reserveA - inputWithFee) = - inputWithFee * reserveB
    //outputAmount * (reserveA + inputWithFee) = inputWithFee * reserveB
    //outputAmount = (inputWithFee * reserveB) / (reserveA + inputWithFee)
    //numerator = inputWithFee * reserveB
    //denominator = reserveA + inputWithFee
    uint256 inputWithFee = inputAmount * 997; // 0.3% fee
    uint256 numerator = inputWithFee * outputReserve;
    uint256 denominator = (inputReserve * 1000) + inputWithFee;
    return numerator / denominator;
  }

  function swap(uint256 inputAmount, address inputToken) external nonReentrant {
    require(inputAmount > 0, "Input amount must be greater than zero");
    require(inputToken == tokenA || inputToken == tokenB, "Invalid input token");

    address outputToken;
    if (inputToken == tokenA) {
      outputToken = tokenB;
    } else {
      outputToken = tokenA;
    }
    uint256 outputAmount = getAmountOut(inputAmount, inputToken);
    require(outputAmount > 0, "Output amount must be greater than zero");

    IERC20(inputToken).transferFrom(msg.sender, address(this), inputAmount);
    IERC20(outputToken).transfer(msg.sender, outputAmount);

    _updateReserves();

    emit Swapped(msg.sender, inputToken, inputAmount, outputToken, outputAmount);
  }

  // View functions
  function getReserves() external view returns (uint256, uint256) {
    return (reserveA, reserveB);
  }

  function getLPBalance(address user) external view returns (uint256) {
    return lpBalances[user];
  }

  function getTotalLPSupply() external view returns (uint256) {
    return totalLPSupply;
  }
}