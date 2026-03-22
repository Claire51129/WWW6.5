// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockWeatherOracle {
    address public owner;

    // location => weather condition
    mapping(string => bool) public isDrought;

    event WeatherUpdated(string location, bool drought);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // 设置天气（true = 干旱，false = 正常）
    function setWeather(string memory location, bool drought) external onlyOwner {
        isDrought[location] = drought;
        emit WeatherUpdated(location, drought);
    }

    // 查询天气
    function getWeather(string memory location) external view returns (bool) {
        return isDrought[location];
    }
}