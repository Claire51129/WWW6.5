/* ## **你的金库仪表板**

这个合约充当**控制中心**，供用户创建、命名、管理和与他们的存款箱交互。

可以将其视为你的**金库应用后端**：

- 它允许用户创建不同类型的存款箱（基础型、高级型、时间锁型）。
- 它跟踪哪个用户拥有哪个存款箱。
- 它强制执行所有权规则。
- 它提供命名和检索存款箱信息的辅助函数。*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-IDepositBox.sol";
import "./day14-BasicDepositBox.sol";
import "./day14-PremiumDepositBox.sol";
import "./day14-TimeLockedDepositBox.sol";

contract VaultManager {
    mapping(address => address[]) private userDepositBoxes; // 将用户的地址映射到其拥有的所有存款箱（作为合约地址）
    mapping(address => string) private boxNames; // 允许用户为每个邮箱分配自定义名称，按邮箱地址存储。

    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType); // 每次用户创建新存款箱时触发
    event BoxNamed(address indexed boxAddress, string name); // 当用户给他们的存款箱自定义名称时触发

    function createBasicBox() external returns (address) { // 创建基础存款箱
        BasicDepositBox box = new BasicDepositBox(); // 部署一个新的 BasicDepositBox 合约并将其地址存储在变量 box 中
        userDepositBoxes[msg.sender].push(address(box)); // 将新存款箱添加到发送者拥有的存款箱列表中
        emit BoxCreated(msg.sender, address(box), "Basic"); // 触发一个事件，以便 UI 可以跟踪此创建
        return address(box); // 返回新存款箱的地址以便于访问
    }

    function createPremiumBox() external returns (address) { // 创建存储额外元数据的存款箱
        PremiumDepositBox box = new PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    function createTimeLockedBox(uint256 lockDuration) external returns (address) { // 创建未来定时开启的存款箱
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }

    function nameBox(address boxAddress, string calldata name) external {
        IDepositBox box = IDepositBox(boxAddress); // 首先，我们将通用地址转换为接口。这让我们可以在存款箱上调用 getOwner()，而无需知道它是什么类型。
        require(box.getOwner() == msg.sender, "Not the box owner"); // 检查所有权，只有合法的所有者可以重命名存款箱
        boxNames[boxAddress] = name; // 保存新名称
        emit BoxNamed(boxAddress, name); // 触发事件
    }

    function storeSecret(address boxAddress, string calldata secret) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        box.storeSecret(secret); // “命令 box 这个特定的合约，去运行它内部名为 storeSecret 的程序，并把 secret 这段数据喂给它。”
    }

    function transferBoxOwnership(address boxAddress, address newOwner) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        box.transferOwnership(newOwner);

        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; i < boxes.length; i++) {
            if (boxes[i] == boxAddress) {
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        } // 从发送者列表中移除存储箱（获取发送者的存储箱列表 > 循环查找正在被转移的那个 > 一旦找到，将它与数组中的最后一项交换，然后调用 .pop() 来删除最后一项。 

        userDepositBoxes[newOwner].push(boxAddress); // 将存储箱添加到新所有者的列表
    }

    function getUserBoxes(address user) external view returns (address[] memory) {
        return userDepositBoxes[user];
    }

    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    function getBoxInfo(address boxAddress) external view returns (
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ) {
        IDepositBox box = IDepositBox(boxAddress);
        return (
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxNames[boxAddress]
        );
    }
}


/*
这段代码是 Solidity 进阶设计的核心：工厂模式（Factory Pattern） 与 接口的实际应用。
如果说之前的 BasicDepositBox 是单个的“产品”，那么这个 VaultManager 就是一个**“自动化工厂”**。它负责生产、记录并管理所有的保险箱。

1. 核心概念：工厂模式
在这段代码中，最亮眼的是关键字 new。
BasicDepositBox box = new BasicDepositBox();
这是什么意思？ 当你在 VaultManager 里调用这个函数时，它会在以太坊网络上**创建一个全新的合约**。
地址管理：新合约创建后会有一个独立的地址。VaultManager 用一个 mapping（映射）把这个地址存起来，挂在你的名下。

2. 接口（Interface）在这里的神奇功用
你注意到了吗？虽然我们要管理三种不同的保险箱（Basic, Premium, TimeLocked），但在很多函数里（如 nameBox, storeSecret），我们并没有写三份逻辑，而是统一用了：
IDepositBox box = IDepositBox(boxAddress);
为什么可以这样？
    不论是哪种保险箱，它们都遵循 IDepositBox 接口。
    VaultManager 不需要知道这个地址到底是一个 PremiumBox 还是 BasicBox。
    它只需要把地址包装成接口，就能调用 getOwner() 或 storeSecret()。这就叫**“多态”**——用统一的界面处理不同的底层实现。
*/


