// 一个可以自己发行代币的银行系统
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleERC20 {    // 一个简化版加密货币系统：功能①创建代币②查询余额③转账④授权别人花钱及授权别人帮你第三方转账
    string public name = "Web3 Compass";
    string public symbol = "COM";
    uint8 public decimals = 18;    // 代币的小数位（小数位后可以有18位数，即1COM=10^18 最小单位）
    uint256 public totalSupply;    // 总发行量

    mapping(address => uint256) public balanceOf;    // 余额数据库 地址→余额
    mapping(address => mapping(address => uint256)) public allowance;    //授权系统：A允许B花多少钱【结构 owner→spender→amount】

    event Transfer(address indexed from, address indexed to, uint256 value);    //转账事件
    event Approval(address indexed owner, address indexed spender, uint256 value);  //授权花钱事件

    constructor(uint256 _initialSupply) {    //合约创建时运行    初始发行量
        totalSupply = _initialSupply * (10 ** uint256(decimals));   //把代币数量转换成最小单位
        balanceOf[msg.sender] = totalSupply;    //所有代币给创建者：谁部署合约谁拥有全部代币
        emit Transfer(address(0), msg.sender, totalSupply);  //代币被创建：从空地址发行给创建者
    }

    // 转账函数
    function transfer(address _to, uint256 _value) public  virtual returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");    //检查余额够不够
        _transfer(msg.sender, _to, _value);    //调用内部函数完成转账
        return true;
    }

    // 授权函数：允许别人花你的代币
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;    // 你允许他花多少钱
        emit Approval(msg.sender, _spender, _value);   // 广播：授权成功
        return true;
    }

    // 代授权函数：代别人转账（交易所帮你转钱）
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[_from] >= _value, "Not enough balance");    // 检查余额，否则“”
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");  // 检查你有没有被授权

        allowance[_from][msg.sender] -= _value;  //减少授权额度，eg授权一百花20，剩80额度
        _transfer(_from, _to, _value);    //执行真正转账
        return true;
    }

    // 内部转账函数（所有转账都会用此）
    function _transfer(address _from,address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");  // 禁止转空地址，否则会烧掉代币(？)
        balanceOf[_from] -= _value;   // 扣钱
        balanceOf[_to] += _value;    // 加钱
        emit Transfer(_from, _to, _value);    // 记录：转账成功
    }
}



// 1 Token发行：创建代币/constructor()
// 2 Token转账：如银行转钱/transfer()
// 3 Token授权：允许别人帮你花钱/approve()
// 4 授权转账：第三方帮你转钱/transferFrom()