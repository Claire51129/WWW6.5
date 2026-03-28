// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleNFT {
    string public name;
    string public symbol;

    uint256 private _tokenIdCounter;

    // 核心映射
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => string) private _tokenURIs;

    // 所有者（用于铸造控制）
    address private _owner;

    // 事件
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // 修饰符：只有所有者可以调用
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner");
        _;
    }

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        _owner = msg.sender;
        _tokenIdCounter = 0;
    }

    // 查询地址拥有的 NFT 数量
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Invalid address");
        return _balances[owner];
    }

    // 查询 NFT 的所有者
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    // 查询单个 NFT 的授权地址
    function getApproved(uint256 tokenId) public view returns (address) {
        return _tokenApprovals[tokenId];
    }

    // 查询是否授权某个操作员管理所有 NFT
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // 授权单个 NFT 给某个地址
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "Not the owner");
        require(to != owner, "Approval to current owner");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // 授权/撤销操作员管理所有 NFT
    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "Approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 转移 NFT（需要授权）
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved");
        _transfer(from, to, tokenId);
    }

    // 安全转移（无回调数据）
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    // 安全转移（带回调数据）
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved");
        _safeTransfer(from, to, tokenId, data);
    }

    // 铸造 NFT（仅所有者）
    function mint(address to, string memory uri) public onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to]++;
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);
        return tokenId;
    }

    // 获取 NFT 元数据 URI
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

    // 内部：核心转账逻辑
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "Not the owner");
        require(to != address(0), "Invalid address");

        // 清除授权
        _tokenApprovals[tokenId] = address(0);

        // 更新余额
        _balances[from]--;
        _balances[to]++;

        // 转移所有权
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    // 内部：检查是否有操作权限
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner ||
                getApproved(tokenId) == spender ||
                isApprovedForAll(owner, spender));
    }

    // 内部：安全转账（带接收者检查）
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) private {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "Transfer to non ERC721Receiver");
    }

    // 内部：检查接收者是否支持 ERC721 接收（简单实现）
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length == 0) return true; // 普通地址无需检查
        (bool success, bytes memory returndata) = to.call(
            abi.encodeWithSignature("onERC721Received(address,address,uint256,bytes)", from, msg.sender, tokenId, data)
        );
        return success && abi.decode(returndata, (bytes4)) == 0x150b7a02;
    }
}
