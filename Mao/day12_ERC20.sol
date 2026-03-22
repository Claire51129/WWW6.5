//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//自己编写代币合约（代币就是在区块链上的代码合约，通过调用里面的函数去分发、转让）
//interal ，合约本身内部的代码调用 ；继承了这个合约的子合约调用
contract SimpleERC20 {
    //基础的元信息
    string public name = "SimpleERC20"; //代币名称
    string public symbol = "SE20"; //代币符号
    uint256 public decimals = 18; //代币精度
    uint256 public totalSupply; //代币总供应量

    //定义一个映射，用于存储地址和余额的对应关系
    mapping(address => uint256) public balances;
    //定义一个映射，用于存储地址和地址的对应关系，以及授权的金额
    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(address indexed from , address indexed to , uint256 value);
    event Approval(address indexed owner, address indexed spender ,uint256 value);

    //构造函数
    constructor(uint256 _initalSupply) {
        //总货币数量
        totalSupply = _initalSupply * (10 ** uint256(decimals));
        //给合约部署者发放所有代币
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    //实际移动代币的引擎,在转账、代理人转账中调用
    function _transfer(address _from, address _to, uint256 _value) internal {
    require(_to != address(0), "Invalid address");
    balances[_from] -= _value;
    balances[_to] += _value;
    emit Transfer(_from, _to, _value);
   }
  
   //owner转账
   function transfer(address _to , uint256 _value) virtual public returns(bool){
    require(balances[msg.sender] >= _value, "Insufficient balance");
    _transfer(msg.sender, _to, _value);
    return true;
   }

   //授权另外地址花费代币
   function approve(address _to ,uint256 _value) public returns(bool){
    require(balances[msg.sender] >= _value, "Insufficient balance");
    allowances[msg.sender][_to] = _value;
    emit Approval(msg.sender, _to, _value);
    return true;
   }

   //允许已获批准的人代为转移代币。
   //1. Alice 调用 approve(Bob, 100)
   //2. Bob 调用 transferFrom(Alice, Carol, 50)
   function transferFrom(address _from, address _to, uint256 _value) public virtual returns(bool){
    require(balances[_from] >= _value, "Insufficient balance");
    require(allowances[_from][msg.sender] >= _value, "Insufficient allowance");
    balances[_from] -= _value;
    balances[_to] += _value;
    allowances[_from][msg.sender] -= _value;
    _transfer(_from, _to, _value);
    return true;
   }

}