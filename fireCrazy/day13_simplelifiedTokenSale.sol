// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day12_SimpleERC20.sol"; // 把昨天的印钞机代码拿过来

contract SimplifiedTokenSale is SimpleERC20 { // 继承印钞机，这个专卖店本身也能印钱、管账
    
    // --- 1. 专卖店的营业参数 ---
    uint256 public tokenPrice;       // 标价：每个代币卖多少 wei
    uint256 public saleStartTime;    // 开门时间
    uint256 public saleEndTime;      // 关门时间
    uint256 public minPurchase;      // 最低消费
    uint256 public maxPurchase;      // 限购最高消费
    uint256 public totalRaised;      // 营业额（总共收了多少真金白银 ETH）
    address public projectOwner;     // 老板是谁（发售结束后钱打给谁）
    bool public finalized = false;   // 关停标记：发售是不是彻底结束了
    bool public initialTransferDone = false; // 铺货标记：货有没有全部摆上货架 

    // --- 2. 大喇叭 (Events) ---
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount); // 播报：谁花多少钱买了多少币 
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold); // 播报：发售圆满结束，总共筹了多少钱 

    // --- 3. 开机程序 (Constructor) ---
    constructor(
        uint256 _initialSupply, 
        uint256 _tokenPrice, 
        uint256 _saleDurationInSeconds, 
        uint256 _minPurchase, 
        uint256 _maxPurchase, 
        address _projectOwner
    ) SimpleERC20(_initialSupply) {  // 关键：把初始供应量传给父合约，把钱印出来 
        
        tokenPrice = _tokenPrice; // 定价 
        saleStartTime = block.timestamp; // 开门时间就是合约部署的这一秒
        saleEndTime = block.timestamp + _saleDurationInSeconds; // 关门时间 = 现在 + 持续秒数 
        minPurchase = _minPurchase; // 设最低消费
        maxPurchase = _maxPurchase; // 设限购额度 
        projectOwner = _projectOwner; // 登记老板地址 

        // 【核心铺货动作】：把印出来的所有币，从老板兜里全塞进这个售货机里！ 
        _transfer(msg.sender, address(this), totalSupply); 
        initialTransferDone = true; // 标记铺货完成
    }

    // --- 4. 辅助函数：查营业状态 ---
    function isSaleActive() public view returns (bool) { 
        // 只有没结束，且当前时间在开门和关门之间，才算正在营业
        return (!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime); 
    }

    // --- 5. 核心收银台：买币通道 ---
    function buyTokens() public payable { // payable 表示可以收真金白银 
        require(isSaleActive(), "Sale is not active"); // 检查是否在营业 
        require(msg.value >= minPurchase, "Amount is below minimum purchase"); 
        require(msg.value <= maxPurchase, "Amount exceeds maximum purchase"); // 检查是否超过限购 

        // 算汇率：用付的钱乘以 10的18次方，再除以单价，算出该发多少个币 
        uint256 tokenAmount = (msg.value * 10 ** uint256(decimals)) / tokenPrice; 
        
        // 查库存：售货机里的货还够不够？
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale"); 
        
        totalRaised += msg.value; // 增加营业额 
        _transfer(address(this), msg.sender, tokenAmount); // 发货！把币从售货机转给买家 
        emit TokensPurchased(msg.sender, msg.value, tokenAmount); // 拿喇叭广播有人买单了
    }

    // --- 6. 隐形大网：无感支付通道 ---
    receive() external payable { // 只要有人硬转账，自动帮他按 buyTokens 按钮 
        buyTokens();
    }

    // --- 7. 锁仓魔法：重写转账规则 ---
    function transfer(address _to, uint256 _value) public override returns (bool) { 
        // 如果发售没结束 且 转账的人不是售货机自己 且 货已经铺好了 -> 不准转！
        if (!finalized && msg.sender != address(this) && initialTransferDone) { 
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transfer(_to, _value); // 发售结束后，恢复正常的转账功能 
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) { 
        // 同样，锁死代扣功能，防止黑客代扣砸盘 
        if (!finalized && _from != address(this)) { 
            require(false, "Tokens are locked until sale is finalized"); 
        }
        return super.transferFrom(_from, _to, _value); 
    }

    // --- 8. 老板结账通道 ---
    function finalizeSale() public { 
        require(msg.sender == projectOwner, "Only Owner can call the function"); // 保安查验：只有老板能点 
        require(!finalized, "Sale already finalized"); // 防止重复结账
        require(block.timestamp > saleEndTime, "Sale not finished yet"); // 必须等时间结束了才能结账 

        finalized = true; // 宣布发售彻底结束，全网锁仓瞬间解除！
        
        // 算算总共卖了多少个币（总发行量 - 售货机里没卖完的）
        uint256 tokensSold = totalSupply - balanceOf[address(this)]; 

        // 【老板收钱】：把这几天赚的所有真金白银（ETH）全部打给老板！ 
        (bool success, ) = projectOwner.call{value: address(this).balance}(""); 
        require(success, "Transfer to project owner failed"); 
        
        emit SaleFinalized(totalRaised, tokensSold); // 拿喇叭广播：发售圆满收官！ 
    }

    // --- 9. 前端看板函数（免费查询） ---
    function timeRemaining() public view returns (uint256) { 
        if (block.timestamp >= saleEndTime) { // 如果已经超时了，返回 0 秒
            return 0; 
        }
        return saleEndTime - block.timestamp; // 返回还剩多少秒 
    }

    function tokensAvailable() public view returns (uint256) { 
        return balanceOf[address(this)]; // 查查售货机里还剩多少货
    }
}
