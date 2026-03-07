// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract pollstation {

    string [] public candidatenames;
    mapping(string => uint256 ) votecount;

    function addcandidatenames(string memory _candidatenames)public {
        candidatenames.push(_candidatenames);
        votecount[_candidatenames] = 0;
    }
    function getcandidatenames()public view returns (string[]memory) {
        return candidatenames;
    }

    function vote(string memory _candidatenames) public {
        votecount[_candidatenames] += 1;
    }

    function getvote(string memory _candidatenames)public view returns (uint256) {
        return votecount [_candidatenames];
    }
}
