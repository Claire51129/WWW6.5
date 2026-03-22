// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleERC20 {
    string public name = "SimpleToken";
    string public symbol = "SIM";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer (address indexed from,address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 _initialSupply){
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender , totalSupply);
    }//**是幂运算符 uin8>>uint256强制转换便于计算

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] -= _value;
    }//内部辅助函数 _transfer(from, to, value)可复用的转账逻辑函数

    function approval(address _spender, uint256 _value) public returns(bool){
        allowance[msg.sender][_spender] += _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }//使得像 DEX 交易和 DAO 投票这样的操作成为可能

    function transfer(address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        _transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns(bool){
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");
        require(balanceOf[_from] >= _value, "Insufficient balance");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        emit Transfer(_from, _to, _value);
        
        return true;
    }

}
/*
//使用OpenZeppelin 轻松创建您自己的代币的方法
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }
}

*/
