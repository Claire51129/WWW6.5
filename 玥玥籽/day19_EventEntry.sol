// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventEntry {

    address public organizer;
    string public eventName;
    uint256 public eventDate;
    uint256 public maxAttendees;
    uint256 public attendeeCount;
    bool public isEventActive;

    mapping(address => bool) public hasAttended;
    mapping(address => bool) public isVIP;

    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedIn(address indexed attendee, bool isVip, uint256 timestamp);
    event EventStatusChanged(bool isActive);

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer");
        _;
    }

    constructor(string memory _eventName, uint256 _eventDate, uint256 _maxAttendees) {
        organizer = msg.sender;
        eventName = _eventName;
        eventDate = _eventDate;
        maxAttendees = _maxAttendees;
        isEventActive = true;
        emit EventCreated(_eventName, _eventDate, _maxAttendees);
    }

    function setEventStatus(bool _isActive) external onlyOrganizer {
        isEventActive = _isActive;
        emit EventStatusChanged(_isActive);
    }

    function getMessageHash(address _attendee, bool _isVIP) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), eventName, _attendee, _isVIP));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function verifySignature(
        address _attendee,
        bool _isVIP,
        bytes memory _signature
    ) public view returns (bool) {
        bytes32 msgHash = getMessageHash(_attendee, _isVIP);
        bytes32 ethHash = getEthSignedMessageHash(msgHash);
        return _recoverSigner(ethHash, _signature) == organizer;
    }

    function _recoverSigner(bytes32 _ethSignedHash, bytes memory _sig) internal pure returns (address) {
        require(_sig.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }

        if (v < 27) v += 27;
        require(v == 27 || v == 28, "Invalid v value");

        return ecrecover(_ethSignedHash, v, r, s);
    }

    function checkIn(bool _isVIP, bytes memory _signature) external {
        require(isEventActive, "Event is not active");
        require(block.timestamp <= eventDate + 1 days, "Event has ended");
        require(!hasAttended[msg.sender], "Already checked in");
        require(attendeeCount < maxAttendees, "Event is full");
        require(verifySignature(msg.sender, _isVIP, _signature), "Invalid signature");

        hasAttended[msg.sender] = true;
        if (_isVIP) isVIP[msg.sender] = true;
        attendeeCount++;

        emit AttendeeCheckedIn(msg.sender, _isVIP, block.timestamp);
    }

    function getEventInfo() external view returns (
        string memory name,
        uint256 date,
        uint256 capacity,
        uint256 checkedIn,
        bool active
    ) {
        return (eventName, eventDate, maxAttendees, attendeeCount, isEventActive);
    }
}
