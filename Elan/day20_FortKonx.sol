// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title FortKnox
 * @dev 这是一个高度安全的资产托管合约逻辑。
 * 核心功能：存入 ERC20 代币、基于权限的提取、防止重入攻击。
 */
contract FortKnox is ReentrancyGuard, Ownable {
    // 资产映射：用户地址 => 代币地址 => 余额
    mapping(address => mapping(address => uint256)) private _balances;

    // 白名单代币：只有允许的代币才能存入
    mapping(address => bool) public whitelistedTokens;

    event Deposited(address indexed user, address indexed token, uint256 amount);
    event Withdrawn(address indexed user, address indexed token, uint256 amount);
    event TokenWhitelisted(address indexed token, bool status);

   constructor() Ownable(msg.sender) {}

    /**
     * @notice 设置代币白名单状态
     */
    function setTokenWhitelist(address token, bool status) external onlyOwner {
        whitelistedTokens[token] = status;
        emit TokenWhitelisted(token, status);
    }

    /**
     * @notice 存入代币到金库
     * @param token 代币合约地址
     * @param amount 存入数量
     */
    function deposit(address token, uint256 amount) external nonReentrant {
        require(whitelistedTokens[token], "Token not whitelisted");
        require(amount > 0, "Amount must be greater than 0");

        // 将代币从用户转入金库
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");

        // 记录余额
        _balances[msg.sender][token] += amount;

        emit Deposited(msg.sender, token, amount);
    }

    /**
     * @notice 从金库提取代币
     * @param token 代币合约地址
     * @param amount 提取数量
     */
    function withdraw(address token, uint256 amount) external nonReentrant {
        require(_balances[msg.sender][token] >= amount, "Insufficient balance");
        
        // 先修改状态，后转账（防止重入的黄金法则）
        _balances[msg.sender][token] -= amount;

        // 执行转账
        bool success = IERC20(token).transfer(msg.sender, amount);
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, token, amount);
    }

    /**
     * @notice 查询用户在金库中的余额
     */
    function balanceOf(address user, address token) external view returns (uint256) {
        return _balances[user][token];
    }

    /**
     * @notice 紧急提取（通常用于合约升级或特殊维护）
     * 仅管理员可调用，将特定代币转给特定地址
     */
    function emergencyWithdraw(address token, address to, uint256 amount) external onlyOwner {
        uint256 vaultBalance = IERC20(token).balanceOf(address(this));
        require(vaultBalance >= amount, "Exceeds vault balance");
        IERC20(token).transfer(to, amount);
    }
}
