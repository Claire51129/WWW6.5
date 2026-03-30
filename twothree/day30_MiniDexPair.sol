// SPDX-License-Identifier: MIT                                 
pragma solidity ^0.8.20;                                         

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";         // 标准代币接口
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";     // 安全锁，防止重复攻击

contract MiniDexPair is ReentrancyGuard {                       // 小型代币兑换交易所
    address public immutable tokenA;                            // 交易对：代币A（固定）
    address public immutable tokenB;                            // 交易对：代币B（固定）

    uint256 public reserveA;                                     // 池子中代币A的数量
    uint256 public reserveB;                                     // 池子中代币B的数量
    uint256 public totalLPSupply;                                // 流动性代币总发行量

    mapping(address => uint256) public lpBalances;              // 每个用户的流动性代币数量

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpMinted); // 添加流动性事件
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpBurned); // 移除流动性事件
    event Swapped(address indexed user, address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount); // 兑换成功事件

    constructor(address _tokenA, address _tokenB) {             // 部署时设置两个代币
        require(_tokenA != _tokenB, "Identical tokens");        // 两个代币不能一样
        require(_tokenA != address(0) && _tokenB != address(0), "Zero address"); // 地址不能为空

        tokenA = _tokenA;                                       // 设置代币A
        tokenB = _tokenB;                                       // 设置代币B
    }

    function sqrt(uint y) internal pure returns (uint z) {      // 计算平方根（内部工具）
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

    function min(uint256 a, uint256 b) internal pure returns (uint256) { // 取两个数里小的那个
        return a < b ? a : b;
    }

    function _updateReserves() private {                        // 更新池子储备量
        reserveA = IERC20(tokenA).balanceOf(address(this));     // 刷新代币A数量
        reserveB = IERC20(tokenB).balanceOf(address(this));     // 刷新代币B数量
    }

    function addLiquidity(uint256 amountA, uint256 amountB) external nonReentrant { // 用户添加流动性
        require(amountA > 0 && amountB > 0, "Invalid amounts"); // 数量必须大于0

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA); // 从用户转A到池子
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB); // 从用户转B到池子

        uint256 lpToMint;                                         // 要发给用户的流动性代币
        if (totalLPSupply == 0) {                                 // 第一次添加流动性
            lpToMint = sqrt(amountA * amountB);                  // 用平方根计算
        } else {                                                  // 非第一次
            lpToMint = min(
                (amountA * totalLPSupply) / reserveA,
                (amountB * totalLPSupply) / reserveB
            );
        }

        require(lpToMint > 0, "Zero LP minted");                // 不能铸造0个

        lpBalances[msg.sender] += lpToMint;                     // 给用户增加LP代币
        totalLPSupply += lpToMint;                              // 总供应量增加

        _updateReserves();                                      // 更新池子数量

        emit LiquidityAdded(msg.sender, amountA, amountB, lpToMint); // 广播成功
    }

    function removeLiquidity(uint256 lpAmount) external nonReentrant { // 取出流动性
        require(lpAmount > 0 && lpAmount <= lpBalances[msg.sender], "Invalid LP amount"); // 数量合法

        uint256 amountA = (lpAmount * reserveA) / totalLPSupply; // 计算能拿回多少A
        uint256 amountB = (lpAmount * reserveB) / totalLPSupply; // 计算能拿回多少B

        lpBalances[msg.sender] -= lpAmount;                     // 销毁用户的LP
        totalLPSupply -= lpAmount;                              // 总供应量减少

        IERC20(tokenA).transfer(msg.sender, amountA);           // 转回A给用户
        IERC20(tokenB).transfer(msg.sender, amountB);           // 转回B给用户

        _updateReserves();                                      // 更新池子

        emit LiquidityRemoved(msg.sender, amountA, amountB, lpAmount); // 广播成功
    }

    function getAmountOut(uint256 inputAmount, address inputToken) public view returns (uint256 outputAmount) {
        require(inputToken == tokenA || inputToken == tokenB, "Invalid input token"); // 输入代币必须是A或B

        bool isTokenA = inputToken == tokenA;
        (uint256 inputReserve, uint256 outputReserve) = isTokenA ? (reserveA, reserveB) : (reserveB, reserveA);

        uint256 inputWithFee = inputAmount * 997;              // 扣0.3%手续费
        uint256 numerator = inputWithFee * outputReserve;     // 计算公式分子
        uint256 denominator = (inputReserve * 1000) + inputWithFee; // 分母

        outputAmount = numerator / denominator;               // 算出能换多少
    }

    function swap(uint256 inputAmount, address inputToken) external nonReentrant { // 兑换代币
        require(inputAmount > 0, "Zero input");               // 输入不能是0
        require(inputToken == tokenA || inputToken == tokenB, "Invalid token"); // 代币合法

        address outputToken = inputToken == tokenA ? tokenB : tokenA; // 确定输出代币
        uint256 outputAmount = getAmountOut(inputAmount, inputToken); // 计算输出数量

        require(outputAmount > 0, "Insufficient output");     // 输出必须大于0

        IERC20(inputToken).transferFrom(msg.sender, address(this), inputAmount); // 收用户输入代币
        IERC20(outputToken).transfer(msg.sender, outputAmount); // 给用户输出代币

        _updateReserves();                                    // 更新池子数量

        emit Swapped(msg.sender, inputToken, inputAmount, outputToken, outputAmount); // 广播兑换成功
    }

    function getReserves() external view returns (uint256, uint256) { // 查看池子有多少钱
        return (reserveA, reserveB);
    }

    function getLPBalance(address user) external view returns (uint256) { // 查看用户LP数量
        return lpBalances[user];
    }

    function getTotalLPSupply() external view returns (uint256) { // 查看总LP
        return totalLPSupply;
    }
}
//这是一个超小型去中心化交易所（只支持两个币互换）
//用户存钱进池子 → 拿到利息凭证（LP 币）
//有人兑换币 → 扣 0.3% 手续费 → 分给存钱的人
//存的人随时可以把钱取回来