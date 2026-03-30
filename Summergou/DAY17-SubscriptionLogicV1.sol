//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./DAY17-SubscriptionStorageLayout.sol";

contract SubscriptionLogicV1 is SubscriptionStorageLayout{
    function addPlan(uint8 _planID, uint256 _price, uint256 _duration) external{
        planPrices[_planID] = _price;
        planDuration[_planID] = _duration;
    }

    function subscribe(uint8 _planID) external payable{
        require(planPrices[_planID] > 0, "Invalide plan ID");
        require(msg.value > planPrices[_planID], "Insufficient payment");
        //"s" is a pointer, storage means this pointer point to a kind of data in the permenent memory part
        Subscription storage s = subscriptions[msg.sender];
        if (block.timestamp < s.expiry){
            s.expiry += planDuration[_planID];
        }
        else{
            s.expiry = block.timestamp + planDuration[_planID];
        }

        s.planID = _planID;
        s.paused = false;

    }

    function isPause(address _user) external view returns(bool){
        Subscription memory s = subscriptions[_user];
        return s.paused;
    }
}
