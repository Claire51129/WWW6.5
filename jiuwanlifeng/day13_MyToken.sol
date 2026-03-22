// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    基础 ERC20 Token 合约
    用于 Day13 Token Presale 作业
*/

contract MyToken{

    // Token 名称
    string public name = "Web3 Compass";

    // Token 符号
    string public symbol = "WBT";

    // 小数位（ERC20标准18）
    uint8 public decimals = 18;

    // Token 总供应量
    uint256 public totalSupply;

    // 记录每个地址拥有多少 Token
    mapping(address => uint256) public balanceOf;

    // 授权额度
    mapping(address => mapping (address => uint256)) public allowance;


    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 授权事件
    event Approval(address indexed owner, address indexed spender, uint256 value);


    /*
        构造函数
        部署合约时执行
    */
    constructor(uint256 _initialSupply){

        // 计算总供应量（考虑 decimals）
        totalSupply = _initialSupply * (10 ** decimals);

        // 把所有 Token 给合约创建者
        balanceOf[msg.sender] = totalSupply;

        // 触发 Token 创建事件
        emit Transfer(address(0), msg.sender, totalSupply);
    } 


    /*
        内部转账函数
        子合约（例如 Presale 合约）可以调用
    */
    function _transfer(address _from, address _to, uint256 _value) internal virtual{

        require(_to != address(0), "Cannot transfer to the zero address");

        require(balanceOf[_from] >= _value, "Insufficient balance");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
    }


    /*
        Token 转账
    */
    function transfer(address _to, uint256 _value) public virtual returns (bool){

        require(balanceOf[msg.sender] >= _value , "Not enough balance");

        _transfer(msg.sender, _to, _value);

        return true;
    }


    /*
        代理转账
        需要先 approve
    */
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns(bool){

        require(balanceOf[_from] >= _value, "Not enough balance");

        require(allowance[_from][msg.sender] >= _value, "Not enough allowance");

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;
    }


    /*
        授权别人可以使用你的 Token
    */
    function approve(address _spender, uint256 _value) public returns(bool){

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

}