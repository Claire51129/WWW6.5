// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//IERC721 接口就像是一份合同承诺，它告诉区块链：“我的合约是一个标准的 NFT 合约，我保证支持上述所有权查询、授权和转移功能”
interface IERC721 {
    //Transfer（转移），uint256 indexed tokenId：被转移的那个 NFT 的唯一识别编号
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    //Approval  “授权”。表示针对某一个特定 NFT 的权限移交
    //address indexed approved：被授予权限的地址（临时）
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    //ApprovalForAll  “全部授权” 或 “授权所有”。表示所有者将其名下所有的 NFT 授权给一个代理人管理
    //address indexed operator：被信任的“操作员”地址
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

//balanceOf  “余额” 或 “查询余额”。
    function balanceOf(address owner) external view returns (uint256);
//查询特定编号（ID）的 NFT 归谁所有
    function ownerOf(uint256 tokenId) external view returns (address);

    //授权某人（如交易平台）可以操作你指定的某一个 NFT
    function approve(address to, uint256 tokenId) external;
    //返回目前被授权操作该特定代币的地址
    function getApproved(uint256 tokenId) external view returns (address);

    //允许一个操作员（Operator）管理你名下所有的 NFT
    function setApprovalForAll(address operator, bool approved) external;
    //检查某操作员是否获得了管理某主人所有资产的权限
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    //将 NFT 从一个钱包转移到另一个钱包。它会更新余额记录并重置该代币的授权状态
    function transferFrom(address from, address to, uint256 tokenId) external;
    //它在转移后会额外检查接收方是否为一个能够处理 NFT 的合约地址
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    //这个两个代码都是同一个意思，只是下面一个可以在转移的时候携带一些信息（data）
}

//“安全防火墙”
//一个收货确认系统。它强制要求作为接收方的智能合约必须出示一份“经营许可证”（即返回正确的选择器），证明自己有能力处理 NFT，否则 NFT 合约将拒绝发货
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

//"嘿Solidity，我们正在构建一个名为SimpleNFT的新合约，它将遵循ERC-721规则。"
contract SimpleNFT is IERC721 {
    string public name;
    string public symbol;//NFT 系列的代币符号或缩写

    uint256 private _tokenIdCounter = 1;//给NFT分配编码，从1开始

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;//一个地址拥有多少总NFT
    mapping(uint256 => address) private _tokenApprovals;//哪个地址被允许转账这枚编号为 X 的 NFT
    //我信任这个地址管理我所有的NFT——不仅仅是一个
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => string) private _tokenURIs;//这个映射存储每个代币的元数据URL
    //元数据链接就像是 NFT 的“数字身份证链接”。通过 tokenURI(uint256 tokenID) 函数，外部世界可以找到存储在 IPFS 上的 JSON 文件，从而看到这个 NFT 代表的真实面貌

//这就是在给你的 NFT 系列“取名字”和“定代号”，确保它在部署那一刻就拥有了唯一的身份标识
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }
//这返回一个地址拥有多少NFT
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }
//给定一个代币ID，这告诉你谁拥有它
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "Already owner");
        //  ||： 这是逻辑中的“或”运算符。这意味着只要符号左右两边的条件中有一个成立，整个权限检查就会通过
        //isApp：全局代理人（操作员）
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;//现在所有检查都通过了——我们继续保存批准
        emit Approval(owner, to, tokenId);
    }

//检查谁被批准转移特定代币。
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

//不是单独批准每个代币，这让用户批准或撤销给定操作员
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        _operatorApprovals[msg.sender][operator] = approved;//= approved：将状态设为 true（授权）或 false（撤销授权）
        emit ApprovalForAll(msg.sender, operator, approved);
    }
//只是检查操作员是否被批准管理某人拥有的所有NFT。
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
//将特定的 NFT 从一个钱包地址转移到另一个钱包地址
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

//铸造（Mint）函数。它的核心作用是在区块链上创造一个全新的、独一无二的 NFT，并将其分配给指定的拥有者
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;//生成唯一编号 (ID)
        _tokenIdCounter++;

        _owners[tokenId] = to;//编号为 tokenId 的 NFT 现在属于地址 to
        _balances[to] += 1;//将接收者 to 拥有的 NFT 总数加 1
        _tokenURIs[tokenId] = uri;//将这个特定的编号与你传入的链接（uri）绑定在一起


        emit Transfer(address(0), to, tokenId);
    }

    //获取特定 NFT 的元数据链接
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }

    //这是处理NFT从一个钱包到另一个钱包实际移动的核心函数
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Zero address");

        _balances[from] -= 1;//更新发送者的余额
        _balances[to] += 1;
        _owners[tokenId] = to;//更改所有权

        delete _tokenApprovals[tokenId];//如果有人之前被批准转移这个代币——我们删除该批准。
        //delete 是一个关键字，用于将某个变量或映射中的值重置为其类型的初始（默认）值
        emit Transfer(from, to, tokenId);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);//该行代码首先调用了底层的 _transfer 函数来完成账本的实际更新
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
        //_checkOnERC721Received 通常翻译为 “检查 ERC721 接收”
    }
//检查调用者是否有权利调用
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) {//接收者是智能合约吗
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;//这行代码检查目标合约返回的值（retval）是否等于预期的选择器（Selector）
            } catch {
                return false;//函数将返回 false。这会导致外部的 safeTransfer 函数触发 require 报错并使整个转账交易回滚，从而保护 NFT 不会被发送到一个不兼容的合约中
            }
        }
        return true;
        //try: 这是 Solidity 中的异常处理机制。它尝试执行一段代码，如果执行过程中发生错误，它不会让整个交易直接崩溃，而是进入下方的 catch 块处理
        //IERC721Receiver(to): 这将接收者地址 to 转换为 IERC721Receiver 接口类型，以便调用该接口中定义的标准函数
        //.onERC721Received(...): 这是合约尝试在目标地址上调用的函数。这被形象地比喻为“敲门”
    }
}

