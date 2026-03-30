// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 OpenZeppelin 合约
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Mini DEX 交易对合约
/// @title Mini DEX Pair
/// @dev 一个简化的 Uniswap V2 风格 AMM 交易对合约
/// @dev 实现恒定乘积做市商（CPMM）算法
/// @dev 继承 ERC20 作为流动性代币（LP Token）
contract MiniDexPair is ERC20, ReentrancyGuard {
    
    // ==================== 状态变量 ====================
    
    /// @notice 代币 0 的合约地址
    /// @dev 按地址排序后较小的那个代币
    address public token0;
    
    /// @notice 代币 1 的合约地址
    /// @dev 按地址排序后较大的那个代币
    address public token1;

    /// @notice 代币 0 的储备量
    /// @dev 记录在合约中的 token0 数量
    uint256 public reserve0;
    
    /// @notice 代币 1 的储备量
    /// @dev 记录在合约中的 token1 数量
    uint256 public reserve1;

    // ==================== 事件 ====================
    
    /// @notice 储备量更新事件
    /// @param reserve0 新的 token0 储备量
    /// @param reserve1 新的 token1 储备量
    event Sync(uint256 reserve0, uint256 reserve1);
    
    /// @notice 交换事件
    /// @param sender 调用者地址
    /// @param amount0In 输入的 token0 数量
    /// @param amount1In 输入的 token1 数量
    /// @param amount0Out 输出的 token0 数量
    /// @param amount1Out 输出的 token1 数量
    /// @param to 接收代币的地址
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    // ==================== 构造函数 ====================
    
    /// @notice 创建交易对合约
    /// @param _token0 代币 0 地址（排序后较小）
    /// @param _token1 代币 1 地址（排序后较大）
    /// @dev 初始化 ERC20 作为 LP 代币，名称为 "MiniDex-LP"，符号为 "MDX-LP"
    constructor(address _token0, address _token1) ERC20("MiniDex-LP", "MDX-LP") {
        token0 = _token0;
        token1 = _token1;
    }

    // ==================== 流动性管理 ====================
    
    /// @notice 添加流动性
    /// @param amount0 要添加的 token0 数量
    /// @param amount1 要添加的 token1 数量
    /// @return liquidity 铸造的 LP 代币数量
    /// @dev 用户需要提前授权合约使用其代币
    function addLiquidity(uint256 amount0, uint256 amount1) external returns (uint256 liquidity) {
        // 从用户账户转移代币到合约
        // transferFrom 需要用户提前 approve
        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), amount1);

        // 获取当前 LP 代币总供应量
        uint256 totalSupply = totalSupply();
        
        if (totalSupply == 0) {
            // 首次添加流动性：使用几何平均数
            // 公式：liquidity = sqrt(amount0 * amount1)
            // 这样可以确保不同比例的池子有公平的 LP 代币分配
            liquidity = sqrt(amount0 * amount1);
        } else {
            // 后续添加流动性：按比例分配
            // 取两个代币按比例计算的最小值，防止套利
            // 公式：liquidity = min(amount0/reserve0, amount1/reserve1) * totalSupply
            liquidity = min(
                (amount0 * totalSupply) / reserve0,
                (amount1 * totalSupply) / reserve1
            );
        }

        // 检查铸造的流动性大于 0
        require(liquidity > 0, "Insufficient liquidity minted");
        
        // 铸造 LP 代币给提供者
        _mint(msg.sender, liquidity);
        
        // 更新储备量
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)));
    }

    /// @notice 移除流动性
    /// @param liquidity 要销毁的 LP 代币数量
    /// @return amount0 取出的 token0 数量
    /// @return amount1 取出的 token1 数量
    /// @dev 用户需要持有 LP 代币才能移除流动性
    function removeLiquidity(uint256 liquidity) external returns (uint256 amount0, uint256 amount1) {
        // 获取合约当前的代币余额
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        
        // 获取 LP 代币总供应量
        uint256 totalSupply = totalSupply();

        // 计算用户可以取出的代币数量
        // 公式：取出数量 = (LP 数量 / 总 LP 数量) * 合约余额
        amount0 = (liquidity * balance0) / totalSupply;
        amount1 = (liquidity * balance1) / totalSupply;

        // 检查计算出的数量大于 0
        require(amount0 > 0 && amount1 > 0, "Insufficient amount");

        // 销毁用户的 LP 代币
        _burn(msg.sender, liquidity);
        
        // 将代币转还给用户
        IERC20(token0).transfer(msg.sender, amount0);
        IERC20(token1).transfer(msg.sender, amount1);

        // 更新储备量
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)));
    }

    // ==================== 代币交换 ====================
    
    /// @notice 交换代币
    /// @param amount0Out 要输出的 token0 数量
    /// @param amount1Out 要输出的 token1 数量
    /// @param to 接收输出代币的地址
    /// @dev 使用恒定乘积公式：x * y = k
    /// @dev 至少一个输出数量必须大于 0
    function swap(uint256 amount0Out, uint256 amount1Out, address to) external nonReentrant {
        // 检查至少有一个输出数量大于 0
        require(amount0Out > 0 || amount1Out > 0, "Insufficient output amount");
        
        // 检查输出数量不超过储备量
        require(amount0Out < reserve0 && amount1Out < reserve1, "Insufficient liquidity");

        // 发送输出代币给接收者
        if (amount0Out > 0) IERC20(token0).transfer(to, amount0Out);
        if (amount1Out > 0) IERC20(token1).transfer(to, amount1Out);

        // 获取转账后的合约余额
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        // 恒定乘积公式检查：x * y >= k
        // 注意：这个简化版本没有收取手续费
        // 真实 Uniswap 会在这里计算并扣除手续费
        require(balance0 * balance1 >= reserve0 * reserve1, "K");

        // 更新储备量
        _update(balance0, balance1);
        
        // 触发交换事件
        emit Swap(
            msg.sender,
            balance0 > reserve0 ? balance0 - reserve0 : 0,
            balance1 > reserve1 ? balance1 - reserve1 : 0,
            amount0Out,
            amount1Out,
            to
        );
    }

    // ==================== 内部函数 ====================
    
    /// @notice 更新储备量
    /// @param balance0 新的 token0 余额
    /// @param balance1 新的 token1 余额
    /// @dev 私有函数，在流动性变化或交换后调用
    function _update(uint256 balance0, uint256 balance1) private {
        reserve0 = balance0;
        reserve1 = balance1;
        emit Sync(reserve0, reserve1);
    }

    // ==================== 数学工具函数 ====================
    
    /// @notice 计算平方根（巴比伦算法）
    /// @param y 输入值
    /// @return z 平方根结果
    /// @dev 使用牛顿迭代法计算整数平方根
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

    /// @notice 返回两个数中的较小值
    /// @param a 第一个数
    /// @param b 第二个数
    /// @return 较小的那个数
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

