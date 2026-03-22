 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleERC20 {
    string public name = "Web3 Compass"; // 代币的全名
    string public symbol = "COM"; // 简短的交易代码（如“ETH”）
    uint8 public decimals = 18; // 可分割程度。大多数代币使用18位小数——就像ETH一样
    uint256 public totalSupply; // 当前存在的代币总数

    mapping(address => uint256) public balanceOf; // 每个地址持有多少代币
    mapping(address => mapping(address => uint256)) public allowance; // 所有者 A 允许代理人 B 使用多少代币 // 这是 ERC-20 的核心功能：允许其他人（如 DApp 或智能合约）移动你的代币，但前提是你必须首先批准。

    event Transfer(address indexed from, address indexed to, uint256 value); // 每当代币从一个地址转移到另一个地址时，这个事件就会触发。钱包和浏览器依赖这个事件来显示交易历史。
    event Approval(address indexed owner, address indexed spender, uint256 value); // 当有人授权另一个地址代表他们花费代币时，这个事件就会触发。

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply); // 铸造事件 // 部署者最初持有 100%的代币
    }

    function transfer(address _to, uint256 _value) public virtual returns (bool) { // mutability是non-payable，修改了balanceOf映射
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        _transfer(msg.sender, _to, _value);
        return true;
    }
    /*为什么不在 transfer() 直接执行转账，而是通过 transfer() 调用 _transfer() ？——逻辑分离
        我们不想在 transfer() 和 transferFrom() 等多个地方重复转账逻辑。相反，我们将核心的余额变更逻辑提取到一个单独的内部辅助函数 _transfer() 中来执行实际的代币转移，并在需要的地方重用它。
        可以把 transfer() 想象成前端按钮，而 _transfer() 是后端引擎。用户只看到按钮，但实际操作在后台进行。
        这种方法的另一个好处是安全性和一致性。如果我们想改变代币余额更新的方式（例如添加费用或记录额外数据），我们只需要在一个地方修改 _transfer()，而 transfer() 和 transferFrom() 都会受益于更新。*/

    function approve(address _spender, uint256 _value) public returns (bool) { // mutability是non-payable，修改了allowance映射
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); // 你授权_spender最大可花费_value金额
        return true;
    }
    // 这是所有委托代币交易的基础——比如在 DEX 上交易、订阅服务或参与收益农场。

    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[_from] >= _value, "Not enough balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true; // 返回bool值是为了满足 ERC-20 标准的强制规范 以及 保障智能合约之间的交互安全性。
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
    /*这是实际移动代币的引擎。
        它被标记为internal，这意味着它只能从该合约或其派生合约内部调用——不能由外部用户或其他合约调用。这是一个有意的选择：我们不想让人们直接调用_transfer()并绕过重要的检查（require）。
        通过将这个逻辑移入它自己的内部函数，我们得到：
            - 干净、可重用的代码
            - 减少重复逻辑的 bug
            - 余额更新的单一真实来源
        transfer()和 transferFrom()都依赖于_transfer()来保持一致性并遵循 DRY（不要重复自己）原则。*/

//vitual：如果有其他合约继承了这个合约，这个函数是可以被重新修改的。

}
