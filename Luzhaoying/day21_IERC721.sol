// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//这段代码完整实现了一个 NFT 合约的生命周期：
//定义标准: 遵循 ERC-721 接口。
//数据存储: 使用 mapping 存储谁拥有谁。
//铸造: mint 函数允许创建新的 Token。
//交易: transferFrom 和 safeTransferFrom 处理所有权变更。
//安全: 通过 _checkOnERC721Received 防止资产被锁死在合约中。
//授权: 允许用户授权他人或市场管理自己的 NFT。



//这是ERC-721接口，在 Solidity 中，接口就像是“合同”或“标准”，规定了合约必须具备哪些功能
interface IERC721 {
    //事件: 区块链前端的“监听器”。当 Transfer 发生时，钱包（如 MetaMask）或市场（如 OpenSea）就知道该更新显示了
    //事件：当 NFT 发生转移时触发
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    //事件：当某个地址被授权管理特定 NFT 时触发
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    //事件：当所有者授权某人管理其名下所有 NFT 时触发
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    //函数: 定义了外部如何与合约交互。例如，balanceOf 用来查某人有多少个币，ownerOf 用来查某个币归谁所有
    //查看余额和所有权
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    //授权机制
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    //转移机制
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}
//这是接受者接口，这个接口用于安全地向合约发送NFT
//当你使用 safeTransferFrom 转账时，代码会检查接收方是不是合约。如果是，就调用这个函数。如果接收方合约没有这个函数，交易就会失败，从而保护资产
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}
//合约状态与变量
//这是 SimpleNFT 合约的主体开始，定义了存储数据的变量。
contract SimpleNFT is IERC721 {
    // NFT 集合名称，如 "Bored Ape Yacht Club"
    string public name;
    // 代币符号，如 "BAYC"
    string public symbol;
    // 用于生成唯一的 Token ID
    uint256 private _tokenIdCounter = 1;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => string) private _tokenURIs;
   
    //构造函数：部署时初始化名称和符号
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }
    //查询某人拥有多少个 NFT
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }
    //查询某个 Token 的拥有者
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }
    //授权：允许某人转移特定的 Token
    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "Already owner");
        // 只有所有者本人，或者被授权管理所有资产的人，才能进行单次授权
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    //查看某个 Token 被授权给了谁
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }
    //设置操作员：允许某人管理你名下的所有 NFT
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    // 检查某人是否是你授权的操作员
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    //转移与安全转移
    // 普通转移：直接转走
    function transferFrom(address from, address to, uint256 tokenId) public override {
        //检查调用者是否有权限
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }
    // 安全转移 (不带数据)：调用带数据的版本
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        safeTransferFrom(from, to, tokenId, "");
    }
    // 安全转移 (带数据)：核心安全逻辑
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, data);
    }
    
    // 铸造与内部逻辑
    // 铸造函数：生成新的 NFT
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = uri;

    // 从 0 地址转移过来，代表“铸造”
        emit Transfer(address(0), to, tokenId);
    }
    // 获取元数据链接
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }
    // --- 内部转移逻辑 ---
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Zero address");
    // 更新余额
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
    //转移后清除之前的授权（为了安全，新主人需要重新授权）
        delete _tokenApprovals[tokenId];
        emit Transfer(from, to, tokenId);
    }
    // --- 内部安全转移逻辑 --- 
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);// 先执行普通转移
        // 检查接收方是不是合约，如果是，必须实现 onERC721Received
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
    }
    // 权限检查辅助函数
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
    // 安全检查辅助函数：通过底层调用检查接收者
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) {// 如果接收地址有代码（是合约）
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch {
                return false;// 调用失败，返回 false
            }
        }
        return true;// 如果是普通地址（EOA），直接返回 true
    }
}

