// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//基于签名验证的活动签到合约
contract EventEntry {

    // 活动名称
    string public eventName;

    // 活动组织者
    address public organizer;

    // 活动时间（Unix时间戳）
    uint256 public eventDate;

    // 最大参与人数
    uint256 public maxAttendees;

    // 当前参与人数
    uint256 public attendeeCount;

    // 活动状态
    bool public isEventActive;

    // 是否已签到
    mapping(address => bool) public hasAttended;

    // 事件
    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive);

    // 构造函数
    constructor(
        string memory _eventName,
        uint256 _eventDate_unix,
        uint256 _maxAttendees
    ) {
        require(_eventDate_unix > block.timestamp, "Invalid event date");
        require(_maxAttendees > 0, "Invalid attendee limit");

        eventName = _eventName;
        eventDate = _eventDate_unix;
        maxAttendees = _maxAttendees;

        organizer = msg.sender;
        isEventActive = true;

        emit EventCreated(_eventName, _eventDate_unix, _maxAttendees);
    }

    // 仅组织者可调用
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer");
        _;
    }

    // 修改活动状态
    function setEventStatus(bool _isActive)
        external
        onlyOrganizer
    {
        isEventActive = _isActive;
        emit EventStatusChanged(_isActive);
    }

    // 生成消息哈希
    function getMessageHash(address _attendee)
        public
        view
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                address(this),
                eventName,
                _attendee
            )
        );
    }

    // 转换为 Ethereum Signed Message
    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                _messageHash
            )
        );
    }

    // 验证签名
    function verifySignature(
        address _attendee,
        bytes memory _signature
    )
        public
        view
        returns (bool)
    {
        bytes32 messageHash = getMessageHash(_attendee);
        bytes32 ethSignedMessageHash =
            getEthSignedMessageHash(messageHash);

        return recoverSigner(
            ethSignedMessageHash,
            _signature
        ) == organizer;
    }

    // 从签名恢复地址
    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    )
        public
        pure
        returns (address)
    {
        require(_signature.length == 65, "Invalid signature");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid v");

        return ecrecover(
            _ethSignedMessageHash,
            v,
            r,
            s
        );
    }

    // 签到
    function checkIn(bytes memory _signature)
        external
    {
        require(isEventActive, "Event not active");
        require(block.timestamp <= eventDate + 1 days, "Event ended");
        require(!hasAttended[msg.sender], "Already checked in");
        require(attendeeCount < maxAttendees, "Event full");
        require(
            verifySignature(msg.sender, _signature),
            "Invalid signature"
        );

        hasAttended[msg.sender] = true;
        attendeeCount++;

        emit AttendeeCheckedIn(msg.sender, block.timestamp);
    }
}
