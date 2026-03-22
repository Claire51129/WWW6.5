// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EventEntry {
    string public eventName;  //活动名称
    address public organizer;  //组织者
    uint256 public eventDate;  //活动日期
    uint256 public maxAttendees; //最多参加人数
    uint256 public attendeeCount; //已签到
    bool public isEventActive;    //活动是否接受签入

    mapping(address => bool) public hasAttended; //映射跟踪已签到人，防止2次签到

    event EventCreated(string name, uint256 date, uint256 maxAttendees); //创建活动，在部署期间发出一次
    event AttendeeCheckedIn(address attendee, uint256 timestamp); //签到成功触发
    event EventStatusChanged(bool isActive); //组织者暂停/恢复触发

    constructor(string memory _eventName, uint256 _eventDate_unix, uint256 _maxAttendees) {
        eventName = _eventName;
        eventDate = _eventDate_unix; //活动日期时间戳
        maxAttendees = _maxAttendees;
        organizer = msg.sender;
        isEventActive = true;

        emit EventCreated(_eventName, _eventDate_unix, _maxAttendees);
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the event organizer can call this function");
        _;
    }

    //切换状态：暂停或恢复签入
    function setEventStatus(bool _isActive) external onlyOrganizer {
        isEventActive = _isActive;
        emit EventStatusChanged(_isActive);
    }

    function getMessageHash(address _attendee) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), eventName, _attendee));
    }
    //获取原始消息哈希并用前缀包装它
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    //验证签名
    function verifySignature(address _attendee, bytes memory _signature) public view returns (bool) {
        bytes32 messageHash = getMessageHash(_attendee); //重新创建组织者为特定与会者在链下签名的确切哈希值
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);//用以太坊的标准前缀包装了消息哈希
        return recoverSigner(ethSignedMessageHash, _signature) == organizer;//从签名反推签名者地址与组织者地址比较
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        //检查签名长度
        require(_signature.length == 65, "Invalid signature length");

        //将签名分为3部分
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

        //检验v值
        require(v == 27 || v == 28, "Invalid signature 'v' value");

        //恢复签名者地址
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function checkIn(bytes memory _signature) external {
        require(isEventActive, "Event is not active"); //活动正在进行
        require(block.timestamp <= eventDate + 1 days, "Event has ended");//活动日期后1天内签到
        require(!hasAttended[msg.sender], "Attendee has already checked in");//签到一次
        require(attendeeCount < maxAttendees, "Maximum attendees reached");//参加人数上限
        require(verifySignature(msg.sender, _signature), "Invalid signature");//验证签名

        hasAttended[msg.sender] = true; //记录签到
        attendeeCount++;//递增已签到人次

        emit AttendeeCheckedIn(msg.sender, block.timestamp); //触发签到成功事件
    }
}