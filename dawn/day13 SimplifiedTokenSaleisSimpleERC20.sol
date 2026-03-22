// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day13 simpleerc20.sol";//导入之前写的合约

contract SimplifiedTokenSale is SimpleERC20 {
    uint256 public tokenPrice;//每个代币的价格
    uint256 public saleStartTime;//销售开始的时间戳
    uint256 public saleEndTime;//销售结束的时间戳
    uint256 public minPurchase;//单次购买的最小ETH金额
    uint256 public maxPurchase;//单次购买的最大ETH金额
    uint256 public totalRaised;//销售期间总共筹集的ETH数量。
    address public projectOwner;//项目方地址
    bool public finalized = false;//销售是否结束
    bool private initialTransferDone = false;//这是一个内部标志，确保构造函数中的初始转账完成后才能启动。
    
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);//购买成功时触发记录购买者地址支付的ETH数量和获得的代币数量。
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);//当销售结束时，记入总筹集金额和总售出货币数量。
    
    constructor(
        uint256 _initialSupply,
        uint256 _tokenPrice,
        uint256 _saleStartTime,
        uint256 _saleDuration,
        uint256 _minPurchase,
        uint256 _maxPurchase
    ) SimpleERC20(_initialSupply) {
        tokenPrice = _tokenPrice;
        saleStartTime = _saleStartTime;
        saleEndTime = _saleStartTime + _saleDuration;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = msg.sender;
        
        // 将所有代币转到合约
        _transfer(msg.sender, address(this), totalSupply);
        initialTransferDone = true;
    }
    
    // 检查销售是否激活
    function isSaleActive() public view returns (bool) {
        return block.timestamp >= saleStartTime && 
               block.timestamp <= saleEndTime && 
               !finalized;
    }
    
    // 购买代币
    function buyTokens() public payable {
        require(isSaleActive(), "Sale not active");
        require(msg.value >= minPurchase && msg.value <= maxPurchase, "Invalid purchase amount");
        
        uint256 tokenAmount = (msg.value * 10**uint256(decimals)) / tokenPrice;
        require(balanceOf[address(this)] >= tokenAmount, "Insufficient tokens");
        
        _transfer(address(this), msg.sender, tokenAmount);
        totalRaised += msg.value;
        
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }
    
    // ✅ 重写transfer - 添加锁定逻辑
    function transfer(address _to, uint256 _value) public override returns (bool) {
        if (!finalized && msg.sender != address(this) && initialTransferDone) {
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transfer(_to, _value);
    }
    
    // ✅ 重写transferFrom - 添加锁定逻辑
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        if (!finalized && _from != address(this) && initialTransferDone) {
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }
    
    // 完成销售
    function finalizeSale() public payable {
        require(msg.sender == projectOwner, "Only owner");
        require(block.timestamp > saleEndTime, "Sale not ended");
        require(!finalized, "Already finalized");
        
        finalized = true;
        
        // 将筹集的ETH转给项目方
        (bool success, ) = projectOwner.call{value: address(this).balance}("");
        require(success, "Transfer failed");
        
        emit SaleFinalized(totalRaised, totalSupply - balanceOf[address(this)]);
    }
    
    // 工具函数
    function timeRemaining() public view returns (uint256) {
        if (block.timestamp >= saleEndTime) return 0;
        return saleEndTime - block.timestamp;
    }
    
    function tokensAvailable() public view returns (uint256) {
        return balanceOf[address(this)];
    }
    
    // 接收直接发送的ETH
    receive() external payable {
        buyTokens();
    }
}