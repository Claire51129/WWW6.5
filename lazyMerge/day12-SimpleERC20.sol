// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


// ERC-20 制定了一个统一的接口——一种共享的语言——所有代币都应该使用
// 名称
// 余额/供应量
// 转账
// 批准和授权支出
// 事件发射

contract SimpleERC20 {
    // 全名
    string public name = "SimpleToken"; 
    // 交易代码
    string public symbol = "SIM";
    // 精度
    uint8 public decimals = 18;
    uint256 public totalSupply; // 代币总数

    mapping(address => uint256) public balanceOf; // 地址-余额
    mapping(address => mapping(address => uint256)) public allowance; // 地址-额度

    event Transfer(address indexed from, address indexed to , uint256 value); // 转账
    event Approval(address indexed owner, address indexed spender, uint256 value); // 授权

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply; // 整个供应量被分配给了部署合约的人
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // virtual  允许子合约重写
    function transfer(address _to, uint256 _value) public virtual returns(bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        // 公共逻辑抽离
        _transfer(msg.sender,_to,_value);
        return true;
    }

    // internal 只能内部调用
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Transfer to zero address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from,_to,_value);
    }

    // 授权
    function approve(address _spender, uint256 _value) public returns(bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 拿到授权的人提币
    // virtual  允许子合约重写
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool){
        require(balanceOf[_from] >= _value, "Not enough balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
}


// 其他实现
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// contract MyToken is ERC20 {
//     constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
//         _mint(msg.sender, initialSupply * 10 ** decimals());
//     }
// }