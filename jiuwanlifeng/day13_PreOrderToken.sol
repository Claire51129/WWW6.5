// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入 Token 合约
import "./day13_MyToken.sol";

/*
    Token 预售合约
    功能：
    - Token 预售
    - 限制购买金额
    - 限制预售时间
    - 预售结束后解锁 Token
*/

contract PreOrderToken is MyToken {

    // Token 价格（单位：wei）
    uint256 public tokenPrice;

    // 预售开始时间
    uint256 public saleStartTime;

    // 预售结束时间
    uint256 public saleEndTime;

    // 最小购买金额
    uint256 public minPurchase;

    // 最大购买金额
    uint256 public maxPurchase;

    // 总募集 ETH
    uint256 public totalRaised;

    // 项目方地址
    address public projectOwner;

    // 是否已经结束预售
    bool public finalized = false;

    // 防止 constructor 转账被锁定
    bool private initialTransferDone = false;

    // 购买 Token 事件
    event TokensPurchased(
        address indexed buyer,
        uint256 etherAmount,
        uint256 tokenAmount
    );

    // 预售结束事件
    event SaleFinalized(
        uint256 totalRaised,
        uint256 totalTokensSold
    );

    /*
        构造函数
        初始化 Token 预售参数
    */
    constructor(
        uint256 _initialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    )

    // 调用父合约 MyToken 构造函数
    MyToken(_initialSupply)
    {
        tokenPrice = _tokenPrice;

        // 设置预售开始时间
        saleStartTime = block.timestamp;

        // 设置预售结束时间
        saleEndTime = block.timestamp + _saleDurationInSeconds;

        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;

        projectOwner = _projectOwner;

        // 把所有 Token 转入合约中用于出售
        _transfer(msg.sender, address(this), totalSupply);

        initialTransferDone = true;
    }

    /*
        判断预售是否仍然进行
    */
    function isSaleActive() public view returns(bool){

        return(
            !finalized &&
            block.timestamp >= saleStartTime &&
            block.timestamp <= saleEndTime
        );
    }

    /*
        购买 Token
    */
    function buyTokens() public payable{

        require(isSaleActive(), "Sale is not active");

        require(msg.value >= minPurchase, "Below min purchase");

        require(msg.value <= maxPurchase, "Above max purchase");

        // 计算可购买的 Token 数量
        uint256 tokenAmount =
        (msg.value * 10**uint256(decimals)) / tokenPrice;

        // 检查合约是否还有足够 Token
        require(
            balanceOf[address(this)] >= tokenAmount,
            "Not enough tokens left"
        );

        // 更新募集金额
        totalRaised += msg.value;

        // Token 从合约发送给购买者
        _transfer(address(this), msg.sender, tokenAmount);

        emit TokensPurchased(
            msg.sender,
            msg.value,
            tokenAmount
        );
    }

    /*
        在预售结束前禁止 Token 自由交易
    */
    function transfer(address _to, uint256 _value)
        public
        override
        returns(bool)
    {
        if(
            !finalized &&
            msg.sender != address(this) &&
            initialTransferDone
        ){
            revert("Tokens are locked until sale is finalized");
        }

        return super.transfer(_to, _value);
    }

    /*
        transferFrom 同样锁定
    */
    function transferFrom(address _from, address _to, uint256 _value)
        public
        override
        returns(bool)
    {
        if(!finalized && _from != address(this)){
            revert("Tokens are locked until sale is finalized");
        }

        return super.transferFrom(_from, _to, _value);
    }

    /*
        结束预售
    */
    function finalizeSale() public{

        require(
            msg.sender == projectOwner,
            "Only owner can finalize"
        );

        require(!finalized, "Sale already finalized");

        require(
            block.timestamp > saleEndTime,
            "Sale not finished yet"
        );

        finalized = true;

        // 计算卖出的 Token 数量
        uint256 tokensSold =
        totalSupply - balanceOf[address(this)];

        // 把募集的 ETH 转给项目方
        (bool success,) =
        projectOwner.call{value: address(this).balance}("");

        require(success, "Transfer failed");

        emit SaleFinalized(
            totalRaised,
            tokensSold
        );
    }

    /*
        查看预售剩余时间
    */
    function timeRemaining() public view returns(uint256){

        if(block.timestamp >= saleEndTime){
            return 0;
        }

        return saleEndTime - block.timestamp;
    }

    /*
        查看剩余 Token
    */
    function tokensAvailable() public view returns(uint256){
        return balanceOf[address(this)];
    }

    /*
        直接向合约发送 ETH 自动购买 Token
    */
    receive() external payable{
        buyTokens();
    }
}