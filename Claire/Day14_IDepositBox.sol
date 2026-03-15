// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

interface IDepositBox {  // 定义一个接口，叫IDepositBox（存款箱接口）

    function getOwner() external view returns(address);  // 查谁是这个盒子的主人
    // external:只能外部调用
    // view:不修改链上数据
    // returns(address):返回主人地址

    function transferOwnership(address newOwner) external;  // 把盒子转给新主人
    // 参数newOwner:新主人的地址

    function storeSecret(string calldata secret) external;  // 存一个秘密
    // calldata:只读的输入数据
    // secret:要存的秘密字符串

    function getSecret() external view returns (string memory);  // 取出存的秘密
    // memory:返回的数据存在内存里

    function getBoxType() external pure returns(string memory);  // 返回盒子类型
    // pure:不读也不写链上数据（纯计算）

    function getDepositTime() external view returns(uint256);  // 返回存秘密的时间
    // uint256:时间戳（秒数）

}