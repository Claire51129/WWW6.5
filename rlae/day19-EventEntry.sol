// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract EventEntry{
    string public eventName; //任何人都可以调用 eventName（） 来获取此值
    address public organizer;
    uint256 public eventDate; //event's scheduled date ，以 Unix 时间戳表示
    uint256 public maxAttendees;
    uint256 public attendeeCount; //谁已经签到了
    bool public isEventActive;
    mapping(address => bool) public hasAttended; 
    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive); //允许组织者暂停/恢复事件

    constructor(string memory _eventName, uint256 _eventDate_unix, uint256 _maxAttendees) {
    eventName = _eventName;
    eventDate = _eventDate_unix; //Unix 时间戳 （如 1745251200）
    maxAttendees = _maxAttendees; //参加的人数设定了上限
    organizer = msg.sender;
    isEventActive = true; //默认情况

    emit EventCreated(_eventName, _eventDate_unix, _maxAttendees);
    }
    modifier onlyOrganizer() {
    require(msg.sender == organizer, "Only the event organizer can call this function");
    _;
    }
    function setEventStatus(bool _isActive) external onlyOrganizer {
    isEventActive = _isActive; //暂停或恢复签入
    emit EventStatusChanged(_isActive);
    }
    function getMessageHash(address _attendee) public view returns (bytes32) {
    return keccak256(abi.encodePacked(address(this), eventName, _attendee));
    //address(this)：防止“重放攻击”。确保这个签名只能在当前这个合约中使用，不能在黑客克隆的伪造合约中使用
    //先调用这个函数得到一个哈希值for 用户发放一个签到证明
    }
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    //开头强制加上了 \x19Ethereum Signed Message:\n...，这段数据在 EVM 解释器里就再也不可能被解析成合法的转账交易格式了。它被永远定性为“一段纯消息”。
    }
    function verifySignature(address _attendee, bytes memory _signature) public view returns (bool) {
    bytes32 messageHash = getMessageHash(_attendee); //创建组织者为特定与会者在链下签名的确切哈希值
    bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash); //转换为以太坊签名格式
    return recoverSigner(ethSignedMessageHash, _signature) == organizer; //提取签名**消息的地址** 。将该地址与`组织者` ==（部署此合约的地址）进行比较
    }
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
    public
    pure
    returns (address)
    {
        require(_signature.length == 65, "Invalid signature length"); //检查签名长度
        bytes32 r;
        bytes32 s;
        uint8 v;
        //将签名分成 3 个部分r,s,v (32byte+32byte+1byte=8bit)
        assembly {
        r := mload(add(_signature, 32)) //从位置 32 开始的前 32 个字节
        s := mload(add(_signature, 64)) //接下来的 32 字节，从 64 开始。
        v := byte(0, mload(add(_signature, 96))) //位置 96 的 1 字节
        }
        //不同的钱包或系统会给你一个 v 值，即 0 或 1
        if (v < 27) {
        v += 27;
        }
        require(v == 27 || v == 28, "Invalid signature 'v' value");
        return ecrecover(_ethSignedMessageHash, v, r, s); //恢复签名者的地址
    }
    function checkIn(bytes memory _signature) external {
    require(isEventActive, "Event is not active");
    require(block.timestamp <= eventDate + 1 days, "Event has ended");
    require(!hasAttended[msg.sender], "Attendee has already checked in");
    require(attendeeCount < maxAttendees, "Maximum attendees reached");
    require(verifySignature(msg.sender, _signature), "Invalid signature");//所有加密逻辑（消息哈希、以太坊前缀、ecrecover）——整齐地包装在 verifySignature（）

    hasAttended[msg.sender] = true; //防止重复签入
    attendeeCount++;

    emit AttendeeCheckedIn(msg.sender, block.timestamp);
    }

}




