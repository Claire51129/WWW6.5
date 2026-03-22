/*带附加功能的金库
现在我们给存款箱**一些额外的东西**：一个叫做 `metadata` 的数据片段。
可以将其视为一个个性化的标签、标记或信息字段，所有者可以设置它。它可以描述秘密的内容、应该在何时访问，或者任何你想要附加的注释。*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox {
    string private metadata; // 我们引入了一个新的状态变量，称为 `metadata`。它被标记为 `private`，这意味着只有**此合约内**的函数可以读取或修改它。（我们将为所有者创建外部访问函数。）

    event MetadataUpdated(address indexed owner); // 当有人更新元数据时发出事件

    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }

    function setMetadata(string calldata _metadata) external onlyOwner { // 只有所有者可以更新元数据
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }

    function getMetadata() external view onlyOwner returns (string memory) { // 只有所有者可以读取元数据
        return metadata;
    }
}



/* Q：getMetadata的mutability是view（只读），用memory是因为字符串需要特殊处理，需要复制到内存才能读取。那setMetadata修改了metadata（non-payable，写入），为什么用calldata（临时的只读存储）？

A：你已经触及了 Solidity 中 数据流向（Data Flow） 的核心。
要理解这个区别，我们不能只看函数是 view 还是修改状态，而要看数据**“从哪来”以及“去哪儿”**。

1. setMetadata: 数据“进入”合约
在这个函数里，数据是从合约外部（你的钱包或前端）传进来的。
    来源：交易的 input data（这就是 calldata 存放的地方）。
    目的地：状态变量 metadata（这就是 storage）。
    过程：calldata -> storage。
为什么用 calldata？ 既然数据已经在交易包里了，我们直接把它“读”出来存进 storage 就行。不需要在中途开辟一块 memory 空间来临时存放。这就像是把快递直接从车上（calldata）搬进仓库（storage），不需要先卸在门口空地上（memory）。

2. getMetadata: 数据“离开”合约
在这个函数里，数据是从合约内部取出来交给外部。
    来源：状态变量 metadata（storage）。
    目的地：外部调用者。
    过程：storage -> memory -> return。
为什么用 memory？
Solidity 的规定是：所有从函数返回的动态类型（如字符串、数组），必须先存放在内存（memory）中。 calldata 是只读且不可修改的，它是专供“函数入参”使用的。由于 getMetadata 不是在接收外部输入，而是在产生输出，所以它无法使用 calldata。它必须把数据从持久化的 storage 拷贝到临时的 memory 缓冲区，才能传回给调用者。

3. 深入一点：为什么 storage 不能直接返回？
你可能会问：既然数据在 storage 里，为什么不能直接从 storage 返回给用户，非要过一遍 memory？
这是因为 EVM（以太坊虚拟机）的架构限制：
    Storage 是在硬盘上的（昂贵、持久）。
    Memory 是在内存里的（便宜、短暂）。
返回值机制：Solidity 设计上要求函数返回动态数据时，必须是在内存中准备好的。这保证了返回的数据是独立的，不会因为后续对 storage 的修改而产生混乱。

## 总结你的疑惑
setMetadata 用 calldata：是因为它是入参，我们想省去复制到内存的费用。
getMetadata 用 memory：是因为它是返回值，Solidity 强制要求动态类型的返回值必须存放在 memory。*/

