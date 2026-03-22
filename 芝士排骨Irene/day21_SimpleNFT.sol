// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// ERC-721 标准接口 - NFT（非同质化代币）的规范
interface IERC721 {
    // 转账事件 - NFT 从一个地址转移到另一个地址时触发
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // 单个 NFT 授权事件
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // 全部 NFT 授权事件（批量授权给某个操作者）
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // 查询某地址拥有多少个 NFT
    function balanceOf(address owner) external view returns (uint256);
    // 查询某个 NFT（tokenId）的所有者是谁
    function ownerOf(uint256 tokenId) external view returns (address);

    // 授权某地址可以转移指定的某一个 NFT
    function approve(address to, uint256 tokenId) external;
    // 查询某个 NFT 当前被授权给了谁
    function getApproved(uint256 tokenId) external view returns (address);

    // 批量授权：允许某个操作者管理自己的所有 NFT
    // 类比：把所有 NFT 的管理权交给一个经纪人（比如 OpenSea 合约）
    function setApprovalForAll(address operator, bool approved) external;
    // 查询某人是否已授权某操作者管理所有 NFT
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // 转移 NFT（不检查接收方是否能处理 NFT）
    function transferFrom(address from, address to, uint256 tokenId) external;
    // 安全转移 NFT（会检查接收方是否实现了接收接口，防止 NFT 丢失）
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    // 安全转移 NFT（带附加数据）
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// ERC-721 接收者接口 - 如果一个合约想接收 NFT，必须实现这个接口
interface IERC721Receiver {
    // 当合约收到 NFT 时被调用，必须返回特定的值（selector）表示"我能处理 NFT"
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// 简易 NFT 合约 - 从零实现 ERC-721 标准
contract SimpleNFT is IERC721 {

    string public name;    // NFT 系列名称（如 "Bored Ape Yacht Club"）
    string public symbol;  // NFT 系列符号（如 "BAYC"）

    uint256 private _tokenIdCounter = 1;  // Token ID 计数器，从 1 开始自增

    // 核心存储
    mapping(uint256 => address) private _owners;           // tokenId => 所有者地址
    mapping(address => uint256) private _balances;         // 地址 => 持有的 NFT 数量
    mapping(uint256 => address) private _tokenApprovals;   // tokenId => 被授权的地址（单个 NFT 授权）
    mapping(address => mapping(address => bool)) private _operatorApprovals;  // 所有者 => (操作者 => 是否授权全部)
    mapping(uint256 => string) private _tokenURIs;         // tokenId => 元数据 URI（指向图片、属性等 JSON 文件）

    // 构造函数 - 设置 NFT 系列的名称和符号
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // 查询某地址拥有多少个 NFT
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");  // 零地址没有意义
        return _balances[owner];
    }

    // 查询某个 NFT 的所有者
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");  // 不存在的 tokenId 所有者是零地址
        return owner;
    }

    // 授权某地址可以转移自己的某一个 NFT
    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "Already owner");           // 不能授权给自己
        // 调用者必须是所有者本人，或者是被全局授权的操作者
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;  // 记录：这个 NFT 被授权给了 to
        emit Approval(owner, to, tokenId);
    }

    // 查询某个 NFT 当前被授权给了谁
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    // 全局授权 - 允许某个操作者管理自己的所有 NFT
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");  // 不能授权给自己
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 查询是否已全局授权
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // 转移 NFT（不安全版本，不检查接收方）
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");  // 必须有权限
        _transfer(from, to, tokenId);
    }

    // 安全转移 NFT（无附加数据版本）
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        safeTransferFrom(from, to, tokenId, "");  // 调用下面带 data 参数的版本，data 传空
    }

    // 安全转移 NFT
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, data);
    }

    // 铸造 NFT - 创建一个全新的 NFT 并分配给指定地址
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;  // 当前 ID
        _tokenIdCounter++;                   // ID 自增，下一个 NFT 用下一个编号

        _owners[tokenId] = to;     // 记录所有者
        _balances[to] += 1;        // 持有数量 +1
        _tokenURIs[tokenId] = uri; // 记录元数据地址

        // 从零地址转出，表示"铸造"（和 ERC-20 一样的约定）
        emit Transfer(address(0), to, tokenId);
    }

    // 查询 NFT 的元数据 URI
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

    // 内部转移函数 - 实际执行 NFT 所有权转移的逻辑
    // virtual：允许子合约重写（比如加转账手续费、锁定期等）
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");   // 确认 from 确实是当前所有者
        require(to != address(0), "Zero address");         // 不能转给零地址

        _balances[from] -= 1;          // 发送方持有数量 -1
        _balances[to] += 1;            // 接收方持有数量 +1
        _owners[tokenId] = to;         // 更新所有者

        delete _tokenApprovals[tokenId];  // 转移后清除之前的授权（新主人需要重新授权）
        emit Transfer(from, to, tokenId);
    }

    // 安全转移 - 先转移，再检查接收方能不能处理 NFT
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);  // 先执行转移
        // 再检查接收方是否实现了 onERC721Received
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
    }

    // 检查调用者是否有权操作这个 NFT
    // 三种情况任一满足即可：是所有者本人、被单独授权、被全局授权
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner ||                          // 是所有者
                getApproved(tokenId) == spender ||           // 被单独授权了这个 NFT
                isApprovedForAll(owner, spender));           // 被全局授权了所有 NFT
    }

    // 检查接收方合约是否实现了 IERC721Receiver 接口
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        // to.code.length > 0 判断接收方是不是合约
        // 普通钱包地址没有代码（length == 0），直接返回 true
        // 合约地址有代码（length > 0），需要进一步检查
        if (to.code.length > 0) {
            // try-catch：尝试调用接收方的 onERC721Received 函数
            // 如果调用成功且返回值正确 → 接收方支持 NFT → 返回 true
            // 如果调用失败（没实现这个函数或返回值不对）→ 返回 false → 转移会被回滚
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                // selector 是函数签名的前 4 字节哈希，用来确认返回的确实是正确的响应
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch {
                return false;  // 调用失败，接收方不支持 NFT
            }
        }
        return true;  // 普通钱包地址，直接通过
    }
}