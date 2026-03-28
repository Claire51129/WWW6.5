/* 代理合约 */
 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17-SubscriptionStorageLayout.sol";

contract SubscriptionStorage is SubscriptionStorageLayout { // 定义代理合约，继承自存储合约。用户与之交互，实际工作委托给逻辑合约。
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;
    }

    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
    }
    // 在不触及用户数据或要求人们重新部署的情况下修复错误、添加功能或重构代码

    fallback() external payable { // 当用户调用的函数名在合约里找不到时，系统就会自动执行它。
        address impl = logicContract;
        require(impl != address(0), "Logic contract not set");
        // 确保已设置逻辑合约，将其存储在 impl 中

        assembly { // 这里使用的是 Yul 语言，它能绕过 Solidity 的高级语法，直接对内存进行底层操作。
            calldatacopy(0, 0, calldatasize()) // 将输入数据（函数名 + 参数）复制到内存槽 0
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0) // delegatecall 调用 impl 合约，运行所输入的参数，上下文（状态变量、余额、msg.sender）保持在当前合约。返回 result：1 表示成功，0 表示失败。
            returndatacopy(0, 0, returndatasize()) // 将逻辑合约执行返回的任何内容复制到内存中——可能是返回值或错误消息

            switch result
            case 0 { revert(0, returndatasize()) } // 如果是0，我们回退（revert）并返回错误
            default { return(0, returndatasize()) } // 如果是1，我们将结果返回给原始调用者
        }
        /** 为什么用汇编（Assembly），而不是 用普通的 Solidity 写？
            通用性：这段代码不需要知道逻辑合约里具体有哪些函数。无论逻辑合约以后怎么改，这段代理逻辑永远不需要变。
            返回值处理：Solidity 原生语法很难在不知道函数返回类型的情况下，动态地转发任何长度的返回数据。汇编可以完美实现“透传”。
        
            这段汇编代码（Assembly/Yul）之所以让新手头疼，是因为它直接操作了内存（Memory）和调用栈。
            我们要理解这些 0，必须先记住一个前提：在 EVM 汇编中，操作数据通常需要两个参数：“从哪开始（offset）” 和 “多长（size）”。

            1. calldatacopy(0, 0, calldatasize())
            这一行的目的是：把用户发来的“请求数据”完整地复制到内存里。
                第一个 0 (destOffset): 目标内存的起始位置。意为“把数据从内存的第 0 字节开始写入”。
                第二个 0 (offset): Call Data（输入数据）的起始偏移量。意为“从用户发来的数据第 0 字节开始读取”。
                calldatasize(): 数据的总长度。
            合起来说：把用户发来的全部请求内容，原封不动地搬到内存的 0 号位 坐好。

            2. let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            这是最核心的一步，它有 6 个参数：delegatecall(g, a, in, insize, out, outsize)。
                gas(): 给这次调用分配多少 Gas（通常是全部剩余 Gas）。
                impl: 逻辑合约的地址。
                0 (in): 输入数据在内存里的起始位置。刚才我们把数据存在了 0，所以这里填 0。
                calldatasize() (insize): 输入数据的长度。
                接下来的 0 (out): 输出数据存到内存的哪里。
                最后一个 0 (outsize): 预留多大的空间给输出数据。
                    重点来了！ 为什么最后两个是 0？因为在执行前，我们不知道逻辑合约会返回多长的数据。所以我们先填 0，等执行完了，再用下面的 returndatacopy 动态抓取。

            3. returndatacopy(0, 0, returndatasize())
            调用完逻辑合约后，它会把结果吐出来。
                第一个 0: 目标内存起始位置。我们要把逻辑合约返回的结果，覆盖掉刚才内存里的旧数据，从 0 号位开始存。
                第二个 0: 返回数据（Return Data）的起始位置。从结果的第 0 字节开始复制。
                returndatasize(): 动态获取逻辑合约实际返回的数据长度。
            合起来说：不管逻辑合约返回了什么，通通抓回来，放在内存 0 号位。

            4. revert(0, returndatasize()) 和 return(0, returndatasize())
            这两行是最后的结果反馈，结构是一样的：
                0: 数据在内存里的起始位置。因为刚才 returndatacopy 把结果存在了 0，所以这里取的时候也从 0 开始。
                returndatasize(): 要返回的数据长度。
            区别：
                revert：告诉用户“出错了”，并把内存里存的错误信息吐给用户。
                return：告诉用户“成功了”，并把内存里的执行结果吐给用户。 
         */
    }

    receive() external payable {} // 一个安全网，允许代理接受原始 ETH 转账。在这里你可能不需要它，但当合约直接接收 ETH 时（例如，在支付期间）通常很有用。
}

