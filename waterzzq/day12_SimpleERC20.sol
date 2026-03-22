// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title 简化版ERC20代币合约
 * @dev 实现ERC20标准核心功能：转账、授权、代理转账，包含名称/符号/小数/总供给
 */
contract SimpleERC20 {
    // ERC20 基础信息
    string public name;        // 代币名称
    string public symbol;      // 代币符号
    uint8 public decimals;     // 代币小数位（固定18，与ETH一致）
    uint256 public totalSupply;// 代币总供给

    // 核心存储：地址余额、地址授权额度
    mapping(address => uint256) public balanceOf;      // 地址对应余额
    mapping(address => mapping(address => uint256)) public allowance; // 授权额度：[授权者][被授权者] => 额度

    // ERC20 标准事件
    event Transfer(address indexed from, address indexed to, uint256 value);       // 转账事件
    event Approval(address indexed owner, address indexed spender, uint256 value); // 授权事件

    /**
     * @dev 构造函数：初始化代币信息，铸造初始供给并分配给部署者
     * @param _initialSupply 初始发行总量（单位：最小单位，需乘以10^decimals）
     */
    constructor(uint256 _initialSupply) {
        // 初始化代币基础信息
        name = "Web3 Compass";
        symbol = "COM";
        decimals = 18;
        
        // 计算总供给 = 初始数量 * 10^小数位（统一单位）
        totalSupply = _initialSupply * (10 ** decimals);
        // 初始供给全部分配给合约部署者
        balanceOf[msg.sender] = totalSupply;
        // 触发转账事件：从0地址转移给部署者
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /**
     * @dev 直接转账：从调用者地址转移到目标地址
     * @param _to 接收地址
     * @param _value 转账数量
     * @return 转账是否成功
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        // 直接调用内部转账逻辑（调用者为自己）
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev 授权：允许指定地址从自己账户转账指定额度
     * @param _spender 被授权地址
     * @param _value 授权额度
     * @return 授权是否成功
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        // 设置授权额度
        allowance[msg.sender][_spender] = _value;
        // 触发授权事件
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev 代理转账：被授权者从授权者地址转账到目标地址
     * @param _from 授权者地址（资金来源）
     * @param _to 接收地址
     * @param _value 转账数量
     * @return 转账是否成功
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        // 校验：授权额度足够
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");
        // 扣减授权额度
        allowance[_from][msg.sender] -= _value;
        // 执行实际转账
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev 内部转账核心逻辑：仅合约内部调用，处理余额扣减/增加与事件触发
     * @param _from 资金来源
     * @param _to 资金接收
     * @param _value 转账数量
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        // 校验：接收地址不能为0地址（无效地址）
        require(_to != address(0), "Invalid address");
        // 校验：转账者余额足够
        require(balanceOf[_from] >= _value, "Not enough balance");

        // 扣减来源地址余额
        balanceOf[_from] -= _value;
        // 增加接收地址余额
        balanceOf[_to] += _value;
        // 触发转账事件
        emit Transfer(_from, _to, _value);
    }
}
