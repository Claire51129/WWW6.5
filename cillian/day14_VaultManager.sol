// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入所有相关的合约文件
import "./day14_IDepositBox.sol";
import "./day14_BasicDepositBox.sol";
import "./day14_PremiumDepositBox.sol";
import "./day14_TimeLockedDepositBox.sol";

/**
 * @dev VaultManager 是一个工厂合约兼管理中心。
 * 它负责创建不同的保险箱子合约，并统一记录和管理它们。
 */
contract VaultManager {
    // 映射：用户地址 => 他拥有的所有保险箱地址列表
    mapping(address => address[]) private userDepositBoxes;
    // 映射：保险箱地址 => 给保险箱起的自定义名字（保存在管理合约中，而非子合约中）
    mapping(address => string) private boxNames;

    // 事件：记录新盒子的诞生
    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    // 事件：记录盒子被命名
    event BoxNamed(address indexed boxAddress, string name);

    /**
     * @notice 创建一个基础版保险箱（Basic）
     */
    function createBasicBox() external returns (address) {
        // 使用 new 关键字在链上部署一个新的子合约
        BasicDepositBox box = new BasicDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    /**
     * @notice 创建一个高级版保险箱（Premium）
     */
    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    /**
     * @notice 创建一个带有时间锁的保险箱（TimeLocked）
     * @param lockDuration 锁定的时长（秒）
     */
    function createTimeLockedBox(uint256 lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }

    /**
     * @notice 给保险箱命名
     * @dev 这里展示了【多态】：虽然传入的是地址，但我们把它看作 IDepositBox（母接口）
     */
    function nameBox(address boxAddress, string calldata name) external {
        IDepositBox box = IDepositBox(boxAddress);
        // 跨合约调用：询问子合约“你的主人是谁？”
        require(box.getOwner() == msg.sender, "Not the box owner");

        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }

    /**
     * @notice 通过管理合约统一调用子合约存入秘密
     */
    function storeSecret(address boxAddress, string calldata secret) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        // 跨合约指令：命令子合约执行 storeSecret
        box.storeSecret(secret);
    }

    /**
     * @notice 转让盒子所有权，并更新管理合约中的记录
     * @param boxAddress 盒子地址
     * @param newOwner 新主人的地址
     */
    function transferBoxOwnership(address boxAddress, address newOwner) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        // 1. 通知子合约修改它内部的 owner 变量
        box.transferOwnership(newOwner);

        // 2. 从旧主人的列表中移除（典型的数组删除逻辑：用最后一个元素覆盖，然后 pop）
        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; i < boxes.length; i++) {
            if (boxes[i] == boxAddress) {
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        }

        // 3. 将地址加入新主人的列表
        userDepositBoxes[newOwner].push(boxAddress);
    }

    /**
     * @notice 查询某个用户拥有的所有保险箱地址
     */
    function getUserBoxes(address user) external view returns (address[] memory) {
        return userDepositBoxes[user];
    }

    /**
     * @notice 查询某个保险箱的自定义名称
     */
    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    /**
     * @notice 聚合查询：一次性获取盒子的类型、主人、创建时间和名字
     * @dev 核心体现：虽然子合约各不相同，但只要符合 IDepositBox 母接口，就能统一查询
     */
    function getBoxInfo(address boxAddress) external view returns (
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ) {
        IDepositBox box = IDepositBox(boxAddress);
        return (
            box.getBoxType(),   // 多态：不同盒子会返回不同的字符串
            box.getOwner(),
            box.getDepositTime(),
            boxNames[boxAddress]
        );
    }
    
}