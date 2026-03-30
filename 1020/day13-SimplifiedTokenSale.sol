// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//- 以固定的 ETH 价格发售你的自定义 ERC-20 代币
//- 设置发售的开始和结束时间
//- 强制执行最低和最高购买金额
//- 自动处理代币分发
//- 防止发售期间的转账（以防止短线抛售或机器人砸盘）
//- 完成发售并将筹集的 ETH 转移给项目所有者
import "./day12-SimpleERC20.sol";

contract SimplifiedTokenSale is SimpleERC20{
    uint256 public tokenPrice;
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public minPurchase;
    uint256 public maxPurchase;//单笔交易中允许购买的最小和最大ETH额度
    uint256 public totalRaised;
    address public projectOwner;//发售结束后接收 ETH 的钱包地址
    bool public finalized=false;//发售是否已经正式关闭
    bool private initialTransferDone = false;//用于确保合约在锁定转账前已收到所有代币
    
    event TokensPurchased(address indexed buyer,uint256 etherAmount,uint256 tokenAmount);
    event SaleFinalized(uint256 totalRaised,uint256 totalTokensSold);

    constructor(
        uint256 _initialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSenconds,//一周的秒数：604800
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner//这些都是初始化输入的
    )SimpleERC20(_initialSupply){//调用母合约的构造函数
        tokenPrice=_tokenPrice;
        saleStartTime=block.timestamp;
        saleEndTime=block.timestamp+_saleDurationInSenconds;
        minPurchase=_minPurchase;
        maxPurchase=_maxPurchase;
        projectOwner=_projectOwner;

        _transfer(msg.sender,address(this),totalSupply);//将代币转给合约
    }

    function isSaleActive() public view returns(bool){
        return(!finalized && block.timestamp>=saleStartTime && block.timestamp<=saleEndTime);
    }

    function buyTokens() public payable{
        require(isSaleActive(),"Sale is not active");
        require(msg.value>=minPurchase,"Amount is below minimun purchase");
        require(msg.value<=maxPurchase,"Amounr exceeds maximum purchase");

        uint256 tokenAmount=(msg.value*10**uint256(decimals))/tokenPrice;
        require(balcanceOf[address(this)]>=tokenAmount,"not enough tokens lefe for sale");
        totalRaised+=msg.value;
        _transfer(address(this),msg.sender,tokenAmount);
        emit TokensPurchased(msg.sender,msg.value,tokenAmount);
    }

    function transfer(address _to, uint256 _value) public override returns (bool) {
    if (!finalized && msg.sender != address(this) && initialTransferDone) {
        require(false, "Tokens are locked until sale is finalized");
    }
    return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
    if (!finalized && _from != address(this)) {
        require(false, "Tokens are locked until sale is finalized");
    }
    return super.transferFrom(_from, _to, _value);
    }

    function finalizeSale() public payable {
    require(msg.sender == projectOwner, "Only Owner can call the function");
    require(!finalized, "Sale already finalized");
    require(block.timestamp > saleEndTime, "Sale not finished yet");

    finalized = true;
    uint256 tokensSold = totalSupply - balcanceOf[address(this)];

    (bool success, ) = projectOwner.call{value: address(this).balance}("");
    require(success, "Transfer to project owner failed");

    emit SaleFinalized(totalRaised, tokensSold);
    }

    function timeRemaining() public view returns (uint256) {
    if (block.timestamp >= saleEndTime) {
        return 0;
    }
    return saleEndTime - block.timestamp;
    }

    function tokensAvailable() public view returns (uint256) {
    return balcanceOf[address(this)];
    }
}