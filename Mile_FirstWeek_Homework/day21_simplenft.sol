// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title IERC721Receiver
 * @dev 接口用于检查接收者合约是否支持安全接收 NFT
 */
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * @title day21_simple_nft
 * @dev 从零实现的 ERC-721 非同质化代币合约
 * 
 * 文件名: day21_simple_nft.sol
 * 合约名: day21_simple_nft
 * 
 * 核心功能:
 * - 完整的 ERC-721 标准实现
 * - 双层批准机制 (单个授权 + 全局授权)
 * - 安全转账检查 (防止资产丢失)
 * - 元数据 URI 管理
 */
contract day21_simple_nft {
    // --- 状态变量 ---
    string public name;
    string public symbol;
    
    // 自增 Token ID 计数器
    uint256 private _tokenIdCounter;

    // --- 五大核心映射 (NFT 的灵魂) ---
    
    // 1. tokenId => 所有者地址 (查询某个 NFT 属于谁)
    mapping(uint256 => address) private _owners;
    
    // 2. 地址 => 拥有数量 (查询某人有多少 NFT)
    mapping(address => uint256) private _balances;
    
    // 3. tokenId => 被批准的地址 (单个授权：谁可以转移这个特定的 NFT)
    mapping(uint256 => address) private _tokenApprovals;
    
    // 4. 所有者 => 操作员 => 是否批准 (全局授权：谁可以管理我所有的 NFT)
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    // 5. tokenId => 元数据 URI (图片/属性链接)
    mapping(uint256 => string) private _tokenURIs;

    // --- 事件 ---
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @param _name NFT 集合名称 (如 "Simple Art")
     * @param _symbol NFT 集合符号 (如 "SART")
     */
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        _tokenIdCounter = 0;
    }

    // ================= 查询函数 =================

    /**
     * @dev 查询地址拥有的 NFT 数量
     */
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Invalid address: zero");
        return _balances[owner];
    }

    /**
     * @dev 查询特定 TokenID 的所有者
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token does not exist");
        return owner;
    }

    /**
     * @dev 查询特定 TokenID 被批准给谁
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev 查询所有者是否批准了操作员管理所有 NFT
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        require(owner != address(0), "Invalid owner address");
        require(operator != address(0), "Invalid operator address");
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev 获取 Token 的元数据 URI
     */
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenURIs[tokenId];
    }

    // ================= 批准管理 =================

    /**
     * @dev 批准另一个地址转移特定的 NFT
     * 只有所有者可以调用
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        
        require(msg.sender == owner, "Caller is not the owner");
        require(to != owner, "Approval to current owner");

        _tokenApprovals[tokenId] = to;
        
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev 设置或取消操作员对所有 NFT 的管理权限
     * 常用于授权市场合约 (如 OpenSea)
     */
    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "Approve to caller");
        
        _operatorApprovals[msg.sender][operator] = approved;
        
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // ================= 转账功能 =================

    /**
     * @dev 普通转账 (不检查接收者是否为合约)
     * 风险：如果转给不支持 NFT 的合约，资产可能丢失
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        // 检查权限：必须是所有者、被批准人或操作员
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev 安全转账 (重载函数 1)
     * 不带额外数据
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev 安全转账 (重载函数 2)
     * 如果接收者是合约，必须实现 onERC721Received 接口，否则交易回滚
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        
        _safeTransfer(from, to, tokenId, data);
    }

    // ================= 内部逻辑函数 =================

    /**
     * @dev 执行实际的资产转移逻辑
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        // 验证 from 确实是当前所有者
        require(ownerOf(tokenId) == from, "From is not the owner");
        require(to != address(0), "Transfer to zero address");

        // 清除之前的批准状态 (转账后授权失效，保障安全)
        delete _tokenApprovals[tokenId];

        // 更新余额
        unchecked {
            // 使用 unchecked 防止下溢 (因为前面已经验证了 from 是所有者，必然有余额)
            _balances[from] -= 1;
            _balances[to] += 1;
        }

        // 转移所有权
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev 执行安全转移逻辑
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        _transfer(from, to, tokenId);
        
        // 如果接收者是合约，检查它是否支持 ERC-721
        if (_isContract(to)) {
            bytes4 retval = IERC721Receiver(to).onERC721Received(
                msg.sender,
                from,
                tokenId,
                data
            );
            require(retval == IERC721Receiver.onERC721Received.selector, "ERC721: transfer to non-receiver");
        }
    }

    /**
     * @dev 检查 spender 是否有权限操作 tokenId
     * 权限来源：是所有者 OR 被单独批准 OR 是全局操作员
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (
            spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender)
        );
    }

    /**
     * @dev 判断地址是否为合约
     */
    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    // ================= 铸造功能 (Mint) =================

    /**
     * @dev 铸造新的 NFT
     * @param to 接收者地址
     * @param uri 元数据 URI (例如 IPFS 链接)
     * @return 新铸造的 tokenId
     * 
     * ⚠️ 注意：此函数为 public，任何人都可铸造。生产环境应添加 onlyOwner 修饰符。
     */
    function mint(address to, string memory uri) public returns (uint256) {
        require(to != address(0), "Mint to zero address");
        
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        // 设置所有权
        _owners[tokenId] = to;
        
        // 增加余额
        unchecked {
            _balances[to] += 1;
        }

        // 设置元数据
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);
        
        return tokenId;
    }
    
    /**
     * @dev 辅助函数：获取当前总供应量
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }
}