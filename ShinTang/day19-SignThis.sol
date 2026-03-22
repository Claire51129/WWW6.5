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
    function checkInWithSignature(address attendee, uint8 v, bytes32 r, bytes32 s) external eventActive {
        require(attendeeCount < maxAttendees, "Event full");
        require(!hasAttended[attendee], "Already checked in");

        // 构造消息哈希 合约地址
        bytes32 messageHash = keccak256(abi.encodePacked(attendee, address(this), eventName));

        // 以太坊签名消息哈希
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

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
    function batchCheckIn(address[] calldata attendees, uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external eventActive {
        require(attendees.length == v.length, "Array length mismatch");
        require(attendees.length == r.length, "Array length mismatch");
        require(attendees.length == s.length, "Array length mismatch");
        require(attendeeCount + attendees.length <= maxAttendees, "Would exceed capacity");

        for (uint256 i = 0; i < attendees.length; i++) {
            address attendee = attendees[i];

            if (hasAttended[attendee]) continue;  // 跳过已签到的

            bytes32 messageHash = keccak256(abi.encodePacked(attendee, address(this), eventName));
            bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

            address signer = ecrecover(ethSignedMessageHash, v[i], r[i], s[i]);

            if (signer == organizer) {
                hasAttended[attendee] = true;
                attendeeCount++;
                emit AttendeeCheckedIn(attendee, block.timestamp);
            }
        }
    }

    // 验证签名有效性 （不执行签到）
    function verifySignature(address attendee, uint8 v, bytes32 r, bytes32 s) external view returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(attendee, address(this), eventName));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        return signer == organizer;
    }

    // 获取消息哈希 (用于前端签名)
    function getMessageHash(address attendee) external view returns (bytes32) {
        return keccak256(abi.encodePacked(attendee, address(this), eventName));
    }

    // 管理员功能
    function toggleEventStatus() external onlyOrganizer {
        isEventActive = !isEventActive;
        emit EventStatusChanged(isEventActive);
    }

    function getEventInfo() external view returns (string memory name, uint256 date, uint256 maxCapacity, uint256 currentCount, bool active) {
        return (eventName, eventDate, maxAttendees, attendeeCount, isEventActive);
    }
}

//    // 1. 修改这里：填入你 getMessageHash 得到的 0x 开头的哈希
//    const msgHash = "0x……";
//
//    // 2. 修改这里：填入 Account A (Organizer) 的地址
//    const accountA = "0x……";
//
//    try {
//        // 使用 web3.eth.sign，它会自动加上以太坊特有的前缀
//        const signature = await web3.eth.sign(msgHash, accountA);
//
//        console.log("Full Signature:", signature);
//
//        const r = signature.slice(0, 66);
//        const s = "0x" + signature.slice(66, 130);
//        let v = parseInt(signature.slice(130, 132), 16);
//
//        // 修正 v 的值 (Ethereum 标准通常是 27 或 28)
//        if (v < 27) v += 27;
//
//        console.log("-----------------------");
//        console.log("把以下值填入 Remix:");
//        console.log("v:", v);
//        console.log("r:", r);
//        console.log("s:", s);
//        console.log("-----------------------");
//    } catch (e) {
//        console.error(e);
//    }
