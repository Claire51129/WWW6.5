// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title 极简去中心化交易所交易对 (MiniDexPair)
 * @notice 独立运行版：手动实现接口与防重入，直接上传不报错
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract MiniDexPair {
    // --- 基础状态变量 (代币基本信息) ---
    address public tokenA;
    address public tokenB;

    // --- 业务逻辑变量 (流动性池参数) ---
    uint256 public reserveA; 
    uint256 public reserveB; 
    bool private _locked; // 手动实现 nonReentrant 锁

    // --- 事件 ---
    event Swap(address indexed user, address inputToken, uint256 inputAmount, uint256 outputAmount);
    event Sync(uint256 reserveA, uint256 reserveB);

    // 防重入装饰器
    modifier nonReentrant() {
        require(!_locked, "ReentrancyGuard: reentrant call");
        _locked = true;
        _;
        _locked = false;
    }

    constructor(address _tokenA, address _tokenB) {
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid addresses");
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    /**
     * @dev 核心交换功能
     * @param inputAmount 输入代币数量
     * @param inputToken 输入代币地址
     */
    function swap(uint256 inputAmount, address inputToken) external nonReentrant {
        require(inputAmount > 0, "Zero input amount");
        require(inputToken == tokenA || inputToken == tokenB, "Invalid input token");

        address outputToken = (inputToken == tokenA) ? tokenB : tokenA;
        uint256 outputAmount = getAmountOut(inputAmount, inputToken);
        
        require(outputAmount > 0, "Insufficient output amount");

        // 执行转账：先收钱，再发钱
        bool successIn = IERC20(inputToken).transferFrom(msg.sender, address(this), inputAmount);
        require(successIn, "Transfer from user failed");

        bool successOut = IERC20(outputToken).transfer(msg.sender, outputAmount);
        require(successOut, "Transfer to user failed");

        // 更新内部储备量账本
        _updateReserves();

        emit Swap(msg.sender, inputToken, inputAmount, outputAmount);
    }

    /**
     * @dev 数学引擎：基于恒定乘积公式计算输出 (x * y = k)
     * 公式推导：(x + Δx * 0.997) * (y - Δy) = x * y
     */
    function getAmountOut(uint256 inputAmount, address inputToken) public view returns (uint256) {
        (uint256 resIn, uint256 resOut) = (inputToken == tokenA) ? (reserveA, reserveB) : (reserveB, reserveA);
        
        require(resIn > 0 && resOut > 0, "Liquidity is zero");

        uint256 inputWithFee = inputAmount * 997; // 扣除 0.3% 手续费
        uint256 numerator = inputWithFee * resOut;
        uint256 denominator = (resIn * 1000) + inputWithFee;
        
        return numerator / denominator;
    }

    /**
     * @dev 同步实际余额到储备量账本
     */
    function _updateReserves() private {
        reserveA = IERC20(tokenA).balanceOf(address(this));
        reserveB = IERC20(tokenB).balanceOf(address(this));
        emit Sync(reserveA, reserveB);
    }

    /**
     * @notice 特别说明：实际使用前需向合约转入代币并手动触发此函数初始化储备
     */
    function sync() external {
        _updateReserves();
    }
}
