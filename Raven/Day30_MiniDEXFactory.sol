// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Day30_MiniDEXPair.sol";

contract MiniDexFactory is Ownable {
	event PairCreated(address indexed tokenA, address indexed tokenB, address pairAddress, uint);
	address[] public allPairs;
	mapping(address => mapping(address => address)) public getPair;
	constructor(address _owner) Ownable(_owner) {}
	// Create new pair for each 2 tokens
	function createPair(address _tokenA, address _tokenB) external onlyOwner returns (address pair) {
		require(_tokenA != address(0) && _tokenB != address(0), "Invalid token");
		require(_tokenA != _tokenB, "Identical token");
		require(getPair[_tokenA][_tokenB] == address(0), "Pair existed");
		(address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
		pair = address(new MiniDexPair(token0, token1));
		// Both orders point to same address
		getPair[token0][token1] = pair;
		getPair[token1][token0] = pair;
		allPairs.push(pair);
		emit PairCreated(token0, token1, pair, allPairs.length - 1);
	}
	    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function getPairAtIndex(uint index) external view returns (address) {
        require(index < allPairs.length, "Index out of bounds");
        return allPairs[index];
    }
}