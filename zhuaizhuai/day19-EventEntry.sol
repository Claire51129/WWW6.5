// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EventEntry {
    
    // 活动基本信息
    string public eventName;        // 活动名称
    address public organizer;       // 主办方地址
    uint256 public eventDate;       // 活动日期（Unix时间戳）
    uint256 public maxAttendees;    // 最大参与人数
    uint256 public attendeeCount;   // 当前已签到人数
    bool public isEventActive;      // 活动是否开放

    // 记录每个地址是否已签到
    mapping(address => bool) public hasAttended;

    // 事件记录
    event EventCreated(string name, uint256 date, uint256 maxAttendees);  // 活动创建
    event AttendeeCheckedIn(address attendee, uint256 timestamp);          // 签到成功
    event EventStatusChanged(bool isActive);                               // 活动状态改变

    // 部署时设置活动信息
    constructor(string memory _eventName, uint256 _eventDate_unix, uint256 _maxAttendees) {
        eventName = _eventName;          // 设置活动名称
        eventDate = _eventDate_unix;     // 设置活动日期
        maxAttendees = _maxAttendees;    // 设置最大人数
        organizer = msg.sender;          // 部署者成为主办方
        isEventActive = true;            // 活动默认开放
        emit EventCreated(_eventName, _eventDate_unix, _maxAttendees);
    }

    // 只有主办方能调用
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the event organizer can call this function");
        _;
    }

    // 主办方开启/关闭活动
    function setEventStatus(bool _isActive) external onlyOrganizer {
        isEventActive = _isActive;
        emit EventStatusChanged(_isActive);
    }

    // 第一步：把参与者地址打包成哈希
    // 包含：合约地址+活动名称+参与者地址
    // 防止同一个签名在不同活动/合约里被重复使用！
    function getMessageHash(address _attendee) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), eventName, _attendee));
    }

    // 第二步：加上以太坊标准前缀
    // "\x19Ethereum Signed Message:\n32" 是以太坊规定的格式
    // 防止签名被用于恶意交易
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    // 第三步：验证签名是不是主办方签的
    function verifySignature(address _attendee, bytes memory _signature) public view returns (bool) {
        bytes32 messageHash = getMessageHash(_attendee);              // 生成消息哈希
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash); // 加前缀
        return recoverSigner(ethSignedMessageHash, _signature) == organizer;
        // 从签名还原出签名者地址，看是不是主办方
    }

    // 从签名还原出签名者地址
    // 签名由三部分组成：r, s, v
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public pure returns (address)
    {
        require(_signature.length == 65, "Invalid signature length");
        // 签名必须是65字节：r(32) + s(32) + v(1)

        bytes32 r; // 签名的第一部分（32字节）
        bytes32 s; // 签名的第二部分（32字节）
        uint8 v;   // 签名的第三部分（1字节）

        // 用assembly从签名里提取r, s, v
        assembly {
            r := mload(add(_signature, 32))   // 读取前32字节
            s := mload(add(_signature, 64))   // 读取中间32字节
            v := byte(0, mload(add(_signature, 96))) // 读取最后1字节
        }

        if (v < 27) {
            v += 27; // 确保v值符合以太坊规范（27或28）
        }

        require(v == 27 || v == 28, "Invalid signature 'v' value");

        // ecrecover：以太坊内置函数
        // 用签名还原出签名者的地址
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    // 参与者签到
    function checkIn(bytes memory _signature) external {
        require(isEventActive, "Event is not active");                          // 活动必须开放
        require(block.timestamp <= eventDate + 1 days, "Event has ended");      // 活动没结束
        require(!hasAttended[msg.sender], "Attendee has already checked in");   // 没有重复签到
        require(attendeeCount < maxAttendees, "Maximum attendees reached");     // 没超过人数上限
        require(verifySignature(msg.sender, _signature), "Invalid signature");  // 验证签名有效

        hasAttended[msg.sender] = true;  // 记录已签到
        attendeeCount++;                  // 人数+1
        emit AttendeeCheckedIn(msg.sender, block.timestamp); // 上链记录
    }
}

// 1️⃣ getMessageHash      → 把数据打包成哈希
// 2️⃣ getEthSignedMessageHash → 加以太坊标准前缀
// 3️⃣ recoverSigner       → 从签名还原出签名者地址
