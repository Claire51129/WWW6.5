// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleERC20 {
    string public name = "Herstory";//因为是文字所以要加“”
    string public symbol = "HER";
    uint8 public decimals = 18;//代币的小数点位可以写到18，uint8可以存下2的8次幂-1，可以存下255个数字
    uint256 public totalSupply;//代币总发行量

    mapping(address => uint256)public balanceOf;//单人余额账本
    mapping(address =>mapping(address => uint256))public allowance;//这个地址允许花多少钱

    event Transfer(address indexed from, address indexed to, uint256 value);//转账事件
    event Approval(address indexed owner,address indexed spender, uint256 value);//授权事件，spender是被授权的人

    constructor(uint256 _initialSupply) {//initialSupply初始发行量
        totalSupply = _initialSupply * (10 ** uint256(decimals));//实际发行量还要再乘上10的18次幂，合约里只能有整数
        balanceOf[msg.sender] = totalSupply;//所有代币都在发行者的钱包里
        emit Transfer(address(0), msg.sender, totalSupply);//发出transfer事件，表示代币已经铸造
    }

    //转钱函数 增加virtual
    function transfer(address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;//allowance[主人地址][被授权人地址]=金额
        emit Approval(msg.sender, _spender, _value);//发送授权事件
        return true;
    }

    //增加virtual
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {//因为有_from，钱是从某人账户出来，所以是替别人转钱
        require(balanceOf[_from] >= _value, "Not enough balance");//保证主人余额有足够金额
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");//保证需调取金额小于授权金额

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    //内部辅助函数
    function _transfer(address _from, address _to, uint256 _value) internal {//internal权限关键词，此函数只能在当前合约内部使用
        require(_to != address(0), "Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
}


