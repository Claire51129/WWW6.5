// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//x*y=k: 小额交易：对曲线影响极小，价格平稳,巨额交易：会把价格推向曲线的极端陡峭处，导致极其高昂的成交成本
contract AutomatedMarketMaker is ERC20 {
    IERC20 public tokenA; //存储 AMM 将管理的 ERC-20 代币的地址,类型是 IERC20，只是一个接口 
    IERC20 public tokenB;
    uint256 public reserveA; //踪当前锁定在 AMM 合约中的每种代币数量
    uint256 public reserveB;
    address public owner;
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity); //添加代币到池子时触发
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity); //移除池中流动性 时记录销毁了多少 LP 代币
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut); //用 10 DAI 换了 9.87 USDC
    constructor(address _tokenA, address _tokenB, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
        //_name：LP 代币名称 ,_symbol：LP 代币符号  string memory 临时传递这个字符串 —— 不是存储在固定长度的位置
        //ERC20(_name, _symbol)调用ECR20的构造函数设置 LP 代币的名称和符号
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b; //上面的条件为真 (True)，则返回 a
    } //希望根据哪个代币贡献较少来铸造 LP 代币 —— 这样可以保持比例稳定，防止铸造过多
    function sqrt(uint256 y) internal pure returns (uint256 z) { //巴比伦平方根算法
    if (y > 3) {
        z = y;
        uint256 x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1; //如果 squr y 是 1、2 或 3，它们的整数平方根都是 1。
    }
    }

    function addLiquidity(uint256 amountA, uint256 amountB) external {
    require(amountA > 0 && amountB > 0, "Amounts must be > 0");

    tokenA.transferFrom(msg.sender, address(this), amountA); //用户将Ta们的代币实际发送到合约
    tokenB.transferFrom(msg.sender, address(this), amountB);
    //要铸造的 LP 代币

    uint256 liquidity;
    if (totalSupply() == 0) {
        liquidity = sqrt(amountA * amountB);
    } else {
        liquidity = min(
            amountA * totalSupply() / reserveA, //比例贡献来计算用户应获得的 LP 代币数量
            amountB * totalSupply() / reserveB
        ); //使用 min() 函数避免当用户输入的代币数量稍有偏差时铸造过多 LP 代币
    } //你的贡献取决于你提供的资产中最少（最不成比例）的那一个

    _mint(msg.sender, liquidity); //把 LP 代币实际发给用户
    //更新储备量

    reserveA += amountA;
    reserveB += amountB;

    emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
    }
    //允许用户提取自己之前添加的代币份额
    function removeLiquidity(uint256 liquidityToRemove) external returns (uint256 amountAOut, uint256 amountBOut) {
    require(liquidityToRemove > 0, "Liquidity to remove must be > 0");
    require(balanceOf(msg.sender) >= liquidityToRemove, "Insufficient liquidity tokens");
    //why not combined together?检查 > 0 只需要读取内存中的参数，非常便宜。而 balanceOf(msg.sender) 需要读取状态变量（SLOAD），这是非常昂贵的操作短路保护：通过先执行廉价的 > 0 检查，如果失败了，合约会立即报错退出，从而避免了后面那个昂贵的“查询余额”操作，为用户节省了不必要的 Gas 消耗
    //分开写：如果交易失败，EVM 会返回具体的错误字符串。用户能立刻知道是自己“手滑输了个 0”（Must be > 0），还是“余额不足”（Insufficient liquidity tokens）
    uint256 totalLiquidity = totalSupply();
    require(totalLiquidity > 0, "No liquidity in the pool"); //获取 LP 代币 总供应量，这代表池子 100% 的所有权

    amountAOut = liquidityToRemove * reserveA / totalLiquidity; //为什么必须先乘后除？因为 Solidity 不支持小数（浮点数）
    amountBOut = liquidityToRemove * reserveB / totalLiquidity;

    require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves for requested liquidity");
    //更新内部储备量

    reserveA -= amountAOut;
    reserveB -= amountBOut;

    _burn(msg.sender, liquidityToRemove);

    tokenA.transfer(msg.sender, amountAOut);
    tokenB.transfer(msg.sender, amountBOut);

    emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);
    return (amountAOut, amountBOut);
    }
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
    require(amountAIn > 0, "Amount must be > 0");
    require(reserveA > 0 && reserveB > 0, "Insufficient reserves");
    //你尝试交换的次数越多，你的兑换率越差 —— 因为你推动了价格曲线

    uint256 amountAInWithFee = amountAIn * 997 / 1000; //从输入代币中扣除 0.3% 手续费,剩余的 0.3 保留在池子里，奖励流动性提供者
    uint256 amountBOut = reserveB * amountAInWithFee / (reserveA + amountAInWithFee);

    require(amountBOut >= minBOut, "Slippage too high"); //防止意外价格波动的影响

    tokenA.transferFrom(msg.sender, address(this), amountAIn);
    tokenB.transfer(msg.sender, amountBOut);

    reserveA += amountAInWithFee;
    reserveB -= amountBOut;

    emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }
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
    function getReserves() external view returns (uint256, uint256) {
    return (reserveA, reserveB); //仅返回两个数值：每个代币的当前储备
    }


}