// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "./Day17_SubscriptionStorageLayout.sol";
// Used for logical functions
contract SubscriptionLogicV2 is SubscriptionStorageLayout {
	function addPlan(uint8 planId, uint256 price, uint256 duration) external {
		planPrice[planId] = price;
		planDuration[planId] = duration;
	}
	function subscribe(uint8 planId) external payable {
		require(planPrice[planId] > 0, "Invalid plan");
		require(msg.value >= planPrice[planId], "Insufficent payment");
		Subscription storage s = subscriptions[msg.sender];
		if (block.timestamp < s.expiry) {
			s.expiry += planDuration[planId];
		}
		else {
			s.expiry = block.timestamp + planDuration[planId];
		}
		s.planId = planId;
		s.paused = false;
	}
	function isActive(address user) external view returns (bool) {
		Subscription memory s = subscriptions[user];
		return (block.timestamp < s.expiry && !s.paused);
	}
	function pauseAccount(address user) external {
		subscriptions[user].paused = true;
	}
	function resumeAccount(address user) external {
		subscriptions[user].paused = false;
	}
}