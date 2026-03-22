// SPDX-License-Identifier: MIT
// 这个合约的使用许可证是MIT（就像玩具的使用说明书授权，随便用、随便改）
pragma solidity ^0.8.19;
// 告诉电脑要用Solidity编程语言的0.8.19版本来运行这个合约

interface IERC721 {
    // 定义NFT的通用规则（就像所有收藏卡都要遵守的"游戏规则"）
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    //卡片转移通知（公告：XX把第123号卡转给了YY）
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // 授权通知（公告：XX允许YY帮他管第123号卡）
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    // 批量授权通知（公告：XX允许YY帮他管所有卡/取消授权）

    function balanceOf(address owner) external view returns (uint256);
    // 查某个人有多少张收藏卡（比如查小明有3张卡）
    function ownerOf(uint256 tokenId) external view returns (address);
    // 查某张卡属于谁（比如查第123号卡是小明的）

    function approve(address to, uint256 tokenId) external;
    //授权某人管某一张卡（小明允许小红帮他管第123号卡）
    function getApproved(uint256 tokenId) external view returns (address);
    // 查某张卡被授权给谁管（查第123号卡授权给了小红）

    function setApprovalForAll(address operator, bool approved) external;
    //批量授权/取消授权（小明允许/禁止小刚管他所有的卡）
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    //查某人是否能管另一个人的所有卡（查小刚能不能管小明的所有卡）

    function transferFrom(address from, address to, uint256 tokenId) external;
    // 普通转移卡片（把第123号卡从小明转给小红）
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    // 安全转移卡片（简单版，确保卡片能安全到账）
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    //安全转移卡片（带备注版，比如附言"送给小红的生日礼物"）
}

interface IERC721Receiver {
    //定义"能接收NFT的合约"要遵守的规则（比如某个合约想收卡，必须有这个功能）
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
    // 合约收到卡后要执行的检查（确认合约认识这张卡，不会弄丢）
}

