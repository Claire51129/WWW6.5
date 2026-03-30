// 造出一个测试代币B
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenB is ERC20 {
    constructor() ERC20("Token B", "TKB") {
        _mint(msg.sender, 1000000 * 10 ** decimals());   //给部署这100个TKB；乘上18位精度
    }
}

// 同tokenA文件一模一样
// 一句话总结：造一个名字叫 Token B、简称 TKB 的标准 ERC20 代币，并在部署时给部署者 100 万个。（该份代码的作用）
