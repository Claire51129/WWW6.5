// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC721 {
    //定义了NFT合约必须实现的所有强制函数和事件，才能被称为"ERC-721兼容"。
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    //当 NFT 从 from 转移到 to 时触发。这是最核心的事件，tokenId 是这个 NFT 的唯一编号
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    //当你授权某个人可以操作你的某一个 NFT 时触发
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    //当你授权某个中介（比如 OpenSea 的合约）操作你名下所有的 NFT 时触发

    function balanceOf(address owner) external view returns (uint256); //查询某人手里一共有多少个 NFT
    function ownerOf(uint256 tokenId) external view returns (address);//查询这个特定的 NFT 现在在谁手里

    function approve(address to, uint256 tokenId) external; //临时把编号为 tokenId 的 NFT 操纵权给 to。注意：一个 NFT 同一时间只能有一个被授权人
    function getApproved(uint256 tokenId) external view returns (address); //查看这个 NFT 现在被授权给谁了

    function setApprovalForAll(address operator, bool approved) external; //这是一个“大开口”授权。如果 approved 为 true，那么 operator（操作员）可以搬走你钱包里这个系列的所有 NFT
    function isApprovedForAll(address owner, address operator) external view returns (bool); //查询 operator 是否拥有 owner 所有 NFT 的操作权限

    function transferFrom(address from, address to, uint256 tokenId) external; //强制转移。把 NFT 从 A 移到 B。调用者必须是 Owner 本人或者得到了授权
    function safeTransferFrom(address from, address to, uint256 tokenId) external; //它在转移之前会多做一步检查：如果接收方 to 是一个合约地址，它会检查该合约是否支持 NFT（即是否实现了 onERC721Received 接口）
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external; //允许在转移的同时向接收合约发送额外的指令数据
}
interface IERC721Receiver {
    //收货确认协议
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4); //接口用于安全地向合约发送NFT
    //operator 谁发起的转账（可能是 Owner，也可能是被授权的第三方）
    // from NFT 原来的主人是谁
    //bytes calldata data  随转账附带的额外指令数据
    //这个函数必须返回一个特定的 4 字节值：IERC721Receiver.onERC721Received.selector 接收合约必须明确返回这个值
}
contract SimpleNFT is IERC721{
    //承诺包含IERC721接口中定义的所有函数
    string public name; //"加密猫"
    string public symbol; //"CAT"

    uint256 private _tokenIdCounter = 1; //分配ID

    mapping(uint256 => address) private _owners; //存储拥有给定代币ID的人的地址
    mapping(address => uint256) private _balances; //一个地址拥有多少总NFT
    mapping(uint256 => address) private _tokenApprovals; //地址xx被批准转移代币
    mapping(address => mapping(address => bool)) private _operatorApprovals;//第一个address是授权者，允许第二个地址操作员是否进行操作_operatorApprovals[Alice][Bob] = true,Bob被允许移动Alice拥有的任何NFT
    mapping(uint256 => string) private _tokenURIs; //映射存储每个代币的元数据URL

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
        //设置NFT收藏的名称和符号
    }
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
        //返回一个地址拥有多少NFT
    }
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
        //给定一个代币ID，这告诉你谁拥有它
    }
    function approve(address to, uint256 tokenId) public override {
    address owner = ownerOf(tokenId);
    require(to != owner, "Already owner");//不批准自己转移自己的代币
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

    _tokenApprovals[tokenId] = to;
    emit Approval(owner, to, tokenId);
    }
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId]; //检查谁被批准转移特定代币
    }
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval"); ////不批准自己转移自己的代币
        _operatorApprovals[msg.sender][operator] = approved; //用户批准撤销操作员
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator]; //检查操作员是否被批准管理某人拥有的所有NFT
    }
    function _transfer(address from, address to, uint256 tokenId) internal virtual { //only合约内部的安全函数调用。virtual：允许子合约重写它。
        require(ownerOf(tokenId) == from, "Not owner"); //from地址是这个代币的所有者吗
        require(to != address(0), "Zero address"); //阻止转移到零地址

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to; //更改所有权

        delete _tokenApprovals[tokenId]; //清除旧批准
        emit Transfer(from, to, tokenId);
        //最终用户直接调用不安全&&不执行权限检查&7假设这些检查已经在外部函数（transferFrom()或safeTransferFrom()）中发生了。
    }
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
    _transfer(from, to, tokenId);
    require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver"); //添加一个关键检查,如果检查失败，整个转移被回滚
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
    address owner = ownerOf(tokenId);
    return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    //spender == owner → 调用的人是代币的实际所有者
    //getApproved(tokenId) == spender → 代币所有者给了这个特定的人移动这一个代币的权限。
    //isApprovedForAll(owner, spender) → 代币所有者说，"这个人可以管理我所有的代币。"
    }
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) { //_safeTransfer使用的安全检查
        if (to.code.length > 0) { //if true then  it is 智能合约， 外部账户 (EOA)（如你的 MetaMask）和 合约账户。EOA：没有代码，code.length 为 0。
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
                } catch {
                    return false;
                }
        }
        return true;
    //尝试通信：try ... catch
    //当目标合约返回的 retval 严格等于这个标准暗号时，函数才认为它是安全的
    //目标合约根本没有这个函数，或者在执行时崩溃（Revert）了，catch 块会捕获到这个失败，并返回 false
    }
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
    safeTransferFrom(from, to, tokenId, "");
    //快捷方式-不想包含任何额外数据时，只需调用这个
    }
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
    require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
    _safeTransfer(from, to, tokenId, data);
    }
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter; //分配唯一的tokenId
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = uri; //存储其元数据URI

        emit Transfer(address(0), to, tokenId);
    }
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

}
