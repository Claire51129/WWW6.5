// 所以现在完整结构是
//✅ constructor     → 设置初始信息
//✅ bool            → 控制转账锁定开关
//✅ mapping         → 记录每人购买数量
//✅ payable         → 接收买家的ETH
//✅ uint256         → 存代币价格
//✅ getBalance      → 查合约余额

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./day13-1-zhuaizhuaiToken.sol";

contract PreOrderToken is zhuaizhuaiToken {
    uint256 public tokenPrice;
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public totalRaised;
    address public projectOwner;
    bool public finalized = false;
    bool private initialTransferDone = false;

    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);

    constructor( 
        uint256 _intitialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    )zhuaizhuaiToken(_intitialSupply){
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;
    

    _transfer(msg.sender, address(this), totalSupply);
    initialTransferDone = true;
}

    function isSaleActive()public view returns(bool){//查询发售是否正在进行中
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);//&&并且，同时满足三个条件才能够到true
    }// !finalized 发售没有结束， && block.timestamp >= saleStartTime  已经到开始时间， && block.timestamp <= saleEndTime 还没到结束时间

    function buyTokens() public payable{
        require(isSaleActive(), "Sale is not active");// 检查发售是否进行中
        require(msg.value >= minPurchase, "Amount is below min purchase");// 检查购买金额范围
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        uint256 tokenAmount = (msg.value * 10**uint256(decimals))/ tokenPrice;//计算能买多少代币
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale");
        totalRaised+= msg.value;//记录筹集金额 + 转账代币
        _transfer(address(this),msg.sender,tokenAmount);
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    function transferFrom(address _from, address _to, uint256 _value)public override returns(bool){
        if(!finalized && _from != address(this)){
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }

    function finalizeSale() public payable{
        require(msg.sender == projectOwner, "Only owner can call this function");// 只有项目方能调用
        require(!finalized,"Sale is already finalized");// 不能重复结束
        require (block.timestamp > saleEndTime, "Sale not finished yet");// 时间到了才能结束
        finalized = true;
        uint256 tokensSold = totalSupply - balanceOf[address(this)];
        (bool sucess,) = projectOwner.call{value:  address(this).balance}("");
        require(sucess, "Transfer failed");
        emit SaleFinalized(totalRaised, tokensSold);
    }

    function timeRemaining() public view  returns(uint256){//剩余时间
        if(block.timestamp >= saleEndTime){
            return 0;
        }
        return (saleEndTime - block.timestamp);
    }

    function tokensAvailable()public view returns(uint256){//剩余代币
        return balanceOf[address(this)];
    }

    receive() external payable{
        buyTokens();
    }
}
