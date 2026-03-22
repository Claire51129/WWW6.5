/* **接口**
一种只包含函数定义的合约——没有逻辑，没有存储，也没有状态变量；用来强制执行规则。

1. 什么是接口？
    接口定义了合约应该“长什么样”，但不规定“怎么实现”。它只列出函数的名称、参数和返回值。可以把“接口”（Interfaces）理解为一份“技术合同”或“标准协议”。

    接口的铁律：
        - 不能包含状态变量（比如 uint public x 是不允许的）。
        - 不能定义构造函数（constructor）。
        - 所有函数必须是 external 类型。
        - 不能实现函数体（函数后面直接跟分号 ;，没有大括号 {...}）。

2. 接口的语法
    我们用关键字 interface 来定义。通常约定以大写字母 I 开头。

3. 为什么要用接口？
    对于零基础的新手，你可能会问：“我直接写合约不就行了，为什么要多此一举写个接口？” 核心原因有两个：
        A. 跨合约调用（最常用）
            如果你想在你的合约 A 里调用别人已经部署好的合约 B（比如你想在你的项目里集成 Uniswap 的代币交换功能），你不需要复制对方几千行的代码。你只需要把对方的接口复制过来，就能像调用本地函数一样调用它。
        B. 统一标准
            接口可以帮助我们定义标准，比如 ERC-20、ERC-721。比如著名的 ERC-20 代币标准。为什么所有的钱包（MetaMask 等）都能显示各种不同的代币？因为这些代币合约都实现了同一个接口。
                你现在可以去看看 ERC-20 Interface 的定义，你会发现全世界数以万计的代币（如 USDT, SHIB）其实都在遵守那几行简单的函数定义。

4. 接口（Interface）与合约（Contract）的区别
    <逻辑> 合约：包含具体的代码逻辑。接口：只定义函数签名，无逻辑
    <变量> 合约：可以存数据（状态变量）。接口：不能存数据。
    <部署> 合约：可以直接部署到链上。接口：无法单独部署。
    <目的> 合约：具体的业务执行。接口：定义标准、方便外部调用。
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDepositBox {
    function getOwner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function storeSecret(string calldata secret) external;
    function getSecret() external view returns (string memory);
    function getBoxType() external pure returns (string memory);
    function getDepositTime() external view returns (uint256);
}


/* 这里我们将定义一个所需函数的简单规则手册，每个金库都必须遵守此规则。
这是我们的**接口**——合约蓝图。
我们基本上是在说：“嘿，任何想要成为我们系统一部分的金库（或存款箱）**必须**实现这些函数。”
让我们看看每个函数代表什么：
- `getOwner()` — 返回存款箱的当前所有者。
- `transferOwnership()` — 允许将所有权转移给其他人。
- `storeSecret()` — 一个用于将字符串（我们的“秘密”）保存在金库中的函数。
- `getSecret()` — 检索存储的秘密。
- `getBoxType()` — 让我们知道它是哪种类型的存款箱（基础型、高级型等）。
- `getDepositTime()` — 返回存款箱的创建时间。
这些就像游戏规则一样——每种类型的存款箱都会遵循这些规则，即使它们的实施方式不同。
*/



/* **calldata**

在 Solidity 中，calldata 是一个非常关键的概念，尤其是当你处理字符串（string）、字节（bytes）、**结构体（struct）或数组（array）**这些复杂数据类型时。
简单来说，calldata 是一个只读的、临时的、便宜的存储区域。

对比calldata vs memory：
    memory是会把比如说字符串复制到内存里，在内存里修改；只是内存的存储是临时的，函数结束就消失。
    calldata也是仅存在于函数调用期间；但它是只读不写的，直接读取原始数据，不复制也不能修改。

calldata 的使用规则：
    1. 外部调用专用：在 external 函数中，如果参数是数组或字符串，优先使用 calldata。
    2. 只读属性：如果你尝试在函数内部修改 calldata 类型的变量，代码编译会报错。
    3. 传递性：你可以把 calldata 数据作为参数再传递给其他函数，但接收方函数也必须声明该参数为 calldata。
*/


