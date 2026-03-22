//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day13_MyToken.sol";

contract PreOrderToken is SimpleERC20{
      
    bool private initialTransferDone = false;
    address public projectOwner;
    uint256 public tokenPrice;
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public totalRaised;
    bool public finalized = false;


event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);

    constructor(
        uint256 _initialSupply,
        uint256 _tokenPrice,
        uint256 _durationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner 
    ) SimpleERC20(_initialSupply) {     
        
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _durationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;

        initialTransferDone = true;
    }


    function isSaleActive() public view returns(bool) {
        return (!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    function buyTokens() public payable {

            require(isSaleActive()==true,"Sale is not active");
            require(msg.value >= minPurchase && msg.value <= maxPurchase,"You must send between min and max amounts");

            uint256 tokenAmount = (msg.value * 10**uint256(decimals)) / tokenPrice;
            require(balances[address(this)] >= tokenAmount,"Not enough tokens left for sale");
            totalRaised += msg.value;
            _transfer(address(this),msg.sender,tokenAmount);

            emit TokensPurchased(address(this), msg.value, tokenAmount);
     }
    

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

        return super.transferFrom(_from, _to, _value);
    }


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