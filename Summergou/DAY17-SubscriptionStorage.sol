//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import "./DAY17-SubscriptionStorageLayout.sol";

//proxy contract in charge of storage
contract SubscriptionStorage is SubscriptionStorageLayout{

    constructor(address _logicContract){
        owner = msg.sender;
        logicContract = _logicContract;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner,"only owner can perform this action");
        _;
    }

    function upgradeTo(address _newLogic) external onlyOwner{
        logicContract = _newLogic;
    }

    fallback() external payable{
        address impl = logicContract;
        require(impl != address(0), "Logic contract not set");

        //the magic
        assembly {
            calldatacopy(0,0,calldatasize())
            let result := delegatecall(gas(),impl,0,calldatasize(),0,0)
            returndatacopy(0,0,returndatasize())

            switch result
            case 0 {revert(0,returndatasize())}
            default {return (0,returndatasize())}
        }

    }


    receive() external payable{}
} 
