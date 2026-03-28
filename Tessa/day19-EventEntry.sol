// 学校活动签到系统：一个人一个人签到（完整版）
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EventEntry {    //基本信息
    string public eventName;    //活动名
    address public organizer;    //组织者（创建合约的人）
    uint256 public eventDate;    //活动日期
    uint256 public maxAttendees;    // 活动最大与会者人数
    uint256 public attendeeCount;    //活动人数（现在来了多少人）
    bool public isEventActive;    //活动是否开启

    mapping(address => bool) public hasAttended;    //记录谁来过（像一个表）

    // 事件：日志广播
    event EventCreated(string name, uint256 date, uint256 maxAttendees);   //创建活动时广播
    event AttendeeCheckedIn(address attendee, uint256 timestamp);    //有人签到
    event EventStatusChanged(bool isActive);

    // 构造函数（创建活动）
    constructor(string memory _eventName, uint256 _eventDate_unix, uint256 _maxAttendees) {
        eventName = _eventName;
        eventDate = _eventDate_unix;
        maxAttendees = _maxAttendees;
        organizer = msg.sender;
        isEventActive = true;

        emit EventCreated(_eventName, _eventDate_unix, _maxAttendees);
    }

    modifier onlyOrganizer() {    //权限控制：只有老师能操作/改规则
        require(msg.sender == organizer, "Only the event organizer can call this function");
        _;
    }

    // 功能：控制活动开关
    function setEventStatus(bool _isActive) external onlyOrganizer { //组织者可以说活动开始/结束
        isEventActive = _isActive;
        emit EventStatusChanged(_isActive);
    }

    // 功能：签名验证（重点-第一步）
    function getMessageHash(address _attendee) public view returns (bytes32) {   //生成“要签的内容”——生成一个“唯一字符串”=合约地址+活动名+这个人
        return keccak256(abi.encodePacked(address(this), eventName, _attendee));   //eg这是小明要参加毕业典礼
    }

    // 功能：加上以太坊前缀（第二步）
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {   //变成标准签名格式
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));   //防止被骗签（安全设计）
    }

    // 功能：验证签名（第三步）——①重新生成消息②加前缀③用ecrecover找出签名人④看是不是老师
    function verifySignature(address _attendee, bytes memory _signature) public view returns (bool) {
        bytes32 messageHash = getMessageHash(_attendee);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, _signature) == organizer;
    }

    // 功能：ecrecover（核心魔法）
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        require(_signature.length == 65, "Invalid signature length");

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

        return ecrecover(_ethSignedMessageHash, v, r, s);   // 从“签名”里找出是谁签的：看到签名→认出是组织者写的
    }

    // 功能：签到
    function checkIn(bytes memory _signature) external {   //学生调用
        require(isEventActive, "Event is not active");   //检查活动还在吗？
        require(block.timestamp <= eventDate + 1 days, "Event has ended");   //还没结束吗？
        require(!hasAttended[msg.sender], "Attendee has already checked in");   //你没签到过吗？
        require(attendeeCount < maxAttendees, "Maximum attendees reached");   //没超人数吗？
        require(verifySignature(msg.sender, _signature), "Invalid signature");   //你的签名是主办方给的吗？

        hasAttended[msg.sender] = true;   //如果以上全部通过
        attendeeCount++;    //则标记你完成签到

        emit AttendeeCheckedIn(msg.sender, block.timestamp);
    }
}






// 现实世界的签名：老师在纸上签字；区块链签名：老师用私钥签一段数据——谁都可以验证：1是不是老师签的；2有没有被篡改。