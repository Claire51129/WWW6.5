// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SignThis
 * @dev 活动签到合约：利用非对称加密技术（ECDSA）实现去中心化的入场核销。
 */
contract SignThis {
    string public eventName;      // 活动名称
    address public organizer;     // 组织者地址（唯一的签名授权方）
    uint256 public eventDate;     // 活动日期（Unix 时间戳）
    uint256 public maxAttendees;  // 最大人数限制
    uint256 public attendeeCount; // 当前已签到人数
    bool public isEventActive;    // 活动是否开启（暂停开关）
    
    // 记录地址是否已经签到过，防止“分身术”重复入场
    mapping(address => bool) public hasAttended;
    
    // 事件日志
    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive);
    
    /**
     * @notice 初始化活动信息
     */
    constructor(string memory _eventName, uint256 _eventDate, uint256 _maxAttendees) {
        eventName = _eventName;
        organizer = msg.sender;
        eventDate = _eventDate;
        maxAttendees = _maxAttendees;
        isEventActive = true;
        
        emit EventCreated(_eventName, _eventDate, _maxAttendees);
    }
    
    /// @dev 权限控制：仅限组织者执行
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer");
        _;
    }
    
    /// @dev 状态检查：活动必须在开启状态
    modifier eventActive() {
        require(isEventActive, "Event not active");
        _;
    }
    
    /**
     * @notice 核心功能：使用组织者的签名进行签到
     * @param attendee 签到人的地址
     * @param v 签名的恢复标识 (Recovery ID)
     * @param r 签名的 R 部分 (输出的 X 坐标)
     * @param s 签名的 S 部分 (输出的证明数据)
     */
    function checkInWithSignature(
        address attendee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external eventActive {
        require(attendeeCount < maxAttendees, "Event full");
        require(!hasAttended[attendee], "Already checked in");
        
        // 1. 重构原始消息哈希：必须与前端签名时的内容完全一致
        bytes32 messageHash = keccak256(abi.encodePacked(
            attendee,
            address(this),  // 加上合约地址防止“重放攻击”（同一个签名不能在别的活动用）
            eventName
        ));
   
        // 2. 转换为以太坊标准的签名格式（加上特定前缀）
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));
        
        // 3. 使用 ecrecover 算出是谁签的名
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        
        // 4. 验证：算出的人是不是我们的组织者
        require(signer == organizer, "Invalid signature");
        
        // 5. 更新状态
        hasAttended[attendee] = true;
        attendeeCount++;
        
        emit AttendeeCheckedIn(attendee, block.timestamp);
    }
    
    /**
     * @notice 批量签到 (Gas 优化版)
     * @dev 适合在网络空闲时由组织者统一上传多个人的签到数据
     */
    function batchCheckIn(
        address[] calldata attendees,
        uint8[] calldata v,
        bytes32[] calldata r,
        bytes32[] calldata s
    ) external eventActive {
        // 数组长度对齐检查
        require(attendees.length == v.length, "Array length mismatch");
        require(attendees.length == r.length, "Array length mismatch");
        require(attendees.length == s.length, "Array length mismatch");
        require(attendeeCount + attendees.length <= maxAttendees, "Would exceed capacity");
        
        for (uint256 i = 0; i < attendees.length; i++) {
            address attendee = attendees[i];
            
            // 跳过已签到地址，避免整个交易因为某一个人而失败（Revert）
            if (hasAttended[attendee]) continue;  
            
            bytes32 messageHash = keccak256(abi.encodePacked(
                attendee,
                address(this),
                eventName
            ));
            
            bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                messageHash
            ));
            
            address signer = ecrecover(ethSignedMessageHash, v[i], r[i], s[i]);
            
            // 如果签名合法，则通过签到
            if (signer == organizer) {
                hasAttended[attendee] = true;
                attendeeCount++;
                emit AttendeeCheckedIn(attendee, block.timestamp);
            }
        }
    }
    
    /**
     * @notice 验证签名的纯查询函数 (不消耗 Gas)
     */
    function verifySignature(
        address attendee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(
            attendee,
            address(this),
            eventName
        ));
        
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));
        
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        return signer == organizer;
    }
    
    /**
     * @notice 辅助函数：获取前端签名所需的哈希值
     * @dev 组织者在前端调用此函数获得哈希，然后用钱包进行签名
     */
    function getMessageHash(address attendee) external view returns (bytes32) {
        return keccak256(abi.encodePacked(
            attendee,
            address(this),
            eventName
        ));
    }
  
    /**
     * @notice 切换活动状态（开启/暂停）
     */
    function toggleEventStatus() external onlyOrganizer {
        isEventActive = !isEventActive;
        emit EventStatusChanged(isEventActive);
    }
    
    /**
     * @notice 视图函数：一键获取活动详情
     */
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