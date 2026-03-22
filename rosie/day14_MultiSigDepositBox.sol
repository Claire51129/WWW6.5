// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigDepositBox {
    enum BoxType {
        Basic,
        Premium
    }

    address public owner;
    address[] public signers;
    uint256 public requiredApprovals;
    BoxType public boxType;
    uint256 public createdAt;

    string private secret;

    // 每次发起“读取秘密申请”时，都会生成一个新的 requestId
    uint256 public currentRequestId;

    // requestId => signer => 是否已批准
    mapping(uint256 => mapping(address => bool)) public secretApprovals;

    // requestId => 已批准数量
    mapping(uint256 => uint256) public approvalCount;

    // 事件
    event SecretStored(address indexed owner, uint256 timestamp);
    event SecretAccessRequested(uint256 indexed requestId, address indexed requester, uint256 timestamp);
    event SecretApproved(uint256 indexed requestId, address indexed signer, uint256 currentApprovalCount);
    event SecretRead(address indexed owner, uint256 indexed requestId, uint256 timestamp);
    event BoxUpgraded(address indexed owner, string newBoxType, uint256 timestamp);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlySigner() {
        require(isSigner(msg.sender), "Not signer");
        _;
    }

    constructor(
        string memory _secret,
        address[] memory _signers,
        uint256 _requiredApprovals
    ) {
        require(_signers.length > 0, "Need at least one signer");
        require(
            _requiredApprovals > 0 && _requiredApprovals <= _signers.length,
            "Invalid required approvals"
        );

        owner = msg.sender;
        secret = _secret;
        boxType = BoxType.Basic;
        createdAt = block.timestamp;
        signers = _signers;
        requiredApprovals = _requiredApprovals;

        emit SecretStored(msg.sender, block.timestamp);
    }

    // =========================
    // 基础查询函数
    // =========================

    function getOwner() external view returns (address) {
        return owner;
    }

    function getBoxType() external view returns (string memory) {
        if (boxType == BoxType.Basic) {
            return "Basic";
        } else {
            return "Premium";
        }
    }

    function getCreatedTime() external view returns (uint256) {
        return createdAt;
    }

    function getSigners() external view returns (address[] memory) {
        return signers;
    }

    function isSigner(address user) public view returns (bool) {
        for (uint256 i = 0; i < signers.length; i++) {
            if (signers[i] == user) {
                return true;
            }
        }
        return false;
    }

    // =========================
    // 存储秘密
    // =========================

    function storeSecret(string memory _newSecret) external onlyOwner {
        secret = _newSecret;

        // 重置旧的读取请求流程，避免旧批准继续生效
        currentRequestId++;

        emit SecretStored(msg.sender, block.timestamp);
    }

    // =========================
    // 多签读取秘密
    // =========================

    // owner 发起一次新的“读取秘密申请”
    function requestSecretAccess() external onlyOwner {
        currentRequestId++;
        emit SecretAccessRequested(currentRequestId, msg.sender, block.timestamp);
    }

    // signer 对当前 requestId 进行批准
    function approveSecretAccess() external onlySigner {
        require(currentRequestId > 0, "No active request");
        require(
            !secretApprovals[currentRequestId][msg.sender],
            "Already approved"
        );

        secretApprovals[currentRequestId][msg.sender] = true;
        approvalCount[currentRequestId]++;

        emit SecretApproved(
            currentRequestId,
            msg.sender,
            approvalCount[currentRequestId]
        );
    }

    // owner 在达到批准数后读取秘密
    function getSecret() external onlyOwner returns (string memory) {
        require(currentRequestId > 0, "No active request");
        require(
            approvalCount[currentRequestId] >= requiredApprovals,
            "Not enough approvals"
        );

        emit SecretRead(msg.sender, currentRequestId, block.timestamp);
        return secret;
    }

    // =========================
    // 升级功能
    // =========================

    function upgradeToPremium() external onlyOwner {
        require(boxType == BoxType.Basic, "Already Premium");
        boxType = BoxType.Premium;

        emit BoxUpgraded(msg.sender, "Premium", block.timestamp);
    }

    // =========================
    // 转让功能
    // =========================

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner");

        address oldOwner = owner;
        owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner, block.timestamp);
    }
}