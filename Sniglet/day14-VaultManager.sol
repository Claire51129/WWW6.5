// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

import "./day14-IDepositBox.sol";

abstract contract BaseDepositBox is IDepositBox {
    address private owner;
    string private secret;
    uint256 private depositTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner);

    constructor() {
        owner = msg.sender;
        depositTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Not the owner");
        _;
    }

    function getOwner() public view override returns (address) {
        return owner;
    }

    function transferOwnership(address newOwner) external virtual override onlyOwner {
        require(newOwner != address(0), "Invalid Address");
        emit OwnershipTransferred(owner, newOwner); 
        owner = newOwner;
    }

    function storeSecret(string calldata _secret) external virtual override onlyOwner {
        secret = _secret;
        emit SecretStored(msg.sender);
    }

    function getSecret() public view virtual override onlyOwner returns (string memory) {
        return secret;
    }

    function getDepositTime() external view virtual override returns (uint256) {
        return depositTime;
    }
}

contract BasicDepositBox is BaseDepositBox {
    function getBoxType() external pure override returns(string memory) {
        return "Basic";
    }
}

contract PremiumDepositBox is BaseDepositBox {
    string private metadata;
    event MetadataUpdated(address indexed owner);

    function getBoxType() override public pure returns(string memory) {
        return "Premium";
    } 

    function setMetadata(string calldata _metadata) external onlyOwner {
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }

    function getMetadata() external view onlyOwner returns(string memory) {
        return metadata;
    }
}

contract TimeLockedDepositBox is BaseDepositBox {
    uint256 private unlockTime;
    
    constructor(uint256 lockDuration) {
        unlockTime = block.timestamp + lockDuration;
    }

    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Box is still locked");
        _;
    }

    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }

    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
        return super.getSecret();
    }

    function getUnlockTime() external view returns(uint256) {
        return unlockTime;
    }

    function getRemainingLockTime() external view returns(uint256) {
        if(block.timestamp >= unlockTime) return 0;
        return unlockTime - block.timestamp;
    }
}

contract VaultManager {
    mapping(address => address[]) private userDepositBoxes;
    mapping(address => string) private boxNames;

    event BoxCreated(address indexed owner, address indexed boxAdress, string boxType);
    event BoxNamed(address indexed boxAdress, string name);

    function createBasicBox() external returns (address) {
        BasicDepositBox box = new BasicDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    function createTimeLockedBox(uint256 lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Time Locked");
        return address(box);
    }

    function nameBox(address boxAddress, string memory name ) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }

    function storeSecret(address boxAddress, string calldata secret) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        box.storeSecret(secret);
    }

    // transferBoxOwnership 函数（消警告+正确删除数组元素）
    function transferBoxOwnership(address boxAddress, address newOwner) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        require(newOwner != address(0), "New owner cannot be zero address");
        
        // 1. 转移箱子所有权
        box.transferOwnership(newOwner);
        
        // 2. 从原主人的箱子列表中删除该箱子（正确逻辑）
        address[] storage boxes = userDepositBoxes[msg.sender];
        uint256 foundIndex = boxes.length; // 初始设为"不存在"的索引
        
        // 遍历找到要删除的箱子地址
        for(uint256 i = 0; i < boxes.length; i++){
            if(boxes[i] == boxAddress) {
                foundIndex = i;
                break; // 找到后跳出循环，不会触发i++不可达警告
            }
        }
        
        // 如果找到该箱子，执行删除操作
        if(foundIndex < boxes.length) {
            // 把最后一个元素移到要删除的位置
            boxes[foundIndex] = boxes[boxes.length - 1];
            // 删除最后一个重复的元素
            boxes.pop();
        }
        
        // 3. 把箱子添加到新主人的列表中
        userDepositBoxes[newOwner].push(boxAddress);
    }

    function getUserBoxes(address user) external view returns(address[] memory) {
        return userDepositBoxes[user];
    }

    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    function getBoxInfo(address boxAddress) external view returns(
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ) {
        IDepositBox box = IDepositBox(boxAddress);
        return(
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxNames[boxAddress]
        );
    }
}