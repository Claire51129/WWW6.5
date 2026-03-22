// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TipJar {
    // 管理员地址
    address public owner;
    
    // 构造函数：设置部署者为管理员
    constructor() {
        owner = msg.sender;
    }
    
    // 仅管理员可调用的修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    // 存储打赏记录
    event TipReceived(address indexed tipper, uint256 amount, string currency);
    
    // 管理员提现函数
    function withdrawTips() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
    // 基础ETH打赏函数
    function tipInEth() external payable {
        emit TipReceived(msg.sender, msg.value, "ETH");
    }
}