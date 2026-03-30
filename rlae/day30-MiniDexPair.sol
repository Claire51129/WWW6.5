// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol"; 
contract MiniDexPair is ReentrancyGuard {
    address public immutable tokenA;
    address public immutable tokenB;
    //这个特定DEX配对支持的两个代币  immutable 一次分配一个值（在构造函数内部） 并且比使用常规storage变量更节省gas
    //跟踪当前在池子中的每个代币数量 引用变量比不断调用balanceOf更快更便宜
    uint256 public reserveA;
    uint256 public reserveB;
    uint256 public totalLPSupply; //曾经铸造的LP代币总量
    mapping(address => uint256) public lpBalances; //跟踪谁拥有什么：lpBalances lpBalances[alice] = 1200;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpMinted);
    //当有人向池子添加流动性时触发此事件 回报收到了多少LP代币
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpBurned);
    //当有人从池子移除流动性时触发 销毁了多少LP代币
    event Swapped(address indexed user, address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount);
    //当有人从池子移除流动性时触发 销毁了多少LP代币
    //
    constructor(address _tokenA, address _tokenB) { //传入这个池子应该支持的两个代币地址
    require(_tokenA != _tokenB, "Identical tokens"); //rejected 同一个代币创建两次池子
    require(_tokenA != address(0) && _tokenB != address(0), "Zero address"); //确保我们没有为任一代币使用空地址

    tokenA = _tokenA;
    tokenB = _tokenB;
    } 
    //当储备中还没有代币时，我们不能使用通常的比例LP计算。相反，我们使用他们存入的代币数量的几何平均值来计算要铸造的LP代币
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
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
    }
    //通过实际读取合约中有多少代币来更新我们的内部跟踪变量 将这些值存储在reserveA和reserveB状态变量中，这样我们就不必一遍又一遍地调用balanceOf——这会花费更多gas并使代码混乱
    function _updateReserves() private { //内部
    reserveA = IERC20(tokenA).balanceOf(address(this));
    reserveB = IERC20(tokenB).balanceOf(address(this));
    }
    //向池子提供代币
    function addLiquidity(uint256 amountA, uint256 amountB) external nonReentrant {
    require(amountA > 0 && amountB > 0, "Invalid amounts");//不能添加零代币
    //将两种代币从用户钱包拉入池子
    IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
    IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
    //确定要铸造多少LP代币
    uint256 lpToMint;
    if (totalLPSupply == 0) {
        lpToMint = sqrt(amountA * amountB);
    } else {
        lpToMint = min(
            (amountA * totalLPSupply) / reserveA,
            (amountB * totalLPSupply) / reserveB
        );
    }

    require(lpToMint > 0, "Zero LP minted");

    lpBalances[msg.sender] += lpToMint; //将新的LP代币添加到用户余额
    totalLPSupply += lpToMint; //增加总LP供应量

    _updateReserves(); //更新储备

    emit LiquidityAdded(msg.sender, amountA, amountB, lpToMint);
    }
    //从池子中提取份额
    function removeLiquidity(uint256 lpAmount) external nonReentrant {
    require(lpAmount > 0 && lpAmount <= lpBalances[msg.sender], "Invalid LP amount");
    //make sure 用户实际上试图移除正数数量 && <= 他们拥有的
    //计算要返回多少每种代币
    uint256 amountA = (lpAmount * reserveA) / totalLPSupply;
    uint256 amountB = (lpAmount * reserveB) / totalLPSupply;
    //销毁LP代币
    lpBalances[msg.sender] -= lpAmount;
    totalLPSupply -= lpAmount;
    //将代币转回给user
    IERC20(tokenA).transfer(msg.sender, amountA);
    IERC20(tokenB).transfer(msg.sender, amountB);

    _updateReserves(); //update 内部储备

    emit LiquidityRemoved(msg.sender, amountA, amountB, lpAmount);
    } 
    //计算交换-恒定乘积公式
    function getAmountOut(uint256 inputAmount, address inputToken) public view returns (uint256 outputAmount) {
    require(inputToken == tokenA || inputToken == tokenB, "Invalid input token");//用户必须交换tokenA或tokenB

    bool isTokenA = inputToken == tokenA; //确定交易的方向a-> B, else B->A
    (uint256 inputReserve, uint256 outputReserve) = isTokenA ? (reserveA, reserveB) : (reserveB, reserveA);
    //(x + Delta x) * (y - Delta y) = x * y-> deltax*y=deltay*(x+deltax)
    uint256 inputWithFee = inputAmount * 997; //collect 0.3%费用 
    uint256 numerator = inputWithFee * outputReserve; //deltax*y
    uint256 denominator = (inputReserve * 1000) + inputWithFee;  //(x+deltax)

    outputAmount = numerator / denominator;
    }
    //执行代币交换
    function swap(uint256 inputAmount, address inputToken) external nonReentrant {
    require(inputAmount > 0, "Zero input");
    require(inputToken == tokenA || inputToken == tokenB, "Invalid token");
    //确定输出代币-输入是TokenA，输出是TokenB——vice versa
    address outputToken = inputToken == tokenA ? tokenB : tokenA;
    //计算要发送回多少,调用刚刚的getAmountOut()
    uint256 outputAmount = getAmountOut(inputAmount, inputToken);

    require(outputAmount > 0, "Insufficient output");
    //转移代币
    IERC20(inputToken).transferFrom(msg.sender, address(this), inputAmount);
    IERC20(outputToken).transfer(msg.sender, outputAmount);

    _updateReserves(); //同步储备

    emit Swapped(msg.sender, inputToken, inputAmount, outputToken, outputAmount);
    }
    //返回池子中当前的TokenA和TokenB数量
    function getReserves() external view returns (uint256, uint256) {
    return (reserveA, reserveB);
    }
    //给定地址持有多少LP代币——本质上是他们在池子中的所有权份额
    function getLPBalance(address user) external view returns (uint256) {
    return lpBalances[user];
    }
    //返回曾经铸造的LP代币总数——等于所有个人LP余额的总和
    function getTotalLPSupply() external view returns (uint256) {
    return totalLPSupply;
    }




}