/*
框架设计原因——为什么：抽象合约继承接口，basic/premium/timelockedbox继承抽象合约，而vaultmanager导入接口和basic/premium/timelockedbox

1. 框架层级：谁在扮演什么角色？
    接口（行业标准） > 抽象合约（公用底盘/半成品） > 具体合约（最终产品） > 管理（批量生产的工厂）

2. 为什么抽象合约继承接口？
    （1）强制约束力：确保“法律”被落地
        接口（Interface）只是一张清单，它不具备任何执行力。
        逻辑：继承确保了后续所有基于 BaseDepositBox 开发的箱子，都百分之百符合 IDepositBox 的标准。
    （2）减少子合约的负担（代码复用）
        如果抽象合约不继承接口，那么每一个子合约（如 BasicBox, PremiumBox）都得自己去声明继承接口，并重复写那些通用的逻辑。
        现在的做法： 抽象合约把“脏活累活”（比如 owner 的存取、权限校验 onlyOwner）全干了，并打上 is IDepositBox 的标签。
        结果： 具体的子合约只需要继承抽象合约，就自动获得了“合规身份”。它只需要关注自己那 10% 的个性化功能即可。
    （3）多态管理（这是最重要的！）
        还记得你的 VaultManager 吗？里面有一行 IDepositBox box = IDepositBox(boxAddress);。
        如果 BaseDepositBox 没有继承接口，那么当你试图把一个 BasicBox 的地址转换成 IDepositBox 时，编译器可能会感到困惑，或者在调用时发生未知错误。
        因为继承了接口： 编译器在底层建立了一套“血缘关系”。它知道 BasicBox 属于 BaseBox，而 BaseBox 又属于 IDepositBox。
        效果： 这样 VaultManager 就可以用一套统一的代码，去管理所有不同类型的保险箱。
    小结：向上对接标准，向下提供实现。

3. 为什么具体合约继承抽象合约？ (垂直继承)
    逻辑：代码复用。
        如果不继承 BaseDepositBox，你每写一个新类型的保险箱，都要重新写一遍 owner 的逻辑、重新写一遍 transferOwnership。
    好处：保证了所有类型的保险箱“骨架”是一致的。如果你以后想给所有保险箱加一个“紧急报警”功能，你只需要改 BaseDepositBox 一个地方，所有的子合约都会自动获得这个功能。

4. 为什么 VaultManager 导入这么多文件？ (水平集成)
    这是最容易让新手困惑的地方：既然有了接口，为什么还要导入具体的 BasicBox 呢？
    
    A. 导入具体合约（Basic/Premium...）是为了“生产”
    在 createBasicBox 函数里，有一句 new BasicDepositBox()。
        逻辑：你要生产一个产品，你手里必须有这个产品的详细蓝图（即具体合约的完整代码）。
        原因：VaultManager 扮演的是“工厂”角色。如果不导入具体合约，它就不知道如何初始化这些复杂的对象。
    
    B. 导入接口（IDepositBox）是为了“管理”
    在 nameBox 或 storeSecret 函数里，你看到它用了 IDepositBox(boxAddress)。
        逻辑：4S 店老板（Manager）不需要知道这辆车引擎的每一个螺丝是怎么拧的（具体实现），他只需要知道这辆车符合“汽车标准”（接口），他就能按喇叭、开车门。
        好处：这叫面向接口编程。这样 VaultManager 的管理逻辑（比如查所有者）对所有类型的保险箱都是通用的，不需要为每种箱子写一遍管理代码。

5. 深度逻辑：为什么要“套这么多层”？
    如果你把所有代码写在一个合约里，会发生什么？
        Gas Limit 限制：以太坊合约有大小限制（24KB）。全写在一起，合约会因为太胖而无法部署。
        灵活性极差：如果你想增加一种“指纹识别保险箱”，你得把整个系统重写一遍。
    现在的框架下：
        你想加新箱子？新建一个 .sol 继承 Base 即可，Manager 只需要多加一个 create 函数。
        这种架构叫**“高内聚，低耦合”**：
            内聚：保险箱自己管自己的秘密。
            解耦：管理合约只管地址和名字，不干涉保险箱内部逻辑。
*/
