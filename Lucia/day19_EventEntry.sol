// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EventEntry {
    string public eventName;
    address public organizer;
    uint256 public eventDate;
    uint256 public maxAttendees;
    uint256 public attendeeCount;
    bool public isEventActive;

    mapping(address=> bool) public hasAttended;

    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive);

    constructor(string memory _eventName, uint256 _eventDate_unix, uint256 _maxAttendees){
        eventName = _eventName;
        eventDate = _eventDate_unix;
        maxAttendees = _maxAttendees;
        organizer = msg.sender;
        isEventActive = true;

        emit EventCreated(_eventName, _eventDate_unix, _maxAttendees);
    }

    modifier onlyOrganizer(){
        require(msg.sender == organizer, "Only the event organizer can call this function");
        _;
    }

    function setEventStatus(bool _isActive) external onlyOrganizer{
        isEventActive = _isActive;
        emit EventStatusChanged(_isActive);
    }

    function getMessageHash(address _attendee) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), eventName, _attendee));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    //二次哈希，打包abi.encodePacked 将前缀字符串和消息哈希_messageHash拼接在一起
    //再次哈希keccak256
    //加上前缀后，数据变成0x19，以太坊节点在处理转账交易不会处理任何以019开头的数据， 把签名消息和签名交易彻底隔离
    //EIP-191标准抓们挑选了0x19这个数字作为防火墙
    }

    function verifySignature(address _attendee, bytes memory _signature) public view returns (bool) {
        bytes32 messageHash = getMessageHash(_attendee);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, _signature) == organizer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns(address)
    {require(_signature.length ==65,"Invalid signature length");
    bytes32 r;
    bytes32 s;
    uint8 v;
    //ESDSA签名固定为65字节，r32字节，s32字节，v1字节
    assembly {
        r := mload(add(_signature, 32))//跳过32字节的长度计算器，32-64
        s := mload(add(_signature, 64))//64-96
        v := byte(0, mload(add(_signature, 96)))//抓取的32字节只取第一个字节
    }

    if (v < 27){
        v += 27;

    }
    require(v ==27 || v ==28, "Invalid signature 'v' value");
    return ecrecover(_ethSignedMessageHash, v , r, s);
    
    }

    function checkIn(bytes memory _signature) external{
        require(isEventActive, "Event is not active");
        require(block.timestamp <= eventDate + 1 days, "Event has ended");
        require(!hasAttended[msg.sender], "Attendee has already checked in");
        require(attendeeCount < maxAttendees, "Maxium attendees reached");
        require(verifySignature(msg.sender, _signature),"Invalid signature");

        hasAttended[msg.sender] = true;
        attendeeCount++;

        emit AttendeeCheckedIn(msg.sender, block.timestamp);
    }
    
    }