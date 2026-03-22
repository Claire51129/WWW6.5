//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 
//接口，调用她的合约都遵循她的规则，让大家共读一本说明书
interface IDepositBox {

    function getOwner() external view returns(address);
    function transferOwnership(address newOwner)external;
    function storeSecret(string calldata secret)external;
    function getSecret() external view returns (string memory);
    function getBoxType() external pure returns(string memory);
    function getDepositTime() external view returns(uint256);
}
