// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import { Ownable } from "./day11-Ownable.sol";
contract VaultMaster is Ownable{
    event DepositSuccessful(address indexed account, uint256 value);
    event WithdrawSuccessful(address indexed recipient, uint256 value);
    uint256 public totalTipsReceived; 
    string[] public supportedCurrencies;
    function deposit()public payable {
        require(msg.value>0,"Enter a valid number");
        emit DepositSuccessful(msg.sender,msg.value);
    }
    function getBalance()public view returns(uint256){
        return address(this).balance;
    }
    function withdraw(address _to, uint256 _amount)public onlyOwner{
        require(_amount<=getBalance(),"Insufficent Balance");
        (bool success, )=payable (_to).call{value:_amount}("");
        require(success,"Transfer Failed");
        emit WithdrawSuccessful(_to,_amount);
    }
    function withdrawTips()public onlyOwner{
        uint256 contractBalance=address(this).balance;
        require(contractBalance>0,"No tips to withdraw");
        (bool success, )=payable (ownerAddress()).call{value:contractBalance}("");
        require(success,"Transfer failed");
        totalTipsReceived=0;
    }
    function getSupportedCurrencies()public view returns (string[]memory){
        return supportedCurrencies;
    }
    function getContractBalance()public view returns (uint256){
        return address(this).balance;
    }
}
