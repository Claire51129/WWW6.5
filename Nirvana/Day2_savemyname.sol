// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SaveMyName{

    string name;
    string bio;

    function add (string memory newname, string memory newbio) public {
        name = newname;
        bio = newbio;
    }

    function retrieve()public view returns(string memory, string memory){
        return (name,bio);
    }
    
}
