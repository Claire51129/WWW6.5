// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title IERC721接口（简化版）
 * @dev 定义ERC721必须实现的事件和函数
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
 * @title 接收NFT的合约接口
 * @dev 防止NFT发送到不支持的合约中导致资产丢失
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
 * @title SimpleNFT
 * @dev 手写实现ERC721核心逻辑（教学版）
 */
contract SimpleNFT is IERC721 {

    // NFT集合名称
    string public name;

    // NFT集合符号
    string public symbol;

    // 合约拥有者（用于权限控制）
    address public owner;

    // tokenId计数器（从1开始）
    uint256 private _tokenIdCounter = 1;

    // tokenId => 拥有者地址
    mapping(uint256 => address) private _owners;

    // 地址 => 持有NFT数量
    mapping(address => uint256) private _balances;

    // tokenId => 单个授权地址
    mapping(uint256 => address) private _tokenApprovals;

    // owner => (operator => 是否授权)
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // tokenId => 元数据URI
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev 构造函数，初始化NFT名称和符号
     */
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
        owner = msg.sender;
    }

    /**
     * @dev 仅限合约拥有者调用
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /**
     * @dev 查询某地址持有的NFT数量
     */
    function balanceOf(address owner_) public view override returns (uint256) {
        require(owner_ != address(0), "Zero address");
        return _balances[owner_];
    }

    /**
     * @dev 查询NFT的拥有者
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner_ = _owners[tokenId];
        require(owner_ != address(0), "Token doesn't exist");
        return owner_;
    }

    /**
     * @dev 授权某地址操作指定NFT
     */
    function approve(address to, uint256 tokenId) public override {
        address owner_ = ownerOf(tokenId);

        require(to != owner_, "Already owner");
        require(
            msg.sender == owner_ || isApprovedForAll(owner_, msg.sender),
            "Not authorized"
        );

        _tokenApprovals[tokenId] = to;

        emit Approval(owner_, to, tokenId);
    }

    /**
     * @dev 查询某NFT的授权地址
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev 设置全局授权（operator）
     */
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");

        _operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev 查询是否为全局授权
     */
    function isApprovedForAll(address owner_, address operator) public view override returns (bool) {
        return _operatorApprovals[owner_][operator];
    }

    /**
     * @dev 转移NFT
     */
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }

    /**
     * @dev 安全转移（无数据）
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev 安全转移（带数据）
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev 铸造NFT（仅Owner）
     */
    function mint(address to, string memory uri) public onlyOwner {
        require(to != address(0), "Zero address");

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev 销毁NFT（仅拥有者）
     */
    function burn(uint256 tokenId) public {
        address owner_ = ownerOf(tokenId);
        require(msg.sender == owner_, "Not owner");

        _balances[owner_] -= 1;
        delete _owners[tokenId];
        delete _tokenURIs[tokenId];

        emit Transfer(owner_, address(0), tokenId);
    }

    /**
     * @dev 获取NFT元数据
     */
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

    /**
     * @dev 内部转移逻辑
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        delete _tokenApprovals[tokenId];

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev 安全转移逻辑
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal {
        _transfer(from, to, tokenId);

        require(
            _checkOnERC721Received(from, to, tokenId, data),
            "Not ERC721Receiver"
        );
    }

    /**
     * @dev 判断调用者是否有权限操作NFT
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner_ = ownerOf(tokenId);

        return (
            spender == owner_ ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner_, spender)
        );
    }

    /**
     * @dev 检查接收方是否支持ERC721
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(
                msg.sender,
                from,
                tokenId,
                data
            ) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev ERC165接口支持（简化版）
     */
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId;
    }
}
