//SPDX-License-Identifier: MIT
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
    require(msg.sender == organizer, "Only organizer can perform this action");
    _;
  }

  function setEventStatus(bool _isActive) external onlyOrganizer {
    isEventActive = _isActive;
    emit EventStatusChanged(_isActive);
  }

  function getMessageHash(address _attendee) public view returns (bytes32) {
    return keccak256(abi.encodePacked(address(this), _attendee));
  }

  function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
  }

  function verifySignature(address _attendee, bytes memory _signature) public view returns (bool) {
    bytes32 messageHash = getMessageHash(_attendee);
    bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
    return recoverSigner(ethSignedMessageHash, _signature) == organizer;
  }

  function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
    //standard signature length is 65 bytes (r(32), s(32), v(1))
    require(_signature.length == 65, "Invalid signature length");
    bytes32 r;
    bytes32 s;
    uint8 v;

    //low-level assembly to extract r, s, v from the signature
    assembly {
      r := mload(add(_signature, 32)) //first 32 bytes after the length prefix
      s := mload(add(_signature, 64)) //next 32 bytes
      v := byte(0, mload(add(_signature, 96))) //last byte, byte(0, ...) extracts the first byte of the loaded word
    }
    //normalize v to be 27 or 28
    if (v < 27) {
      v += 27;
    }

    require(v == 27 || v == 28, "Invalid signature version");
    //ecrecover returns the address that signed the message
    return ecrecover(_ethSignedMessageHash, v, r, s);
  }

  function checkIn(bytes memory _signature) external {
    require(isEventActive, "Event is not active");
    require(block.timestamp < eventDate, "Event has already occurred");
    require(attendeeCount < maxAttendees, "Event is at full capacity");
    require(!hasAttended[msg.sender], "Attendee has already checked in");
    require(verifySignature(msg.sender, _signature), "Invalid signature");

    hasAttended[msg.sender] = true;
    attendeeCount++;

    emit AttendeeCheckedIn(msg.sender, block.timestamp);
  }
}