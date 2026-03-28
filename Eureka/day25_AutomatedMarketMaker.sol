// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AutomatedMarketMaker is ERC20 
{
    IERC20 public tokenA;
    IERC20 public tokenB;

    uint256 public reserveA;//跟踪当前锁定在 AMM 合约中的每种代币数量
    uint256 public reserveB;

    address public owner;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    //添加代币到池子里，获得LP代币
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    //移除池子里的流动资金
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);
    //兑换
    constructor(address _tokenA, address _tokenB, string memory _name, string memory _symbol) ERC20(_name, _symbol) //LP代币的名称和符号
    {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");

        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);//发送代币到池子

        uint256 liquidity;
        if (totalSupply() == 0)//第一个添加流动性的人 
        {
            liquidity = sqrt(amountA * amountB);
        } else {//根据比例贡献来计算用户应获得的 LP 代币数量
            liquidity = min(
                amountA * totalSupply() / reserveA,
                amountB * totalSupply() / reserveB
            );
        }

        _mint(msg.sender, liquidity);//铸造 LP 代币

        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
    }

    function removeLiquidity(uint256 liquidityToRemove) external returns (uint256 amountAOut, uint256 amountBOut) {
        require(liquidityToRemove > 0, "Liquidity to remove must be > 0");
        require(balanceOf(msg.sender) >= liquidityToRemove, "Insufficient liquidity tokens");

        uint256 totalLiquidity = totalSupply();
        require(totalLiquidity > 0, "No liquidity in the pool");

        amountAOut = liquidityToRemove * reserveA / totalLiquidity;
        amountBOut = liquidityToRemove * reserveB / totalLiquidity;

        require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves for requested liquidity");

        reserveA -= amountAOut;
        reserveB -= amountBOut;

        _burn(msg.sender, liquidityToRemove);//销毁LP代币

        tokenA.transfer(msg.sender, amountAOut);
        tokenB.transfer(msg.sender, amountBOut);

        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);
        return (amountAOut, amountBOut);
    }

    //兑换
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
        require(amountAIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        uint256 amountAInWithFee = amountAIn * 997 / 1000;//手续费0.3%
        uint256 amountBOut = reserveB * amountAInWithFee / (reserveA + amountAInWithFee);

        require(amountBOut >= minBOut, "Slippage too high");//滑点保护

        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        reserveA += amountAInWithFee;
        reserveB -= amountBOut;

        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    /// @notice Swap token B for token A
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

    ///查看储备
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    // 返回较小的数（如果用户发送 100 个 A 和 150 个 B，我们只会用 100 个 A 和 100 个 B 来铸造 LP 代币 —— 多余的 50 个 B 会返还给池子）
    function min(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return a < b ? a : b;
    }
    //第一个提供流动性的人获得的 LP 代币数量为：sqrt(amountA * amountB)
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
