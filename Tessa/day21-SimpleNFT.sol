// 一个数字卡片系统，每张卡都有唯一编号、主人和内容
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 接口：规则说明书——NFT世界的“法律”
interface IERC721 {    //NFT规则
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);   //事件广播：这张卡从谁→给谁
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);    //事件广播：授权别人操作你的卡
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);   //时间广播：授权“全部卡”

    // 必须实现的函数
    function balanceOf(address owner) external view returns (uint256);    //查你有多少卡
    function ownerOf(uint256 tokenId) external view returns (address);    //查这张卡是谁的

    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address);

    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// 防丢卡机制
interface IERC721Receiver {    //用来检查接收方会不会处理NFT
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);   //如果返回正确值，可以安全接受NFT
}    //否则NFT可能丢失

// 正式开始：SimpleNFT
contract SimpleNFT is IERC721 {    //这个合约实现了NFT标准
    string public name;    //名字
    string public symbol;    //符号

    uint256 private _tokenIdCounter = 1;    //NFT编号计数器：从1开始编号

    // 【核心】最重要的5个“数据盒子”
    mapping(uint256 => address) private _owners;    //谁拥有哪张卡
    mapping(address => uint256) private _balances;    //每人有多少卡
    mapping(uint256 => address) private _tokenApprovals;    //单个授权
    mapping(address => mapping(address => bool)) private _operatorApprovals;    //全部授权
    mapping(uint256 => string) private _tokenURIs;    //NFT内容

    // 构造函数（构建NFT项目）
    constructor(string memory name_, string memory symbol_) {    //设置NFT名字+简称
        name = name_;
        symbol = symbol_;
    }

    // 查询函数
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");    // 地址不能是空的
        return _balances[owner];    //返回NFT数量
    }

    // 找主人
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");    //必须存在
        return owner;
    }

    // 【重点】授权系统
    function approve(address to, uint256 tokenId) public override {    //approve(单个授权)
        address owner = ownerOf(tokenId);     //找真正主人
        require(to != owner, "Already owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");   //必须是本人/管理员

        _tokenApprovals[tokenId] = to;    //设置授权
        emit Approval(owner, to, tokenId);
    }

    // 查某张卡授权给谁
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    // 【重点！】
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        _operatorApprovals[msg.sender][operator] = approved;   //我允许你操作我所有NFT
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 查询是否被授权
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // 【核心】转账系统
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");   //必须是主人or被授权人
        _transfer(from, to, tokenId);   //真正转账
    }

    // 安全版
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {   //调用带data的版本
        safeTransferFrom(from, to, tokenId, "");    //安全转账（会检查接收方）
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, data);
    }

    // mint:铸造NFT
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;    //生成ID
        _tokenIdCounter++;    //+1

        _owners[tokenId] = to;    //设置主人
        _balances[to] += 1;    //增加数量
        _tokenURIs[tokenId] = uri;    //设置内容

        emit Transfer(address(0), to, tokenId);    //表示“从空气创建”
    }

    // 返回NFT内容
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

    // 【核心内部函数】_transfer
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");    //必须是主人
        require(to != address(0), "Zero address");

        _balances[from] -= 1;    //更新数量
        _balances[to] += 1;
        _owners[tokenId] = to;    //换主人

        delete _tokenApprovals[tokenId];    //清除旧授权
        emit Transfer(from, to, tokenId);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);    //先转
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");    //再检查接收方
    }

    // 权限判断（超级重要）
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {   //判断是不是：主人/被授权人/管理员
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    // 防NFT丢失机制（高级）
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) {    //如果接收方是合约
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {   //调用它的函数
                return retval == IERC721Receiver.onERC721Received.selector;   //必须返回正确值
            } catch {
                return false;    //否则转账失败（防止NFT被锁死）
            }
        }
        return true;
    }
}




// 1、NFT三要素：ID+Owner+uri；
// 2、两个最重要mapping： _owners→谁拥有；_balances→拥有多少；
// 3、授权机制：approve→单个授权；setApprovalForAll→全部授权；
// 4、安全转账：safeTransferFrom→防止NFT丢失