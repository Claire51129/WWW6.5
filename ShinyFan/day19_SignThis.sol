// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


contract EventEntry{

    string public eventName;//活动名称
    address public organizer;//组织者地址
    uint256 public eventDate;//活动时间
    uint256 public maxAttendees;//可参加人数
    uint256 public attendeeCount;//谁已经签到了  从 `0` 开始，每次新用户成功签入时递增 1
    bool public isEventActive;//活动是否进行，是否可以签到


    mapping(address => bool) public hasAttended;//跟踪谁已经签到了

    event EventCreated(string name, uint256 date, uint256 maxAttendees);//事件：创建活动
    event AttendeeCheckedIn(address attendee, uint256 timestamp);//事件：签到
    event EventStatusChanged(bool isActive);//时间：活动是否进行

    //构造函数
    constructor(string memory _eventName, uint256 _eventDate_unix, uint256 _maxAttendees) {
        eventName = _eventName;
        eventDate = _eventDate_unix;
        maxAttendees = _maxAttendees;
        organizer = msg.sender;
        isEventActive = true;

        emit EventCreated(_eventName, _eventDate_unix, _maxAttendees);//触发活动已创建事件
    }

    //修饰符
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the event organizer can call this function");
        _;
    }

    //组织者可以修改活动开始/暂停的状态
    function setEventStatus(bool _isActive) external onlyOrganizer {
        isEventActive = _isActive;
        emit EventStatusChanged(_isActive);//触发活动状态事件
    }

    //获取信息哈希值 当需要验证签到时触发
    function getMessageHash(address _attendee) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), eventName, _attendee));
    }//将合约地址+活动名字+参加者地址打包生成一个哈希值

    //获取以太坊签名消息哈希
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }//加上以太坊信息格式

    //验证签名
    function verifySignature(address _attendee, bytes memory _signature) public view returns (bool) {
        bytes32 messageHash = getMessageHash(_attendee);//生成基本消息的哈希
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);//给这个消息加上以太坊格式
        return recoverSigner(ethSignedMessageHash, _signature) == organizer;//通过辅助函数 recoverSigner提取签名消息 比对是否为合约签名
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        require(_signature.length == 65, "Invalid signature length");//检查签名长度是否为65，以太坊签名长度均为65

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

        require(v == 27 || v == 28, "Invalid signature 'v' value");

        return ecrecover(_ethSignedMessageHash, v, r, s);//恢复签名者地址
    }

    //签到前进行检查
    function checkIn(bytes memory _signature) external {
        require(isEventActive, "Event is not active");
        require(block.timestamp <= eventDate + 1 days, "Event has ended");
        require(!hasAttended[msg.sender], "Attendee has already checked in");
        require(attendeeCount < maxAttendees, "Maximum attendees reached");
        require(verifySignature(msg.sender, _signature), "Invalid signature");//拿到用户地址和用户签名，放到之前写的verifySignature进行检查

        hasAttended[msg.sender] = true;
        attendeeCount++;

        emit AttendeeCheckedIn(msg.sender, block.timestamp);
    }
}