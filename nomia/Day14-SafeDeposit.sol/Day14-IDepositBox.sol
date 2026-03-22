//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

//金库接口 记录金库的功能 只是函数声明
interface IDepositBox {

    function getOwner() external view returns(address);
    function transferOwnership(address newOwner)external;
    function storeSecret(string calldata secret)external;
    function getSecret() external view returns (string memory);
    function getBoxType() external pure returns(string memory);
    function getDepositTime() external view returns(uint256);


}