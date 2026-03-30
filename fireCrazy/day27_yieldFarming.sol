// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract YieldFarming {
    struct StakerInfo {
        uint256 stakedAmount;
        uint256 rewardDebt;
        uint256 lastUpdateTime;
    }

    IERC20 public stakingToken;
    IERC20 public rewardToken;
    uint256 public rewardRatePerSecond;

    mapping(address => StakerInfo) public stakers;

    constructor(address _stake, address _reward, uint256 _rate) {
        stakingToken = IERC20(_stake);
        rewardToken = IERC20(_reward);
        rewardRatePerSecond = _rate;
    }

    function _updateRewards(address user) internal {
        StakerInfo storage staker = stakers[user];
        if (staker.stakedAmount > 0) {
            uint256 timeElapsed = block.timestamp - staker.lastUpdateTime;
            uint256 pending = staker.stakedAmount * rewardRatePerSecond * timeElapsed;
            staker.rewardDebt += pending;
        }
        staker.lastUpdateTime = block.timestamp;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount error");
        _updateRewards(msg.sender);
        bool success = stakingToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");
        stakers[msg.sender].stakedAmount += amount;
    }

    function claimRewards() external {
        _updateRewards(msg.sender);
        uint256 reward = stakers[msg.sender].rewardDebt;
        require(reward > 0, "No rewards");
        stakers[msg.sender].rewardDebt = 0;
        bool success = rewardToken.transfer(msg.sender, reward);
        require(success, "Reward failed");
    }
}