// ==================== 合约设计要点说明 ====================
//
// 1. DEX 交易对核心概念:
//    - 交易对（Pair）: 两种代币组成的流动性池
//    - 恒定乘积公式: x * y = k，保持两种代币储备的乘积不变
//    - LP 代币: 流动性证明，代表提供者在池子中的份额
//    - 储备量（Reserves）: 记录在合约中的代币数量
//
// 2. 数学原理:
//    恒定乘积公式: reserve0 * reserve1 = k（常数）
//    
//    交换计算:
//    - 用户输入 amountIn，想要 amountOut
//    - 新储备量: reserve0' = reserve0 + amountIn, reserve1' = reserve1 - amountOut
//    - 必须满足: reserve0' * reserve1' >= reserve0 * reserve1
//    
//    价格发现:
//    - 代币 0 的价格 = reserve1 / reserve0
//    - 代币 1 的价格 = reserve0 / reserve1
//
// 3. 使用流程:
//    添加流动性:
//    1. 用户 approve 两种代币给 Pair 合约
//    2. 调用 addLiquidity(amount0, amount1)
//    3. 获得 LP 代币
//    
//    交换代币:
//    1. 用户计算想要获得的输出数量
//    2. 调用 swap(amount0Out, amount1Out, to)
//    3. 合约自动计算需要输入的数量
//    
//    移除流动性:
//    1. 用户持有 LP 代币
//    2. 调用 removeLiquidity(liquidity)
//    3. 按比例取回两种代币
//
// 4. 与 Uniswap V2 的区别:
//    - 本合约是简化版，没有收取交易手续费
//    - Uniswap V2 收取 0.3% 手续费，分配给 LP 持有者
//    - Uniswap V2 有更复杂的价格预言机功能
//    - Uniswap V2 使用 create2 部署交易对
//
// 5. 安全机制:
//    - ReentrancyGuard: 防止交换时的重入攻击
//    - 恒定乘积检查: 确保交换符合 AMM 规则
//    - 储备量更新: 每次操作后更新储备量
//
// 6. 关键知识点:
//    - AMM（自动化做市商）原理
//    - 恒定乘积公式（x * y = k）
//    - LP 代币机制
//    - 价格发现机制
//    - 平方根计算（牛顿迭代法）
//
