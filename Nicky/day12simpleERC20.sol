// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

    import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {//name:mytoken;sylbol:MTK
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }
}


contract SimpleERC20{
    string public name="SimpleToken";
    string public symbol="STM";
    uint8 public decimals=18;
    uint256 public totalSupply; //当前代币总数

    mapping(address =>uint256) public balanceOf;
    mapping(address =>mapping(address =>uint256)) public  allowance;//谁被允许代表谁花代币，花了多少

    event Transfer(address indexed from, address indexed to, uint256 value); //记录代币从哪个地址转移到哪个地址，金额
    event Approval(address indexed owner, address indexed spender, uint256 value);//记录代币被owner授权给那个spender，金额

    constructor(uint256 _initinalSupply){
        totalSupply =_initinalSupply *(10**uint256(decimals));//初始值*10^18
        balanceOf[msg.sender]=totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);//代币被凭空创造：address(0)
    }

    function transfer(address _to, uint256 _value) public virtual returns(bool){
        require(balanceOf[msg.sender] >=_value, "Not enough balance");
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns(bool){
        allowance[msg.sender][_spender]=_value;
        emit Approval(msg.sender,_spender,_value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool){
        require(balanceOf[_from]>= _value,"Not Enough balance");
        require(allowance[_from][msg.sender] >=_value,"Allowance too low");
        allowance[_from][msg.sender]-=_value;
        _transfer(_from,_to,_value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal{
        require(_to !=address(0), "Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }




}