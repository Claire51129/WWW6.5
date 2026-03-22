//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
//import "./day12_SimpleERC20.sol";
import {SimpleERC20} from "./day12_SimpleERC20.sol";

contract SimplifiedTokenSale is SimpleERC20 {

    //每个代币值多少 ETH（单位是 wei，1 ETH = 10¹⁸ wei）
    uint256 public tokenPrice;
    //表示发售开始和结束时间的时间戳
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    //单笔交易中允许购买的最小和最大ETH额度
    uint256 public minPurchase;
    uint256 public maxPurchase;
    //目前为止接收的 ETH总额
    uint256 public totalRaised;
    //发售结束后接收 ETH 的钱包地址
    address public projectOwner;
    //发售是否已经正式关闭
    bool public finalized = false;
    //用于确保合约在锁定转账前已收到所有代币
    bool private initialTransferDone = false;
    //当有人成功购买代币时触发。它会记录购买者、支付的 ETH 数量以及收到的代币数量
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    //发售结束时触发。记录筹集的 ETH 总数和售出的代币数量
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);
    //constructor(...) SimpleERC20(_initialSupply)
    //这个合约继承自 SimpleERC20，所以需要把_initialSupply（初始代币数量）传递给母合约，这样才能真的铸造代币
    constructor( 
        uint256 _initialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    )   SimpleERC20(_initialSupply){
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;  
    // 将所有代币转移至此合约用于发售
    _transfer(msg.sender, address(this), totalSupply);
    // 标记我们已经从部署者那里转移了代币
    initialTransferDone = true;
}
    //判断什么时候可以买代币:finalized 不能是 true（说明发售还没结束），当前时间必须在发售时间窗口内
    function isSaleActive()public view returns(bool){
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }
    //用户在发售期间买代币，会调用 buyTokens() 并随交易发送 ETH
    function buyTokens() public payable{
        //用辅助函数isSaleActive()检查发售是否正在进行中。如果发售已结束、尚未开始或已完成，则此检查失败，交易将被撤销
        require(isSaleActive(), "Sale is not active");
        //执行最低和最高购买限额
        require(msg.value >= minPurchase, "Amount is below min purchase");
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        //计算要发多少代币
        uint256 tokenAmount = (msg.value * 10**uint256(decimals))/ tokenPrice;
        //确保合约里有足够的代币
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale");
        //更新已筹集的 ETH总额
        totalRaised+= msg.value;
        //把代币转给买家，这个 _transfer() 函数是在我们之前构建的 ERC-20 代币中定义的
        _transfer(address(this),msg.sender,tokenAmount);
        //触发购买事件
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
        
    }
    //重写子合约的transfer() 函数，这里的主要目的是在发售进行期间暂时限制代币转账
    function transfer(address _to, uint256 _value)public override returns(bool){
        //检查发售:
        //`!finalized`：发售**尚未**完成。
        // `msg.sender != address(this)`：交易**不是由合约本身**发起的（例如在 `buyTokens()` 期间）。
        //`initialTransferDone`：初始代币供应已经转移到合约中。
        //若以上三个条件都满足，交易会被撤销
        if(!finalized && msg.sender != address(this) && initialTransferDone){
            require(false, "Tokens are locked until sale is finalized");
        }
        //正常转账
        return super.transfer(_to, _value);
    }
    //重写母合约的transferFrom() — 锁定委托转账
    function transferFrom(address _from, address _to, uint256 _value)public override returns(bool){
        if(!finalized && _from != address(this)){
            require(false, "Tokens are locked until sale is finalized");
        }
        //如果检查通过（发售完成或转移由合约发起），我们使用 super 回退到原始的 ERC-20 transferFrom() ，恢复默认的转账逻辑
        return super.transferFrom(_from, _to, _value);
    }
    //这是结束代币发售的函数
    function finalizeSale() public payable{
        //访问控制和计时
        require(msg.sender == projectOwner, "Only owner can call this function");
        require(!finalized,"Sale is already finalized");
        require (block.timestamp > saleEndTime, "Sale not finished yet");
        //将发售标记为完成
        finalized = true;
        //计算已售出的代币数量
        uint256 tokensSold = totalSupply - balanceOf[address(this)];
        //向项目所有者发送 ETH
        (bool sucess,) = projectOwner.call{value:  address(this).balance}("");
        require(sucess, "Transfer failed");
        //触发最终事件:- 筹集的 ETH总额,售出的代币数量,前端页面、DApp 或区块浏览器可监听该事件，从而向用户显示发售已正式完成
        emit SaleFinalized(totalRaised, tokensSold);
    }
    //该函数返回距离发售结束还剩余多少秒
    //前端可以调用此函数来显示倒计时，例如"还剩 2 小时 15 分钟"——既能体现紧迫感，也方便用户把握最后参与时机
    function timeRemaining() public view  returns(uint256){
        if(block.timestamp >= saleEndTime){
            return 0;
        }
        return (saleEndTime - block.timestamp);
    }
    //该函数返回当前可购买的代币数量
    //前端或 DApp 可显示"剩余 X 个代币"，让买家及时了解库存、提升决策效率
    function tokensAvailable()public view returns(uint256){
        return balanceOf[address(this)];
    }
    //无需手动调用 buyTokens() 函数，只需发送 ETH ，即可参与发售
    receive() external payable{
        buyTokens();
    }
    }