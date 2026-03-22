// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title 单个保险箱合约（只认管理器，不认用户）
 * @dev 解决原onlyOwner把管理器地址认成主人的问题：保险箱只允许管理器调用，权限校验交给管理器
 */
contract DepositBox {
    // 存储的秘密内容（私有变量，外部无法直接读取）
    string private secret;
    // 保险箱的管理者地址（固定为创建它的VaultManager合约地址）
    address public manager;

    /**
     * @dev 构造函数：部署时指定管理者（由VaultManager调用，所以manager是VaultManager的地址）
     * @param _manager 管理者合约地址
     */
    constructor(address _manager) {
        manager = _manager;
    }

    /**
     * @dev 修饰器：仅允许管理者（VaultManager）调用
     * 替代原来的onlyOwner，避免把VaultManager地址误判为用户owner
     */
    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can operate this box");
        _;
    }

    /**
     * @dev 存储秘密：仅管理者可调用
     * @param _secret 要存入的秘密内容
     */
    function storeSecret(string calldata _secret) external onlyManager {
        secret = _secret;
    }

    /**
     * @dev 获取秘密：仅管理者可调用
     * @return 秘密内容
     */
    function getSecret() external view onlyManager returns (string memory) {
        return secret;
    }
}

/**
 * @title 保险箱管理器（核心：负责创建箱子 + 验证用户 ownership）
 * @dev 把ownership校验从DepositBox移到这里，解决msg.sender变成管理器地址的问题
 */
contract VaultManager {
    // 核心映射：记录「用户地址 → 他拥有的所有保险箱地址列表」
    mapping(address => address[]) public userDepositBoxes;

    /**
     * @dev 创建新保险箱：用户调用后，自动创建一个新DepositBox，并把地址加入用户的箱子列表
     */
    function createBox() external {
        // 1. 创建新的DepositBox，指定管理者为当前VaultManager合约
        DepositBox box = new DepositBox(address(this));
        // 2. 把新箱子地址加入调用者（msg.sender）的箱子列表
        userDepositBoxes[msg.sender].push(address(box));
    }

    /**
     * @dev 存储秘密：先验证「这个箱子是否属于调用者」，再调用箱子的storeSecret
     * @param boxAddress 目标保险箱地址
     * @param secret 要存入的秘密
     */
    function storeSecret(address boxAddress, string calldata secret) external {
        // 1. 校验：这个箱子是否属于当前调用者
        bool owned = false;
        // 遍历调用者的所有箱子地址，看是否包含目标boxAddress
        for (uint i = 0; i < userDepositBoxes[msg.sender].length; i++) {
            if (userDepositBoxes[msg.sender][i] == boxAddress) {
                owned = true;
                break;
            }
        }
        // 校验不通过则报错
        require(owned, "Box not owned by sender");

        // 2. 校验通过：将boxAddress转为IDepositBox接口，调用其storeSecret
        DepositBox box = DepositBox(boxAddress);
        box.storeSecret(secret);
    }

    /**
     * @dev 获取秘密：逻辑同storeSecret，先验证ownership
     * @param boxAddress 目标保险箱地址
     * @return 秘密内容
     */
    function getSecret(address boxAddress) external view returns (string memory) {
        // 1. 校验：这个箱子是否属于当前调用者
        bool owned = false;
        for (uint i = 0; i < userDepositBoxes[msg.sender].length; i++) {
            if (userDepositBoxes[msg.sender][i] == boxAddress) {
                owned = true;
                break;
            }
        }
        require(owned, "Box not owned by sender");

        // 2. 校验通过：调用箱子的getSecret
        DepositBox box = DepositBox(boxAddress);
        return box.getSecret();
    }

    /**
     * @dev 辅助函数：查询当前用户拥有的所有保险箱地址
     * @return 用户的保险箱列表
     */
    function getMyBoxes() external view returns (address[] memory) {
        return userDepositBoxes[msg.sender];
    }
}