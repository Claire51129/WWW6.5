// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./day14_1_IDepositBox.sol";
import "./day14_3_BasicDepositBox.sol";
import "./day14_4_PermiumDepositBox.sol";
import "./day14_5_TimeLockedDepositBox.sol";


/*
这个合约充当**控制中心**，供用户创建、命名、管理和与他们的存款箱交互。
可以将其视为你的**金库应用后端**：
- 它允许用户创建不同类型的存款箱（基础型、高级型、时间锁型）。
- 它跟踪哪个用户拥有哪个存款箱。
- 它强制执行所有权规则。
- 它提供命名和检索存款箱信息的辅助函数。
*/

contract VaultManager {
   //状态变量
   // `userDepositBoxes`：将用户的地址映射到其拥有的所有存款箱（作为合约地址）。
  mapping(address => address[]) private userDepositBoxes;
  //boxNames：允许用户为每个邮箱分配自定义名称。按邮箱地址存储。
  mapping(address => string) private boxNames;
  
  //事件有助于前端和浏览器显示
  event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
  event BoxNamed(address indexed boxAddress, string name);
  
  //需要主动把真正的地址传过来，不然就是传的VaultManager的地址
  function createBasicBox() external returns (address) {
        BasicDepositBox box = new BasicDepositBox(msg.sender);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
   }
    
      function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox(msg.sender);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }
        function createTimeLockedBox(uint256 lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox(msg.sender, lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }
    function nameBox(address boxAddress, string calldata name) external {
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

    function transferBoxOwnership(address boxAddress, address newOwner) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.transferOwnership(newOwner);

        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; i < boxes.length; i++) {
            if (boxes[i] == boxAddress) {
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        }

        userDepositBoxes[newOwner].push(boxAddress);
    }

    function getUserBoxes(address user) external view returns (address[] memory) {
        return userDepositBoxes[user];
    }

    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    function getBoxInfo(address boxAddress) external view returns (
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