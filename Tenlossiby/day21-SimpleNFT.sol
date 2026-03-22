// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// IERC721 - ERC721 标准接口
// 定义了 NFT 合约必须实现的基本功能
// 符合以太坊改进提案 EIP-721
interface IERC721 {
    // 事件定义
    // 当代币被转移时触发
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // 当代币授权给某个地址时触发
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // 当设置或取消操作员授权时触发
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // 查询某个地址拥有的代币数量
    function balanceOf(address owner) external view returns (uint256);
    // 查询代币的所有者
    function ownerOf(uint256 tokenId) external view returns (address);

    // 授权某个地址操作特定代币
    function approve(address to, uint256 tokenId) external;
    // 查询代币被授权给的地址
    function getApproved(uint256 tokenId) external view returns (address);

    // 设置或取消操作员授权（授权操作员管理所有代币）
    function setApprovalForAll(address operator, bool approved) external;
    // 查询是否授权了操作员
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // 转移代币（需要授权）
    function transferFrom(address from, address to, uint256 tokenId) external;
    // 安全转移代币（检查接收方是否支持 ERC721）
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    // 带数据的安全转移
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// IERC721Receiver - ERC721 代币接收接口
// 合约必须实现此接口才能接收 ERC721 代币
// 防止代币被意外发送到不支持 ERC721 的合约
interface IERC721Receiver {
    // 当合约接收到 ERC721 代币时调用
    // 必须返回此函数的 selector（0x150b7a02）以确认接收
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// SimpleNFT - 简化版 ERC721 NFT 合约
// 实现了 ERC721 标准的基本功能
// 包含铸造、转移、授权等核心功能
contract SimpleNFT is IERC721 {
    // NFT 名称
    string public name;
    // NFT 符号（代币标识）
    string public symbol;

    // 代币 ID 计数器，从 1 开始
    uint256 private _tokenIdCounter = 1;

    // 代币 ID 到所有者的映射
    mapping(uint256 => address) private _owners;
    // 所有者地址到代币数量的映射
    mapping(address => uint256) private _balances;
    // 代币 ID 到被授权地址的映射
    mapping(uint256 => address) private _tokenApprovals;
    // 所有者到操作员授权的映射（嵌套映射）
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    // 代币 ID 到元数据 URI 的映射
    mapping(uint256 => string) private _tokenURIs;

    // 构造函数 - 设置 NFT 名称和符号
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // 查询地址拥有的代币数量
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }

    // 查询代币的所有者
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    // 授权地址操作特定代币
    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "Already owner");
        // 验证调用者是代币所有者或已授权的操作员
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // 查询代币被授权给的地址
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    // 设置或取消操作员授权
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 查询是否授权了操作员
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // 转移代币（需要授权）
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }

    // 安全转移代币
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    // 带数据的安全转移代币
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, data);
    }

    // 铸造新代币
    // to: 接收者地址
    // uri: 代币元数据 URI
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        // 设置代币所有者和余额
        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = uri;

        // 触发 Transfer 事件（from 为 0 地址表示铸造）
        emit Transfer(address(0), to, tokenId);
    }

    // 查询代币的元数据 URI
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

    // 内部转移函数
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Zero address");

        // 清除授权
        delete _tokenApprovals[tokenId];

        // 更新余额
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    // 内部安全转移函数
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        // 检查接收方是否支持 ERC721
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
    }

    // 检查调用者是否被授权操作代币
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    // 检查接收方合约是否实现了 IERC721Receiver
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        // 检查 to 是否是合约地址
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                // 验证返回值是否正确
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch {
                // 调用失败
                return false;
            }
        }
        // EOA（外部账户）总是可以接收
        return true;
    }
}

// ERC721 关键概念:
//
// 1. 代币标识:
//    - 每个代币有唯一的 tokenId（uint256）
//    - 从 0 地址铸造，转移到 0 地址销毁
//
// 2. 所有权管理:
//    - _owners: tokenId => owner
//    - _balances: owner => count
//
// 3. 授权机制:
//    - 单代币授权: approve()
//    - 操作员授权: setApprovalForAll()
//
// 4. 安全转移:
//    - 检查接收方是否支持 ERC721
//    - 防止代币被锁定在不支持的合约中
//
// 5. 元数据:
//    - tokenURI() 返回代币的元数据链接
//    - 通常指向 JSON 文件，包含名称、描述、图片等
