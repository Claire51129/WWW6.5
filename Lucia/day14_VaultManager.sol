// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_IDepositBox.sol";
import "./day14_BasicDepositBox.sol";
import "./day14_PremiumDepositBox.sol";
import "./day14_TimeLockedDepositBox.sol";

contract VaultManager{
    mapping(address => address[]) private userDepositBoxes;//address[]地址数组
    mapping(address => string) private boxNames;

    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    event BoxNamed(address indexed boxAddress, string name);

    function createBasicBox() external returns (address){
        BasicDepositBox box = new BasicDepositBox();//左边的BasicDepositBox类型不仅代表一个地址还告诉编译器这个地址上运行着符合BasicDepositBox规范的的代码
        //具体的合约（Contract）其实本身就是一份更高规格的“接口”。//右边的new BasicDepositBox 是指按照这张名为BasicDepositBox的图纸盖一栋新房子，部署一个完整的合约
        //new BasicDepositBox() 自动触发父合约的constructor
        userDepositBoxes[msg.sender].push(address(box));//box 博涵地址，为了匹配mapping(address => address[])需要用 address()把它强制转换成最基础的地址格式
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    function createPremiumBox() external returns (address){
        PremiumDepositBox box = new PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    function createTimeLockedBox(uint256 lockDuration) external returns (address){
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }

    function nameBox(address boxAddress, string calldata name) external {
        //function 里面的boxAddress是输入参数，event里面的boxAddress是记录标签，但值是一样的
        //Function参数-在银行输入账号为了钱可以过去，Event参数-银行回执单上印账号为了以后对账方便
        IDepositBox box = IDepositBox(boxAddress);
        //把boxAddress这串普通的address类型的看成一个遵循IDepositBox接口的合约，box就是一个合约了，可以执行box.getOwner()
        require(box.getOwner() == msg.sender, "Not the box owner");

        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }
    function storeSecret(address boxAddress, string calldata secret) external{
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        box.storeSecret(secret);
    }

    function transferBoxOwnership(address boxAddress, address newOwner) external{
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.transferOwnership(newOwner);
        address[] storage boxes =userDepositBoxes[msg.sender];

        for (uint i = 0; i < boxes.length; i++){
            if(boxes[i] == boxAddress){
                //boxAddress 你手里的那张准备转让给别人的地址
                boxes[i] = boxes[boxes.length -1];
                boxes.pop();//修建末尾
                break;
            }
        }
        userDepositBoxes[newOwner].push(boxAddress);
    }

    function getUserBoxes(address user) external view returns (address[] memory) {
        return userDepositBoxes[user];
    }

    function getBoxName(address boxAddress) external view returns(string memory){
        return boxNames[boxAddress];
    }

    function getBoxInfo(address boxAddress) external view returns(
        string memory boxType, address owner, uint256 depositTime, string memory name){
            IDepositBox box = IDepositBox(boxAddress);
            return (
                box.getBoxType(),
                box.getOwner(),//external call 合约暂停 跳到boxAddress那个地址跑一遍代码拿回结果再跳回来
                box.getDepositTime(),
                boxNames[boxAddress]//internal lookup 合约在自己的内存和存储里找，速度快且逻辑简单
                //
            );
        }

}
