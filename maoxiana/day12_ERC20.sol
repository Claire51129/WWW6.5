 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleERC20 {
    string public name = "Web3 Compass";//代币名
    string public symbol = "COM";//简短的交易代码
    uint8 public decimals = 18;//大多数代币使用18位小数
    uint256 public totalSupply;//代币供应总数

    //每个地址持有的代币
    mapping(address => uint256) public balanceOf;
    //授权：owner允许spender花费的金额，例如：Alice允许Bob花费100个代币，allowance[Alice][Bob] = 100
    //用于追踪谁被允许代表谁花费代币——以及花费多少。
    //这是 ERC-20 的核心功能：允许其他人（如 DApp 或智能合约）移动你的代币，但前提是你必须首先批准。
    mapping(address => mapping(address => uint256)) public allowance;

    //每当代币从一个地址转移到另一个地址时，这个事件就会触发。钱包和浏览器依赖这个事件来显示交易历史。
    event Transfer(address indexed from, address indexed to, uint256 value);
    //当有人授权另一个地址代表他们花费代币时，这个事件就会触发。
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //初始供应
    constructor(uint256 _initialSupply) {
        //设定代币总数
        //ERC-20 代币使用小数位来确保精确度（就像 ETH 使用 Wei 一样）。
        //所以如果你的代币使用 18 位小数（这是标准），并且你想创建 100 个代币，你实际上需要将其表示为：
        //100 * 10^18 = 100000000000000000000
        //这就是为什么我们将初始供应量乘以 10 ** decimals。
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        //供应量被分配给了部署合约的人
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    //允许用户将他们的代币发送到另一个地址
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        //不是在这里处理转账逻辑，而是调用一个内部辅助函数 _transfer() 来执行实际的代币转移。
        _transfer(msg.sender, _to, _value);
        return true;
    }

    //授权另一个地址（通常是智能合约）代表你花费代币
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //允许已获批准的人代为转移代币。
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balanceOf[_from] >= _value, "Not enough balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    //标记为internal，这意味着它只能从该合约或其派生合约内部调用——不能由外部用户或其他合约调用。
    //这是一个有意的选择：不想让人们直接调用_transfer()并绕过重要的检查，如额度。
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
}
