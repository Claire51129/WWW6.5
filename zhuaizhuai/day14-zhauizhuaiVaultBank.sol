// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract zhuaizhuaiVaultBank {
    enum BoxType {
        Basic,
        Premium,
        TimeLocked
    }

    struct Vault {
        address owner;      // 主人地址
        uint256 balance;    // 余额
        BoxType boxType;    // 金库类型
        uint256 depositTime; // 存入时间
        uint256 unlockTime;  // 解锁时间（TimeLocked用）
        string metadata;    // 附加信息（Premium用）
        bool exists;        // 是否存在
    }

    mapping (address =>Vault) public vaults;

    event VaultCreated(address indexed owner, BoxType boxType, uint256 depositTime);
    event Deposited(address indexed owner, BoxType boxType, uint256 amount, uint256 depositTime);
    event Withdrawn(address indexed owner, BoxType boxType, uint256 amount, uint256 withdrawTime);
    event VaultUnlocked(address indexed owner, uint256 withdrawTime);

    modifier onlyOwner() {
        require(msg.sender == vaults[msg.sender].owner, "Not the box owner");
        _;
    }

    modifier vaultExists() {
         require(vaults[msg.sender].exists == true, "Vault does not exist");
        _;
   
    }

    modifier timeUnlocked() {
        require(block.timestamp >= vaults[msg.sender].unlockTime, "Vault is still locked");
        _;
    }

     // 创建金库
    function createVault(BoxType _boxType, uint256 _lockDuration) public {
        require(!vaults[msg.sender].exists, "Vault already exists");
        
        vaults[msg.sender] = Vault({
            owner: msg.sender,
            balance: 0,
            boxType: _boxType,
            depositTime: block.timestamp,
            unlockTime: _boxType == BoxType.TimeLocked 
                ? block.timestamp + _lockDuration 
                : 0,
            metadata: "",
            exists: true
        });

        emit VaultCreated(msg.sender, _boxType, block.timestamp);
    }

    // 存款
    function deposit() public payable vaultExists onlyOwner {
        require(msg.value > 0, "Amount must be greater than 0");
        vaults[msg.sender].balance += msg.value;
        emit Deposited(msg.sender, vaults[msg.sender].boxType, msg.value, block.timestamp);
    }

    // 取款
    function withdraw(uint256 _amount) public vaultExists onlyOwner {
        require(vaults[msg.sender].balance >= _amount, "Not enough balance");
        
        // 如果是TimeLocked，检查时间
        if(vaults[msg.sender].boxType == BoxType.TimeLocked) {
            require(block.timestamp >= vaults[msg.sender].unlockTime, "Vault is still locked");
        }

        vaults[msg.sender].balance -= _amount;
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");
        emit Withdrawn(msg.sender, vaults[msg.sender].boxType, _amount, block.timestamp);
    }

    // 查余额
    function getBalance() public view vaultExists returns(uint256) {
        return vaults[msg.sender].balance;
    }

    // 查金库信息
    function getVaultInfo() public view vaultExists returns(
        BoxType boxType,
        uint256 balance,
        uint256 depositTime,
        uint256 unlockTime
    ) {
        Vault memory v = vaults[msg.sender];
        return (v.boxType, v.balance, v.depositTime, v.unlockTime);
    }

    // Premium用：存附加信息
    function setMetadata(string calldata _metadata) public vaultExists onlyOwner {
        require(vaults[msg.sender].boxType == BoxType.Premium, "Only Premium vaults");
        vaults[msg.sender].metadata = _metadata;
    }

    // Premium用：查附加信息
    function getMetadata() public view vaultExists onlyOwner returns(string memory) {
        require(vaults[msg.sender].boxType == BoxType.Premium, "Only Premium vaults");
        return vaults[msg.sender].metadata;
    }




}
