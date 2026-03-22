// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Day21_Day22_NFT_Metadata
 * @dev Implementation of ERC721 with Metadata URI management
 */
contract ShiliuNFT is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    // Base URI for IPFS or centralized server metadata
    string private _baseTokenURI;

    event NFTMinted(address indexed owner, uint256 indexed tokenId, string uri);

    constructor(string memory baseURI) 
        ERC721("Shiliu Collectible", "SLC") 
        Ownable(msg.sender) 
    {
        _baseTokenURI = baseURI;
    }

    /**
     * @dev Internal function to return the base URI
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Minting function - Restricted to Owner
     * @param to Recipient address
     * @param uri Metadata json path (e.g., "1.json")
     */
    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        emit NFTMinted(to, tokenId, uri);
    }

    /**
     * @dev Admin function to update Base URI
     */
    function setBaseURI(string memory newBaseURI) public onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    // Required overrides for Solidity inheritance
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
