// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//目的：构建一个代币发售合约，建立在创建好的ERC20代币合约基础上
import "./day12-SimpleERC20.sol";

contract PreOrderTokens is SimpleERC20 {
    //声明状态变量
    uint256 public tokenPrice; //每个代币值多少ETH（单位为wei）
    uint256 public saleStartTime; //发售开始时间
    uint256 public saleEndTime; //发售结束时间
    uint256 public minPurchase; //单笔交易中允许购买的最小ETH额度（单位为wei）
    uint256 public maxPurchase; //单笔交易中允许购买的最大ETH额度（单位为wei）
    uint256 public totalRaised; //目前为止接收到的ETH总额（单位为wei）
    address public projectOwner; //发售结束后接收ETH的钱包地址
    bool public finalized = false; //发售是否已经正式关闭
    bool private initialTransferDone = false; //确保合约在锁定转账前已收到所有代币

    //创建事件
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount); //当有人成功购买代币时触发的事件
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold); //当发售结束时触发的事件

    //构造函数
    constructor(
        uint256 _initialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    ) SimpleERC20(_initialSupply) { //在此处将初始代币数量（_initialSupply）传递给母合约SimpleERC20，再由母合约将全部代币分配给部署者
        tokenPrice = _tokenPrice; //记录每个代币的价格（单位为wei）
        saleStartTime = block.timestamp; //合约部署的那一秒即为发售开始时间
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;

        //自动将所有代币转移至此合约用于发售
        _transfer(msg.sender, address(this), totalSupply);

        //标记我们已经从部署者那里转移了代币
        initialTransferDone = true;
    }

    //检查发售是否正在进行的函数，用于判断什么时候可以购买代币
    function isSaleActive() public view returns (bool) {
        return (!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    //主要购买函数
    function buyTokens() public payable {
        require(isSaleActive(), "Sale is not active.");
        require(msg.value >= minPurchase, "Amount is below minimum purchase.");
        require(msg.value <= maxPurchase, "Amount exceeds maximum purchase.");

        uint256 tokenAmount = (msg.value * 10**uint256(decimals)) / tokenPrice; //计算要发多少代币给买家：买家发送的ETH数量（先换算成ETH单位）除以每个代笔的价格
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale."); //确保合约里有足够的代币可以发给买家

        totalRaised += msg.value;
        _transfer(address(this), msg.sender, tokenAmount); //把代币转给买家
        emit TokensPurchased(msg.sender, msg.value, tokenAmount); //触发事件
    }

    //重写transfer()函数——锁定直接转账（Question：什么是“锁定”？）
    function transfer(address _to, uint256 _value) public override returns (bool) {
        if (!finalized && msg.sender != address(this) && initialTransferDone) { //检查三件事：发售尚未完成、交易不是由合约本身发起的、初始代币已转移到合约中
            require(false, "Tokens are locked until sale is finalized."); //如果上述三个条件全都满足（为true），交易就会被撤销，函数会回滚（阻止提前交易代币）
        }
        return super.transfer(_to, _value); //如果为false，只需调用母合约的原始函数transfer()函数即可，会执行实际的转账逻辑
    }

    //重写transferFrom()函数——锁定委托转账
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) { //发售锁定检查
        if (!finalized && _from != address(this)) {
            require(false, "Tokens are locked until sale is finalized.");
        }
        return super.transferFrom(_from, _to, _value); //通过检查即恢复默认的函数逻辑（使用super来回退到母合约中的原始逻辑）
    }

    //结束代币发售（并将所得转给所有者）的函数
    function finalizeSale() public payable {
        require(msg.sender == projectOwner, "Only owner can call the function."); //只有所有者可以操作结束
        require(!finalized, "Sale already finalized."); //必须是未完成发售的状态（不能重复调用）
        require(block.timestamp > saleEndTime, "Sale not finished yet."); //确保发售时间已结束（不能提前终止）

        finalized = true;
        uint256 tokensSold = totalSupply - balanceOf[address(this)]; //计算本次实际售出的代币：总发行量-当前合约中仍然持有的代币数量

        (bool success, ) = projectOwner.call{value: address(this).balance}(""); //用“.call{value:...}”来发送全部ETH给projectOwner
        require(success, "Transfer to project owner failed.");

        emit SaleFinalized(totalRaised, tokensSold);
    }

    //发售状态辅助函数
    //查看距离发售结束还剩多少时间的函数
    function timeRemaining() public view returns (uint256) {
        if (block.timestamp >= saleEndTime) {
            return 0;
        }
        return saleEndTime - block.timestamp;
    }
    //查看可购买代币数量的函数
    function tokensAvailable() public view returns (uint256) {
        return balanceOf[address(this)];
    }

    //ETH回退处理器——当有人直接向合约转入ETH且未指定要调用的任何函数时，可以允许ETH流入并自动调用buyTokens()完成购买流程（Question：为什么？）
    receive() external payable {
        buyTokens();
    }
}