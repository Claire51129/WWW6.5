// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入 OpenZeppelin 的 ERC20 标准（用于创建流动性代币）
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title AutomatedMarketMaker
 * @notice 一个简单的 AMM 合约，类似 Uniswap V2 的核心逻辑
 * @dev 支持两种代币（tokenA 和 tokenB）的流动性添加/移除，以及两者之间的兑换
 *      合约本身也是一个 ERC20 代币，代表流动性份额（LP token）
 */
contract AutomatedMarketMaker is ERC20 {
    // 两种代币的接口
    IERC20 public tokenA;
    IERC20 public tokenB;

    // 池子中两种代币的储备量（实际合约持有的数量）
    uint256 public reserveA;
    uint256 public reserveB;

    // 合约所有者（一般用于管理，但本合约中未使用，可以删除）
    address public owner;

    // 事件
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);

    /**
     * @dev 构造函数：传入两种代币的地址，以及流动性代币的名称和符号
     * @param _tokenA 代币A的合约地址
     * @param _tokenB 代币B的合约地址
     * @param _name 流动性代币的名称（例如 "Uniswap V2"）
     * @param _symbol 流动性代币的符号（例如 "UNI-V2"）
     */
    constructor(address _tokenA, address _tokenB, string memory _name, string memory _symbol)
        ERC20(_name, _symbol)  // 初始化 ERC20 代币
    {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    /**
     * @notice 流动性提供者存入两种代币，获得 LP 代币
     * @dev 首次添加时，LP 代币数量 = sqrt(amountA * amountB)（恒定乘积公式）
     *      后续添加时，按现有比例计算，不得破坏当前比例
     * @param amountA 存入的代币A数量
     * @param amountB 存入的代币B数量
     */
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");

        // 将用户的两类代币转入本合约（需要用户先授权）
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        uint256 liquidity;
        if (totalSupply() == 0) {
            // 首次添加流动性：LP代币数量 = sqrt(amountA * amountB)
            liquidity = sqrt(amountA * amountB);
        } else {
            // 非首次：按两种代币现有储备比例计算，取较小的那个（避免比例失衡）
            liquidity = min(
                amountA * totalSupply() / reserveA,
                amountB * totalSupply() / reserveB
            );
        }

        // 铸造 LP 代币给流动性提供者
        _mint(msg.sender, liquidity);

        // 更新储备量
        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
    }

    /**
     * @notice 流动性提供者销毁 LP 代币，取回对应的两种代币
     * @param liquidityToRemove 要销毁的 LP 代币数量
     * @return amountAOut 取回代币A的数量
     * @return amountBOut 取回代币B的数量
     */
    function removeLiquidity(uint256 liquidityToRemove) external returns (uint256 amountAOut, uint256 amountBOut) {
        require(liquidityToRemove > 0, "Liquidity to remove must be > 0");
        require(balanceOf(msg.sender) >= liquidityToRemove, "Insufficient liquidity tokens");

        uint256 totalLiquidity = totalSupply();
        require(totalLiquidity > 0, "No liquidity in the pool");

        // 按 LP 代币占比计算可提取的代币数量
        amountAOut = liquidityToRemove * reserveA / totalLiquidity;
        amountBOut = liquidityToRemove * reserveB / totalLiquidity;

        require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves");

        // 更新储备量（减少）
        reserveA -= amountAOut;
        reserveB -= amountBOut;

        // 销毁 LP 代币
        _burn(msg.sender, liquidityToRemove);

        // 将两种代币转回给用户
        tokenA.transfer(msg.sender, amountAOut);
        tokenB.transfer(msg.sender, amountBOut);

        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);
        return (amountAOut, amountBOut);
    }

    /**
     * @notice 用代币A兑换代币B
     * @param amountAIn 用户支付的代币A数量
     * @param minBOut 最小期望得到的代币B数量（用于防止滑点）
     */
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
        require(amountAIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        // 扣除 0.3% 手续费（997/1000）
        uint256 amountAInWithFee = amountAIn * 997 / 1000;
        // 根据恒定乘积公式计算输出：x * y = k  =>  (reserveA + amountAInWithFee) * (reserveB - amountBOut) = k
        // 解得 amountBOut = reserveB * amountAInWithFee / (reserveA + amountAInWithFee)
        uint256 amountBOut = reserveB * amountAInWithFee / (reserveA + amountAInWithFee);

        // 检查滑点
        require(amountBOut >= minBOut, "Slippage too high");

        // 转移用户支付的代币A到合约
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        // 将代币B转给用户
        tokenB.transfer(msg.sender, amountBOut);

        // 更新储备量：注意手续费部分（amountAInWithFee 已包含手续费）会留在池中，所以 reserveA 增加 amountAInWithFee
        reserveA += amountAInWithFee;
        reserveB -= amountBOut;

        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    /**
     * @notice 用代币B兑换代币A（对称于 swapAforB）
     * @param amountBIn 用户支付的代币B数量
     * @param minAOut 最小期望得到的代币A数量
     */
    function swapBforA(uint256 amountBIn, uint256 minAOut) external {
        require(amountBIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        uint256 amountBInWithFee = amountBIn * 997 / 1000;
        uint256 amountAOut = reserveA * amountBInWithFee / (reserveB + amountBInWithFee);

        require(amountAOut >= minAOut, "Slippage too high");

        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        reserveB += amountBInWithFee;
        reserveA -= amountAOut;

        emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }

    /**
     * @notice 查看当前两种代币的储备量
     * @return reserveA 代币A储备
     * @return reserveB 代币B储备
     */
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    /**
     * @notice 根据给定输入数量，计算输出数量（供前端估算）
     * @param amountIn 输入的代币数量
     * @param reserveIn 输入代币的当前储备
     * @param reserveOut 输出代币的当前储备
     * @return amountOut 输出的代币数量
     */
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        public pure returns (uint256 amountOut) {
        require(amountIn > 0, "Amount in must be > 0");
        require(reserveIn > 0 && reserveOut > 0, "Insufficient reserves");

        // 带手续费的公式： amountOut = (amountIn * 997 * reserveOut) / (reserveIn * 1000 + amountIn * 997)
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    // 内部工具函数：返回两个数中的较小值
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    // 内部工具函数：计算平方根（用于首次添加流动性时计算 LP 数量）
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
