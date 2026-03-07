// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract SaveMyName{

    string name;
    string bio;
    string age;
    string job;

    //合并
    function saveAndRetrieve(string memory _name, string memory _bio, string memory _age, string memory _job) public returns (string memory, string memory, string memory, string memory) {
        name = _name;
        bio = _bio;
        age = _age;
        job = _job;
        return (name, bio, age, job);
    }

    //存储
    function add(string memory newName, string memory newBio, string memory newAge, string memory newJob) public {
        name = newName;
        bio = newBio;
        age = newAge;
        job = newJob;
    }
    //获取
    function retrieve() public view returns (string memory, string memory, string memory, string memory) {
        return (name, bio, age, job);
    }

}
