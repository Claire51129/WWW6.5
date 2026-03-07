// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SaveNameAndBio{

    string name;
    string bio;

    function addInfo(string memory newName, string memory newBio) public{
        name = newName;
        bio = newBio;
    }

    function getInfo() public view returns(string memory, string memory){
        return (name, bio);
    }
}

