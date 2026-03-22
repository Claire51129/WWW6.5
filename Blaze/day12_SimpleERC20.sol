// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleERC20 {
    string public name = "SimpleToken";
    string public symbol = "SIM";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    //铸造初始供应
    constructor(uint256 _initialSupply) {
        //将存在的代币总数
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        //整个供应量被分配给了部署合约的人
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    //允许用户将他们的代币发送到另一个地址(自己转账)
    function transfer(address _to, uint256 _value) public virtual  returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        //调用一个内部辅助函数 _transfer() 来执行实际的代币转移。
        _transfer(msg.sender, _to, _value);
        return true;
    }

    //允许你授权另一个地址（通常是智能合约）代表你花费代币
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //允许已获批准的人代为转移代币(委托转账前先授权，执行approve)
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[_from] >= _value, "Not enough balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    //实际的代币转移
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
}

