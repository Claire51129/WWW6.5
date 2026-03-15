
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleERC20 {
    string public name = "Web3 Compass";//代币名字
    string public symbol = "COM";//代币符号
    uint8 public decimals = 18;//小数点后几位
    uint256 public totalSupply;
//代币基础信息
    mapping(address => uint256) public balanceOf;//余额记录
    mapping(address => mapping(address => uint256)) public allowance;//授权记录
//allowance[主人][被授权人]=额度
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        //这一行设定了将存在的代币总数。
        //_initialSupply 是部署合约时传入的数值。
        //ERC-20 代币使用小数位来确保精确度（就像 ETH 使用 Wei 一样）。
        //- 如果你的代币使用 18 位小数（这是标准），并且你想创建 100 个代币，你实际上需要将其表示为：
        //100 * 10^18 = 100000000000000000000
        //10是十进制固定的
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        //这会发出一个 Transfer 事件来表示代币已被"铸造"。
        //我们将from地址设置为 address(0)，这是一种特殊说法：
        //  这些代币并非来自其他用户——它们凭空创造了。
    }

    function transfer(address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        _transfer(msg.sender, _to, _value);
        return true;
        //自己账户扣钱，给对方加钱
        //它不是在这里处理转账逻辑，而是调用一个内部辅助函数 _transfer() 来执行实际的代币转移。
        //重要的逻辑分离
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual  returns (bool) {
        require(balanceOf[_from] >= _value, "Not enough balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
        //经主人授权后，从主人账户扣钱转给别人，帮主人付钱的场景
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        //内部函数，真正执行转账的地方
    }
}