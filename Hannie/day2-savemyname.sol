//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract SaveMyName {
    string name;
    string bio;

    //添加更新数据
    function add(string memory _name,string memory _bio)public {
        name=_name;
        bio=_bio;
    }

    //只读函数，用来检索数据
    function retrieve()public  view  returns (string memory,string memory){
        return (name,bio);
    }

    //组合函数-保存并立即返回
    function saveAndRetrieve(string memory _name,string memory _bio)
        public 
        returns (string memory,string memory){// 第1处：返回值类型声明
            name= _name;
            bio= _bio;
            return(name,bio);// 第2处：实际返回数据的执行语句
        }
    
}