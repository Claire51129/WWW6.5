// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-IDepositBox.sol";
import "./day14-BasicDepositBox.sol";
import "./day14-PremiumDepositBox.sol";
import "./day14-TimeLockedDepositBox.sol";

contract VaultManager {
    //constructor(address initialOwner) BaseDepositBox(initialOwner) {}
    mapping(address => address[]) private userDepositBoxes; //将用户的地址映射到其拥有的所有存款箱（作为合约地址）
    mapping(address => string) private boxNames;

    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType); //用户创建新存款箱时触发
    event BoxNamed(address indexed boxAddress, string name);//用户存款箱自定义名称

    function createBasicBox() external returns (address) {
        BasicDepositBox box = new BasicDepositBox(msg.sender); //new BasicDepositBox 合约并将其地址存储在变量 box 
        userDepositBoxes[msg.sender].push(address(box)); // box list add新存款箱
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox(msg.sender);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    function createTimeLockedBox(uint256 lockDuration) external returns (address) { // add  lockDuration
        TimeLockedDepositBox box = new TimeLockedDepositBox(msg.sender,lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }

    function nameBox(address boxAddress, string calldata name) external {
        IDepositBox box = IDepositBox(boxAddress); // 将通用地址转换为接口
        require(box.getOwner() == msg.sender, "Not the box owner");
        boxNames[boxAddress] = name; //只有合法的所有者可以重命名存款箱
        emit BoxNamed(boxAddress, name);
    }

    function storeSecret(address boxAddress, string calldata secret) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.storeSecret(secret); ////只有合法的所有者可以 store secret
    }

    function transferBoxOwnership(address boxAddress, address newOwner) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.transferOwnership(newOwner); //会告知存储箱合约，让其更新自己的内部 owner 状态
        //// 从旧所有者处移除金库
        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; i < boxes.length; i++) {
            if (boxes[i] == boxAddress) { //我们循环查找正在被转移的那
                boxes[i] = boxes[boxes.length - 1]; //将它与数组中的最后一项交换
                boxes.pop(); //调用 .pop() 来删除最后一项
                break;
            }
        }
        //将金库添加到新所有者
        userDepositBoxes[newOwner].push(boxAddress);
    }

    function getUserBoxes(address user) external view returns (address[] memory) {
        return userDepositBoxes[user]; //返回属于特定用户的存款箱地址列表
    }

    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    function getBoxInfo(address boxAddress) external view returns ( //一次调用获取完整信息
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ) {
        IDepositBox box = IDepositBox(boxAddress);
        return (
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxNames[boxAddress]
        );
    }
}
