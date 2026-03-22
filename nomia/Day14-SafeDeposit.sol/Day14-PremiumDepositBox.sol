//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "./Day14-BaseDepositBox.sol";

//高级版子合约
contract PremiumDepositBox is BaseDepositBox{

    string private metadata;
    event MetadataUpdated(address indexed owner);

    constructor(address _owner, address _manager) BaseDepositBox(_owner, _manager) {}

    function getBoxType() override public pure returns(string memory){
        return "Premium";
    } 


    function setMetadata(string calldata _metadata) external onlyOwner{
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }

    function getMetadata() external view onlyOwner returns(string memory){
        return metadata;
    }


}