// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Day20_YieldFarm
 * @dev Logic: Staking for Reward Token issuance
 */
contract Day20_YieldFarm is Ownable, ReentrancyGuard {
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    address[] public stakers;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsIssued(uint256 totalParticipants);

    constructor(IERC20 _stakingToken, IERC20 _rewardToken) Ownable(msg.sender) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
    }

    /**
     * @dev Deposit tokens for yield
     */
    function stakeTokens(uint256 _amount) public nonReentrant {
        require(_amount > 0, "Amount must be > 0");

        stakingToken.transferFrom(msg.sender, address(this), _amount);
        stakingBalance[msg.sender] += _amount;

        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;

        emit Staked(msg.sender, _amount);
    }

    /**
     * @dev Withdraw principal tokens
     */
    function unstakeTokens() public nonReentrant {
        uint256 balance = stakingBalance[msg.sender];
        require(balance > 0, "No balance to unstake");

        stakingToken.transfer(msg.sender, balance);
        stakingBalance[msg.sender] = 0;
        isStaking[msg.sender] = false;

        emit Unstaked(msg.sender, balance);
    }

    /**
     * @dev Admin function: Mint/Distribute rewards
     * Logic: Reward = Stake * 10%
     */
    function issueRewards() public onlyOwner {
        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint256 balance = stakingBalance[recipient];
            if (balance > 0) {
                rewardToken.transfer(recipient, balance / 10);
            }
        }
        emit RewardsIssued(stakers.length);
    }
}
