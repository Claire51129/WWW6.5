// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day13_BaseERC20.sol";

/**
 * @title Day13 预售代币合约
 * @dev 限时发售 + 锁仓 + 结束结算
 */
contract PreOrderToken is day13_BaseERC20 {
    address public projectOwner;       // 项目方
    uint256 public tokenPrice;         // 代币价格（wei）
    uint256 public minPurchase;        // 最小购买金额
    uint256 public maxPurchase;        // 最大购买金额
    uint256 public saleStartTime;      // 发售开始时间
    uint256 public saleEndTime;        // 发售结束时间
    bool public finalized;             // 是否已结束发售
    bool public initialTransferDone;   // 初始转账是否完成
    uint256 public totalRaised;        // 总共募集 ETH

    event TokensPurchased(address indexed buyer, uint256 ethAmount, uint256 tokenAmount);
    event SaleFinalized(uint256 totalRaised, uint256 tokensSold);

    // 构造函数：初始化预售规则
    constructor(
        uint256 _initialSupply,
        uint256 _tokenPrice,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        uint256 _saleDuration
    ) day13_BaseERC20(_initialSupply) {
        projectOwner = msg.sender;
        tokenPrice = _tokenPrice;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDuration;
        finalized = false;
        initialTransferDone = false;
        totalRaised = 0;

        // 把所有代币转到合约，用于预售
        _transfer(msg.sender, address(this), totalSupply);
        initialTransferDone = true;
    }

    // 查询预售是否正在进行
    function isSaleActive() public view returns (bool) {
        return (!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    // 用户购买代币（支付ETH）
    function buyTokens() public payable {
        require(isSaleActive(), "Sale is not active");
        require(msg.value >= minPurchase, "Amount below min");
        require(msg.value <= maxPurchase, "Amount above max");

        // 计算可获得代币数量
        uint256 tokenAmount = (msg.value * 10 ** uint256(decimals)) / tokenPrice;
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens");

        totalRaised += msg.value;
        _transfer(address(this), msg.sender, tokenAmount);
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    // 重写转账：预售未结束 → 锁仓
    function transfer(address _to, uint256 _value) public override returns (bool) {
        if (!finalized && msg.sender != address(this) && initialTransferDone) {
            revert("Tokens locked until sale ends");
        }
        return super.transfer(_to, _value);
    }

    // 重写第三方转账：预售未结束 → 锁仓
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        if (!finalized && _from != address(this)) {
            revert("Tokens locked until sale ends");
        }
        return super.transferFrom(_from, _to, _value);
    }

    // 项目方结束预售，提取ETH
    function finalizeSale() public {
        require(msg.sender == projectOwner, "Only owner");
        require(!finalized, "Already done");
        require(block.timestamp > saleEndTime, "Sale not ended");

        finalized = true;
        uint256 tokensSold = totalSupply - balanceOf[address(this)];
        (bool ok, ) = projectOwner.call{value: address(this).balance}("");
        require(ok, "Transfer failed");
        emit SaleFinalized(totalRaised, tokensSold);
    }

    // 剩余时间
    function timeRemaining() public view returns (uint256) {
        return block.timestamp >= saleEndTime ? 0 : saleEndTime - block.timestamp;
    }

    // 合约剩余可售代币
    function tokensAvailable() public view returns (uint256) {
        return balanceOf[address(this)];
    }

    // 直接转入ETH自动购买
    receive() external payable {
        buyTokens();
    }
}