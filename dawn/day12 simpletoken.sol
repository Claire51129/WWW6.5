// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleToken {
    // 代币元数据
    string public name = "SimpleToken";
    string public symbol = "SIM";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    // 核心映射
    mapping(address => uint256) public balanceOf;//该地址持有的该币数量
    mapping(address => mapping(address => uint256)) public allowance;//嵌套映射用于记录授权额度，所有者的地址和被授权的地址然后是额度。
    
    // 事件
    event Transfer(address indexed from, address indexed to, uint256 value);//代币的转移，从哪里转向哪里，价值是多少？
    event Approval(address indexed owner, address indexed spender, uint256 value);//代币使用的许可代币的所有者是谁，花费者是谁，价值是多少？
    
    // 构造函数
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals));//代币的总供应量乘以一个代币对应的最小单位数量。例如初始供应量是1000，那总供应量最小单位就是1000乘以10的18次方。
        balanceOf[msg.sender] = totalSupply;//将全部代币分配给部署合约的地址。
        emit Transfer(address(0), msg.sender, totalSupply);//触发转移事件从零地址转出，这是铸造代币的标准做法。
    }
    
    // 直接转账
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Invalid address");
        _transfer(msg.sender, _to, _value);
        return true;//公开函数任何用户调用她从自己账户转给to地址返回布尔值表示成功。
    }
    
    // 内部转账逻辑
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(_from, _to, _value);//内部函数只能被本合约内其她函数调用。首先检查发送方余额是否足够，然后减少发送方的余额，增加接收方的余额，触发转账事件。
    }
    
    // 授权
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0), "Invalid address");
        
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    // 授权转账
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
}