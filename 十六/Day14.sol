// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface definition for cross-contract interaction
 */
interface IVault {
    function deposit() external payable;
    function withdraw(uint256 _amount) external;
    function getBalance(address _user) external view returns (uint256);
}

/**
 * @dev Implementation of the target contract
 */
contract SimpleVault {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");
    }

    function getBalance(address _user) public view returns (uint256) {
        return balances[_user];
    }
}

/**
 * @dev Logic for interacting with external contracts using Interfaces and Low-level calls
 */
contract InteractionController {
    
    // 1. Interface Interaction
    function vaultDeposit(address _vaultAddress) public payable {
        IVault(_vaultAddress).deposit{value: msg.value}();
    }

    // 2. Low-level Call Interaction
    function lowLevelDeposit(address _vaultAddress) public payable returns (bool) {
        (bool success, ) = _vaultAddress.call{value: msg.value}(
            abi.encodeWithSignature("deposit()")
        );
        return success;
    }

    // 3. Delegatecall Interaction
    // Note: This executes target logic within the context of the caller's storage
    uint256 public mockBalance; 
    function delegateDeposit(address _vaultAddress) public payable returns (bool) {
        (bool success, ) = _vaultAddress.delegatecall(
            abi.encodeWithSignature("deposit()")
        );
        return success;
    }

    function checkRemoteBalance(address _vaultAddress, address _user) public view returns (uint256) {
        return IVault(_vaultAddress).getBalance(_user);
    }

    receive() external payable {}
}
