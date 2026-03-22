// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SignThis {
    string public eventName;
    address public organizer;
    uint256 public eventDate;
    uint256 public maxAttendees;
    uint256 public attendeeCount;
    bool public isEventActive;

    mapping(address => bool) public hasAttended;

    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive);

    constructor(string memory _eventName, uint256 _eventDate, uint256 _maxAttendees) {
        eventName = _eventName;
        organizer = msg.sender;
        eventDate = _eventDate;
        maxAttendees = _maxAttendees;
        isEventActive = true;

        emit EventCreated(_eventName, _eventDate, _maxAttendees);
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer");
        _;
    }

    modifier eventActive() {
        require(isEventActive, "Event not active");
        _;
    }

    // 使用签名验证参与者身份
    function checkInWithSignature(
        address attendee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external eventActive {
        require(attendeeCount < maxAttendees, "Event full");
        require(!hasAttended[attendee], "Already checked in");

        // 构造消息哈希
        bytes32 messageHash = keccak256(abi.encodePacked(
            attendee,
            address(this),  // 合约地址
            eventName
        ));

        // 以太坊签名消息哈希
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));

        // 恢复签名者地址
        address signer = ecrecover(ethSignedMessageHash, v, r, s);

        // 验证签名者是组织者
        require(signer == organizer, "Invalid signature");

        // 记录参与
        hasAttended[attendee] = true;
        attendeeCount++;

        emit AttendeeCheckedIn(attendee, block.timestamp);
    }

    // 批量签到 (Gas优化)
    function batchCheckIn(
        address[] calldata attendees,
        uint8[] calldata v,
        bytes32[] calldata r,
        bytes32[] calldata s
    ) external eventActive {
        require(attendees.length == v.length, "Array length mismatch");
        require(attendees.length == r.length, "Array length mismatch");
        require(attendees.length == s.length, "Array length mismatch");
        require(attendeeCount + attendees.length <= maxAttendees, "Would exceed capacity");

        for (uint256 i = 0; i < attendees.length; i++) {
            address attendee = attendees[i];

            if (hasAttended[attendee]) continue;  // 跳过已签到的

            bytes32 messageHash = keccak256(abi.encodePacked(
                attendee,
                address(this),
                eventName
            ));

            bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                messageHash
            ));

            address signer = ecrecover(ethSignedMessageHash, v[i], r[i], s[i]);

            if (signer == organizer) {
                hasAttended[attendee] = true;
                attendeeCount++;
                emit AttendeeCheckedIn(attendee, block.timestamp);
            }
        }
    }

    // 验证签名有效性 (不执行签到)
    function verifySignature(
        address attendee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(
            attendee,
            address(this),
            eventName
        ));

        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));

        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        return signer == organizer;
    }

    // 获取消息哈希 (用于前端签名)：这是一个极佳的辅助工具。前端不需要自己写复杂的 keccak256 逻辑，直接调用合约的这个 view 函数，就能拿到跟合约算法一模一样的哈希值，确保签名时不会出错。
    function getMessageHash(address attendee) external view returns (bytes32) {
        return keccak256(abi.encodePacked(
            attendee,
            address(this),
            eventName
        ));
    }

    // 管理员功能
    function toggleEventStatus() external onlyOrganizer {
        isEventActive = !isEventActive;
        emit EventStatusChanged(isEventActive);
    }

    function getEventInfo() external view returns (
        string memory name,
        uint256 date,
        uint256 maxCapacity,
        uint256 currentCount,
        bool active
    ) {
        return (eventName, eventDate, maxAttendees, attendeeCount, isEventActive);
    }
}

// **签名验证流程**：1. 组织者链下生成参与者签名 → 2. 参与者提交签名到合约 → 3. 合约使用ecrecover验证签名 → 4. 验证通过则允许签到。整个过程无需预先存储白名单！

/** 
这段新代码 `SignThis` 在你之前学习的基础上，更贴近**实际生产环境**的写法。它不仅仅是在验证逻辑上做了优化，还引入了区块链开发中非常重要的 **Gas 优化** 意识。

我们来深入拆解这个合约的核心升级点：

---

### 1. 参数拆解：直接传入 v, r, s
在之前的代码中，你传入的是一整串 `bytes signature`，然后在合约内部用 `assembly`（汇编）去拆分。
在这个新合约中：
```solidity
function checkInWithSignature(address attendee, uint8 v, bytes32 r, bytes32 s)
```
* **变化**：签名在传入函数之前，就已经在前端（如 ethers.js）被拆分好了。
* **好处**：**节省 Gas**。避开了复杂的汇编操作和字节数组的切片处理，直接给 `ecrecover` 喂它需要的参数。

---

### 2. 批量处理：`batchCheckIn`（Gas 优化的精髓）
这是这段代码最亮眼的地方。在以太坊上，发起一次交易的固定成本是 **21,000 Gas**。

* **逻辑**：组织者（或工作人员）可以一次性收集 50 个人的签名，然后只发**一笔交易**就把这 50 个人全部签到。
* **代码技巧**：
    * 使用 `calldata`：`address[] calldata attendees` 告诉 Solidity 直接从交易数据中读取，不复制到内存，极大地节省了 Gas。
    * 容错处理：它使用了 `if (hasAttended[attendee]) continue;`。如果这批名单里有人已经签到过了，程序不会报错回滚，而是优雅地跳过，处理下一个。

---

 */