// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
//"链下签名，链上验证" 
//出席跟踪器
contract EventEntry {
    /**
 - 活动内容
- 谁负责
- 当它发生时
- 可参加人数
- 谁已经签到了
- 大门是否还开着
    **/
    string public eventName;
    address public organizer;//看门人
    uint256 public eventDate;
    uint256 public maxAttendees;
    uint256 public attendeeCount;
    bool public isEventActive;

    mapping(address => bool) public hasAttended;//跟踪谁已经签到
/**`
EventCreated`：在部署期间发出一次。

`AttendeeCheckedIn`：每次有人成功签到时触发。

`EventStatusChanged`：允许组织者暂停/恢复事件。
**/
    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive);

    constructor(string memory _eventName, uint256 _eventDate_unix, uint256 _maxAttendees) {
        eventName = _eventName;
        eventDate = _eventDate_unix;
        maxAttendees = _maxAttendees;
        organizer = msg.sender;
        isEventActive = true;
//设置初始值
        emit EventCreated(_eventName, _eventDate_unix, _maxAttendees);
    }

//权限控制
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the event organizer can call this function");
        _;
    }
//设置事件状态
    function setEventStatus(bool _isActive) external onlyOrganizer {
        isEventActive = _isActive;
        emit EventStatusChanged(_isActive);
    }
// 以太坊签名消息哈希？？ 制作密码
    function getMessageHash(address _attendee) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), eventName, _attendee));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }
//签名验证？？ 验证密码
    function verifySignature(address _attendee, bytes memory _signature) public view returns (bool) {
        bytes32 messageHash = getMessageHash(_attendee);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, _signature) == organizer;
    }


    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        // 以太坊签名的长度都是 65 字节
        require(_signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;
// 程序集提取值
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

    /**
    有时，不同的钱包或系统会给你一个 `v` 值，即 0 或 1。
    但以太坊预计是 27 或 28
    **/
// 根据需要修复 V 值
        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature 'v' value");
// 恢复签名者的地址
/**
`ecrecover`——一个内置的以太坊函数，它采用：

签名消息哈希

签名值 （`v、r、s`）

**/
        return ecrecover(_ethSignedMessageHash, v, r, s);//返回签名者的地址
    }

    function checkIn(bytes memory _signature) external {
/**
他们被邀请（通过提供有效签名）
他们在允许的窗口内签到
活动仍在进行中
他们尚未签到。
还有空余
**/
        require(isEventActive, "Event is not active");
        require(block.timestamp <= eventDate + 1 days, "Event has ended");
        require(!hasAttended[msg.sender], "Attendee has already checked in");
        require(attendeeCount < maxAttendees, "Maximum attendees reached");
        require(verifySignature(msg.sender, _signature), "Invalid signature");
//将呼叫者标记为现在已签到的人
        hasAttended[msg.sender] = true;
        attendeeCount++;

        emit AttendeeCheckedIn(msg.sender, block.timestamp);
    }
}