// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleNFT {
    // 1. 五大账本
    mapping(uint256 => address) private _owners;          // ID -> 主人
    mapping(address => uint256) private _balances;        // 主人 -> 持仓数
    mapping(uint256 => address) private _tokenApprovals;  // 单个ID授权
    mapping(address => mapping(address => bool)) private _operatorApprovals; // 批量授权
    mapping(uint256 => string) private _tokenURIs;        // ID -> 图片链接

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    // 【核心：查询谁是主人】
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token does not exist");
        return owner;
    }

    // 【核心：铸造 - 创造新NFT】
    function _mint(address to, uint256 tokenId, string memory uri) internal {
        require(to != address(0), "Mint to zero");
        require(_owners[tokenId] == address(0), "Already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;
        _tokenURIs[tokenId] = uri; // 绑定图片

        emit Transfer(address(0), to, tokenId);
    }

    // 【核心：转账 - 换主人】
    function transferFrom(address from, address to, uint256 tokenId) public {
        // 安检：必须是主人或被授权人
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        
        // 清除旧授权
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    // 内部检查：是否拥有权限
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || _tokenApprovals[tokenId] == spender || _operatorApprovals[owner][spender]);
    }

    // 内部函数：设置授权
    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
}
