// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Automated Market Maker (AMM)
 * @dev 实现了基于 x * y = k 公式的基础 DEX 引擎
 * 文件名命名格式: day25_amm.sol
 */
contract day25_amm is ERC20 {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    
    uint256 public reserveA;
    uint256 public reserveB;
    
    // 事件
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);
    
    /**
     * @param _tokenA 代币A地址
     * @param _tokenB 代币B地址
     * @param _name LP代币名称
     * @param _symbol LP代币符号
     */
    constructor(address _tokenA, address _tokenB, string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }
    
    // ================= 流动性管理 =================

    /**
     * @dev 添加流动性
     * 首次添加使用 sqrt(a*b)，后续添加按比例
     */
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");
        
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);
        
        uint256 liquidity;
        uint256 _totalSupply = totalSupply();

        if (_totalSupply == 0) {
            // 首次添加流动性
            liquidity = sqrt(amountA * amountB);
        } else {
            // 按现有比例添加，取较小值以防注入比例不均
            uint256 liquidityA = (amountA * _totalSupply) / reserveA;
            uint256 liquidityB = (amountB * _totalSupply) / reserveB;
            liquidity = liquidityA < liquidityB ? liquidityA : liquidityB;
        }
        
        require(liquidity > 0, "Insufficient liquidity minted");
        
        _mint(msg.sender, liquidity);
        reserveA += amountA;
        reserveB += amountB;
        
        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
    }
    
    /**
     * @dev 移除流动性并按比例取回两种代币
     */
    function removeLiquidity(uint256 liquidityToRemove) external returns (uint256 amountAOut, uint256 amountBOut) {
        require(liquidityToRemove > 0, "Liquidity must be > 0");
        uint256 _totalSupply = totalSupply();
        
        // 按比例计算返还金额
        amountAOut = (liquidityToRemove * reserveA) / _totalSupply;
        amountBOut = (liquidityToRemove * reserveB) / _totalSupply;
        
        require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves");
        
        reserveA -= amountAOut;
        reserveB -= amountBOut;
        
        _burn(msg.sender, liquidityToRemove);
        
        tokenA.transfer(msg.sender, amountAOut);
        tokenB.transfer(msg.sender, amountBOut);
        
        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);
        return (amountAOut, amountBOut);
    }
    
    // ================= 交换逻辑 =================

    /**
     * @dev 用代币A换代币B，含0.3%手续费
     */
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
        require(amountAIn > 0, "Amount must be > 0");
        
        uint256 amountBOut = getAmountOut(amountAIn, reserveA, reserveB);
        require(amountBOut >= minBOut, "Slippage too high");
        
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);
        
        // 更新储备（注意：为了简单起见，手续费留在池中增加k值）
        reserveA += amountAIn;
        reserveB -= amountBOut;
        
        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }
    
    /**
     * @dev 用代币B换代币A
     */
    function swapBforA(uint256 amountBIn, uint256 minAOut) external {
        require(amountBIn > 0, "Amount must be > 0");
        
        uint256 amountAOut = getAmountOut(amountBIn, reserveB, reserveA);
        require(amountAOut >= minAOut, "Slippage too high");
        
        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);
        
        reserveB += amountBIn;
        reserveA -= amountAOut;
        
        emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }
    
    // ================= 辅助工具 =================

    /**
     * @dev 基于 x * y = k 计算输出金额（含0.3%手续费）
     */
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) 
        public pure returns (uint256 amountOut) {
        require(amountIn > 0, "Amount in must be > 0");
        require(reserveIn > 0 && reserveOut > 0, "Insufficient reserves");
        
        uint256 amountInWithFee = amountIn * 997; // 扣除0.3%
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    /**
     * @dev 开根号函数（Babylonian方法）用于计算初始LP
     */
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

    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }
}
