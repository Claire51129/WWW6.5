// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyFirstToken {
    // 1. 代币基本信息
    string public name = "MyFirstToken";
    string public symbol = "MFT";
    uint8 public decimals = 18; // 标准精度，1 ETH = 10^18 Wei
    uint256 public totalSupply; // 总发行量

    // 2. 核心账本：记录每个地址有多少钱
    mapping(address => uint256) public balanceOf;

    // 3. 管理员：只有他能印钱 (Mint)
    address public owner;

    // 4. 事件：每当发生转账或铸币时，必须在链上公示
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);

    // 构造函数：设定管理员
    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        // 初始发行一些币给创建者
        mint(owner, _initialSupply);
    }

    // 修饰器：权限控制
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // 5. 铸币功能：凭空创造新代币
    function mint(address _to, uint256 _amount) public onlyOwner {
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount); // 规范：铸币是从 0 地址转出
    }

    // 6. 转账功能：最核心的逻辑
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // 检查：余额够吗？不能转给空地址
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(_to != address(0), "Invalid address");

        // 账本变动
        balanceOf[msg.sender] -= _value; // 减去发送者的钱
        balanceOf[_to] += _value;       // 增加接收者的钱

        // 广播交易
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}