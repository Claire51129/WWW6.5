// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入母合约ERC20（OpenZeppelin的标准ERC20，本合约继承它）
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Automated Market Maker with Liquidity Token（去中心化自动做市商，LP代币版）
contract AutomatedMarketMaker is ERC20 {
    // ==================== 状态变量：存储池子数据 ====================
    IERC20 public tokenA;    // 第一种代币（比如ETH）
    IERC20 public tokenB;    // 第二种代币（比如USDT）

    uint256 public reserveA;  // 池子中tokenA的储备量
    uint256 public reserveB;  // 池子中tokenB的储备量

    address public owner;     // 合约所有者（部署者）

    // ==================== 事件：记录所有操作，链上可查 ====================
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);

    // ==================== 构造函数：部署合约时初始化 ====================
    constructor(
        address _tokenA,    // tokenA的合约地址
        address _tokenB,    // tokenB的合约地址
        string memory _name, // LP代币的名字（比如AMM-LP）
        string memory _symbol // LP代币的符号（比如AMM-LP）
    ) ERC20(_name, _symbol) { // 继承母合约ERC20的构造函数
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    // ==================== 工具函数1：取两个数的最小值（内部用） ====================
    /// @dev Utility: Return the smaller of two values
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    // ==================== 工具函数2：巴比伦法开平方（内部用，算流动性） ====================
    /// @dev Utility: Babylonian square root
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

    // ==================== 功能1：添加流动性（LP操作，存A和B，拿LP代币） ====================
    /// @notice Add liquidity to the pool
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0"); // 必须存大于0的A和B

        // 把用户的A和B转到合约里
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        uint256 liquidity;
        if (totalSupply() == 0) {
            // 第一次加流动性：LP代币数量 = sqrt(amountA * amountB)（保证比例正确）
            liquidity = sqrt(amountA * amountB);
        } else {
            // 后续加流动性：按当前池子比例，取最小值，保证不破坏价格
            liquidity = min(
                amountA * totalSupply() / reserveA,
                amountB * totalSupply() / reserveB
            );
        }

        // 给用户 mint（铸造）LP代币，代表他在池子里的份额
        _mint(msg.sender, liquidity);

        // 更新池子的储备量
        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
    }

    // ==================== 功能2：移除流动性（LP操作，烧LP代币，拿回A和B+手续费） ====================
    /// @notice Remove liquidity from the pool
    function removeLiquidity(uint256 liquidityToRemove) external returns (uint256, uint256) {
        require(liquidityToRemove > 0, "Liquidity to remove must be > 0"); // 必须移除大于0的LP
        require(balanceOf(msg.sender) >= liquidityToRemove, "Insufficient liquidity"); // LP余额足够

        uint256 totalLiquidity = totalSupply(); // 池子总LP代币数量
        require(totalLiquidity > 0, "No liquidity in the pool"); // 池子必须有流动性

        // 计算能拿回的A和B：按LP份额比例
        uint256 amountAOut = liquidityToRemove * reserveA / totalLiquidity;
        uint256 amountBOut = liquidityToRemove * reserveB / totalLiquidity;

        require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves for removal"); // 拿回的钱必须大于0

        // 更新池子的储备量
        reserveA -= amountAOut;
        reserveB -= amountBOut;

        // 烧（销毁）用户的LP代币，代表份额消失
        _burn(msg.sender, liquidityToRemove);

        // 把A和B转给用户（含手续费，因为储备里有手续费）
        tokenA.transfer(msg.sender, amountAOut);
        tokenB.transfer(msg.sender, amountBOut);

        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);
        return (amountAOut, amountBOut);
    }

    // ==================== 功能3：用A换B（交易者操作，扣0.3%手续费） ====================
    /// @notice Swap token A for token B
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
        require(amountAIn > 0, "Amount must be > 0"); // 必须换大于0的A
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves"); // 池子必须有流动性

        // 扣0.3%手续费：amountAIn * 997 / 1000（1000-3=997，0.3%手续费给LP）
        uint256 amountAInWithFee = amountAIn * 997 / 1000;
        // 用恒定乘积公式算能拿到的B：reserveB * amountAInWithFee / (reserveA + amountAInWithFee)
        uint256 amountBOut = reserveB * amountAInWithFee / (reserveA + amountAInWithFee);

        require(amountBOut >= minBOut, "Slippage too high"); // 滑点检查：拿到的B不能低于最小值，防止价格滑太多

        // 把用户的A转到合约里
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        // 把B转给用户
        tokenB.transfer(msg.sender, amountBOut);

        // 更新池子的储备量
        reserveA += amountAInWithFee;
        reserveB -= amountBOut;

        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    // ==================== 功能4：用B换A（交易者操作，扣0.3%手续费） ====================
    /// @notice Swap token B for token A
    function swapBforA(uint256 amountBIn, uint256 minAOut) external {
        require(amountBIn > 0, "Amount must be > 0"); // 必须换大于0的B
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves"); // 池子必须有流动性

        // 扣0.3%手续费：amountBIn * 997 / 1000
        uint256 amountBInWithFee = amountBIn * 997 / 1000;
        // 用恒定乘积公式算能拿到的A：reserveA * amountBInWithFee / (reserveB + amountBInWithFee)
        uint256 amountAOut = reserveA * amountBInWithFee / (reserveB + amountBInWithFee);

        require(amountAOut >= minAOut, "Slippage too high"); // 滑点检查

        // 把用户的B转到合约里
        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        // 把A转给用户
        tokenA.transfer(msg.sender, amountAOut);

        // 更新池子的储备量
        reserveB += amountBInWithFee;
        reserveA -= amountAOut;

        emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }

    // ==================== 功能5：查询池子当前储备量（看价格） ====================
    /// @notice View the current reserves
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }
}