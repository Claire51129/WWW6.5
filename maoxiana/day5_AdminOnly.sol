//SPDX-Llicense-Identifier: MIT
pragma solidity ^0.8.0;

contract AdminOnly {
    //状态变量
    address public owner;//管理员地址
    uint256 public treasureAmount;//宝藏数量
    mapping(address => uint256) public withdrawalAllowance;//提取额度
    mapping (address => bool) public hasWithdrawn;//是否已经提取过


    constructor() {
        owner = msg.sender;//部署合约的地址成为管理员
        //treasureAmount = 1000;//初始宝藏数量
        
    }

    //modifier（修饰符）让我们能够创建可以附加到函数中的可复用的小型权限检查逻辑。
    //这个修饰符会检查调用者是否是拥有者。如果不是，函数将不会继续执行。
    //符号 `_` 表示权限检查之后的函数主体将被插入的位置（它是一个占位符）。
    //使用这个修饰符，我们可以确保只有管理员才能执行特定的函数，例如设置宝藏数量或提取宝藏。
    modifier onlyOwner() {
        require(msg.sender == owner,"Access denied : Only the owner can perform this action.");
        _;
    }

    function  addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount;//增加宝藏数量
    }

    function approveWithdrawal(address recipient,uint256 amount)  public onlyOwner{
        require(amount <= treasureAmount,"Not enough treasure available.");//检查宝藏数量是否足够
        withdrawalAllowance[recipient] = amount;//设置提取额度
    }

    function withdrawTreasure(uint256 amount) public{

        if(msg.sender == owner){
            require(amount <= treasureAmount,"Not enough treasure available.");//检查宝藏数量是否足够
            treasureAmount -= amount;//管理员直接提取宝藏

            return;

        }
        uint256 allowance = withdrawalAllowance[msg.sender];//获取调用者的提取额度

        ////用户只能提取一次，且必须经过拥有者的批准
        require(allowance > 0,"You don't have any withdrawal allowance.");//检查调用者是否有提取额度
        require(!hasWithdrawn[msg.sender],"You have already withdrawn your treasure.");//检查调用者是否已经提取过
        require(allowance <= treasureAmount,"Not enough treasure in the chest.");//检查宝藏数量是否足够
        require(allowance >= amount,"Cannot withdraw more than your are allowed.");//检查提取金额是否超过提取额度
        
        hasWithdrawn[msg.sender] = true;//标记调用者已经提取过
        //为何不是treasureAmount -= amount;？因为管理员批准的提取额度可能大于用户实际提取的数量，所以应该从宝藏中扣除实际提取的数量，而不是批准的额度。
        treasureAmount -= allowance;//从宝藏中扣除提取的数量
        withdrawalAllowance[msg.sender] = 0;//将调用者的提取额度设为0

    }

    function resetWithdrawalStatus(address user) public onlyOwner {
        hasWithdrawn[user] = false;//重置提取状态
    }

    function transferOwnership(address newOwner) public onlyOwner {
        //“零地址”，所有 address 类型的变量在未赋值时，默认值就是 address(0)
        require(newOwner != address(0),"Invalid address.");//检查新管理员地址是否有效
        owner = newOwner;//转移管理员权限
    }

    function getTreasureDetails()  public view onlyOwner returns(uint256){
        return treasureAmount;//返回宝藏数量
        
    }


}