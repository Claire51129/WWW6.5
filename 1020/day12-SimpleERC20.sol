// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// contract MyToken is ERC20 {
//     constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
//         _mint(msg.sender, initialSupply * 10 ** decimals());
//     }
// mint是铸币，把所有的初始代币都发给部署者，默认只有
// }

//ERC20是代币的规则

contract SimpleERC20{
    string public name="SimpleToken";
    string public symbol="SIM";
    uint8 public decimals=18;//- decimals 定义了它的可分割程度。大多数代币使用 18 位小数
    uint256 public totalSupply;//代币总量

    mapping (address=>uint256) public balcanceOf;//每个地址持有多少代币
    mapping (address=>mapping(address=>uint256)) public allowance;//谁被允许代表谁花费代币——以及花费多少

//每当代币从一个地址转移到另一个地址时
    event Transfer(address indexed from,address indexed to,uint256 value);
//当有人授权另一个地址代表他们花费代币时
    event Approval(address indexed owner,address indexed spender,uint256 value);
    
    constructor(uint256 _initialSupply){
        totalSupply=_initialSupply*(10**decimals);
        balcanceOf[msg.sender]=totalSupply;
        emit Transfer(address(0),msg.sender,totalSupply);
    }
       
    function _transfer(address _from,address _to,uint256 _value) internal{
        require(_to!=address(0),"Invalid address");
        balcanceOf[_from]-=_value;
        balcanceOf[_from]+=_value;
        emit Transfer(_from,_to,_value);
    }

    function transfer(address _to,uint256 _value) public virtual returns(bool){
        require(balcanceOf[msg.sender]>=_value,"Not enough balance");
        _transfer(msg.sender,_to,_value);//把转账的过程另外做一个function
        return true;
    }

    function transferFrom(address _from,address _to,uint256 _value) public virtual returns(bool){
        require(balcanceOf[_from]>=_value,"Not enough balance");
        require(allowance[_from][msg.sender]>=_value,"Allowance too low");

        allowance[_from][msg.sender]-=_value; //减少授权额度
        _transfer(_from,_to,_value);
        return true;
    }

    function approve(address _spender,uint256 _value) public returns(bool){
        allowance[msg.sender][_spender]=_value;//msg.sender授权_spender支配金额_value
        emit Approval(msg.sender,_spender,_value);
        return true;
    }
}
