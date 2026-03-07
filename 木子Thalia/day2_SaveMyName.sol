// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SaveMyName {
    string name;
    string bio;
    uint16 age;
    string job;

    // function add (string memory _name, string memory _bio) public {
    //     name = _name;
    //     bio = _bio;
    // }

    // function retrieve () public view returns (string memory, string memory) {
    //     return (name, bio);
    // }

    function saveAndRetrieve (string memory _name, string memory _bio, uint16 _age, string memory _job ) public returns (string memory, string memory, uint16, string memory) {
        name = _name;
        bio = _bio;
        age = _age;
        job = _job;
        return (name, bio, age, job);
    }
}
