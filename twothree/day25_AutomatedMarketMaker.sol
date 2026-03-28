// SPDX-License-Identifier: MIT   
pragma solidity ^0.8.20;         

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";  // 导入标准代币工具
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // 导入代币接口

/// @title 自动化做市（AMM）合约，带流动性代币
contract AutomatedMarketMaker is ERC20 {  // 开始写AMM交易所合约
    IERC20 public tokenA;       // 定义池子中的第一种代币
    IERC20 public tokenB;       // 定义池子中的第二种代币

    uint256 public reserveA;    // 池子里面代币A的数量
    uint256 public reserveB;    // 池子里面代币B的数量

    address public owner;       // 合约的主人

    //添加流动性事件
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);  // 有人加钱时发通知
    //移除流动性事件
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity); // 有人撤钱时发通知
    //代币交换事件
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut); // 兑换代币时发通知

    //构造函数，初始化代币和流动性代币名称
    constructor(address _tokenA, address _tokenB, string memory _name, string memory _symbol) ERC20(_name, _symbol) {  // 部署合约时设置两个代币和流动性币名字
        tokenA = IERC20(_tokenA);  // 把传入的地址设为代币A
        tokenB = IERC20(_tokenB);  // 把传入的地址设为代币B
        owner = msg.sender;         // 部署合约的人是主人
    }

    //添加流动性
    function addLiquidity(uint256 amountA, uint256 amountB) external {  // 函数：用户给池子加钱
        require(amountA > 0 && amountB > 0, "Amounts must be greater than 0");  // 必须两种币都大于0

        // 从用户账户转入代币
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Token A transfer failed");  // 把用户的代币A转到池子
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "Token B transfer failed");  // 把用户的代币B转到池子

        uint256 liquidity;  // 定义要给用户的流动性币数量
        if (totalSupply() == 0) {  // 如果池子是第一次加钱
            liquidity = sqrt(amountA * amountB); // 按平方根计算初始流动性
        } else {  // 不是第一次
            liquidity = min(  // 取两种计算结果里更小的那个
                amountA * totalSupply() / reserveA,
                amountB * totalSupply() / reserveB
            );
        }

        _mint(msg.sender, liquidity); // 给用户铸造流动性代币

        reserveA += amountA;  // 池子A数量增加
        reserveB += amountB;  // 池子B数量增加

        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);  // 广播：加流动性成功
    }

    //移除流动性
    function removeLiquidity(uint256 liquidityToRemove) external returns (uint256 amountAOut, uint256 amountBOut) {  // 函数：用户撤资
        require(liquidityToRemove > 0, "Liquidity to remove must be greater than 0");  // 撤的数量必须大于0
        require(balanceOf(msg.sender) >= liquidityToRemove, "Insufficient liquidity");  // 用户必须有足够的流动性币

        uint256 totalLiquidity = totalSupply();  // 池子总流动性
        require(totalLiquidity > 0, "No liquidity in the pool");  // 池子不能是空的

        amountAOut = liquidityToRemove * reserveA / totalLiquidity;  // 计算能拿回多少A
        amountBOut = liquidityToRemove * reserveB / totalLiquidity;  // 计算能拿回多少B

        require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves");  // 拿回来的不能是0

        reserveA -= amountAOut;  // 池子A减少
        reserveB -= amountBOut;  // 池子B减少

        _burn(msg.sender, liquidityToRemove);  // 销毁用户的流动性代币

        require(tokenA.transfer(msg.sender, amountAOut), "Token A transfer failed");  // 把A转给用户
        require(tokenB.transfer(msg.sender, amountBOut), "Token B transfer failed");  // 把B转给用户

        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);  // 广播：撤资成功
        return (amountAOut, amountBOut);  // 返回拿到的两种币数量
    }

    //用代币A兑换代币B
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {  // 函数：A换B
        require(amountAIn > 0, "Amount must be greater than 0");  // 投入数量必须大于0
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");  // 池子必须有两种币

        uint256 amountAInWithFee = amountAIn * 997 / 1000; // 扣0.3%手续费
        uint256 amountBOut = reserveB * amountAInWithFee / (reserveA + amountAInWithFee);  // 算能换多少B

        require(amountBOut >= minBOut, "Slippage too high");  // 滑点保护，不能换太少

        require(tokenA.transferFrom(msg.sender, address(this), amountAIn), "Token A transfer failed");  // 收用户的A
        require(tokenB.transfer(msg.sender, amountBOut), "Token B transfer failed");  // 给用户B

        reserveA += amountAIn;  // 池子A变多
        reserveB -= amountBOut;  // 池子B变少

        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);  // 广播：兑换成功
    }

    //用代币B兑换代币A
    function swapBforA(uint256 amountBIn, uint256 minAOut) external {  // 函数：B换A
        require(amountBIn > 0, "Amount must be greater than 0");  // 投入数量必须大于0
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");  // 池子必须有两种币

        uint256 amountBInWithFee = amountBIn * 997 / 1000; // 扣0.3%手续费
        uint256 amountAOut = reserveA * amountBInWithFee / (reserveB + amountBInWithFee);  // 算能换多少A

        require(amountAOut >= minAOut, "Slippage too high");  // 滑点保护

        require(tokenB.transferFrom(msg.sender, address(this), amountBIn), "Token B transfer failed");  // 收用户的B
        require(tokenA.transfer(msg.sender, amountAOut), "Token A transfer failed");  // 给用户A

        reserveB += amountBIn;  // 池子B变多
        reserveA -= amountAOut;  // 池子A变少

        emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);  // 广播：兑换成功
    }

    //查看当前储备量
    function getReserves() external view returns (uint256, uint256) {  // 查看池子有多少钱
        return (reserveA, reserveB);  // 返回A和B的数量
    }

    //返回较小值
    function min(uint256 a, uint256 b) internal pure returns (uint256) {  // 小工具：取两个数里小的那个
        return a < b ? a : b;
    }

    //巴比伦平方根算法
    function sqrt(uint256 y) internal pure returns (uint256 z) {  // 小工具：计算平方根
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