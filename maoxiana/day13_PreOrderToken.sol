//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./day13_MyToken.sol";

//合约继承：PreOrderToken 继承了 MyToken，这意味着 PreOrderToken 拥有 MyToken 中定义的所有状态变量和函数，并且可以重用它们的逻辑。
//MyToken（在day12的基础上添加了两个函数virtual标记） 是一个基本的 ERC-20 代币实现，而 PreOrderToken 在此基础上添加了预售特定的功能，如销售时间限制、购买限制和资金管理。
contract PreOrderToken is MyToken {

    uint256 public tokenPrice;//每个代币值多少 ETH（单位是 wei，1 ETH = 10¹⁸ wei）
    //表示发售开始和结束时间的时间戳
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    //单笔交易中允许购买的最小和最大ETH额度
    uint256 public minPurchase;
    uint256 public maxPurchase;
    
    uint256 public totalRaised;//目前为止接收的 ETH总额
    
    address public projectOwner;//发售结束后接收 ETH 的钱包地址
    bool public finalized = false;//发售是否已经正式关闭
    bool private initialTransferDone = false;//用于确保合约在锁定转账前已收到所有代币

    //当有人成功购买代币时触发。它会记录购买者、支付的 ETH 数量以及收到的代币数量。
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    //发售结束时触发。记录筹集的 ETH 总数和售出的代币数量。
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);

    constructor( 
        uint256 _intitialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    )MyToken(_intitialSupply){
        tokenPrice = _tokenPrice;//单位是wei
        saleStartTime = block.timestamp;//合约部署的那一秒
        saleEndTime = block.timestamp + _saleDurationInSeconds;//+持续时间以秒为单位
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;
    

    _transfer(msg.sender, address(this), totalSupply);
    initialTransferDone = true;
}

    //发售是否正在进行，这个函数检查当前时间是否在预售的开始和结束时间之间，并且预售尚未结束（finalized）。如果满足这些条件，它返回 true，表示预售正在进行中；否则返回 false。
    function isSaleActive()public view returns(bool){
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    //主要购买函数，发售期间买代币使用这个函数。
    //它执行几个检查：确保发售正在进行中，购买金额在允许的范围内，并且合约有足够的代币可供出售。然后它计算买家应该收到多少代币，更新筹集的 ETH 总额，并将代币从合约地址转移到买家地址。最后，它触发一个事件来记录这笔交易。
    function buyTokens() public payable{
        require(isSaleActive(), "Sale is not active");
        require(msg.value >= minPurchase, "Amount is below min purchase");
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        //这样除完不会是小数吗？比如msg.value = 1 tokenPrice = 3，1/3不是0.333吗？在 Solidity 中，整数除法会向下取整，所以 1 / 3 将返回 0。
        uint256 tokenAmount = (msg.value * 10**uint256(decimals))/ tokenPrice;
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale");
        totalRaised+= msg.value;
        _transfer(address(this),msg.sender,tokenAmount);
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
        
    }

    function transfer(address _to, uint256 _value)public override returns(bool){
        //如果：发售尚未完成、交易不是由合约本身发起的（例如在 buyTokens() 期间）、初始代币供应已经转移到合约中
        //交易撤销，并显示一条消息，说明代币在发售完成之前被锁定了。
        //否则，交易将继续进行，调用父合约（MyToken）的 transfer 函数来执行实际的转账逻辑。
        if(!finalized && msg.sender != address(this) && initialTransferDone){
            require(false, "Tokens are locked until sale is finalized");
        }

        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)public override returns(bool){
        if(!finalized && _from != address(this)){
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }

    //结束代币发售，只有项目所有者可以调用这个函数。它检查发售是否已经结束（基于时间）并且尚未被正式关闭（finalized）。
    //如果满足条件，它将 finalzied 设置为 true，计算售出的代币数量，并将合约中剩余的 ETH 转移到项目所有者的地址。最后，它触发一个事件来记录发售的最终结果。
    function finalizeSale() public payable{
        require(msg.sender == projectOwner, "Only owner can call this function");
        require(!finalized,"Sale is already finalized");
        require (block.timestamp > saleEndTime, "Sale not finished yet");
        finalized = true;
        //代币总发行量-合约当前持有的代币余额（尚未售出部分） = 已分配给用户的代币数量
        uint256 tokensSold = totalSupply - balanceOf[address(this)];
        //把发售期间筹集到的全部ether转给项目所有者
        (bool sucess,) = projectOwner.call{value:  address(this).balance}("");
        require(sucess, "Transfer failed");
        emit SaleFinalized(totalRaised, tokensSold);
    }

    //发售状态辅助函数：距离发售结束还剩多少秒
    function timeRemaining() public view  returns(uint256){
        if(block.timestamp >= saleEndTime){
            return 0;
        }
        return (saleEndTime - block.timestamp);
    }

    //函数检查合约地址的代币余额，并返回这个余额，表示还有多少代币可供购买。
    function tokensAvailable()public view returns(uint256){
        return balanceOf[address(this)];
    }

    //`receive()` 函数是一个**特殊的回退函数**，在满足以下条件时被触发：
    // - 有人**直接**向合约地址发送 ETH
    // - 且**未指定**要调用的任何函数
    receive() external payable{
        buyTokens();
    }
    }





