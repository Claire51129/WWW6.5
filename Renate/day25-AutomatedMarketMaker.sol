// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 OpenZeppelin 的 ERC20 合约
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Automated Market Maker with Liquidity Token
/// @title 自动化做市商合约
/// @dev 这是一个简化的 Uniswap V1 风格的 AMM 合约
/// @dev 实现了流动性提供、流动性移除和代币交换功能
/// @dev 使用恒定乘积公式：x * y = k
contract AutomatedMarketMaker is ERC20 {
    
    // ==================== 状态变量 ====================
    
    /// @notice 代币 A 的合约接口
    /// @dev 使用 IERC20 接口与任意 ERC20 代币交互
    IERC20 public tokenA;
    
    /// @notice 代币 B 的合约接口
    IERC20 public tokenB;

    /// @notice 代币 A 的储备量
    /// @dev 记录在合约中的 tokenA 数量
    uint256 public reserveA;
    
    /// @notice 代币 B 的储备量
    /// @dev 记录在合约中的 tokenB 数量
    uint256 public reserveB;

    /// @notice 合约所有者地址
    /// @dev 这里虽然记录了 owner，但代码中没有使用 onlyOwner 修饰符
    address public owner;

    // ==================== 事件 ====================
    
    /// @notice 添加流动性事件
    /// @param provider 流动性提供者地址
    /// @param amountA 添加的 tokenA 数量
    /// @param amountB 添加的 tokenB 数量
    /// @param liquidity 铸造的流动性代币数量
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    
    /// @notice 移除流动性事件
    /// @param provider 流动性提供者地址
    /// @param amountA 取出的 tokenA 数量
    /// @param amountB 取出的 tokenB 数量
    /// @param liquidity 销毁的流动性代币数量
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    
    /// @notice 代币交换事件
    /// @param trader 交易者地址
    /// @param tokenIn 输入代币地址
    /// @param amountIn 输入数量
    /// @param tokenOut 输出代币地址
    /// @param amountOut 输出数量
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);

    // ==================== 构造函数 ====================
    
    /// @notice 创建 AMM 合约
    /// @param _tokenA 代币 A 的合约地址
    /// @param _tokenB 代币 B 的合约地址
    /// @param _name 流动性代币的名称
    /// @param _symbol 流动性代币的符号
    /// @dev 继承 ERC20 合约，流动性提供者会收到 LP 代币作为凭证
    constructor(
        address _tokenA, 
        address _tokenB, 
        string memory _name, 
        string memory _symbol
    ) ERC20(_name, _symbol) {
        tokenA = IERC20(_tokenA);  // 初始化 tokenA 接口
        tokenB = IERC20(_tokenB);  // 初始化 tokenB 接口
        owner = msg.sender;         // 记录部署者为所有者
    }

    // ==================== 流动性管理 ====================
    
    /// @notice 向流动性池添加流动性
    /// @param amountA 要添加的 tokenA 数量
    /// @param amountB 要添加的 tokenB 数量
    /// @dev 流动性提供者需要提前授权（approve）合约使用其代币
    /// @dev 首次添加流动性决定代币的初始价格比例
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        // 检查输入金额必须大于 0
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");

        // 从用户账户转移 tokenA 到合约
        // transferFrom 需要用户提前 approve
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        // 计算应该铸造的流动性代币数量
        uint256 liquidity;
        if (totalSupply() == 0) {
            // 首次添加流动性：使用几何平均数
            // 公式：liquidity = sqrt(amountA * amountB)
            // 这样可以确保不同比例的池子有公平的 LP 代币分配
            liquidity = sqrt(amountA * amountB);
        } else {
            // 后续添加流动性：按比例分配
            // 取两个代币按比例计算的最小值，防止套利
            liquidity = min(
                amountA * totalSupply() / reserveA,
                amountB * totalSupply() / reserveB
            );
        }

        // 铸造流动性代币给提供者
        // LP 代币代表提供者在池子中的份额
        _mint(msg.sender, liquidity);

        // 更新储备量记录
        reserveA += amountA;
        reserveB += amountB;

        // 触发添加流动性事件
        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
    }

    /// @notice 从流动性池移除流动性
    /// @param liquidityToRemove 要移除的流动性代币数量
    /// @return amountAOut 取出的 tokenA 数量
    /// @return amountBOut 取出的 tokenB 数量
    /// @dev 用户需要持有 LP 代币才能移除流动性
    function removeLiquidity(uint256 liquidityToRemove) 
        external 
        returns (uint256 amountAOut, uint256 amountBOut) 
    {
        // 检查要移除的流动性大于 0
        require(liquidityToRemove > 0, "Liquidity to remove must be > 0");
        
        // 检查用户有足够的 LP 代币
        require(balanceOf(msg.sender) >= liquidityToRemove, "Insufficient liquidity tokens");

        // 获取总流动性供应量
        uint256 totalLiquidity = totalSupply();
        require(totalLiquidity > 0, "No liquidity in the pool");

        // 计算用户可以取出的代币数量
        // 公式：取出数量 = (移除的流动性 / 总流动性) * 储备量
        amountAOut = liquidityToRemove * reserveA / totalLiquidity;
        amountBOut = liquidityToRemove * reserveB / totalLiquidity;

        // 检查计算出的数量大于 0
        require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves for requested liquidity");

        // 更新储备量（先更新状态，防止重入攻击）
        reserveA -= amountAOut;
        reserveB -= amountBOut;

        // 销毁用户的 LP 代币
        _burn(msg.sender, liquidityToRemove);

        // 将代币转还给用户
        tokenA.transfer(msg.sender, amountAOut);
        tokenB.transfer(msg.sender, amountBOut);

        // 触发移除流动性事件
        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);
        
        return (amountAOut, amountBOut);
    }

    // ==================== 代币交换 ====================
    
    /// @notice 用 tokenA 交换 tokenB
    /// @param amountAIn 输入的 tokenA 数量
    /// @param minBOut 最小输出的 tokenB 数量（滑点保护）
    /// @dev 使用恒定乘积公式计算交换数量
    /// @dev 收取 0.3% 的手续费（997/1000）
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
        // 检查输入金额大于 0
        require(amountAIn > 0, "Amount must be > 0");
        
        // 检查池子有足够的流动性
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        // 计算扣除手续费后的输入金额
        // 手续费 0.3%：amountAIn * 997 / 1000
        uint256 amountAInWithFee = amountAIn * 997 / 1000;
        
        // 使用恒定乘积公式计算输出数量
        // 公式：amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee)
        // 这是 AMM 的核心算法，保持 x * y = k 的恒定乘积
        uint256 amountBOut = reserveB * amountAInWithFee / (reserveA + amountAInWithFee);

        // 检查输出数量满足最小要求（滑点保护）
        // 如果实际输出小于 minBOut，交易回滚，保护用户免受大额滑点损失
        require(amountBOut >= minBOut, "Slippage too high");

        // 从用户账户收取 tokenA
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        
        // 向用户发送 tokenB
        tokenB.transfer(msg.sender, amountBOut);

        // 更新储备量
        // 注意：reserveA 增加的是扣除手续费后的金额
        reserveA += amountAInWithFee;
        reserveB -= amountBOut;

        // 触发交换事件
        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    /// @notice 用 tokenB 交换 tokenA
    /// @param amountBIn 输入的 tokenB 数量
    /// @param minAOut 最小输出的 tokenA 数量（滑点保护）
    /// @dev 与 swapAforB 对称，只是方向相反
    function swapBforA(uint256 amountBIn, uint256 minAOut) external {
        // 检查输入金额大于 0
        require(amountBIn > 0, "Amount must be > 0");
        
        // 检查池子有足够的流动性
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        // 计算扣除手续费后的输入金额
        uint256 amountBInWithFee = amountBIn * 997 / 1000;
        
        // 使用恒定乘积公式计算输出数量
        uint256 amountAOut = reserveA * amountBInWithFee / (reserveB + amountBInWithFee);

        // 检查滑点
        require(amountAOut >= minAOut, "Slippage too high");

        // 收取 tokenB，发送 tokenA
        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        // 更新储备量
        reserveB += amountBInWithFee;
        reserveA -= amountAOut;

        // 触发交换事件
        emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }

    // ==================== 查询函数 ====================
    
    /// @notice 查看当前储备量
    /// @return 代币 A 的储备量
    /// @return 代币 B 的储备量
    /// @dev view 函数，不消耗 gas，用于前端查询
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    // ==================== 工具函数 ====================
    
    /// @notice 返回两个数中的较小值
    /// @param a 第一个数
    /// @param b 第二个数
    /// @return 较小的那个数
    /// @dev internal pure: 内部纯函数，不读取状态
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /// @notice 计算平方根（巴比伦算法）
    /// @param y 输入值
    /// @return z 平方根结果
    /// @dev 使用牛顿迭代法计算整数平方根
    /// @dev 用于首次添加流动性时计算 LP 代币数量
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            // 牛顿迭代：x_{n+1} = (y / x_n + x_n) / 2
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // 如果 y == 0，z 保持为 0
    }
}

