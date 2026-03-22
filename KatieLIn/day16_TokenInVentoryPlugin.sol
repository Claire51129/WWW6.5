// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenInventoryPlugin {
    address public pluginStore;
    struct NFTItem {
        address contractAddress; 
        uint256 tokenId;        
    }

    mapping(address => mapping(uint256 => NFTItem)) public inventory;
    mapping(address => uint256) public itemCount;
    constructor(address _pluginStore) {
        pluginStore = _pluginStore;
    }
    modifier onlyPluginStore() {
        require(msg.sender == pluginStore, "Not authorized");
        _;
    }

    function addItem(address user, address contractAddress, uint256 tokenId) public onlyPluginStore {
        uint256 slot = itemCount[user];        
        inventory[user][slot] = NFTItem(contractAddress, tokenId);
        itemCount[user]++;                     
    }
    function getItem(address user, uint256 slot) public view returns (address, uint256) {
        NFTItem memory item = inventory[user][slot];
        return (item.contractAddress, item.tokenId);
    }

    function getItemCount(address user) public view returns (uint256) {
        return itemCount[user];
    }
}