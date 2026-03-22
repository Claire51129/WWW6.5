// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./day12-SimpleERC20.sol";

contract SimplifiedTokenSale is SimpleERC20 {
    uint256 public tokenPrice; // 价格 wei
    uint256 public saleStartTime; 
    uint256 public saleEndTime;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public totalRaised; // 总金额
    address public projectOwner; // 最后接收的钱包地址
    bool public finalized = false; // 是否已经结束
    bool private initialTransferDone = false; // 用于取保合约在转账前收到所有代币

    // 成功购买触发
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    // 发售结束触发
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);

    constructor( 
        uint256 _initialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    )SimpleERC20(_initialSupply){
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;

        // 所有代币转移到合约用于发售
        _transfer(msg.sender, address(this), totalSupply);
        initialTransferDone = true;
    }

    // 是否活动还在进行
     function isSaleActive()public view returns(bool){
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    function buyTokens() public payable{
        require(isSaleActive(), "Sale is not active");
        require(msg.value >= minPurchase, "Amount is below min purchase");
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        uint256 tokenAmount = (msg.value * 10**uint256(decimals))/ tokenPrice;
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale");

        totalRaised += msg.value;
        _transfer(address(this),msg.sender,tokenAmount);

        // 触发购买事件
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);

    }

    // 这里重写了 transfer 函数
    function transfer(address _to, uint256 _value) public override returns (bool) {
        if (!finalized && msg.sender != address(this) && initialTransferDone) {
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transfer(_to, _value);
    }

    // 这里也重写了
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        if (!finalized && _from != address(this)) {
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }

    // 结束活动
    function finalizeSale() public payable {
        // 项目所有者才能调用
        require(msg.sender == projectOwner, "Only Owner can call the function");
        require(!finalized, "Sale already finalized");
        require(block.timestamp > saleEndTime, "Sale not finished yet");

        finalized = true;
        uint256 tokensSold = totalSupply - balanceOf[address(this)];

        (bool success, ) = projectOwner.call{value: address(this).balance}("");
        require(success, "Transfer to project owner failed");

        // 触发筹集的 eth 总额和售出的代币数量
        emit SaleFinalized(totalRaised, tokensSold);
    }

    // 查询距离活动结束还有多久
    function timeRemaining() public view  returns(uint256){
        if(block.timestamp >= saleEndTime){
            return 0;
        }
        return (saleEndTime - block.timestamp);
    }

    // 查询可购买代币数量
    function tokensAvailable()public view returns(uint256){
        return balanceOf[address(this)];
    }

    // 新知识：加入有人向合约转入 eth 都会自动调用参与活动
    receive() external payable {
        buyTokens();
    }

        
}