// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//the interface: to tell the Ethereum（it's a platform）,"hi, I am a NFT contract, these are the functions I have"
//这是ERC-721接口，它定义了NFT合约必须实现的所有强制函数和事件，才能被称为"ERC-721兼容"
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

    //为什么这两个函数是一样的？
    //这个叫做函数的重载，名字一样不要紧，编译器会根据传入的参数个数、参数类型知道调用哪一个
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

//这个接口用于安全的向合约转移NFT

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract SimpleNFT is IERC721{
    //NFC的名字和代号
    string public name;
    string public symbol;

    //用于记录当前NFT的数量，不从0开始是为了方便人类理解
    uint256 private _tokenIdCounter = 1;
    //代币X属于谁
    mapping(uint256 => address) private _owners;
    //谁拥有多少代币？
    mapping(address => uint256) private _balances;
    //代币X被批准让谁进行转移
    mapping(uint256 => address) private _tokenApprovals;
    //某人授权另一人管理所有的代币
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    //代币X所代表的东西，所谓的元数据，用URI表示，URI可能指向<https://my-nft-host.com/metadata/42.json>
    mapping(uint256 => string) private _tokenURIs;

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }
    //这个指的是NFT的拥有者而不是合同的拥有者
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }

    //查询一个代币的拥有者是谁
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    //授权可转移代币
    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "Already owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        //更新能转移代币的人，这里之前的approval就没有了，那她转移不需要经过原主人的同意吗？
        _tokenApprovals[tokenId] = to;

        //前端监听这些事件以保持它们的UI同步
        emit Approval(owner, to, tokenId);
    }

    //查询某个代币允许被谁转移
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    //设置默认接管自己的所有代币
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    //内部调用函数前面有个_, transferFrom()和safeTransferFrom()要调用它
    //为什么用户不能直接调用它，因为太不安全，它不执行权限检查，如"调用者被批准转移这个代币吗？"
    //但是这些检查在外部函数（`transferFrom()`或`safeTransferFrom()`）中
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");
        //我们也阻止转移到**零地址**——这就像将NFT发送到数字黑洞。
        //只有铸造（创建新NFT）应该使用零地址作为`from`。
        require(to != address(0), "Zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        //新的关键字delete，指的是彻底清除这个代币的Mapping映射
        delete _tokenApprovals[tokenId];
        emit Transfer(from, to, tokenId);
    }


    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        //如果`to`是普通钱包，工作正常。
        //当`to`是智能合约时额外安全。
        //如果合约不支持ERC-721则回滚，为什么放在已经转移的后面？
        //因为是内部调用的函数，所以没关系，失败了之前的所有的操作比如balances[from] -= 1;都会恢复，这就是“回滚”
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    //安全检查，检查我们是向能处理ERC721代币的合约转账
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
    //如果code大于0说明是合约因为钱包地址的code为0
        if (to.code.length > 0) {
            //try是指尝试可能错误的操作与catch一起用，如果失败了就执行catch后面的代码
            //IERC721Receiver是一个类型转换，类似string（），将地址转换为一个IERC721Receiver接口类型的合约
            //onERC721Received应该存在于对方的合约中
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch {
                return false;
            }
        }

        return true;
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
    
    //铸造代币
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }
    

}