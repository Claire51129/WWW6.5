// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract addCandidateNames{

string[] public candidateNames;
mapping (string => uint256) voteCount;

// 添加候选人
function addCandidateName(string memory _candidateNames)public {
    candidateNames.push(_candidateNames);
    voteCount[_candidateNames] = 0;
}
//检查候选人列表
function getcandidateNames() public view returns(string[] memory){
    return candidateNames;
}
//投票
function vote(string memory _candidateNames) public {
   //检查后选人列表 keccak256 bytes -->字符串转换字节数（只确定长度）转哈希值
   bool candidateExists = false;
    for(uint i = 0;i<candidateNames.length;i++){
        if (keccak256(bytes(candidateNames[i])) == keccak256(bytes(_candidateNames))){

        candidateExists = true;
        break;

        }
    }

    if (candidateExists) {
    voteCount[_candidateNames]++;
    }
}

//查票
function getvote(string memory _candidateNames) public view returns (uint256){
    return voteCount[_candidateNames];
   
}

}