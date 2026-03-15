//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./Day12_ERC20.sol";
contract PreOrderToken is SimpleERC20 {
//Pre是SimpleERC20的一种
//is = 继承，拿到母合约所有功能
//构造函数里先调用母合约，再初始化自己的变量
    uint256 public tokenPrice;//预售代币价格
    uint256 public saleStartTime;//开始时间
    uint256 public saleEndTime;//结束时间
    uint256 public minPurchase;//最少
    uint256 public maxPurchase;//最多买多少
    uint256 public totalRaised;//总共多少钱
    address public projectOwner;//收钱的地址？
    bool public finalized = false;//销售结束没
    bool private initialTransferDone = false;//初始转账了吗

    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    //有人购买了
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);
    //销售结束了

    constructor( 
        uint256 _intitialSupply,//总供应量
        uint256 _tokenPrice,//价格
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    )SimpleERC20 (_intitialSupply){
        tokenPrice = _tokenPrice;//把每个代币的价格记录下来，单位是 wei （ ETH 的最小单位），
        //就像一块钱拆成一分、一厘一样。如果tokenPrice = 10**16，
        //就代表一个代币的成本为 0.01 ETH 。
        saleStartTime = block.timestamp;//我们将发售的开始时间标记为现在——即合约部署的那一秒。
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        //我们通过在开始时间上添加持续时间（以秒为单位） 来设置结束时间
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;
    

    _transfer(msg.sender, address(this), totalSupply);//所有币转给合约自己
    initialTransferDone = true;//这个布尔值会在 transfer() 函数中使用，
    //用来确保锁定功能只有在代币已转入合约之后才生效。
    //合约地址也持有币，充当自动售货机
    //卖的币从合约地址转给买家
    //在构造函数里，程序会自动地将所有代币从部署者（你）转移至合约里
}
    function isSaleActive()public view returns(bool){
    //这个函数是用来检查发售是否正在进行，整个合约会用这个函数来判断什么时候可以买代币
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }
//三个条件同时满足才可购买：没结束 + 开始时间到 + 没超时
    function buyTokens() public payable{//主动调用购买，接受ETH的方式一
    //主要的购买函数
        require(isSaleActive(), "Sale is not active");
        require(msg.value >= minPurchase, "Amount is below min purchase");
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        uint256 tokenAmount = (msg.value * 10**uint256(decimals))/ tokenPrice;
        //计算要发多少代币
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale");
        //确保合约里有足够的代币
        totalRaised+= msg.value;
        //这句代码会记录本次发售中接收的 ETH 的累计总额。发售结束时，我们会用这个总额来结账。
        _transfer(address(this),msg.sender,tokenAmount);
        //这里就是代币真的“动起来”的地方。合约会把自己账户里的代币转给买家。
        //这个 _transfer() 函数是在我们之前构建的 ERC-20 代币中定义的。
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
        //触发购买事件
        
    }

    function transfer(address _to, uint256 _value)public override returns(bool){
        if(!finalized && msg.sender != address(this) && initialTransferDone){
            require(false, "Tokens are locked until sale is finalized");
        }
//预售期间锁定转账（只能买不能卖），销售结束后才能自由转账
//重写函数？
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)public override returns(bool){
        if(!finalized && _from != address(this)){
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }
//锁定委托转账。即某人代表另一个钱包消费代币（通常在 approve() 调用之后）。
    function finalizeSale() public payable{
    //这是结束代币发售的函数
        require(msg.sender == projectOwner, "Only owner can call this function");
        require(!finalized,"Sale is already finalized");
        require (block.timestamp > saleEndTime, "Sale not finished yet");
        finalized = true;
        uint256 tokensSold = totalSupply - balanceOf[address(this)];
        //计算已售出的代币数量
        (bool sucess,) = projectOwner.call{value:  address(this).balance}("");
        require(sucess, "Transfer failed");
        //此处把发售期间筹集到的全部 ETH 转给  projectOwner。
        emit SaleFinalized(totalRaised, tokensSold);
    }
//最后，我们触发 SaleFinalized 事件，其中包含：- 筹集的 ETH总额和售出的代币数量
    function timeRemaining() public view  returns(uint256){
        if(block.timestamp >= saleEndTime){
            return 0;
        }
        return (saleEndTime - block.timestamp);
    }

    function tokensAvailable()public view returns(uint256){
        return balanceOf[address(this)];
    }

    receive() external payable{//直接转ETH自动触发购买
        buyTokens();
    }
    }





