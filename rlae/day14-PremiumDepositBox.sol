// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-BaseDepositBox.sol"; //从 BaseDepositBox 导入基础逻辑

contract PremiumDepositBox is BaseDepositBox {
    constructor(address initialOwner) BaseDepositBox(initialOwner) {}
    string private metadata;

    event MetadataUpdated(address indexed owner); //更新元数据,跟踪变化

    function getBoxType() external pure override returns (string memory) {
        return "Premium";
        // function does not read from or modify the contract's state. It only performs computations based on the input parameters and returns a value. In this case, the function simply returns the string "Premium" without accessing any state variables or blockchain data.
        //Using pure functions can help optimize gas usage and ensure that the function does not have any unintended side effects. 
    }

    function setMetadata(string calldata _metadata) external onlyOwner {
        metadata = _metadata;
        //可以将注释、类别或标签附加到他们的金库上的方法
        emit MetadataUpdated(msg.sender); 
    }

    function getMetadata() external view onlyOwner returns (string memory) {
        return metadata;
    }

}
