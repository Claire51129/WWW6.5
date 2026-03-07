//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//投票站合约：实现添加候选人、查找候选人列表、为候选人投票、检查候选人收到的总票数
//补充：唯一名称登记、一人一票、候选人校验

contract PollStation{
    //定义数据结构：数组存储候选人名单 ，映射mapping存储名字作为键，票数作为值
    //public 关键字定义candidateNames，就自动生成一个获取的函数
    string[] public candidateNames;
    mapping (string => uint256) voteCount;

    //---新增补充需求---
    //1、记录候选人是否已经存在，防止重复登记
    mapping(string => bool) public candidateExists;
    //2、记录投票人地址，防止重复投票
    mapping(address =>bool) public hasVoted;
    
    //添加候选人，在添加之前校验是否已存在
    function addCandidateName(string memory _candidateNames) public {
          //校验：名字已存在则报错
          require(!candidateExists[_candidateNames],"Candidate already exists!");
          
           candidateNames.push(_candidateNames);
           voteCount[_candidateNames] = 0;
           candidateExists[_candidateNames]=true;
    }

    //检索候选人列表
    function getCandidateNames()public view returns(string [] memory){
        return candidateNames;
    }

    //为候选人投票,一人一票+校验候选人
    function vote(string memory _candidateNames) public{
        // 校验 1：确保投票人还没投过票 (msg.sender 是当前操作者的地址)
        require(!hasVoted[msg.sender], "You have already voted!");
        // 校验 2：确保投票的对象是真实登记过的候选人
        require(candidateExists[_candidateNames], "Candidate does not exist!");
        
        voteCount[_candidateNames]++;
        hasVoted[msg.sender] = true; // 标记该地址已投票
    }



    //检查候选人收到的总票数
    function getvote(string memory _candidateNames) public view returns(uint256){
        return voteCount[_candidateNames];
    }
    
    }