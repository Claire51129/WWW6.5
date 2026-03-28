// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleAMM {
    uint256 public reserveA;
    uint256 public reserveB;

    mapping(address => uint256) public liquidityShares;
    uint256 public totalLiquidity;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 shareMinted);
    event SwappedAForB(address indexed user, uint256 amountAIn, uint256 amountBOut);
    event SwappedBForA(address indexed user, uint256 amountBIn, uint256 amountAOut);

    // 初始化池子 / 添加流动性
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Invalid amounts");

        uint256 share;

        if (totalLiquidity == 0) {
            // 第一次添加流动性
            share = _sqrt(amountA * amountB);
        } else {
            // 后续添加流动性需按比例
            uint256 shareA = (amountA * totalLiquidity) / reserveA;
            uint256 shareB = (amountB * totalLiquidity) / reserveB;
            require(shareA == shareB, "Must add in correct ratio");
            share = shareA;
        }

        require(share > 0, "Zero liquidity share");

        reserveA += amountA;
        reserveB += amountB;
        liquidityShares[msg.sender] += share;
        totalLiquidity += share;

        emit LiquidityAdded(msg.sender, amountA, amountB, share);
    }

    // 用 A 换 B
    function swapAForB(uint256 amountAIn) external returns (uint256 amountBOut) {
        require(amountAIn > 0, "Invalid input");
        require(reserveA > 0 && reserveB > 0, "Pool is empty");

        // 常数乘积公式 x * y = k
        uint256 k = reserveA * reserveB;
        uint256 newReserveA = reserveA + amountAIn;
        uint256 newReserveB = k / newReserveA;

        amountBOut = reserveB - newReserveB;
        require(amountBOut > 0, "Zero output");
        require(amountBOut < reserveB, "Insufficient liquidity");

        reserveA = newReserveA;
        reserveB = newReserveB;

        emit SwappedAForB(msg.sender, amountAIn, amountBOut);
    }

    // 用 B 换 A
    function swapBForA(uint256 amountBIn) external returns (uint256 amountAOut) {
        require(amountBIn > 0, "Invalid input");
        require(reserveA > 0 && reserveB > 0, "Pool is empty");

        uint256 k = reserveA * reserveB;
        uint256 newReserveB = reserveB + amountBIn;
        uint256 newReserveA = k / newReserveB;

        amountAOut = reserveA - newReserveA;
        require(amountAOut > 0, "Zero output");
        require(amountAOut < reserveA, "Insufficient liquidity");

        reserveA = newReserveA;
        reserveB = newReserveB;

        emit SwappedBForA(msg.sender, amountBIn, amountAOut);
    }

    // 查询 A 对 B 的价格（放大 1e18）
    function getPriceAInB() external view returns (uint256) {
        require(reserveA > 0, "No reserveA");
        return (reserveB * 1e18) / reserveA;
    }

    // 查询 B 对 A 的价格（放大 1e18）
    function getPriceBInA() external view returns (uint256) {
        require(reserveB > 0, "No reserveB");
        return (reserveA * 1e18) / reserveB;
    }

    // 查询池子信息
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    // 内部开平方函数
    function _sqrt(uint256 y) internal pure returns (uint256 z) {
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