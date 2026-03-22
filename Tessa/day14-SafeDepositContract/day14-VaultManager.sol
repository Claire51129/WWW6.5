// 银行管理中心（整个系统）
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

import {IDepositBox} from "./day14-IDepositBox.sol";
import {BasicDepositBox} from "./day14-BasicDepositBox.sol";
import {PremiumDepositBox} from "./day14-PremiumDepositBox.sol";
import {TimeLockedDepositBox} from "./day14-TimeLockedDeposit.sol";

contract VaultManager{

    mapping(address => address[]) private userDepositBoxes;    //用户拥有的箱子：用户地址 → 保险箱列表
    mapping(address => string)private boxNames;    //box地址 → 名字

    event BoxCreated(address indexed owner, address indexed boxAdress, string boxType);
    event BoxNamed(address indexed boxAddress, string name);

    //创建Basic箱：创建、保存、记录事件、返回
    function createBasicBox() external returns (address){

        BasicDepositBox box = new BasicDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender,address(box), "Basic");
        return address(box);
    }

    //创建Premium箱
    function createPremiumBox() external returns (address){

        PremiumDepositBox box = new PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box),"Premium");
        return address(box);
    }

    //创建带锁时间的箱子
    function createTimeLockedBox(uint256 lockDuration) external returns (address){
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }

    //给箱子起名字：获取箱子、检查是不是owner、设置名字、记录事件
    function nameBox(address boxAddress, string memory name ) external{
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the owner of the box");
        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);

    }

    //存秘密
    function storeSecret(address boxAddress, string calldata secret) external{
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the owner of the box");
        box.storeSecret(secret);    //调用
    }

    //转移所有权：确认owner、调用box.transferOwnership、从旧用户列表删除、加入新用户列表（gas费最省）
    function transferBoxOwnership(address boxAddress, address newOwner) external{
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the owner of the box");
        box.transferOwnership(newOwner);
        address[] storage boxes = userDepositBoxes[msg.sender];
        for(uint i = 0; i < boxes.length; i++){
            if(boxes[i] == boxAddress){
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        }

        userDepositBoxes[newOwner].push(boxAddress);
    }

    //获取用户箱子
    function getUserBoxes(address user) external view returns(address[] memory){
        return userDepositBoxes[user];    //返回用户所有箱子
    }

    //获取箱子名字
    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    //获取箱子信息，返回类型、owner、创建时间、名字
    function getBoxInfo(address boxAddress)external view returns(
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ){
        IDepositBox box = IDepositBox(boxAddress);
        return(
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxNames[boxAddress]
        );
    }

}



// mapping 键值存储
// address[] 地址数组
// new contract 创建新合约
// interface调用 IDepositBox
//gas优化删除：swap+pop