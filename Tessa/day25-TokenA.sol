// 造出一个测试代币A
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 借工具箱：导入了 OpenZeppelin 的 ERC20 合约。OpenZeppelin 的 ERC20 实现提供了标准代币能力，比如余额查询、转账、授权、以及子合约可用的 _mint 等内部函数。
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {    //TokenA 继承了 ERC20 的本领。
    constructor() ERC20("Token A", "TKA") {   //告诉 ERC20 爸爸：这个代币全名叫 Token A，简称叫 TKA
        _mint(msg.sender, 1000000 * 10 ** decimals()); //铸造 100 万代币给你
    }    //部署这个合约的人，一上来就拿到 100 万个 Token A
}


// _mint(...):凭空创建新的代币; OpenZeppelin 的 ERC20 把 _mint 作为内部函数提供给继承它的合约使用。
// 一句话总结：造一个名字叫 Token A、简称 TKA 的标准 ERC20 代币，并在部署时给部署者 100 万个。（该份代码的作用）
// Q: 为什么要乘 10 ** decimals() ？ A: 因为 ERC20 代币通常不是直接用“1、2、3”这种整数来记，而是像人民币的“元和分”那样，有更细的最小单位。OpenZeppelin 的 ERC20 默认 decimals() 是 18。

