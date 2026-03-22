//SPDX-License-Identifier:MIT

pragma solidity 0.8.34;

contract GoldVault{

    mapping(address => uint256) goldBalance;

    //Reentrancy lock step
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    constructor(){
        _status = _NOT_ENTERED;
    }

    //custom nonReentrant modifier: Lock the withdraw function during execution
    modifier nonReentrant(){
        require(_status!= _ENTERED,"Reentrant call blocked");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    function deposit() external payable {
        require(msg.value>0, "Deposit must be more than 0");
        goldBalance[msg.sender] += msg.value;
    }

    function vulnerableWithdraw()external{
        uint256 amount = goldBalance[msg.sender];
        require(amount>0,"Nothing to withdraw");

        (bool success,) = msg.sender.call{value: amount}("");

        require (success, "withdraw failed");

        goldBalance[msg.sender] = 0;        
    }

    //safe principle: check - effect(change) - interface, interface must be after effect
    function safeWithdraw()external nonReentrant{
        uint256 amount = goldBalance[msg.sender];
        require(amount>0,"Nothing to withdraw");

        goldBalance[msg.sender] = 0;   
        
        (bool success,) = msg.sender.call{value: amount}("");

        require (success, "withdraw failed");
    }

    
}
