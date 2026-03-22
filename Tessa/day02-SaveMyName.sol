// 区块链上的小资料卡：存储姓名和简介等（读写区块链数据）
// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract SaveMyName{

    string name;
    string bio;

    uint256 age;
    string job;

    //更新、存储数据：姓名和简介,年龄和职位
    function add (string memory _name, string memory _bio, uint256 _age, string memory _job )public {
        name = _name;    // 函数参数_name和_bio是占位符，用于存储用户的输入
        bio = _bio;
        age = _age;
        job = _job;
    }

    //检索函数：从区块链获取数据：姓名和简介等（仅调用查看）
    function retrieve() public view returns(string memory, string memory, uint256, string memory){
        return (name,bio,age,job);
    }
    
}



// Solidity有两种主要存储类型：1）Storage(存储)——永久存储在区块链上的数据（eg姓名&简介）；2）Memory(内存)——仅在函数运行时存在的临时存储空间。当函数接受字符串作为输入时，Solidity要求我们明确说明它是存储在内存M还是存储S中。内存memory就像草稿纸，函数运行时暂时保存，然后小时。
// view告诉Solidity这个函数只读取数据，不修改区块链，只是获取并返回现有数据，调用时不会消耗gas
// 字符串在Solidity中需特殊处理，必须在函数内部显式地存储在内存中；
// 函数参数中的下划线(_)只是命名约定，并非强制要求
// 该为单用户版本合约，若增加mapping和msg.sender可迭代为多用户版本