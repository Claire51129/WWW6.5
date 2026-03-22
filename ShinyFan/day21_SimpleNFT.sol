// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC721 {//调用ERC-721接口
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);//转移NFT
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);//授权某人操作某个 NFT
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);//授权某人操作所有 NFT

    function balanceOf(address owner) external view returns (uint256);//查询该地址NFT余额
    function ownerOf(uint256 tokenId) external view returns (address);//查询这个NFT是谁的

    function approve(address to, uint256 tokenId) external;//允许别人操控我的NFT
    function getApproved(uint256 tokenId) external view returns (address);//这个 NFT 被授权给谁了？

    function setApprovalForAll(address operator, bool approved) external;//允许某人操控我的NFT
    function isApprovedForAll(address owner, address operator) external view returns (bool);//是否授权过某人操作所有 NFT

    function transferFrom(address from, address to, uint256 tokenId) external;//转账
    function safeTransferFrom(address from, address to, uint256 tokenId) external;//安全转账，会检查是否NFT转账成功
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;//带数据的安全转账
}

//这个接口用于安全地向合约发送NFT
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

//继承接口
contract SimpleNFT is IERC721 {
    string public name;
    string public symbol;

    uint256 private _tokenIdCounter = 1;//分配id

    mapping(uint256 => address) private _owners;//用它来存储拥有给定代币ID的人的地址
    mapping(address => uint256) private _balances;//某人有多少代币
    mapping(uint256 => address) private _tokenApprovals;//谁被批准了可以转移代币
    mapping(address => mapping(address => bool)) private _operatorApprovals;//授权a可以移动b的NFT
    mapping(uint256 => string) private _tokenURIs;//这个映射存储每个代币的元数据URL。

    //确定代币的名称
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    //查询所有者的代币余额
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }

    //给定一个代币ID，这告诉你谁拥有它
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    //授权转账
    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "Already owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    //检查谁被批准转移特定代币
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

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

    //铸造NFT
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        delete _tokenApprovals[tokenId];
        emit Transfer(from, to, tokenId);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
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
