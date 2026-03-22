// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Day13 基础ERC20合约（给预售合约继承用）
 * @dev 给 transfer / transferFrom 加了 virtual，允许子合约重写
 */
contract day13_BaseERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 构造函数：初始化代币
    constructor(uint256 _initialSupply) {
        name = "Web3 Compass";
        symbol = "COM";
        decimals = 18;
        totalSupply = _initialSupply * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // 转账：加 virtual 允许子合约重写
    function transfer(address _to, uint256 _value) public virtual returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    // 授权第三方转账
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 第三方代转：加 virtual 允许重写
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    // 内部统一转账逻辑
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        require(balanceOf[_from] >= _value, "Not enough balance");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
}