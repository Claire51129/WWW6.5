// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day12_ERC20.sol";  // 修改导入路径

// 安全版代币预售合约
contract PreOrderToken is SimpleERC20 {  // 修改继承类

    uint256 public tokenPrice;            // 每个代币价格（wei）
    uint256 public saleStartTime;         // 售卖开始时间
    uint256 public saleEndTime;           // 售卖结束时间
    uint256 public minPurchase;           // 最小购买金额（wei）
    uint256 public maxPurchase;           // 最大购买金额（wei）
    uint256 public totalRaised;           // 总筹集 ETH
    address public projectOwner;          // 项目方地址
    bool public finalized = false;        // 售卖是否结束
    bool private initialTransferDone = false;

    // Events
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);

    // 构造函数，初始化代币和售卖参数
    constructor( 
        uint256 _initialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    ) SimpleERC20(_initialSupply) {  // 修改构造函数调用
        require(_projectOwner != address(0), "Invalid project owner");

        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;

        // 初始代币转到合约地址
        _transfer(msg.sender, address(this), totalSupply);
        initialTransferDone = true;
    }

    // 判断售卖是否进行中
    function isSaleActive() public view returns (bool) {
        return (!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    // 购买代币
    function buyTokens() public payable {
        require(isSaleActive(), "Sale is not active");
        require(msg.value >= minPurchase, "Amount below min purchase");
        require(msg.value <= maxPurchase, "Amount above max purchase");

        uint256 tokenAmount = (msg.value * 10**uint256(decimals)) / tokenPrice;
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale");

        totalRaised += msg.value;
        _transfer(address(this), msg.sender, tokenAmount);

        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    // 重写 transfer，锁定售卖期间代币
    function transfer(address _to, uint256 _value) public override returns (bool) {
        if (!finalized && msg.sender != address(this) && initialTransferDone) {
            revert("Transfers locked during sale");
        }
        return super.transfer(_to, _value);
    }

    // 重写 transferFrom，锁定售卖期间代币
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        if (!finalized && _from != address(this)) {
            revert("Transfers locked during sale");
        }
        return super.transferFrom(_from, _to, _value);
    }

    // 售卖结束，转 ETH 给项目方并解锁代币
    function finalizeSale() public {
        require(msg.sender == projectOwner, "Only project owner can finalize");
        require(!finalized, "Sale already finalized");
        require(block.timestamp > saleEndTime, "Sale not finished yet");

        finalized = true;
        uint256 tokensSold = totalSupply - balanceOf[address(this)];

        // 添加转移 ETH 到项目所有者的代码
        (bool success, ) = payable(projectOwner).call{value: address(this).balance}("");
        require(success, "ETH transfer failed");

        emit SaleFinalized(totalRaised, tokensSold);
    }

    // 剩余售卖时间（秒）
    function timeRemaining() public view returns (uint256) {
        if (block.timestamp >= saleEndTime) {
            return 0;
        }
        return saleEndTime - block.timestamp;
    }

    // 合约地址剩余代币
    function tokensAvailable() public view returns (uint256) {
        return balanceOf[address(this)];
    }

    // 直接发送 ETH 调用 buyTokens()
    receive() external payable {
        buyTokens();
    }
}