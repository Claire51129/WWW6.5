// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TipJar {

    address public owner;

    uint256 public totalTipsReceived;

    // 使用 bytes32 代替 string 作为 key
    mapping(bytes32 => uint256) public conversionRates;

    mapping(address => uint256) public tipPerPerson;

    bytes32[] public supportedCurrencies;

    mapping(bytes32 => uint256) public tipsPerCurrency;

    event TipReceived(address indexed tipper, uint256 amount, bytes32 currency);
    event CurrencyUpdated(bytes32 currency, uint256 rate);
    event Withdraw(address owner, uint256 amount);

    constructor() {
        owner = msg.sender;

        _addCurrency("USD", 5 * 10**14);
        _addCurrency("EUR", 6 * 10**14);
        _addCurrency("JPY", 4 * 10**12);
        _addCurrency("INR", 7 * 10**12);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function _addCurrency(string memory code, uint256 rate) internal {

        bytes32 currency = keccak256(bytes(code));

        if (conversionRates[currency] == 0) {
            supportedCurrencies.push(currency);
        }

        conversionRates[currency] = rate;

        emit CurrencyUpdated(currency, rate);
    }

    function addCurrency(string memory code, uint256 rate) public onlyOwner {

        require(rate > 0, "Invalid rate");

        _addCurrency(code, rate);
    }

    function convertToEth(string memory code, uint256 amount)
        public
        view
        returns (uint256)
    {
        bytes32 currency = keccak256(bytes(code));

        uint256 rate = conversionRates[currency];

        require(rate > 0, "Unsupported currency");

        return amount * rate;
    }

    function tipInEth() public payable {

        require(msg.value > 0, "Tip must be > 0");

        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;

        bytes32 eth = keccak256("ETH");
        tipsPerCurrency[eth] += msg.value;

        emit TipReceived(msg.sender, msg.value, eth);
    }

    function tipInCurrency(string memory code, uint256 amount)
        public
        payable
    {
        bytes32 currency = keccak256(bytes(code));

        uint256 rate = conversionRates[currency];

        require(rate > 0, "Unsupported currency");
        require(amount > 0, "Invalid amount");

        uint256 ethAmount = amount * rate;

        require(msg.value == ethAmount, "Incorrect ETH sent");

        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;

        tipsPerCurrency[currency] += amount;

        emit TipReceived(msg.sender, msg.value, currency);
    }

    function withdrawTips() public onlyOwner {

        uint256 balance = address(this).balance;

        require(balance > 0, "No balance");

        (bool success, ) = payable(owner).call{value: balance}("");

        require(success, "Transfer failed");

        emit Withdraw(owner, balance);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Invalid address");

        owner = newOwner;
    }

    function getSupportedCurrencies()
        public
        view
        returns (bytes32[] memory)
    {
        return supportedCurrencies;
    }

    function getContractBalance()
        public
        view
        returns (uint256)
    {
        return address(this).balance;
    }

    function getTipperContribution(address tipper)
        public
        view
        returns (uint256)
    {
        return tipPerPerson[tipper];
    }

    function getTipsInCurrency(string memory code)
        public
        view
        returns (uint256)
    {
        bytes32 currency = keccak256(bytes(code));
        return tipsPerCurrency[currency];
    }

    function getConversionRate(string memory code)
        public
        view
        returns (uint256)
    {
        bytes32 currency = keccak256(bytes(code));
        return conversionRates[currency];
    }
}