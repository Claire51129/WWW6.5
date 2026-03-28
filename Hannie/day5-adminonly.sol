//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract AdminOnly {
    address public owner; //合约所有者
    uint256 public treasureAmount; //宝藏总量

    //映射：记录每个地址的提取额度
    mapping(address => uint256) public withdrawalAllowance;
    //映射：记录每个地址是否已被提取
    mapping(address => bool) public hasWithdrawn;

    //构造函数：部署时设置owner
    constructor() {
        owner = msg.sender; //msg.sender 是 Solidity 内置全局变量，表示当前调用者的地址（部署合约时，调用者就是部署者，因此 owner 会被赋值为部署者地址）。
    }

    //修饰符：只允许owner调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _; //占位符，表示修饰的函数体会在这里执行
    }

    //只有owner能添加宝藏
    function addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount;
    }

    //任何人都可以提取（如果有额度）
    function withdrawTreasure(uint256 amount) public {
        require(
            amount <= withdrawalAllowance[msg.sender],
            "Insufficient allowance"
        );
        require(!hasWithdrawn[msg.sender], "Already withdrawn");

        hasWithdrawn[msg.sender] = true; //标记已提取
        withdrawalAllowance[msg.sender] -= amount; //扣除额度,等价于 withdrawalAllowance[msg.sender] = withdrawalAllowance[msg.sender] - amount，减少该用户剩余可提取额度。
    }

    //只有owner能充值提取状态
    function resetWithdrawalStatus(address user) public onlyOwner {
        //饰符：public + onlyOwner（仅所有者可调用）。
        hasWithdrawn[user] = false; //重置提取状态
    }

    //只有owner能转移所有权
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    //只有owner 能查看宝藏详情
    function getTreasureDetails() public view onlyOwner returns (uint256) {
        return treasureAmount;
    }
}
