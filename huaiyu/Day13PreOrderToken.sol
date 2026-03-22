// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./Day12ERC20.sol";

//在ERC20里三个代码段落添加了virtual标记告诉solidity继承该合约并且可以修改
contract PreOrderToken is SimpleER20 {
//发售设置
    uint256 public tokenPrice; //每个代币值多少ETH（1ETH=10¹⁸ wei）
    uint256 public saleStartTime; //开始和结束时间
    uint256 public saleEndTime;
    uint256 public minPurchase;//单笔允许最大和最小额度
    uint256 public maxPurchase;
    uint256 public totalRaised;//目前为止接收总额
    address public projectOwner;//发售结束后接收 ETH 的钱包地址
    bool public finalized = false;
    bool private initialTransferDone = false;

//事件
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);

//设置：构造函数，在合约第一次部署时自动执行
    constructor( 
        uint256 _intitialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    )SimpleER20(_intitialSupply){
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;
    

    _transfer(msg.sender, address(this), totalSupply);
    initialTransferDone = true; //表示从部署者到合约的代币交接完成
}
//isSaleActive用来检查发售是否正在进行
    function isSaleActive()public view returns(bool){
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }
//主要购买函数
    function buyTokens() public payable{
        require(isSaleActive(), "Sale is not active");//检查发行是否还在进行
        require(msg.value >= minPurchase, "Amount is below min purchase");
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        uint256 tokenAmount = (msg.value * 10**uint256(decimals))/ tokenPrice;
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale");
        totalRaised+= msg.value;
        _transfer(address(this),msg.sender,tokenAmount);//把代币转给买家
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);//触发购买事件
        
    }

    function transfer(address _to, uint256 _value)public override returns(bool){
        if(!finalized && msg.sender != address(this) && initialTransferDone){
            require(false, "Tokens are locked until sale is finalized");
        }

        return super.transfer(_to, _value);
    }
//锁定委托转账
    function transferFrom(address _from, address _to, uint256 _value)public override returns(bool){
        if(!finalized && _from != address(this)){
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);//super回退到原始，恢复默认的转账逻辑
    }
//结束代币发售的函数
    function finalizeSale() public payable{
        require(msg.sender == projectOwner, "Only owner can call this function");
        require(!finalized,"Sale is already finalized");
        require (block.timestamp > saleEndTime, "Sale not finished yet");
        finalized = true;//将发售标记为完成
        uint256 tokensSold = totalSupply - balanceOf[address(this)];
        (bool sucess,) = projectOwner.call{value:  address(this).balance}("");
        require(sucess, "Transfer failed");
        emit SaleFinalized(totalRaised, tokensSold);
    }

    function timeRemaining() public view  returns(uint256){
        if(block.timestamp >= saleEndTime){
            return 0;
        }
        return (saleEndTime - block.timestamp);
    }

    function tokensAvailable()public view returns(uint256){
        return balanceOf[address(this)];
    }

    receive() external payable{
        buyTokens();
    }
    }