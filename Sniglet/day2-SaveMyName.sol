//SPDX-License-Identifier:MIT 
pragma solidity ^0.8.0;
contract SaveMyName{
    string name ;
    string bio;
    function saveAndRetrieve(string memory Nname ,string memory Nbio)
    public returns (string memory,string memory){
        name =Nname ;
        bio = Nbio;
        return(name,bio);
     }
 }