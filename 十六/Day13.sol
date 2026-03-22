// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ShiliuToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Shiliu Token", "SLT") {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }
}

contract ShiliuSale is Ownable {
    ShiliuToken public tokenContract;
    uint256 public tokenPrice = 1000;

    event Sold(address indexed buyer, uint256 amount);

    constructor(address _tokenAddress) Ownable(msg.sender) {
        tokenContract = ShiliuToken(_tokenAddress);
    }

    function buyTokens() public payable {
        uint256 _amount = msg.value * tokenPrice;
        require(tokenContract.balanceOf(address(this)) >= _amount, "Insufficient tokens");
        require(tokenContract.transfer(msg.sender, _amount), "Transfer failed");
        emit Sold(msg.sender, _amount);
    }

    receive() external payable {
        buyTokens();
    }

    function tokensAvailable() public view returns (uint256) {
        return tokenContract.balanceOf(address(this));
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdraw failed");
    }
}
