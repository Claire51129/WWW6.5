// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdminOnly {
    // State variables
    address public owner;
    uint256 private treasureAmount;
    mapping(address => uint256) public withdrawalAllowance;
    mapping(address => bool) public hasWithdrawn;
    
    // Constructor sets the contract creator as the owner
    constructor() {
        owner = msg.sender;
    }
    
    // Modifier for owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied: Only the owner can perform this action");
        _;
    }
    //通过修饰符实现可复用的访问控制：modifier是用来给function添加条件限制的，即函数执行前的检查规则。在Solidity中，modifier（修饰符）让我们能够创建可以附加到函数中的可复用的小型权限检查逻辑。符号 `_` 表示权限检查之后的函数主体将被插入的位置（它是一个占位符），在上述代码中，占位符在require函数后面，意味着以后的函数里如果包含了这个onlyOwner修饰符，应当先执行require函数，只有检查通过时，函数主体的代码才会被执行。这样一来，我们不再需要在每个函数中都写`require(msg.sender == owner)`，只需添加 `onlyOwner` 修饰符即可——更简洁、更安全、也更好维护。

    // Only the owner can add treasure
    function addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount;
    }
    
    // Only the owner can approve withdrawals
    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner {
        require(amount <= treasureAmount, "Not enough treasure available");
        withdrawalAllowance[recipient] = amount;
    }
    
    // Anyone can attempt to withdraw, but only those with allowance will succeed
    function withdrawTreasure(uint256 amount) public {

        if(msg.sender == owner){
            require(amount <= treasureAmount, "Not enough treasury available for this action.");
            treasureAmount-= amount;
            return;
        }
        uint256 allowance = withdrawalAllowance[msg.sender];
        //调用withdrawTreasure函数者如果是owner，则运行if内部，修改treasureAmount并返回（return，即该withdrawTreasure函数调用完毕）
        //调用者如果不是owner，则跳过if，定义allowance为该调用者的被授权金额，并继续经历下方四项require检查。【注意这里allowance和前面的amount，recipient都是函数参数】
        
        // Check if user has an allowance and hasn't withdrawn yet
        require(allowance > 0, "You don't have any treasure allowance");
        require(!hasWithdrawn[msg.sender], "You have already withdrawn your treasure");
        require(amount <= treasureAmount, "Not enough treasure in the chest"); 
        require(amount <= allowance, "Cannot withdraw more than you are allowed"); // condition to check if user is withdrawing more than allowed
        
        // Mark as withdrawn and reduce treasure
        hasWithdrawn[msg.sender] = true;
        treasureAmount -= amount;
        withdrawalAllowance[msg.sender] = 0;
        
    }
    
    // Only the owner can reset someone's withdrawal status
    function resetWithdrawalStatus(address user) public onlyOwner {
        hasWithdrawn[user] = false;
    }
    
    // Only the owner can transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
    //require(newOwner != address(0), ...): 这是一个防呆设计。在 Solidity 中，address(0) 代表 0x0000...0000（全零地址），这是一个没有人能控制的“黑洞”地址。如果不做这个检查，万一你不小心传了个空值，或者参数填错了，权限就会被转给黑洞，这个合约的管理员功能就永久报废了（俗称“丢钥匙”）。
    
    function getTreasureDetails() public view onlyOwner returns (uint256) {
        return treasureAmount;
    }
}


//在原代码基础上做了两处改动：
//1.声明状态变量treasureAmount时，可见性由public改为private。通过末尾的getTreasureDetails函数实现仅限owner可查看。
//2.49行和54行allowance改为amount，在宝藏总数已经减少到低于该用户被授权的金额的情况下，如果该用户提取不超过宝藏总数的金额，也是可行的；且宝藏总数应减少实际提取金额，而非被授权金额。