// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// ERC721接口
interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256);   // 查询账户NFT数量
    function ownerOf(uint256 tokenId) external view returns (address);   // 查询NFT归属

    function approve(address to, uint256 tokenId) external;              // 授权单个NFT
    function getApproved(uint256 tokenId) external view returns (address); // 查询单个NFT授权

    function setApprovalForAll(address operator, bool approved) external; // 设置全部NFT操作授权
    function isApprovedForAll(address owner, address operator) external view returns (bool); // 查询操作授权

    function transferFrom(address from, address to, uint256 tokenId) external; // 转移NFT
    function safeTransferFrom(address from, address to, uint256 tokenId) external; // 安全转移NFT
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// 接收ERC721的合约接口
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// 简易NFT合约
contract SimpleNFT is IERC721 {
    string public name;      // NFT名称
    string public symbol;    // NFT符号

    uint256 private _tokenIdCounter = 1; // 计数器，从1开始

    mapping(uint256 => address) private _owners;                     // tokenId => 拥有者
    mapping(address => uint256) private _balances;                   // 地址 => NFT数量
    mapping(uint256 => address) private _tokenApprovals;             // tokenId => 授权地址
    mapping(address => mapping(address => bool)) private _operatorApprovals; // 操作员授权
    mapping(uint256 => string) private _tokenURIs;                   // tokenId => 元数据URI

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // 查询账户NFT数量
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }

    // 查询NFT归属
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    // 授权单个NFT,批准分配：前端监听
    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "Already owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // 检查谁被批准转移特定代币
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    // 让用户批准或撤销给定操作员（例如，市场或金库合约）对他们所有NFT的访问权限
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 只是检查操作员是否被批准管理某人拥有的所有NFT
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // 转移NFT
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }

    // 安全转移NFT
    // ERC-721 标准设计上允许两个重载版本的 safeTransferFrom，以适应不同的使用场景
    // 简化版
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        this.safeTransferFrom(from, to, tokenId, ""); // Explicit external call
    }

    // 带data!!!这里原代码deploy的时候有参数位置一致问题，将memory改成calldata
    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId, 
        bytes calldata data
    ) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, data);
    }

    // 铸造NFT
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);
    }

    // 查询NFT元数据URI
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

    // 内部NFT转移
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        delete _tokenApprovals[tokenId];
        emit Transfer(from, to, tokenId);
    }

    // 内部安全转移
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
    }

    /// 像transferFrom或safeTransferFrom这样的公共函数处理权限检查和外部输入。
    /// 像_transfer或_safeTransfer这样的内部函数做移动代币或更新状态的核心逻辑。
    /// 像_isApprovedOrOwner这样的辅助函数保持我们的访问规则干净和可重用。

    // 检查调用者是否是拥有者或被授权
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    // 检查目标地址是否实现IERC721Receiver接口
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