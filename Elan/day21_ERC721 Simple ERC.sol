// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SimpleNFT
 * @dev 一个基础的 ERC721 NFT 合约实现。
 * 包含基础的铸造功能和所有者管理。
 */
contract SimpleNFT is ERC721, Ownable {
    uint256 private _nextTokenId;

    // 事件：当新 NFT 被铸造时触发
    event NFTMinted(address indexed owner, uint256 indexed tokenId);

    /**
     * @dev 构造函数：设置代币名称和符号
     * 注意：OpenZeppelin 5.0+ 需要在 Ownable 构造函数中传入初始所有者地址
     */
    constructor(string memory name, string memory symbol) 
        ERC721(name, symbol) 
        Ownable(msg.sender) 
    {
        _nextTokenId = 1; // 从 ID 1 开始递增
    }

    /**
     * @notice 铸造一个新的 NFT 给调用者
     * @dev 只有合约所有者可以铸造（如果想让所有人铸造，可以删掉 onlyOwner）
     */
    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        
        emit NFTMinted(to, tokenId);
    }

    /**
     * @dev 返回该代币的 URI（通常指向元数据 JSON 地址）
     * 实际开发中通常需要重写此函数以对接 IPFS 地址
     */
    function _baseURI() internal pure override returns (string memory) {
        return "https://api.example.com/metadata/";
    }
}