// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// 以下列出的几个都是IERC721的必须函数
interface IERC721 is IERC165{
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // 查询某个地址持有的NFT数量
    // 如果owner == address(0)，通常需要revert
    function balanceOf(address owner) external view returns (uint256);
    // 查询某个代币NFT的当前所有者地址
    function ownerOf(uint256 tokenId) external view returns (address);

    // 授权某个地址可以转移指定的单个NFT
    // Q：为啥需要授权？可能会有授权帮忙代理销售的情况？
    // 权限检查：tokenID的所有者 或者 已被授权的“操作员”
    function approve(address to, uint256 tokenId) external;
    // 查询某个NFT被授权的地址
    function getApproved(uint256 tokenId) external view returns (address);

    // 批量授权或者撤销授权，允许操作员管理 调用者 的所有NFT
    // 调用者不能授权自己
    function setApprovalForAll(address operator, bool approved) external;
    // 查询操作员是否有权限管理 owner的所有NFT
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // 不安全的转移NFT，不检查接收方是否支持NFT，当转移至未实现onERC721Received的合约是，可能会导致NFT被永久锁定
    function transferFrom(address from, address to, uint256 tokenId) external;
    // 安全的转移NFT所有权，从from 转移给to
    // 该方法会检查1.from是否是指定NFT的所有者；2.检查to的合理性；3. 如果to是合约，会调用其onERC721Received验证该合约可以处理NFT
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    // 携带附加数据data（传递给接收方合约
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract SimpleNFT is IERC721 {
    string public name;
    string public symbol;

    uint256 private _tokenIdCounter = 1;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => string) private _tokenURIs;

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // ========== ERC165 实现（必需） ==========
    function supportsInterface(bytes4 interfaceId) public view override(IERC165) returns (bool) {
        // 使用硬编码的接口ID，避免依赖计算
        bytes4 IERC721_ID = 0x80ac58cd;  // IERC721 的接口ID
        bytes4 IERC165_ID = 0x01ffc9a7;  // IERC165 的接口ID
        
        return interfaceId == IERC721_ID || interfaceId == IERC165_ID;
    }
    

    function balanceOf(address account) public view override returns (uint256) {
        require(account != address(0), "ERC721: balance query for zero address");
        return _balances[account];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "Already owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
    }

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

    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        delete _tokenApprovals[tokenId];
        emit Transfer(from, to, tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
}

/**
知识点：
关于mint函数：
    mint函数的作用是从无到有的创建新的NFT，具体包括4个关键动作：
    （1）分配唯一标识符，本合约中使用_tokenIdCounter 变量来跟踪并递增编号
    （2）确定所有权，这里传入的 to，最后将成为NFT的所有者
    （3）绑定元数据，将NFT关联到一个具体的元数据地址
    （4）发出官方信号，发出transfer事件
在 SimpleNFT 合约中，示例的 mint 函数被设置为 public（任何人都能调用），但在真实的商业项目中，
通常会通过 onlyOwner 访问控制来限制铸造权限，或者要求用户支付一定的费用才能进行铸造

一个NFT的完整生命流程：
1. 部署合约
2. Alice mint FNT
3. 检查NFT的所有权
4. Alice 批准Bob 转移
5. Bob执行转账给Charlie
6. 验证结果

 */