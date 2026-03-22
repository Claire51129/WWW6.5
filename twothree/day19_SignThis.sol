// SPDX-License-Identifier: MIT
// 这个合约的使用许可证是MIT（就像玩具的使用说明书授权）
pragma solidity ^0.8.0;
// 告诉电脑要用Solidity编程语言的0.8.0及以上版本来运行这个合约

contract SignThis {
    //定义一个叫SignThis的合约（就像制定一份「活动签到规则手册」）
    
    string public eventName;
    // 存活动的名字（比如「六一儿童节游园会」），所有人都能看
    address public organizer;
    // 存活动组织者的钱包地址（就像记录班主任的手机号，唯一标识）
    uint256 public eventDate;
    // 存活动日期（用时间戳表示，比如1740969600代表2025年8月1日）
    uint256 public maxAttendees;
    // 存活动最多能来多少人（比如教室最多坐50人）
    uint256 public attendeeCount;
    // 存已经签到的人数（比如现在来了30人）
    bool public isEventActive;
    // 存活动是否有效（true=活动还在进行，false=活动取消/结束）
    
    mapping(address => bool) public hasAttended;
    // 做一个「签到本」，记录每个钱包地址（同学）是否已经签到了
    
    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    // 定义一个「活动创建成功」的通知，创建活动时会触发（像班级群发“游园会定在8月1日，限50人”）
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    // 定义一个「有人签到」的通知，签到成功时触发（像群里发“小明已签到，时间：10:00”）
    event EventStatusChanged(bool isActive);
    // 定义一个「活动状态变更」的通知，比如活动取消时触发（群里发“游园会取消了”）
    
    constructor(string memory _eventName, uint256 _eventDate, uint256 _maxAttendees) {
        //合约的「初始化函数」，创建活动时必须填这3个信息（名字、日期、最多人数）
        eventName = _eventName;
        //把填的活动名字存到合约里
        organizer = msg.sender;
        // 把创建活动的人（班主任）的钱包地址记为组织者
        eventDate = _eventDate;
        //把填的活动日期存起来
        maxAttendees = _maxAttendees;
        //把填的最多人数存起来
        isEventActive = true;
        // 刚创建的活动默认是“有效”的
        
        emit EventCreated(_eventName, _eventDate, _maxAttendees);
        // 触发「活动创建成功」的通知，告诉所有人这个活动建好了
    }
    
    modifier onlyOrganizer() {
        //定义一个「只有组织者能操作」的规则（像只有班主任能改活动规则）
        require(msg.sender == organizer, "Only organizer");
        // 检查操作的人是不是组织者，不是的话就提示“只有组织者能弄”
        _;
        // 如果检查通过，就执行后面的函数（比如改活动状态）
    }
    
    modifier eventActive() {
        // 定义一个「活动必须有效」的规则（活动取消了就不能签到）
        require(isEventActive, "Event not active");
        // 检查活动是不是有效，无效的话提示“活动已失效”
        _;
        // 检查通过就执行后面的函数
    }
    
    // 使用签名验证参与者身份
    function checkInWithSignature(
        address attendee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external eventActive {
        // 单个同学签到的函数，必须活动有效才能用
        // 参数说明：attendee=要签到的同学地址，v/r/s=班主任的签名（相当于盖章）
        
        require(attendeeCount < maxAttendees, "Event full");
        // 检查签到人数没超上限，超了就提示“活动满人了”
        require(!hasAttended[attendee], "Already checked in");
        // 检查这个同学没签过到，签过了就提示“已经签到过了”
        
        // 构造消息哈希
        bytes32 messageHash = keccak256(abi.encodePacked(
            attendee,
            address(this),  // 合约地址
            eventName
        ));
        // 把“同学地址+活动合约地址+活动名字”打包，生成一个唯一的“签到凭证码”
        
        // 以太坊签名消息哈希
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));
        // 给“签到凭证码”加个以太坊专属的前缀，防止被篡改（像给凭证盖个学校的章）
        
        // 恢复签名者地址
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        // 通过签名（v/r/s）反推是谁签的字，得到签名者的地址
        
        // 验证签名者是组织者
        require(signer == organizer, "Invalid signature");
        // 检查签名的人是不是班主任，不是的话提示“签名无效（假章）”
        
        // 记录参与
        hasAttended[attendee] = true;
        // 在签到本上标记这个同学“已签到”
        attendeeCount++;
        // 已签到人数加1
        
        emit AttendeeCheckedIn(attendee, block.timestamp);
        // 触发「有人签到」的通知，告诉所有人这个同学签到成功了
    }
    
    // 批量签到 (Gas优化)
    function batchCheckIn(
        address[] calldata attendees,
        uint8[] calldata v,
        bytes32[] calldata r,
        bytes32[] calldata s
    ) external eventActive {
        // 批量签到函数（一次给多个同学签到），活动有效才能用
        // 参数：attendees=同学地址列表，v/r/s=对应每个同学的班主任签名列表
        
        require(attendees.length == v.length, "Array length mismatch");
        // 检查同学数量和v签名数量一样多，不一样就提示“数量对不上”
        require(attendees.length == r.length, "Array length mismatch");
        // 检查同学数量和r签名数量一样多
        require(attendees.length == s.length, "Array length mismatch");
        // 检查同学数量和s签名数量一样多
        require(attendeeCount + attendees.length <= maxAttendees, "Would exceed capacity");
        // 检查批量签到后人数不超上限，超了就提示“会超过最大人数”
        
        for (uint256 i = 0; i < attendees.length; i++) {
            // 循环，一个一个处理每个同学
            address attendee = attendees[i];
            // 取出第i个同学的地址
            
            if (hasAttended[attendee]) continue;  // 跳过已签到的
            // 如果这个同学已经签过到，就跳过（不重复处理）
            
            bytes32 messageHash = keccak256(abi.encodePacked(
                attendee,
                address(this),
                eventName
            ));
            // 生成这个同学的“签到凭证码”
            
            bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                messageHash
            ));
            // 给凭证码加以太坊前缀
            
            address signer = ecrecover(ethSignedMessageHash, v[i], r[i], s[i]);
            // 反推这个同学签名的人是谁
            
            if (signer == organizer) {
                // 如果签名的是班主任
                hasAttended[attendee] = true;
                // 标记已签到
                attendeeCount++;
                //人数加1
                emit AttendeeCheckedIn(attendee, block.timestamp);
                // 触发签到通知
            }
        }
    }
    
    // 验证签名有效性 (不执行签到)
    function verifySignature(
        address attendee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool) {
        // 只验证签名是不是班主任的（不实际签到），返回true/false
        bytes32 messageHash = keccak256(abi.encodePacked(
            attendee,
            address(this),
            eventName
        ));
        // 生成签到凭证码
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));
        // 加以太坊前缀
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        // 反推签名者
        return signer == organizer;
        // 返回“是不是班主任签的”（true=是，false=不是）
    }
    
    // 获取消息哈希 (用于前端签名)
    function getMessageHash(address attendee) external view returns (bytes32) {
        // 给前端用的函数，生成某个同学的“签到凭证码”（方便班主任签名）
        return keccak256(abi.encodePacked(
            attendee,
            address(this),
            eventName
        ));
    }
    
    // 管理员功能
    function toggleEventStatus() external onlyOrganizer {
        // 只有班主任能操作的函数，切换活动状态（有效↔无效）
        isEventActive = !isEventActive;
        // 如果活动有效就改成无效，无效就改成有效（像开关灯）
        emit EventStatusChanged(isEventActive);
        // 触发「活动状态变更」的通知
    }
    
    function getEventInfo() external view returns (
        string memory name,
        uint256 date,
        uint256 maxCapacity,
        uint256 currentCount,
        bool active
    ) {
        // 查询活动信息的函数，所有人都能看，返回5个信息
        return (eventName, eventDate, maxAttendees, attendeeCount, isEventActive);
        // 返回活动名字、日期、最大人数、已签到人数、是否有效
    }
}