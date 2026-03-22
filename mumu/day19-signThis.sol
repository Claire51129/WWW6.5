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

    // 获取消息哈希 (用于前端签名)
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

/**
学习：
1. 如何对结构化的数据进行哈希处理（abi.encodePacked(arg);
2. 为什么以太坊使用签名消息前缀
3. ecrecover() 如何让你在链上验证，链下批准

使用数字签名的好处：
    权限验证控制机制：无需再维护繁重的用户身份管理系统，构建一个去中心化、安全高效的活动管理系统
    零gas注册费用、无限扩展性、隐私保护

设计思路：
1）组织者在链下位合法参与者生成数字签名
2）参与者提交签名到区块链合约进行验证
3）只能合约通过ecrecover函数回复签名者地址，确认其身份的有效性

获取签名的脚本：
// sign.js 脚本逻辑
async function main() {
    // 1. 粘贴你从合约 getMessageHash 函数中复制出来的哈希值
    const messageHash = "0xc03xxxxx"; 

    // 2. 获取当前连接的账户（即组织者/部署者地址）
    // const accounts = await web3.eth.getAccounts();
    // const organizer = accounts;

    // console.log("正在使用组织者地址进行签名:", organizer);
    organizer = "0x5B38Da6a701c5xxxxx"

    // 3. 对消息哈希进行签名
    // 注意：以太坊签名会自动添加前缀 "\x19Ethereum Signed Message:\n32" [2]
    const signature = await web3.eth.sign(messageHash, organizer);

    console.log("生成的完整签名 (65字节):", signature);
}

main();

我们可以将其手动拆分为 r、s、v 三个部分：
r (32 字节)：签名 0x 之后的前 64 个十六进制字符
s (32 字节)：接下来的 64 个十六进制字符
v (1 字节)：最后的 2 个十六进制字符
 */