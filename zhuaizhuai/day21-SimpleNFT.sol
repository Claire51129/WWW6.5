// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// ERC721标准接口：规定所有NFT合约必须有哪些函数
interface IERC721 {
    // 事件：NFT转移时广播
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // 事件：授权某人操作某个NFT时广播
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // 事件：授权某人操作所有NFT时广播
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256);      // 查某人有几个NFT
    function ownerOf(uint256 tokenId) external view returns (address);      // 查某个NFT属于谁

    function approve(address to, uint256 tokenId) external;                 // 授权某人操作某个NFT
    function getApproved(uint256 tokenId) external view returns (address);  // 查某个NFT授权给谁了

    function setApprovalForAll(address operator, bool approved) external;   // 授权某人操作所有NFT
    function isApprovedForAll(address owner, address operator) external view returns (bool); // 查是否授权

    function transferFrom(address from, address to, uint256 tokenId) external;      // 普通转移NFT
    function safeTransferFrom(address from, address to, uint256 tokenId) external;  // 安全转移NFT
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external; // 带数据的安全转移
}

// 安全转移接口：收款合约必须实现这个接口才能收NFT
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract SimpleNFT is IERC721 {
    
    string public name;    // NFT集合名称，比如"Bored Ape"
    string public symbol;  // NFT集合符号，比如"BAYC"

    uint256 private _tokenIdCounter = 1;  // tokenId从1开始，每次mint+1

    // 核心mapping：
    mapping(uint256 => address) private _owners;          // tokenId → 拥有者地址
    mapping(address => uint256) private _balances;        // 地址 → 拥有几个NFT
    mapping(uint256 => address) private _tokenApprovals;  // tokenId → 被授权的地址
    mapping(address => mapping(address => bool)) private _operatorApprovals; // 地址 → 操作员 → 是否授权
    mapping(uint256 => string) private _tokenURIs;        // tokenId → NFT数据链接

    // 部署时设置NFT集合名称和符号
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // 查询某个地址拥有几个NFT
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }

    // 查询某个tokenId属于谁
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    // 授权某个地址操作你的某个NFT
    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "Already owner");  // 不能授权给自己
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");
        // 必须是owner或者被授权的操作员才能授权

        _tokenApprovals[tokenId] = to;  // 记录授权
        emit Approval(owner, to, tokenId);
    }

    // 查询某个NFT授权给谁了
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    // 授权某个地址操作你所有的NFT
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");  // 不能授权给自己
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 查询是否授权某人操作所有NFT
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // 普通转移NFT（不检查接收方是否能处理NFT）
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }

    // 安全转移NFT（检查接收方能否处理NFT）
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    // 带数据的安全转移NFT
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, data);
    }

    // 铸造新NFT
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;  // 获取当前tokenId
        _tokenIdCounter++;                   // tokenId+1，下次mint用新的

        _owners[tokenId] = to;              // 记录拥有者
        _balances[to] += 1;                 // 拥有者NFT数量+1
        _tokenURIs[tokenId] = uri;          // 记录NFT数据链接

        emit Transfer(address(0), to, tokenId);  // 从零地址转出 = 新铸造
    }

    // 查询NFT的数据链接（图片、属性等）
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

    // 内部转移函数：真正执行转移逻辑
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");  // 确认from是owner
        require(to != address(0), "Zero address");        // 不能转给零地址

        _balances[from] -= 1;   // from的NFT数量-1
        _balances[to] += 1;     // to的NFT数量+1
        _owners[tokenId] = to;  // 更新拥有者

        delete _tokenApprovals[tokenId];  // 清除之前的授权
        emit Transfer(from, to, tokenId);
    }

    // 安全转移：转移后检查接收方能否处理NFT
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
        // 如果接收方是合约，必须能处理NFT！
    }

    // 检查调用者是否有权操作这个NFT
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (
            spender == owner ||                    // 是owner
            getApproved(tokenId) == spender ||     // 被单独授权
            isApprovedForAll(owner, spender)       // 被授权操作所有NFT
        );
    }

    // 检查接收方合约是否能处理NFT
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) {
            // 如果接收方是合约
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
                // 检查返回值是否正确
            } catch {
                return false;  // 合约不支持接收NFT！
            }
        }
        return true;  // 如果是普通地址，直接通过
    }
}
//## 整个合约结构：

//接口层：IERC721      → 规定必须有什么函数
//接口层：IERC721Receiver → 规定收款合约格式

//合约层：SimpleNFT
 // 状态变量  → 存储NFT数据
  //mint()   → 创建NFT
 // transfer → 转移NFT
  //approve  → 授权
 // 查询函数  → 查余额、拥有者等
