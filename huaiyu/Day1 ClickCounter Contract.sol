// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter {
    // stored click count
    uint256 private count;

    constructor() {
        count = 0;
    }

    /// @notice increment the click counter by one
    function increment() external {
        count += 1;
    }

    /// @notice reset the counter to zero
    function reset() external {
        count = 0;
    }

    /// @notice view current click count
    /// @return the number of clicks recorded
    function getCount() external view returns (uint256) {
        return count;
    }
}
