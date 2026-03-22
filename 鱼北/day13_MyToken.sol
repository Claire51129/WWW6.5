//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleERC20 {

    string public name = "SimpleERC20";
    string public symbol = "SE20";
    uint256 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(address indexed from , address indexed to , uint256 value);
    event Approval(address indexed owner, address indexed spender ,uint256 value);

    constructor(uint256 _initalSupply) {
        totalSupply = _initalSupply * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
    require(_to != address(0), "Invalid address");
    balances[_from] -= _value;
    balances[_to] += _value;
    emit Transfer(_from, _to, _value);
   }
  
   function transfer(address _to , uint256 _value) virtual public returns(bool){
    require(balances[msg.sender] >= _value, "Insufficient balance");
    _transfer(msg.sender, _to, _value);
    return true;
   }

   function approve(address _to ,uint256 _value) public returns(bool){
    require(balances[msg.sender] >= _value, "Insufficient balance");
    allowances[msg.sender][_to] = _value;
    emit Approval(msg.sender, _to, _value);
    return true;
   }

   function transferFrom(address _from, address _to, uint256 _value) public virtual returns(bool){
    require(balances[_from] >= _value, "Insufficient balance");
    require(allowances[_from][msg.sender] >= _value, "Insufficient allowance");
    balances[_from] -= _value;
    balances[_to] += _value;
    allowances[_from][msg.sender] -= _value;
    _transfer(_from, _to, _value);
    return true;
   }

}