// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utilS/ReentrancyGuard.sol";

/// @title MiniDexPair - 简单去中心化交易对（DEX）合约
/// @notice 支持添加/移除流动性、代币交换、LP份额管理
contract MiniDexPair is ReentrancyGuard {
    // 交易对的代币地址
    address public immutable tokenA;
    address public immutable tokenB;

    // 当前池子内代币的储备量
    uint256 public reserveA;
    uint256 public reserveB;

    // LP（流动性提供者）总供应量
    uint256 public totalLPSupply;

    // 每个用户持有的LP数量
    mapping(address => uint256) public lpBalances;

    // 事件
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpMinted);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpBurned);
    event Swapped(address indexed user, address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount);

    /// @notice 构造函数，初始化交易对代币
    constructor(address _tokenA, address _tokenB) {
        require(_tokenA != _tokenB, "Identical tokens"); // 两个代币不能相同
        require(_tokenA != address(0) && _tokenB != address(0), "Zero address"); // 地址不能为0

        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    // ========================
    // 内部工具函数
    // ========================

    /// @notice 计算平方根（用于首次添加流动性时LP铸造数量）
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

    /// @notice 返回两个数中较小的一个
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /// @notice 更新储备量（同步合约内余额到状态变量）
    function _updateReserves() private {
        reserveA = IERC20(tokenA).balanceOf(address(this));
        reserveB = IERC20(tokenB).balanceOf(address(this));
    }

    // ========================
    // 添加/移除流动性
    // ========================

    /// @notice 添加流动性
    /// @param amountA 代币A的数量
    /// @param amountB 代币B的数量
    function addLiquidity(uint256 amountA, uint256 amountB) external nonReentrant {
        require(amountA > 0 && amountB > 0, "Invalid amounts");

        // 将用户代币转入合约
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        // 计算本次需要铸造的LP数量
        uint256 lpToMint;
        if (totalLPSupply == 0) {
            // 首次添加流动性，使用几何平均值
            lpToMint = sqrt(amountA * amountB);
        } else {
            // 根据已有储备比例计算LP
            lpToMint = min(
                (amountA * totalLPSupply) / reserveA,
                (amountB * totalLPSupply) / reserveB
            );
        }

        require(lpToMint > 0, "Zero LP minted");

        // 更新用户LP余额与总供应量
        lpBalances[msg.sender] += lpToMint;
        totalLPSupply += lpToMint;

        // 更新储备量
        _updateReserves();

        emit LiquidityAdded(msg.sender, amountA, amountB, lpToMint);
    }

    /// @notice 移除流动性
    /// @param lpAmount 要赎回的LP数量
    function removeLiquidity(uint256 lpAmount) external nonReentrant {
        require(lpAmount > 0 && lpAmount <= lpBalances[msg.sender], "Invalid LP amount");

        // 按比例计算用户可取回的代币数量
        uint256 amountA = (lpAmount * reserveA) / totalLPSupply;
        uint256 amountB = (lpAmount * reserveB) / totalLPSupply;

        // 更新用户LP余额和总供应量
        lpBalances[msg.sender] -= lpAmount;
        totalLPSupply -= lpAmount;

        // 转账代币给用户
        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        // 更新储备量
        _updateReserves();

        emit LiquidityRemoved(msg.sender, amountA, amountB, lpAmount);
    }

    // ========================
    // 代币交换
    // ========================

    /// @notice 根据输入金额计算输出金额（自动做市商公式，含0.3%手续费）
    /// @param inputAmount 输入代币数量
    /// @param inputToken 输入代币地址
    /// @return outputAmount 输出代币数量
    function getAmountOut(uint256 inputAmount, address inputToken) public view returns (uint256 outputAmount) {
        require(inputToken == tokenA || inputToken == tokenB, "Invalid input token");

        bool isTokenA = inputToken == tokenA;
        (uint256 inputReserve, uint256 outputReserve) = isTokenA ? (reserveA, reserveB) : (reserveB, reserveA);

        // 0.3% 交易手续费
        uint256 inputWithFee = inputAmount * 997;
        uint256 numerator = inputWithFee * outputReserve;
        uint256 denominator = (inputReserve * 1000) + inputWithFee;

        outputAmount = numerator / denominator;
    }

    /// @notice 代币交换
    /// @param inputAmount 输入代币数量
    /// @param inputToken 输入代币地址
    function swap(uint256 inputAmount, address inputToken) external nonReentrant {
        require(inputAmount > 0, "Zero input");
        require(inputToken == tokenA || inputToken == tokenB, "Invalid token");

        address outputToken = inputToken == tokenA ? tokenB : tokenA;
        uint256 outputAmount = getAmountOut(inputAmount, inputToken);

        require(outputAmount > 0, "Insufficient output");

        // 用户支付输入代币
        IERC20(inputToken).transferFrom(msg.sender, address(this), inputAmount);
        // 合约发放输出代币
        IERC20(outputToken).transfer(msg.sender, outputAmount);

        _updateReserves();

        emit Swapped(msg.sender, inputToken, inputAmount, outputToken, outputAmount);
    }

    // ========================
    // 查看函数
    // ========================

    /// @notice 查看当前储备量
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    /// @notice 查看用户LP余额
    function getLPBalance(address user) external view returns (uint256) {
        return lpBalances[user];
    }

    /// @notice 查看LP总供应量
    function getTotalLPSupply() external view returns (uint256) {
        return totalLPSupply;
    }
}
