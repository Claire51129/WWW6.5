//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//基于“共同资金池”的虚拟账本管理过程
contract SimpleIOU{
    address public owner;
    uint256 public amount;

    mapping(address => bool) public registeredFriends;
    address[] public friendList;

    mapping(address => uint256) public balances;

    mapping(address => mapping(address => uint256)) public debts;// debts[debtor][creditor]

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can perform this reaction");
        _;
    }
    modifier onlyRegistered(){
        require(registeredFriends[msg.sender], "You are not registered");
        _;
    }
    
    function addFriend(address _friend) public onlyOwner {
        require(_friend != address(0), "Invalid address!");
        require(!registeredFriends[_friend] , "Friend already registered");

        registeredFriends[_friend] = true;
        friendList.push(_friend);
    }

    function depositIntoWallet() public payable onlyRegistered {
        require(msg.value > 0,"Must send ETH");
        balances[msg.sender] += msg.value;
    }

    function recordDebt(address _debtor, uint256 _amount) public onlyRegistered {
        require(_debtor != address(0), "Invalid address");
        require(registeredFriends[_debtor], "Address not registered");
        require(_amount > 0 , "Amount must be greater than 0");

        debts[_debtor][msg.sender] += _amount;
    }

    //虚拟余额 在共同账本中随用随划 ETH并没有离开合约
    function payFromWallet(address _creditor, uint256 _amount) public onlyRegistered{
        require(_creditor != address(0), "Invalid address");
        require(registeredFriends[_creditor], "Creditor not registered");
        require(_amount > 0 , "Amount must be greater than 0");

        require(debts[msg.sender][_creditor] >= _amount, "Debts amount incorrect");
        require(balances[msg.sender] > amount, "Insufficient balance");

        balances[_creditor] += _amount;
        balances[msg.sender] -= _amount;
        debts[msg.sender][_creditor] -= _amount;
    }

    //资金提取/外发 transfer用于将ETH从合约发送到外部地址 _to无需提现直接转到钱包里
    function transferEther(address payable _to, uint256 _amount) public onlyRegistered{
        require(_to != address(0), "Invalid address");
        require(registeredFriends[_to], "Recipient not registered");//保证资金在受信任的圈子里流动

        //而不是msg.value 后者是随函数调用发给合约的ETH 
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        _to.transfer(_amount);
        //共同账本是余额的综合 _to接收到真实货币 msg.sender余额减少 总账还是准确的
    }

    function transferEtherViaCall(address payable _to, uint256 _amount) public onlyRegistered{
        require(_to != address(0), "Invalid address");
        require(registeredFriends[_to], "Recipient not registered");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;

        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");
    }//演示代码似乎有错误 这两个函数后面应该都不加_to的余额
    //在编程里，普通的小括号 () 是用来写“指令”的,而大括号 {} 则是专门用来放“附加礼物”的，也就是真金白银（以太币）
    //value关键字默认为wei 单位

    function withdraw(uint256 _amount) public onlyRegistered{
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Withdrawal failed");
    }

    function checkBalance() public view onlyRegistered returns(uint256) {
        return (balances[msg.sender]);}
}
