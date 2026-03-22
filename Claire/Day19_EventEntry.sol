// SPDX-License-Identifier: MIT
// 代码开源协议

pragma solidity ^0.8.0;
// 指定Solidity编译器版本

contract SignThis {
// 定义一个合约，叫"签名签到"
// 作用：通过数字签名验证参与者身份并签到

    string public eventName;
    // 活动名称（公开）
    
    address public organizer;
    // 组织者地址（公开）
    
    uint256 public eventDate;
    // 活动日期（Unix时间戳）
    
    uint256 public maxAttendees;
    // 最大参与人数
    
    uint256 public attendeeCount;
    // 当前已签到人数
    
    bool public isEventActive;
    // 活动是否活跃（true=进行中）

    mapping(address => bool) public hasAttended;
    // 映射：地址 → 是否已签到

    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    // 事件：活动创建
    
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    // 事件：签到成功
    
    event EventStatusChanged(bool isActive);
    // 事件：活动状态改变

    constructor(string memory _eventName, uint256 _eventDate, uint256 _maxAttendees) {
    // 构造函数：部署时执行
        eventName = _eventName;
        organizer = msg.sender;
        eventDate = _eventDate;
        maxAttendees = _maxAttendees;
        isEventActive = true;

        emit EventCreated(_eventName, _eventDate, _maxAttendees);
    }

    modifier onlyOrganizer() {
    // 修饰符：只有组织者能调用
        require(msg.sender == organizer, "Only organizer");
        _;
    }

    modifier eventActive() {
    // 修饰符：活动必须活跃
        require(isEventActive, "Event not active");
        _;
    }

    // 使用签名验证参与者身份
    function checkInWithSignature(
        address attendee,      // 参与者地址
        uint8 v,               // 签名的v值（恢复ID）
        bytes32 r,             // 签名的r值
        bytes32 s              // 签名的s值
    ) external eventActive {
    // 函数：单个签到（传入签名参数）
    // external：外部调用
    // eventActive：活动必须活跃
        
        require(attendeeCount < maxAttendees, "Event full");
        // 检查：还有空位
        
        require(!hasAttended[attendee], "Already checked in");
        // 检查：该参与者还没签到过

        // 构造消息哈希
        bytes32 messageHash = keccak256(abi.encodePacked(
            attendee,           // 参与者地址
            address(this),      // 当前合约地址
            eventName           // 活动名称
        ));
        // 打包三个信息并哈希，生成唯一消息
        // 这样签名和特定的活动、特定的参与者绑定

        // 以太坊签名消息哈希
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",  // EIP-191 前缀
            messageHash                          // 原始消息哈希
        ));
        // 添加以太坊签名标准前缀
        // 这是以太坊钱包签名时使用的格式

        // 恢复签名者地址
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        // ecrecover：以太坊内置函数
        // 从签名和消息中恢复出签名者的地址
        // 不需要知道私钥，任何人都能验证

        // 验证签名者是组织者
        require(signer == organizer, "Invalid signature");
        // 只有组织者签名的消息才有效

        // 记录参与
        hasAttended[attendee] = true;
        // 标记该地址已签到
        
        attendeeCount++;
        // 签到人数+1

        emit AttendeeCheckedIn(attendee, block.timestamp);
        // 发出签到事件
    }

    // 批量签到 (Gas优化)
    function batchCheckIn(
        address[] calldata attendees,  // 参与者地址数组
        uint8[] calldata v,            // v值数组
        bytes32[] calldata r,          // r值数组
        bytes32[] calldata s           // s值数组
    ) external eventActive {
    // 函数：批量签到，一次交易签到多人
    // calldata：只读参数，节省gas
    // 适合活动结束后批量录入
        
        require(attendees.length == v.length, "Array length mismatch");
        require(attendees.length == r.length, "Array length mismatch");
        require(attendees.length == s.length, "Array length mismatch");
        // 检查所有数组长度相同
        
        require(attendeeCount + attendees.length <= maxAttendees, "Would exceed capacity");
        // 检查：批量签到后不会超过容量

        for (uint256 i = 0; i < attendees.length; i++) {
        // 循环处理每个参与者
            address attendee = attendees[i];

            if (hasAttended[attendee]) continue;
            // 如果已经签到过，跳过（防止重复签到）

            // 构造消息哈希（与单个签到相同）
            bytes32 messageHash = keccak256(abi.encodePacked(
                attendee,
                address(this),
                eventName
            ));

            bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                messageHash
            ));

            // 恢复签名者地址
            address signer = ecrecover(ethSignedMessageHash, v[i], r[i], s[i]);

            // 如果签名有效（是组织者签的）
            if (signer == organizer) {
                hasAttended[attendee] = true;
                attendeeCount++;
                emit AttendeeCheckedIn(attendee, block.timestamp);
            }
            // 如果签名无效，跳过该参与者（不报错，继续处理下一个）
        }
    }

    // 验证签名有效性 (不执行签到)
    function verifySignature(
        address attendee,  // 参与者地址
        uint8 v,           // 签名的v值
        bytes32 r,         // 签名的r值
        bytes32 s          // 签名的s值
    ) external view returns (bool) {
    // 函数：验证签名是否有效（只读，不改变状态）
    // 用于前端预先验证
        
        // 构造消息哈希
        bytes32 messageHash = keccak256(abi.encodePacked(
            attendee,
            address(this),
            eventName
        ));

        // 添加以太坊签名前缀
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));

        // 恢复签名者地址
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        
        // 返回是否是组织者签的名
        return signer == organizer;
    }

    // 获取消息哈希 (用于前端签名)
    function getMessageHash(address attendee) external view returns (bytes32) {
    // 函数：获取要签名的消息哈希
    // 前端调用这个函数获取哈希，然后用组织者私钥签名
        
        return keccak256(abi.encodePacked(
            attendee,
            address(this),
            eventName
        ));
    }

    // 管理员功能
    function toggleEventStatus() external onlyOrganizer {
    // 函数：切换活动状态（只有组织者）
        isEventActive = !isEventActive;
        // 取反：true变false，false变true
        
        emit EventStatusChanged(isEventActive);
        // 发出状态改变事件
    }

    function getEventInfo() external view returns (
        string memory name,      // 活动名称
        uint256 date,            // 活动日期
        uint256 maxCapacity,     // 最大容量
        uint256 currentCount,    // 当前签到人数
        bool active              // 是否活跃
    ) {
    // 函数：获取活动所有信息
    // 一次调用返回所有数据，方便前端
        
        return (eventName, eventDate, maxAttendees, attendeeCount, isEventActive);
    }
}