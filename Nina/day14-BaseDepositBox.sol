/* **抽象合约** 
什么是抽象合约？
    在代码中，abstract contract 指的是一个不完整的合约。
    它不能被直接部署（你不能在 Remix 里直接 Deploy 它）。
    它的存在是为了被继承。它把通用的逻辑（比如谁是主人、存取时间）先写好，剩下的个性化功能留给子合约去实现。*/


/*这个合约是我们存款箱系统的核心。所有特定类型的存款箱——如基础型、高级型和时间锁型——都建立在这个合约之上。
这是我们共享的基础。它会实现接口中定义的大部分逻辑，如秘密存储、所有权和存入时间。*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-IDepositBox.sol"; 
// 我们正在导入一个名为 `IDepositBox` 的接口。可以将接口视为一个**仅包含函数声明而没有实际实现的合约**。当我们导入并继承这个接口时，就是在说：“我承诺实现 IDepositBox 中声明的所有函数——即使不是所有函数都在这里实现。” 这样做的好处是，每个存款箱都必须按照同样的标准来实现功能，就像大家都在用同一本说明书，这样结构就不会乱。

abstract contract BaseDepositBox is IDepositBox { //关键字 `abstract` 表示这个合约**不能直接部署**。它是充当其他合约构建的**模板**或**地基**。为什么它是抽象的？因为它没有把接口里规定的所有功能都写完整。例如，它**没有定义** `getBoxType()` 函数——每个后面的子合约会有自己的版本（如“基础型”、“高级型”等）。所以这个基础合约只处理**通用逻辑**，剩下的细节由每个具体的金库自己补充。
    address private owner; // 存储拥有此存款箱人员的地址。只有此人被允许存储或检索秘密。
    string private secret; // 用户可以安全地存储在该存款箱中的私有字符串。
    uint256 private depositTime; // 记录存款箱部署的准确时间（Unix 时间戳）。这对于基于时间的逻辑（例如，锁定）很有用。
    // 这些变量都是 private，表示它们只能在内部访问。如果有人想读取它们，必须通过我们提供的公共getter 函数来查。

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner);
    /*事件有助于记录重要的链上活动。这些对于前端和像 Etherscan 或 TheGraph 等工具有用。
        - `OwnershipTransferred`：当有人转移存款箱的所有权时触发。
        - `SecretStored`：当存储新秘密时触发。
    关键词 `indexed` 在查询链上数据时，可以更轻松地按这些字段过滤日志。*/

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the box owner");
        _;
    }
    /*此修饰符限制对某些函数的访问。如果一个函数标记为 `onlyOwner`，那么只有当前所有者可以运行它。
    否则，函数调用会回滚，并显示消息 `"Not the box owner"`。
    我们在每个重要函数中使用这个修饰符——比如存储机密或转移所有权。*/

    constructor() {
        owner = msg.sender;
        depositTime = block.timestamp;
    }
    /*该函数只运行一次——在金库部署时。
        - `msg.sender`：部署合约的人成为 `owner`。
        - `block.timestamp`：当前时间（自 Unix 纪元以来的秒数）被记录为存入时间。
    所以，该金库在创建时自动设置所有权和时间跟踪。*/

    function getOwner() public view override returns (address) {
        return owner;
    }
    /* 注意这里的override——接口中的函数隐式地就是 virtual，而实现它的合约必须显式使用 override。
    接口不需要写virtual，接口里的函数默认就是 virtual：编译器规定接口不能有任何实现（没有 { }），这意味着它存在的唯一目的就是等着别人去重写（override）它。为了简洁，Solidity 强制省略了接口中的 virtual 关键字。
    抽象合同继承接口时，必须写override：你在抽象合约里写了逻辑，你就是在覆盖（实现）接口的空白定义，所以必须标记 override。 */

    function transferOwnership(address newOwner) external virtual override onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    /* 注意这里的virtual意味着允许子合约修改这个逻辑。 */

    function storeSecret(string calldata _secret) external virtual override onlyOwner {
        secret = _secret;
        emit SecretStored(msg.sender);
    }

    function getSecret() public view virtual override onlyOwner returns (string memory) {
        return secret;
    }

    function getDepositTime() external view virtual override returns (uint256) {
        return depositTime;
    }
}
