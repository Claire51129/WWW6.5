//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SaveMyName{

    //不指定可见性修饰符，则默认private
    string name;
    string bio;
    uint256 age;
    string job;

    //name是状态变量，_name是函数参数，是一个临时变量。部署合约时仅规定name=_name，将来调用add函数时再输入_name的实际内容，更新存储name。否则name无法更改。【你的钱包（输入数据） --- 函数参数（临时变量 _newName） --- 智能合约逻辑 --- 状态变量（永久存储 name）】
    //字符串在 Solidity 中需要特殊处理，必须在函数内部显式地存储在内存中。【uint无需 memory：因为 uint256 永远是 32 字节。它像一个标准的小零件，EVM（虚拟机）可以直接在执行栈（Stack）上处理它，不需要开辟额外的临时中转站。string必须声明 memory：字符串的大小是不确定的。函数参数 _name 必须写 string memory，因为合约需要先在内存里拉出一条“临时传送带”来接收这段不定长的文本，然后再搬进 Storage。retrieve函数返回同理也需 memory。】
    function add (string memory _name,string memory _bio,uint256 _age, string memory _job)public{
        name=_name;
        bio=_bio;
        age=_age;
        job=_job;  
    }

    //用户调用如下retrieve函数可以一次性返回name&bio。如果在声明状态变量时用public自动生成getter函数，用户将分别查看到name和bio。
    //按照string，string，uint256，stirng的格式返回name，bio，age，job
    function retrieve()public view returns(string memory,string memory,uint256,string memory){
        return(name,bio,age,job);
    }
}

