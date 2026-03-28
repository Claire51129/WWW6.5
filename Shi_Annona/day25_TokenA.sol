// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {
    // 最简单的TokenA合约
    constructor() ERC20("Token A", "TKA") {
        // 给合约部署者100万个代币
        _mint(msg.sender, 1000000 * (10 ** decimals()));
    }
}