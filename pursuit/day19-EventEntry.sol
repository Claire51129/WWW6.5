// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EventEntry {
    string public eventName;
    address public organizer;
    uint256 public eventDate;
    uint256 public maxAttendees;
    uint256 public attendeeCount;
    bool public isEventActive;

    mapping(address => bool) public hasAttended;

    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive);

    constructor(string memory _eventName, uint256 _eventDate_unix, uint256 _maxAttendees) {
        eventName = _eventName;
        eventDate = _eventDate_unix;
        maxAttendees = _maxAttendees;
        organizer = msg.sender;
        isEventActive = true;

        emit EventCreated(_eventName, _eventDate_unix, _maxAttendees);
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the event organizer can call this function");
        _;
    }

    function setEventStatus(bool _isActive) external onlyOrganizer {
        isEventActive = _isActive;
        emit EventStatusChanged(_isActive);
    }

    function getMessageHash(address _attendee) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), eventName, _attendee));
    }
    /** getMessageHash：【消息哈希】
        这部分负责定义你要对什么内容签名。
            abi.encodePacked(...)：将多个变量（合约地址、事件名称、参与者地址）紧凑地打包成一串二进制数据。
            address(this) 的妙用：在哈希里包含当前合约地址是为了防止重放攻击（Replay Attack）。如果没有它，黑客可能拿着你在 A 合约的签名，去 B 合约里尝试领取同样的奖励。
            keccak256：将其转换成一个固定的 32 字节哈希值。这就像是生成了这封信的“指纹”。
     */

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }
    /** getEthSignedMessageHash：获取原始消息哈希并添加以太坊特有前缀，再次哈希处理 —— 【以太坊签名消息哈希】，它是像 MetaMask 这样的钱包在你调用 eth_sign 时使用的确切格式。
        为什么不能直接对上面的哈希签名，非要再套一层？
            加上 "\x19Ethereum Signed Message:\n32"是为了安全性。如果没有这个前缀，恶意网站可能会诱骗你签名一段看似杂乱无章的数据，但那段数据其实是一笔转账交易的代码。
            防止身份冒充：以太坊钱包（如 MetaMask）在请求签名时，会自动给消息加上这段前缀。如果合约在验证时不加上同样的前缀，ecrecover 就无法匹配出正确的地址。
            32 的含义：这代表后面跟着的消息长度是 32 字节（即上一步生成的 bytes32 哈希）。
     */

    function verifySignature(address _attendee, bytes memory _signature) public view returns (bool) {
        bytes32 messageHash = getMessageHash(_attendee);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash); // 根据来访者地址创建消息哈希
        return recoverSigner(ethSignedMessageHash, _signature) == organizer; // 恢复/提取签名者地址，与组织者地址作比较
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        require(_signature.length == 65, "Invalid signature length"); // 第 1 步：检查签名长度。所有以太坊签名的**长度都是 65 字节** ——不多也不少。如果它更短或更长，则可能是损坏的、不完整的或假的。所以如果长度不对，我们会立即停止。

        bytes32 r;
        bytes32 s;
        uint8 v;
        // 第 2 步：将签名分成 3 个部分。以太坊签名不仅仅是一大块——它们由 3 个部分组成，称为：`r`（32 字节）；`s`（32 字节）；`v`（1 字节）。这三个值协同工作，以**数学方式证明谁签署了邮件** 。

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }
        /* 第 3 步：使用程序集提取这些值。
        汇编是一种直接从内存访问数据的低级方法。
        可以把它想象成挖一个盒子，准确地拿出我们需要的东西。
        我们说：
        “嘿以太坊，给我从位置 32 开始的前 32 个字节。那是 `r`。
        “现在给我接下来的 32 字节，从 64 开始。那是`s` 。
        “最后给我位置 96 的 1 字节。那是 `v`。
        */

        if (v < 27) {
            v += 27;
        }
        // 第 4 步：根据需要修复 V 值。有时，不同的钱包或系统会给你一个 `v` 值，即 0 或 1。但以太坊预计是 27 或 28。所以我们只是在需要时进行调整。

        require(v == 27 || v == 28, "Invalid signature 'v' value");
        // 第 5 步：验证 v 现在是否正确。我们确保 v 是 27 或 28 - 其他任何东西都是不可接受的。如果是其他任何东西，我们会抛出错误，因为我们不能信任签名。

        return ecrecover(_ethSignedMessageHash, v, r, s);
        // 第 6 步：恢复签名者的地址。`ecrecover`——一个内置的以太坊函数，它采用：签名消息哈希 和 签名值 （`v、r、s`）。它返回：签名者的地址。
    }

    function checkIn(bytes memory _signature) external {
        require(isEventActive, "Event is not active");
        require(block.timestamp <= eventDate + 1 days, "Event has ended");
        require(!hasAttended[msg.sender], "Attendee has already checked in");
        require(attendeeCount < maxAttendees, "Maximum attendees reached");
        require(verifySignature(msg.sender, _signature), "Invalid signature");

        hasAttended[msg.sender] = true;
        attendeeCount++;

        emit AttendeeCheckedIn(msg.sender, block.timestamp);
    }
}

/** 逻辑梳理：数字邀请函的生成与核验
1. 制作信封（Hash）： 【 _attendee address > _attendee Hash 】
组织者在后台针对特定的参与者 _attendee 地址，生成一个独特的哈希值。这确保了这张“邀请函”只能给这个人用，别人拿去没用。

2. 盖上私章（Sign）： 【 organizer私钥 + _attendee Hash > _signature 】
组织者用自己的私钥对这个哈希进行签名。这个生成的 _signature 就是“防伪涂层”。

3. 发放门票：
组织者通过链下（比如邮件、微信、App）把这个 _signature 发送给参与者。

4. 入场核销（Check-in）：
参与者来到现场，调用chekcIn函数，并出示 _signature。合约此时化身“验票员”：
    重新算一遍：用 msg.sender（来访者地址）当场再算一个哈希。 【 来访者address > 来访者Hash 】 
    反向推导：用这个哈希和来访者提供的签名，通过 ecrecover 倒推签名者。 【 _signature + 来访者Hash > 签名者私钥 】 
    比对身份：比对签名者地址与 organizer（组织者）地址，一致则说明这张票是真的。 【 签名者私钥 vs organizer私钥】
 */