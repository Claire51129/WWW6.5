// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// ERC721标准接口：NFT必须实现的功能
interface IERC721 {
    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // 授权事件
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // 批量授权事件
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // 查询地址拥有的NFT数量
    function balanceOf(address owner) external view returns (uint256);
    // 查询NFT的拥有者
    function ownerOf(uint256 tokenId) external view returns (address);

    // 授权别人操作单个NFT
    function approve(address to, uint256 tokenId) external;
    // 查询单个NFT的授权对象
    function getApproved(uint256 tokenId) external view returns (address);

    // 批量授权别人操作所有NFT
    function setApprovalForAll(address operator, bool approved) external;
    // 查询是否批量授权
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // 转账NFT
    function transferFrom(address from, address to, uint256 tokenId) external;
    // 安全转账NFT
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    // 带数据的安全转账
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// 安全接收NFT的接口
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// NFT主合约：实现所有功能
contract SimpleNFT is IERC721 {
    // NFT全称
    string public name;
    // NFT简称（符号）
    string public symbol;

    // NFT身份证号计数器（自动生成1、2、3...）
    uint256 private _tokenIdCounter = 1;

    // 存储：NFTID => 拥有者地址
    mapping(uint256 => address) private _owners;
    // 存储：地址 => 拥有的NFT数量
    mapping(address => uint256) private _balances;
    // 存储：NFTID => 授权的地址
    mapping(uint256 => address) private _tokenApprovals;
    // 存储：批量授权权限
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    // 存储：NFTID => 图片/资料链接
    mapping(uint256 => string) private _tokenURIs;

    // 构造函数：部署合约时设置NFT名字和符号
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // 查询地址拥有的NFT数量
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }

    // 查询NFT的拥有者
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    // 授权别人操作我的NFT
    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "Already owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // 查询NFT被授权给谁
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    // 批量授权：允许别人操作我所有的NFT
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 查询是否开启了批量授权
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // 转账NFT
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }

    // 安全转账NFT（防止转丢）
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        _safeTransfer(from, to, tokenId, ""); // ✅ 改这里，直接调用内部函数
    }

// 带数据的安全转账（完整实现）
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, data);
    }

    // ==================== 核心功能：造NFT ====================
    function mint(address to, string memory uri) public {
        // 自动生成NFT身份证号
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        // 给地址分配NFT
        _owners[tokenId] = to;
        // 数量+1
        _balances[to] += 1;
        // 存储NFT的图片链接
        _tokenURIs[tokenId] = uri;

        // 触发转账事件（从0地址创建，代表造新NFT）
        emit Transfer(address(0), to, tokenId);
    }

    // 查询NFT的图片/资料链接
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

    // 内部函数：真正执行转账逻辑
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Zero address");

        // 转出方数量-1
        _balances[from] -= 1;
        // 转入方数量+1
        _balances[to] += 1;
        // 修改NFT拥有者
        _owners[tokenId] = to;

        // 清空旧授权
        delete _tokenApprovals[tokenId];
        emit Transfer(from, to, tokenId);
    }

    // 内部函数：安全转账
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
    }

    // 内部函数：检查是否有权限操作NFT
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    // 内部函数：验证NFT安全接收
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