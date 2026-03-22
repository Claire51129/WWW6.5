// SPDX-License-Identifier: MIT
// 代码开源协议

pragma solidity ^0.8.19;
// 指定Solidity编译器版本

interface IERC721 {
// ERC721标准接口
// 定义了所有NFT必须实现的函数和事件
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // 转账事件：当NFT被转移时触发
    
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // 授权事件：当某个地址被授权管理单个NFT时触发
    
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    // 批量授权事件：当某个地址被授权管理所有NFT时触发

    function balanceOf(address owner) external view returns (uint256);
    // 查询地址拥有的NFT数量
    
    function ownerOf(uint256 tokenId) external view returns (address);
    // 查询NFT的拥有者

    function approve(address to, uint256 tokenId) external;
    // 授权某个地址管理单个NFT
    
    function getApproved(uint256 tokenId) external view returns (address);
    // 查询NFT被授权给了哪个地址

    function setApprovalForAll(address operator, bool approved) external;
    // 授权/取消授权某个地址管理所有NFT
    
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    // 查询某个地址是否被授权管理所有NFT

    function transferFrom(address from, address to, uint256 tokenId) external;
    // 转移NFT（不安全版本）
    
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    // 安全转移NFT（检查接收方）
    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    // 安全转移NFT（带额外数据）
}

interface IERC721Receiver {
// ERC721接收者接口
// 如果接收方是合约，必须实现这个接口
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
    // 当NFT被安全转移到合约时调用
    // 返回值必须是 0x150b7a02
}

contract SimpleNFT is IERC721 {
// 定义一个合约，叫"简单NFT"
// is IERC721：实现ERC721标准接口

    string public name;
    // NFT名称（如"CryptoPunks"）
    
    string public symbol;
    // NFT符号（如"PUNK"）

    uint256 private _tokenIdCounter = 1;
    // token ID计数器，从1开始
    // 每次铸造增加1

    mapping(uint256 => address) private _owners;
    // 映射：token ID → 拥有者地址
    
    mapping(address => uint256) private _balances;
    // 映射：地址 → 拥有的NFT数量
    
    mapping(uint256 => address) private _tokenApprovals;
    // 映射：token ID → 被授权的地址（单个授权）
    
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    // 映射：拥有者 → 操作者 → 是否授权（批量授权）
    
    mapping(uint256 => string) private _tokenURIs;
    // 映射：token ID → 元数据URI（指向NFT图片/信息）

    constructor(string memory name_, string memory symbol_) {
    // 构造函数：部署时设置名称和符号
        name = name_;
        symbol = symbol_;
    }

    function balanceOf(address owner) public view override returns (uint256) {
    // 函数：查询地址拥有的NFT数量
        require(owner != address(0), "Zero address");
        // 检查：地址不能是零地址
        
        return _balances[owner];
        // 返回该地址的余额
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
    // 函数：查询NFT的拥有者
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        // 检查：token必须存在
        
        return owner;
        // 返回拥有者地址
    }

    function approve(address to, uint256 tokenId) public override {
    // 函数：授权某个地址管理单个NFT
    // 被授权的地址可以转移这个NFT
        
        address owner = ownerOf(tokenId);
        // 获取NFT的拥有者
        
        require(to != owner, "Already owner");
        // 检查：不能授权给自己
        
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");
        // 检查：调用者必须是拥有者，或者被批量授权

        _tokenApprovals[tokenId] = to;
        // 记录授权地址
        
        emit Approval(owner, to, tokenId);
        // 发出授权事件
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
    // 函数：查询NFT被授权给了哪个地址
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        // 检查：token必须存在
        
        return _tokenApprovals[tokenId];
        // 返回授权地址（如果没有授权，返回零地址）
    }

    function setApprovalForAll(address operator, bool approved) public override {
    // 函数：授权/取消授权某个地址管理所有NFT
    // 批量授权，被授权的地址可以转移这个地址的所有NFT
        
        require(operator != msg.sender, "Self approval");
        // 检查：不能授权给自己
        
        _operatorApprovals[msg.sender][operator] = approved;
        // 记录授权状态
        
        emit ApprovalForAll(msg.sender, operator, approved);
        // 发出批量授权事件
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
    // 函数：查询某个地址是否被授权管理所有NFT
        return _operatorApprovals[owner][operator];
        // 返回授权状态
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
    // 函数：转移NFT（不安全版本）
    // 不检查接收方是否能接收NFT
        
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        // 检查：调用者有权转移这个NFT
        // 条件：是拥有者、或被单个授权、或被批量授权
        
        _transfer(from, to, tokenId);
        // 执行转移
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
    // 函数：安全转移NFT（无额外数据）
        safeTransferFrom(from, to, tokenId, "");
        // 调用带数据的版本，传入空数据
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
    // 函数：安全转移NFT（带额外数据）
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        // 检查：调用者有权转移
        
        _safeTransfer(from, to, tokenId, data);
        // 执行安全转移
    }

    function mint(address to, string memory uri) public {
    // 函数：铸造新的NFT
    // 任何人都可以调用（生产环境需要权限控制）
        
        uint256 tokenId = _tokenIdCounter;
        // 获取当前计数器值作为新token ID
        
        _tokenIdCounter++;
        // 计数器+1

        _owners[tokenId] = to;
        // 记录拥有者
        
        _balances[to] += 1;
        // 增加拥有者的NFT数量
        
        _tokenURIs[tokenId] = uri;
        // 记录元数据URI

        emit Transfer(address(0), to, tokenId);
        // 发出转账事件（从零地址转出表示铸造）
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
    // 函数：获取NFT的元数据URI
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        // 检查：token必须存在
        
        return _tokenURIs[tokenId];
        // 返回URI（指向JSON元数据）
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
    // 内部函数：实际执行转移（不检查接收方）
        
        require(ownerOf(tokenId) == from, "Not owner");
        // 检查：from必须是当前拥有者
        
        require(to != address(0), "Zero address");
        // 检查：不能转移到零地址

        _balances[from] -= 1;
        // 减少转出方余额
        
        _balances[to] += 1;
        // 增加接收方余额
        
        _owners[tokenId] = to;
        // 更新拥有者

        delete _tokenApprovals[tokenId];
        // 清除授权（转移后授权失效）
        
        emit Transfer(from, to, tokenId);
        // 发出转账事件
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
    // 内部函数：安全转移
    // 先执行转移，再检查接收方
        
        _transfer(from, to, tokenId);
        // 执行转移
        
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
        // 检查：如果接收方是合约，必须实现IERC721Receiver接口
        // 如果接收方是普通地址，直接通过
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
    // 内部函数：检查调用者是否有权操作这个NFT
    // 返回true的情况：
    // 1. 调用者是拥有者
    // 2. 调用者被单个授权
    // 3. 调用者被批量授权
        
        address owner = ownerOf(tokenId);
        // 获取拥有者
        
        return (spender == owner || 
                getApproved(tokenId) == spender || 
                isApprovedForAll(owner, spender));
        // 三种情况任一满足即可
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
    // 内部函数：检查接收方是否能接收ERC721
    // 如果接收方是普通地址，返回true
    // 如果接收方是合约，必须实现onERC721Received并返回正确值
        
        if (to.code.length > 0) {
        // 如果接收方是合约（有代码）
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
                // 检查返回值是否是 0x150b7a02
            } catch {
                return false;
                // 调用失败，返回false
            }
        }
        return true;
        // 接收方是普通地址，直接通过
    }
}
