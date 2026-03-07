//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract SaveMyName{

    string twothree;
    string Web3Developer;
    uint age; // Declare the age variable here

    function add(string memory _twothree, string memory _Web3Developer) public {
        twothree =_twothree;
        Web3Developer = _Web3Developer;
        age = 22; // Assin the value to the age variable
    }

    function retrieve() public view returns(string memory,string memory,uint){
        return (twothree,Web3Developer,age); // Include age in the return statement
    }

    function getAge() public view returns(uint) {
    }

// Define the receive function to handle Ether sent directly to the contract
    //receive() external payable {
        // This function is called when Ether is sent to the contract without data
    
    // Define the fallback function to handle Ether sent with data or when no function is specified
    //fallback() external payable {
        // This function is called when Ether is sent with data or when no function is specified
}