// ==================== 合约设计要点说明 ====================
//
// 1. AMM 核心概念:
//    - 自动化做市商（AMM）: 使用算法而不是订单簿来定价
//    - 恒定乘积公式: x * y = k，保持两种代币储备的乘积不变
//    - 流动性提供者（LP）: 向池子存入代币，赚取交易手续费
//    - LP 代币: 代表提供者在池子中的份额，可以赎回原始代币
//
// 2. 数学原理:
//    - 价格发现: 价格 = reserveA / reserveB（相对价格）
//    - 交换公式: amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee)
//    - 手续费: 0.3%，通过 997/1000 计算
//    - 无常损失: LP 可能因价格波动而遭受的损失
//
// 3. 使用流程:
//    添加流动性:
//    1. 用户 approve AMM 合约使用其 tokenA 和 tokenB
//    2. 调用 addLiquidity(amountA, amountB)
//    3. 合约铸造 LP 代币给用户
//    
//    交换代币:
//    1. 用户 approve AMM 合约使用其输入代币
//    2. 调用 swapAforB(amountAIn, minBOut)
//    3. 合约计算输出数量并转账
//    
//    移除流动性:
//    1. 用户调用 removeLiquidity(liquidityAmount)
//    2. 合约销毁 LP 代币
//    3. 合约按比例返还 tokenA 和 tokenB
//
// 4. 安全机制:
//    - 滑点保护: minBOut/minAOut 参数防止大额滑点
//    - 先更新状态: 遵循 Checks-Effects-Interactions 模式
//    - require 检查: 各种前置条件验证
//
// 5. 与 Uniswap 的区别:
//    - 这是 V1 风格，Uniswap 现在使用 V3 集中流动性
//    - 没有闪电贷功能
//    - 没有价格预言机
//    - 手续费固定为 0.3%，不能调整
//
// 6. 潜在问题:
//    - 没有重入锁保护（虽然遵循了先更新状态的原则）
//    - 没有紧急暂停功能
//    - 首次添加流动性可以任意定价（需要谨慎）
//
// 7. 关键知识点:
//    - ERC20 标准: 代币接口和交互
//    - 恒定乘积做市商（CPMM）算法
//    - LP 代币机制: 份额证明和收益分配
//    - 滑点（Slippage）: 大额交易对价格的影响
//    - 牛顿迭代法: 计算平方根
