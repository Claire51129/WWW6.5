//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
contract SaveMyName {

    string name;//state variable ;save forever in chain
    string bio;//state variable

    //need gas to add data to chain
    function add(string memory _name,string memory _bio)public{
        name = _name;
        bio = _bio; 
        /* 这里为什么将_name和_bio赋值给name和bio？ 和全局变量类似吗
        而全局变量为链上数据吗？因此可以保存在链上？
        */
        /* 把“临时输入”写入“链上存储” --》这里谁决定 链上空间？
        比如默认全局的变量存入链上吗？还是特定的string类型呢？
        解释：因为在合约顶层声明的变量，Solidity 会自动为它们分配链上存储槽位（storage slot）
        string 只是类型，表示“存字符串”
        真正决定上链的是：声明在合约顶层 → 成为状态变量 → 有链上存储
        */
    }
    /*
     transcation gas: 交易费用69110
     execution gas: 执行费用47074
     */
    // add("Mia_Z","engineer");

    //don't need gas to retrieve data from chain
    /* 这里 public view 很奇怪 一般c函数不包含后者 直接（void），为什么？
    “被标记为 view 的函数在被调用时不会消耗 gas。”
    但是我不理解这里的语法
    */
    /*
    solidity中函数可以带修饰符，用于修饰链上状态和gas
    3种情况，public view、public pure、public
    public view：只读，不会修改状态，不会消耗gas
    public pure：只读，不会修改状态，不会消耗gas
    public：可以修改状态，会消耗gas （上面的add就是 省略相当于默认消耗gas）

    */

    function retrieve() public view returns (string memory, string memory){
        return (name, bio);
    }
    /*
     transcation gas: 交易费用0
     execution gas: 执行费用6428 gas (Cost only applies when called by a contract)
     */
    // retrieve();

    //for conbine
    /*但是感觉输入什么返回什么的无用？
    或在于上链 和 返回校验
    */
    
    /**
     transcation gas: 交易费用31592
     execution gas: 执行费用9556
     */
    function saveAndRetrieve(string memory _name, string memory _bio) public returns (string memory, string memory) {
        name = _name;
        bio = _bio;
        return (name, bio);
    }

}
/*
为什么要做contract？规则定理？还是作为函数，编译后调用？
为什么不能想c一样存在函数体，存在调用体？
规则语法，可以想象 每一份合约都是一个函数体，需要从外部调用，
而c有固定的入口，相当于main的调用在外部，终端执行该函数
因此做这样一个函数体，需要确定边界，自己的状态变量，自己的若干函数
相当于外层包装
 */
