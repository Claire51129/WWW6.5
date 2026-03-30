// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SimpleStableCoin
 * @dev 超额抵押稳定币系统基石
 * 文件名: day29_stable_coin.sol
 */
contract day29_stable_coin is ERC20, Ownable, ReentrancyGuard {
    IERC20 public immutable collateralToken; // 抵押代币 (例如 WETH)
    address public priceOracle;              // 价格预言机地址

    uint256 public constant LIQUIDATION_THRESHOLD = 150; // 150% 抵押率要求
    uint256 public constant PRECISION = 1e18;            // 精度基数

    // 用户在合约中锁定的抵押品数量
    mapping(address => uint256) public collateralBalances;

    event Minted(address indexed user, uint256 collateralAmount, uint256 mintAmount);
    event Redeemed(address indexed user, uint256 stableCoinAmount, uint256 collateralAmount);
    event OracleUpdated(address indexed newOracle);

    constructor(
        address _collateralToken,
        address _priceOracle,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) Ownable(msg.sender) {
        collateralToken = IERC20(_collateralToken);
        priceOracle = _priceOracle;
    }

    // ================= 核心业务逻辑 =================

    /**
     * @dev 铸造稳定币
     * @param collateralAmount 存入的抵押品数量
     * @param mintAmount 计划铸造的稳定币数量
     */
    function mint(uint256 collateralAmount, uint256 mintAmount) external nonReentrant {
        require(collateralAmount > 0, "Collateral must be > 0");
        require(mintAmount > 0, "Mint amount must be > 0");

        // 1. 转移抵押品：用户需先执行 collateralToken.approve(this, amount)
        require(collateralToken.transferFrom(msg.sender, address(this), collateralAmount), "Transfer failed");
        collateralBalances[msg.sender] += collateralAmount;

        // 2. 抵押率检查
        uint256 price = getAssetPrice(); 
        // 计算用户总抵押品价值 (以 USD 计，保持 18 位精度)
        uint256 totalCollateralValue = (collateralBalances[msg.sender] * price) / PRECISION;
        
        // 核心公式：总抵押价值 >= (当前已铸造 + 本次新铸造) * 1.5
        // 为了简化基础作业逻辑，这里检查用户本次铸造后的总负债是否安全
        uint256 totalDebtAfterMint = balanceOf(msg.sender) + mintAmount;
        require(totalCollateralValue >= (totalDebtAfterMint * LIQUIDATION_THRESHOLD) / 100, "Insecure collateral ratio");

        // 3. 铸造稳定币
        _mint(msg.sender, mintAmount);

        emit Minted(msg.sender, collateralAmount, mintAmount);
    }

    /**
     * @dev 赎回抵押品：销毁稳定币以取回抵押资产
     */
    function redeem(uint256 stableCoinAmount) external nonReentrant {
        require(stableCoinAmount > 0, "Amount must be > 0");
        require(balanceOf(msg.sender) >= stableCoinAmount, "Insufficient stablecoin");

        // 1. 根据当前价格计算应返还的抵押品数量
        uint256 price = getAssetPrice();
        uint256 collateralToReturn = (stableCoinAmount * PRECISION) / price;

        require(collateralBalances[msg.sender] >= collateralToReturn, "Insufficient collateral locked");

        // 2. 销毁稳定币（减少负债）
        _burn(msg.sender, stableCoinAmount);

        // 3. 更新余额并返还抵押品
        collateralBalances[msg.sender] -= collateralToReturn;
        require(collateralToken.transfer(msg.sender, collateralToReturn), "Transfer back failed");

        emit Redeemed(msg.sender, stableCoinAmount, collateralToReturn);
    }

    // ================= 辅助与管理 =================

    /**
     * @dev 获取抵押资产价格（由预言机提供）
     */
    function getAssetPrice() public view returns (uint256) {
        // 调用预言机接口获取价格
        return IPriceOracle(priceOracle).getPrice();
    }

    /**
     * @dev 更新预言机地址
     */
    function setOracle(address _newOracle) external onlyOwner {
        require(_newOracle != address(0), "Invalid oracle");
        priceOracle = _newOracle;
        emit OracleUpdated(_newOracle);
    }

    /**
     * @dev 拒绝直接转账，强制使用业务函数
     */
    receive() external payable {
        revert("Direct payments not accepted");
    }
}

/**
 * @dev 预言机简单接口定义
 */
interface IPriceOracle {
    function getPrice() external view returns (uint256);
}