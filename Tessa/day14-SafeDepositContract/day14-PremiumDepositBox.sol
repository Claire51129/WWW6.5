//高级保险箱：string private metadata存额外信息
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import {BaseDepositBox} from "./day14-BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox{

    string private metadata;
    event MetadataUpdated(address indexed owner);

    function getBoxType() override public pure returns(string memory){
        return "Premium";
    }

    //设置metadata
    function setMetadata(string calldata _metadata) external onlyOwner{    //只有owner可修改
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }

    //获取metadata
    function getMetadata() external view onlyOwner returns(string memory){    //只有owner可看
        return metadata;
    }


}


// 扩展功能：在继承上增加功能
// onlyOwner：权限控制