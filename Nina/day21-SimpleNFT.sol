// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC721 {
    // 事件
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId); // 单笔授权事件。当你允许某人（approved）操作你名下的某个 NFT（tokenId）时，发出这个通知。
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved); // 全权委托事件。当你把名下所有该系列的 NFT 都授权给一个代理人（operator）管理时，发出通知。

    // 查询功能
    function balanceOf(address owner) external view returns (uint256); // 输入一个钱包地址，返回这个地址一共拥有多少个这个系列的 NFT。
    function ownerOf(uint256 tokenId) external view returns (address); // 输入一个 NFT 的编号，返回这个 NFT 现在的主人是谁。

    // 授权功能
    function approve(address to, uint256 tokenId) external; // 你授权某个地址（to）可以操作你的某一个 NFT。
    function getApproved(uint256 tokenId) external view returns (address); // 查询某个具体的 NFT 现在被授权给谁了。

    function setApprovalForAll(address operator, bool approved) external; // 全权委托。把你的“整箱”NFT 都交给某个代理人（比如 OpenSea 的智能合约）。true 是开启，false 是撤销。
    function isApprovedForAll(address owner, address operator) external view returns (bool); // 查询某人是否拥有操作另一人所有 NFT 的权限。

    // 所有权转移
    function transferFrom(address from, address to, uint256 tokenId) external; // 最基础的转账。从 from 发送到 to。通常由获得授权的第三方（比如交易所）调用。
    function safeTransferFrom(address from, address to, uint256 tokenId) external; // 安全转账。它比上面的多了一步检查：如果接收方（to）是一个合约地址，它会确认那个合约是否有能力接收 NFT。如果没有这个检查，NFT 可能会掉进一个“只会进不会出”的死合约里，导致永久丢失。
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external; // 安全转账二。带额外参数 data
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}
// 这个接口用于安全地向合约发送NFT。没有它，如果你试图将NFT转移到无法处理它的智能合约，NFT可能会被卡住。所以我们检查接收合约知道如何处理NFT。

contract SimpleNFT is IERC721 {
    string public name;
    string public symbol;

    uint256 private _tokenIdCounter = 1;

    mapping(uint256 => address) private _owners; // 没有所有者=没有代币
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals; // 某人被授权操作某枚NFT
    mapping(address => mapping(address => bool)) private _operatorApprovals; // 某人被授权操作某人的全部NFT
    mapping(uint256 => string) private _tokenURIs; // 这个映射存储每个代币的元数据URI

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
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
    // 不是单独批准每个代币，这让用户批准或撤销给定操作员（例如，市场或金库合约）对他们所有NFT的访问权限。approved需要输入true或false。

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
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

    // 获取给定NFT的元数据URI——图像、描述等
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

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) { // 钱包地址没有代码，但合约有。如果to.code.length > 0，则接收者是智能合约。
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) { // （1）try...catch：尝试性操作。 （2）IERC721Receiver(to)：类型转换，把to这个普通的地址转换为【实现了 IERC721Receiver 接口的合约】类型。（3）.onERC721Received：发起调用。（4）retval：返回值。
                return retval == IERC721Receiver.onERC721Received.selector; // 如果返回值（retval）与预期值（特定的选择器）完全一致时，说明to是一个能处理转账操作的合约。
            } catch {
                return false;
            }
        }
        return true;
    }
}

