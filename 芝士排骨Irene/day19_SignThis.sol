// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 签名验证签到合约 - 组织者在链下用私钥对参与者身份进行签名，参与者拿着签名到链上验证签到
contract SignThis {
    // 状态变量
    string public eventName;        // 活动名称
    address public organizer;       // 组织者地址（拥有签名权限的人）
    uint256 public eventDate;       // 活动日期（时间戳）
    uint256 public maxAttendees;    // 最大参与人数
    uint256 public attendeeCount;   // 当前已签到人数
    bool public isEventActive;      // 活动是否进行中

    // 地址 => 是否已签到（防止重复签到）
    mapping(address => bool) public hasAttended;

    // 事件
    event EventCreated(string name, uint256 date, uint256 maxAttendees);    // 活动创建
    event AttendeeCheckedIn(address attendee, uint256 timestamp);            // 参与者签到
    event EventStatusChanged(bool isActive);                                 // 活动状态变更

    // 构造函数 - 创建活动，设定名称、日期、人数上限
    constructor(string memory _eventName, uint256 _eventDate, uint256 _maxAttendees) {
        eventName = _eventName;
        organizer = msg.sender;          // 部署者就是组织者
        eventDate = _eventDate;
        maxAttendees = _maxAttendees;
        isEventActive = true;            // 默认激活

        emit EventCreated(_eventName, _eventDate, _maxAttendees);
    }

    // 仅组织者可调用
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer");
        _;
    }

    // 活动必须进行中
    modifier eventActive() {
        require(isEventActive, "Event not active");
        _;
    }

    // 使用签名验证参与者身份并签到 - 整个合约的核心函数
    function checkInWithSignature(
        address attendee,
        uint8 v,        // 签名恢复标识符（27 或 28）
        bytes32 r,      // 签名的前 32 字节
        bytes32 s       // 签名的后 32 字节
    ) external eventActive {
        require(attendeeCount < maxAttendees, "Event full");       // 人数未满
        require(!hasAttended[attendee], "Already checked in");     // 未重复签到

        // 第一步：构造原始消息哈希
        // 把参与者地址 + 合约地址 + 活动名称打包后哈希
        // 加入合约地址是为了防止签名被拿到另一个合约里冒用
        bytes32 messageHash = keccak256(abi.encodePacked(
            attendee,
            address(this),  // 合约地址，防止跨合约重放
            eventName
        ));

        // 第二步：构造以太坊标准签名消息哈希
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));

        // 第三步：用 ecrecover 从签名中恢复出签名者的地址
        address signer = ecrecover(ethSignedMessageHash, v, r, s);

        // 第四步：验证恢复出的地址是否是组织者
        require(signer == organizer, "Invalid signature");

        // 验证通过，记录签到
        hasAttended[attendee] = true;
        attendeeCount++;

        emit AttendeeCheckedIn(attendee, block.timestamp);
    }

    // 批量签到 - 一次交易处理多个参与者，节省 gas
    // 参数是四个等长的数组：参与者地址列表 + 每个人对应的签名（v, r, s）
    function batchCheckIn(
        address[] calldata attendees,   // calldata：只读且比 memory 省 gas，适合外部传入的数组
        uint8[] calldata v,
        bytes32[] calldata r,
        bytes32[] calldata s
    ) external eventActive {
        // 确保四个数组长度一致，否则签名和地址对不上
        require(attendees.length == v.length, "Array length mismatch");
        require(attendees.length == r.length, "Array length mismatch");
        require(attendees.length == s.length, "Array length mismatch");
        // 确保批量签到后不会超过人数上限
        require(attendeeCount + attendees.length <= maxAttendees, "Would exceed capacity");

        // 遍历每个参与者，逐一验证签名并签到
        for (uint256 i = 0; i < attendees.length; i++) {
            address attendee = attendees[i];

            // 已签到的直接跳过，不 revert，继续处理下一个
            // 这比 require 更友好：一个人重复不影响其他人
            if (hasAttended[attendee]) continue;

            // 和单人签到完全一样的签名验证流程
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

            // 这里用 if 而不是 require：签名无效的直接跳过，不阻断整个批次
            // 如果用 require，一个人的签名有问题就会导致所有人都签不了
            if (signer == organizer) {
                hasAttended[attendee] = true;
                attendeeCount++;
                emit AttendeeCheckedIn(attendee, block.timestamp);
            }
        }
    }

    // 验证签名有效性 - 只查不改，不执行签到
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
        return signer == organizer;  // 返回 true/false，不 require
    }

    // 获取消息哈希 - 给前端用的辅助函数
    function getMessageHash(address attendee) external view returns (bytes32) {
        return keccak256(abi.encodePacked(
            attendee,
            address(this),
            eventName
        ));
    }

    // 切换活动状态 - 组织者可以暂停/恢复活动
    function toggleEventStatus() external onlyOrganizer {
        isEventActive = !isEventActive;  // true 变 false，false 变 true
        emit EventStatusChanged(isEventActive);
    }

    // 查询活动信息 - 一次性返回所有关键数据
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