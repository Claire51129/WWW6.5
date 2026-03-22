// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//ERC20是一套简单的通用规则，定义一个自定义的代币必须具备的功能
contract SimpleERC20 {
    string public name = "SimpleToken"; //代币的名称
    string public symbol = "SIM"; //代币的符号
    uint8 public decimals = 18; //代币的小数位数；uint8是指8bits（1byte），适用于存储占用内存较少的数值
    uint256 public totalSupply; //代币的余额总数

    mapping (address => uint256) public balanceOf; //获取到每个地址持有的代币数额
    mapping (address => mapping (address => uint256)) public allowance; //嵌套映射，用于追踪谁被允许代表谁花费代币，以及花费多少

    event Transfer(address indexed from, address indexed to, uint256 value); //当代币从一个地址转移到另一个地址时发生的事件
    event Approval(address indexed owner, address indexed spender, uint256 value); //当有人授权另一个地址代表他们花费代币时发生的事件

    //构造函数——铸造初始供应，在合约部署时只会运行一次
    constructor(uint256 _initialSupply) { //_initialSupply是部署时传入的数值
        totalSupply = _initialSupply * (10 ** uint256(decimals)); //ERC20使用小数位数来确保精确度，需要在原始数值上乘以10的decimals次幂
        balanceOf[msg.sender] = totalSupply; //将代币初始供应全部给部署合约的人
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    //允许用户将ta们的代币发送给另一个地址的函数
    function transfer(address _to, uint256 _value) public virtual returns (bool) { //加上virtual，可以在引用的子合约里对其进行重写
        require(balanceOf[msg.sender] >= _value, "Not enough balance.");
        _transfer(msg.sender, _to, _value); //逻辑分离：此处的transfer()函数与后面的transferFrom()函数都将重复转账逻辑，因此将核心的余额变更逻辑抽象成一个单独的函数_transfer()，需要时只需要重复调用
        return true;
    }
    //允许用户授权另一个地址代表自己花费代币的函数
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value; //msg.sender授权_spender为自己花费代币，最多可花费_value这么多
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    //允许获得授权的用户代为转移代币的函数
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[_from] >= _value, "Not enough balance.");
        require(allowance[_from][msg.sender] >= _value, "Allowance too low.");
        allowance[_from][msg.sender] -= _value; //减少被授权用户的授权额度
        _transfer(_from, _to, _value); //调用_transfer()来执行实际的代币转移
        return true;
    }
    //实际移动代币的引擎（遵循“不要重复自己”的DRY原则）
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address.");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
} //实际上述构建的ERC20代币还缺少重要的部分：没有对approve()进行抢先交易的保护