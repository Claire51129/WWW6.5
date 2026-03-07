//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
//为什么要写一个投票站例子？？
contract PollStation{

    //------1. 数据池 做投票用

    //除了函数外 状态变量也能用public修饰
    string[] public candidateNames;
    /**
    //又是特有mapping 映射
    //特用键值对的形式存储，键是string，值是uint256
    // key: 候选人名字(string)  ->  value: 票数(uint256)
    //箭头也很奇怪，为什么不直接等于？？区分值和类型吗
    表示“键类型 => 值类型”，不是赋值
    */
    mapping(string => uint256) voteCount;

    //------2. 添加投票候选人

    function addCandidateNames(string memory _candidateNames) public{
        //新的特有push？作为给数组添加元素的方法吗 
        //push()：类似在动态数组末尾追加元素
        candidateNames.push(_candidateNames);
        //这里用到上面映射的内容？？并且还是数组符号？里面string？？完全没看懂
        //类似初始化？
        voteCount[_candidateNames] = 0;
    }

    //------3. 获取投票候选人

    //这里又是view的return 但是这次注意到了数组的参数类型传递，此处应该是给返回值存储的memory
    // view = 只读，不修改状态，类似 const 函数
    function getcandidateNames() public view returns (string[] memory){
        return candidateNames;
    }

    //------4. 投票

    //所以语法就是function 函数名(参数类型 存储  _参数名) public修饰符gas用 返回{}
    function vote(string memory _candidateNames) public{
        voteCount[_candidateNames] += 1;
    }

    //------5. 获取投票结果

    //为什么这个用类型定义返回参数，但是上面的返回名字使用memory？？
    /**
    // memory ≈ 栈/堆上的临时变量，函数结束就没了
    // storage ≈ 全局/静态变量，一直存在

    void foo(char* param) {  // param 类似 memory，临时
        static int x;        // 类似 storage，持久
    }
    类型	是否需要    memory	原因
    string、string[]、结构体等引用类型	需要	要指定存在哪（memory/storage）
    uint256、int、bool 等值类型	不需要	直接复制值，没有引用
     */
    function getVote(string memory _candidateNames) public view returns (uint256){

        return voteCount[_candidateNames];
    }

}