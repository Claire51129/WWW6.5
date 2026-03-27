// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 引入标准的 ERC20 协议，因为我们的“股权小票”(LP Token) 本身也是一种代币
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title 自动做市商合约 (AMM)
 * @notice 这是一个简易版的 Uniswap V2 模型，使用 x * y = k 恒定乘积公式
 */
contract AutomatedMarketMaker is ERC20 {
    // 交易对中的两种代币
    IERC20 public tokenA;
    IERC20 public tokenB;

    // 两种代币在池子里的实时库存（储备量）
    uint256 public reserveA;
    uint256 public reserveB;

    address public owner;

    // 事件：记录增加流动性、移除流动性和兑换
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);

    constructor(address _tokenA, address _tokenB, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    /**
     * @notice 添加流动性（合伙开店）
     * @dev 注入等比例的两种代币，并获得 LP Token（股权凭证）
     */
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");

        // 将用户的代币转入合约（需要用户先在代币合约里对本合约授权 approve）
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        uint256 liquidity;
        if (totalSupply() == 0) {
            // 如果是第一个开店的人，股权 = 两种代币数量乘积的平方根
            liquidity = sqrt(amountA * amountB);
        } else {
            // 如果不是第一个，必须按当前比例存入，股权取 A 和 B 比例中的最小值（防止白闝）
            liquidity = min(
                (amountA * totalSupply()) / reserveA,
                (amountB * totalSupply()) / reserveB
            );
        }

        // 铸造 LP Token 发给用户
        _mint(msg.sender, liquidity);

        // 更新库存
        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
    }

    /**
     * @notice 移除流动性（撤资分红）
     * @param liquidityToRemove 想要退回的股权凭证数量
     */
    function removeLiquidity(uint256 liquidityToRemove) external returns (uint256 amountAOut, uint256 amountBOut) {
        require(liquidityToRemove > 0, "Liquidity to remove must be > 0");
        require(balanceOf(msg.sender) >= liquidityToRemove, "Insufficient liquidity tokens");

        uint256 totalLiquidity = totalSupply();

        // 根据股权占比，计算用户能拿回多少代币（本金 + 手续费收益）
        amountAOut = (liquidityToRemove * reserveA) / totalLiquidity;
        amountBOut = (liquidityToRemove * reserveB) / totalLiquidity;

        require(amountAOut > 0 && amountBOut > 0, "No liquidity in the pool");

        // 更新库存
        reserveA -= amountAOut;
        reserveB -= amountBOut;

        // 销毁用户的 LP Token，并把钱转回去
        _burn(msg.sender, liquidityToRemove);
        tokenA.transfer(msg.sender, amountAOut);
        tokenB.transfer(msg.sender, amountBOut);

        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);
        return (amountAOut, amountBOut);
    }

    /**
     * @notice 用 A 换 B（自动兑换）
     * @param amountAIn 用户投入的 A 数量
     * @param minBOut 用户要求最少换回的 B 数量（防止滑点过大被割肉）
     */
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
        require(amountAIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        // 扣除 0.3% 的手续费 (1000 - 997 = 3)
        uint256 amountAInWithFee = (amountAIn * 997) / 1000;

        // 恒定乘积公式计算该给用户多少 B：dy = (y * dx) / (x + dx)
        uint256 amountBOut = (reserveB * amountAInWithFee) / (reserveA + amountAInWithFee);

        require(amountBOut >= minBOut, "Slippage too high");

        // 执行转账
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        // 更新库存
        reserveA += amountAIn; // 这里的库存增加的是原始投入
        reserveB -= amountBOut;

        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    /**
     * @notice 用 B 换 A（逻辑同上）
     */
    function swapBforA(uint256 amountBIn, uint256 minAOut) external {
        require(amountBIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        uint256 amountBInWithFee = (amountBIn * 997) / 1000;
        uint256 amountAOut = (reserveA * amountBInWithFee) / (reserveB + amountBInWithFee);

        require(amountAOut >= minAOut, "Slippage too high");

        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        reserveB += amountBIn;
        reserveA -= amountAOut;

        emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }

    // 查询当前池子里的库存
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    // 辅助工具：取两个数中的最小值
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    // 辅助工具：巴比伦开平方法计算平方根（链上计算的高级技巧）
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