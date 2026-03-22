// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day13_SimpleERC20.sol";

contract SimplifiedTokenSale is SimpleERC20 {
    // ========== 状态变量 ==========
    uint256 public tokenPrice;           // 每个代币价格（wei）
    uint256 public saleStartTime;        // 销售开始时间戳
    uint256 public saleEndTime;          // 销售结束时间戳
    uint256 public minPurchase;          // 最小购买额（wei）
    uint256 public maxPurchase;          // 最大购买额（wei）
    uint256 public totalRaised;          // 已筹集ETH总额
    address public projectOwner;         // 项目方地址
    bool public finalized = false;       // 销售是否结束
    bool private initialTransferDone = false;
    
    // ========== 事件 ==========
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);
    
    // ========== 构造函数 ==========
    constructor(
        uint256 _initialSupply,          // 初始供应量（不含18位小数）
        uint256 _tokenPrice,             // 代币价格（wei）
        uint256 _saleStartTime,          // 开始时间戳
        uint256 _saleDuration,           // 持续时长（秒）
        uint256 _minPurchase,            // 最小购买（wei）
        uint256 _maxPurchase             // 最大购买（wei）
    ) SimpleERC20(_initialSupply) {
        tokenPrice = _tokenPrice;
        saleStartTime = _saleStartTime;
        saleEndTime = _saleStartTime + _saleDuration;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = msg.sender;
        
        // 把所有代币从部署者转给合约
        _transfer(msg.sender, address(this), totalSupply);
        initialTransferDone = true;
    }
    
    // ========== 核心函数 ==========
    
    // 检查销售是否进行中
    function isSaleActive() public view returns (bool) {
        return block.timestamp >= saleStartTime && 
               block.timestamp <= saleEndTime && 
               !finalized;
    }
    
    // 购买代币
    function buyTokens() public payable {
        require(isSaleActive(), "Sale is not active");
        require(msg.value >= minPurchase, "Below minimum");
        require(msg.value <= maxPurchase, "Above maximum");
        
        // 计算代币数量
        uint256 tokenAmount = (msg.value * 10**decimals) / tokenPrice;
        require(balanceOf[address(this)] >= tokenAmount, "Sold out");
        
        totalRaised += msg.value;
        _transfer(address(this), msg.sender, tokenAmount);
        
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }
    
    // ✅ 重写 transfer - 销售期间锁定
    function transfer(address _to, uint256 _value) public override returns (bool) {
        if (!finalized && msg.sender != address(this) && initialTransferDone) {
            revert("Tokens are locked until sale is finalized");
        }
        return super.transfer(_to, _value);
    }
    
    // ✅ 重写 transferFrom - 销售期间锁定
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        if (!finalized && _from != address(this) && initialTransferDone) {
            revert("Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }
    
    // 项目方结束销售并提取ETH
    function finalizeSale() public {
        require(msg.sender == projectOwner, "Only owner");
        require(!finalized, "Already finalized");
        require(block.timestamp > saleEndTime, "Sale not ended");
        
        finalized = true;
        uint256 tokensSold = totalSupply - balanceOf[address(this)];
        
        (bool success, ) = projectOwner.call{value: address(this).balance}("");
        require(success, "Transfer failed");
        
        emit SaleFinalized(totalRaised, tokensSold);
    }
    
    // ========== 工具函数 ==========
    
    function timeRemaining() public view returns (uint256) {
        if (block.timestamp >= saleEndTime) return 0;
        return saleEndTime - block.timestamp;
    }
    
    function tokensAvailable() public view returns (uint256) {
        return balanceOf[address(this)];
    }
    
    // 直接发送ETH自动购买
    receive() external payable {
        buyTokens();
    }
}