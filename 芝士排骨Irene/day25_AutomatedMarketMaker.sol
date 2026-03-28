// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入 OpenZeppelin 的 ERC-20 合约
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// 自动做市商合约
contract AutomatedMarketMaker is ERC20 {

    IERC20 public tokenA;   // 交易对中的代币 A
    IERC20 public tokenB;   // 交易对中的代币 B

    uint256 public reserveA;  // 池子里代币 A 的储备量
    uint256 public reserveB;  // 池子里代币 B 的储备量

    address public owner;

    // 事件
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);

    // 构造函数 - 传入两种代币的地址，以及 LP 代币的名称和符号
    constructor(address _tokenA, address _tokenB, string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    // 添加流动性 - 流动性提供者往池子里存入两种代币，获得 LP 代币作为凭证
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");

        // 从用户钱包把代币转到合约里（用户需要先 approve）
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        uint256 liquidity;
        if (totalSupply() == 0) {
            // 首次添加流动性：LP 代币数量 = 两种代币数量的几何平均数
            liquidity = sqrt(amountA * amountB);
        } else {
            // 后续添加：按现有比例计算，取较小值
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

    // 移除流动性 - 用 LP 代币换回两种代币
    function removeLiquidity(uint256 liquidityToRemove) external returns (uint256 amountAOut, uint256 amountBOut) {
        require(liquidityToRemove > 0, "Liquidity to remove must be > 0");
        require(balanceOf(msg.sender) >= liquidityToRemove, "Insufficient liquidity tokens");

        uint256 totalLiquidity = totalSupply();
        require(totalLiquidity > 0, "No liquidity in the pool");

        // 按持有的 LP 代币比例计算能取回多少代币
        amountAOut = liquidityToRemove * reserveA / totalLiquidity;
        amountBOut = liquidityToRemove * reserveB / totalLiquidity;

        require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves");

        // 更新储备量
        reserveA -= amountAOut;
        reserveB -= amountBOut;

        // 销毁 LP 代币（凭证用完就作废）
        _burn(msg.sender, liquidityToRemove);

        // 把代币转回给用户
        tokenA.transfer(msg.sender, amountAOut);
        tokenB.transfer(msg.sender, amountBOut);

        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);
        return (amountAOut, amountBOut);
    }

    // 用代币 A 换代币 B
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
        require(amountAIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        // 扣除 0.3% 手续费（Uniswap 的标准费率）
        uint256 amountAInWithFee = amountAIn * 997 / 1000;

        // 恒定乘积公式计算输出：
        uint256 amountBOut = reserveB * amountAInWithFee / (reserveA + amountAInWithFee);

        // 滑点保护：实际换到的 B 不能少于用户设定的最低值
        require(amountBOut >= minBOut, "Slippage too high");

        // 执行代币转移
        tokenA.transferFrom(msg.sender, address(this), amountAIn);  // 用户的 A 进池子
        tokenB.transfer(msg.sender, amountBOut);                      // 池子的 B 给用户

        // 更新储备量（注意：手续费部分留在池子里，不计入 reserveA）
        reserveA += amountAInWithFee;
        reserveB -= amountBOut;

        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    // 用代币 B 换代币 A（和上面完全对称，方向反过来）
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

    // 查询池子的储备量
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    // 计算任意交换的输出数量（纯计算，不执行交易）
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        public pure returns (uint256 amountOut) {
        require(amountIn > 0, "Amount in must be > 0");
        require(reserveIn > 0 && reserveOut > 0, "Insufficient reserves");

        // 和 swap 函数里的计算逻辑一样
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;

        amountOut = numerator / denominator;
    }

    // 取两个数中的较小值
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    // 计算平方根（巴比伦算法 / 牛顿迭代法）
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;       // 初始猜测值
            while (x < z) {               // 不断逼近真实值
                z = x;
                x = (y / x + x) / 2;     // 牛顿迭代公式
            }
        } else if (y != 0) {
            z = 1;                         // 1、2、3 的平方根取整都是 1
        }
        // y == 0 时 z 默认就是 0
    }
}