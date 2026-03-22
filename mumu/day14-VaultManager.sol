// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-IDepositBox.sol";
import "./day14-BasicDepositBox.sol";
import "./day14-PremiumDepositBox.sol";
import "./day14-TimeLockedDepositBox.sol";

contract VaultManager {
    // 用户创建了哪些boxs   
    mapping(address => address[]) private userDepositBoxes;
    mapping(address => string) private boxNames;

    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    event BoxNamed(address indexed boxAddress, string name);

    // 创建basic box
    function createBasicBox() external returns (address) {
        // BasicDepositBox box = new BasicDepositBox(msg.sender);
        BasicDepositBox box = new BasicDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");

        // 立刻转移box的所有权从当前合约转移 给 msg.sender
        transferBoxOwnershipInternal(address(box), msg.sender);

        return address(box);
    }

    // 创建 premium box
    function createPremiumBox() external returns (address) {
        // PremiumDepositBox box = new PremiumDepositBox(msg.sender);
        PremiumDepositBox box = new PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");

        // 立刻转移box的所有权从当前合约转移 给 msg.sender
        transferBoxOwnershipInternal(address(box), msg.sender);

        return address(box);
    }

    // 创建 timelocked box
    function createTimeLockedBox(uint256 _lockDuration) external returns (address) {
        // TimeLockedDepositBox box = new TimeLockedDepositBox(msg.sender,_lockDuration);
        TimeLockedDepositBox box = new TimeLockedDepositBox(_lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");

        // 立刻转移box的所有权从当前合约转移 给 msg.sender
        transferBoxOwnershipInternal(address(box), msg.sender);

        return address(box);
    }

    // 为储蓄箱命名
    function nameBox(address _boxAddress, string calldata _name) external {
        IDepositBox box = IDepositBox(_boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        boxNames[_boxAddress] = _name;
        emit BoxNamed(_boxAddress, _name);
    }

    // 存储密钥
    function storeSecret(address _boxAddress, string calldata _secret) external {
        IDepositBox box = IDepositBox(_boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.storeSecret(_secret);
    }

    // 转移储蓄箱internal
    function transferBoxOwnershipInternal(address _boxAddress,address _newOwner) internal{
        IDepositBox box = IDepositBox(_boxAddress);
        require(box.getOwner() == address(this), "Not the contract call");

        box.transferOwnership(_newOwner);

        address[] storage boxes = userDepositBoxes[address(this)];
        for (uint i=0;i<boxes.length;i++){
            if (boxes[i] == _boxAddress){
                // 用最后一个元素覆盖当前元素，并将最后一个元素出队
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        }

        userDepositBoxes[_newOwner].push(_boxAddress);
    }

    // 转移储蓄箱
    function transferBoxOwnership(address _boxAddress, address _newOwner) external {
        IDepositBox box = IDepositBox(_boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.transferOwnership(_newOwner);

        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; i < boxes.length; i++) {
            if (boxes[i] == _boxAddress) {
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        }

        userDepositBoxes[_newOwner].push(_boxAddress);
    }

    // 获取用户名下的储蓄箱
    function getUserBoxes(address _user) external view returns (address[] memory) {
        return userDepositBoxes[_user];
    }

    // 获取储蓄箱名称
    function getBoxName(address _boxAddress) external view returns (string memory) {
        return boxNames[_boxAddress];
    }

    //   获取储蓄箱名称
    function getBoxInfo(address _boxAddress) external view returns (
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ) {
        IDepositBox box = IDepositBox(_boxAddress);
        return (
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxNames[_boxAddress]
        );
    }
}


/**
注意：
// 创建basic box
    function createBasicBox() external returns (address) {
        BasicDepositBox box = new BasicDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }
此时合约 BasicDepositBox 中的 msg.sender 是当前合约 的地址，而不是部署交易的外部账户（EOA），也不是合约 BasicDepositBox 自己的地址。

这是一个很好的问题，涉及到 Solidity 中 `new` 关键字创建合约时 `msg.sender` 的上下文问题。

## 简短回答

合约 B 中的 `msg.sender` **是合约 A 的地址**，而不是部署交易的外部账户（EOA），也不是合约 B 自己的地址。

## 详细解释

当你使用 `new` 关键字创建合约时：
- `msg.sender` 指的是**创建这个新合约的合约（即合约 A）**的地址
- 整个创建过程发生在合约 A 的执行上下文中

### 代码示例说明

```solidity
// 合约B
contract BasicDepositBox {
    address public owner;
    uint public depositTime;
    
    constructor() {
        owner = msg.sender;        // 这个msg.sender是谁？
        depositTime = block.timestamp;
    }
}

// 合约A
contract Factory {
    BasicDepositBox public box;
    
    function createBox() external {
        // 假设用户0x123调用这个函数
        box = new BasicDepositBox();  
        // 此时，BasicDepositBox中的msg.sender = 合约A的地址
        // 而不是0x123
    }
}
```

### 调用链分析

```
外部账户 (0x123) 
    ↓
调用合约A的 createBox() 函数
    ↓
合约A执行 new BasicDepositBox()
    ↓
在创建 BasicDepositBox 时，msg.sender = 合约A的地址
    ↓
BasicDepositBox 构造函数中的 owner = 合约A的地址
```

## 如何获取原始调用者？

如果你想让合约 B 记录实际部署者的地址（外部账户），有几种方式：

### 方式1：通过构造函数参数传递
```solidity
// 合约B
contract BasicDepositBox {
    address public owner;
    uint public depositTime;
    
    constructor(address _owner) {
        owner = _owner;            // 接收传入的实际部署者
        depositTime = block.timestamp;
    }
}

// 合约A
contract Factory {
    BasicDepositBox public box;
    
    function createBox() external {
        // 将实际调用者(msg.sender)作为参数传入
        box = new BasicDepositBox(msg.sender);
    }
}
```

### 方式2：使用 tx.origin（不推荐）
```solidity
// 合约B
contract BasicDepositBox {
    address public owner;
    uint public depositTime;
    
    constructor() {
        owner = tx.origin;          // tx.origin 永远是外部账户
        depositTime = block.timestamp;
    }
}
```

**注意**：使用 `tx.origin` 通常不推荐，因为它存在安全风险（钓鱼攻击）。

## 关键概念总结

| 场景 | msg.sender | tx.origin |
|------|------------|-----------|
| 外部账户直接创建合约B | 外部账户 | 外部账户 |
| 合约A创建合约B | **合约A的地址** | 最初的外部账户 |
| 合约A调用合约B的函数 | **合约A的地址** | 最初的外部账户 |

所以，在合约 A 中通过 `new BasicDepositBox()` 创建合约 B 时，合约 B 构造函数中的 `msg.sender` 是**合约 A 的地址**。
 */