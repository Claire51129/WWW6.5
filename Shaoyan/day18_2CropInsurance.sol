// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day18_1MockWeatherOracle.sol";

contract CropInsurance {
    struct Policy {
        address farmer;
        string location;
        uint256 premium;
        uint256 payout;
        bool active;
        bool claimed;
    }

    uint256 public policyCount;
    mapping(uint256 => Policy) public policies;

    MockWeatherOracle public oracle;
    address public owner;

    event PolicyPurchased(uint256 policyId, address farmer);
    event ClaimPaid(uint256 policyId, address farmer, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _oracle) {
        owner = msg.sender;
        oracle = MockWeatherOracle(_oracle);
    }

    // 购买保险
    function buyPolicy(
        string memory location,
        uint256 payout
    ) external payable {
        require(msg.value > 0, "Premium required");

        policyCount++;

        policies[policyCount] = Policy({
            farmer: msg.sender,
            location: location,
            premium: msg.value,
            payout: payout,
            active: true,
            claimed: false
        });

        emit PolicyPurchased(policyCount, msg.sender);
    }

    // 触发赔付（根据天气）
    function claim(uint256 policyId) external {
        Policy storage p = policies[policyId];

        require(p.active, "Policy inactive");
        require(!p.claimed, "Already claimed");
        require(msg.sender == p.farmer, "Not policy owner");

        bool drought = oracle.getWeather(p.location);

        require(drought, "No drought, no payout");

        p.claimed = true;
        p.active = false;

        (bool success, ) = payable(p.farmer).call{value: p.payout}("");
        require(success, "Transfer failed");

        emit ClaimPaid(policyId, p.farmer, p.payout);
    }

    // 合约充值（用于赔付）
    function fundContract() external payable onlyOwner {}

    // 查询保单
    function getPolicy(uint256 policyId)
        external
        view
        returns (Policy memory)
    {
        return policies[policyId];
    }
}
