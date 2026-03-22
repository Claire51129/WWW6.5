// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EventEntry {
    string public eventName;
    uint256 public eventDate;
    uint256 public maxAttendees;
    address public organizer;
    bool public isEventActive;

    uint256 public attendeeCount;
    mapping(address => bool) public hasAttended;

    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive);

    constructor(string memory _eventName, uint256 _eventDate_unix, uint256 _maxAttendees) {
        eventName = _eventName;
        eventDate = _eventDate_unix;
        maxAttendees = _maxAttendees;
        organizer = msg.sender;
        isEventActive = true;

        emit EventCreated(_eventName, _eventDate_unix, _maxAttendees);
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the event organizer can call this function");
        _;
    }

    function setEventStatus(bool _isActive) external onlyOrganizer {
        isEventActive = _isActive;
        emit EventStatusChanged(_isActive);
    }

    function getMessageHash(address _attendee) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), eventName, _attendee));
    }

    // 如果有人诱骗用户在链下签署某些内容，然后在链上重复使用该签名来做一些恶意的事情怎么办？
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        // keccak256 的输出长度是 32 字节
        // 签名绑定在"消息签名"场景，无法用于交易执行
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function verifySignature(address _attendee, bytes memory _signature) public view returns (bool) {
        // 原始消息哈希
        bytes32 messageHash = getMessageHash(_attendee);
        // 以太坊签名消息哈希
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, _signature) == organizer;
    }

    // 使用ecrecover 从签名恢复签名者地址
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        // 所有以太坊签名的长度都是 65 字节
        require(_signature.length == 65, "Invalid signature length");

        // 签名的两个组成部分
        bytes32 r;
        bytes32 s;
        // 恢复ID (通常是27或28)
        uint8 v;

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        // 不同的钱包或系统会给你一个 `v` 值，即 0 或 1。但以太坊预计是 27 或 28。
        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature 'v' value");

        // 使用 ecrecover 来验证它是否由组织者签署
        // 即看这个签名是不是组织者发给改参加者的，恢复出的是组织者的地址
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function checkIn(bytes memory _signature) external {
        require(isEventActive, "Event is not active");
        require(block.timestamp <= eventDate + 1 days, "Event has ended");
        require(!hasAttended[msg.sender], "Attendee has already checked in");
        require(attendeeCount < maxAttendees, "Maximum attendees reached");
        require(verifySignature(msg.sender, _signature), "Invalid signature");

        hasAttended[msg.sender] = true;
        attendeeCount++;

        emit AttendeeCheckedIn(msg.sender, block.timestamp);
    }
}