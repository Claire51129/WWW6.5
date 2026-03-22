// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Day14-IDepositBox.sol";
import "./Day14-BasicDepositBox.sol";
import "./Day14-PremiumDepositBox.sol";
import "./Day14-TimeLockedDepositBox.sol";

//金库管理中心
contract VaultManager{

    mapping(address => address[]) private userDepositBoxes;
    mapping(address => string)private boxNames;

    event BoxCreated(address indexed owner, address indexed boxAdress, string boxType);
    event BoxNamed(address indexed boxAdress, string name);

    //创建基础版箱子 用户按了就return一个新创建的箱子地址
    function createBasicBox() external returns (address){

        //BasicDepositBox box = new BasicDepositBox(); 
        //这个新创建的box的owner是msg.sender
        //address（this)指的是当前这个管理中心合约
        BasicDepositBox box = new BasicDepositBox(msg.sender, address(this));

        ////记录用户的box的列表 push是在列表后面加新的东西
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    function createPremiumBox() external returns (address){

        PremiumDepositBox box = new PremiumDepositBox(msg.sender, address(this));
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    function createTimeLockedBox(uint256 lockDuration) external returns (address){
        TimeLockedDepositBox box = new TimeLockedDepositBox(msg.sender, address(this),lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Time Locked");
        return address(box);
    }

    function nameBox(address boxAddress, string memory name ) external{
        IDepositBox box = IDepositBox(boxAddress); 
        require(box.getOwner() == msg.sender, "Not the box owner");
        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);

    }



    function storeSecret(address boxAddress, string calldata secret) external{
        IDepositBox box = IDepositBox(boxAddress); //不写具体合约名 管理中心把所有type的box都当成标准的复合这个标准的箱子
        require(box.getOwner() == msg.sender, "Not the box owner");
        box.storeSecret(secret);



    }




    function transferBoxOwnership(address boxAddress, address newOwner)  external{
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



        // for(uint i = 0; i < boxes.length; i++){
        //     boxes[i] = boxes[boxes.length - 1];
        //     boxes.pop();
        //     break;
        // }

        userDepositBoxes[newOwner].push(boxAddress);
      
    }

    function getUserBoxes(address user) external view returns(address[] memory){
        return userDepositBoxes[user];
    }

    function getBoxName(address boxAddress) external view returns (string memory) {
    return boxNames[boxAddress];
}

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

    


    