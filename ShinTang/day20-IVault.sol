// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IVault {
    function deposit() external payable;

    function vulnerableWithdraw() external;

    function safeWithdraw() external;
}
