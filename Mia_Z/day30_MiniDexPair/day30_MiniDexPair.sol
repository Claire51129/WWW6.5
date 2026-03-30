
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title MiniDexPair
 * @notice 一个“极简版 DEX Pair”示例合约（仿 Uniswap V2 核心思想）：
 * - 两个 ERC20 资产池化（`tokenA` 与 `tokenB`）并维护储备量（`reserveA`/`reserveB`）
 * - 支持添加/移除流动性（mint/burn LP）
 * - 支持基于恒定乘积的兑换（`swap`，并引入 0.3% 手续费，997/1000 计算方式）
 *
 * 说明：该合约是教学/示例用途，未包含完整生产级别的安全与经济设计（例如精确的 LP 代币实现、价格滑点保护、事件与精度边界等）。
 */
contract MiniDexPair is ReentrancyGuard {
    /// @dev 池子中两种代币地址（创建后不可变）
    address public immutable tokenA;
    address public immutable tokenB;

    /// @dev 储备量：用于恒定乘积公式计算
    uint256 public reserveA;
    uint256 public reserveB;

    /// @dev 总 LP 份额（此示例用 uint256 模拟，并非标准 ERC20）
    uint256 public totalLPSupply;

    /// @dev 用户 LP 份额映射
    mapping(address => uint256) public lpBalances;

    /// @dev 添加流动性事件
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpMinted);
    /// @dev 移除流动性事件
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpBurned);
    /// @dev 兑换事件
    event Swapped(address indexed user, address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount);

    /// @param _tokenA 池子资产 A
    /// @param _tokenB 池子资产 B
    constructor(address _tokenA, address _tokenB) {
        // 不允许相同代币或零地址
        require(_tokenA != _tokenB, "Identical tokens");
        require(_tokenA != address(0) && _tokenB != address(0), "Zero address");

        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    // ----------------------------
    //  实用工具函数（数学）
    // ----------------------------

    /// @dev 牛顿迭代法计算平方根（用于首次流动性 mint LP）
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

    /// @dev 返回两个数的较小值
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /// @dev 从链上余额重新计算储备（swap/add/remove 后调用）
    function _updateReserves() private {
        reserveA = IERC20(tokenA).balanceOf(address(this));
        reserveB = IERC20(tokenB).balanceOf(address(this));
    }

    /// @notice 添加流动性：按比例铸造 LP
    /// @param amountA tokenA 数量
    /// @param amountB tokenB 数量
    function addLiquidity(uint256 amountA, uint256 amountB) external nonReentrant {
        // 简单输入校验
        require(amountA > 0 && amountB > 0, "Invalid amounts");

        // 接收用户转入的两种代币
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        uint256 lpToMint;
        // 首次添加流动性：LP = sqrt(x*y)
        if (totalLPSupply == 0) {
            lpToMint = sqrt(amountA * amountB);
        } else {
            // 后续添加流动性：LP = min( amountA * totalLP / reserveA, amountB * totalLP / reserveB )
            lpToMint = min(
                (amountA * totalLPSupply) / reserveA,
                (amountB * totalLPSupply) / reserveB
            );
        }

        // 防止出现由于比例不对导致的 0 LP
        require(lpToMint > 0, "Zero LP minted");

        // 更新用户与全局 LP 状态
        lpBalances[msg.sender] += lpToMint;
        totalLPSupply += lpToMint;

        // 更新储备并发事件
        _updateReserves();

        emit LiquidityAdded(msg.sender, amountA, amountB, lpToMint);
    }

    /// @notice 移除流动性：按用户 LP 份额赎回池中代币
    /// @param lpAmount 要移除的 LP 份额数量
    function removeLiquidity(uint256 lpAmount) external nonReentrant {
        // 输入与额度校验
        require(lpAmount > 0 && lpAmount <= lpBalances[msg.sender], "Invalid LP amount");

        // 赎回比例：amount = lpAmount / totalLP * reserve
        uint256 amountA = (lpAmount * reserveA) / totalLPSupply;
        uint256 amountB = (lpAmount * reserveB) / totalLPSupply;

        // 更新 LP 状态
        lpBalances[msg.sender] -= lpAmount;
        totalLPSupply -= lpAmount;

        // 返还代币给用户
        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        // 更新储备并发事件
        _updateReserves();

        emit LiquidityRemoved(msg.sender, amountA, amountB, lpAmount);
    }

    /**
     * @notice 根据输入数量计算“理论输出数量”（不执行转账）
     * @param inputAmount 输入代币数量
     * @param inputToken 输入代币地址（必须是 tokenA 或 tokenB）
     *
     * 定价公式（简化恒定乘积，带 0.3% 手续费）：
     * - inputWithFee = inputAmount * 997
     * - output = (inputWithFee * outputReserve) / (inputReserve * 1000 + inputWithFee)
     */
    function getAmountOut(uint256 inputAmount, address inputToken) public view returns (uint256 outputAmount) {
        require(inputToken == tokenA || inputToken == tokenB, "Invalid input token");

        bool isTokenA = inputToken == tokenA;
        (uint256 inputReserve, uint256 outputReserve) = isTokenA ? (reserveA, reserveB) : (reserveB, reserveA);

        uint256 inputWithFee = inputAmount * 997;
        uint256 numerator = inputWithFee * outputReserve;
        uint256 denominator = (inputReserve * 1000) + inputWithFee;

        outputAmount = numerator / denominator;
    }

    /// @notice 执行兑换：将输入代币转入池子，并把计算的输出代币转给用户
    /// @param inputAmount 输入代币数量
    /// @param inputToken 输入代币地址（必须是 tokenA 或 tokenB）
    function swap(uint256 inputAmount, address inputToken) external nonReentrant {
        // 输入合法性校验
        require(inputAmount > 0, "Zero input");
        require(inputToken == tokenA || inputToken == tokenB, "Invalid token");

        // 输出代币与输入代币相反
        address outputToken = inputToken == tokenA ? tokenB : tokenA;
        uint256 outputAmount = getAmountOut(inputAmount, inputToken);

        // 简单保护：至少要有非零输出
        require(outputAmount > 0, "Insufficient output");

        // 先把输入代币转入，再把输出代币转出
        IERC20(inputToken).transferFrom(msg.sender, address(this), inputAmount);
        IERC20(outputToken).transfer(msg.sender, outputAmount);

        // 更新储备并发事件
        _updateReserves();

        emit Swapped(msg.sender, inputToken, inputAmount, outputToken, outputAmount);
    }

    // ----------------------------
    //  只读查询函数
    // ----------------------------

    /// @notice 查看当前储备（reserveA, reserveB）
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    /// @notice 查看用户 LP 份额
    function getLPBalance(address user) external view returns (uint256) {
        return lpBalances[user];
    }

    /// @notice 查看 LP 总供应
    function getTotalLPSupply() external view returns (uint256) {
        return totalLPSupply;
    }
}
