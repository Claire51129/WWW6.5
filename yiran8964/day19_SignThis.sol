// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SignThis {
    string public eventName;
    address public organizer;
    uint256 public eventDate;
    uint256 public maxAttendees;
    uint256 public attendeeCount;
    bool public isEventActive;

    mapping(address => bool) public hasAttended;

    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedId(address attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive);

    constructor(string memory _eventName, uint256 _maxAttendees) {
        eventName = _eventName;
        organizer = msg.sender;
        eventDate = block.timestamp;
        maxAttendees = _maxAttendees;
        isEventActive = true;

        emit EventCreated(eventName, eventDate, maxAttendees);
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can do this action");
        _;
    }

    modifier eventActive() {
        require(isEventActive, "Event not active");
        _;
    }

    function checkInWithSignature(address attendee, uint8 v, bytes32 r, bytes32 s) external eventActive {
        require(attendeeCount < maxAttendees, "Event full");
        require(!hasAttended[attendee], "Already checked in");

        require(verifySignature(attendee, v, r, s), "Invalid signature");
        hasAttended[attendee] = true;
        attendeeCount++;

        emit AttendeeCheckedId(attendee, block.timestamp);
    }

    function batchCheckIn(address[] calldata attendees, uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external eventActive {
        require(attendees.length == v.length, "Array length mismatch");
        require(attendees.length == r.length, "Array length mismatch");
        require(attendees.length == s.length, "Array length mismatch");
        require(attendeeCount + attendees.length <= maxAttendees, "Would exceed capacity");

        for(uint256 i=0; i<attendees.length;i++) {
            address attendee = attendees[i];
            
            if (verifySignature(attendee, v[i], r[i], s[i])) {
                hasAttended[attendee] = true;
                attendeeCount++;
                emit AttendeeCheckedId(attendee, block.timestamp);
            }
        }
    }

    function verifySignature(address attendee, uint8 v, bytes32 r, bytes32 s) public view returns(bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(attendee, address(this), eventName));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        
        return signer == organizer;
    }

    function getMessageHash(address attendee) external view returns(bytes32) {
        return keccak256(abi.encodePacked(attendee, address(this), eventName));
    }

    function getRSV(bytes memory _signature) external pure returns(bytes32,bytes32,uint8) {
        require(_signature.length == 65, "Invalid signature");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature,32))
            s := mload(add(_signature,64))
            v := byte(0,mload(add(_signature,96)))
        }

        if(v < 27) {
            v += 27;
        }

        return (r,s,v);
    }

    function toggleEventStatus() external onlyOrganizer {
        isEventActive = !isEventActive;
        emit EventStatusChanged(isEventActive);
    }

    function getEventInfo() external view returns(string memory name, uint256 date, uint256 maxCapacity, uint256 currentCount, bool active) {
        return (eventName, eventDate, maxAttendees, attendeeCount, isEventActive);
    }
}