//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./day12-SimpleERC20.sol";

contract SimplifiedTokenSale is SimpleERC20 {

    uint256 public tokenPrice; // 每个代币值多少 ETH（单位是 wei，1 ETH = 10¹⁸ wei）
    uint256 public saleStartTime; // 表示发售开始时间的时间戳
    uint256 public saleEndTime; // 表示发售结束时间的时间戳
    uint256 public minPurchase; // 单笔交易中允许购买的最小ETH额度
    uint256 public maxPurchase; // 单笔交易中允许购买的最大ETH额度
    uint256 public totalRaised; // 目前为止接收的 ETH总额
    address public projectOwner; // 发售结束后接收 ETH 的钱包地址
    bool public finalized = false; // 发售是否已经正式关闭
    bool private initialTransferDone = false; // 用于确保合约在锁定转账前已收到所有代币

    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount); // 当有人成功购买代币时触发。它会记录购买者、支付的 ETH 数量以及收到的代币数量。
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold); // 发售结束时触发。记录筹集的 ETH 总数和售出的代币数量。


    constructor( 
        uint256 _intitialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    )SimpleERC20(_intitialSupply){
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;
    
        _transfer(msg.sender, address(this), totalSupply); // 将所有代币从部署者转移至此合约用于发售
        initialTransferDone = true; // 标记从部署者到合约的代币交接已经完成。这个布尔值会在 transfer() 函数中使用，用来确保锁定功能只有在代币已转入合约之后才生效。
    }
    /* 小括号内部时部署时需要输入的参数；“SimpleERC20(_intitialSupply)”中_intitialSupply是母合约SimpleERC20构造函数中的初始化参数。花括号内部是该函数需要处理的逻辑运算和赋值。
    必须显式初始化母合约：在部署时，输入子合约初始化参数，其中_intitialSupply会传递给母合约（因此母合约构造函数要求的变量必须在子合约构造函数中声明）。先完整执行母合约构造函数，再执行子合约构造函数。*/


    function isSaleActive()public view returns(bool){
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }
    // 这个函数是用来检查发售是否正在进行：(1) finalized 不能是 true（说明发售还没结束）.（2）当前时间必须在发售时间窗口内.

    function buyTokens() public payable{
        require(isSaleActive(), "Sale is not active");
        require(msg.value >= minPurchase, "Amount is below min purchase");
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        uint256 tokenAmount = (msg.value * 10**uint256(decimals))/ tokenPrice; // 买家获得代币数量
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale"); // 检查合约里是否有足够的代币数量来满足买家请求
        totalRaised+= msg.value;
        _transfer(address(this),msg.sender,tokenAmount);
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }
    // 这个函数就是用户在发售期间买代币时要用的，他们会调用 buyTokens() 并随交易发送 ETH。

    function transfer(address _to, uint256 _value)public override returns(bool){
        if(!finalized && msg.sender != address(this) && initialTransferDone){
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transfer(_to, _value);
    }
    /* 重写母合约的 transfer() 函数 — 锁定发售期间的代币直接转账。
    如果发售尚未完成，且交易不是由本合约自己发起的（是用户调用），且初始代币供应已经转移到合约中：提示locked，函数回滚，交易撤销；
    如果发售已经完成，或者交易是由本合约自己发起的，或者发售尚未开始：可以调用母合约原始transfer函数，执行转账逻辑。
    
    ### 防御性编程
    Q：为什么需要 msg.sender != address(this)？这里拦截用户调用本函数买币，但用户是通过buyTokens()交易的，不调用transfer()；允许address(this)调用transfer函数，但暂时没有这个场景。
    Q：为什么需要 initialTransferDone = true？合约部署后即恒定为true，不会出现false。
    A：确保任何进入转帐逻辑的入口不会被误封。如果将来你或别的开发者修改了代码或继承了本合约，让合约的某个功能（比如退款、奖励）需要在发售期间去调用 transfer，或者构造函数中改用了 transfer，没有前述判断，合约自己也会被自己锁死或无法完成初始化。也就是说，这行代码是给合约地址留的一个“后门”，确保“只要是合约发起的转账，都不受销售锁定的限制”“发售尚未开始，不需要锁定”。*/

    /* super：跳过当前定义，去执行母合约中同名函数。
    使用super：功能增强。在父类逻辑的基础上，增加一些额外的检查、记录或修改。好处：母合约代码维护后，子合约逻辑自动更新，避免不一致性；如果子合约里重写一遍，重复的代码会增加合约的大小，导致部署合约时消耗更多额gas。
    不写super：完全替换。彻底抛弃父类的逻辑，只运行子类写的代码。
    注意不可以“return transfer(_to, _value);”，会再次执行子合约的if-return transfer，陷入无限递归（Infinite Recursion），最终导致 Gas 耗尽而交易失败（Out of Gas）。*/

    function transferFrom(address _from, address _to, uint256 _value)public override returns(bool){
        if(!finalized && _from != address(this)){
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }
    /* 重写母合约的 transferFrom() 函数 — 锁定发售期间的代币委托转账。
    Q：为什么transferFrom()不检查initialTransferDone？
    A：认为合约部署的初始化阶段不会发生授权和委托转账。*/

    function finalizeSale() public payable{ // 这是结束代币发售的函数
        require(msg.sender == projectOwner, "Only owner can call this function"); // 只有projectOwner可以结束发售
        require(!finalized,"Sale is already finalized"); // 检查是否为未完成发售状态——如果已完成，则不允许再次调用
        require (block.timestamp > saleEndTime, "Sale not finished yet");
        finalized = true; // 将 finalized 状态变量设置为已完成。以便其他函数（如 transfer() 和 transferFrom()）识别发售已结束，解除锁定，恢复自由转账。
        uint256 tokensSold = totalSupply - balanceOf[address(this)]; // 已售出的代币数量
        (bool success,) = projectOwner.call{value: address(this).balance}(""); // 将发售期间筹集到的全部 ETH 转给 projectOwner
        require(success, "Transfer failed"); // 提取成功触发emit，失败则提示
        emit SaleFinalized(totalRaised, tokensSold); // 筹集的 ETH总额，售出的代币数量。前端页面、DApp 或区块浏览器可监听该事件，从而向用户显示发售已正式完成。
    }

    function timeRemaining() public view returns(uint256){
        if(block.timestamp >= saleEndTime){
            return 0;
        }
        return (saleEndTime - block.timestamp);
    }
    // 前端可以调用此函数来显示倒计时

    function tokensAvailable()public view returns(uint256){
        return balanceOf[address(this)];
    }
    // 前端可调用此函数来显示库存

    receive() external payable{
        buyTokens();
    }
    /*在 Solidity 中，receive() 函数是一个特殊的回退函数，在满足以下条件时被触发：
        - 有人 直接 向合约地址发送 ETH
        - 且 未指定要调用的任何函数
    通常若合约未定义该函数，外部直接转入 ETH 的交易会失败。
    但在这种情况下，我们定义了 receive()，只要有人向该合约转入 ETH（即使只是从 MetaMask 或简单的钱包转账），合约都会在后台自动调用buyTokens()完成购买流程。
    这意味着：用户无需进入 dApp 的界面操作，无需手动调用 buyTokens() 函数，只需发送 ETH ，即可参与发售。
    receive() 既是安全兜底，又是快速通道。它的功能是允许ETH流入，并将 ETH 直接路由到代币销售逻辑中。*/ 

}





