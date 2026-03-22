// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @dev ERC721 标准接口：定义了 NFT 必须具备的所有核心功能
 */
interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

/**
 * @dev 接收者接口：如果要把 NFT 发给一个“合约地址”，该合约必须实现此接口，否则 NFT 会被锁死。
 */
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract SimpleNFT is IERC721 {
    string public name;    // NFT 名称
    string public symbol;  // NFT 符号

    uint256 private _tokenIdCounter = 1; // 简单的 ID 计数器，从 1 开始累加

    // --- 核心数据存储 ---
    mapping(uint256 => address) private _owners;              // TokenID => 拥有者地址
    mapping(address => uint256) private _balances;            // 用户地址 => 持有的 NFT 总数
    mapping(uint256 => address) private _tokenApprovals;      // 单个 NFT 的授权 (针对某个具体 ID)
    mapping(address => mapping(address => bool)) private _operatorApprovals; // 批量授权 (授权某人管理我所有的 NFT)
    mapping(uint256 => string) private _tokenURIs;           // TokenID => 元数据链接 (如 IPFS 图片链接)

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    /// @notice 查询某人持有多少个 NFT
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }

    /// @notice 查询某个具体的 NFT 现在归谁所有
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    /// @notice 授权别人操作我的某一个 NFT (比如在 OpenSea 上挂单)
    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "Already owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /// @notice 查看某个 NFT 授权给了谁
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    /// @notice 授权一个“代理人”管理我所有的 NFT
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /// @notice 普通转移：如果接收方是合约且没处理好，NFT 会丢失
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }

    /// @notice 安全转移：会自动检查接收方是否有能力处理 NFT
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @notice 铸造（Mint）一个新的 NFT
     * @param to 接收者的地址
     * @param uri NFT 的图片/属性数据链接
     */
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId); // 从零地址转移，代表增发
    }

    /// @notice 获取 NFT 的元数据地址
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

    /// @dev 内部转移逻辑
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        delete _tokenApprovals[tokenId]; // 换主人后，旧的单项授权失效
        emit Transfer(from, to, tokenId);
    }

    /// @dev 内部安全转移逻辑
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        // 关键一步：检查接收者能不能收 NFT
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
    }

    /// @dev 判断调用者是否有权操作这个 NFT (拥有者、获授权人、或全局代理人)
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev 核心安全检查
     * 如果目标是合约，调用它的 onERC721Received，如果没返回正确的特征码就报错回滚。
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) { // 判断目标是否为合约地址
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch {
                return false;
            }
        }
        return true;
    }
}