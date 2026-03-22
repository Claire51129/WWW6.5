/** **可升级合约**——将**存储**与**逻辑**分离
-你部署一个存储**数据**的合约——我们称之为**代理（proxy）**。
-你部署另一个包含**逻辑**的合约——这是实际的代码。
-代理使用 `delegatecall` 来执行外部合约的逻辑——但使用的是**它自己的存储**。
所以，如果你需要改变行为，你不必动代理——你只需将它指向一个新的逻辑合约。所有数据都保持安全。

让我们通过构建一个模块化订阅管理器（你可以在 SaaS 应用或 dApp 中使用的那种）来将这个想法变为现实。
 */

 
/** **共享内存蓝图**
这是一个独立的合约，**只保存状态变量**——它不包含任何函数（除了后面继承的逻辑）。
这个布局合约就像一个**蓝图**，定义了代理和逻辑合约的**内存结构**。
通过导入和继承这个布局，两个合约可以**共享和操作相同的数据**，前提是它们的内存布局顺序相同——这对于 `delegatecall` 的正确工作至关重要。
 */ 

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionStorageLayout {
    address public logicContract; // 存储逻辑合约地址，代理合约可调用，该存储可更新
    address public owner;

    struct Subscription {
        uint8 planId; // 用户套餐的标识符。一个小的数字，如 1, 2, 或 3，代表不同的层级（例如，基础版、专业版、高级版）。
        uint256 expiry; // 时间戳，指示订阅何时到期
        bool paused;
    }

    mapping(address => Subscription) public subscriptions; // 跟踪每个用户的套餐状态
    mapping(uint8 => uint256) public planPrices; // 每种套餐的价格和时长
    mapping(uint8 => uint256) public planDuration;
}

/** 这个蓝图合约实际上并不需要部署，编译器通过import的位置抓取本合约代码进其他文件。
    代理合约和逻辑合约 在编译环节 通过import和继承代码 已经将本合约的逻辑抓取过去 形成字节码了。
    如果想让其他开发者能看到完整源代码，需要主动公开本文件。
 */

/** #问题 在storagelayout合约里声明了paused变量，logicV2合约里实现暂停或恢复订阅，好像是最初已经设想到这个功能了，只是没有去实现它。感觉现实情况会不会更可能是最初没有想到过暂停这回事，可能就没有声明过paused，后面想升级时发现需要一个这个东西。但是storagelayout合约是不是已经不能修改了？毕竟代理也继承了它并且部署了...这种情况还可以实现升级吗？
 */