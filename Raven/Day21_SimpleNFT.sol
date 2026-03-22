// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
interface IERC721 {
	event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
	event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
	event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
	function balanceOf(address owner) external view returns (uint256);
	function ownerOf(uint256 tokenId) external view returns (address);
	function approve(address to, uint256 tokenId) external;
	function getApproved(uint256 tokenId) external view returns (address);
	function setApprovalForAll(address operator, bool approved) external;
	function isApprovalForAll(address owner, address operator) external view returns (bool);
	function transferFrom(address from, address to, uint256 tokenId) external;
	// Different override versions
	function safeTransferFrom(address from, address to, uint256 tokenId) external;
	function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}
interface IERC721Receiver {
	function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}
contract SimpleNFT is IERC721 {
	string public name;
	string public symbol;
	// tokenId starts from 1
	uint256 private _tokenCounter = 1;
	mapping(uint256 => address) private _owners;
	mapping(address => uint256) private _balance;
	mapping(uint256 => address) private _tokenApproval;
	mapping(address => mapping(address => bool)) private _operatorApproval;
	mapping(uint256 => string) private _tokenURI;
	constructor(string memory name_, string memory symbol_) {
		name = name_;
		symbol = symbol_;
	}
	// Number of NFT each address has
	function balanceOf(address owner) public view override returns (uint256) {
		require(owner != address(0), "Invalid address");
		return (_balance[owner]);
	}
	// Owner of each NFT
	function ownerOf(uint256 tokenId) public view override returns (address) {
		address owner = _owners[tokenId];
		require(owner != address(0), "Invalid address");
		return (owner);
	}
	// Approve other to operate a single NFT
	function approve(address to, uint256 tokenId) public override {
		address owner = ownerOf(tokenId);
		require(to != owner, "Already owner");
		require(msg.sender == owner || isApprovalForAll(owner, msg.sender), "Not authorized");
		_tokenApproval[tokenId] = to;
		emit Approval(owner, to, tokenId);
	}
	// The address approved to operate a single NFT
	function getApproved(uint256 tokenId) public view override returns (address) {
		require(_owners[tokenId] != address(0), "Invalid address");
		return _tokenApproval[tokenId];
	}
	// Approve other to operate all NFT one has
	function setApprovalForAll(address operator, bool approved) public override {
		require(operator != msg.sender, "Self approved");
		_operatorApproval[msg.sender][operator] = approved;
		emit ApprovalForAll(msg.sender, operator, approved);
	}
	// The address approved by owner to operate all NFT
	function isApprovalForAll(address owner, address operator) public view override returns (bool) {
		return _operatorApproval[owner][operator];
	}
	// Is owner or approved operator of a single NFT
	function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
		address owner = ownerOf(tokenId);
		return (spender == owner || getApproved(tokenId) == spender || isApprovalForAll(owner, spender));
	}
	// Transfer NFT from owner to other
	// virtual for derived contracts to reuse
	function _transfer(address from, address to, uint256 tokenId) internal virtual {
		require(ownerOf(tokenId) == from, "Not owner");
		require(to != address(0), "Invalid address");
		_balance[from] -= 1;
		_balance[to] += 1;
		_owners[tokenId] = to;
		// remove approved operator of this single NFT
		delete _tokenApproval[tokenId];
		emit Transfer(from, to, tokenId);
	}
	// Check whether allowed to receive NFT
	function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
		// Smart contract
		if (to.code.length > 0) {
			try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
				// Magic value: 0x150b7a02
				// Should return this value if method implemented
				return retval == IERC721Receiver.onERC721Received.selector;
			}
			catch {
				// Revert if errors catched
				return false;
			}
		}
		// Regular wallet
		return (true);
	}
	// Revert if not ERC721Received
	function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
		_transfer(from, to, tokenId);
		require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
	}
	// Transfer by approved operator
	function transferFrom(address from, address to, uint256 tokenId) public override {
		require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
		_transfer(from, to, tokenId);
	}
	function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
		require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
		_safeTransfer(from, to, tokenId, data);
	}
	function safeTransferFrom(address from, address to, uint256 tokenId) public override {
		safeTransferFrom(from, to, tokenId, "");
	}
	// Mint new NFT
	// to cannot be address(0)
	function mint(address to, string memory uri) public {
		uint256 tokenId = _tokenCounter;
		_tokenCounter++;
		_owners[tokenId] = to;
		_balance[to] += 1;
		_tokenURI[tokenId] = uri;
		emit Transfer(address(0), to, tokenId);
	}
	// URI is the unique info about NFT
	function tokenURI(uint256 tokenId) public view returns (string memory) {
		require(_owners[tokenId] != address(0), "Token not exist");
		return _tokenURI[tokenId];
	}
}