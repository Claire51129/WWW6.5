//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC721 {
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  function balanceOf(address owner) external view returns (uint256);
  function ownerOf(uint256 tokenId) external view returns (address);

  function approve(address to, uint256 tokenId) external;
  function getApproved(uint256 tokenId) external view returns (address);

  function setApprovalForAll(address operator, bool _approved) external;
  function isApprovedForAll(address owner, address operator) external view returns (bool);

  function transferFrom(address from, address to, uint256 tokenId) external;
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
  function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IERC721Receiver {
  function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract SimpleNFT is IERC721 {
  string public name;
  string public symbol;

  uint256 private _tokenIdCounter = 1;

  mapping(uint256 => address) private _owners;
  mapping(address => uint256) private _balances;
  mapping(uint256 => address) private _tokenApprovals;
  mapping(address => mapping(address => bool)) private _operatorApprovals;
  mapping(uint256 => string) private _tokenURIs;

  constructor(string memory _name, string memory _symbol) {
    name = _name;
    symbol = _symbol;
  }

  function balanceOf(address owner) public view override returns (uint256) {
    require(owner != address(0), "Invalid address");
    return _balances[owner];
  }

  function ownerOf(uint256 tokenId) public view override returns (address) {
    address owner = _owners[tokenId];
    require(owner != address(0), "Token does not exist");
    return owner;
  }

  function approve(address to, uint256 tokenId) public override {
    address owner = ownerOf(tokenId);
    require(to != owner, "Already owner");
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

    _tokenApprovals[tokenId] = to;
    emit Approval(owner, to, tokenId);
  }

  //get approved address for a token
  function getApproved(uint256 tokenId) public view override returns (address) {
    require(_owners[tokenId] != address(0), "Token does not exist");
    return _tokenApprovals[tokenId];
  }

  //msg.sender get approved for all tokens of the owner
  function setApprovalForAll(address operator, bool approved) public override {
    require(operator != msg.sender, "Cannot approve self");
    _operatorApprovals[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
  }

  //check if operator is approved for all tokens of the owner
  function isApprovedForAll(address owner, address operator) public view override returns (bool) {
    return _operatorApprovals[owner][operator];
  }

  function transferFrom(address from, address to, uint256 tokenId) public override {
    require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
    _transfer(from, to, tokenId);
  }

  function safeTransferFrom(address from, address to, uint256 tokenId) public override {
    safeTransferFrom(from, to, tokenId, "");
  }

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
    require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
    _safeTransfer(from, to, tokenId, data);
  }

  //mint means create a new token and assign it to an address
  function mint(address to, string memory uri) public {
    uint256 tokenId = _tokenIdCounter++;
    _owners[tokenId] = to;
    _balances[to] += 1;
    _tokenURIs[tokenId] = uri;
    emit Transfer(address(0), to, tokenId);
  }

  function tokenURI(uint256 tokenId) public view returns (string memory) {
    require(_owners[tokenId] != address(0), "Token does not exist");
    return _tokenURIs[tokenId];
  }

  function _transfer(address from, address to, uint256 tokenId) internal virtual {
    require(ownerOf(tokenId) == from, "Not owner");
    require(to != address(0), "Invalid address");

    _balances[from] -= 1;
    _balances[to] += 1;
    _owners[tokenId] = to;

    delete _tokenApprovals[tokenId];
    emit Transfer(from, to, tokenId);
  }

  function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
    _transfer(from, to, tokenId);
    require(_checkOnERC721Received(from, to, tokenId, data), "Transfer to non ERC721Receiver");
  }

  function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
    address owner = ownerOf(tokenId);
    return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
  }

  function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
    if (to.code.length > 0) {
      try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
        return retval == IERC721Receiver.onERC721Received.selector;
      } catch {
        return false;
      }
    }
    return true;
  }
}