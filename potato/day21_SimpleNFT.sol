// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ==========================================
// 1. 接收器接口 (供质押合约使用)
// ==========================================
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// ==========================================
// 2. 主 NFT 合约
// ==========================================
contract SimpleNFT {
    string public name;
    string public symbol;
    uint256 private _tokenIdCounter;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => string) private _tokenURIs;

    mapping(address => uint256[]) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Invalid address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    function mint(address to, string memory uri) public returns (uint256) {
        require(to != address(0), "Mint to zero address");
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        
        _owners[tokenId] = to;
        _balances[to]++;
        _tokenURIs[tokenId] = uri;

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
        
        return tokenId;
    }

    function batchMint(address to, string[] memory uris) public returns (uint256[] memory) {
        require(uris.length > 0 && uris.length <= 50, "Batch size must be between 1 and 50");
        uint256[] memory tokenIds = new uint256[](uris.length);
        for (uint256 i = 0; i < uris.length; i++) {
            tokenIds[i] = mint(to, uris[i]);
        }
        return tokenIds;
    }

    function burn(uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not owner nor approved");
        _tokenApprovals[tokenId] = address(0);
        _removeTokenFromOwnerEnumeration(owner, tokenId);
        _balances[owner]--;
        delete _owners[tokenId];
        delete _tokenURIs[tokenId];
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), "Index out of bounds");
        return _ownedTokens[owner][index];
    }

    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        return _ownedTokens[owner];
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // 授权函数
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "Not the owner");
        require(to != owner, "Approval to current owner");
        _tokenApprovals[tokenId] = to;
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved");
        _transfer(from, to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "Not the owner");
        require(to != address(0), "Invalid address");
        
        _tokenApprovals[tokenId] = address(0);
        
        _removeTokenFromOwnerEnumeration(from, tokenId);
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);

        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = _ownedTokens[from].length - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        _ownedTokens[from].pop();
        delete _ownedTokensIndex[tokenId];
    }
}

// ==========================================
// 3. 质押合约 (直接引用上面的 SimpleNFT)
// ==========================================
contract NFTStaking is IERC721Receiver {
    SimpleNFT public nftCollection; // 直接使用同一个文件里的 SimpleNFT 类型
    
    uint256 public rewardRatePerDay = 100;

    struct Stake {
        address owner;
        uint256 timestamp;
    }
    
    mapping(uint256 => Stake) public stakes;
    
    // 部署时传入 SimpleNFT 合约的地址
    constructor(address _nftAddress) {
        nftCollection = SimpleNFT(_nftAddress);
    }
    
    function stake(uint256 tokenId) external {
        require(nftCollection.ownerOf(tokenId) == msg.sender, "You don't own this NFT");
        nftCollection.transferFrom(msg.sender, address(this), tokenId);
        
        stakes[tokenId] = Stake({
            owner: msg.sender,
            timestamp: block.timestamp
        });
    }
    
    function unstake(uint256 tokenId) external {
        Stake memory staker = stakes[tokenId];
        require(staker.owner == msg.sender, "Not the original owner");
        
        uint256 reward = calculateReward(tokenId);
        // 此处省略发送代币奖励代码
        
        delete stakes[tokenId];
        nftCollection.transferFrom(address(this), msg.sender, tokenId);
    }
    
    function calculateReward(uint256 tokenId) public view returns (uint256) {
        Stake memory staker = stakes[tokenId];
        if (staker.owner == address(0)) {
            return 0;
        }
        uint256 stakedDuration = block.timestamp - staker.timestamp;
        return (stakedDuration * rewardRatePerDay) / 1 days;
    }
    
    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}