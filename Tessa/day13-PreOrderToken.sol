// 一个卖游戏币的自动售货机：用户投ETH，机器给Token（游戏币）
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./day12-ERC20.sol";

contract PreOrderToken is SimpleERC20 {    //创建一个新合约，并继承SimpleERC20。该售货机=ERC20代币+预售功能

    //状态变量（记录信息）
    uint256 public tokenPrice;    //代币单价
    uint256 public saleStartTime;    //预售开始时间
    uint256 public saleEndTime;    //预售结束时间
    uint256 public minPurchase;    //最少购买价格
    uint256 public maxPurchase;    //最大购买价格
    uint256 public totalRaised;    //募集到的钱
    address public projectOwner;    //项目方的钱包地址
    bool public finalized = false;    //预售是否已经结束
    bool private initialTransferDone = false;    //初始化标记：标记初始token是否已经转到合约

    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);    //有人买token时的记录日志（购买事件：记录谁买的，花了多少ETH，得到多少token）
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);  //预售结束事件：记录日志

    constructor(    //构造函数=部署合约时执行，即创建合约时需要输入一些参数
        uint256 _initialSupply,    //初始token数量
        uint256 _tokenPrice,    //token价格
        uint256 _saleDurationInSeconds,    //预售持续多久
        uint256 _minPurchase,    //最小购买
        uint256 _maxPurchase,    //最大购买
        address _projectOwner    //项目方地址
    )SimpleERC20(_initialSupply){    //先运行ERC20合约，创建token
        tokenPrice = _tokenPrice;    //设置价格
        saleStartTime = block.timestamp;    //设置开始时间
        saleEndTime = block.timestamp + _saleDurationInSeconds;    //设置结束时间：等于现在+预售持续时间
        minPurchase = _minPurchase;    //设置购买最小限制
        maxPurchase = _maxPurchase;     //设置购买最大限制
        projectOwner = _projectOwner;    //设置项目方


        _transfer(msg.sender, address(this),totalSupply);    //把token转入合约，即把所有token转进售货机，这样用户买时合约才有token发
        initialTransferDone = true;   //标记完成
    }
    
    // 判断预售是否开启
    function isSaleActive()public view returns(bool){    //检查预售是否还在进行
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);   //必须满足三条件：没结束；时间>=开始，时间<=结束
    }

    // 购买token
    function buyTokens() public payable{    //用户用ETH买token；payable表示这个函数可以收ETH
        require(isSaleActive(), "Sale is not active");   //检查预售是否开启
        require(msg.value >= minPurchase, "Amount is below min purchase");   //检查最小购买，msg.value=用户发来的ETH
        require(msg.value <= maxPurchase, "Amount is above max purchase");   //检查最大购买
        uint256 tokenAmount = (msg.value * 10**uint256(decimals))/ tokenPrice;   //计算token数量（涉及换算）
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale");  //检查roken是否足够
        totalRaised+= msg.value;    //更新募资
        _transfer(address(this),msg.sender, tokenAmount);    //发token：合约→用户
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);   //记录事件

    }

    //锁定token转账：这是重写ERC20的transfer
    function transfer(address _to, uint256 _value)public override returns(bool){
        if(!finalized && msg.sender != address(this) && initialTransferDone){    //，即如果预售还没结束，不是合约自己
            require(false, "Tokens are locked until sale is finalized");    //禁止转账
        }

        return super.transfer(_to, _value);
    }

    //逻辑同上：预售没结束，禁止转账
    function transferFrom(address _from, address _to, uint256 _value)public override returns(bool){
        if(!finalized && _from != address(this)){
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }

    //结束预售
    function finalizeSale() public payable{
        require(msg.sender == projectOwner, "Only owner can call this function");  //检查，只有项目方可以调用
        require(!finalized, "Sale is already finalized");    //防止重复结束
        require(block.timestamp > saleEndTime, "Sale is not finished yet");    //必须到时间
        finalized = true;    //标记结束
        uint256 tokensSold = totalSupply - balanceOf[address(this)];    //计算卖了多少token
        (bool success,) = projectOwner.call{value: address(this).balance}("");   //把钱给项目方，即把合约里的ETH转给项目方
        require(success, "Transfer failed");
        emit SaleFinalized(totalRaised, tokensSold);
    }

    //查看剩余时间：预售还剩多少秒
    function timeRemaining() public view returns(uint256){
        if(block.timestamp >= saleEndTime){
            return 0;
        }
        return (saleEndTime - block.timestamp);
    }

    //合约还剩多少token
    function tokensAvailable()public view returns(uint256){
        return balanceOf[address(this)];
    }

    receive() external payable{    //直接转ETH购买，即如果有人直接往合约里打ETH
        buyTokens();    //自动执行
    }
    }





//ERC20 TOKEN预售系统————流程：部署合约 → token转入合约 → 用户发送ETH → 合约发token → 预售结束 → 项目方提走ETH