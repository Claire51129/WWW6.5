// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    // lets people send tips in ETH directly or in other currecies like USD/CNY and we'll convert that to ETH
      address public owner;
      mapping (string => uint256) public conversionRates; // eg. USD to ETH
      string[] public supportedCurrencies;
      uint256 public totalTipReceived; 
      mapping (address => uint256) public tipperContributions;
      mapping (string => uint256) public tipsPerCurrency;

    //modifiers
      modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can perform this action.");
        _;
      }

    //functions
    function addCurrency(string memory _currencyCode, uint256 _rateToETH) public onlyOwner {
        require(_rateToETH > 0, "Conversion rate to ETH must be greater than 0");

        //check if currency already exists ————这里为什么不用之前查重registeredMember的mapping？
        //because in Solidity you can't directly compare two strings using "==" like address
        bool currencyExists = false;

        for (uint i = 0; i < supportedCurrencies.length; i++) {
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode)))
            //convert string to bytes by using "bytes()", and the pass those bytes into keccak256() -- Solidity's built-in cryptographic hash function
            {
                currencyExists = true;
                break;
            }
        }

        if (currencyExists == false) 
        {
            supportedCurrencies.push(_currencyCode);
        }

        //set the conversion rate
        conversionRates[_currencyCode] = _rateToETH;
    }

    constructor() {
        owner = msg.sender;

        addCurrency("USD", 5 * 10** 14); // 1 USD = 0.0005 ETH; 1 ETH = 1 * 10^18 wei
        addCurrency("EUR", 6 * 10** 14);
        addCurrency("JPY", 4 * 10** 12);
        addCurrency("GBP", 7 * 10** 14);
    }  

    //converting to ETH: calculate currency and return the equivalent ETH value (in wei)
    //Solidity don't do decimals
    function convertToETH(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported.");

        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;
    }

    //sending a Tip in ETH
    function tipInETH() public payable {
        require(msg.value > 0, "Tip amount must be greater than zero.");

        tipperContributions[msg.sender] += msg.value;
        totalTipReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }

    //sending a Tip in a Foreign Currency
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported.");
        require(_amount > 0, "Tip amount must be greater than zero.");

        uint256 ethAmount = convertToETH(_currencyCode, _amount);
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount.");

        tipperContributions[msg.sender] += ethAmount;
        totalTipReceived += ethAmount;
        tipsPerCurrency[_currencyCode] += _amount;
    } 

    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance; //address(this).balance
        require(contractBalance > 0, "No tips to withdraw.");

        (bool success, ) = payable (owner).call{value: contractBalance}(""); // sending the entire balance to the owner
        require(success, "Transfer failed.");

        totalTipReceived = 0;
    }

    function transferOwnership (address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address"); // check if the address is valid))
        owner = _newOwner;
    }

    //utility functions - getting infomation from the contract
    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
    }
    function getContractBalance() public view returns (uint256) {
        return address(this).balance; //number returned in wei, not ETH
    }
    function getTipperContributions(address _tipper) public view returns (uint256) {
        return tipperContributions[_tipper];
    }
    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];
    }
    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported.");
        return conversionRates[_currencyCode];
    }
}