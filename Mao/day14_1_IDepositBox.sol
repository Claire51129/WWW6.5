//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
- `getOwner()` — 返回存款箱的当前所有者。
- `transferOwnership()` — 允许将所有权转移给其他人。
- `storeSecret()` — 一个用于将字符串（我们的“秘密”）保存在金库中的函数。
- `getSecret()` — 检索存储的秘密。
- `getBoxType()` — 让我们知道它是哪种类型的存款箱（基础型、高级型等）。
- `getDepositTime()` — 返回存款箱的创建时间。
*/
interface IDepositBox {
    function getOwner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function storeSecret(string calldata secret) external;
    function getSecret() external view returns (string memory);
    function getBoxType() external pure returns (string memory);
    function getDepositTime() external view returns (uint256);
}
