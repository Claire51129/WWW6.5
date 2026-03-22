//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleERC20 {
    string public name = "SimpleToken";
    string public symbol = "STM";
    uint8 public decimals =18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from,address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply *(10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender,totalSupply);
    }
    function _transfer(address _from, address _to,uint256 _value) internal {
        require(balanceOf[_from] >= _value,"Insufficient balance");
        balanceOf[_from] -= _value;
        emit Transfer(_from, _to, _value);
    }

    //添加virtual关键字
    function transfer(address _to,uint256 _value) public virtual returns (bool) {
        require(_to != address(0), "Invaild address");
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0), "Invaild address");
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    //添加virtual关键字
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns(bool) {
        require(_to != address(0), "Invailed address");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
}