// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

contract SaveMyName{
    struct User{
        string name;       
        string bio;     
        uint256 age;    
        string profession;
    }
    
    User public user;

    function add(
        string memory _name, 
        string memory _bio ,
        uint256 _age , 
        string memory _profession
    ) public {
        user =User(_name, _bio, _age, _profession);
    }

    function retrieve() 
        public  
        view 
        returns (string memory, string memory, uint256, string memory)
    {
        return (user.name, user.bio, user.age, user.profession);
    }


}