//  第二部分：具体的NFT收藏卡系统（SimpleNFT）
contract SimpleNFT is IERC721 {
    //创建一个叫SimpleNFT的收藏卡系统，遵守上面的NFT通用规则
    string public name;   // NFT收藏名称（比如"奥特曼限量卡"）
    string public symbol; // 收藏卡简称（比如"ATM"）

    uint256 private _tokenIdCounter = 1; // 卡片ID计数器（从1开始，每张卡有唯一ID：1、2、3...）

    mapping(uint256 => address) private _owners; // 卡片归属表：第123号卡 → 小明的地址
    mapping(address => uint256) private _balances; // 个人卡数量：小明的地址 → 3张
    mapping(uint256 => address) private _tokenApprovals;  // 单卡授权表：第123号卡 → 小红（授权小红管）
    mapping(address => mapping(address => bool)) private _operatorApprovals; // 批量授权表：小明 → 小刚 → true（小刚能管小明所有卡）
    mapping(uint256 => string) private _tokenURIs; // 卡片信息链接：第123号卡 → "https://xxx.com/卡的图片和介绍"

    // 构造函数：创建收藏卡系统时的初始化
    constructor(string memory name_, string memory symbol_) {
        // 创建系统时，设置收藏卡的名称和简称
        name = name_; // 比如设置名称为"奥特曼限量卡"
        symbol = symbol_; // 比如设置简称为"ATM"
    }

    // 返回一个地址拥有多少NFT（查某人有多少张卡）
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address");
        // 检查要查的人不是"空地址"（不存在的人），否则提示"地址无效"
        return _balances[owner];
        // 返回这个人的卡数量（比如小明有3张就返回3）
    }

    // 给定一个代币ID，告诉你谁拥有它（查某张卡属于谁）
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        // 从卡片归属表中查这张卡的主人
        require(owner != address(0), "Token doesn't exist");
        // 检查这张卡存在（不是0地址=没人拥有=卡不存在），否则提示"卡片不存在"
        return owner;
        // 返回这张卡的主人地址（比如小明的地址）
    }

    // 临时交出钥匙（授权某人管某一张卡，不转移所有权）
    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId); // 先查这张卡的主人是谁
        require(to != owner, "Already owner");
        //检查授权的人不是主人自己（比如小明不能授权给自己管第123号卡），否则提示"已经是主人了"
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");
        // 检查操作的人是卡的主人，或者是被授权管主人所有卡的人，否则提示"没权限"

        _tokenApprovals[tokenId] = to;
        // 在单卡授权表中记录：这张卡授权给to这个人管
        emit Approval(owner, to, tokenId);
        // 发公告：XX（主人）授权XX（to）管第123号卡
    }

    // 检查谁被批准转移特定代币（查某张卡授权给谁管）
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        // 检查这张卡存在，否则提示"卡片不存在"
        return _tokenApprovals[tokenId];
        // 返回这张卡被授权的人地址（比如小红）
    }

    // 让用户批准或撤销给定操作员（批量授权/取消授权管所有卡）
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        // 检查不能授权给自己管自己的卡，否则提示"不能授权给自己"
        _operatorApprovals[msg.sender][operator] = approved;
        // 在批量授权表中记录：我（msg.sender）允许/禁止operator管我所有的卡
        emit ApprovalForAll(msg.sender, operator, approved);
        // 发公告：XX允许/禁止XX管他所有的卡
    }

    // 检查操作员是否被批准管理某人拥有的所有NFT（查某人能不能管另一个人的所有卡）
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
        //返回批量授权表中的结果（true=能管，false=不能管）
    }

    // 代币转移：只有所有者或被批准的人可以这样做（普通转卡）
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        // 检查操作的人有权限（是主人/被授权管这张卡/被授权管所有卡），否则提示"没权限"
        _transfer(from, to, tokenId);
        //执行实际的转卡操作（调用下面的_internal转移函数）
    }

    // 安全转移的简化版本（快捷方式），传入空数据负载（简单版安全转卡）
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        safeTransferFrom(from, to, tokenId, "");
        // 调用带备注的安全转卡函数，备注为空（比如没话要说）
    }

    // 安全转移（带数据）：实际工作（带备注的安全转卡）
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        // 检查操作的人有权限，否则提示"没权限"
        _safeTransfer(from, to, tokenId, data);
        // 执行安全转卡操作（调用下面的_internal安全转移函数）
    }

    // 铸造NFT（生成新的收藏卡）
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;
        // 给新卡分配ID（比如计数器是1，就分配ID=1；用完后计数器+1，下次是2）
        _tokenIdCounter++;

        _owners[tokenId] = to;
        // 在卡片归属表中记录：这张新卡属于to这个人（比如小明）
        _balances[to] += 1;
        // 把to的卡数量+1（比如小明原来有2张，现在3张）
        _tokenURIs[tokenId] = uri;
        // 记录这张卡的信息链接（比如链接到卡的图片和介绍）

        emit Transfer(address(0), to, tokenId);
        // 发公告：从"空地址"（系统）生成了第123号卡，给了to这个人（相当于"发行新卡"）
    }

    // 获取给定NFT的元数据URL（查某张卡的信息链接）
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        // 检查这张卡存在，否则提示"卡片不存在"
        return _tokenURIs[tokenId];
        // 返回这张卡的信息链接（比如能看到卡的图片）
    }

    // 内部函数：transferFrom()和safeTransferFrom()的核心功能（实际转卡的逻辑）
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");
        // 检查from是这张卡的主人，否则提示"不是主人"
        require(to != address(0), "Zero address");
        // 检查to不是空地址（不存在的人），否则提示"地址无效"

        _balances[from] -= 1;
        //把from的卡数量-1（比如小明原来3张，现在2张）
        _balances[to] += 1;
        // 把to的卡数量+1（比如小红原来1张，现在2张）
        _owners[tokenId] = to;
        // 更新卡片归属表：这张卡现在属于to

        delete _tokenApprovals[tokenId];
        // 删除这张卡的旧授权（比如原来授权小红管，转卡后授权失效）
        emit Transfer(from, to, tokenId);
        // 发公告：XX把第123号卡转给了XX
    }

    // 内部函数：执行安全转移（确保卡能安全到账）
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        // 先执行普通转卡操作
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
        // 检查接收方能不能安全收卡（如果是合约地址，要确认合约能处理这张卡），否则提示"接收方不能收NFT"
    }

    // 守门员函数：检查调用者是否被允许移动这个代币（权限检查）
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        // 查这张卡的主人
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
        // 返回是否有权限：
        // 1. spender是卡的主人 → 有权限；
        // 2. spender被授权管这张卡 → 有权限；
        // 3. spender被授权管主人所有的卡 → 有权限；
        // 以上满足一个就返回true（有权限），否则false（没权限）
    }

    // 安全检查：检查是否是在向知道如何处理NFT的智能合约发送这个NFT
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) {
            // 如果接收方是合约地址（有代码），而不是普通钱包（没代码）
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                // 尝试调用合约的"收卡检查函数"，看合约能不能处理这张卡
                return retval == IERC721Receiver.onERC721Received.selector;
                // 检查合约返回的结果是否正确（正确=能收卡，返回true）
            } catch {
                // 如果调用失败（合约不能处理这张卡），返回false
                return false;
            }
        }
        return true;
        // 如果接收方是普通钱包（不是合约），直接返回true（钱包能安全收卡）
    }
}