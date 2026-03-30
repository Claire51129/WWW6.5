// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StableCoin {
    string public name = "Mini USD";
    string public symbol = "mUSD";
    uint8 public decimals = 18;

    uint256 public totalSupply;
    address public engine;

    mapping(address => uint256) public balanceOf;

    modifier onlyEngine() {
        require(msg.sender == engine, "Not engine");
        _;
    }

    constructor() {
        engine = msg.sender;
    }

    function setEngine(address _engine) external {
        require(engine == msg.sender, "Only current engine");
        engine = _engine;
    }

    function mint(address to, uint256 amount) external onlyEngine {
        totalSupply += amount;
        balanceOf[to] += amount;
    }

    function burn(address from, uint256 amount) external onlyEngine {
        require(balanceOf[from] >= amount, "Not enough balance");

        balanceOf[from] -= amount;
        totalSupply -= amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Not enough");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}