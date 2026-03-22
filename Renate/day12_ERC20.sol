// SPDX-License-Identifier: MIT
// 合约采用MIT开源许可证协议
pragma solidity ^0.8.20;
// 指定Solidity编译器版本：兼容0.8.20及以上，不兼容0.9.0+

// 简化版ERC20代币合约
// 实现ERC20核心标准：余额查询、代币转账、授权转账
contract SimpleERC20 {
    // 代币基础属性
    string public name = "Web3 Compass";  // 代币名称
    string public symbol = "COM";          // 代币符号
    uint8 public decimals = 18;            // 代币小数位数（ERC20标准值）
    uint256 public totalSupply;            // 代币总供应量（最小单位）

    // 地址→代币余额映射（最小单位）
    mapping(address => uint256) public balanceOf;
    // 授权额度映射：持有者→被授权者→可使用额度（最小单位）
    mapping(address => mapping(address => uint256)) public allowance;

    // 转账事件：记录转账发起方、接收方及金额，indexed支持日志过滤
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 授权事件：记录授权方、被授权方及额度，indexed支持日志过滤
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 构造函数：部署时初始化代币总供应量并全部分配给部署者
    constructor(uint256 _initialSupply) {
        // 总供应量换算为最小单位（×10^decimals）
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        // 部署者获得全部代币
        balanceOf[msg.sender] = totalSupply;
        // 触发铸币事件（from为零地址表示代币发行）
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // 代币转账：调用方向指定地址转移代币
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance"); // 校验余额充足
        _transfer(msg.sender, _to, _value); // 执行内部转账逻辑
        return true;
    }

    // 授权：允许被授权方从调用方账户转移指定额度代币
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value; // 设置授权额度
        emit Approval(msg.sender, _spender, _value); // 触发授权事件
        return true;
    }

    // 授权转账：调用方使用授权额度从指定账户转移代币
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balanceOf[_from] >= _value, "Not enough balance"); // 校验账户余额
        require(allowance[_from][msg.sender] >= _value, "Allowance too low"); // 校验授权额度

        allowance[_from][msg.sender] -= _value; // 扣减已使用的授权额度
        _transfer(_from, _to, _value); // 执行内部转账逻辑
        return true;
    }

    // 内部转账函数：处理核心转账逻辑，仅合约内部可调用
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address"); // 校验接收地址非零
        balanceOf[_from] -= _value; // 扣减转出方余额
        balanceOf[_to] += _value;   // 增加接收方余额
        emit Transfer(_from, _to, _value); // 触发转账事件
    }
}