// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 一个简化版 ERC20 代币合约
contract SimpleERC20 {

    // 代币名称
    string public name = "Web3 Compass";

    // 代币符号
    string public symbol = "COM";

    // 代币的小数位数
    // 大多数 ERC20 代币都是 18
    uint8 public decimals = 18;

    // 代币总供应量
    uint256 public totalSupply;

    // 记录每个地址拥有多少代币
    mapping(address => uint256) public balanceOf;

    // 授权机制
    // owner => spender => amount
    mapping(address => mapping(address => uint256)) public allowance;

    // 转账事件（区块链日志）
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 授权事件
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 构造函数：部署合约时执行
    constructor(uint256 _initialSupply) {

        // 计算真实供应量（考虑 decimals）
        totalSupply = _initialSupply * (10 ** uint256(decimals));

        // 把所有代币给合约创建者
        balanceOf[msg.sender] = totalSupply;

        // 触发转账事件（从0地址 -> 创建者）
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // 普通转账函数
    function transfer(address _to, uint256 _value) public returns (bool) {

        // 检查发送者余额是否足够
        require(balanceOf[msg.sender] >= _value, "Not enough balance");

        // 调用内部转账函数
        _transfer(msg.sender, _to, _value);

        return true;
    }

    // 授权某个地址使用你的代币
    function approve(address _spender, uint256 _value) public returns (bool) {

        // 设置授权额度
        allowance[msg.sender][_spender] = _value;

        // 触发授权事件
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    // 代别人转账（授权机制）
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        // 检查余额
        require(balanceOf[_from] >= _value, "Not enough balance");

        // 检查授权额度
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");

        // 减少授权额度
        allowance[_from][msg.sender] -= _value;

        // 执行转账
        _transfer(_from, _to, _value);

        return true;
    }

    // 内部转账函数
    function _transfer(address _from, address _to, uint256 _value) internal {

        // 防止转到无效地址
        require(_to != address(0), "Invalid address");

        // 扣除发送者余额
        balanceOf[_from] -= _value;

        // 增加接收者余额
        balanceOf[_to] += _value;

        // 触发转账事件
        emit Transfer(_from, _to, _value);
    }
}
