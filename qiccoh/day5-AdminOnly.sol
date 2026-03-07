// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract AdminOnly{

address  public owner;
uint256 public treasureAmount;




//构造函数只在部署时运行一次
constructor(){


    owner = msg.sender;
    //“谁部署了这个合约，谁就是合约的拥有者。”
}
//这个修饰符权限检查机制，确保只有合约所有者才能调用
modifier  onlyOwner(){
    require(msg.sender == owner,"Access denied:only owner");
    _;
    //`_` 这是一个占位符，表示如果检查通过，函数的主体代码将在这里执行
}



function addTreasure(uint256 amount) public  onlyOwner{
    treasureAmount += amount;
}

//取钱
//mapping 来记录每个地址被允许提取的数量 后面是条件
mapping (address => uint256) public withdrawalAllowance;

function approveWithdrawal(address recipient,uint256 amount )public onlyOwner{
    require(amount <= treasureAmount,"Not enough treasure available");
    withdrawalAllowance[recipient] = amount;
}

//实际取宝
mapping (address =>bool) public hasWithdrawn;

function withdrawTreasure(uint256 amount) public {

    //拥有者取宝
    if (msg.sender == owner){

        //后面文字是为假时抛出的文字
        require(amount <= treasureAmount,"Not enough treasury available for this action");
        treasureAmount = amount;
        return;
    }

    uint256 allowance = withdrawalAllowance[msg.sender];
    //是否被批准
    require(allowance > 0,"You don't hava any treasure allowance");
   //是否被提取过
    require(!hasWithdrawn[msg.sender],"you have already withdrawn your treasure");
   //宝物是否足够
    require(allowance <= treasureAmount,"Not enough treasure in the chest ");
    //完成取宝
    //1、用户标记为已取
    hasWithdrawn[msg.sender] = true;
    treasureAmount -= allowance;
    //权限去除
    withdrawalAllowance[msg.sender] = 0;

}
//重置权限
function resetWithdrawalStatus(address user)public onlyOwner{
    hasWithdrawn[user] = false;
}
//转移合约拥有权

function transferOwenership(address newOwner)public onlyOwner{
    require(newOwner !=address(0),"invalid address");
    owner = newOwner;
}

function getTreasureDetails() public view onlyOwner returns(uint256){
    return treasureAmount;
}
}
