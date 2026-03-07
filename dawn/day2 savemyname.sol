// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SaveMyName {

    string name;
    string bio;
    string career;
    string age;

    function add (string memory newname, string memory newbio) public {
        name = newname;
        bio = newbio;
    }

    function retrieve() public view returns (string memory, string memory) {
        return (name,bio);
    }
    function addcareer( string memory _career, string memory _age ) public {
        career = _career;
        age = _age;
    } 
    function retrivecareer () public view returns (string memory, string memory ) {
        return (career,age);
    }


    }
