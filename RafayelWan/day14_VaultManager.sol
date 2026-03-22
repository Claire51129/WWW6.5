// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_IDepositBox.sol";
import "./day14_BasicDepositBox.sol";
import "./day14_PremiumDepositBox.sol";
import "./day14_TimeLockedDepositBox.sol";

contract VaultManager//管理器合约
{
    mapping(address => address[]) private userDepositBoxes;
    mapping(address => string) private boxNames;

    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    event BoxNamed(address indexed boxAddress, string name);

    function createBasicBox() external returns (address) 
    {
        BasicDepositBox box = new BasicDepositBox();//部署一个新的BasicDepositBox合约并将其地址存储在变量box中
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    function createPremiumBox() external returns (address) 
    {
        PremiumDepositBox box = new PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    function createTimeLockedBox(uint256 lockDuration) external returns (address) 
    {
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        userDepositBoxes[msg.sender].push(address(box));//一个用户可以拥有多个boxes
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }

    function nameBox(address boxAddress, string calldata name) external 
    {
        IDepositBox box = IDepositBox(boxAddress);//获取boxAddress（这只是区块链上的一个常规地址），并将其转换为IDepositBox接口类型,从而可以安全地调用getBoxType()、getOwner() 和 getDepositTime() 函数，而无需确切知道它是哪种类型的存款箱（基础型、高级型、时间锁型等）
        require(box.getOwner() == msg.sender, "Not the box owner");

        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }

    function storeSecret(address boxAddress, string calldata secret) external 
    {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.storeSecret(secret);
    }

    function transferBoxOwnership(address boxAddress, address newOwner) external 
    {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.transferOwnership(newOwner);

        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; i < boxes.length; i++)//循环查找被转移的box 
        {
            if (boxes[i] == boxAddress) {
                boxes[i] = boxes[boxes.length - 1];//找到以后用数组最后一项覆盖
                boxes.pop();//删除数组最后一项（可以让数组不留下空位
                break;
            }
        }

        userDepositBoxes[newOwner].push(boxAddress);
    }

    function getUserBoxes(address user) external view returns (address[] memory) 
    {
        return userDepositBoxes[user];
    }

    function getBoxName(address boxAddress) external view returns (string memory) 
    {
        return boxNames[boxAddress];
    }

    function getBoxInfo(address boxAddress) external view returns (string memory boxType,address owner,uint256 depositTime,string memory name) 
    {
        IDepositBox box = IDepositBox(boxAddress);
        return (box.getBoxType(),box.getOwner(),box.getDepositTime(),boxNames[boxAddress]);
    }
}