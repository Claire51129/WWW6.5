// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EventEntry {
    // 活动基础信息
    string public eventName;
    address public organizer;
    uint256 public eventDate;
    uint256 public maxAttendees;
    uint256 public attendeeCount;
    bool public isEventActive;

    // 记录谁已经签到了
    mapping(address => bool) public hasAttended;

    // 事件：记录操作（方便前端查看）
    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive);

    // 构造函数：部署时设置活动信息
    constructor(string memory _eventName, uint256 _eventDate_unix, uint256 _maxAttendees) {
        eventName = _eventName;
        eventDate = _eventDate_unix;
        maxAttendees = _maxAttendees;
        organizer = msg.sender; // 部署者就是组织者
        isEventActive = true;  // 默认活动开启
        emit EventCreated(_eventName, _eventDate_unix, _maxAttendees);
    }

    // 修饰器：只有组织者能调用
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can do this!");
        _;
    }

    // 修饰器：只有活动开启时才能签到
    modifier eventActive() {
        require(isEventActive, "Event is not active!");
        _;
    }

    // --------------------------
    // 1. 单个签到：用签名验证身份
    // --------------------------
    function checkInWithSignature(
        address attendee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external eventActive {
        require(attendeeCount < maxAttendees, "Event is full!");
        require(!hasAttended[attendee], "Already checked in!");

        // 生成消息哈希
        bytes32 messageHash = keccak256(abi.encodePacked(
            attendee,
            address(this),
            eventName
        ));

        // 以太坊签名格式（必须加这个前缀）
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));

        // 恢复签名者地址
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        require(signer == organizer, "Invalid signature! Not allowed.");

        // 记录签到
        hasAttended[attendee] = true;
        attendeeCount++;
        emit AttendeeCheckedIn(attendee, block.timestamp);
    }

    // --------------------------
    // 2. 批量签到：一次给很多人签到（省Gas）
    // --------------------------
    function batchCheckIn(
        address[] calldata attendees,
        uint8[] calldata v,
        bytes32[] calldata r,
        bytes32[] calldata s
    ) external onlyOrganizer eventActive {
        require(attendees.length == v.length, "Array length mismatch!");
        require(attendees.length == r.length, "Array length mismatch!");
        require(attendees.length == s.length, "Array length mismatch!");
        require(attendeeCount + attendees.length <= maxAttendees, "Too many people!");

        for (uint256 i = 0; i < attendees.length; i++) {
            address attendee = attendees[i];
            if (hasAttended[attendee]) continue; // 跳过已签到的

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

    // --------------------------
    // 3. 验证签名：不签到，只检查签名是否有效
    // --------------------------
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

    // --------------------------
    // 4. 获取消息哈希：给前端生成签名用
    // --------------------------
    function getMessageHash(address attendee) external view returns (bytes32) {
        return keccak256(abi.encodePacked(
            attendee,
            address(this),
            eventName
        ));
    }

    // --------------------------
    // 5. 组织者功能：开启/关闭活动
    // --------------------------
    function toggleEventStatus() external onlyOrganizer {
        isEventActive = !isEventActive;
        emit EventStatusChanged(isEventActive);
    }

    // --------------------------
    // 6. 获取活动完整信息
    // --------------------------
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