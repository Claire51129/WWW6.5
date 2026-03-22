// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "./Day17_SubscriptionStorageLayout.sol";
// Used for data storage
contract SubscriptionStorage is SubscriptionStorageLayout {
	modifier onlyOwner() {
		require(msg.sender == owner, "Not owner");
		_;
	}
	constructor(address _logicContract) {
		owner = msg.sender;
		logicContract = _logicContract;
	}
	function upgradeTo(address _newLogic) external onlyOwner {
		logicContract = _newLogic;
	}
	// Call this function when functions outside this contract get called
	fallback() external payable {
		address impl = logicContract;
		require(impl != address(0), "Invalid logic contract");
		// Assembly uses Yul language
		assembly {
			// calldatacopy(t, f, s):
			// t-start pos of memory
			// f-start pos of calldata
			// s-byte size of data
			calldatacopy(0, 0, calldatasize())
			// delegatecall(g, a, in, insize, out, outsize)
			// g-all gas left
			// a-address of logic contract
			// in-start pos of input in memory
			// insze-size of input data
			// out-start pos of output in buffer
			// outsize-size of output data
			// result-return value
			// Call functions in logic contract but store data in this contract
			let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
			// returndatacopy(t, f, s)
			// t-start pos of memory
			// f-start pos of return data
			// s-size of return data
			returndatacopy(0, 0, returndatasize())
			switch result
			// Failed
			case 0 {
				revert(0, returndatasize())
			}
			// Success
			default {
				// return data from 0 to datasize()
				return(0, returndatasize())
			}
		}
	}
	receive() external payable {}
}