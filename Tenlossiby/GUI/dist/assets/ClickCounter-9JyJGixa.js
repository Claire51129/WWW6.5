import{_ as p,u as C,o as a,c as k,a as t,b as o,t as f,d as v,e as _,n as g,f as m,r as y}from"./index-BLJR1KhC.js";import{K as b,F as h}from"./FullCodeModal-CKXNbbth.js";const w={class:"day-1-content day-content"},x={class:"left-column"},B={class:"interaction-area"},F={class:"interaction-controls"},S={class:"result-display"},D={class:"result-value"},I={class:"right-column"},i=`//SPDx-License-Identifier:MIT

// 声明Solidity版本，要求编译器版本在0.8.0或更高（但低于0.9.0）
pragma solidity ^0.8.0;

// 定义一个名为clickcounter的合约（相当于其他语言中的类）
contract clickcounter{
    // 声明一个无符号256位整数类型的状态变量counter
    // public关键字表示这个变量可以被外部访问，编译器会自动生成getter函数
    uint256 public counter;

    // 定义一个名为click的公共函数
    // public表示任何人都可以调用这个函数
    function click() public {
        // 将counter的值加1（自增操作）
        counter++;
    }
}`,N={__name:"ClickCounter",setup(P){const{counter:u,clickCounter:c,resetCounter:r,unlockedConcepts:s,progressPercentage:d}=C(),l=y(!1);return(V,e)=>(a(),k("div",w,[t("div",{class:g(["content-layout",{"single-column":o(s).length===0}])},[t("div",x,[t("div",B,[e[5]||(e[5]=t("h3",null,"🎮 交互操作",-1)),t("div",F,[t("button",{class:"day-action-btn cyan",onClick:e[0]||(e[0]=(...n)=>o(c)&&o(c)(...n))}," 🖱️ 点击计数器/ClickCounter "),t("button",{class:"day-action-btn red",onClick:e[1]||(e[1]=(...n)=>o(r)&&o(r)(...n))}," 🔄 重置计数器/ResetCounter ")]),t("div",S,[e[4]||(e[4]=t("h4",null,"当前计数值：",-1)),t("div",D,f(o(u)),1)])])]),t("div",I,[o(s).length>0?(a(),v(b,{key:0,"current-day":1,"unlocked-concepts":o(s),"progress-percentage":o(d),"full-code":i,onShowFullCode:e[2]||(e[2]=n=>l.value=!0)},null,8,["unlocked-concepts","progress-percentage"])):_("",!0)])],2),m(h,{show:l.value,title:"ClickCounter 完整代码",code:i,onClose:e[3]||(e[3]=n=>l.value=!1)},null,8,["show"])]))}},$=p(N,[["__scopeId","data-v-8a741906"]]);export{$ as default};
