// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./day17_SubscriptionStorageLayout.sol";
contract SubscriptionStorage is SubscriptionStorageLayout {
    
    event Upgraded(address indexed newLogic);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _logicContract) {
        require(_logicContract != address(0), "Invalid logic address");
        owner = msg.sender;
        logicContract = _logicContract;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function upgradeTo(address _newLogic) external onlyOwner {
        require(_newLogic != address(0), "Invalid logic address");
        require(_newLogic != logicContract, "Already using this logic");
        logicContract = _newLogic;
        emit Upgraded(_newLogic);
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        require(_newOwner != owner, "Already the owner");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
    
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    fallback() external payable {
        address impl = logicContract;
        require(impl != address(0), "Logic contract not set");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}