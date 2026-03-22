//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./day13_ERC20_OpenZeppelin.sol";
//继承自MyToken合约，因为是MT从open zeppelin调用，主要使用 totalSupply()、decimals()、balanceOf(addrress) 她们的函数接口，强调函数借口，是与另一个day13使用状态变量的情况对比
contract PreOrderToken is MyToken {

    uint256 public tokenPrice; //代币价格
    uint256 public saleStartTime; //发售开始事件
    uint256 public saleEndTime; //发售结束事件
    uint256 public minPurchase; //最小购入量，省gas
    uint256 public maxPurchase; //最大购入量，防机器人或者恶意购买
    uint256 public totalRaised; //总共筹集到的ETH
    address public projectOwner; //项目拥有者
    bool public finalized = false; //定义预售结束状态为false，下方锁定转账以及结束预售函数用得到
    bool private initialTransferDone = false; //定义初始转账状态为false，下方代币转入合约和锁定转账函数用得到

    //设置两个事件，可以让前端/DAPP/区块链浏览器都看到，可视化，吸引人们购买，以及展示交易记录
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount); //谁用多少ETH买了多少GDT
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold); //预售结束时出现，总筹集ETH量，代币卖出总量

    constructor( //构架函数，以下变量需要在部署时确定
        uint256 _intitialSupply, //初始供应量
        uint256 _tokenPrice, //代币价格
        uint256 _saleDurationInSeconds, //预售持续时间，单位秒
        uint256 _minPurchase, //最小购买量
        uint256 _maxPurchase, //最大
        address _projectOwner 
    )MyToken(_intitialSupply){ //根据ERC-20规则，部署者地址拥有所有代币
        tokenPrice = _tokenPrice; 
        saleStartTime = block.timestamp; //开始时间就是部署时间
        saleEndTime = block.timestamp + _saleDurationInSeconds; //结束时间是部署时间+持续时间
        minPurchase = _minPurchase; 
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;
    

    _transfer(msg.sender, address(this), totalSupply());//为了部署者不用一笔笔分发，将全部代币转给本合约，合约完成分发
    initialTransferDone = true; //初始代币转移完成，将其设置为true
}
    function isSaleActive()public view returns(bool){ //预售是否进行中，下方买代币函数用这个判断是否能买
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    function buyTokens() public payable{ //买代币函数，payable
        require(isSaleActive(), "Sale is not active"); //用上了刚才的函数
        require(msg.value >= minPurchase, "Amount is below min purchase"); //最大量和最小量核查
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        uint256 tokenAmount = (msg.value * 10**uint256(decimals()))/ tokenPrice; //计算用户发来的ETH可以购买多少代币，注意此时算出的tokenAmount是最小单位
        require(balanceOf(address(this))>= tokenAmount, "Not enough tokens left for sale");
        totalRaised+= msg.value;//筹集量增加
        _transfer(address(this),msg.sender,tokenAmount); //调用母合约的_transfer函数
        emit TokensPurchased(msg.sender, msg.value, tokenAmount); //触发购买成功时间
        
    }

    function transfer(address _to, uint256 _value)public override returns(bool){ //子合约override+母合约virtual可以重写母合约函数
        //满足三个条件的情况下，不可转账，其一不满足则可以转账，return调用母合约函数
        //finalized = false 预售未结束时用户间不能转账
        //msg.sender != address(this) 不是合约地址调用转账：只有合约地址能转账
        //initialTransferDone = true 初始转账完成。给上面代币转给合约地址留口子，如果没有这个条件，没来得及初始合约代币就执行了，合约就没钱
        if(!finalized && msg.sender != address(this) && initialTransferDone){
            require(false, "Tokens are locked until sale is finalized");//三个条件满足的情况下，会判定false，出现后面的话
        }

        return super.transfer(_to, _value); //super.是固定语法，用于子合约调用母合约函数
    }

    function transferFrom(address _from, address _to, uint256 _value)public override returns(bool){
        //同上，如果合约结束或者是本合约地址想转移授权金额，就可以执行母合约的transferFrom函数
        if(!finalized && _from != address(this)){
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }

    function finalizeSale() public payable{ //预售结束时调用
        //只有项目拥有者可以调用
        require(msg.sender == projectOwner, "Only owner can call this function");
        //finalized为false才能往下，一个项目只能结束一次
        require(!finalized,"Sale is already finalized");
        //当前时间要晚于预售结束时间
        require (block.timestamp > saleEndTime, "Sale not finished yet");
        finalized = true;//定义结束状态为true，前面的转账和授权转账函数都能用了
        uint256 tokensSold = totalSupply() - balanceOf(address(this)); //算一下卖出了多少代币
        (bool sucess,) = projectOwner.call{value: address(this).balance}(""); //剩下的代币转到项目拥有者地址
        require(sucess, "Transfer failed"); //失败预警
        emit SaleFinalized(totalRaised, tokensSold); //触发项目结束时间，告知总筹集ETH，和总售出量
    }

    function timeRemaining() public view  returns(uint256){ //一个可读的项目持续时间函数，告知其他人项目剩余多少时间
        if(block.timestamp >= saleEndTime){
            return 0;
        }
        return (saleEndTime - block.timestamp);
    }

    function tokensAvailable()public view returns(uint256){ //一个可读的代币剩余数量函数
        return balanceOf(address(this));
    }

    //ETH回退，如果有人发来了ETH却没有调用buyToken（），这个函数就会自动执行buyToken（），帮用户买好。防止用户流失，也是个快速通道
    receive() external payable{ 
        buyTokens();
    }
}
