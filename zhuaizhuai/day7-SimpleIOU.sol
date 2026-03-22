// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleIOU {
    address public owner;

    //track registered friends，身份准入
    mapping (address => bool) public registeredFriends;
    address[] public friendList;
    
    //track balance，金库记账
    mapping (address => uint256) public balances;

    //simple debt tracking，信用来往
    mapping (address => mapping (address => uint256)) public debts; // debtor -> amount，地址A欠地址B多少钱。

    constructor(){
        owner = msg.sender; //我上任
        registeredFriends[msg.sender] = true; //我上白名单
        friendList.push(msg.sender); //我是0号
    }

     modifier onlyOwner() { 
        require(msg.sender == owner, "Only owner can perform this action");//只有我可以动这个账户
        _;
    }

     modifier onlyRegistered() {
        require(registeredFriends[msg.sender], "You are not registered");//只有我添加的朋友可以用
        _;
    }
    
      // Register a new friend，我在添加新的朋友
    function addFriend(address _friend) public onlyOwner {
        require(_friend != address(0), "Invalid address"); //受邀的朋友的地址，否则是无效地址
        require(!registeredFriends[_friend], "Friend already registered");//邀请朋友地址后显示已注册
        
        registeredFriends[_friend] = true;
        friendList.push(_friend);//把之前的申请加入变成记录，状态变成“true”

    }
      
    // Deposit funds to your balance
    function depositIntoWallet() public payable onlyRegistered {
        require(msg.value > 0, "Must send ETH");
        balances[msg.sender] += msg.value;//我朋友向我的账户存钱，必须使用ETH
    }
    
     // Record that someone owes you money
    function recordDebt(address _debtor, uint256 _amount) public onlyRegistered {//只能是名单里的人
        require(_debtor != address(0), "Invalid address");//欠债朋友的地址只有“圈内人”之间才能产生债务往来
        require(_amount > 0, "Amount must be greater than 0");//欠债人欠了我多少数额的钱
        
        debts[_debtor][msg.sender] += _amount;//在 debts[A][B] 这个结构里，通常第一个地址 A 是被查询的主体（欠债人），第二个地址 B 是关联的债主。
    }

       // Pay off debt using internal balance transfer，让用户能用自己在 balances 账本里的余额，去冲抵在 debts 账本里欠别人的债务。
    function payFromWallet(address _creditor, uint256 _amount) public onlyRegistered {
        require(_creditor != address(0), "Invalid address");//债主不能是空地址
        require(registeredFriends[_creditor], "Creditor not registered");//不能把钱还给一个不在朋友圈名单里的“陌生人”。
        require(_amount > 0, "Amount must be greater than 0"); //还款金额必须大于 0，防止无效操作
        require(debts[msg.sender][_creditor] >= _amount, "Debt amount incorrect");//“不能多还”。
        require(balances[msg.sender] >= _amount, "Insufficient balance");//“余额充足”。你在银行里的“内部存款”必须够还这笔债。

        // Update balances and debt
        balances[msg.sender] -= _amount;//欠债的人（你自己）在银行里的可用余额减少了
        balances[_creditor] += _amount;//债主在银行里的可用余额增加了。
        debts[msg.sender][_creditor] -= _amount;//“欠条数字”变小了（如果还清了就变成 0）。
    }

      // Direct transfer method using transfer()，让你在合约里的虚拟余额 (balances) 变成对方钱包里实实在在的 ETH。
    function transferEther(address payable _to, uint256 _amount) public onlyRegistered {
        require(_to != address(0), "Invalid address");
        require(registeredFriends[_to], "Recipient not registered");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;//我扣钱
        _to.transfer(_amount); //对方收钱
        balances[_to] +=_amount;
    }

        // Alternative transfer method using call()
    function transferEtherViaCall(address payable _to, uint256 _amount) public onlyRegistered {
        require(_to != address(0), "Invalid address");
        require(registeredFriends[_to], "Recipient not registered");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount;
        
        (bool success, ) = _to.call{value: _amount}("");
        balances[_to]+=_amount;
        require(success, "Transfer failed");
    }
    
    // Withdraw your balance
    function withdraw(uint256 _amount) public onlyRegistered {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount;
        
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdrawal failed");
    }
    
    // Check your balance
    function checkBalance() public view onlyRegistered returns (uint256) {
        return balances[msg.sender];
    }
}
    
