// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleERC20{
    string public name = "Web3 Compass";
    string public symbol = "COM";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;//A给B授予了多少A的钱

    event Transfer(address indexed from,address indexed to, uint256 value);// 转账时广播：从谁，转给谁，转了多少
    event Approval(address indexed owner, address indexed sender,uint256 value);// 授权时广播：谁授权了，授权给谁，授权多少

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");   //先确认：你的余额够不够转这么多？
        _transfer(msg.sender, _to, _value); // 够了才真正转账
        return true; // 成功！
    }
    

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;//在授权表里记录：我给你授权多少币
        emit Approval(msg.sender, _spender, _value);//广播这件事
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");//收款地址不能是零地址
        balanceOf[_from] -= _value; //扣掉A的余额
        balanceOf[_to] += _value; //加到B的余额
        emit Transfer(_from, _to, _value); //上链广播转账记录
    }


}
