// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
contract EventEntry {
	string public eventName;
	address public organizer;
	uint256 public eventDate;
	uint256 public maxAttendees;
	uint256 public attendeeCount;
	bool public isEventActive;
	mapping(address => bool) public hasAttended;
	event EventCreated(string name, uint256 date, uint256 maxAttendees);
	event AttendeeCheckIn(address attendee, uint256 timestamp);
	event EventStatusChange(bool isActive);
	constructor(string memory _eventName, uint256 _eventDate_unix, uint256 _maxAttendee) {
		eventName = _eventName;
		eventDate = _eventDate_unix;
		maxAttendees = _maxAttendee;
		organizer = msg.sender;
		isEventActive = true;
		emit EventCreated(_eventName, _eventDate_unix, _maxAttendee);
	}
	modifier onlyOrganizer() {
		require(msg.sender == organizer, "Not organizer");
		_;
	}
	function setEventStatus(bool _isActive) external onlyOrganizer {
		isEventActive = _isActive;
		emit EventStatusChange(_isActive);
	}
	// Primitive signature info
	function getMessageHash(address _attendee) public view returns (bytes32) {
		return (keccak256(abi.encodePacked(address(this), eventName, _attendee)));
	}
	// Final signature info, with prefix
	function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
		return (keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)));
	}
	function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
		require(_signature.length == 65, "Invalid signature");
		bytes32 r;
		bytes32 s;
		uint8 v;
		assembly {
			// length (32)
			r := mload(add(_signature, 32))
			// signature (32)
			s := mload(add(_signature, 64))
			// v (32, but only use the first)
			v := byte(0, mload(add(_signature, 96)))
		}
		if (v < 27) {
			v += 27;
		}
		require(v == 27 || v == 28, "Invalid signature v value");
		return (ecrecover(_ethSignedMessageHash, v, r, s));
	}
	function verifySignature(address _attendee, bytes memory _signature) public view returns (bool) {
		bytes32 messageHash = getMessageHash(_attendee);
		bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
		return (recoverSigner(ethSignedMessageHash, _signature) == organizer);
	}
	function checkIn(bytes memory _signature) external {
		require(isEventActive, "Event is not active");
		require(block.timestamp <= eventDate + 1 days, "Event ended");
		require(!hasAttended[msg.sender], "Has already attended");
		require(attendeeCount < maxAttendees, "Maximum attendence reached");
		require(verifySignature(msg.sender, _signature), "Invalid signature");
		hasAttended[msg.sender] = true;
		attendeeCount++;
		emit AttendeeCheckIn(msg.sender, block.timestamp);
	}
}