// SPDX-License-Identifier: MIT
// 合约采用MIT开源许可证协议

pragma solidity ^0.8.0;
// 指定Solidity编译器版本：兼容0.8.x系列，不兼容1.0.0及以上版本

// 简化版ERC20代币合约
contract MyToken {
    string public name = "Web3 Compass";    // 代币名称
    string public symbol = "WBT";            // 代币符号
    uint8 public decimals = 18;              // 代币小数位数（ERC20标准值）
    uint256 public totalSupply;              // 代币总供应量（最小单位）

    mapping(address => uint256) public balanceOf; // 地址→代币余额（最小单位）
    // 授权额度映射：所有者地址→被授权地址→可使用代币额度（最小单位）
    mapping(address => mapping (address => uint256)) public allowance;

    // 转账事件：记录转账发起方、接收方及金额，indexed支持日志过滤
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 授权事件：记录授权方、被授权方及额度，indexed支持日志过滤
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 构造函数：部署时初始化代币总供应量，全部分配给部署者
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** decimals); // 总供应量换算为最小单位
        balanceOf[msg.sender] = totalSupply; // 部署者获得全部代币
        emit Transfer(address(0), msg.sender, _initialSupply); // 铸币事件（零地址代表发行）
    } 

    // 内部转账核心逻辑：仅合约内部可调用，virtual支持子类重写
    function _transfer(address _from, address _to, uint256 _value) internal virtual {
        require(_to != address(0), "Cannot transfer to the zero address"); // 禁止转账至零地址
        balanceOf[_from] -= _value; // 扣减转出方余额
        balanceOf[_to] += _value;   // 增加接收方余额
        emit Transfer(_from, _to, _value); // 触发转账事件
    }

    // 代币转账：调用方向指定地址转移自有代币
    function transfer(address _to, uint256 _value) public virtual returns (bool success) { 
        require(balanceOf[msg.sender] >= _value , "Not enough balance"); // 校验调用方余额充足
        _transfer(msg.sender, _to, _value); // 执行内部转账
        return true; // 转账成功返回true
    }

    // 授权转账：被授权方从指定地址转移代币（需校验授权额度）
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns(bool) {
        require(balanceOf[_from] >= _value, "Not enough balance"); // 校验转出方余额充足
        require(allowance[_from][msg.sender] >= _value, "Not enough allowance"); // 校验授权额度充足（修正拼写错误）
        allowance[_from][msg.sender] -= _value; // 扣减已使用的授权额度
        _transfer(_from, _to, _value); // 执行内部转账
        return true; // 转账成功返回true
    }

    // 授权：为指定地址设置可使用调用方代币的额度
    function approve(address _spender, uint256 _value) public returns(bool) {
        allowance[msg.sender][_spender] = _value; // 配置授权额度
        emit Approval(msg.sender, _spender, _value); // 触发授权事件
        return true; // 授权成功返回true
    }
}