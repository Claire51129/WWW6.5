// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract ClickCounter {
	uint256 public counter;
	// increase counter
	function click() public
	{
		counter++;
	}
	// reset counter
	function reset() public
	{
		counter = 0;
	}
	// decrease counter
	function decrease() public
	{
		// if (counter > 0)
		// "if" will complete transaction silently
		// "require" will revert and return gas fee
		// better use "require"
		require(counter > 0, "Counter is already 0");
		counter--;
	}
	// getter (unnecessary when counter is public)
	function getCounter() public view returns (uint256) {
		return (counter);
	}
	// multiple increases in 1 click
	// save more gas fee than click()
	function clickMultiple(uint256 times) public {
		require(times > 0, "times must be positive");
		counter += times;
	}
}