//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract EventEntery{
    string public eventName;
    address public organizer;
    uint256 public enventDate;
    uint256 public maxAttendees;
    uint256 public attendeeCount;
    bool public isEventActive;

    //is this mapping take the storage?
    mapping(address => bool) public hasAttended;

    event eventCreated(string eventName, uint256 enventDate, uint256 maxAttendees);
    event attendeeCheckin(address attendee, uint256 timestamp);
    event eventStatusChanged(bool isActive);

    constructor(string memory _eventName, uint256 _eventDate_uinx, uint256 _maxAttendees){
        eventName = _eventName;
        organizer = msg.sender;
        enventDate = _eventDate_uinx;
        maxAttendees = _maxAttendees;
        isEventActive = true;

        emit eventCreated(_eventName, _eventDate_uinx,_maxAttendees);
    }

    modifier onlyOrganizer(){
        require(msg.sender == organizer, "only organizer can perform this action");
        _;
    }

    function setEventStatus(bool _isActive) external onlyOrganizer{
        isEventActive = _isActive;
        emit eventStatusChanged(_isActive);
    }

    //why we do this step?
    //preparing for the next step!
    function getMessageHash(address _attendee) public view returns(bytes32){
        return keccak256(abi.encodePacked(address(this),eventName,_attendee));
    }

    /**It is an "anti-counterfeiting label machine". 
    *You input an original message fingerprint, and it firmly stamps the anti-counterfeiting seal "Ethereum Certified: This is a regular message signature, not a transaction instruction" on this fingerprint, and then outputs a new fingerprint with the seal affixed. 
    *In this way, your signature becomes secure and exclusive, and cannot be misused elsewhere for malicious purposes. This is a very smart design by Ethereum to protect users!**/
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns(bytes32){
         return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",_messageHash)); //"\x19Ethereum Signed Message:\n32" is special
    }

    function verifySignature(address _attendee, bytes memory _signature) public view returns(bool){
        bytes32 MessageHash = getMessageHash(_attendee);
        bytes32 EthSignedMessageHash = getEthSignedMessageHash(MessageHash);
        return recoverSigner(EthSignedMessageHash, _signature) == organizer;
    }
    //where can attendees get the _signature?
    function recoverSigner(bytes32 _EthSignedMessageHash, bytes memory _signature) public pure returns(address){
        //it should be 65
        require(_signature.length == 65,"Invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly{
            r := mload(add(_signature,32))
            s := mload(add(_signature,64)) 
            v := byte(0,mload(add(_signature,96)))
            }

            if(v < 27){
                v+=27;
            }

            require(v==27 || v==28, "Invalid signature v value");

            return ecrecover(_EthSignedMessageHash, v, r, s);
    }

    function checkIn(bytes memory _signature)external{
        require(isEventActive, "Event is not active");
        require(block.timestamp <= enventDate + 1 days, "Event has ended");
        require(!hasAttended[msg.sender], "Attendee has already checked in");
        require(attendeeCount < maxAttendees, "Maximum attendees reached");
        require(verifySignature(msg.sender, _signature), "Invalid signature");

        hasAttended[msg.sender] = true;
        attendeeCount++;
        emit attendeeCheckin(msg.sender, block.timestamp);
    }



}

//guest:0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2