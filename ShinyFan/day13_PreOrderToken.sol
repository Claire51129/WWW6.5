//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "./day13_SimpleToken.sol";//导入之前合约

contract PreOrderToken is SimpleERC20 {//预售合约继承代币合约

    //状态变量-发售设置
    uint256 public tokenPrice;//代币价格
    uint256 public saleStartTime;//预售开始事件
    uint256 public saleEndTime;//预售结束事件
    uint256 public minPurchase;//最少购买量
    uint256 public maxPurchase;//最多购买量
    uint256 public totalRaised;//总共筹集多少ETH
    address public projectOwner;//创始人地址
    bool public finalized = false;//发售是否结束
    bool private initialTransferDone = false;//内部标记，确保在锁定转账前购买者已收到所有代币

    //事件
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);//购买事件：某人花多少ETH买了多少代币
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);//预售结束事件：总共筹集多少ETH，卖出多少代币

    //构造函数-设置一切
    constructor( 
        uint256 _intitialSupply,//代币总发行量
        uint256 _tokenPrice,//代币价格
        uint256 _saleDurationInSeconds,//预售持续事件
        uint256 _minPurchase,//最低购买量
        uint256 _maxPurchase,//最高购买量
        address _projectOwner//项目创始人地址
    )SimpleERC20(_intitialSupply){//调用母合约的函数，直接发行代币
        tokenPrice = _tokenPrice;//价格单位都是wei
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;
    

    _transfer(msg.sender, address(this), totalSupply);//调用母合约函数，将我的代币都转到合约里
    initialTransferDone = true;//初始发行结束
}
    //检查代币是否在发行
    function isSaleActive()public view returns(bool){//返回true/false
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);//需满足调节：发行未结束+当前时间在开始时间和结束时间之间
    }

    //购买代币函数
    function buyTokens() public payable{
        require(isSaleActive(), "Sale is not active");//确保代币在发行
        require(msg.value >= minPurchase, "Amount is below min purchase");
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        uint256 tokenAmount = (msg.value * 10**uint256(decimals))/ tokenPrice;//计算发多少个代币
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale");//合约余额大于购买数量
        totalRaised += msg.value;
        _transfer(address(this),msg.sender,tokenAmount);
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);//触发购买事件
        
    }

    //重写 transfer() — 锁定直接转账，防止提前买卖
    function transfer(address _to, uint256 _value)public override returns(bool){//override重写
        if(!finalized && msg.sender != address(this) && initialTransferDone){//满足发行未结束+购买者地址不是合约地址+初始代币在合约里 将返回true
            require(false, "Tokens are locked until sale is finalized");
        }

        return super.transfer(_to, _value);//找母合约的代码执行
    }

    function transferFrom(address _from, address _to, uint256 _value)public override returns(bool){
        if(!finalized && _from != address(this)){
            require(false, "Tokens are locked until sale is finalized");
        }
        //恢复转账
        return super.transferFrom(_from, _to, _value);//调用母合约和拿书
    }

    //结束代币发行
    function finalizeSale() public payable{
        require(msg.sender == projectOwner, "Only owner can call this function");
        require(!finalized,"Sale is already finalized");
        require (block.timestamp > saleEndTime, "Sale not finished yet");
        finalized = true;//结束发行
        uint256 tokensSold = totalSupply - balanceOf[address(this)];//计算已售代币
        (bool sucess,) = projectOwner.call{value:  address(this).balance}("");
        require(sucess, "Transfer failed");
        emit SaleFinalized(totalRaised, tokensSold);//触发最终事件
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