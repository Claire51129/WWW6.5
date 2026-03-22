// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * 教学用最小 Mock：与 CropInsurance 里 latestRoundData() 用法一致。
 * 不引用 Chainlink npm 包，Remix 单文件即可部署；answer 当作「降雨量」。
 */
contract Day18MockV3Aggregator {
    uint8 public immutable decimals;
    int256 public latestAnswer;
    uint80 public latestRoundId;

    constructor(uint8 _decimals, int256 _initialAnswer) {
        require(_initialAnswer >= 0, "use non-negative for rainfall mock");
        decimals = _decimals;
        latestAnswer = _initialAnswer;
        latestRoundId = 1;
    }

    function updateAnswer(int256 _answer) external {
        require(_answer >= 0, "use non-negative");
        latestAnswer = _answer;
        unchecked {
            latestRoundId++;
        }
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        roundId = latestRoundId;
        answer = latestAnswer;
        uint256 ts = block.timestamp;
        if (ts == 0) ts = 1;
        startedAt = ts;
        updatedAt = ts;
        answeredInRound = latestRoundId;
    }
}