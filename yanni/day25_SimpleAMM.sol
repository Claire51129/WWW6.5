// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 引入 OpenZeppelin 的 ERC20 标准实现（用于 LP Token）
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title 自动做市商（AMM）+ 流动性凭证（LP Token）
/// 存钱！取钱！兑换！
contract AutomatedMarketMaker is ERC20 {

    // ===== 代币地址 =====
    IERC20 public tokenA; // 交易对中的 Token A
    IERC20 public tokenB; // 交易对中的 Token B

    // ===== 储备量 =====
    uint256 public reserveA; // 池子中 A 的数量
    uint256 public reserveB; // 池子中 B 的数量

    address public owner; // 合约拥有者（部署者）

    // ===== 事件 =====
    event LiquidityAdded(
        address indexed provider, // 提供流动性的人
        uint256 amountA,          // 存入的 A 数量
        uint256 amountB,          // 存入的 B 数量
        uint256 liquidity         // 获得的 LP Token 数量
    );

    event LiquidityRemoved(
        address indexed provider,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    event TokensSwapped(
        address indexed trader,  // 交易者
        address tokenIn,         // 输入代币
        uint256 amountIn,        // 输入数量
        address tokenOut,        // 输出代币
        uint256 amountOut        // 输出数量
    );

    // ===== 构造函数 =====
    constructor(
        address _tokenA,
        address _tokenB,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    /// ===== 添加流动性 =====
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        // 必须存入大于 0 的数量
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");

        // 从用户账户转入代币到池子
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        uint256 liquidity;

        if (totalSupply() == 0) {
            // 第一次添加流动性：用 sqrt 计算初始 LP
            liquidity = sqrt(amountA * amountB);
        } else {
            // 按比例计算 LP Token（防止破坏池子价格）
            liquidity = min(
                (amountA * totalSupply()) / reserveA,
                (amountB * totalSupply()) / reserveB
            );
        }

        // 给用户铸造 LP Token（代表份额）
        _mint(msg.sender, liquidity);

        // 更新池子储备
        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
    }

    /// ===== 移除流动性 =====
    function removeLiquidity(uint256 liquidity)
        external
        returns (uint256 amountAOut, uint256 amountBOut)
    {
        require(liquidity > 0, "Must be > 0");
        require(balanceOf(msg.sender) >= liquidity, "Not enough LP");

        uint256 totalLiquidity = totalSupply();

        // 按比例计算应返还的资产
        amountAOut = (liquidity * reserveA) / totalLiquidity;
        amountBOut = (liquidity * reserveB) / totalLiquidity;

        require(amountAOut > 0 && amountBOut > 0, "Too small");

        // 更新储备
        reserveA -= amountAOut;
        reserveB -= amountBOut;

        // 销毁 LP Token
        _burn(msg.sender, liquidity);

        // 转回代币
        tokenA.transfer(msg.sender, amountAOut);
        tokenB.transfer(msg.sender, amountBOut);

        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidity);
    }

    /// ===== A → B 兑换 =====
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
        require(amountAIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "No liquidity");

        // 扣除 0.3% 手续费（997/1000）
        uint256 amountAInWithFee = (amountAIn * 997) / 1000;

        // 恒定乘积公式计算输出
        uint256 amountBOut =
            (reserveB * amountAInWithFee) /
            (reserveA + amountAInWithFee);

        // 防止滑点过大
        require(amountBOut >= minBOut, "Slippage too high");

        // 执行转账
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        // 更新储备
        reserveA += amountAInWithFee;
        reserveB -= amountBOut;

        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    /// ===== B → A 兑换 =====
    function swapBforA(uint256 amountBIn, uint256 minAOut) external {
        require(amountBIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "No liquidity");

        uint256 amountBInWithFee = (amountBIn * 997) / 1000;

        uint256 amountAOut =
            (reserveA * amountBInWithFee) /
            (reserveB + amountBInWithFee);

        require(amountAOut >= minAOut, "Slippage too high");

        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        reserveB += amountBInWithFee;
        reserveA -= amountAOut;

        emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }

    /// ===== 查看当前储备 =====
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    /// ===== 工具函数：取最小值 =====
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /// ===== 工具函数：平方根（流动性代币（LP token）初始分配的公平性）=====
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;

            // 迭代逼近平方根
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }

        } else if (y != 0) {
            z = 1;
        }
    }
}