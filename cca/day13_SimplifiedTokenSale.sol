// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SimpleERC20} from "./day12_SimpleERC20.sol";

contract SimplifiedTokenSale is SimpleERC20{
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
    //因为卖家是固定的
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);

    constructor(
        uint256 _initialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    ) SimpleERC20(_initialSupply) {//SimpleERC20 其实是在后台帮你把全部代币分配给部署者
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;//接收筹集的ETH 的人

        //“铸造”后部署者拥有所有代币 将所有代币转移至此合约用于发售 合约代替部署者分发代币
        _transfer(msg.sender, address(this), totalSupply);

        // 标记我们已经从部署者那里转移了代币
        initialTransferDone = true;
}

    function isSaleActive() public view returns(bool){
        return (!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    function buyTokens()public payable{
        require(isSaleActive(), "Sale is not active");
        require(msg.value >= minPurchase, "Amount is below min purchase");
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        uint256 tokenAmount = (msg.value * 10**uint256(decimals))/tokenPrice;
        require(balanceOf[address(this)] >tokenAmount, "Not enough token left for sale");
        totalRaised += tokenAmount;
        _transfer(address(this), msg.sender, tokenAmount);

        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    //为保证在发售期间暂时限制货币转账 重写transfer加上限制条件 锁定直接转账
    function transfer(address _to, uint256 _value) public override returns(bool){
        if(!finalized && msg.sender!= address(this) && initialTransferDone){
            require(false,"Tokens are locked until sale is finalized");
            //硬编码 false 的结果：当第一个参数被明确设为 false 时，这个检查条件永远无法被满足
            //require检查失败后会自动回滚 撤销交易
        }
        return super.transfer(_to, _value);//恢复默认逻辑
        //super 关键字让当前的子合约能够访问并调用其直接母合约 前提是存在virtual & override
        //super 是一个指向母辈逻辑的“快捷键”，确保你在增强功能的同时，依然能够复用那些已经测试过的
        //、核心的原始代码
    }

    function transferFrom(address _from, address _to, uint256 _value)public override returns(bool){
        if(!finalized && _from != address(this)){
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }

    function finalizeSale()public payable{
        require(msg.sender == projectOwner, "only Owner can call the function");
        require(!finalized, "Sale already finalized");
        require(block.timestamp > saleEndTime, "Sale not finished yet");

        finalized = true;
        uint256 totalTokensSold = totalSupply - balanceOf[address(this)];
        (bool success, ) = payable(projectOwner).call{value :address(this).balance}("");//其实call没有payable也能转账 只有send和tranfer要求
        require(success, "Transfer to project owner failed");
        emit SaleFinalized(totalRaised,totalTokensSold);

    }//finalized 设置为 true，合约的行为模式将发生永久性转变，从“发售模式”切换到“自由流通模式”
    //而非每次都要计算发售时间是否结束 transfer函数中利用这个作为状态切换的条件 

    function timeRemaining() public view returns(uint256){
        if(block.timestamp >= saleEndTime){
            return 0;
        }
        return saleEndTime - block.timestamp;
    }

    function tokensAvailable() public view returns (uint256) {
        return balanceOf[address(this)];
}

    receive() external payable {
        buyTokens();
    }//特殊的回退函数 - 有人直接向合约地址发送 ETH/且未指定要调用的任何函数时触发 
    //通常未定义时购买会直接失败 但是这样转入ETH合约会自动调用buyTokens()



}