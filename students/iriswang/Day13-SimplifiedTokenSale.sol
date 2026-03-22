// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day13-SimpleERC20.sol";

contract SimplifiedTokenSale is SimpleERC20 {
    uint256 public tokenPrice;
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public totalRaised;
    address public projectOwner;
    bool public finalized = false;
    bool private initialTransferDone = false;
    
    // 白名单映射
    mapping(address => bool) public whitelist;
    
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);
    event WhitelistUpdated(address indexed account, bool added);
    
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Address not whitelisted");
        _;
    }
    
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
    
    function isSaleActive() public view returns (bool) {
        return block.timestamp >= saleStartTime && 
               block.timestamp <= saleEndTime && 
               !finalized;
    }
    
    // 添加白名单限制
    function buyTokens() public payable onlyWhitelisted {
        require(isSaleActive(), "Sale not active");
        require(msg.value >= minPurchase && msg.value <= maxPurchase, "Invalid purchase amount");
        
        uint256 tokenAmount = (msg.value * 10**uint256(decimals)) / tokenPrice;
        require(balanceOf[address(this)] >= tokenAmount, "Insufficient tokens");
        
        _transfer(address(this), msg.sender, tokenAmount);
        totalRaised += msg.value;
        
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }
    
    // 白名单管理函数
    function addToWhitelist(address _account) public {
        require(msg.sender == projectOwner, "Only owner");
        whitelist[_account] = true;
        emit WhitelistUpdated(_account, true);
    }
    
    function removeFromWhitelist(address _account) public {
        require(msg.sender == projectOwner, "Only owner");
        whitelist[_account] = false;
        emit WhitelistUpdated(_account, false);
    }
    
    // 以下函数保持不变
    function transfer(address _to, uint256 _value) public override returns (bool) {
        if (!finalized && msg.sender != address(this) && initialTransferDone) {
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transfer(_to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        if (!finalized && _from != address(this) && initialTransferDone) {
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }
    
    function finalizeSale() public payable {
        require(msg.sender == projectOwner, "Only owner");
        require(block.timestamp > saleEndTime, "Sale not ended");
        require(!finalized, "Already finalized");
        
        finalized = true;
        
        (bool success, ) = projectOwner.call{value: address(this).balance}("");
        require(success, "Transfer failed");
        
        emit SaleFinalized(totalRaised, totalSupply - balanceOf[address(this)]);
    }
    
    function timeRemaining() public view returns (uint256) {
        if (block.timestamp >= saleEndTime) return 0;
        return saleEndTime - block.timestamp;
    }
    
    function tokensAvailable() public view returns (uint256) {
        return balanceOf[address(this)];
    }
    
    receive() external payable {
        buyTokens();
    }
}
