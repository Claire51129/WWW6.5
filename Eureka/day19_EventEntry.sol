// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//ecrecover 验证签名

contract EventEntry 
{
    string public eventName;
    address public organizer;
    uint256 public eventDate;//以 Unix 时间戳表示
    uint256 public maxAttendees;
    uint256 public attendeeCount;
    bool public isEventActive;

    mapping(address => bool) public hasAttended;//考勤，不能签到两次

    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive);

    constructor(string memory _eventName, uint256 _eventDate_unix, uint256 _maxAttendees) 
    {
        eventName = _eventName;
        eventDate = _eventDate_unix;
        maxAttendees = _maxAttendees;
        organizer = msg.sender;
        isEventActive = true;

        emit EventCreated(_eventName, _eventDate_unix, _maxAttendees);
    }

    modifier onlyOrganizer() 
    {
        require(msg.sender == organizer, "Only the event organizer can call this function");
        _;
    }

    function setEventStatus(bool _isActive) external onlyOrganizer 
    {
        isEventActive = _isActive;
        emit EventStatusChanged(_isActive);
    }

    function getMessageHash(address _attendee) public view returns (bytes32) 
    {
        return keccak256(abi.encodePacked(address(this), eventName, _attendee));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) 
    {
        //以太坊签名消息哈希 ，添加保护性前缀，防止重入
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function verifySignature(address _attendee, bytes memory _signature) public view returns (bool) 
    {
        bytes32 messageHash = getMessageHash(_attendee);
        //生成基本消息哈希keccak256(contract address + event name + attendee address)
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        //转换为以太坊签名格式
        return recoverSigner(ethSignedMessageHash, _signature) == organizer;
        //ecrecover（）恢复签名地址与部署合约地址比较
    }

    //检查签名
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        require(_signature.length == 65, "Invalid signature length");
        //检查签名长度，所有以太坊签名的长度都是 65 字节

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly //低级汇编
        {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        if (v < 27) //根据需要修复 V 值，以太坊预计是 27 或 28
        {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature 'v' value");

        return ecrecover(_ethSignedMessageHash, v, r, s);
        // ecrecover恢复签名者的地址
    }

    function checkIn(bytes memory _signature) external 
    {
        require(isEventActive, "Event is not active");
        require(block.timestamp <= eventDate + 1 days, "Event has ended");
        require(!hasAttended[msg.sender], "Attendee has already checked in");
        require(attendeeCount < maxAttendees, "Maximum attendees reached");
        require(verifySignature(msg.sender, _signature), "Invalid signature");
        //检查签名

        hasAttended[msg.sender] = true;
        attendeeCount++;

        emit AttendeeCheckedIn(msg.sender, block.timestamp);
    }
}
