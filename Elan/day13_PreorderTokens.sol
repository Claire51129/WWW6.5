// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PreorderTokens {
    // 1. 设置代币价格：1 ETH 可以买多少个代币
    // 假设 1 ETH = 100 Tokens
    uint256 public constant TOKEN_PRICE = 100;

    // 2. 账本：记录用户预购的代币余额
    mapping(address => uint256) public tokenBalances;
    
    // 3. 记录合约总共筹集了多少 ETH
    uint256 public totalEthRaised;

    address public owner;

    event TokensPurchased(address indexed buyer, uint256 ethSpent, uint256 tokensReceived);

    constructor() {
        owner = msg.sender;
    }

    // 4. 购买功能：用户发送 ETH，获得代币额度
    function buyTokens() public payable {
        require(msg.value > 0, "Send some ETH to buy tokens");

        // 计算用户应该获得的代币数量
        // msg.value 是 Wei，所以结果也是带 18 位精度的代币单位
        uint256 amountToBuy = msg.value * TOKEN_PRICE;

        // 更新状态
        tokenBalances[msg.sender] += amountToBuy;
        totalEthRaised += msg.value;

        emit TokensPurchased(msg.sender, msg.value, amountToBuy);
    }

    // 5. 提现功能：管理员拿走筹集到的 ETH
    function withdrawFunds() public {
        require(msg.sender == owner, "Only owner can withdraw");
        
        uint256 amount = address(this).balance;
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Withdraw failed");
    }

    // 查看我的代币余额（为了方便显示，可以除以 10^18）
    function getMyTokenBalance() public view returns (uint256) {
        return tokenBalances[msg.sender];
    }
}