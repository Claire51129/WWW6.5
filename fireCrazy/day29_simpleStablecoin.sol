// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 手动定义最小化接口
interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IPriceFeed {
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
}

/**
 * @title 简易稳定币合约 (SimpleStablecoin)
 * @notice 独立运行版：无需外部 import，直接上传不报错
 */
contract SimpleStablecoin {
    // ERC20 基础状态变量
    string public name = "Simple USD";
    string public symbol = "sUSD";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    // 业务变量
    IERC20 public collateralToken;
    IPriceFeed public priceFeed;
    uint256 public collateralizationRatio = 150; // 抵押率 150%
    bool private locked; // 简单的防重入锁

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Minted(address indexed user, uint256 amount, uint256 collateralUsed);

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    constructor(address _collateral, address _priceFeed) {
        collateralToken = IERC20(_collateral);
        priceFeed = IPriceFeed(_priceFeed);
    }

    /**
     * @dev 铸造稳定币
     * 逻辑：根据预言机价格计算所需的抵押品并转入合约，随后铸造 sUSD
     */
    function mint(uint256 stablecoinAmount) external nonReentrant {
        require(stablecoinAmount > 0, "Amount must be > 0");

        // 1. 获取价格（假设价格有 8 位小数）
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        uint256 ethPrice = uint256(price); 

        // 2. 算账 (公式简化处理)
        // 抵押品数量 = (想要印的币 * 抵押率) / 价格
        // 注意：此处假设 stablecoinAmount 和 ethPrice 的精度已经对齐
        uint256 requiredCollateral = (stablecoinAmount * collateralizationRatio) / (ethPrice / 1e6); 

        // 3. 转移抵押品
        bool success = collateralToken.transferFrom(msg.sender, address(this), requiredCollateral);
        require(success, "Collateral transfer failed");

        // 4. 铸造代币 (内部逻辑)
        balanceOf[msg.sender] += stablecoinAmount;
        totalSupply += stablecoinAmount;

        emit Transfer(address(0), msg.sender, stablecoinAmount);
        emit Minted(msg.sender, stablecoinAmount, requiredCollateral);
    }
}
