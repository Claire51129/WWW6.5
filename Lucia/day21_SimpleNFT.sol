// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC721{
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed wner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns(uint256);
    function ownerOf(uint256 tokenId) external view returns(address);

    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address);

    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns  (bool);

    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}

interface IERC721Receiver{
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

//定义了两个interface，IERC721我是谁 标准协议
//IERC721Receiver对方是谁 接收协议，给你转账的目标地址用，确认转账目标地址能处理NFT，需要用onERC721Received函数

contract SimpleNFT is IERC721{
    //abstract 抽象合约无法部署，已经删除
    string public name;
    string public symbol;

    uint256 private _tokenIdCounter = 1;

    mapping(uint256 => address) private _owners;
    mapping(address =>uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => string) private _tokenURIs;

    constructor(string memory name_, string memory symbol_){
        name = name_;
        symbol = symbol_;
    }

    function balanceOf(address owner) public view override returns (uint256){
        require(owner != address(0), "zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address)
    {
    address owner = _owners[tokenId];
    require(owner != address(0), "Token doesn't exist");

    return owner;
    }

    function approve(address to, uint256 tokenId) public override{
        address owner = ownerOf(tokenId);
        require(to !=owner, "Already owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authroized");
        
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
           
    }

    function getApproved(uint256 tokenId) public view override returns (address){
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        _operatorApprovals[msg.sender][operator] = approved;
        //第一个[]是Owner,第二个[]是Operator，mapping（address=>mapping(address =>bool))
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns(bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }


    function safeTransferFrom(address from, address to, uint256 tokenId) public override{
        safeTransferFrom(from, to, tokenId, "");

    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, data);
    }

    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to] +=1;
        _tokenURIs[ tokenId] = uri;

        emit Transfer(address(0), to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view returns(string memory){
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];

    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual{
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Zero address");

        _balances[from] -=1;
        _balances[to] +=1;
        _owners[tokenId] =to;

        delete _tokenApprovals[tokenId];
        //delete作用于mapping，相当于重置到初始值
        emit Transfer(from, to ,tokenId);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual{
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner= ownerOf(tokenId);
        return(spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool){
        if (to.code.length > 0){
            //to.code.length > 0是合约地址，普通用户钱包地址是没有代码的
            //.code是从区块链状态中读取该地址关联的字节码
            //逻辑越多，字节码就越长，一个合约的字节码最大不能超过24KB
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns(bytes4 retval){
                return retval == IERC721Receiver.onERC721Received.selector;
            //selector是一个由函数名和参数哈希后取前4字节哈希，如果对方返回的retval正好等于这个暗号，说明对方不仅是一个合约还是一个专门设计用来接收NFT的合约
            //接口-函数-属性访问器
            } catch {
                return false;
            }
            //if-else 判断本地变量或条件 如果if的代码报错整个交易直接Revert回滚
            //try-catch 处理外部合约调用的结果，如果外部合约报错，本地合约不会死，而是进catch，用于跨合约交互，防止对方合约出问题拖累自己 
        }
        return true;
    }

}