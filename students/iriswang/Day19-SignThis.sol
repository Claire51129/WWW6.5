// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 这是一个活动签到合约：组织者可以提前为参与者生成“电子门票”（签名）
// 参与者拿着这个签名来签到，合约验证签名是组织者签的，就允许签到
contract SignThis {
    string public eventName;         // 活动名称
    address public organizer;        // 组织者地址（只有他能生成有效签名）
    uint256 public eventDate;        // 活动日期（时间戳）
    uint256 public maxAttendees;     // 最大参与人数
    uint256 public attendeeCount;    // 当前已签到人数
    bool public isEventActive;       // 活动是否开放签到
    
    mapping(address => bool) public hasAttended;  // 记录某地址是否已签到
    
    // 事件：记录重要操作
    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive);
    
    // 构造函数：部署时设置活动基本信息
    constructor(string memory _eventName, uint256 _eventDate, uint256 _maxAttendees) {
        eventName = _eventName;
        organizer = msg.sender;                // 部署者成为组织者
        eventDate = _eventDate;
        maxAttendees = _maxAttendees;
        isEventActive = true;
        
        emit EventCreated(_eventName, _eventDate, _maxAttendees);
    }
    
    // 修饰符：只有组织者能调用某些函数
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer");
        _;
    }
    
    // 修饰符：活动必须处于激活状态
    modifier eventActive() {
        require(isEventActive, "Event not active");
        _;
    }
    
    // ========== 核心函数：使用签名签到 ==========
    // 参与者调用此函数，传入组织者提前生成的签名（v, r, s 三个部分）
    // 合约会验证签名是否由组织者签署，并且消息内容是“参与者地址+合约地址+活动名称”
    function checkInWithSignature(
        address attendee,   // 参与者地址
        uint8 v,            // 签名的一部分（恢复签名所需的参数）
        bytes32 r,          // 签名的一部分
        bytes32 s           // 签名的一部分
    ) external eventActive {
        require(attendeeCount < maxAttendees, "Event full");
        require(!hasAttended[attendee], "Already checked in");
        
        // 步骤1：构造原始消息（即组织者签名的内容）
        // 注意：这里的消息必须与前端生成签名时使用的消息完全一致
        bytes32 messageHash = keccak256(abi.encodePacked(
            attendee,           // 参与者地址
            address(this),      // 当前合约地址
            eventName           // 活动名称
        ));
        
        // 步骤2：以太坊签名要求对消息进行前缀包装（避免签名被重用）
        // 这就是标准的以太坊签名格式："\x19Ethereum Signed Message:\n32" + messageHash
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));
        
        // 步骤3：使用 ecrecover 恢复签名者的地址
        // ecrecover 是 Solidity 内置函数，输入签名和消息哈希，返回签署该消息的地址
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        
        // 步骤4：验证签名者是否是组织者
        require(signer == organizer, "Invalid signature");
        
        // 通过验证，记录签到
        hasAttended[attendee] = true;
        attendeeCount++;
        
        emit AttendeeCheckedIn(attendee, block.timestamp);
    }
    
    // 批量签到（用于一次签到多个参与者，节省 Gas）
    function batchCheckIn(
        address[] calldata attendees,
        uint8[] calldata v,
        bytes32[] calldata r,
        bytes32[] calldata s
    ) external eventActive {
        // 检查数组长度一致
        require(attendees.length == v.length, "Array length mismatch");
        require(attendees.length == r.length, "Array length mismatch");
        require(attendees.length == s.length, "Array length mismatch");
        require(attendeeCount + attendees.length <= maxAttendees, "Would exceed capacity");
        
        for (uint256 i = 0; i < attendees.length; i++) {
            address attendee = attendees[i];
            if (hasAttended[attendee]) continue;  // 跳过已签到的
            
            // 重复单次签到的验证逻辑
            bytes32 messageHash = keccak256(abi.encodePacked(attendee, address(this), eventName));
            bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
            address signer = ecrecover(ethSignedMessageHash, v[i], r[i], s[i]);
            
            if (signer == organizer) {
                hasAttended[attendee] = true;
                attendeeCount++;
                emit AttendeeCheckedIn(attendee, block.timestamp);
            }
        }
    }
    
    // 辅助函数：验证签名是否正确（不执行签到）
    function verifySignature(
        address attendee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(attendee, address(this), eventName));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        return signer == organizer;
    }
    
    // 获取消息哈希（前端可以用来生成签名）
    function getMessageHash(address attendee) external view returns (bytes32) {
        return keccak256(abi.encodePacked(attendee, address(this), eventName));
    }
    
    // 管理员功能：开启/关闭签到
    function toggleEventStatus() external onlyOrganizer {
        isEventActive = !isEventActive;
        emit EventStatusChanged(isEventActive);
    }
    
    // 获取活动信息
    function getEventInfo() external view returns (
        string memory name,
        uint256 date,
        uint256 maxCapacity,
        uint256 currentCount,
        bool active
    ) {
        return (eventName, eventDate, maxAttendees, attendeeCount, isEventActive);
    }
}
