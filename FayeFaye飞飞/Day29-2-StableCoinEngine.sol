// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStableCoin {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function balanceOf(address user) external view returns (uint256);
}

contract StableCoinEngine {
    IStableCoin public stable;

    // 抵押余额
    mapping(address => uint256) public collateral;

    // 借款余额
    mapping(address => uint256) public debt;

    // 抵押率 150%
    uint256 public collateralRatio = 150;

    constructor(address _stable) {
        stable = IStableCoin(_stable);
    }

    // 存入抵押（ETH）
    function depositCollateral() external payable {
        require(msg.value > 0, "Zero");

        collateral[msg.sender] += msg.value;
    }

    // 借 stablecoin
    function borrow(uint256 amount) external {
        uint256 maxBorrow = (collateral[msg.sender] * 100) / collateralRatio;

        require(debt[msg.sender] + amount <= maxBorrow, "Over borrow");

        debt[msg.sender] += amount;

        stable.mint(msg.sender, amount);
    }

    // 还款
    function repay(uint256 amount) external {
        require(debt[msg.sender] >= amount, "Too much");

        stable.burn(msg.sender, amount);

        debt[msg.sender] -= amount;
    }

    // 提取抵押
    function withdrawCollateral(uint256 amount) external {
        require(collateral[msg.sender] >= amount, "Not enough");

        uint256 remaining = collateral[msg.sender] - amount;

        uint256 maxBorrow = (remaining * 100) / collateralRatio;

        require(debt[msg.sender] <= maxBorrow, "Would liquidate");

        collateral[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
         require(success, "Withdraw failed");
    }

    // 清算（别人可以清算你）
    function liquidate(address user) external payable {
        uint256 maxBorrow = (collateral[user] * 100) / collateralRatio;

        require(debt[user] > maxBorrow, "Healthy");

        uint256 collateralToTake = collateral[user];

        collateral[user] = 0;
        debt[user] = 0;

        (bool success, ) = payable(msg.sender).call{value: collateralToTake}("");
         require(success, "Liquidation transfer failed");
    }
}