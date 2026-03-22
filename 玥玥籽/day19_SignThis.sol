// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SignThis {

    address public organizer;
    string public eventName;
    uint256 public eventDate;
    uint256 public maxAttendees;
    uint256 public attendeeCount;
    bool public isEventActive;

    mapping(address => bool) public hasAttended;
    mapping(bytes32 => bool) private _usedSignatures;

    event AttendeeCheckedIn(address indexed attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive);

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer");
        _;
    }

    modifier eventActive() {
        require(isEventActive, "Event not active");
        _;
    }

    constructor(string memory _eventName, uint256 _eventDate, uint256 _maxAttendees) {
        organizer = msg.sender;
        eventName = _eventName;
        eventDate = _eventDate;
        maxAttendees = _maxAttendees;
        isEventActive = true;
    }

    function getMessageHash(address _attendee, uint256 _deadline) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            address(this),
            eventName,
            _attendee,
            _deadline
        ));
    }

    function getEthSignedMessageHash(bytes32 _msgHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _msgHash));
    }

    function _verify(address _attendee, uint256 _deadline, uint8 v, bytes32 r, bytes32 s)
        internal view returns (bool)
    {
        bytes32 msgHash = getMessageHash(_attendee, _deadline);
        bytes32 ethHash = getEthSignedMessageHash(msgHash);
        address signer = ecrecover(ethHash, v, r, s);
        return signer == organizer;
    }

    function checkInWithSignature(
        address _attendee,
        uint256 _deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external eventActive {
        require(block.timestamp <= _deadline, "Signature has expired");
        require(attendeeCount < maxAttendees, "Event is full");
        require(!hasAttended[_attendee], "Already checked in");
        require(_verify(_attendee, _deadline, v, r, s), "Invalid signature");

        bytes32 sigHash = keccak256(abi.encodePacked(v, r, s));
        require(!_usedSignatures[sigHash], "Signature already used");
        _usedSignatures[sigHash] = true;

        hasAttended[_attendee] = true;
        attendeeCount++;
        emit AttendeeCheckedIn(_attendee, block.timestamp);
    }

    function batchCheckIn(
        address[] calldata _attendees,
        uint256[] calldata _deadlines,
        uint8[] calldata _v,
        bytes32[] calldata _r,
        bytes32[] calldata _s
    ) external eventActive {
        uint256 len = _attendees.length;
        require(len == _deadlines.length && len == _v.length && len == _r.length && len == _s.length,
            "Array length mismatch");
        require(attendeeCount + len <= maxAttendees, "Would exceed capacity");

        for (uint256 i = 0; i < len; i++) {
            address attendee = _attendees[i];
            if (hasAttended[attendee]) continue;
            if (block.timestamp > _deadlines[i]) continue;

            if (!_verify(attendee, _deadlines[i], _v[i], _r[i], _s[i])) continue;

            bytes32 sigHash = keccak256(abi.encodePacked(_v[i], _r[i], _s[i]));
            if (_usedSignatures[sigHash]) continue;

            _usedSignatures[sigHash] = true;
            hasAttended[attendee] = true;
            attendeeCount++;
            emit AttendeeCheckedIn(attendee, block.timestamp);
        }
    }

    function verifySignature(
        address _attendee,
        uint256 _deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool valid, bool expired) {
        return (
            _verify(_attendee, _deadline, v, r, s),
            block.timestamp > _deadline
        );
    }

    function toggleEventStatus() external onlyOrganizer {
        isEventActive = !isEventActive;
        emit EventStatusChanged(isEventActive);
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
