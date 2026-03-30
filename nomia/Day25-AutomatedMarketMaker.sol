// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 引入 OpenZeppelin 的 ERC20 实现
// 因为这个合约本身也要发行 ERC20 代币（LP token）
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 引入 ERC20 接口
// 用来和外部的 tokenA / tokenB 交互
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title 自动化做市（AMM）合约，带流动性代币
/// 这个合约同时做两件事：
/// 1. 作为 A/B 交易池
/// 2. 作为 LP token 合约
contract AutomatedMarketMaker is ERC20 {

    // 池子里的两种外部 ERC20 代币
    IERC20 public tokenA;
    IERC20 public tokenB;

    // 记录池子的储备量
    // 注意：这里是“手动记账”的储备，不是自动读取余额
    uint256 public reserveA;
    uint256 public reserveB;

    // 合约拥有者
    // 这份代码里只是记录了，但没有特别使用
    address public owner;

    /// @notice 添加流动性事件
    /// provider: 谁加的
    /// amountA / amountB: 加了多少 A 和 B
    /// liquidity: 发了多少 LP token
    event LiquidityAdded(
        address indexed provider,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    /// @notice 移除流动性事件
    /// provider: 谁移除的
    /// amountA / amountB: 取回多少 A 和 B
    /// liquidity: 烧掉多少 LP token
    event LiquidityRemoved(
        address indexed provider,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    /// @notice 代币交换事件
    /// trader: 交易者
    /// tokenIn / amountIn: 输入了什么币、多少
    /// tokenOut / amountOut: 输出了什么币、多少
    event TokensSwapped(
        address indexed trader,
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint256 amountOut
    );

    /// @notice 构造函数
    /// _tokenA / _tokenB: 两种交易代币的地址
    /// _name / _symbol: LP token 的名字和符号
    constructor(
        address _tokenA,
        address _tokenB,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        // 把传入地址转换成 IERC20 接口，方便后面调用 transfer / transferFrom
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);

        // 记录部署者
        owner = msg.sender;
    }

    /// @notice 添加流动性
    /// 用户要同时存入 tokenA 和 tokenB
    /// 合约会根据存入数量给用户铸造 LP token
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        // 两边数量都必须大于 0
        require(amountA > 0 && amountB > 0, "Amounts must be greater than 0");

        // 把用户的 tokenA 转进池子
        // 前提：用户已经先 approve 过这个合约
        require(
            tokenA.transferFrom(msg.sender, address(this), amountA),
            "Token A transfer failed"
        );

        // 把用户的 tokenB 转进池子
        require(
            tokenB.transferFrom(msg.sender, address(this), amountB),
            "Token B transfer failed"
        );

        // 用来记录这次应该发多少 LP token
        uint256 liquidity;

        // 如果当前 LP 总供应量为 0，说明这是第一次加流动性
        if (totalSupply() == 0) {
            // 初始 LP 数量 = sqrt(amountA * amountB)
            // 这是 AMM 里常见的初始化方法
            liquidity = sqrt(amountA * amountB);
        } else {
            // 如果池子已经存在，就按当前池子比例来算
            // 这里取较小值，是为了防止一边加太多还多发 LP
            liquidity = min(
                amountA * totalSupply() / reserveA,
                amountB * totalSupply() / reserveB
            );
        }

        // 给用户铸造 LP token
        // 因为本合约继承了 ERC20，所以能直接 _mint
        _mint(msg.sender, liquidity);

        // 更新池子储备
        reserveA += amountA;
        reserveB += amountB;

        // 记录事件
        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
    }

    /// @notice 移除流动性
    /// 用户把 LP token 交回来，按比例取回 tokenA 和 tokenB
    function removeLiquidity(uint256 liquidityToRemove)
        external
        returns (uint256 amountAOut, uint256 amountBOut)
    {
        // 要移除的 LP 数量必须大于 0
        require(
            liquidityToRemove > 0,
            "Liquidity to remove must be greater than 0"
        );

        // 用户手里的 LP token 必须够
        require(
            balanceOf(msg.sender) >= liquidityToRemove,
            "Insufficient liquidity"
        );

        // 当前池子里 LP 总量
        uint256 totalLiquidity = totalSupply();

        // 池子里必须真的有流动性
        require(totalLiquidity > 0, "No liquidity in the pool");

        // 按份额计算可以取回多少 A 和 B
        // 比如你烧掉 10% 的 LP，就拿走池子里 10% 的 A 和 B
        amountAOut = liquidityToRemove * reserveA / totalLiquidity;
        amountBOut = liquidityToRemove * reserveB / totalLiquidity;

        // 至少要能拿到东西
        require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves");

        // 先更新储备
        reserveA -= amountAOut;
        reserveB -= amountBOut;

        // 销毁用户的 LP token
        _burn(msg.sender, liquidityToRemove);

        // 把 A 和 B 转回给用户
        require(tokenA.transfer(msg.sender, amountAOut), "Token A transfer failed");
        require(tokenB.transfer(msg.sender, amountBOut), "Token B transfer failed");

        // 记录事件
        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);

        return (amountAOut, amountBOut);
    }

    /// @notice 用 tokenA 换 tokenB
    /// amountAIn: 用户输入多少 A
    /// minBOut: 用户可接受的最少 B 输出，防止滑点太高
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
        // 输入数量必须大于 0
        require(amountAIn > 0, "Amount must be greater than 0");

        // 池子里必须有储备
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        // 扣掉 0.3% 手续费
        // 只有 99.7% 用来参与定价
        uint256 amountAInWithFee = amountAIn * 997 / 1000;

        // 按 AMM 公式算出能换到多少 B
        // 这是恒定乘积模型的常见写法
        uint256 amountBOut =
            reserveB * amountAInWithFee / (reserveA + amountAInWithFee);

        // 如果实际能拿到的 B 小于用户可接受最低值，就回滚
        require(amountBOut >= minBOut, "Slippage too high");

        // 用户把 A 转进池子
        require(
            tokenA.transferFrom(msg.sender, address(this), amountAIn),
            "Token A transfer failed"
        );

        // 池子把 B 转给用户
        require(
            tokenB.transfer(msg.sender, amountBOut),
            "Token B transfer failed"
        );

        // 更新储备
        // 注意这里加的是完整的 amountAIn，不是扣费后的 amountAInWithFee
        // 因为手续费也留在池子里
        reserveA += amountAIn;
        reserveB -= amountBOut;

        // 记录事件
        emit TokensSwapped(
            msg.sender,
            address(tokenA),
            amountAIn,
            address(tokenB),
            amountBOut
        );
    }

    /// @notice 用 tokenB 换 tokenA
    /// 逻辑和上面的 swapAforB 是镜像关系
    function swapBforA(uint256 amountBIn, uint256 minAOut) external {
        // 输入数量必须大于 0
        require(amountBIn > 0, "Amount must be greater than 0");

        // 池子里必须有储备
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        // 扣掉 0.3% 手续费
        uint256 amountBInWithFee = amountBIn * 997 / 1000;

        // 按公式算出输出的 A
        uint256 amountAOut =
            reserveA * amountBInWithFee / (reserveB + amountBInWithFee);

        // 防滑点
        require(amountAOut >= minAOut, "Slippage too high");

        // 用户把 B 转进池子
        require(
            tokenB.transferFrom(msg.sender, address(this), amountBIn),
            "Token B transfer failed"
        );

        // 池子把 A 转给用户
        require(
            tokenA.transfer(msg.sender, amountAOut),
            "Token A transfer failed"
        );

        // 更新储备
        reserveB += amountBIn;
        reserveA -= amountAOut;

        // 记录事件
        emit TokensSwapped(
            msg.sender,
            address(tokenB),
            amountBIn,
            address(tokenA),
            amountAOut
        );
    }

    /// @notice 查看当前储备量
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    /// @dev 返回较小值
    /// 用于 addLiquidity 中的 LP 计算
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /// @dev 巴比伦算法求平方根
    /// 用于第一次添加流动性时计算初始 LP
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
        } else {
            z = 0;
        }
    }
}