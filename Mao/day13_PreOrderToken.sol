//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day12_ERC20.sol";
//预购代币
/*
用户  发送 ETH 发售合约
发售合约 确认收到钱 计算代币数
发售合约 调用 代币合约的 Mint/Transfer函数  代币发送给用户
*/

/*
这个“发售合约”的工作流程
我们可以用“全自动售票机”来类比这个合约：
你是老板（项目方）： 你先把“售票机”（发售合约）造好，并告诉它：1 个 ETH 换 1000 个代币。
它是管家（发售合约）： 所有的代币先放在它这里保管。
用户是买家： 他们把 ETH 丢进机器。机器自动计算：“哦，你给了 0.5 个 ETH，那给你 500 个代币。”
限制条件（逻辑重写）： 用户拿到代币后很开心，想立刻卖给别人。但因为你重写了转账函数，系统会报错：“对不起，发售还没结束，你的代币目前处于锁定状态。”
收钱（完成交易）： 发售日期一到，你点一下“结束”按钮。这时候：
用户的代币解锁了，可以自由买卖。
用户之前付的所有 ETH，都会一次性转进你的钱包里。
*/

contract SimplifiedTokenSale is SimpleERC20{
      
    bool private initialTransferDone = false;
    address public projectOwner;    // 项目方地址
    uint256 public tokenPrice;      // 汇率：1 ETH 兑换多少 Token
    uint256 public saleStartTime;   // 发售开始时间戳
    uint256 public saleEndTime;     // 发售结束时间戳
    uint256 public minPurchase;     // 最低购买金额 (单位: Wei)  ETH
    uint256 public maxPurchase;     // 最高购买金额 (单位: Wei)  ETH
    uint256 public totalRaised;     // 已筹集到的 ETH 总量
    bool public finalized = false;  // 发售是否已完成（结算）


event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);


    /**
     * @dev 构造函数：在合约部署的一瞬间执行。
     * * 这里有一个特殊的语法：SimpleERC20(_initialSupply)
     * 它的意思是：在运行子类逻辑之前，先带着 _initialSupply 这个参数去运行父类（SimpleERC20）的构造函数。
     */
    constructor(
        uint256 _initialSupply,         // 1. 想要印币的总量（例如：1000000）
        uint256 _tokenPrice,            // 2. 价格：1 ETH 换多少币（例如：1000）
        uint256 _durationInSeconds,     // 3. 发售持续时间（单位：秒，例如：3600）
        uint256 _minPurchase,           // 4. 最少买多少（防止恶意刷单）
        uint256 _maxPurchase,           // 5. 最多买多少（防止大户包场）
        address _projectOwner           // 6. 项目方钱包（发售完谁来领钱）
    ) SimpleERC20(_initialSupply) {     // 【关键点】先让父类印好币，并把币给到 msg.sender 手里
        
        // --- 第一步：把传入的参数存到合约的状态变量里，定好“发售规则” ---
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;                     // 记录当前开始时间
        saleEndTime = block.timestamp + _durationInSeconds; // 计算结束时间
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;

        // --- 第二步：核心资产划转 ---
        /**
         * 此时的情况：父类构造函数刚刚跑完，所有的币都在部署者（msg.sender）钱包里。
         * 现在的动作：调用父类的内部转账函数 _transfer。
         * 逻辑：把部署者刚到手的币，全部划转给“合约自己”（address(this)）。
         * 目的：让合约账户成为“持币者”，这样它才能像自动售货机一样，在收到 ETH 后自动把币吐给买家。
         */
        _transfer(msg.sender, address(this), totalSupply);

        // --- 第三步：状态标记 ---
        // 标记资产划转已完成，发售准备就绪
        initialTransferDone = true;
    }

    //检查发售是否还在进行
    function isSaleActive() public view returns(bool) {
        return (!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    //主要购买函数
    //用ETH购买代币，首先前提检查（是否还在发售、ETH是否符合最大以及最小限制）、购买操作（ETH可以购买多少、合约里有足够代币、更新ETH总额、转给买家、更新代币金额）、触发购买事件
    function buyTokens() public payable {
            //首先前提检查（是否还在发售、ETH是否符合最大以及最小限制）
            require(isSaleActive()==true,"Sale is not active");
            require(msg.value >= minPurchase && msg.value <= maxPurchase,"You must send between min and max amounts");
            //购买操作（ETH可以购买多少、合约里有足够代币、更新ETH总额、转给买家）
            uint256 tokenAmount = (msg.value * 10**uint256(decimals)) / tokenPrice;
            require(balances[address(this)] >= tokenAmount,"Not enough tokens left for sale");
            totalRaised += msg.value;
            _transfer(address(this),msg.sender,tokenAmount);
           // balances[address(this)] -= tokenAmount; 不需要更新代币金额，在_transfer 函数内部 已经更新
        
            //触发购买事件
            emit TokensPurchased(address(this), msg.value, tokenAmount);
     }
    
    //重写transfer，发售进行期间暂时限制代币转账。
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
        // 如果通过了上面的检查（比如已经结算了），则调用母类（super）原本的转账功能
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev 第二部分：发售结算（老板提款机）
     * 该函数负责结束发售、解锁代币交易、并将筹集的 ETH 转给项目方。
     */
    function finalizeSale() public payable {
        require(msg.sender == projectOwner, "Only Owner can call the function");
        require(!finalized, "Sale already finalized");
        require(block.timestamp > saleEndTime, "Sale not finished yet");

        finalized = true;
        uint256 tokensSold = totalSupply - balances[address(this)];

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
        return balances[address(this)];
    }

    receive() external payable {
        buyTokens();
    }
 
}