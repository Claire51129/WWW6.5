// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//ERC-721接口
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

//接口用于安全地向合约发送NFT
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

//承诺包含IERC721接口中定义的所有函数
contract SimpleNFT is IERC721 {
    //任何人都可以调用函数来询问名称或符号
    string public name;
    string public symbol;

    //每次铸造NFT分配ID
    uint256 private _tokenIdCounter = 1;

    mapping(uint256 => address) private _owners;   //#X的NFT由该所有者地址拥有
    mapping(address => uint256) private _balances; //某地址拥有多少NFT
    mapping(uint256 => address) private _tokenApprovals;//给某人临时权限将NFT交给买家
    mapping(address => mapping(address => bool)) private _operatorApprovals;//给某地址权限管理我所有的NFT
    mapping(uint256 => string) private _tokenURIs; //存储每个代币的元数据URL

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    //返回一个地址拥有多少NFT
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }

    //返回某ID的NFT拥有者地址
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    //特定的人权限来转移这个特定的代币
    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);//确认拥有者
        require(to != owner, "Already owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");//只有授权用户可以分配特定代币的权限

        _tokenApprovals[tokenId] = to;//保存批准，信息存储在_tokenApprovals映射中
        emit Approval(owner, to, tokenId);
    }

    //检查批准
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    //批准或撤销给定操作员对他们所有NFT的访问权限。
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    //检查操作员是否被批准管理某人拥有的所有NFT
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _transfer(from, to, tokenId);//调用_transfer
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, data);//调用_safetransfer
    }

    //铸造NFT
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = uri;//储存元数据

        emit Transfer(address(0), to, tokenId);//触发事件从零地址发出Transfer
    }

    //获取给定NFT的元数据
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Zero address");

        _balances[from] -= 1;//更新发送者余额
        _balances[to] += 1; //更新接收者余额
        _owners[tokenId] = to;//更新所有权

        delete _tokenApprovals[tokenId];//清除旧批准信息
        emit Transfer(from, to, tokenId);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");//如果接受者合约不支持ERC-721则回滚
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        //调用的人是代币的实际所有者/移动一个权限/管理所有权限
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) {  //接收者是智能合约
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) { //尝试调用合约应该实现的函数
                return retval == IERC721Receiver.onERC721Received.selector;//调用成功返回true
            } catch {//捕获失败
                return false;
            }
        }
        return true;
    }
}

