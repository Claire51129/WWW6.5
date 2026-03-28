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

    constructor(string memory _eventName, uint256 _eventDate, uint256 _maxAttendees) {
        eventName = _eventName;
        organizer = msg.sender;
        eventDate = _eventDate;
        maxAttendees = _maxAttendees;
        isEventActive = true;
        emit EventCreated(_eventName, _eventDate, _maxAttendees);
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer");
        _;
    }

    modifier eventActive() {
        require(isEventActive, "Event not active");
        _;
    }

    modifier withinCheckInWindow() {
        require(
            block.timestamp >= eventDate - 1 hours &&
            block.timestamp <= eventDate + 1 hours,
            "Not within check-in window"
        );
        _;
    }

    function checkInWithSignature(
        address attendee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external eventActive withinCheckInWindow {  
        require(attendeeCount < maxAttendees, "Event full");
        require(!hasAttended[attendee], "Already checked in");

        bytes32 messageHash = keccak256(abi.encodePacked(
            block.chainid,  
            attendee,
            address(this),
            eventName
        ));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));

        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        require(signer != address(0), "Invalid signature");  
        require(signer == organizer, "Invalid signature");

        hasAttended[attendee] = true;
        attendeeCount++;
        emit AttendeeCheckedIn(attendee, block.timestamp);
    }

    function batchCheckIn(
        address[] calldata attendees,
        uint8[] calldata v,
        bytes32[] calldata r,
        bytes32[] calldata s
    ) external eventActive withinCheckInWindow {  
        require(
            attendees.length == v.length &&
            attendees.length == r.length &&
            attendees.length == s.length,
            "Array length mismatch"
        );

        for (uint256 i = 0; i < attendees.length; i++) {
            address attendee = attendees[i];

        
            if (hasAttended[attendee]) continue;
            if (attendeeCount >= maxAttendees) break;

            bytes32 messageHash = keccak256(abi.encodePacked(
                block.chainid,  
                attendee,
                address(this),
                eventName
            ));
            bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                messageHash
            ));

            address signer = ecrecover(ethSignedMessageHash, v[i], r[i], s[i]);
            if (signer == address(0) || signer != organizer) continue;  

            hasAttended[attendee] = true;
            attendeeCount++;
            emit AttendeeCheckedIn(attendee, block.timestamp);
        }
    }

    function verifySignature(
        address attendee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(
            block.chainid,  
            attendee,
            address(this),
            eventName
        ));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        return signer != address(0) && signer == organizer;  
    }

    function getMessageHash(address attendee) external view returns (bytes32) {
        return keccak256(abi.encodePacked(
            block.chainid,  
            attendee,
            address(this),
            eventName
        ));
    }

    function toggleEventStatus() external onlyOrganizer {
        isEventActive = !isEventActive;
        emit EventStatusChanged(isEventActive);
    }

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