const __vite__mapDeps=(i,m=__vite__mapDeps,d=(m.f||(m.f=["./ClickCounter-9JyJGixa.js","./FullCodeModal-CKXNbbth.js","./FullCodeModal-Zn8XNxUp.css","./ClickCounter-CzObLuMm.css","./SaveMyName-BIqESgan.js","./SaveMyName-Bi1WbNe0.css","./PollStation-BisNinLf.js","./PollStation-CoGCkr8x.css","./AuctionHouse-BDAtGYUw.js","./AuctionHouse-BTdmDDb5.css","./AdminOnly-C5zWahh4.js","./AdminOnly-C6WJB3vU.css","./EtherPiggyBank-D8NFv8s2.js","./EtherPiggyBank-C8B5Rj1R.css","./SimpleIOUApp-CRgK-VGp.js","./SimpleIOUApp-Ble9e2zf.css","./TipJar-9T_O6kqq.js","./TipJar-BgtlJBrt.css","./SmartCalculator-Cg3DyfGC.js","./SmartCalculator-mJXbxSSH.css","./ActivityTracker-BizV9rH3.js","./ActivityTracker-D-MU0r6o.css","./MasterkeyContract-CkQn-8AA.js","./MasterkeyContract-DLiBvmSW.css","./ERC20Token-DWxeg8i2.js","./ERC20Token-DjGZzp0s.css","./MyToken-BgUsXMDi.js","./MyToken-C3kWlOTB.css","./SafeDeposit-B01DGgze.js","./SafeDeposit-D8FILzun.css","./GasEfficientVoting-BlBaerag.js","./GasEfficientVoting-C3nae1Wg.css","./PluginStore-DYqQQwuK.js","./PluginStore-CJU6Vt0U.css","./UpgradeHub-C_DdyWp-.js","./UpgradeHub-DaAoBRV_.css","./OracleContract-Q2WE0VuW.js","./OracleContract-DDwHPvfl.css","./SignThis-BeIFG3Lk.js","./SignThis-BYHvljOF.css","./ReentryAttack-BlkWNHdb.js","./ReentryAttack-CQITNzYE.css"])))=>i.map(i=>d[i]);
var du=Object.defineProperty;var Fo=t=>{throw TypeError(t)};var fu=(t,e,n)=>e in t?du(t,e,{enumerable:!0,configurable:!0,writable:!0,value:n}):t[e]=n;var Z=(t,e,n)=>fu(t,typeof e!="symbol"?e+"":e,n),yi=(t,e,n)=>e.has(t)||Fo("Cannot "+n);var N=(t,e,n)=>(yi(t,e,"read from private field"),n?n.call(t):e.get(t)),he=(t,e,n)=>e.has(t)?Fo("Cannot add the same private member more than once"):e instanceof WeakSet?e.add(t):e.set(t,n),oe=(t,e,n,r)=>(yi(t,e,"write to private field"),r?r.call(t,n):e.set(t,n),n),xe=(t,e,n)=>(yi(t,e,"access private method"),n);var qo=(t,e,n,r)=>({set _(s){oe(t,e,s,n)},get _(){return N(t,e,r)}});(function(){const e=document.createElement("link").relList;if(e&&e.supports&&e.supports("modulepreload"))return;for(const s of document.querySelectorAll('link[rel="modulepreload"]'))r(s);new MutationObserver(s=>{for(const i of s)if(i.type==="childList")for(const o of i.addedNodes)o.tagName==="LINK"&&o.rel==="modulepreload"&&r(o)}).observe(document,{childList:!0,subtree:!0});function n(s){const i={};return s.integrity&&(i.integrity=s.integrity),s.referrerPolicy&&(i.referrerPolicy=s.referrerPolicy),s.crossOrigin==="use-credentials"?i.credentials="include":s.crossOrigin==="anonymous"?i.credentials="omit":i.credentials="same-origin",i}function r(s){if(s.ep)return;s.ep=!0;const i=n(s);fetch(s.href,i)}})();/**
* @vue/shared v3.5.29
* (c) 2018-present Yuxi (Evan) You and Vue contributors
* @license MIT
**/function ao(t){const e=Object.create(null);for(const n of t.split(","))e[n]=1;return n=>n in e}const ye={},ur=[],Wt=()=>{},pc=()=>!1,Ks=t=>t.charCodeAt(0)===111&&t.charCodeAt(1)===110&&(t.charCodeAt(2)>122||t.charCodeAt(2)<97),co=t=>t.startsWith("onUpdate:"),Me=Object.assign,lo=(t,e)=>{const n=t.indexOf(e);n>-1&&t.splice(n,1)},pu=Object.prototype.hasOwnProperty,de=(t,e)=>pu.call(t,e),re=Array.isArray,dr=t=>is(t)==="[object Map]",js=t=>is(t)==="[object Set]",Wo=t=>is(t)==="[object Date]",ie=t=>typeof t=="function",ke=t=>typeof t=="string",Gt=t=>typeof t=="symbol",me=t=>t!==null&&typeof t=="object",gc=t=>(me(t)||ie(t))&&ie(t.then)&&ie(t.catch),mc=Object.prototype.toString,is=t=>mc.call(t),gu=t=>is(t).slice(8,-1),hc=t=>is(t)==="[object Object]",Xs=t=>ke(t)&&t!=="NaN"&&t[0]!=="-"&&""+parseInt(t,10)===t,Rr=ao(",key,ref,ref_for,ref_key,onVnodeBeforeMount,onVnodeMounted,onVnodeBeforeUpdate,onVnodeUpdated,onVnodeBeforeUnmount,onVnodeUnmounted"),Js=t=>{const e=Object.create(null);return n=>e[n]||(e[n]=t(n))},mu=/-\w/g,bt=Js(t=>t.replace(mu,e=>e.slice(1).toUpperCase())),hu=/\B([A-Z])/g,In=Js(t=>t.replace(hu,"-$1").toLowerCase()),Ys=Js(t=>t.charAt(0).toUpperCase()+t.slice(1)),bi=Js(t=>t?`on${Ys(t)}`:""),Dn=(t,e)=>!Object.is(t,e),xs=(t,...e)=>{for(let n=0;n<t.length;n++)t[n](...e)},yc=(t,e,n,r=!1)=>{Object.defineProperty(t,e,{configurable:!0,enumerable:!1,writable:r,value:n})},Zs=t=>{const e=parseFloat(t);return isNaN(e)?t:e};let zo;const Qs=()=>zo||(zo=typeof globalThis<"u"?globalThis:typeof self<"u"?self:typeof window<"u"?window:typeof global<"u"?global:{});function ei(t){if(re(t)){const e={};for(let n=0;n<t.length;n++){const r=t[n],s=ke(r)?vu(r):ei(r);if(s)for(const i in s)e[i]=s[i]}return e}else if(ke(t)||me(t))return t}const yu=/;(?![^(]*\))/g,bu=/:([^]+)/,wu=/\/\*[^]*?\*\//g;function vu(t){const e={};return t.replace(wu,"").split(yu).forEach(n=>{if(n){const r=n.split(bu);r.length>1&&(e[r[0].trim()]=r[1].trim())}}),e}function Ct(t){let e="";if(ke(t))e=t;else if(re(t))for(let n=0;n<t.length;n++){const r=Ct(t[n]);r&&(e+=r+" ")}else if(me(t))for(const n in t)t[n]&&(e+=n+" ");return e.trim()}const _u="itemscope,allowfullscreen,formnovalidate,ismap,nomodule,novalidate,readonly",xu=ao(_u);function bc(t){return!!t||t===""}function Cu(t,e){if(t.length!==e.length)return!1;let n=!0;for(let r=0;n&&r<t.length;r++)n=Zn(t[r],e[r]);return n}function Zn(t,e){if(t===e)return!0;let n=Wo(t),r=Wo(e);if(n||r)return n&&r?t.getTime()===e.getTime():!1;if(n=Gt(t),r=Gt(e),n||r)return t===e;if(n=re(t),r=re(e),n||r)return n&&r?Cu(t,e):!1;if(n=me(t),r=me(e),n||r){if(!n||!r)return!1;const s=Object.keys(t).length,i=Object.keys(e).length;if(s!==i)return!1;for(const o in t){const a=t.hasOwnProperty(o),c=e.hasOwnProperty(o);if(a&&!c||!a&&c||!Zn(t[o],e[o]))return!1}}return String(t)===String(e)}function Su(t,e){return t.findIndex(n=>Zn(n,e))}const wc=t=>!!(t&&t.__v_isRef===!0),Te=t=>ke(t)?t:t==null?"":re(t)||me(t)&&(t.toString===mc||!ie(t.toString))?wc(t)?Te(t.value):JSON.stringify(t,vc,2):String(t),vc=(t,e)=>wc(e)?vc(t,e.value):dr(e)?{[`Map(${e.size})`]:[...e.entries()].reduce((n,[r,s],i)=>(n[wi(r,i)+" =>"]=s,n),{})}:js(e)?{[`Set(${e.size})`]:[...e.values()].map(n=>wi(n))}:Gt(e)?wi(e):me(e)&&!re(e)&&!hc(e)?String(e):e,wi=(t,e="")=>{var n;return Gt(t)?`Symbol(${(n=t.description)!=null?n:e})`:t};/**
* @vue/reactivity v3.5.29
* (c) 2018-present Yuxi (Evan) You and Vue contributors
* @license MIT
**/let Fe;class _c{constructor(e=!1){this.detached=e,this._active=!0,this._on=0,this.effects=[],this.cleanups=[],this._isPaused=!1,this.__v_skip=!0,this.parent=Fe,!e&&Fe&&(this.index=(Fe.scopes||(Fe.scopes=[])).push(this)-1)}get active(){return this._active}pause(){if(this._active){this._isPaused=!0;let e,n;if(this.scopes)for(e=0,n=this.scopes.length;e<n;e++)this.scopes[e].pause();for(e=0,n=this.effects.length;e<n;e++)this.effects[e].pause()}}resume(){if(this._active&&this._isPaused){this._isPaused=!1;let e,n;if(this.scopes)for(e=0,n=this.scopes.length;e<n;e++)this.scopes[e].resume();for(e=0,n=this.effects.length;e<n;e++)this.effects[e].resume()}}run(e){if(this._active){const n=Fe;try{return Fe=this,e()}finally{Fe=n}}}on(){++this._on===1&&(this.prevScope=Fe,Fe=this)}off(){this._on>0&&--this._on===0&&(Fe=this.prevScope,this.prevScope=void 0)}stop(e){if(this._active){this._active=!1;let n,r;for(n=0,r=this.effects.length;n<r;n++)this.effects[n].stop();for(this.effects.length=0,n=0,r=this.cleanups.length;n<r;n++)this.cleanups[n]();if(this.cleanups.length=0,this.scopes){for(n=0,r=this.scopes.length;n<r;n++)this.scopes[n].stop(!0);this.scopes.length=0}if(!this.detached&&this.parent&&!e){const s=this.parent.scopes.pop();s&&s!==this&&(this.parent.scopes[this.index]=s,s.index=this.index)}this.parent=void 0}}}function xc(t){return new _c(t)}function Cc(){return Fe}function Eu(t,e=!1){Fe&&Fe.cleanups.push(t)}let we;const vi=new WeakSet;class Sc{constructor(e){this.fn=e,this.deps=void 0,this.depsTail=void 0,this.flags=5,this.next=void 0,this.cleanup=void 0,this.scheduler=void 0,Fe&&Fe.active&&Fe.effects.push(this)}pause(){this.flags|=64}resume(){this.flags&64&&(this.flags&=-65,vi.has(this)&&(vi.delete(this),this.trigger()))}notify(){this.flags&2&&!(this.flags&32)||this.flags&8||kc(this)}run(){if(!(this.flags&1))return this.fn();this.flags|=2,Go(this),Ac(this);const e=we,n=St;we=this,St=!0;try{return this.fn()}finally{Tc(this),we=e,St=n,this.flags&=-3}}stop(){if(this.flags&1){for(let e=this.deps;e;e=e.nextDep)po(e);this.deps=this.depsTail=void 0,Go(this),this.onStop&&this.onStop(),this.flags&=-2}}trigger(){this.flags&64?vi.add(this):this.scheduler?this.scheduler():this.runIfDirty()}runIfDirty(){$i(this)&&this.run()}get dirty(){return $i(this)}}let Ec=0,Nr,Mr;function kc(t,e=!1){if(t.flags|=8,e){t.next=Mr,Mr=t;return}t.next=Nr,Nr=t}function uo(){Ec++}function fo(){if(--Ec>0)return;if(Mr){let e=Mr;for(Mr=void 0;e;){const n=e.next;e.next=void 0,e.flags&=-9,e=n}}let t;for(;Nr;){let e=Nr;for(Nr=void 0;e;){const n=e.next;if(e.next=void 0,e.flags&=-9,e.flags&1)try{e.trigger()}catch(r){t||(t=r)}e=n}}if(t)throw t}function Ac(t){for(let e=t.deps;e;e=e.nextDep)e.version=-1,e.prevActiveLink=e.dep.activeLink,e.dep.activeLink=e}function Tc(t){let e,n=t.depsTail,r=n;for(;r;){const s=r.prevDep;r.version===-1?(r===n&&(n=s),po(r),ku(r)):e=r,r.dep.activeLink=r.prevActiveLink,r.prevActiveLink=void 0,r=s}t.deps=e,t.depsTail=n}function $i(t){for(let e=t.deps;e;e=e.nextDep)if(e.dep.version!==e.version||e.dep.computed&&(Dc(e.dep.computed)||e.dep.version!==e.version))return!0;return!!t._dirty}function Dc(t){if(t.flags&4&&!(t.flags&16)||(t.flags&=-17,t.globalVersion===jr)||(t.globalVersion=jr,!t.isSSR&&t.flags&128&&(!t.deps&&!t._dirty||!$i(t))))return;t.flags|=2;const e=t.dep,n=we,r=St;we=t,St=!0;try{Ac(t);const s=t.fn(t._value);(e.version===0||Dn(s,t._value))&&(t.flags|=128,t._value=s,e.version++)}catch(s){throw e.version++,s}finally{we=n,St=r,Tc(t),t.flags&=-3}}function po(t,e=!1){const{dep:n,prevSub:r,nextSub:s}=t;if(r&&(r.nextSub=s,t.prevSub=void 0),s&&(s.prevSub=r,t.nextSub=void 0),n.subs===t&&(n.subs=r,!r&&n.computed)){n.computed.flags&=-5;for(let i=n.computed.deps;i;i=i.nextDep)po(i,!0)}!e&&!--n.sc&&n.map&&n.map.delete(n.key)}function ku(t){const{prevDep:e,nextDep:n}=t;e&&(e.nextDep=n,t.prevDep=void 0),n&&(n.prevDep=e,t.nextDep=void 0)}let St=!0;const Bc=[];function fn(){Bc.push(St),St=!1}function pn(){const t=Bc.pop();St=t===void 0?!0:t}function Go(t){const{cleanup:e}=t;if(t.cleanup=void 0,e){const n=we;we=void 0;try{e()}finally{we=n}}}let jr=0;class Au{constructor(e,n){this.sub=e,this.dep=n,this.version=n.version,this.nextDep=this.prevDep=this.nextSub=this.prevSub=this.prevActiveLink=void 0}}class go{constructor(e){this.computed=e,this.version=0,this.activeLink=void 0,this.subs=void 0,this.map=void 0,this.key=void 0,this.sc=0,this.__v_skip=!0}track(e){if(!we||!St||we===this.computed)return;let n=this.activeLink;if(n===void 0||n.sub!==we)n=this.activeLink=new Au(we,this),we.deps?(n.prevDep=we.depsTail,we.depsTail.nextDep=n,we.depsTail=n):we.deps=we.depsTail=n,Ic(n);else if(n.version===-1&&(n.version=this.version,n.nextDep)){const r=n.nextDep;r.prevDep=n.prevDep,n.prevDep&&(n.prevDep.nextDep=r),n.prevDep=we.depsTail,n.nextDep=void 0,we.depsTail.nextDep=n,we.depsTail=n,we.deps===n&&(we.deps=r)}return n}trigger(e){this.version++,jr++,this.notify(e)}notify(e){uo();try{for(let n=this.subs;n;n=n.prevSub)n.sub.notify()&&n.sub.dep.notify()}finally{fo()}}}function Ic(t){if(t.dep.sc++,t.sub.flags&4){const e=t.dep.computed;if(e&&!t.dep.subs){e.flags|=20;for(let r=e.deps;r;r=r.nextDep)Ic(r)}const n=t.dep.subs;n!==t&&(t.prevSub=n,n&&(n.nextSub=t)),t.dep.subs=t}}const Ps=new WeakMap,jn=Symbol(""),Li=Symbol(""),Xr=Symbol("");function qe(t,e,n){if(St&&we){let r=Ps.get(t);r||Ps.set(t,r=new Map);let s=r.get(n);s||(r.set(n,s=new go),s.map=r,s.key=n),s.track()}}function rn(t,e,n,r,s,i){const o=Ps.get(t);if(!o){jr++;return}const a=c=>{c&&c.trigger()};if(uo(),e==="clear")o.forEach(a);else{const c=re(t),l=c&&Xs(n);if(c&&n==="length"){const u=Number(r);o.forEach((d,w)=>{(w==="length"||w===Xr||!Gt(w)&&w>=u)&&a(d)})}else switch((n!==void 0||o.has(void 0))&&a(o.get(n)),l&&a(o.get(Xr)),e){case"add":c?l&&a(o.get("length")):(a(o.get(jn)),dr(t)&&a(o.get(Li)));break;case"delete":c||(a(o.get(jn)),dr(t)&&a(o.get(Li)));break;case"set":dr(t)&&a(o.get(jn));break}}fo()}function Tu(t,e){const n=Ps.get(t);return n&&n.get(e)}function nr(t){const e=ue(t);return e===t?e:(qe(e,"iterate",Xr),dt(t)?e:e.map(kt))}function ti(t){return qe(t=ue(t),"iterate",Xr),t}function Cn(t,e){return gn(t)?br(cn(t)?kt(e):e):kt(e)}const Du={__proto__:null,[Symbol.iterator](){return _i(this,Symbol.iterator,t=>Cn(this,t))},concat(...t){return nr(this).concat(...t.map(e=>re(e)?nr(e):e))},entries(){return _i(this,"entries",t=>(t[1]=Cn(this,t[1]),t))},every(t,e){return Xt(this,"every",t,e,void 0,arguments)},filter(t,e){return Xt(this,"filter",t,e,n=>n.map(r=>Cn(this,r)),arguments)},find(t,e){return Xt(this,"find",t,e,n=>Cn(this,n),arguments)},findIndex(t,e){return Xt(this,"findIndex",t,e,void 0,arguments)},findLast(t,e){return Xt(this,"findLast",t,e,n=>Cn(this,n),arguments)},findLastIndex(t,e){return Xt(this,"findLastIndex",t,e,void 0,arguments)},forEach(t,e){return Xt(this,"forEach",t,e,void 0,arguments)},includes(...t){return xi(this,"includes",t)},indexOf(...t){return xi(this,"indexOf",t)},join(t){return nr(this).join(t)},lastIndexOf(...t){return xi(this,"lastIndexOf",t)},map(t,e){return Xt(this,"map",t,e,void 0,arguments)},pop(){return Br(this,"pop")},push(...t){return Br(this,"push",t)},reduce(t,...e){return Ko(this,"reduce",t,e)},reduceRight(t,...e){return Ko(this,"reduceRight",t,e)},shift(){return Br(this,"shift")},some(t,e){return Xt(this,"some",t,e,void 0,arguments)},splice(...t){return Br(this,"splice",t)},toReversed(){return nr(this).toReversed()},toSorted(t){return nr(this).toSorted(t)},toSpliced(...t){return nr(this).toSpliced(...t)},unshift(...t){return Br(this,"unshift",t)},values(){return _i(this,"values",t=>Cn(this,t))}};function _i(t,e,n){const r=ti(t),s=r[e]();return r!==t&&!dt(t)&&(s._next=s.next,s.next=()=>{const i=s._next();return i.done||(i.value=n(i.value)),i}),s}const Bu=Array.prototype;function Xt(t,e,n,r,s,i){const o=ti(t),a=o!==t&&!dt(t),c=o[e];if(c!==Bu[e]){const d=c.apply(t,i);return a?kt(d):d}let l=n;o!==t&&(a?l=function(d,w){return n.call(this,Cn(t,d),w,t)}:n.length>2&&(l=function(d,w){return n.call(this,d,w,t)}));const u=c.call(o,l,r);return a&&s?s(u):u}function Ko(t,e,n,r){const s=ti(t);let i=n;return s!==t&&(dt(t)?n.length>3&&(i=function(o,a,c){return n.call(this,o,a,c,t)}):i=function(o,a,c){return n.call(this,o,Cn(t,a),c,t)}),s[e](i,...r)}function xi(t,e,n){const r=ue(t);qe(r,"iterate",Xr);const s=r[e](...n);return(s===-1||s===!1)&&ri(n[0])?(n[0]=ue(n[0]),r[e](...n)):s}function Br(t,e,n=[]){fn(),uo();const r=ue(t)[e].apply(t,n);return fo(),pn(),r}const Iu=ao("__proto__,__v_isRef,__isVue"),Oc=new Set(Object.getOwnPropertyNames(Symbol).filter(t=>t!=="arguments"&&t!=="caller").map(t=>Symbol[t]).filter(Gt));function Ou(t){Gt(t)||(t=String(t));const e=ue(this);return qe(e,"has",t),e.hasOwnProperty(t)}class Pc{constructor(e=!1,n=!1){this._isReadonly=e,this._isShallow=n}get(e,n,r){if(n==="__v_skip")return e.__v_skip;const s=this._isReadonly,i=this._isShallow;if(n==="__v_isReactive")return!s;if(n==="__v_isReadonly")return s;if(n==="__v_isShallow")return i;if(n==="__v_raw")return r===(s?i?Fu:Nc:i?Rc:Lc).get(e)||Object.getPrototypeOf(e)===Object.getPrototypeOf(r)?e:void 0;const o=re(e);if(!s){let c;if(o&&(c=Du[n]))return c;if(n==="hasOwnProperty")return Ou}const a=Reflect.get(e,n,Ee(e)?e:r);if((Gt(n)?Oc.has(n):Iu(n))||(s||qe(e,"get",n),i))return a;if(Ee(a)){const c=o&&Xs(n)?a:a.value;return s&&me(c)?Ni(c):c}return me(a)?s?Ni(a):ni(a):a}}class $c extends Pc{constructor(e=!1){super(!1,e)}set(e,n,r,s){let i=e[n];const o=re(e)&&Xs(n);if(!this._isShallow){const l=gn(i);if(!dt(r)&&!gn(r)&&(i=ue(i),r=ue(r)),!o&&Ee(i)&&!Ee(r))return l||(i.value=r),!0}const a=o?Number(n)<e.length:de(e,n),c=Reflect.set(e,n,r,Ee(e)?e:s);return e===ue(s)&&(a?Dn(r,i)&&rn(e,"set",n,r):rn(e,"add",n,r)),c}deleteProperty(e,n){const r=de(e,n);e[n];const s=Reflect.deleteProperty(e,n);return s&&r&&rn(e,"delete",n,void 0),s}has(e,n){const r=Reflect.has(e,n);return(!Gt(n)||!Oc.has(n))&&qe(e,"has",n),r}ownKeys(e){return qe(e,"iterate",re(e)?"length":jn),Reflect.ownKeys(e)}}class Pu extends Pc{constructor(e=!1){super(!0,e)}set(e,n){return!0}deleteProperty(e,n){return!0}}const $u=new $c,Lu=new Pu,Ru=new $c(!0);const Ri=t=>t,fs=t=>Reflect.getPrototypeOf(t);function Nu(t,e,n){return function(...r){const s=this.__v_raw,i=ue(s),o=dr(i),a=t==="entries"||t===Symbol.iterator&&o,c=t==="keys"&&o,l=s[t](...r),u=n?Ri:e?br:kt;return!e&&qe(i,"iterate",c?Li:jn),Me(Object.create(l),{next(){const{value:d,done:w}=l.next();return w?{value:d,done:w}:{value:a?[u(d[0]),u(d[1])]:u(d),done:w}}})}}function ps(t){return function(...e){return t==="delete"?!1:t==="clear"?void 0:this}}function Mu(t,e){const n={get(s){const i=this.__v_raw,o=ue(i),a=ue(s);t||(Dn(s,a)&&qe(o,"get",s),qe(o,"get",a));const{has:c}=fs(o),l=e?Ri:t?br:kt;if(c.call(o,s))return l(i.get(s));if(c.call(o,a))return l(i.get(a));i!==o&&i.get(s)},get size(){const s=this.__v_raw;return!t&&qe(ue(s),"iterate",jn),s.size},has(s){const i=this.__v_raw,o=ue(i),a=ue(s);return t||(Dn(s,a)&&qe(o,"has",s),qe(o,"has",a)),s===a?i.has(s):i.has(s)||i.has(a)},forEach(s,i){const o=this,a=o.__v_raw,c=ue(a),l=e?Ri:t?br:kt;return!t&&qe(c,"iterate",jn),a.forEach((u,d)=>s.call(i,l(u),l(d),o))}};return Me(n,t?{add:ps("add"),set:ps("set"),delete:ps("delete"),clear:ps("clear")}:{add(s){!e&&!dt(s)&&!gn(s)&&(s=ue(s));const i=ue(this);return fs(i).has.call(i,s)||(i.add(s),rn(i,"add",s,s)),this},set(s,i){!e&&!dt(i)&&!gn(i)&&(i=ue(i));const o=ue(this),{has:a,get:c}=fs(o);let l=a.call(o,s);l||(s=ue(s),l=a.call(o,s));const u=c.call(o,s);return o.set(s,i),l?Dn(i,u)&&rn(o,"set",s,i):rn(o,"add",s,i),this},delete(s){const i=ue(this),{has:o,get:a}=fs(i);let c=o.call(i,s);c||(s=ue(s),c=o.call(i,s)),a&&a.call(i,s);const l=i.delete(s);return c&&rn(i,"delete",s,void 0),l},clear(){const s=ue(this),i=s.size!==0,o=s.clear();return i&&rn(s,"clear",void 0,void 0),o}}),["keys","values","entries",Symbol.iterator].forEach(s=>{n[s]=Nu(s,t,e)}),n}function mo(t,e){const n=Mu(t,e);return(r,s,i)=>s==="__v_isReactive"?!t:s==="__v_isReadonly"?t:s==="__v_raw"?r:Reflect.get(de(n,s)&&s in r?n:r,s,i)}const Uu={get:mo(!1,!1)},Hu={get:mo(!1,!0)},Vu={get:mo(!0,!1)};const Lc=new WeakMap,Rc=new WeakMap,Nc=new WeakMap,Fu=new WeakMap;function qu(t){switch(t){case"Object":case"Array":return 1;case"Map":case"Set":case"WeakMap":case"WeakSet":return 2;default:return 0}}function Wu(t){return t.__v_skip||!Object.isExtensible(t)?0:qu(gu(t))}function ni(t){return gn(t)?t:ho(t,!1,$u,Uu,Lc)}function zu(t){return ho(t,!1,Ru,Hu,Rc)}function Ni(t){return ho(t,!0,Lu,Vu,Nc)}function ho(t,e,n,r,s){if(!me(t)||t.__v_raw&&!(e&&t.__v_isReactive))return t;const i=Wu(t);if(i===0)return t;const o=s.get(t);if(o)return o;const a=new Proxy(t,i===2?r:n);return s.set(t,a),a}function cn(t){return gn(t)?cn(t.__v_raw):!!(t&&t.__v_isReactive)}function gn(t){return!!(t&&t.__v_isReadonly)}function dt(t){return!!(t&&t.__v_isShallow)}function ri(t){return t?!!t.__v_raw:!1}function ue(t){const e=t&&t.__v_raw;return e?ue(e):t}function yo(t){return!de(t,"__v_skip")&&Object.isExtensible(t)&&yc(t,"__v_skip",!0),t}const kt=t=>me(t)?ni(t):t,br=t=>me(t)?Ni(t):t;function Ee(t){return t?t.__v_isRef===!0:!1}function F(t){return Gu(t,!1)}function Gu(t,e){return Ee(t)?t:new Ku(t,e)}class Ku{constructor(e,n){this.dep=new go,this.__v_isRef=!0,this.__v_isShallow=!1,this._rawValue=n?e:ue(e),this._value=n?e:kt(e),this.__v_isShallow=n}get value(){return this.dep.track(),this._value}set value(e){const n=this._rawValue,r=this.__v_isShallow||dt(e)||gn(e);e=r?e:ue(e),Dn(e,n)&&(this._rawValue=e,this._value=r?e:kt(e),this.dep.trigger())}}function Jr(t){return Ee(t)?t.value:t}const ju={get:(t,e,n)=>e==="__v_raw"?t:Jr(Reflect.get(t,e,n)),set:(t,e,n,r)=>{const s=t[e];return Ee(s)&&!Ee(n)?(s.value=n,!0):Reflect.set(t,e,n,r)}};function Mc(t){return cn(t)?t:new Proxy(t,ju)}function Xu(t){const e=re(t)?new Array(t.length):{};for(const n in t)e[n]=Yu(t,n);return e}class Ju{constructor(e,n,r){this._object=e,this._key=n,this._defaultValue=r,this.__v_isRef=!0,this._value=void 0,this._raw=ue(e);let s=!0,i=e;if(!re(e)||!Xs(String(n)))do s=!ri(i)||dt(i);while(s&&(i=i.__v_raw));this._shallow=s}get value(){let e=this._object[this._key];return this._shallow&&(e=Jr(e)),this._value=e===void 0?this._defaultValue:e}set value(e){if(this._shallow&&Ee(this._raw[this._key])){const n=this._object[this._key];if(Ee(n)){n.value=e;return}}this._object[this._key]=e}get dep(){return Tu(this._raw,this._key)}}function Yu(t,e,n){return new Ju(t,e,n)}class Zu{constructor(e,n,r){this.fn=e,this.setter=n,this._value=void 0,this.dep=new go(this),this.__v_isRef=!0,this.deps=void 0,this.depsTail=void 0,this.flags=16,this.globalVersion=jr-1,this.next=void 0,this.effect=this,this.__v_isReadonly=!n,this.isSSR=r}notify(){if(this.flags|=16,!(this.flags&8)&&we!==this)return kc(this,!0),!0}get value(){const e=this.dep.track();return Dc(this),e&&(e.version=this.dep.version),this._value}set value(e){this.setter&&this.setter(e)}}function Qu(t,e,n=!1){let r,s;return ie(t)?r=t:(r=t.get,s=t.set),new Zu(r,s,n)}const gs={},$s=new WeakMap;let Nn;function ed(t,e=!1,n=Nn){if(n){let r=$s.get(n);r||$s.set(n,r=[]),r.push(t)}}function td(t,e,n=ye){const{immediate:r,deep:s,once:i,scheduler:o,augmentJob:a,call:c}=n,l=f=>s?f:dt(f)||s===!1||s===0?sn(f,1):sn(f);let u,d,w,m,S=!1,h=!1;if(Ee(t)?(d=()=>t.value,S=dt(t)):cn(t)?(d=()=>l(t),S=!0):re(t)?(h=!0,S=t.some(f=>cn(f)||dt(f)),d=()=>t.map(f=>{if(Ee(f))return f.value;if(cn(f))return l(f);if(ie(f))return c?c(f,2):f()})):ie(t)?e?d=c?()=>c(t,2):t:d=()=>{if(w){fn();try{w()}finally{pn()}}const f=Nn;Nn=u;try{return c?c(t,3,[m]):t(m)}finally{Nn=f}}:d=Wt,e&&s){const f=d,p=s===!0?1/0:s;d=()=>sn(f(),p)}const D=Cc(),I=()=>{u.stop(),D&&D.active&&lo(D.effects,u)};if(i&&e){const f=e;e=(...p)=>{f(...p),I()}}let b=h?new Array(t.length).fill(gs):gs;const C=f=>{if(!(!(u.flags&1)||!u.dirty&&!f))if(e){const p=u.run();if(s||S||(h?p.some((v,k)=>Dn(v,b[k])):Dn(p,b))){w&&w();const v=Nn;Nn=u;try{const k=[p,b===gs?void 0:h&&b[0]===gs?[]:b,m];b=p,c?c(e,3,k):e(...k)}finally{Nn=v}}}else u.run()};return a&&a(C),u=new Sc(d),u.scheduler=o?()=>o(C,!1):C,m=f=>ed(f,!1,u),w=u.onStop=()=>{const f=$s.get(u);if(f){if(c)c(f,4);else for(const p of f)p();$s.delete(u)}},e?r?C(!0):b=u.run():o?o(C.bind(null,!0),!0):u.run(),I.pause=u.pause.bind(u),I.resume=u.resume.bind(u),I.stop=I,I}function sn(t,e=1/0,n){if(e<=0||!me(t)||t.__v_skip||(n=n||new Map,(n.get(t)||0)>=e))return t;if(n.set(t,e),e--,Ee(t))sn(t.value,e,n);else if(re(t))for(let r=0;r<t.length;r++)sn(t[r],e,n);else if(js(t)||dr(t))t.forEach(r=>{sn(r,e,n)});else if(hc(t)){for(const r in t)sn(t[r],e,n);for(const r of Object.getOwnPropertySymbols(t))Object.prototype.propertyIsEnumerable.call(t,r)&&sn(t[r],e,n)}return t}/**
* @vue/runtime-core v3.5.29
* (c) 2018-present Yuxi (Evan) You and Vue contributors
* @license MIT
**/function os(t,e,n,r){try{return r?t(...r):t()}catch(s){as(s,e,n)}}function Kt(t,e,n,r){if(ie(t)){const s=os(t,e,n,r);return s&&gc(s)&&s.catch(i=>{as(i,e,n)}),s}if(re(t)){const s=[];for(let i=0;i<t.length;i++)s.push(Kt(t[i],e,n,r));return s}}function as(t,e,n,r=!0){const s=e?e.vnode:null,{errorHandler:i,throwUnhandledErrorInProduction:o}=e&&e.appContext.config||ye;if(e){let a=e.parent;const c=e.proxy,l=`https://vuejs.org/error-reference/#runtime-${n}`;for(;a;){const u=a.ec;if(u){for(let d=0;d<u.length;d++)if(u[d](t,c,l)===!1)return}a=a.parent}if(i){fn(),os(i,null,10,[t,c,l]),pn();return}}nd(t,n,s,r,o)}function nd(t,e,n,r=!0,s=!1){if(s)throw t;console.error(t)}const Ke=[];let Lt=-1;const fr=[];let Sn=null,ir=0;const Uc=Promise.resolve();let Ls=null;function bo(t){const e=Ls||Uc;return t?e.then(this?t.bind(this):t):e}function rd(t){let e=Lt+1,n=Ke.length;for(;e<n;){const r=e+n>>>1,s=Ke[r],i=Yr(s);i<t||i===t&&s.flags&2?e=r+1:n=r}return e}function wo(t){if(!(t.flags&1)){const e=Yr(t),n=Ke[Ke.length-1];!n||!(t.flags&2)&&e>=Yr(n)?Ke.push(t):Ke.splice(rd(e),0,t),t.flags|=1,Hc()}}function Hc(){Ls||(Ls=Uc.then(Fc))}function sd(t){re(t)?fr.push(...t):Sn&&t.id===-1?Sn.splice(ir+1,0,t):t.flags&1||(fr.push(t),t.flags|=1),Hc()}function jo(t,e,n=Lt+1){for(;n<Ke.length;n++){const r=Ke[n];if(r&&r.flags&2){if(t&&r.id!==t.uid)continue;Ke.splice(n,1),n--,r.flags&4&&(r.flags&=-2),r(),r.flags&4||(r.flags&=-2)}}}function Vc(t){if(fr.length){const e=[...new Set(fr)].sort((n,r)=>Yr(n)-Yr(r));if(fr.length=0,Sn){Sn.push(...e);return}for(Sn=e,ir=0;ir<Sn.length;ir++){const n=Sn[ir];n.flags&4&&(n.flags&=-2),n.flags&8||n(),n.flags&=-2}Sn=null,ir=0}}const Yr=t=>t.id==null?t.flags&2?-1:1/0:t.id;function Fc(t){try{for(Lt=0;Lt<Ke.length;Lt++){const e=Ke[Lt];e&&!(e.flags&8)&&(e.flags&4&&(e.flags&=-2),os(e,e.i,e.i?15:14),e.flags&4||(e.flags&=-2))}}finally{for(;Lt<Ke.length;Lt++){const e=Ke[Lt];e&&(e.flags&=-2)}Lt=-1,Ke.length=0,Vc(),Ls=null,(Ke.length||fr.length)&&Fc()}}let lt=null,qc=null;function Rs(t){const e=lt;return lt=t,qc=t&&t.type.__scopeId||null,e}function id(t,e=lt,n){if(!e||t._n)return t;const r=(...s)=>{r._d&&ua(-1);const i=Rs(e);let o;try{o=t(...s)}finally{Rs(i),r._d&&ua(1)}return o};return r._n=!0,r._c=!0,r._d=!0,r}function Nh(t,e){if(lt===null)return t;const n=ai(lt),r=t.dirs||(t.dirs=[]);for(let s=0;s<e.length;s++){let[i,o,a,c=ye]=e[s];i&&(ie(i)&&(i={mounted:i,updated:i}),i.deep&&sn(o),r.push({dir:i,instance:n,value:o,oldValue:void 0,arg:a,modifiers:c}))}return t}function $n(t,e,n,r){const s=t.dirs,i=e&&e.dirs;for(let o=0;o<s.length;o++){const a=s[o];i&&(a.oldValue=i[o].value);let c=a.dir[r];c&&(fn(),Kt(c,n,8,[t.el,a,t,e]),pn())}}function od(t,e){if(Le){let n=Le.provides;const r=Le.parent&&Le.parent.provides;r===n&&(n=Le.provides=Object.create(r)),n[t]=e}}function Ur(t,e,n=!1){const r=hl();if(r||Xn){let s=Xn?Xn._context.provides:r?r.parent==null||r.ce?r.vnode.appContext&&r.vnode.appContext.provides:r.parent.provides:void 0;if(s&&t in s)return s[t];if(arguments.length>1)return n&&ie(e)?e.call(r&&r.proxy):e}}function ad(){return!!(hl()||Xn)}const cd=Symbol.for("v-scx"),ld=()=>Ur(cd);function Cs(t,e,n){return Wc(t,e,n)}function Wc(t,e,n=ye){const{immediate:r,deep:s,flush:i,once:o}=n,a=Me({},n),c=e&&r||!e&&i!=="post";let l;if(vr){if(i==="sync"){const m=ld();l=m.__watcherHandles||(m.__watcherHandles=[])}else if(!c){const m=()=>{};return m.stop=Wt,m.resume=Wt,m.pause=Wt,m}}const u=Le;a.call=(m,S,h)=>Kt(m,u,S,h);let d=!1;i==="post"?a.scheduler=m=>{Ve(m,u&&u.suspense)}:i!=="sync"&&(d=!0,a.scheduler=(m,S)=>{S?m():wo(m)}),a.augmentJob=m=>{e&&(m.flags|=4),d&&(m.flags|=2,u&&(m.id=u.uid,m.i=u))};const w=td(t,e,a);return vr&&(l?l.push(w):c&&w()),w}function ud(t,e,n){const r=this.proxy,s=ke(t)?t.includes(".")?zc(r,t):()=>r[t]:t.bind(r,r);let i;ie(e)?i=e:(i=e.handler,n=e);const o=cs(this),a=Wc(s,i.bind(r),n);return o(),a}function zc(t,e){const n=e.split(".");return()=>{let r=t;for(let s=0;s<n.length&&r;s++)r=r[n[s]];return r}}const Gc=Symbol("_vte"),dd=t=>t.__isTeleport,Hr=t=>t&&(t.disabled||t.disabled===""),Xo=t=>t&&(t.defer||t.defer===""),Jo=t=>typeof SVGElement<"u"&&t instanceof SVGElement,Yo=t=>typeof MathMLElement=="function"&&t instanceof MathMLElement,Mi=(t,e)=>{const n=t&&t.to;return ke(n)?e?e(n):null:n},Kc={name:"Teleport",__isTeleport:!0,process(t,e,n,r,s,i,o,a,c,l){const{mc:u,pc:d,pbc:w,o:{insert:m,querySelector:S,createText:h,createComment:D}}=l,I=Hr(e.props);let{shapeFlag:b,children:C,dynamicChildren:f}=e;if(t==null){const p=e.el=h(""),v=e.anchor=h("");m(p,n,r),m(v,n,r);const k=(g,T)=>{b&16&&u(C,g,T,s,i,o,a,c)},x=()=>{const g=e.target=Mi(e.props,S),T=Ui(g,e,h,m);g&&(o!=="svg"&&Jo(g)?o="svg":o!=="mathml"&&Yo(g)&&(o="mathml"),s&&s.isCE&&(s.ce._teleportTargets||(s.ce._teleportTargets=new Set)).add(g),I||(k(g,T),Ss(e,!1)))};I&&(k(n,v),Ss(e,!0)),Xo(e.props)?(e.el.__isMounted=!1,Ve(()=>{x(),delete e.el.__isMounted},i)):x()}else{if(Xo(e.props)&&t.el.__isMounted===!1){Ve(()=>{Kc.process(t,e,n,r,s,i,o,a,c,l)},i);return}e.el=t.el,e.targetStart=t.targetStart;const p=e.anchor=t.anchor,v=e.target=t.target,k=e.targetAnchor=t.targetAnchor,x=Hr(t.props),g=x?n:v,T=x?p:k;if(o==="svg"||Jo(v)?o="svg":(o==="mathml"||Yo(v))&&(o="mathml"),f?(w(t.dynamicChildren,f,g,s,i,o,a),Ao(t,e,!0)):c||d(t,e,g,T,s,i,o,a,!1),I)x?e.props&&t.props&&e.props.to!==t.props.to&&(e.props.to=t.props.to):ms(e,n,p,l,1);else if((e.props&&e.props.to)!==(t.props&&t.props.to)){const A=e.target=Mi(e.props,S);A&&ms(e,A,null,l,0)}else x&&ms(e,v,k,l,1);Ss(e,I)}},remove(t,e,n,{um:r,o:{remove:s}},i){const{shapeFlag:o,children:a,anchor:c,targetStart:l,targetAnchor:u,target:d,props:w}=t;if(d&&(s(l),s(u)),i&&s(c),o&16){const m=i||!Hr(w);for(let S=0;S<a.length;S++){const h=a[S];r(h,e,n,m,!!h.dynamicChildren)}}},move:ms,hydrate:fd};function ms(t,e,n,{o:{insert:r},m:s},i=2){i===0&&r(t.targetAnchor,e,n);const{el:o,anchor:a,shapeFlag:c,children:l,props:u}=t,d=i===2;if(d&&r(o,e,n),(!d||Hr(u))&&c&16)for(let w=0;w<l.length;w++)s(l[w],e,n,2);d&&r(a,e,n)}function fd(t,e,n,r,s,i,{o:{nextSibling:o,parentNode:a,querySelector:c,insert:l,createText:u}},d){function w(D,I){let b=I;for(;b;){if(b&&b.nodeType===8){if(b.data==="teleport start anchor")e.targetStart=b;else if(b.data==="teleport anchor"){e.targetAnchor=b,D._lpa=e.targetAnchor&&o(e.targetAnchor);break}}b=o(b)}}function m(D,I){I.anchor=d(o(D),I,a(D),n,r,s,i)}const S=e.target=Mi(e.props,c),h=Hr(e.props);if(S){const D=S._lpa||S.firstChild;e.shapeFlag&16&&(h?(m(t,e),w(S,D),e.targetAnchor||Ui(S,e,u,l,a(t)===S?t:null)):(e.anchor=o(t),w(S,D),e.targetAnchor||Ui(S,e,u,l),d(D&&o(D),e,S,n,r,s,i))),Ss(e,h)}else h&&e.shapeFlag&16&&(m(t,e),e.targetStart=t,e.targetAnchor=o(t));return e.anchor&&o(e.anchor)}const Mh=Kc;function Ss(t,e){const n=t.ctx;if(n&&n.ut){let r,s;for(e?(r=t.el,s=t.anchor):(r=t.targetStart,s=t.targetAnchor);r&&r!==s;)r.nodeType===1&&r.setAttribute("data-v-owner",n.uid),r=r.nextSibling;n.ut()}}function Ui(t,e,n,r,s=null){const i=e.targetStart=n(""),o=e.targetAnchor=n("");return i[Gc]=o,t&&(r(i,t,s),r(o,t,s)),o}const pd=Symbol("_leaveCb");function vo(t,e){t.shapeFlag&6&&t.component?(t.transition=e,vo(t.component.subTree,e)):t.shapeFlag&128?(t.ssContent.transition=e.clone(t.ssContent),t.ssFallback.transition=e.clone(t.ssFallback)):t.transition=e}function gd(t,e){return ie(t)?Me({name:t.name},e,{setup:t}):t}function _o(t){t.ids=[t.ids[0]+t.ids[2]+++"-",0,0]}function Zo(t,e){let n;return!!((n=Object.getOwnPropertyDescriptor(t,e))&&!n.configurable)}const Ns=new WeakMap;function Vr(t,e,n,r,s=!1){if(re(t)){t.forEach((h,D)=>Vr(h,e&&(re(e)?e[D]:e),n,r,s));return}if(Fr(r)&&!s){r.shapeFlag&512&&r.type.__asyncResolved&&r.component.subTree.component&&Vr(t,e,n,r.component.subTree);return}const i=r.shapeFlag&4?ai(r.component):r.el,o=s?null:i,{i:a,r:c}=t,l=e&&e.r,u=a.refs===ye?a.refs={}:a.refs,d=a.setupState,w=ue(d),m=d===ye?pc:h=>Zo(u,h)?!1:de(w,h),S=(h,D)=>!(D&&Zo(u,D));if(l!=null&&l!==c){if(Qo(e),ke(l))u[l]=null,m(l)&&(d[l]=null);else if(Ee(l)){const h=e;S(l,h.k)&&(l.value=null),h.k&&(u[h.k]=null)}}if(ie(c))os(c,a,12,[o,u]);else{const h=ke(c),D=Ee(c);if(h||D){const I=()=>{if(t.f){const b=h?m(c)?d[c]:u[c]:S()||!t.k?c.value:u[t.k];if(s)re(b)&&lo(b,i);else if(re(b))b.includes(i)||b.push(i);else if(h)u[c]=[i],m(c)&&(d[c]=u[c]);else{const C=[i];S(c,t.k)&&(c.value=C),t.k&&(u[t.k]=C)}}else h?(u[c]=o,m(c)&&(d[c]=o)):D&&(S(c,t.k)&&(c.value=o),t.k&&(u[t.k]=o))};if(o){const b=()=>{I(),Ns.delete(t)};b.id=-1,Ns.set(t,b),Ve(b,n)}else Qo(t),I()}}}function Qo(t){const e=Ns.get(t);e&&(e.flags|=8,Ns.delete(t))}const ea=t=>t.nodeType===8;Qs().requestIdleCallback;Qs().cancelIdleCallback;function md(t,e){if(ea(t)&&t.data==="["){let n=1,r=t.nextSibling;for(;r;){if(r.nodeType===1){if(e(r)===!1)break}else if(ea(r))if(r.data==="]"){if(--n===0)break}else r.data==="["&&n++;r=r.nextSibling}}else e(t)}const Fr=t=>!!t.type.__asyncLoader;function Ie(t){ie(t)&&(t={loader:t});const{loader:e,loadingComponent:n,errorComponent:r,delay:s=200,hydrate:i,timeout:o,suspensible:a=!0,onError:c}=t;let l=null,u,d=0;const w=()=>(d++,l=null,m()),m=()=>{let S;return l||(S=l=e().catch(h=>{if(h=h instanceof Error?h:new Error(String(h)),c)return new Promise((D,I)=>{c(h,()=>D(w()),()=>I(h),d+1)});throw h}).then(h=>S!==l&&l?l:(h&&(h.__esModule||h[Symbol.toStringTag]==="Module")&&(h=h.default),u=h,h)))};return gd({name:"AsyncComponentWrapper",__asyncLoader:m,__asyncHydrate(S,h,D){let I=!1;(h.bu||(h.bu=[])).push(()=>I=!0);const b=()=>{I||D()},C=i?()=>{const f=i(b,p=>md(S,p));f&&(h.bum||(h.bum=[])).push(f)}:b;u?C():m().then(()=>!h.isUnmounted&&C())},get __asyncResolved(){return u},setup(){const S=Le;if(_o(S),u)return()=>hs(u,S);const h=C=>{l=null,as(C,S,13,!r)};if(a&&S.suspense||vr)return m().then(C=>()=>hs(C,S)).catch(C=>(h(C),()=>r?Re(r,{error:C}):null));const D=F(!1),I=F(),b=F(!!s);return s&&setTimeout(()=>{b.value=!1},s),o!=null&&setTimeout(()=>{if(!D.value&&!I.value){const C=new Error(`Async component timed out after ${o}ms.`);h(C),I.value=C}},o),m().then(()=>{D.value=!0,S.parent&&xo(S.parent.vnode)&&S.parent.update()}).catch(C=>{h(C),I.value=C}),()=>{if(D.value&&u)return hs(u,S);if(I.value&&r)return Re(r,{error:I.value});if(n&&!b.value)return hs(n,S)}}})}function hs(t,e){const{ref:n,props:r,children:s,ce:i}=e.vnode,o=Re(t,r,s);return o.ref=n,o.ce=i,delete e.vnode.ce,o}const xo=t=>t.type.__isKeepAlive;function hd(t,e){jc(t,"a",e)}function yd(t,e){jc(t,"da",e)}function jc(t,e,n=Le){const r=t.__wdc||(t.__wdc=()=>{let s=n;for(;s;){if(s.isDeactivated)return;s=s.parent}return t()});if(si(e,r,n),n){let s=n.parent;for(;s&&s.parent;)xo(s.parent.vnode)&&bd(r,e,n,s),s=s.parent}}function bd(t,e,n,r){const s=si(e,t,r,!0);So(()=>{lo(r[e],s)},n)}function si(t,e,n=Le,r=!1){if(n){const s=n[t]||(n[t]=[]),i=e.__weh||(e.__weh=(...o)=>{fn();const a=cs(n),c=Kt(e,n,t,o);return a(),pn(),c});return r?s.unshift(i):s.push(i),i}}const hn=t=>(e,n=Le)=>{(!vr||t==="sp")&&si(t,(...r)=>e(...r),n)},wd=hn("bm"),Co=hn("m"),vd=hn("bu"),_d=hn("u"),xd=hn("bum"),So=hn("um"),Cd=hn("sp"),Sd=hn("rtg"),Ed=hn("rtc");function kd(t,e=Le){si("ec",t,e)}const Ad="components",Xc=Symbol.for("v-ndc");function Td(t){return ke(t)?Dd(Ad,t,!1)||t:t||Xc}function Dd(t,e,n=!0,r=!1){const s=lt||Le;if(s){const i=s.type;{const a=gf(i,!1);if(a&&(a===e||a===bt(e)||a===Ys(bt(e))))return i}const o=ta(s[t]||i[t],e)||ta(s.appContext[t],e);return!o&&r?i:o}}function ta(t,e){return t&&(t[e]||t[bt(e)]||t[Ys(bt(e))])}function Ms(t,e,n,r){let s;const i=n,o=re(t);if(o||ke(t)){const a=o&&cn(t);let c=!1,l=!1;a&&(c=!dt(t),l=gn(t),t=ti(t)),s=new Array(t.length);for(let u=0,d=t.length;u<d;u++)s[u]=e(c?l?br(kt(t[u])):kt(t[u]):t[u],u,void 0,i)}else if(typeof t=="number"){s=new Array(t);for(let a=0;a<t;a++)s[a]=e(a+1,a,void 0,i)}else if(me(t))if(t[Symbol.iterator])s=Array.from(t,(a,c)=>e(a,c,void 0,i));else{const a=Object.keys(t);s=new Array(a.length);for(let c=0,l=a.length;c<l;c++){const u=a[c];s[c]=e(t[u],u,c,i)}}else s=[];return s}const Hi=t=>t?yl(t)?ai(t):Hi(t.parent):null,qr=Me(Object.create(null),{$:t=>t,$el:t=>t.vnode.el,$data:t=>t.data,$props:t=>t.props,$attrs:t=>t.attrs,$slots:t=>t.slots,$refs:t=>t.refs,$parent:t=>Hi(t.parent),$root:t=>Hi(t.root),$host:t=>t.ce,$emit:t=>t.emit,$options:t=>Yc(t),$forceUpdate:t=>t.f||(t.f=()=>{wo(t.update)}),$nextTick:t=>t.n||(t.n=bo.bind(t.proxy)),$watch:t=>ud.bind(t)}),Ci=(t,e)=>t!==ye&&!t.__isScriptSetup&&de(t,e),Bd={get({_:t},e){if(e==="__v_skip")return!0;const{ctx:n,setupState:r,data:s,props:i,accessCache:o,type:a,appContext:c}=t;if(e[0]!=="$"){const w=o[e];if(w!==void 0)switch(w){case 1:return r[e];case 2:return s[e];case 4:return n[e];case 3:return i[e]}else{if(Ci(r,e))return o[e]=1,r[e];if(s!==ye&&de(s,e))return o[e]=2,s[e];if(de(i,e))return o[e]=3,i[e];if(n!==ye&&de(n,e))return o[e]=4,n[e];Vi&&(o[e]=0)}}const l=qr[e];let u,d;if(l)return e==="$attrs"&&qe(t.attrs,"get",""),l(t);if((u=a.__cssModules)&&(u=u[e]))return u;if(n!==ye&&de(n,e))return o[e]=4,n[e];if(d=c.config.globalProperties,de(d,e))return d[e]},set({_:t},e,n){const{data:r,setupState:s,ctx:i}=t;return Ci(s,e)?(s[e]=n,!0):r!==ye&&de(r,e)?(r[e]=n,!0):de(t.props,e)||e[0]==="$"&&e.slice(1)in t?!1:(i[e]=n,!0)},has({_:{data:t,setupState:e,accessCache:n,ctx:r,appContext:s,props:i,type:o}},a){let c;return!!(n[a]||t!==ye&&a[0]!=="$"&&de(t,a)||Ci(e,a)||de(i,a)||de(r,a)||de(qr,a)||de(s.config.globalProperties,a)||(c=o.__cssModules)&&c[a])},defineProperty(t,e,n){return n.get!=null?t._.accessCache[e]=0:de(n,"value")&&this.set(t,e,n.value,null),Reflect.defineProperty(t,e,n)}};function na(t){return re(t)?t.reduce((e,n)=>(e[n]=null,e),{}):t}let Vi=!0;function Id(t){const e=Yc(t),n=t.proxy,r=t.ctx;Vi=!1,e.beforeCreate&&ra(e.beforeCreate,t,"bc");const{data:s,computed:i,methods:o,watch:a,provide:c,inject:l,created:u,beforeMount:d,mounted:w,beforeUpdate:m,updated:S,activated:h,deactivated:D,beforeDestroy:I,beforeUnmount:b,destroyed:C,unmounted:f,render:p,renderTracked:v,renderTriggered:k,errorCaptured:x,serverPrefetch:g,expose:T,inheritAttrs:A,components:L,directives:K,filters:ee}=e;if(l&&Od(l,r,null),o)for(const E in o){const $=o[E];ie($)&&(r[E]=$.bind(n))}if(s){const E=s.call(n,n);me(E)&&(t.data=ni(E))}if(Vi=!0,i)for(const E in i){const $=i[E],Y=ie($)?$.bind(n,n):ie($.get)?$.get.bind(n,n):Wt,ne=!ie($)&&ie($.set)?$.set.bind(n):Wt,ce=B({get:Y,set:ne});Object.defineProperty(r,E,{enumerable:!0,configurable:!0,get:()=>ce.value,set:pe=>ce.value=pe})}if(a)for(const E in a)Jc(a[E],r,n,E);if(c){const E=ie(c)?c.call(n):c;Reflect.ownKeys(E).forEach($=>{od($,E[$])})}u&&ra(u,t,"c");function O(E,$){re($)?$.forEach(Y=>E(Y.bind(n))):$&&E($.bind(n))}if(O(wd,d),O(Co,w),O(vd,m),O(_d,S),O(hd,h),O(yd,D),O(kd,x),O(Ed,v),O(Sd,k),O(xd,b),O(So,f),O(Cd,g),re(T))if(T.length){const E=t.exposed||(t.exposed={});T.forEach($=>{Object.defineProperty(E,$,{get:()=>n[$],set:Y=>n[$]=Y,enumerable:!0})})}else t.exposed||(t.exposed={});p&&t.render===Wt&&(t.render=p),A!=null&&(t.inheritAttrs=A),L&&(t.components=L),K&&(t.directives=K),g&&_o(t)}function Od(t,e,n=Wt){re(t)&&(t=Fi(t));for(const r in t){const s=t[r];let i;me(s)?"default"in s?i=Ur(s.from||r,s.default,!0):i=Ur(s.from||r):i=Ur(s),Ee(i)?Object.defineProperty(e,r,{enumerable:!0,configurable:!0,get:()=>i.value,set:o=>i.value=o}):e[r]=i}}function ra(t,e,n){Kt(re(t)?t.map(r=>r.bind(e.proxy)):t.bind(e.proxy),e,n)}function Jc(t,e,n,r){let s=r.includes(".")?zc(n,r):()=>n[r];if(ke(t)){const i=e[t];ie(i)&&Cs(s,i)}else if(ie(t))Cs(s,t.bind(n));else if(me(t))if(re(t))t.forEach(i=>Jc(i,e,n,r));else{const i=ie(t.handler)?t.handler.bind(n):e[t.handler];ie(i)&&Cs(s,i,t)}}function Yc(t){const e=t.type,{mixins:n,extends:r}=e,{mixins:s,optionsCache:i,config:{optionMergeStrategies:o}}=t.appContext,a=i.get(e);let c;return a?c=a:!s.length&&!n&&!r?c=e:(c={},s.length&&s.forEach(l=>Us(c,l,o,!0)),Us(c,e,o)),me(e)&&i.set(e,c),c}function Us(t,e,n,r=!1){const{mixins:s,extends:i}=e;i&&Us(t,i,n,!0),s&&s.forEach(o=>Us(t,o,n,!0));for(const o in e)if(!(r&&o==="expose")){const a=Pd[o]||n&&n[o];t[o]=a?a(t[o],e[o]):e[o]}return t}const Pd={data:sa,props:ia,emits:ia,methods:Lr,computed:Lr,beforeCreate:Ge,created:Ge,beforeMount:Ge,mounted:Ge,beforeUpdate:Ge,updated:Ge,beforeDestroy:Ge,beforeUnmount:Ge,destroyed:Ge,unmounted:Ge,activated:Ge,deactivated:Ge,errorCaptured:Ge,serverPrefetch:Ge,components:Lr,directives:Lr,watch:Ld,provide:sa,inject:$d};function sa(t,e){return e?t?function(){return Me(ie(t)?t.call(this,this):t,ie(e)?e.call(this,this):e)}:e:t}function $d(t,e){return Lr(Fi(t),Fi(e))}function Fi(t){if(re(t)){const e={};for(let n=0;n<t.length;n++)e[t[n]]=t[n];return e}return t}function Ge(t,e){return t?[...new Set([].concat(t,e))]:e}function Lr(t,e){return t?Me(Object.create(null),t,e):e}function ia(t,e){return t?re(t)&&re(e)?[...new Set([...t,...e])]:Me(Object.create(null),na(t),na(e??{})):e}function Ld(t,e){if(!t)return e;if(!e)return t;const n=Me(Object.create(null),t);for(const r in e)n[r]=Ge(t[r],e[r]);return n}function Zc(){return{app:null,config:{isNativeTag:pc,performance:!1,globalProperties:{},optionMergeStrategies:{},errorHandler:void 0,warnHandler:void 0,compilerOptions:{}},mixins:[],components:{},directives:{},provides:Object.create(null),optionsCache:new WeakMap,propsCache:new WeakMap,emitsCache:new WeakMap}}let Rd=0;function Nd(t,e){return function(r,s=null){ie(r)||(r=Me({},r)),s!=null&&!me(s)&&(s=null);const i=Zc(),o=new WeakSet,a=[];let c=!1;const l=i.app={_uid:Rd++,_component:r,_props:s,_container:null,_context:i,_instance:null,version:hf,get config(){return i.config},set config(u){},use(u,...d){return o.has(u)||(u&&ie(u.install)?(o.add(u),u.install(l,...d)):ie(u)&&(o.add(u),u(l,...d))),l},mixin(u){return i.mixins.includes(u)||i.mixins.push(u),l},component(u,d){return d?(i.components[u]=d,l):i.components[u]},directive(u,d){return d?(i.directives[u]=d,l):i.directives[u]},mount(u,d,w){if(!c){const m=l._ceVNode||Re(r,s);return m.appContext=i,w===!0?w="svg":w===!1&&(w=void 0),t(m,u,w),c=!0,l._container=u,u.__vue_app__=l,ai(m.component)}},onUnmount(u){a.push(u)},unmount(){c&&(Kt(a,l._instance,16),t(null,l._container),delete l._container.__vue_app__)},provide(u,d){return i.provides[u]=d,l},runWithContext(u){const d=Xn;Xn=l;try{return u()}finally{Xn=d}}};return l}}let Xn=null;const Md=(t,e)=>e==="modelValue"||e==="model-value"?t.modelModifiers:t[`${e}Modifiers`]||t[`${bt(e)}Modifiers`]||t[`${In(e)}Modifiers`];function Ud(t,e,...n){if(t.isUnmounted)return;const r=t.vnode.props||ye;let s=n;const i=e.startsWith("update:"),o=i&&Md(r,e.slice(7));o&&(o.trim&&(s=n.map(u=>ke(u)?u.trim():u)),o.number&&(s=n.map(Zs)));let a,c=r[a=bi(e)]||r[a=bi(bt(e))];!c&&i&&(c=r[a=bi(In(e))]),c&&Kt(c,t,6,s);const l=r[a+"Once"];if(l){if(!t.emitted)t.emitted={};else if(t.emitted[a])return;t.emitted[a]=!0,Kt(l,t,6,s)}}const Hd=new WeakMap;function Qc(t,e,n=!1){const r=n?Hd:e.emitsCache,s=r.get(t);if(s!==void 0)return s;const i=t.emits;let o={},a=!1;if(!ie(t)){const c=l=>{const u=Qc(l,e,!0);u&&(a=!0,Me(o,u))};!n&&e.mixins.length&&e.mixins.forEach(c),t.extends&&c(t.extends),t.mixins&&t.mixins.forEach(c)}return!i&&!a?(me(t)&&r.set(t,null),null):(re(i)?i.forEach(c=>o[c]=null):Me(o,i),me(t)&&r.set(t,o),o)}function ii(t,e){return!t||!Ks(e)?!1:(e=e.slice(2).replace(/Once$/,""),de(t,e[0].toLowerCase()+e.slice(1))||de(t,In(e))||de(t,e))}function oa(t){const{type:e,vnode:n,proxy:r,withProxy:s,propsOptions:[i],slots:o,attrs:a,emit:c,render:l,renderCache:u,props:d,data:w,setupState:m,ctx:S,inheritAttrs:h}=t,D=Rs(t);let I,b;try{if(n.shapeFlag&4){const f=s||r,p=f;I=Ht(l.call(p,f,u,d,m,w,S)),b=a}else{const f=e;I=Ht(f.length>1?f(d,{attrs:a,slots:o,emit:c}):f(d,null)),b=e.props?a:Vd(a)}}catch(f){Wr.length=0,as(f,t,1),I=Re(Bn)}let C=I;if(b&&h!==!1){const f=Object.keys(b),{shapeFlag:p}=C;f.length&&p&7&&(i&&f.some(co)&&(b=Fd(b,i)),C=wr(C,b,!1,!0))}return n.dirs&&(C=wr(C,null,!1,!0),C.dirs=C.dirs?C.dirs.concat(n.dirs):n.dirs),n.transition&&vo(C,n.transition),I=C,Rs(D),I}const Vd=t=>{let e;for(const n in t)(n==="class"||n==="style"||Ks(n))&&((e||(e={}))[n]=t[n]);return e},Fd=(t,e)=>{const n={};for(const r in t)(!co(r)||!(r.slice(9)in e))&&(n[r]=t[r]);return n};function qd(t,e,n){const{props:r,children:s,component:i}=t,{props:o,children:a,patchFlag:c}=e,l=i.emitsOptions;if(e.dirs||e.transition)return!0;if(n&&c>=0){if(c&1024)return!0;if(c&16)return r?aa(r,o,l):!!o;if(c&8){const u=e.dynamicProps;for(let d=0;d<u.length;d++){const w=u[d];if(el(o,r,w)&&!ii(l,w))return!0}}}else return(s||a)&&(!a||!a.$stable)?!0:r===o?!1:r?o?aa(r,o,l):!0:!!o;return!1}function aa(t,e,n){const r=Object.keys(e);if(r.length!==Object.keys(t).length)return!0;for(let s=0;s<r.length;s++){const i=r[s];if(el(e,t,i)&&!ii(n,i))return!0}return!1}function el(t,e,n){const r=t[n],s=e[n];return n==="style"&&me(r)&&me(s)?!Zn(r,s):r!==s}function Wd({vnode:t,parent:e},n){for(;e;){const r=e.subTree;if(r.suspense&&r.suspense.activeBranch===t&&(r.el=t.el),r===t)(t=e.vnode).el=n,e=e.parent;else break}}const tl={},nl=()=>Object.create(tl),rl=t=>Object.getPrototypeOf(t)===tl;function zd(t,e,n,r=!1){const s={},i=nl();t.propsDefaults=Object.create(null),sl(t,e,s,i);for(const o in t.propsOptions[0])o in s||(s[o]=void 0);n?t.props=r?s:zu(s):t.type.props?t.props=s:t.props=i,t.attrs=i}function Gd(t,e,n,r){const{props:s,attrs:i,vnode:{patchFlag:o}}=t,a=ue(s),[c]=t.propsOptions;let l=!1;if((r||o>0)&&!(o&16)){if(o&8){const u=t.vnode.dynamicProps;for(let d=0;d<u.length;d++){let w=u[d];if(ii(t.emitsOptions,w))continue;const m=e[w];if(c)if(de(i,w))m!==i[w]&&(i[w]=m,l=!0);else{const S=bt(w);s[S]=qi(c,a,S,m,t,!1)}else m!==i[w]&&(i[w]=m,l=!0)}}}else{sl(t,e,s,i)&&(l=!0);let u;for(const d in a)(!e||!de(e,d)&&((u=In(d))===d||!de(e,u)))&&(c?n&&(n[d]!==void 0||n[u]!==void 0)&&(s[d]=qi(c,a,d,void 0,t,!0)):delete s[d]);if(i!==a)for(const d in i)(!e||!de(e,d))&&(delete i[d],l=!0)}l&&rn(t.attrs,"set","")}function sl(t,e,n,r){const[s,i]=t.propsOptions;let o=!1,a;if(e)for(let c in e){if(Rr(c))continue;const l=e[c];let u;s&&de(s,u=bt(c))?!i||!i.includes(u)?n[u]=l:(a||(a={}))[u]=l:ii(t.emitsOptions,c)||(!(c in r)||l!==r[c])&&(r[c]=l,o=!0)}if(i){const c=ue(n),l=a||ye;for(let u=0;u<i.length;u++){const d=i[u];n[d]=qi(s,c,d,l[d],t,!de(l,d))}}return o}function qi(t,e,n,r,s,i){const o=t[n];if(o!=null){const a=de(o,"default");if(a&&r===void 0){const c=o.default;if(o.type!==Function&&!o.skipFactory&&ie(c)){const{propsDefaults:l}=s;if(n in l)r=l[n];else{const u=cs(s);r=l[n]=c.call(null,e),u()}}else r=c;s.ce&&s.ce._setProp(n,r)}o[0]&&(i&&!a?r=!1:o[1]&&(r===""||r===In(n))&&(r=!0))}return r}const Kd=new WeakMap;function il(t,e,n=!1){const r=n?Kd:e.propsCache,s=r.get(t);if(s)return s;const i=t.props,o={},a=[];let c=!1;if(!ie(t)){const u=d=>{c=!0;const[w,m]=il(d,e,!0);Me(o,w),m&&a.push(...m)};!n&&e.mixins.length&&e.mixins.forEach(u),t.extends&&u(t.extends),t.mixins&&t.mixins.forEach(u)}if(!i&&!c)return me(t)&&r.set(t,ur),ur;if(re(i))for(let u=0;u<i.length;u++){const d=bt(i[u]);ca(d)&&(o[d]=ye)}else if(i)for(const u in i){const d=bt(u);if(ca(d)){const w=i[u],m=o[d]=re(w)||ie(w)?{type:w}:Me({},w),S=m.type;let h=!1,D=!0;if(re(S))for(let I=0;I<S.length;++I){const b=S[I],C=ie(b)&&b.name;if(C==="Boolean"){h=!0;break}else C==="String"&&(D=!1)}else h=ie(S)&&S.name==="Boolean";m[0]=h,m[1]=D,(h||de(m,"default"))&&a.push(d)}}const l=[o,a];return me(t)&&r.set(t,l),l}function ca(t){return t[0]!=="$"&&!Rr(t)}const Eo=t=>t==="_"||t==="_ctx"||t==="$stable",ko=t=>re(t)?t.map(Ht):[Ht(t)],jd=(t,e,n)=>{if(e._n)return e;const r=id((...s)=>ko(e(...s)),n);return r._c=!1,r},ol=(t,e,n)=>{const r=t._ctx;for(const s in t){if(Eo(s))continue;const i=t[s];if(ie(i))e[s]=jd(s,i,r);else if(i!=null){const o=ko(i);e[s]=()=>o}}},al=(t,e)=>{const n=ko(e);t.slots.default=()=>n},cl=(t,e,n)=>{for(const r in e)(n||!Eo(r))&&(t[r]=e[r])},Xd=(t,e,n)=>{const r=t.slots=nl();if(t.vnode.shapeFlag&32){const s=e._;s?(cl(r,e,n),n&&yc(r,"_",s,!0)):ol(e,r)}else e&&al(t,e)},Jd=(t,e,n)=>{const{vnode:r,slots:s}=t;let i=!0,o=ye;if(r.shapeFlag&32){const a=e._;a?n&&a===1?i=!1:cl(s,e,n):(i=!e.$stable,ol(e,s)),o=e}else e&&(al(t,e),o={default:1});if(i)for(const a in s)!Eo(a)&&o[a]==null&&delete s[a]},Ve=tf;function Yd(t){return Zd(t)}function Zd(t,e){const n=Qs();n.__VUE__=!0;const{insert:r,remove:s,patchProp:i,createElement:o,createText:a,createComment:c,setText:l,setElementText:u,parentNode:d,nextSibling:w,setScopeId:m=Wt,insertStaticContent:S}=t,h=(y,_,P,U=null,R=null,H=null,G=void 0,W=null,q=!!_.dynamicChildren)=>{if(y===_)return;y&&!Ir(y,_)&&(U=it(y),pe(y,R,H,!0),y=null),_.patchFlag===-2&&(q=!1,_.dynamicChildren=null);const{type:V,ref:te,shapeFlag:j}=_;switch(V){case oi:D(y,_,P,U);break;case Bn:I(y,_,P,U);break;case Es:y==null&&b(_,P,U,G);break;case ct:L(y,_,P,U,R,H,G,W,q);break;default:j&1?p(y,_,P,U,R,H,G,W,q):j&6?K(y,_,P,U,R,H,G,W,q):(j&64||j&128)&&V.process(y,_,P,U,R,H,G,W,q,pt)}te!=null&&R?Vr(te,y&&y.ref,H,_||y,!_):te==null&&y&&y.ref!=null&&Vr(y.ref,null,H,y,!0)},D=(y,_,P,U)=>{if(y==null)r(_.el=a(_.children),P,U);else{const R=_.el=y.el;_.children!==y.children&&l(R,_.children)}},I=(y,_,P,U)=>{y==null?r(_.el=c(_.children||""),P,U):_.el=y.el},b=(y,_,P,U)=>{[y.el,y.anchor]=S(y.children,_,P,U,y.el,y.anchor)},C=({el:y,anchor:_},P,U)=>{let R;for(;y&&y!==_;)R=w(y),r(y,P,U),y=R;r(_,P,U)},f=({el:y,anchor:_})=>{let P;for(;y&&y!==_;)P=w(y),s(y),y=P;s(_)},p=(y,_,P,U,R,H,G,W,q)=>{if(_.type==="svg"?G="svg":_.type==="math"&&(G="mathml"),y==null)v(_,P,U,R,H,G,W,q);else{const V=y.el&&y.el._isVueCE?y.el:null;try{V&&V._beginPatch(),g(y,_,R,H,G,W,q)}finally{V&&V._endPatch()}}},v=(y,_,P,U,R,H,G,W)=>{let q,V;const{props:te,shapeFlag:j,transition:Q,dirs:se}=y;if(q=y.el=o(y.type,H,te&&te.is,te),j&8?u(q,y.children):j&16&&x(y.children,q,null,U,R,Si(y,H),G,W),se&&$n(y,null,U,"created"),k(q,y,y.scopeId,G,U),te){for(const be in te)be!=="value"&&!Rr(be)&&i(q,be,null,te[be],H,U);"value"in te&&i(q,"value",null,te.value,H),(V=te.onVnodeBeforeMount)&&Pt(V,U,y)}se&&$n(y,null,U,"beforeMount");const ae=Qd(R,Q);ae&&Q.beforeEnter(q),r(q,_,P),((V=te&&te.onVnodeMounted)||ae||se)&&Ve(()=>{V&&Pt(V,U,y),ae&&Q.enter(q),se&&$n(y,null,U,"mounted")},R)},k=(y,_,P,U,R)=>{if(P&&m(y,P),U)for(let H=0;H<U.length;H++)m(y,U[H]);if(R){let H=R.subTree;if(_===H||dl(H.type)&&(H.ssContent===_||H.ssFallback===_)){const G=R.vnode;k(y,G,G.scopeId,G.slotScopeIds,R.parent)}}},x=(y,_,P,U,R,H,G,W,q=0)=>{for(let V=q;V<y.length;V++){const te=y[V]=W?Qt(y[V]):Ht(y[V]);h(null,te,_,P,U,R,H,G,W)}},g=(y,_,P,U,R,H,G)=>{const W=_.el=y.el;let{patchFlag:q,dynamicChildren:V,dirs:te}=_;q|=y.patchFlag&16;const j=y.props||ye,Q=_.props||ye;let se;if(P&&Ln(P,!1),(se=Q.onVnodeBeforeUpdate)&&Pt(se,P,_,y),te&&$n(_,y,P,"beforeUpdate"),P&&Ln(P,!0),(j.innerHTML&&Q.innerHTML==null||j.textContent&&Q.textContent==null)&&u(W,""),V?T(y.dynamicChildren,V,W,P,U,Si(_,R),H):G||$(y,_,W,null,P,U,Si(_,R),H,!1),q>0){if(q&16)A(W,j,Q,P,R);else if(q&2&&j.class!==Q.class&&i(W,"class",null,Q.class,R),q&4&&i(W,"style",j.style,Q.style,R),q&8){const ae=_.dynamicProps;for(let be=0;be<ae.length;be++){const ge=ae[be],Ye=j[ge],Ze=Q[ge];(Ze!==Ye||ge==="value")&&i(W,ge,Ye,Ze,R,P)}}q&1&&y.children!==_.children&&u(W,_.children)}else!G&&V==null&&A(W,j,Q,P,R);((se=Q.onVnodeUpdated)||te)&&Ve(()=>{se&&Pt(se,P,_,y),te&&$n(_,y,P,"updated")},U)},T=(y,_,P,U,R,H,G)=>{for(let W=0;W<_.length;W++){const q=y[W],V=_[W],te=q.el&&(q.type===ct||!Ir(q,V)||q.shapeFlag&198)?d(q.el):P;h(q,V,te,null,U,R,H,G,!0)}},A=(y,_,P,U,R)=>{if(_!==P){if(_!==ye)for(const H in _)!Rr(H)&&!(H in P)&&i(y,H,_[H],null,R,U);for(const H in P){if(Rr(H))continue;const G=P[H],W=_[H];G!==W&&H!=="value"&&i(y,H,W,G,R,U)}"value"in P&&i(y,"value",_.value,P.value,R)}},L=(y,_,P,U,R,H,G,W,q)=>{const V=_.el=y?y.el:a(""),te=_.anchor=y?y.anchor:a("");let{patchFlag:j,dynamicChildren:Q,slotScopeIds:se}=_;se&&(W=W?W.concat(se):se),y==null?(r(V,P,U),r(te,P,U),x(_.children||[],P,te,R,H,G,W,q)):j>0&&j&64&&Q&&y.dynamicChildren&&y.dynamicChildren.length===Q.length?(T(y.dynamicChildren,Q,P,R,H,G,W),(_.key!=null||R&&_===R.subTree)&&Ao(y,_,!0)):$(y,_,P,te,R,H,G,W,q)},K=(y,_,P,U,R,H,G,W,q)=>{_.slotScopeIds=W,y==null?_.shapeFlag&512?R.ctx.activate(_,P,U,G,q):ee(_,P,U,R,H,G,q):M(y,_,q)},ee=(y,_,P,U,R,H,G)=>{const W=y.component=lf(y,U,R);if(xo(y)&&(W.ctx.renderer=pt),uf(W,!1,G),W.asyncDep){if(R&&R.registerDep(W,O,G),!y.el){const q=W.subTree=Re(Bn);I(null,q,_,P),y.placeholder=q.el}}else O(W,y,_,P,R,H,G)},M=(y,_,P)=>{const U=_.component=y.component;if(qd(y,_,P))if(U.asyncDep&&!U.asyncResolved){E(U,_,P);return}else U.next=_,U.update();else _.el=y.el,U.vnode=_},O=(y,_,P,U,R,H,G)=>{const W=()=>{if(y.isMounted){let{next:j,bu:Q,u:se,parent:ae,vnode:be}=y;{const It=ll(y);if(It){j&&(j.el=be.el,E(y,j,G)),It.asyncDep.then(()=>{Ve(()=>{y.isUnmounted||V()},R)});return}}let ge=j,Ye;Ln(y,!1),j?(j.el=be.el,E(y,j,G)):j=be,Q&&xs(Q),(Ye=j.props&&j.props.onVnodeBeforeUpdate)&&Pt(Ye,ae,j,be),Ln(y,!0);const Ze=oa(y),Bt=y.subTree;y.subTree=Ze,h(Bt,Ze,d(Bt.el),it(Bt),y,R,H),j.el=Ze.el,ge===null&&Wd(y,Ze.el),se&&Ve(se,R),(Ye=j.props&&j.props.onVnodeUpdated)&&Ve(()=>Pt(Ye,ae,j,be),R)}else{let j;const{el:Q,props:se}=_,{bm:ae,m:be,parent:ge,root:Ye,type:Ze}=y,Bt=Fr(_);Ln(y,!1),ae&&xs(ae),!Bt&&(j=se&&se.onVnodeBeforeMount)&&Pt(j,ge,_),Ln(y,!0);{Ye.ce&&Ye.ce._hasShadowRoot()&&Ye.ce._injectChildStyle(Ze);const It=y.subTree=oa(y);h(null,It,P,U,y,R,H),_.el=It.el}if(be&&Ve(be,R),!Bt&&(j=se&&se.onVnodeMounted)){const It=_;Ve(()=>Pt(j,ge,It),R)}(_.shapeFlag&256||ge&&Fr(ge.vnode)&&ge.vnode.shapeFlag&256)&&y.a&&Ve(y.a,R),y.isMounted=!0,_=P=U=null}};y.scope.on();const q=y.effect=new Sc(W);y.scope.off();const V=y.update=q.run.bind(q),te=y.job=q.runIfDirty.bind(q);te.i=y,te.id=y.uid,q.scheduler=()=>wo(te),Ln(y,!0),V()},E=(y,_,P)=>{_.component=y;const U=y.vnode.props;y.vnode=_,y.next=null,Gd(y,_.props,U,P),Jd(y,_.children,P),fn(),jo(y),pn()},$=(y,_,P,U,R,H,G,W,q=!1)=>{const V=y&&y.children,te=y?y.shapeFlag:0,j=_.children,{patchFlag:Q,shapeFlag:se}=_;if(Q>0){if(Q&128){ne(V,j,P,U,R,H,G,W,q);return}else if(Q&256){Y(V,j,P,U,R,H,G,W,q);return}}se&8?(te&16&&wt(V,R,H),j!==V&&u(P,j)):te&16?se&16?ne(V,j,P,U,R,H,G,W,q):wt(V,R,H,!0):(te&8&&u(P,""),se&16&&x(j,P,U,R,H,G,W,q))},Y=(y,_,P,U,R,H,G,W,q)=>{y=y||ur,_=_||ur;const V=y.length,te=_.length,j=Math.min(V,te);let Q;for(Q=0;Q<j;Q++){const se=_[Q]=q?Qt(_[Q]):Ht(_[Q]);h(y[Q],se,P,null,R,H,G,W,q)}V>te?wt(y,R,H,!0,!1,j):x(_,P,U,R,H,G,W,q,j)},ne=(y,_,P,U,R,H,G,W,q)=>{let V=0;const te=_.length;let j=y.length-1,Q=te-1;for(;V<=j&&V<=Q;){const se=y[V],ae=_[V]=q?Qt(_[V]):Ht(_[V]);if(Ir(se,ae))h(se,ae,P,null,R,H,G,W,q);else break;V++}for(;V<=j&&V<=Q;){const se=y[j],ae=_[Q]=q?Qt(_[Q]):Ht(_[Q]);if(Ir(se,ae))h(se,ae,P,null,R,H,G,W,q);else break;j--,Q--}if(V>j){if(V<=Q){const se=Q+1,ae=se<te?_[se].el:U;for(;V<=Q;)h(null,_[V]=q?Qt(_[V]):Ht(_[V]),P,ae,R,H,G,W,q),V++}}else if(V>Q)for(;V<=j;)pe(y[V],R,H,!0),V++;else{const se=V,ae=V,be=new Map;for(V=ae;V<=Q;V++){const ot=_[V]=q?Qt(_[V]):Ht(_[V]);ot.key!=null&&be.set(ot.key,V)}let ge,Ye=0;const Ze=Q-ae+1;let Bt=!1,It=0;const Dr=new Array(Ze);for(V=0;V<Ze;V++)Dr[V]=0;for(V=se;V<=j;V++){const ot=y[V];if(Ye>=Ze){pe(ot,R,H,!0);continue}let Ot;if(ot.key!=null)Ot=be.get(ot.key);else for(ge=ae;ge<=Q;ge++)if(Dr[ge-ae]===0&&Ir(ot,_[ge])){Ot=ge;break}Ot===void 0?pe(ot,R,H,!0):(Dr[Ot-ae]=V+1,Ot>=It?It=Ot:Bt=!0,h(ot,_[Ot],P,null,R,H,G,W,q),Ye++)}const Uo=Bt?ef(Dr):ur;for(ge=Uo.length-1,V=Ze-1;V>=0;V--){const ot=ae+V,Ot=_[ot],Ho=_[ot+1],Vo=ot+1<te?Ho.el||ul(Ho):U;Dr[V]===0?h(null,Ot,P,Vo,R,H,G,W,q):Bt&&(ge<0||V!==Uo[ge]?ce(Ot,P,Vo,2):ge--)}}},ce=(y,_,P,U,R=null)=>{const{el:H,type:G,transition:W,children:q,shapeFlag:V}=y;if(V&6){ce(y.component.subTree,_,P,U);return}if(V&128){y.suspense.move(_,P,U);return}if(V&64){G.move(y,_,P,pt);return}if(G===ct){r(H,_,P);for(let j=0;j<q.length;j++)ce(q[j],_,P,U);r(y.anchor,_,P);return}if(G===Es){C(y,_,P);return}if(U!==2&&V&1&&W)if(U===0)W.beforeEnter(H),r(H,_,P),Ve(()=>W.enter(H),R);else{const{leave:j,delayLeave:Q,afterLeave:se}=W,ae=()=>{y.ctx.isUnmounted?s(H):r(H,_,P)},be=()=>{H._isLeaving&&H[pd](!0),j(H,()=>{ae(),se&&se()})};Q?Q(H,ae,be):be()}else r(H,_,P)},pe=(y,_,P,U=!1,R=!1)=>{const{type:H,props:G,ref:W,children:q,dynamicChildren:V,shapeFlag:te,patchFlag:j,dirs:Q,cacheIndex:se}=y;if(j===-2&&(R=!1),W!=null&&(fn(),Vr(W,null,P,y,!0),pn()),se!=null&&(_.renderCache[se]=void 0),te&256){_.ctx.deactivate(y);return}const ae=te&1&&Q,be=!Fr(y);let ge;if(be&&(ge=G&&G.onVnodeBeforeUnmount)&&Pt(ge,_,y),te&6)bn(y.component,P,U);else{if(te&128){y.suspense.unmount(P,U);return}ae&&$n(y,null,_,"beforeUnmount"),te&64?y.type.remove(y,_,P,pt,U):V&&!V.hasOnce&&(H!==ct||j>0&&j&64)?wt(V,_,P,!1,!0):(H===ct&&j&384||!R&&te&16)&&wt(q,_,P),U&&st(y)}(be&&(ge=G&&G.onVnodeUnmounted)||ae)&&Ve(()=>{ge&&Pt(ge,_,y),ae&&$n(y,null,_,"unmounted")},P)},st=y=>{const{type:_,el:P,anchor:U,transition:R}=y;if(_===ct){ze(P,U);return}if(_===Es){f(y);return}const H=()=>{s(P),R&&!R.persisted&&R.afterLeave&&R.afterLeave()};if(y.shapeFlag&1&&R&&!R.persisted){const{leave:G,delayLeave:W}=R,q=()=>G(P,H);W?W(y.el,H,q):q()}else H()},ze=(y,_)=>{let P;for(;y!==_;)P=w(y),s(y),y=P;s(_)},bn=(y,_,P)=>{const{bum:U,scope:R,job:H,subTree:G,um:W,m:q,a:V}=y;la(q),la(V),U&&xs(U),R.stop(),H&&(H.flags|=8,pe(G,y,_,P)),W&&Ve(W,_),Ve(()=>{y.isUnmounted=!0},_)},wt=(y,_,P,U=!1,R=!1,H=0)=>{for(let G=H;G<y.length;G++)pe(y[G],_,P,U,R)},it=y=>{if(y.shapeFlag&6)return it(y.component.subTree);if(y.shapeFlag&128)return y.suspense.next();const _=w(y.anchor||y.el),P=_&&_[Gc];return P?w(P):_};let Pn=!1;const Dt=(y,_,P)=>{let U;y==null?_._vnode&&(pe(_._vnode,null,null,!0),U=_._vnode.component):h(_._vnode||null,y,_,null,null,null,P),_._vnode=y,Pn||(Pn=!0,jo(U),Vc(),Pn=!1)},pt={p:h,um:pe,m:ce,r:st,mt:ee,mc:x,pc:$,pbc:T,n:it,o:t};return{render:Dt,hydrate:void 0,createApp:Nd(Dt)}}function Si({type:t,props:e},n){return n==="svg"&&t==="foreignObject"||n==="mathml"&&t==="annotation-xml"&&e&&e.encoding&&e.encoding.includes("html")?void 0:n}function Ln({effect:t,job:e},n){n?(t.flags|=32,e.flags|=4):(t.flags&=-33,e.flags&=-5)}function Qd(t,e){return(!t||t&&!t.pendingBranch)&&e&&!e.persisted}function Ao(t,e,n=!1){const r=t.children,s=e.children;if(re(r)&&re(s))for(let i=0;i<r.length;i++){const o=r[i];let a=s[i];a.shapeFlag&1&&!a.dynamicChildren&&((a.patchFlag<=0||a.patchFlag===32)&&(a=s[i]=Qt(s[i]),a.el=o.el),!n&&a.patchFlag!==-2&&Ao(o,a)),a.type===oi&&(a.patchFlag===-1&&(a=s[i]=Qt(a)),a.el=o.el),a.type===Bn&&!a.el&&(a.el=o.el)}}function ef(t){const e=t.slice(),n=[0];let r,s,i,o,a;const c=t.length;for(r=0;r<c;r++){const l=t[r];if(l!==0){if(s=n[n.length-1],t[s]<l){e[r]=s,n.push(r);continue}for(i=0,o=n.length-1;i<o;)a=i+o>>1,t[n[a]]<l?i=a+1:o=a;l<t[n[i]]&&(i>0&&(e[r]=n[i-1]),n[i]=r)}}for(i=n.length,o=n[i-1];i-- >0;)n[i]=o,o=e[o];return n}function ll(t){const e=t.subTree.component;if(e)return e.asyncDep&&!e.asyncResolved?e:ll(e)}function la(t){if(t)for(let e=0;e<t.length;e++)t[e].flags|=8}function ul(t){if(t.placeholder)return t.placeholder;const e=t.component;return e?ul(e.subTree):null}const dl=t=>t.__isSuspense;function tf(t,e){e&&e.pendingBranch?re(t)?e.effects.push(...t):e.effects.push(t):sd(t)}const ct=Symbol.for("v-fgt"),oi=Symbol.for("v-txt"),Bn=Symbol.for("v-cmt"),Es=Symbol.for("v-stc"),Wr=[];let ut=null;function ve(t=!1){Wr.push(ut=t?null:[])}function nf(){Wr.pop(),ut=Wr[Wr.length-1]||null}let Zr=1;function ua(t,e=!1){Zr+=t,t<0&&ut&&e&&(ut.hasOnce=!0)}function fl(t){return t.dynamicChildren=Zr>0?ut||ur:null,nf(),Zr>0&&ut&&ut.push(t),t}function Se(t,e,n,r,s,i){return fl(J(t,e,n,r,s,i,!0))}function pl(t,e,n,r,s){return fl(Re(t,e,n,r,s,!0))}function gl(t){return t?t.__v_isVNode===!0:!1}function Ir(t,e){return t.type===e.type&&t.key===e.key}const ml=({key:t})=>t??null,ks=({ref:t,ref_key:e,ref_for:n})=>(typeof t=="number"&&(t=""+t),t!=null?ke(t)||Ee(t)||ie(t)?{i:lt,r:t,k:e,f:!!n}:t:null);function J(t,e=null,n=null,r=0,s=null,i=t===ct?0:1,o=!1,a=!1){const c={__v_isVNode:!0,__v_skip:!0,type:t,props:e,key:e&&ml(e),ref:e&&ks(e),scopeId:qc,slotScopeIds:null,children:n,component:null,suspense:null,ssContent:null,ssFallback:null,dirs:null,transition:null,el:null,anchor:null,target:null,targetStart:null,targetAnchor:null,staticCount:0,shapeFlag:i,patchFlag:r,dynamicProps:s,dynamicChildren:null,appContext:null,ctx:lt};return a?(To(c,n),i&128&&t.normalize(c)):n&&(c.shapeFlag|=ke(n)?8:16),Zr>0&&!o&&ut&&(c.patchFlag>0||i&6)&&c.patchFlag!==32&&ut.push(c),c}const Re=rf;function rf(t,e=null,n=null,r=0,s=null,i=!1){if((!t||t===Xc)&&(t=Bn),gl(t)){const a=wr(t,e,!0);return n&&To(a,n),Zr>0&&!i&&ut&&(a.shapeFlag&6?ut[ut.indexOf(t)]=a:ut.push(a)),a.patchFlag=-2,a}if(mf(t)&&(t=t.__vccOpts),e){e=sf(e);let{class:a,style:c}=e;a&&!ke(a)&&(e.class=Ct(a)),me(c)&&(ri(c)&&!re(c)&&(c=Me({},c)),e.style=ei(c))}const o=ke(t)?1:dl(t)?128:dd(t)?64:me(t)?4:ie(t)?2:0;return J(t,e,n,r,s,o,i,!0)}function sf(t){return t?ri(t)||rl(t)?Me({},t):t:null}function wr(t,e,n=!1,r=!1){const{props:s,ref:i,patchFlag:o,children:a,transition:c}=t,l=e?of(s||{},e):s,u={__v_isVNode:!0,__v_skip:!0,type:t.type,props:l,key:l&&ml(l),ref:e&&e.ref?n&&i?re(i)?i.concat(ks(e)):[i,ks(e)]:ks(e):i,scopeId:t.scopeId,slotScopeIds:t.slotScopeIds,children:a,target:t.target,targetStart:t.targetStart,targetAnchor:t.targetAnchor,staticCount:t.staticCount,shapeFlag:t.shapeFlag,patchFlag:e&&t.type!==ct?o===-1?16:o|16:o,dynamicProps:t.dynamicProps,dynamicChildren:t.dynamicChildren,appContext:t.appContext,dirs:t.dirs,transition:c,component:t.component,suspense:t.suspense,ssContent:t.ssContent&&wr(t.ssContent),ssFallback:t.ssFallback&&wr(t.ssFallback),placeholder:t.placeholder,el:t.el,anchor:t.anchor,ctx:t.ctx,ce:t.ce};return c&&r&&vo(u,c.clone(u)),u}function zr(t=" ",e=0){return Re(oi,null,t,e)}function Uh(t,e){const n=Re(Es,null,t);return n.staticCount=e,n}function As(t="",e=!1){return e?(ve(),pl(Bn,null,t)):Re(Bn,null,t)}function Ht(t){return t==null||typeof t=="boolean"?Re(Bn):re(t)?Re(ct,null,t.slice()):gl(t)?Qt(t):Re(oi,null,String(t))}function Qt(t){return t.el===null&&t.patchFlag!==-1||t.memo?t:wr(t)}function To(t,e){let n=0;const{shapeFlag:r}=t;if(e==null)e=null;else if(re(e))n=16;else if(typeof e=="object")if(r&65){const s=e.default;s&&(s._c&&(s._d=!1),To(t,s()),s._c&&(s._d=!0));return}else{n=32;const s=e._;!s&&!rl(e)?e._ctx=lt:s===3&&lt&&(lt.slots._===1?e._=1:(e._=2,t.patchFlag|=1024))}else ie(e)?(e={default:e,_ctx:lt},n=32):(e=String(e),r&64?(n=16,e=[zr(e)]):n=8);t.children=e,t.shapeFlag|=n}function of(...t){const e={};for(let n=0;n<t.length;n++){const r=t[n];for(const s in r)if(s==="class")e.class!==r.class&&(e.class=Ct([e.class,r.class]));else if(s==="style")e.style=ei([e.style,r.style]);else if(Ks(s)){const i=e[s],o=r[s];o&&i!==o&&!(re(i)&&i.includes(o))&&(e[s]=i?[].concat(i,o):o)}else s!==""&&(e[s]=r[s])}return e}function Pt(t,e,n,r=null){Kt(t,e,7,[n,r])}const af=Zc();let cf=0;function lf(t,e,n){const r=t.type,s=(e?e.appContext:t.appContext)||af,i={uid:cf++,vnode:t,type:r,parent:e,appContext:s,root:null,next:null,subTree:null,effect:null,update:null,job:null,scope:new _c(!0),render:null,proxy:null,exposed:null,exposeProxy:null,withProxy:null,provides:e?e.provides:Object.create(s.provides),ids:e?e.ids:["",0,0],accessCache:null,renderCache:[],components:null,directives:null,propsOptions:il(r,s),emitsOptions:Qc(r,s),emit:null,emitted:null,propsDefaults:ye,inheritAttrs:r.inheritAttrs,ctx:ye,data:ye,props:ye,attrs:ye,slots:ye,refs:ye,setupState:ye,setupContext:null,suspense:n,suspenseId:n?n.pendingId:0,asyncDep:null,asyncResolved:!1,isMounted:!1,isUnmounted:!1,isDeactivated:!1,bc:null,c:null,bm:null,m:null,bu:null,u:null,um:null,bum:null,da:null,a:null,rtg:null,rtc:null,ec:null,sp:null};return i.ctx={_:i},i.root=e?e.root:i,i.emit=Ud.bind(null,i),t.ce&&t.ce(i),i}let Le=null;const hl=()=>Le||lt;let Hs,Wi;{const t=Qs(),e=(n,r)=>{let s;return(s=t[n])||(s=t[n]=[]),s.push(r),i=>{s.length>1?s.forEach(o=>o(i)):s[0](i)}};Hs=e("__VUE_INSTANCE_SETTERS__",n=>Le=n),Wi=e("__VUE_SSR_SETTERS__",n=>vr=n)}const cs=t=>{const e=Le;return Hs(t),t.scope.on(),()=>{t.scope.off(),Hs(e)}},da=()=>{Le&&Le.scope.off(),Hs(null)};function yl(t){return t.vnode.shapeFlag&4}let vr=!1;function uf(t,e=!1,n=!1){e&&Wi(e);const{props:r,children:s}=t.vnode,i=yl(t);zd(t,r,i,e),Xd(t,s,n||e);const o=i?df(t,e):void 0;return e&&Wi(!1),o}function df(t,e){const n=t.type;t.accessCache=Object.create(null),t.proxy=new Proxy(t.ctx,Bd);const{setup:r}=n;if(r){fn();const s=t.setupContext=r.length>1?pf(t):null,i=cs(t),o=os(r,t,0,[t.props,s]),a=gc(o);if(pn(),i(),(a||t.sp)&&!Fr(t)&&_o(t),a){if(o.then(da,da),e)return o.then(c=>{fa(t,c)}).catch(c=>{as(c,t,0)});t.asyncDep=o}else fa(t,o)}else bl(t)}function fa(t,e,n){ie(e)?t.type.__ssrInlineRender?t.ssrRender=e:t.render=e:me(e)&&(t.setupState=Mc(e)),bl(t)}function bl(t,e,n){const r=t.type;t.render||(t.render=r.render||Wt);{const s=cs(t);fn();try{Id(t)}finally{pn(),s()}}}const ff={get(t,e){return qe(t,"get",""),t[e]}};function pf(t){const e=n=>{t.exposed=n||{}};return{attrs:new Proxy(t.attrs,ff),slots:t.slots,emit:t.emit,expose:e}}function ai(t){return t.exposed?t.exposeProxy||(t.exposeProxy=new Proxy(Mc(yo(t.exposed)),{get(e,n){if(n in e)return e[n];if(n in qr)return qr[n](t)},has(e,n){return n in e||n in qr}})):t.proxy}function gf(t,e=!0){return ie(t)?t.displayName||t.name:t.name||e&&t.__name}function mf(t){return ie(t)&&"__vccOpts"in t}const B=(t,e)=>Qu(t,e,vr),hf="3.5.29";/**
* @vue/runtime-dom v3.5.29
* (c) 2018-present Yuxi (Evan) You and Vue contributors
* @license MIT
**/let zi;const pa=typeof window<"u"&&window.trustedTypes;if(pa)try{zi=pa.createPolicy("vue",{createHTML:t=>t})}catch{}const wl=zi?t=>zi.createHTML(t):t=>t,yf="http://www.w3.org/2000/svg",bf="http://www.w3.org/1998/Math/MathML",Jt=typeof document<"u"?document:null,ga=Jt&&Jt.createElement("template"),wf={insert:(t,e,n)=>{e.insertBefore(t,n||null)},remove:t=>{const e=t.parentNode;e&&e.removeChild(t)},createElement:(t,e,n,r)=>{const s=e==="svg"?Jt.createElementNS(yf,t):e==="mathml"?Jt.createElementNS(bf,t):n?Jt.createElement(t,{is:n}):Jt.createElement(t);return t==="select"&&r&&r.multiple!=null&&s.setAttribute("multiple",r.multiple),s},createText:t=>Jt.createTextNode(t),createComment:t=>Jt.createComment(t),setText:(t,e)=>{t.nodeValue=e},setElementText:(t,e)=>{t.textContent=e},parentNode:t=>t.parentNode,nextSibling:t=>t.nextSibling,querySelector:t=>Jt.querySelector(t),setScopeId(t,e){t.setAttribute(e,"")},insertStaticContent(t,e,n,r,s,i){const o=n?n.previousSibling:e.lastChild;if(s&&(s===i||s.nextSibling))for(;e.insertBefore(s.cloneNode(!0),n),!(s===i||!(s=s.nextSibling)););else{ga.innerHTML=wl(r==="svg"?`<svg>${t}</svg>`:r==="mathml"?`<math>${t}</math>`:t);const a=ga.content;if(r==="svg"||r==="mathml"){const c=a.firstChild;for(;c.firstChild;)a.appendChild(c.firstChild);a.removeChild(c)}e.insertBefore(a,n)}return[o?o.nextSibling:e.firstChild,n?n.previousSibling:e.lastChild]}},vf=Symbol("_vtc");function _f(t,e,n){const r=t[vf];r&&(e=(e?[e,...r]:[...r]).join(" ")),e==null?t.removeAttribute("class"):n?t.setAttribute("class",e):t.className=e}const Vs=Symbol("_vod"),vl=Symbol("_vsh"),Hh={name:"show",beforeMount(t,{value:e},{transition:n}){t[Vs]=t.style.display==="none"?"":t.style.display,n&&e?n.beforeEnter(t):Or(t,e)},mounted(t,{value:e},{transition:n}){n&&e&&n.enter(t)},updated(t,{value:e,oldValue:n},{transition:r}){!e!=!n&&(r?e?(r.beforeEnter(t),Or(t,!0),r.enter(t)):r.leave(t,()=>{Or(t,!1)}):Or(t,e))},beforeUnmount(t,{value:e}){Or(t,e)}};function Or(t,e){t.style.display=e?t[Vs]:"none",t[vl]=!e}const xf=Symbol(""),Cf=/(?:^|;)\s*display\s*:/;function Sf(t,e,n){const r=t.style,s=ke(n);let i=!1;if(n&&!s){if(e)if(ke(e))for(const o of e.split(";")){const a=o.slice(0,o.indexOf(":")).trim();n[a]==null&&Ts(r,a,"")}else for(const o in e)n[o]==null&&Ts(r,o,"");for(const o in n)o==="display"&&(i=!0),Ts(r,o,n[o])}else if(s){if(e!==n){const o=r[xf];o&&(n+=";"+o),r.cssText=n,i=Cf.test(n)}}else e&&t.removeAttribute("style");Vs in t&&(t[Vs]=i?r.display:"",t[vl]&&(r.display="none"))}const ma=/\s*!important$/;function Ts(t,e,n){if(re(n))n.forEach(r=>Ts(t,e,r));else if(n==null&&(n=""),e.startsWith("--"))t.setProperty(e,n);else{const r=Ef(t,e);ma.test(n)?t.setProperty(In(r),n.replace(ma,""),"important"):t[r]=n}}const ha=["Webkit","Moz","ms"],Ei={};function Ef(t,e){const n=Ei[e];if(n)return n;let r=bt(e);if(r!=="filter"&&r in t)return Ei[e]=r;r=Ys(r);for(let s=0;s<ha.length;s++){const i=ha[s]+r;if(i in t)return Ei[e]=i}return e}const ya="http://www.w3.org/1999/xlink";function ba(t,e,n,r,s,i=xu(e)){r&&e.startsWith("xlink:")?n==null?t.removeAttributeNS(ya,e.slice(6,e.length)):t.setAttributeNS(ya,e,n):n==null||i&&!bc(n)?t.removeAttribute(e):t.setAttribute(e,i?"":Gt(n)?String(n):n)}function wa(t,e,n,r,s){if(e==="innerHTML"||e==="textContent"){n!=null&&(t[e]=e==="innerHTML"?wl(n):n);return}const i=t.tagName;if(e==="value"&&i!=="PROGRESS"&&!i.includes("-")){const a=i==="OPTION"?t.getAttribute("value")||"":t.value,c=n==null?t.type==="checkbox"?"on":"":String(n);(a!==c||!("_value"in t))&&(t.value=c),n==null&&t.removeAttribute(e),t._value=n;return}let o=!1;if(n===""||n==null){const a=typeof t[e];a==="boolean"?n=bc(n):n==null&&a==="string"?(n="",o=!0):a==="number"&&(n=0,o=!0)}try{t[e]=n}catch{}o&&t.removeAttribute(s||e)}function En(t,e,n,r){t.addEventListener(e,n,r)}function kf(t,e,n,r){t.removeEventListener(e,n,r)}const va=Symbol("_vei");function Af(t,e,n,r,s=null){const i=t[va]||(t[va]={}),o=i[e];if(r&&o)o.value=r;else{const[a,c]=Tf(e);if(r){const l=i[e]=If(r,s);En(t,a,l,c)}else o&&(kf(t,a,o,c),i[e]=void 0)}}const _a=/(?:Once|Passive|Capture)$/;function Tf(t){let e;if(_a.test(t)){e={};let r;for(;r=t.match(_a);)t=t.slice(0,t.length-r[0].length),e[r[0].toLowerCase()]=!0}return[t[2]===":"?t.slice(3):In(t.slice(2)),e]}let ki=0;const Df=Promise.resolve(),Bf=()=>ki||(Df.then(()=>ki=0),ki=Date.now());function If(t,e){const n=r=>{if(!r._vts)r._vts=Date.now();else if(r._vts<=n.attached)return;Kt(Of(r,n.value),e,5,[r])};return n.value=t,n.attached=Bf(),n}function Of(t,e){if(re(e)){const n=t.stopImmediatePropagation;return t.stopImmediatePropagation=()=>{n.call(t),t._stopped=!0},e.map(r=>s=>!s._stopped&&r&&r(s))}else return e}const xa=t=>t.charCodeAt(0)===111&&t.charCodeAt(1)===110&&t.charCodeAt(2)>96&&t.charCodeAt(2)<123,Pf=(t,e,n,r,s,i)=>{const o=s==="svg";e==="class"?_f(t,r,o):e==="style"?Sf(t,n,r):Ks(e)?co(e)||Af(t,e,n,r,i):(e[0]==="."?(e=e.slice(1),!0):e[0]==="^"?(e=e.slice(1),!1):$f(t,e,r,o))?(wa(t,e,r),!t.tagName.includes("-")&&(e==="value"||e==="checked"||e==="selected")&&ba(t,e,r,o,i,e!=="value")):t._isVueCE&&(/[A-Z]/.test(e)||!ke(r))?wa(t,bt(e),r,i,e):(e==="true-value"?t._trueValue=r:e==="false-value"&&(t._falseValue=r),ba(t,e,r,o))};function $f(t,e,n,r){if(r)return!!(e==="innerHTML"||e==="textContent"||e in t&&xa(e)&&ie(n));if(e==="spellcheck"||e==="draggable"||e==="translate"||e==="autocorrect"||e==="sandbox"&&t.tagName==="IFRAME"||e==="form"||e==="list"&&t.tagName==="INPUT"||e==="type"&&t.tagName==="TEXTAREA")return!1;if(e==="width"||e==="height"){const s=t.tagName;if(s==="IMG"||s==="VIDEO"||s==="CANVAS"||s==="SOURCE")return!1}return xa(e)&&ke(n)?!1:e in t}const _r=t=>{const e=t.props["onUpdate:modelValue"]||!1;return re(e)?n=>xs(e,n):e};function Lf(t){t.target.composing=!0}function Ca(t){const e=t.target;e.composing&&(e.composing=!1,e.dispatchEvent(new Event("input")))}const ln=Symbol("_assign");function Sa(t,e,n){return e&&(t=t.trim()),n&&(t=Zs(t)),t}const Vh={created(t,{modifiers:{lazy:e,trim:n,number:r}},s){t[ln]=_r(s);const i=r||s.props&&s.props.type==="number";En(t,e?"change":"input",o=>{o.target.composing||t[ln](Sa(t.value,n,i))}),(n||i)&&En(t,"change",()=>{t.value=Sa(t.value,n,i)}),e||(En(t,"compositionstart",Lf),En(t,"compositionend",Ca),En(t,"change",Ca))},mounted(t,{value:e}){t.value=e??""},beforeUpdate(t,{value:e,oldValue:n,modifiers:{lazy:r,trim:s,number:i}},o){if(t[ln]=_r(o),t.composing)return;const a=(i||t.type==="number")&&!/^0\d/.test(t.value)?Zs(t.value):t.value,c=e??"";a!==c&&(document.activeElement===t&&t.type!=="range"&&(r&&e===n||s&&t.value.trim()===c)||(t.value=c))}},Fh={created(t,{value:e},n){t.checked=Zn(e,n.props.value),t[ln]=_r(n),En(t,"change",()=>{t[ln](Qr(t))})},beforeUpdate(t,{value:e,oldValue:n},r){t[ln]=_r(r),e!==n&&(t.checked=Zn(e,r.props.value))}},qh={deep:!0,created(t,{value:e,modifiers:{number:n}},r){const s=js(e);En(t,"change",()=>{const i=Array.prototype.filter.call(t.options,o=>o.selected).map(o=>n?Zs(Qr(o)):Qr(o));t[ln](t.multiple?s?new Set(i):i:i[0]),t._assigning=!0,bo(()=>{t._assigning=!1})}),t[ln]=_r(r)},mounted(t,{value:e}){Ea(t,e)},beforeUpdate(t,e,n){t[ln]=_r(n)},updated(t,{value:e}){t._assigning||Ea(t,e)}};function Ea(t,e){const n=t.multiple,r=re(e);if(!(n&&!r&&!js(e))){for(let s=0,i=t.options.length;s<i;s++){const o=t.options[s],a=Qr(o);if(n)if(r){const c=typeof a;c==="string"||c==="number"?o.selected=e.some(l=>String(l)===String(a)):o.selected=Su(e,a)>-1}else o.selected=e.has(a);else if(Zn(Qr(o),e)){t.selectedIndex!==s&&(t.selectedIndex=s);return}}!n&&t.selectedIndex!==-1&&(t.selectedIndex=-1)}}function Qr(t){return"_value"in t?t._value:t.value}const Rf=["ctrl","shift","alt","meta"],Nf={stop:t=>t.stopPropagation(),prevent:t=>t.preventDefault(),self:t=>t.target!==t.currentTarget,ctrl:t=>!t.ctrlKey,shift:t=>!t.shiftKey,alt:t=>!t.altKey,meta:t=>!t.metaKey,left:t=>"button"in t&&t.button!==0,middle:t=>"button"in t&&t.button!==1,right:t=>"button"in t&&t.button!==2,exact:(t,e)=>Rf.some(n=>t[`${n}Key`]&&!e.includes(n))},Mf=(t,e)=>{if(!t)return t;const n=t._withMods||(t._withMods={}),r=e.join(".");return n[r]||(n[r]=(s,...i)=>{for(let o=0;o<e.length;o++){const a=Nf[e[o]];if(a&&a(s,e))return}return t(s,...i)})},Uf={esc:"escape",space:" ",up:"arrow-up",left:"arrow-left",right:"arrow-right",down:"arrow-down",delete:"backspace"},Wh=(t,e)=>{const n=t._withKeys||(t._withKeys={}),r=e.join(".");return n[r]||(n[r]=s=>{if(!("key"in s))return;const i=In(s.key);if(e.some(o=>o===i||Uf[o]===i))return t(s)})},Hf=Me({patchProp:Pf},wf);let ka;function Vf(){return ka||(ka=Yd(Hf))}const Ff=(...t)=>{const e=Vf().createApp(...t),{mount:n}=e;return e.mount=r=>{const s=Wf(r);if(!s)return;const i=e._component;!ie(i)&&!i.render&&!i.template&&(i.template=s.innerHTML),s.nodeType===1&&(s.textContent="");const o=n(s,!1,qf(s));return s instanceof Element&&(s.removeAttribute("v-cloak"),s.setAttribute("data-v-app","")),o},e};function qf(t){if(t instanceof SVGElement)return"svg";if(typeof MathMLElement=="function"&&t instanceof MathMLElement)return"mathml"}function Wf(t){return ke(t)?document.querySelector(t):t}/*!
 * pinia v3.0.4
 * (c) 2025 Eduardo San Martin Morote
 * @license MIT
 */let _l;const ci=t=>_l=t,xl=Symbol();function Gi(t){return t&&typeof t=="object"&&Object.prototype.toString.call(t)==="[object Object]"&&typeof t.toJSON!="function"}var Gr;(function(t){t.direct="direct",t.patchObject="patch object",t.patchFunction="patch function"})(Gr||(Gr={}));function zf(){const t=xc(!0),e=t.run(()=>F({}));let n=[],r=[];const s=yo({install(i){ci(s),s._a=i,i.provide(xl,s),i.config.globalProperties.$pinia=s,r.forEach(o=>n.push(o)),r=[]},use(i){return this._a?n.push(i):r.push(i),this},_p:n,_a:null,_e:t,_s:new Map,state:e});return s}const Cl=()=>{};function Aa(t,e,n,r=Cl){t.add(e);const s=()=>{t.delete(e)&&r()};return!n&&Cc()&&Eu(s),s}function rr(t,...e){t.forEach(n=>{n(...e)})}const Gf=t=>t(),Ta=Symbol(),Ai=Symbol();function Ki(t,e){t instanceof Map&&e instanceof Map?e.forEach((n,r)=>t.set(r,n)):t instanceof Set&&e instanceof Set&&e.forEach(t.add,t);for(const n in e){if(!e.hasOwnProperty(n))continue;const r=e[n],s=t[n];Gi(s)&&Gi(r)&&t.hasOwnProperty(n)&&!Ee(r)&&!cn(r)?t[n]=Ki(s,r):t[n]=r}return t}const Kf=Symbol();function jf(t){return!Gi(t)||!Object.prototype.hasOwnProperty.call(t,Kf)}const{assign:_n}=Object;function Xf(t){return!!(Ee(t)&&t.effect)}function Jf(t,e,n,r){const{state:s,actions:i,getters:o}=e,a=n.state.value[t];let c;function l(){a||(n.state.value[t]=s?s():{});const u=Xu(n.state.value[t]);return _n(u,i,Object.keys(o||{}).reduce((d,w)=>(d[w]=yo(B(()=>{ci(n);const m=n._s.get(t);return o[w].call(m,m)})),d),{}))}return c=Sl(t,l,e,n,r,!0),c}function Sl(t,e,n={},r,s,i){let o;const a=_n({actions:{}},n),c={deep:!0};let l,u,d=new Set,w=new Set,m;const S=r.state.value[t];!i&&!S&&(r.state.value[t]={});let h;function D(x){let g;l=u=!1,typeof x=="function"?(x(r.state.value[t]),g={type:Gr.patchFunction,storeId:t,events:m}):(Ki(r.state.value[t],x),g={type:Gr.patchObject,payload:x,storeId:t,events:m});const T=h=Symbol();bo().then(()=>{h===T&&(l=!0)}),u=!0,rr(d,g,r.state.value[t])}const I=i?function(){const{state:g}=n,T=g?g():{};this.$patch(A=>{_n(A,T)})}:Cl;function b(){o.stop(),d.clear(),w.clear(),r._s.delete(t)}const C=(x,g="")=>{if(Ta in x)return x[Ai]=g,x;const T=function(){ci(r);const A=Array.from(arguments),L=new Set,K=new Set;function ee(E){L.add(E)}function M(E){K.add(E)}rr(w,{args:A,name:T[Ai],store:p,after:ee,onError:M});let O;try{O=x.apply(this&&this.$id===t?this:p,A)}catch(E){throw rr(K,E),E}return O instanceof Promise?O.then(E=>(rr(L,E),E)).catch(E=>(rr(K,E),Promise.reject(E))):(rr(L,O),O)};return T[Ta]=!0,T[Ai]=g,T},f={_p:r,$id:t,$onAction:Aa.bind(null,w),$patch:D,$reset:I,$subscribe(x,g={}){const T=Aa(d,x,g.detached,()=>A()),A=o.run(()=>Cs(()=>r.state.value[t],L=>{(g.flush==="sync"?u:l)&&x({storeId:t,type:Gr.direct,events:m},L)},_n({},c,g)));return T},$dispose:b},p=ni(f);r._s.set(t,p);const k=(r._a&&r._a.runWithContext||Gf)(()=>r._e.run(()=>(o=xc()).run(()=>e({action:C}))));for(const x in k){const g=k[x];if(Ee(g)&&!Xf(g)||cn(g))i||(S&&jf(g)&&(Ee(g)?g.value=S[x]:Ki(g,S[x])),r.state.value[t][x]=g);else if(typeof g=="function"){const T=C(g,x);k[x]=T,a.actions[x]=g}}return _n(p,k),_n(ue(p),k),Object.defineProperty(p,"$state",{get:()=>r.state.value[t],set:x=>{D(g=>{_n(g,x)})}}),r._p.forEach(x=>{_n(p,o.run(()=>x({store:p,app:r._a,pinia:r,options:a})))}),S&&i&&n.hydrate&&n.hydrate(p.$state,S),l=!0,u=!0,p}/*! #__NO_SIDE_EFFECTS__ */function Do(t,e,n){let r;const s=typeof e=="function";r=s?n:e;function i(o,a){const c=ad();return o=o||(c?Ur(xl,null):null),o&&ci(o),o=_l,o._s.has(t)||(s?Sl(t,e,r,o):Jf(t,r,o)),o._s.get(t)}return i.$id=t,i}const xr={1:{title:"Day 1 - 点击计数器",subtitle:"点击计数器/ClickCounter",concepts:["function","increment","uint256","contract"]},2:{title:"Day 2 - 保存名字",subtitle:"保存名字/SaveMyName",concepts:["string","private","memory","view","parameters","returns"]},3:{title:"Day 3 - 投票站",subtitle:"投票站/PollStation",concepts:["array","mapping","push","compound_assignment"]},4:{title:"Day 4 - 拍卖行",subtitle:"拍卖行/AuctionHouse",concepts:["constructor","msg_sender","block_timestamp","require","external","address_type","bool_type"]},5:{title:"Day 5 - 管理员权限",subtitle:"管理员权限/AdminOnly",concepts:["modifier","zero_address","return_statement"]},6:{title:"Day 6 - 以太坊银行",subtitle:"以太坊银行/EtherPiggyBank",concepts:["address_mapping_balance","payable","msg_value","wei_unit","ether_deposit_withdraw"]},7:{title:"Day 7 - 朋友借条",subtitle:"朋友借条/SimpleIOU",concepts:["nested_mapping","address_payable","debt_tracking","internal_transfer","transfer_method","call_method","withdraw_pattern"]},8:{title:"Day 8 - 打赏罐",subtitle:"打赏罐/TipJar",concepts:["modifier_onlyOwner","payable_tip","msg_value_tip","address_balance","call_withdraw","mapping_rates"]},9:{title:"Day 9 - 跨合约调用",subtitle:"跨合约调用/InterContract",concepts:["pure_function","view_function","cross_contract_call","interface_call","low_level_call","modifier_onlyOwner","newton_iteration","contract_composition"]},10:{title:"Day 10 - 健身追踪器",subtitle:"健身追踪器/ActivityTracker",concepts:["struct_definition","array_in_mapping","multiple_mappings","storage_keyword","event_logging","milestone_detection","timestamp_usage","onlyRegistered_modifier"]},11:{title:"Day 11 - 主密钥保险库",subtitle:"合约继承与所有权/MasterkeyVault",concepts:["inheritance","import_statement","constructor","private_visibility","event_logging","indexed_parameter","transfer_ownership","onlyOwner_modifier"]},12:{title:"Day 12 - ERC20 代币标准",subtitle:"ERC20代币/Web3Compass",concepts:["erc20_standard","mapping_nested","event","transfer","approve","allowance","transferFrom"]},13:{title:"Day 13 - MyToken 代币扩展",subtitle:"ERC20进阶/Virtual & Inheritance",concepts:["constructor_mint","zero_address_mint","internal_function","virtual_function"]},14:{title:"Day 14 - 安全存款盒",subtitle:"抽象合约、接口与工厂模式/Abstract, Interface & Factory",concepts:["interface_definition","abstract_contract","inheritance","override_keyword","virtual_function","super_keyword","modifier_combination","factory_pattern","metadata_storage","time_lock"]},15:{title:"Day 15 - Gas优化投票",subtitle:"高效节能投票/GasEfficientVoting",concepts:["compact_datatype","uint8_uint32","bytes32_string","storage_optimization","bit_operation","mapping_storage","mask_check","timestamp_block","event_logging"]},16:{title:"Day 16 - 插件存储系统",subtitle:"动态插件注册与低级别调用/PluginStore",concepts:["struct_definition","mapping_storage","plugin_registration","low_level_call","abi_encoding","staticcall","dynamic_delegation","contract_interop"]},17:{title:"Day 17",subtitle:"可升级合约/UpgradeHub",concepts:["proxy_pattern","delegatecall","storage_layout","upgrade_mechanism","logic_contract","fallback_function","data_persistence","version_control"]},18:{title:"Day 18 - 预言机与参数保险",subtitle:"预言机/OracleContract",concepts:["oracle_interface","eth_usd_oracle","random_generation","purchase_insurance","price_conversion","parametric_payout","cooldown_mechanism","contract_balance"]},19:{title:"Day 19 - 基于签名的活动参与",subtitle:"ECDSA签名验证/SignThis",concepts:["keccak256_hash","ecdsa_signature","signature_rsv","eip191_prefix","ecrecover","require_statement","mapping_storage","msg_sender"]},20:{title:"Day 20 - 重入攻击与防护",subtitle:"Reentrancy Attack & Protection",concepts:["reentrancy_attack","fallback_receive","vulnerable_withdraw","deposit_function","checks_effects_interactions","reentrancy_guard","contract_balance","code_comparison"]}},zh=t=>t===1?`//SPDx-License-Identifier:MIT

// 声明Solidity版本，要求编译器版本在0.8.0或更高（但低于0.9.0）
pragma solidity ^0.8.0;

// 定义一个名为clickcounter的合约（相当于其他语言中的类）
contract clickcounter {
    // 声明一个无符号256位整数类型的状态变量counter
    // public关键字表示这个变量可以被外部访问，编译器会自动生成getter函数
    uint256 public counter;

    // 定义一个名为click的公共函数
    // public表示任何人都可以调用这个函数
    function click() public {
        // 将counter的值加1（自增操作）
        counter++;
    }
}`:t===2?`// SPDX-License-Identifier:MIT

// 声明Solidity版本，要求编译器版本在0.8.0或更高（但低于0.9.0）
pragma solidity ^0.8.0;

// 定义一个名为SaveMyName的合约，用于存储和检索姓名与简介
contract SaveMyName{
     
  // 声明一个字符串类型的私有状态变量name（默认私有）
  string name;
  
  // 声明一个字符串类型的私有状态变量bio（默认私有）
  string bio;

  // 定义一个名为add的公共函数，用于设置姓名和简介
  // memory关键字表示参数数据存储在内存中（临时存储）
  // _name 和 _bio 是函数参数（参数名通常用下划线前缀表示）
  function add (string memory _name, string memory _bio )public {
    // 将传入的_name值赋给状态变量name
    name = _name;
    
    // 将传入的_bio值赋给状态变量bio
    bio = _bio;
  }

  // 定义一个名为retrieve的公共函数，用于获取姓名和简介
  // view关键字表示该函数只读取状态变量，不修改任何状态（不消耗gas）
  // returns声明返回值类型为两个字符串
  function retrieve() public view returns(string memory, string memory){
    // 返回name和bio的值（以元组形式返回多个值）
    return (name,bio);
  }

}`:t===3?`// SPDX-License-Identifier:MIT

// 声明Solidity版本，要求编译器版本在0.8.0或更高（但低于0.9.0）
pragma solidity ^0.8.0;

// 定义一个名为PollStation的合约，用于管理投票
contract PollStation{
    // 声明一个公共字符串数组，用于存储候选人姓名
    // public关键字表示外部可以访问，编译器会自动生成getter函数
    string[] public candidateNames;
    
    // 声明一个映射，用于存储每个候选人的得票数
    // 映射类型：键是字符串（候选人姓名），值是uint256（票数）
    mapping(string => uint256) voteCount;

    // 定义一个名为addCandidateNames的公共函数，用于添加候选人
    // memory关键字表示参数数据存储在内存中（临时存储）
    function addCandidateNames(string memory _candidateNames) public{
        // 使用push方法将候选人姓名添加到数组末尾
        candidateNames.push(_candidateNames);
        
        // 初始化该候选人的票数为0
        voteCount[_candidateNames] = 0;
    }

    // 定义一个名为vote的公共函数，用于投票
    function vote(string memory _candidateNames) public{
        // 使用复合赋值运算符+=，将指定候选人的票数加1
        // 等同于：voteCount[_candidateNames] = voteCount[_candidateNames] + 1;
        voteCount[_candidateNames] += 1;
    }

    // 定义一个名为getVoteCount的公共视图函数，用于获取候选人的票数
    // view关键字表示该函数只读取状态变量，不修改任何状态（不消耗gas）
    function getVoteCount(string memory _candidateNames) public view returns (uint256){
        // 返回指定候选人的票数
        return voteCount[_candidateNames];
    }
}`:t===4?`// SPDX-License-Identifier: MIT
// 声明Solidity版本，要求编译器版本在0.8.0或更高（但低于0.9.0）
pragma solidity ^0.8.0;

// 定义一个名为AuctionHouse的合约，用于拍卖行功能
contract AuctionHouse {
    // 声明公共地址变量，存储拍卖行的所有者地址
    address public owner;
    
    // 声明公共字符串变量，存储拍卖物品的名称
    string public item;
    
    // 声明公共无符号整数，存储拍卖结束时间戳
    uint public auctionEndTime;
    
    // 声明私有地址变量，存储最高出价者的地址
    // private 表示只能在这个合约内部访问，外部无法直接读取
    address private highestBidder; // 获胜者是私有的，可以通过getWinner函数访问
    
    // 声明私有无符号整数，存储最高出价金额
    uint private highestBid;       // 最高出价是私有的，可以通过getWinner函数访问
    
    // 声明公共布尔变量，标记拍卖是否已结束
    bool public ended;

    // 声明映射，存储每个地址（竞拍者）的出价金额
    // 键是地址类型，值是无符号整数
    mapping(address => uint) public bids;
    
    // 声明地址数组，存储所有参与竞拍的地址
    address[] public bidders;

    // 构造函数：在合约部署时执行一次，用于初始化合约状态
    // 参数：_item是拍卖物品名称，_biddingTime是拍卖持续时间（秒）
    constructor(string memory _item, uint _biddingTime) {
        // 将部署合约的地址（发送者）设置为所有者
        owner = msg.sender;
        
        // 设置拍卖物品名称
        item = _item;
        
        // 设置拍卖结束时间：当前区块时间戳 + 拍卖持续时间
        // block.timestamp 是当前区块的时间戳（Unix时间，秒）
        auctionEndTime = block.timestamp + _biddingTime;
    }

    // 允许用户出价的函数
    // external 表示函数只能从合约外部调用（比public更省gas）
    function bid(uint amount) external {
        // require是条件检查函数，如果条件为false则回滚交易并显示错误信息
        // 检查当前时间是否早于拍卖结束时间，确保拍卖未结束
        require(block.timestamp < auctionEndTime, "Auction has already ended.");
        
        // 检查出价金额是否大于0
        require(amount > 0, "Bid amount must be greater than zero.");
        
        // 检查新出价是否高于该竞拍者当前的出价
        require(amount > bids[msg.sender], "New bid must be higher than your current bid.");

        // 如果该竞拍者之前没有出价（出价为0），则将其添加到竞拍者数组
        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }

        // 更新该竞拍者的出价金额
        bids[msg.sender] = amount;

        // 如果新出价高于当前最高出价，则更新最高出价和最高出价者
        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }

    // 结束拍卖的函数（只能在拍卖时间结束后调用）
    function endAuction() external {
        // 检查当前时间是否已达到或超过拍卖结束时间
        require(block.timestamp >= auctionEndTime, "Auction hasn't ended yet.");
        
        // 检查拍卖是否已经结束（防止重复调用）
        require(!ended, "Auction end already called.");

        // 将ended标记设置为true，表示拍卖已结束
        ended = true;
    }

    // 获取所有竞拍者列表的函数
    function getAllBidders() external view returns (address[] memory) {
        // 返回竞拍者地址数组
        return bidders;
    }

    // 获取拍卖获胜者和其出价的函数（仅在拍卖结束后可调用）
    function getWinner() external view returns (address, uint) {
        // 检查拍卖是否已结束
        require(ended, "Auction has not ended yet.");
        
        // 返回最高出价者的地址和最高出价金额
        return (highestBidder, highestBid);
    }
}`:t===5?`// SPDX-License-Identifier: MIT
// 声明Solidity版本，要求编译器版本在0.8.0或更高（但低于0.9.0）
pragma solidity ^0.8.0;

// 定义一个名为AdminOnly的合约，用于管理员权限控制的宝库管理
contract AdminOnly {
    // 状态变量区域
    
    // 声明公共地址变量，存储合约所有者的地址
    address public owner;
    
    // 声明公共无符号整数，存储宝库中的宝藏数量
    uint256 public treasureAmount;
    
    // 声明映射，存储每个地址的提款额度
    // 键是地址，值是该地址允许提取的宝藏数量
    mapping(address => uint256) public withdrawalAllowance;
    
    // 声明映射，记录每个地址是否已经提取过宝藏
    // 键是地址，值是布尔值（true表示已提取，false表示未提取）
    mapping(address => bool) public hasWithdrawn;
    
    // 构造函数：合约部署时执行一次，将部署者设置为所有者
    constructor() {
        owner = msg.sender;
    }
    
    // 修饰符：用于限制只有所有者才能调用某些函数
    // modifier 可以理解为函数的"前置条件检查"
    modifier onlyOwner() {
        // 检查调用者是否为所有者，如果不是则回滚交易并显示错误信息
        require(msg.sender == owner, "Access denied: Only the owner can perform this action");
        
        // _; 表示执行修饰符后的函数体
        // 这是修饰符的语法，表示"通过检查后，继续执行被修饰的函数"
        _;
    }
    
    // 添加宝藏函数：只有所有者可以调用
    // onlyOwner 修饰符确保只有所有者能执行此函数
    function addTreasure(uint256 amount) public onlyOwner {
        // 将指定数量的宝藏添加到宝库中
        treasureAmount += amount;
    }
    
    // 批准提款函数：只有所有者可以调用，用于给用户分配提款额度
    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner {
        // 检查批准的额度是否不超过宝库中现有的宝藏数量
        require(amount <= treasureAmount, "Not enough treasure available");
        
        // 为指定地址设置提款额度
        withdrawalAllowance[recipient] = amount;
    }
    
    
    // 提取宝藏函数：任何人都可以调用，但只有有额度且未提取过的用户才能成功
    function withdrawTreasure(uint256 amount) public {

        // 如果调用者是所有者，允许直接提取任意数量（在宝库范围内）
        if(msg.sender == owner){
            // 检查提取数量是否不超过宝库现有数量
            require(amount <= treasureAmount, "Not enough treasury available for this action.");
            
            // 从宝库中扣除指定数量的宝藏
            treasureAmount-= amount;

            // 直接返回，不执行后面的普通用户提款逻辑
            return;
        }
        
        // 获取调用者的提款额度
        uint256 allowance = withdrawalAllowance[msg.sender];
        
        // 检查用户是否有提款额度（额度必须大于0）
        require(allowance > 0, "You don't have any treasure allowance");
        
        // 检查用户是否已经提取过宝藏（不能重复提取）
        require(!hasWithdrawn[msg.sender], "You have already withdrawn your treasure");
        
        // 检查宝库中是否有足够的宝藏
        require(allowance <= treasureAmount, "Not enough treasure in the chest");
        
        // 检查用户尝试提取的数量是否不超过其允许的额度
        require(allowance >= amount, "Cannot withdraw more than you are allowed");
        
        // 标记该用户已经提取过宝藏
        hasWithdrawn[msg.sender] = true;
        
        // 从宝库中扣除用户额度对应的宝藏数量
        treasureAmount -= allowance;
        
        // 将用户的提款额度清零
        withdrawalAllowance[msg.sender] = 0;
        
    }
    
    // 重置提款状态函数：只有所有者可以调用，用于重置某个用户的提款状态
    function resetWithdrawalStatus(address user) public onlyOwner {
        // 将指定用户的提款状态重置为false（允许再次提取）
        hasWithdrawn[user] = false;
    }
    
    // 转移所有权函数：只有所有者可以调用，用于将合约所有权转移给新所有者
    function transferOwnership(address newOwner) public onlyOwner {
        // 检查新所有者地址是否有效（不能是零地址）
        // address(0) 表示零地址，是一个无效的地址
        require(newOwner != address(0), "Invalid address");
        
        // 将所有者更新为新地址
        owner = newOwner;
    }
    
    // 获取宝藏详情函数：只有所有者可以调用，查看宝库中的宝藏数量
    function getTreasureDetails() public view onlyOwner returns (uint256) {
        // 返回宝库中的宝藏数量
        return treasureAmount;
    }
}`:t===6?`// SPDX-License-Identifier: MIT

// 声明Solidity版本，要求编译器版本在0.8.0或更高（但低于0.9.0）
pragma solidity ^0.8.0;

// 定义一个名为EtherPiggyBank的合约，用于以太坊存钱罐银行功能
contract EtherPiggyBank{

    // 状态变量区域
    
    // 声明银行管理员的地址
    // 银行管理员具有特殊权限，可以添加新成员
    address public bankManager;
    
    // 声明地址数组，存储所有已注册的会员地址
    address[] members;
    
    // 声明映射，记录每个地址是否已注册为会员
    // 键是地址，值是布尔值（true表示已注册，false表示未注册）
    mapping(address => bool) public registeredMembers;
    
    // 声明映射，记录每个地址的账户余额
    // 键是地址，值是该地址的余额（以wei为单位）
    mapping(address => uint256) balance;

    // 构造函数：合约部署时执行一次，初始化银行管理员
    constructor(){
        // 将部署合约的地址设置为银行管理员
        bankManager = msg.sender;
        
        // 将银行管理员添加到会员数组中（管理员默认是会员）
        members.push(msg.sender);
    }

    // 修饰符：限制只有银行管理员才能调用某些函数
    modifier onlyBankManager(){
        // 检查调用者是否为银行管理员，如果不是则回滚交易
        require(msg.sender == bankManager, "Only bank manager can perform this action");
        
        // 继续执行被修饰的函数
        _;
    }

    // 修饰符：限制只有已注册的会员才能调用某些函数
    modifier onlyRegisteredMember() {
        // 检查调用者是否为已注册的会员，如果不是则回滚交易
        require(registeredMembers[msg.sender], "Member not registered");
        
        // 继续执行被修饰的函数
        _;
    }
  
    // 添加会员函数：只有银行管理员可以调用，用于添加新会员
    function addMembers(address _member)public onlyBankManager{
        // 检查新会员地址是否有效（不能是零地址）
        require(_member != address(0), "Invalid address");
        
        // 检查是否尝试添加银行管理员本人（管理员已经是会员）
        require(_member != msg.sender, "Bank Manager is already a member");
        
        // 检查该地址是否已经是注册会员
        require(!registeredMembers[_member], "Member already registered");
        
        // 将该地址标记为已注册会员
        registeredMembers[_member] = true;
        
        // 将该地址添加到会员数组中
        members.push(_member);
    }

    // 获取会员列表函数：任何人都可以调用，返回所有会员地址
    function getMembers() public view returns(address[] memory){
        // 返回会员地址数组
        return members;
    }
    
    // 存入以太币函数：只有已注册会员可以调用
    // payable 关键字表示该函数可以接收以太币
    function depositAmountEther() public payable onlyRegisteredMember{  
        // 检查发送的以太币数量是否大于0
        // msg.value 是调用函数时发送的以太币数量（以wei为单位）
        require(msg.value > 0, "Invalid amount");
        
        // 将发送的以太币数量累加到调用者的余额中
        balance[msg.sender] = balance[msg.sender]+msg.value;
   
    }
    
    // 提取金额函数：只有已注册会员可以调用，用于提取余额
    function withdrawAmount(uint256 _amount) public onlyRegisteredMember{
        // 检查提取金额是否大于0
        require(_amount > 0, "Invalid amount");
        
        // 检查调用者的余额是否足够
        require(balance[msg.sender] >= _amount, "Insufficient balance");
        
        // 从调用者的余额中扣除提取的金额
        balance[msg.sender] = balance[msg.sender]-_amount;
   
    }

    // 获取余额函数：任何人都可以调用，查询指定会员的余额
    function getBalance(address _member) public view returns (uint256){
        // 检查查询的地址是否有效
        require(_member != address(0), "Invalid address");
        
        // 返回指定会员的余额
        return balance[_member];
    } 
}`:t===7?`//SPDX-License-Identifier: MIT

// 声明Solidity版本，要求编译器版本在0.8.0或更高（但低于0.9.0）
pragma solidity ^0.8.0;

// 定义一个名为SimpleIOU的合约，用于朋友间的借条（IOU）管理
contract SimpleIOU{
    // 声明合约所有者的地址
    address public owner;
    
    // 跟踪已注册的朋友
    // 映射：地址 -> 是否已注册（布尔值）
    mapping(address => bool) public registeredFriends;
    
    // 地址数组：存储所有已注册朋友的地址列表
    address[] public friendList;
    
    // 跟踪每个朋友的余额
    // 映射：地址 -> 余额（以太币数量）
    mapping(address => uint256) public balances;
    
    // 简单的债务跟踪系统
    // 嵌套映射：债务人地址 -> 债权人地址 -> 欠款金额
    // 映射结构：mapping(键1 => mapping(键2 => 值))
    mapping(address => mapping(address => uint256)) public debts; // 债务人 -> 债权人 -> 金额
    
    // 构造函数：合约部署时执行一次，初始化合约
    constructor() {
        // 将部署合约的地址设置为所有者
        owner = msg.sender;
        
        // 将所有者注册为朋友（所有者默认是已注册用户）
        registeredFriends[msg.sender] = true;
        
        // 将所有者添加到朋友列表中
        friendList.push(msg.sender);
    }
    
    // 修饰符：限制只有所有者才能调用某些函数
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    // 修饰符：限制只有已注册的朋友才能调用某些函数
    modifier onlyRegistered() {
        require(registeredFriends[msg.sender], "You are not registered");
        _;
    }
    
    // 添加新朋友函数：只有所有者可以调用，用于注册新朋友
    function addFriend(address _friend) public onlyOwner {
        // 检查朋友地址是否有效（不能是零地址）
        require(_friend != address(0), "Invalid address");
        
        // 检查该朋友是否已经注册
        require(!registeredFriends[_friend], "Friend already registered");
        
        // 将该地址标记为已注册朋友
        registeredFriends[_friend] = true;
        
        // 将该地址添加到朋友列表中
        friendList.push(_friend);
    }
    
    // 存款函数：将以太币存入你的钱包余额
    // payable 关键字表示该函数可以接收以太币
    function depositIntoWallet() public payable onlyRegistered {
        // 检查是否发送了以太币
        require(msg.value > 0, "Must send ETH");
        
        // 将发送的以太币数量累加到调用者的余额中
        balances[msg.sender] += msg.value;
    }
    
    // 记录债务函数：记录某人欠你钱
    function recordDebt(address _debtor, uint256 _amount) public onlyRegistered {
        // 检查债务人地址是否有效
        require(_debtor != address(0), "Invalid address");
        
        // 检查债务人是否已注册
        require(registeredFriends[_debtor], "Address not registered");
        
        // 检查金额是否大于0
        require(_amount > 0, "Amount must be greater than 0");
        
        // 记录债务：在嵌套映射中增加债务金额
        // 结构：debts[债务人][债权人] += 金额
        debts[_debtor][msg.sender] += _amount;
    }
    
    // 使用内部余额转账偿还债务
    function payFromWallet(address _creditor, uint256 _amount) public onlyRegistered {
        // 检查债权人地址是否有效
        require(_creditor != address(0), "Invalid address");
        
        // 检查债权人是否已注册
        require(registeredFriends[_creditor], "Creditor not registered");
        
        // 检查金额是否大于0
        require(_amount > 0, "Amount must be greater than 0");
        
        // 检查债务金额是否足够
        require(debts[msg.sender][_creditor] >= _amount, "Debt amount incorrect");
        
        // 检查余额是否足够
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        // 更新余额和债务
        // 从债务人的余额中扣除金额
        balances[msg.sender] -= _amount;
        
        // 将金额添加到债权人的余额中
        balances[_creditor] += _amount;
        
        // 从债务记录中减少债务金额
        debts[msg.sender][_creditor] -= _amount;
    }
    
    // 直接转账方法：使用 transfer() 方法进行以太币转账
    function transferEther(address payable _to, uint256 _amount) public onlyRegistered {
        // 检查接收者地址是否有效
        require(_to != address(0), "Invalid address");
        
        // 检查接收者是否已注册
        require(registeredFriends[_to], "Recipient not registered");
        
        // 检查余额是否足够
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        // 从发送者的余额中扣除金额
        balances[msg.sender] -= _amount;
        
        // 使用 transfer() 方法将以太币转账给接收者
        // transfer() 是一个安全的转账方法，会自动转发2300 gas
        _to.transfer(_amount);
        
        // 将金额添加到接收者的余额中
        balances[_to]+=_amount;
    }
    
    // 替代转账方法：使用 call() 方法进行以太币转账
    function transferEtherViaCall(address payable _to, uint256 _amount) public onlyRegistered {
        // 检查接收者地址是否有效
        require(_to != address(0), "Invalid address");
        
        // 检查接收者是否已注册
        require(registeredFriends[_to], "Recipient not registered");
        
        // 检查余额是否足够
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        // 从发送者的余额中扣除金额
        balances[msg.sender] -= _amount;
        
        // 使用 call() 方法进行低级调用
        // call() 方法更灵活，可以设置 gas 限制
        // 返回值：success (bool) 表示调用是否成功
        // 第二个返回值是返回数据（这里不需要，用 _ 忽略）
        (bool success, ) = _to.call{value: _amount}("");
        
        // 将金额添加到接收者的余额中
        balances[_to]+=_amount;
        
        // 检查转账是否成功
        require(success, "Transfer failed");
    }
    
    // 提取函数：提取你的余额到外部钱包
    function withdraw(uint256 _amount) public onlyRegistered {
        // 检查余额是否足够
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        // 从余额中扣除金额
        balances[msg.sender] -= _amount;
        
        // 使用 call() 方法将以太币转回给调用者
        // payable(msg.sender) 将地址转换为可支付地址
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        
        // 检查提取是否成功
        require(success, "Withdrawal failed");
    }
    
    // 查询余额函数：查看你的余额
    function checkBalance() public view onlyRegistered returns (uint256) {
        // 返回调用者的余额
        return balances[msg.sender];
    }
}`:t===8?`//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    // 合约的拥有者（管理员）地址
    address public owner;
    
    // 记录收到的打赏总金额
    uint256 public totalTipsReceived;
    
    // 汇率映射表：记录法币（如USD）到ETH的汇率
    mapping(string => uint256) public conversionRates;

    // 记录每个地址（人）打赏的金额
    mapping(address => uint256) public tipPerPerson;
    
    // 当前支持的代币/货币列表
    string[] public supportedCurrencies;
    
    // 记录每种货币收到的打赏总数
    mapping(string => uint256) public tipsPerCurrency;
    
    // 构造函数：初始化所有者和预设汇率
    constructor() {
        owner = msg.sender;
        addCurrency("USD", 5 * 10**14);  // 1 USD = 0.0005 ETH
        addCurrency("EUR", 6 * 10**14);
        addCurrency("JPY", 4 * 10**12);
        addCurrency("INR", 7 * 10**12);
    }
    
    // 自定义修饰符：限制只有管理员才能使用
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    // 增加或更新支持的币种以及对等汇率
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Conversion rate must be greater than 0");
        bool currencyExists = false;
        for (uint i = 0; i < supportedCurrencies.length; i++) {
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }
        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }
        conversionRates[_currencyCode] = _rateToEth;
    }
    
    // 核心换算模块：计算法币金额对应的 ETH (wei)
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return _amount * conversionRates[_currencyCode];
    }
    
    // 直接发送 ETH 打赏
    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0");
        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }
    
    // 指定货法币进行打赏
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");
        
        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");
        
        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    // 提现函数：管理员提取合约内的全部资金
    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");
        
        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Transfer failed");
        
        totalTipsReceived = 0;
    }
  
    // 权限转移
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}`:t===9?`// ==================== 文件 1: day9-Calculator.sol ====================

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./day9-ScientificCalculator.sol";

contract Calculator{

    address public owner; // 当前合约的创建者
    address public scientificCalculatorAddress; // 外部高级科学计算器(ScientificCalculator)合约所在的地址

    constructor(){
        owner = msg.sender; // 赋予创建者这所合约的主人权限
    }

    // 限定操作者必须是 owner 的修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this action");
         _;  // 指代原本应用此修改器的接下来的执行流
    }

    // 让系统知晓高级计算器究竟被部署在哪个地址。只要知道了对方合约的地址，才能对其进行外部通信调用
    function setScientificCalculator(address _address)public onlyOwner{
        scientificCalculatorAddress = _address;
        }

    // 基础的加法，pure的意思是说它是"纯"函数，既不消耗或修改区块链状态，又跟外界毫无联动。这类型的函数不仅执行快速而且不收Gas燃料费(本地查看时)
    function add(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a+b;
        return result;
    }

    function subtract(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a-b;
        return result;
    }

    function multiply(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a*b;
        return result;
    }

    function divide(uint256 a, uint256 b)public pure returns(uint256){
        require(b!= 0, "Cannot divide by zero");
        uint256 result = a/b;
        return result;
    }

    // 计算指数功能：这是一个高级计算功能所以我们利用跨合约互调。这体现了区块链合约的组合式应用（所谓乐高积木）
    function calculatePower(uint256 base, uint256 exponent)public view returns(uint256){

    // 方法一（常规方法）：将外部合约视作对象进行实例对象的创建，然后按接口标准来调用
    ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);

    // external call （对外发起合约调用）
    // 当前合约（Calculator）在背后会去请求被指定地址的（ScientificCalculator）完成这项计算
    uint256 result = scientificCalc.power(base, exponent);

    return result;

}

    // 获取平方运算的操作：这里演示了另外一种更基层的跨合约联调操作手段：底层 call 方法
    function calculateSquareRoot(uint256 number)public returns (uint256){
        require(number >= 0 , "Cannot calculate square root of negative nmber");

        // 使用 abi.encodeWithSignature 来明确编码函数名称和附带的具体传参变量
        // 这个生成的16进制短字符数据就是待发送请求的方法执行代号，(注意函数的签名内不准出现空格：squareRoot(int256))
        bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);
        
        // 对另外一个以太坊地址使用底层的 .call() 将参数打入进去尝试引动相应的执行功能
        // .call() 会始终返还两个值：调用情况的状态(布尔) 和如果它顺利返回带出的数据字节(returnData)
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        require(success, "External call failed"); // 安全编程习惯之一，处理它底层执行没有回弹失败并致使出错的情况
        
        // 最后通过利用 abi.decode 把取回的一串原始数据（returnData）解密成我们需要能阅读懂的具体数字 (uint256类型)
        uint256 result = abi.decode(returnData, (uint256));
        return result;
    }

    
}


// ==================== 文件 2: day9-ScientificCalculator.sol ====================

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ScientificCalculator{

    // 求基数(base) 的给定指次数 (exponent) 的结果。pure同样表明只是本地的简单输出纯逻辑计算。
    function power(uint256 base, uint256 exponent)public pure returns(uint256){
        if(exponent == 0)return 1; // 零次方均为 1
        else return (base ** exponent); // '**' 在Solidity等价于指数的意思
    }

    // 以牛顿法逼近求取输入数的平方根 （Solidity 因为不具备浮点数运算支持这使这种开箱式求近似正变得常用）
    function squareRoot(int256 number)public pure returns(int256){
        require(number >= 0, "Cannot calculate square root of negative number"); // 数学要求被开方根必须不是负的
        if(number == 0)return 0;

        int256 result = number/2; // 原始预估近似值
        // 为保证它不仅消耗光所有的手续费且死锁(Gas exhausted), 人为限制让逼近只能进行 10 轮
        // 虽然轮次限制代表得不到精确数字，但足够反映逼近的过程
        for(uint256 i = 0; i<10; i++){
            result = (result + number / result)/2; // 牛顿迭代法的基础公约公式
        }

        return result; // 反馈出求取之后的收敛值
    }
}`:t===10?`//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ActivityTracker {
    // 合约所有者地址，用于权限管理
    address public owner;
    
    // 用户资料结构体：存储用户的基本信息
    struct UserProfile {
        string name;        // 用户姓名
        uint256 weight;     // 用户体重
        bool isRegistered;  // 是否已注册标记
    }
    
    // 运动活动结构体：存储单次运动的详细信息
    struct WorkoutActivity {
        string activityType; // 运动类型（如：跑步、游泳、骑行等）
        uint256 duration;    // in seconds / 运动时长（单位：秒）
        uint256 distance;    // in meters / 运动距离（单位：米）
        uint256 timestamp;   // 运动记录时间戳
    }
    
    // 用户地址 => 用户资料的映射，用于存储每个注册用户的基本信息
    mapping(address => UserProfile) public userProfiles;
    
    // 用户地址 => 运动历史数组的映射，存储每个用户的所有运动记录
    mapping(address => WorkoutActivity[]) private workoutHistory;
    
    // 用户地址 => 总运动次数的映射
    mapping(address => uint256) public totalWorkouts;
    
    // 用户地址 => 总运动距离的映射
    mapping(address => uint256) public totalDistance;
    
    // 事件定义：用于记录重要的合约操作，方便前端监听和日志查询
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(
        address indexed userAddress, 
        string activityType, 
        uint256 duration, 
        uint256 distance, 
        uint256 timestamp
    );
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);
    
    // 构造函数：在合约部署时执行，设置合约部署者为所有者
    constructor() {
        owner = msg.sender;
    }
    
    // 仅限已注册用户修饰器：确保调用函数的用户已经完成注册
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }
    
    // 用户注册函数：允许新用户注册到系统中
    function registerUser(string memory _name, uint256 _weight) public {
        // 检查用户是否已注册，防止重复注册
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        
        // 创建新的用户资料并存储
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        
        // 触发用户注册事件
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }
    
    // 更新体重函数：允许已注册用户更新体重，并检测是否达成减重目标
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        // 使用storage关键字获取存储引用，直接修改原数据
        UserProfile storage profile = userProfiles[msg.sender];
        
        // 检查是否达成显著减重目标（减重5%或以上）
        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) {
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }
        
        // 更新体重
        profile.weight = _newWeight;
        
        // 触发资料更新事件
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }
    
    // 记录运动函数：允许已注册用户记录新的运动活动
    function logWorkout(
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {
        // 创建新的运动活动记录
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });
        
        // 将新记录添加到用户的运动历史中
        workoutHistory[msg.sender].push(newWorkout);
        
        // 更新用户的统计数据
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        
        // 触发运动记录事件
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );
        
        // 检查运动次数里程碑（10次、50次）
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }
        
        // 检查距离里程碑（100公里 = 100000米）
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }
    
    // 获取用户运动次数函数：返回当前登录用户的运动记录数量
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }
}`:t===11?`// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ==================== 父合约：Ownable.sol ====================
// 基础所有权管理合约，可被其他合约继承复用

contract Ownable {
    // private 可见性：只能在当前合约内部访问
    address private owner;
    
    // 构造函数：合约部署时执行一次，初始化所有者
    constructor() {
        owner = msg.sender;
    }
    
    // 事件日志：indexed 参数可以被过滤查询
    event OwnershipTransferred(
        address indexed previousOwner,  // indexed 允许按地址搜索事件
        address indexed newOwner
    );
    
    // 修饰符：限制只有所有者才能调用某些函数
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;  // 继续执行被修饰的函数
    }
    
    // 查看当前所有者
    function ownerAddress() public view returns (address) {
        return owner;
    }
    
    // 转移所有权（只有所有者可以调用）
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address: cannot be zero address");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// ==================== 子合约：VaultMaster.sol ====================
// 资金保险库合约，继承 Ownable 的所有权管理功能

import "./Ownable.sol";

contract VaultMaster is Ownable {
    // 合约余额（实际上使用 address(this).balance）
    
    // 事件：记录成功的存款
    event DepositSuccessful(
        address indexed depositor,
        uint256 amount,
        uint256 timestamp
    );
    
    // 事件：记录成功的提款
    event WithdrawSuccessful(
        address indexed recipient,
        uint256 amount,
        uint256 timestamp
    );
    
    // 存款函数：任何人都可以存入 ETH
    function deposit() public payable {
        require(msg.value > 0, "Must send ETH to deposit");
        emit DepositSuccessful(msg.sender, msg.value, block.timestamp);
    }
    
    // 提款函数：只有所有者可以提取（继承的 onlyOwner 修饰符）
    function withdraw(address payable recipient, uint256 amount) public onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than 0");
        require(address(this).balance >= amount, "Insufficient contract balance");
        
        // 转账到指定地址
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit WithdrawSuccessful(recipient, amount, block.timestamp);
    }
    
    // 查询合约余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}`:t===12?`// SPDX-License-Identifier: MIT
// SPDX许可证标识符，指定代码使用MIT开源许可证
pragma solidity ^0.8.20;
// 指定Solidity编译器版本为0.8.20及以上，但小于0.9.0

// 简化版ERC20代币合约：ERC20是以太坊上最常用的代币标准，功能包括转账、授权、查询余额等
contract SimpleERC20 {
    // 代币基本信息
    string public name = "Web3 Compass";  // 代币全称
    string public symbol = "COM";          // 代币符号（交易时使用）
    uint8 public decimals = 18;            // 小数位数（18是标准值，1代币 = 10^18最小单位）
    uint256 public totalSupply;            // 代币总供应量

    // 余额映射：记录每个地址持有的代币数量，address => uint256: 地址 => 余额
    mapping(address => uint256) public balanceOf;
    // 授权额度映射（双重映射）：记录每个地址授权给其他地址可以使用的代币数量
    // address => address => uint256: 代币持有者 => 被授权者 => 授权额度
    // 例如：allowance[A][B] = 100 表示A授权B可以使用A的100个代币
    mapping(address => mapping(address => uint256)) public allowance;

    // 转账事件：当代币从一个地址转移到另一个地址时触发
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 授权事件：当代币持有者授权他人使用自己的代币时触发
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 构造函数：在合约部署时创建所有代币并分配给部署者
    // _initialSupply 是用户输入的值（不含小数位）
    constructor(uint256 _initialSupply) {
        // 计算实际总供应量：用户输入值 × 10^decimals
        // 例如：输入1000，decimals为18，则实际创建 1000 * 10^18 个最小单位
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        // 将所有代币分配给合约部署者
        balanceOf[msg.sender] = totalSupply;
        // 触发转账事件，表示从0地址（代表铸币）转账给部署者
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // 转账函数：调用者将自己的代币转给他人
    function transfer(address _to, uint256 _value) public returns (bool) {
        // 检查调用者余额是否足够
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        // 执行转账（内部函数）
        _transfer(msg.sender, _to, _value);
        return true;
    }

    // 授权函数：允许_spender从调用者账户中转走_value数量的代币
    function approve(address _spender, uint256 _value) public returns (bool) {
        // 设置授权额度
        allowance[msg.sender][_spender] = _value;
        // 触发授权事件
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 代转账函数（从他人账户转账）：调用者使用被授权的额度从_from地址向_to地址转账
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        // 检查_from地址的余额是否足够
        require(balanceOf[_from] >= _value, "Not enough balance");
        // 检查调用者被授权的额度是否足够
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");

        // 减少授权额度（已使用的部分）
        allowance[_from][msg.sender] -= _value;
        // 执行转账
        _transfer(_from, _to, _value);
        return true;
    }

    // 内部转账函数：internal修饰符表示只能在合约内部调用，这是实际执行转账逻辑的核心函数
    function _transfer(address _from, address _to, uint256 _value) internal {
        // 检查收款地址是否有效（不能是零地址）
        require(_to != address(0), "Invalid address");
        // 减少转出地址的余额
        balanceOf[_from] -= _value;
        // 增加转入地址的余额
        balanceOf[_to] += _value;
        // 触发转账事件
        emit Transfer(_from, _to, _value);
    }
}`:t===13?`//SPDX-License-Identifier: MIT
// SPDX许可证标识符，指定代码使用MIT开源许可证

pragma solidity ^0.8.0;
// 指定Solidity编译器版本为0.8.0或更高，但不包括1.0.0

contract MyToken{
// 定义一个名为MyToken的合约，这是一个ERC20代币合约

    string public name = "Web3 Compass";
    // 代币名称，公开可读
    string public symbol = "WBT";
    // 代币符号（简称），公开可读
    uint8 public decimals = 18;
    // 代币小数位数，ERC20标准通常为18位，公开可读
    uint256 public totalSupply;
    // 代币总供应量，公开可读

    mapping(address => uint256) public balanceOf;
    // 地址到余额的映射，记录每个地址持有的代币数量
    mapping(address => mapping (address  => uint256)) public allowance;
    // 嵌套映射，记录授权额度：allowance[所有者][被授权者] = 授权金额

    event Transfer(address indexed from, address indexed to, uint256 value);
    // 转账事件，当代币被转移时触发，indexed表示可以按该字段搜索
    event Approval(address indexed owner, address indexed spender, uint256 value);
    // 授权事件，当所有者授权 spender 使用代币时触发

    constructor(uint256 _initialSupply){
    // 构造函数，合约部署时执行一次，传入初始供应量参数
        totalSupply = _initialSupply * (10 ** decimals);
        // 计算实际总供应量 = 初始值 × 10^18（考虑小数位）
        balanceOf[msg.sender] = totalSupply;
        // 将所有代币分配给合约部署者（创建者）
        emit Transfer(address(0), msg.sender, _initialSupply);
        // 触发转账事件，from地址为0表示这是新铸造的代币
    } 

    function _transfer(address _from, address _to, uint256 _value)internal virtual{
    // 内部转账函数，只能在合约内部调用，virtual表示可被重写
        require(_to != address(0), "Cannot transfer to the zero address");
        // 检查：不能转账到零地址（防止代币丢失）
        balanceOf[_from]-= _value;
        // 从发送者余额中扣除转账金额
        balanceOf[_to] += _value;
        // 向接收者余额中增加转账金额
        emit Transfer(_from, _to, _value);
        // 触发转账事件，记录这笔转账
    }
     function transfer(address _to, uint256 _value)public virtual returns (bool success){ 
     // 公共转账函数，允许用户直接转账自己的代币
        require(balanceOf[msg.sender] >= _value , "Not enough balance");
        // 检查：发送者余额必须足够
        _transfer(msg.sender, _to, _value);
        // 调用内部转账函数执行转账
        return true;
        // 返回true表示转账成功
    
    }

    function transferFrom(address _from, address _to, uint256 _value)public virtual returns(bool){
    // 代转账函数，用于被授权者代替所有者转账（如交易所、DApp等场景）
        require(balanceOf[_from] >= _value, "Not enough balance");
        // 检查：所有者余额必须足够
        require(allowance[_from][msg.sender]>= _value, "Not enough allowence");
        // 检查：调用者的授权额度必须足够
        allowance[_from][msg.sender]-= _value;
        // 减少调用者的授权额度
        _transfer(_from, _to, _value);
        // 执行转账
        return true;
        // 返回true表示转账成功

    }

    function approve(address _spender, uint256 _value)public returns(bool){
    // 授权函数，允许_spender使用调用者最多_value数量的代币
        allowance[msg.sender][_spender] = _value;
        // 设置授权额度
        emit Approval(msg.sender, _spender, _value);
        // 触发授权事件
        return true;
        // 返回true表示授权成功

    }
}`:t===14?`// ==================== 文件 1: IDepositBox.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 定义存款盒接口 - 规定所有存款盒必须实现的功能
interface IDepositBox {
    // 存入秘密的函数
    function storeSecret(string calldata secret) external;
    
    // 取出秘密的函数
    function getSecret() external view returns (string memory);
    
    // 转移所有权的函数
    function transferOwnership(address newOwner) external;
    
    // 获取盒子类型的函数
    function getBoxType() external view returns (string memory);
    
    // 获取当前所有者的函数
    function getOwner() external view returns (address);
}

// ==================== 文件 2: BaseDepositBox.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IDepositBox.sol";

// 抽象基础合约 - 实现通用功能，但不能直接部署
abstract contract BaseDepositBox is IDepositBox {
    // 状态变量
    string internal secret;
    address internal owner;
    uint256 internal createdAt;
    
    // 修饰器：只有所有者可以调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    // 构造函数
    constructor() {
        owner = msg.sender;
        createdAt = block.timestamp;
    }
    
    // 虚函数：存入秘密（子合约可以重写）
    function storeSecret(string calldata _secret) public virtual onlyOwner {
        secret = _secret;
    }
    
    // 虚函数：取出秘密（子合约可以重写）
    function getSecret() public view virtual onlyOwner returns (string memory) {
        return secret;
    }
    
    // 转移所有权
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }
    
    // 获取当前所有者
    function getOwner() public view returns (address) {
        return owner;
    }
    
    // 纯虚函数：获取盒子类型（必须由子合约实现）
    function getBoxType() public view virtual returns (string memory);
}

// ==================== 文件 3: BasicDepositBox.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseDepositBox.sol";

// 基础存款盒 - 简单继承，无额外功能
contract BasicDepositBox is BaseDepositBox {
    // 只继承父合约功能，不添加新功能
    
    function getBoxType() public view override returns (string memory) {
        return "Basic";
    }
}

// ==================== 文件 4: PremiumDepositBox.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseDepositBox.sol";

// 高级存款盒 - 增加 metadata 功能
contract PremiumDepositBox is BaseDepositBox {
    // 额外的状态变量
    string private metadata;
    
    // 设置元数据
    function setMetadata(string calldata _metadata) public onlyOwner {
        metadata = _metadata;
    }
    
    // 获取元数据
    function getMetadata() public view onlyOwner returns (string memory) {
        return metadata;
    }
    
    // 重写获取盒子类型
    function getBoxType() public view override returns (string memory) {
        return "Premium";
    }
}

// ==================== 文件 5: TimeLockedDepositBox.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseDepositBox.sol";

// 时间锁定存款盒 - 增加时间锁功能
contract TimeLockedDepositBox is BaseDepositBox {
    // 解锁时间戳
    uint256 private unlockTime;
    
    // 修饰器：检查是否已解锁
    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Box is still locked");
        _;
    }
    
    // 构造函数：设置锁定时间
    constructor(uint256 _lockDuration) {
        unlockTime = block.timestamp + _lockDuration;
    }
    
    // 重写存入秘密
    function storeSecret(string calldata _secret) public override onlyOwner {
        secret = _secret;
    }
    
    // 重写取出秘密：需要同时满足 onlyOwner 和 timeUnlocked
    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
        return secret;
    }
    
    // 获取解锁时间
    function getUnlockTime() public view returns (uint256) {
        return unlockTime;
    }
    
    // 获取剩余锁定时间
    function getRemainingLockTime() public view returns (uint256) {
        if (block.timestamp >= unlockTime) {
            return 0;
        }
        return unlockTime - block.timestamp;
    }
    
    // 重写获取盒子类型
    function getBoxType() public view override returns (string memory) {
        return "TimeLocked";
    }
}

// ==================== 文件 6: VaultManager.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BasicDepositBox.sol";
import "./PremiumDepositBox.sol";
import "./TimeLockedDepositBox.sol";

// 保险库管理器 - 工厂模式 + 管理功能
contract VaultManager {
    // 存储所有创建的存款盒
    address[] public allBoxes;
    
    // 记录每个用户拥有的存款盒
    mapping(address => address[]) public userBoxes;
    
    // 事件
    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    
    // 创建基础存款盒
    function createBasicBox() public returns (address) {
        BasicDepositBox newBox = new BasicDepositBox();
        address boxAddress = address(newBox);
        
        allBoxes.push(boxAddress);
        userBoxes[msg.sender].push(boxAddress);
        
        emit BoxCreated(msg.sender, boxAddress, "Basic");
        return boxAddress;
    }
    
    // 创建高级存款盒
    function createPremiumBox() public returns (address) {
        PremiumDepositBox newBox = new PremiumDepositBox();
        address boxAddress = address(newBox);
        
        allBoxes.push(boxAddress);
        userBoxes[msg.sender].push(boxAddress);
        
        emit BoxCreated(msg.sender, boxAddress, "Premium");
        return boxAddress;
    }
    
    // 创建时间锁定存款盒
    function createTimeLockedBox(uint256 _lockDuration) public returns (address) {
        TimeLockedDepositBox newBox = new TimeLockedDepositBox(_lockDuration);
        address boxAddress = address(newBox);
        
        allBoxes.push(boxAddress);
        userBoxes[msg.sender].push(boxAddress);
        
        emit BoxCreated(msg.sender, boxAddress, "TimeLocked");
        return boxAddress;
    }
    
    // 获取用户的所有存款盒
    function getMyBoxes() public view returns (address[] memory) {
        return userBoxes[msg.sender];
    }
    
    // 获取所有存款盒数量
    function getTotalBoxes() public view returns (uint256) {
        return allBoxes.length;
    }
    
    // 完成所有权转移（新所有者调用）
    function completeOwnershipTransfer(address boxAddress) public {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "You are not the new owner");
        
        userBoxes[msg.sender].push(boxAddress);
    }
}`:t===15?` ==================== GasEfficientVoting.sol ====================
\\ SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Gas 优化投票合约
// 展示如何使用紧凑数据类型和位运算优化 Gas 消耗
contract GasEfficientVoting {

    // ==================== 紧凑数据类型优化 ====================

    // 使用 uint8 而非 uint256，节省 31 字节存储空间
    uint8 public proposalCount;  // 最多支持 255 个提案

    // 提案结构体 - 使用紧凑数据类型
    struct Proposal {
        uint32 id;           // 4 字节：提案 ID
        uint32 voteCount;    // 4 字节：投票数
        uint64 startTime;    // 8 字节：开始时间
        uint64 endTime;      // 8 字节：结束时间
        bool executed;       // 1 字节：是否已执行
        bytes32 name;        // 32 字节：固定长度名称（比 string 更省 Gas）
        address creator;     // 20 字节：创建者地址
    }

    // ==================== 映射存储 ====================

    // 提案 ID → 提案详情
    mapping(uint256 => Proposal) public proposals;

    // 地址 → 投票位图（1个 uint256 可存储 256 个提案的投票状态）
    mapping(address => uint256) public voterRegistry;

    // 提案 ID → 投票数（使用 uint32 足够大）
    mapping(uint256 => uint32) public proposalVoterCount;

    // ==================== 事件定义 ====================

    event ProposalCreated(uint256 indexed id, bytes32 name, uint256 endTime);
    event Voted(address indexed voter, uint256 indexed proposalId);
    event ProposalExecuted(uint256 indexed id, uint256 voteCount);

    // ==================== 核心功能 ====================

    // 创建提案
    function createProposal(bytes32 _name, uint256 _durationMinutes) public {
        uint256 proposalId = proposalCount;

        // 创建新提案
        proposals[proposalId] = Proposal({
            id: uint32(proposalId),
            voteCount: 0,
            startTime: uint64(block.timestamp),
            endTime: uint64(block.timestamp + _durationMinutes * 1 minutes),
            executed: false,
            name: _name,
            creator: msg.sender
        });

        proposalCount++;  // uint8 自动溢出检查

        emit ProposalCreated(proposalId, _name, block.timestamp + _durationMinutes * 1 minutes);
    }

    // 投票功能 - 使用位运算记录投票状态
    function vote(uint256 _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];

        // 检查提案是否存在
        require(proposal.creator != address(0), "Proposal does not exist");
        require(!proposal.executed, "Proposal already executed");

        // 检查投票时间窗口
        require(block.timestamp >= proposal.startTime, "Voting not started");
        require(block.timestamp <= proposal.endTime, "Voting ended");

        // ==================== 位运算技巧 ====================

        // 生成掩码：1 左移 proposalId 位
        // 例如：proposalId = 5，mask = 0b100000 (二进制)
        uint256 mask = 1 << _proposalId;

        // 获取当前选民的投票位图
        uint256 voterData = voterRegistry[msg.sender];

        // 掩码检查：使用与运算检查是否已投票
        require((voterData & mask) == 0, "Already voted");

        // 记录投票：使用或运算设置对应位为 1
        voterRegistry[msg.sender] = voterData | mask;

        // 增加投票计数
        proposal.voteCount++;
        proposalVoterCount[_proposalId]++;

        emit Voted(msg.sender, _proposalId);
    }

    // 执行提案
    function executeProposal(uint256 _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];

        // 检查提案是否存在
        require(proposal.creator != address(0), "Proposal does not exist");

        // 检查投票是否已结束
        require(block.timestamp > proposal.endTime, "Voting still in progress");

        // 检查是否已执行
        require(!proposal.executed, "Already executed");

        // 标记为已执行
        proposal.executed = true;

        emit ProposalExecuted(_proposalId, proposal.voteCount);
    }

    // ==================== 查询功能 ====================

    // 检查地址是否对某提案投过票
    function hasVoted(address _voter, uint256 _proposalId) public view returns (bool) {
        uint256 mask = 1 << _proposalId;
        uint256 voterData = voterRegistry[_voter];
        return (voterData & mask) != 0;
    }

    // 获取提案详情
    function getProposal(uint256 _proposalId) public view returns (
        uint32 id,
        bytes32 name,
        uint32 voteCount,
        uint64 startTime,
        uint64 endTime,
        bool executed,
        address creator
    ) {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.creator != address(0), "Proposal does not exist");

        return (
            proposal.id,
            proposal.name,
            proposal.voteCount,
            proposal.startTime,
            proposal.endTime,
            proposal.executed,
            proposal.creator
        );
    }

    // 获取选民的投票位图（用于调试）
    function getVoterBitmap(address _voter) public view returns (uint256) {
        return voterRegistry[_voter];
    }
}

\\ ==================== Gas 优化要点总结 ====================
\\
\\ 1. 紧凑数据类型：
\\    - uint8 (1 字节) 代替 uint256 (32 字节) 存储小范围数字
\\    - uint32 (4 字节) 存储投票数，最大值 42 亿
\\    - uint64 (8 字节) 存储时间戳，支持到公元 294,247 年
\\
\\ 2. 固定长度类型：
\\    - bytes32 (32 字节) 代替 string，避免动态存储开销
\\    - 适合存储固定长度的短文本和哈希值
\\
\\ 3. 位运算优化：
\\    - 1 个 uint256 (32 字节) 存储 256 个布尔值
\\    - 相比 mapping(uint256 => bool)，节省约 40% Gas
\\    - 关键操作：生成掩码(<<)、检查(&)、设置(|)
\\
\\ 4. 存储布局优化：
\\    - 将多个小变量打包到同一存储槽位
\\    - 减少存储读取次数，降低 Gas 消耗
\\
\\ 5. 事件日志：
\\    - 使用 indexed 参数实现链下高效检索
    - 事件不占用状态存储，只消耗少量 Gas`:t===16?`// ==================== PluginStore.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// PluginStore - 插件存储合约
// 这是一个插件系统的核心合约，允许注册和调用各种插件
// 支持玩家资料管理和插件的动态调用
contract PluginStore {

    // ==================== 结构体定义 ====================
    // 玩家资料结构体
    // name: 玩家名称
    // avatar: 玩家头像标识
    struct PlayerProfile {
        string name;
        string avatar;
    }

    // ==================== 映射存储 ====================
    // 存储每个地址的玩家资料
    mapping(address => PlayerProfile) public profiles;

    // 存储已注册的插件
    // key: 插件标识符（字符串）
    // value: 插件合约地址
    mapping(string => address) public plugins;

    // ==================== 玩家资料管理 ====================
    // 设置玩家资料
    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    // 获取玩家资料
    function getProfile(address user) external view returns (string memory, string memory) {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }

    // ==================== 插件注册 ====================
    // 注册插件
    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }

    // 获取插件地址
    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }

    // ==================== 低级别调用 (call) ====================
    // 执行插件函数（状态改变）
    function runPlugin(
        string memory key, 
        string memory functionSignature, 
        address user, 
        string memory argument
    ) external {
        // 获取插件地址
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        // ABI编码函数调用数据
        bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);

        // 使用 low-level call 调用插件合约
        (bool success, ) = plugin.call(data);
        require(success, "Plugin execution failed");
    }

    // ==================== 静态调用 (staticcall) ====================
    // 执行插件函数（只读视图）
    function runPluginView(
        string memory key, 
        string memory functionSignature, 
        address user
    ) external view returns (string memory) {
        address plugin = plugins[key];
        require(plugin != address(0), "No plugin found");

        // ABI编码函数调用数据
        bytes memory data = abi.encodeWithSignature(functionSignature, user);

        // 使用 staticcall 调用插件合约（不修改状态）
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin execution failed");

        // 解码返回数据
        return abi.decode(result, (string));
    }
}

// ==================== WeaponStorePlugin.sol ====================
// 武器商店插件合约
contract WeaponStorePlugin {
    // 存储每个用户当前装备的武器
    mapping(address => string) public equippedWeapon;

    // 设置用户的装备武器
    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }

    // 获取用户当前装备的武器
    function getWeapon(address user) public view returns (string memory) {
        return equippedWeapon[user];
    }
}

// ==================== AchievementsPlugin.sol ====================
// 成就插件合约
contract AchievementsPlugin {
    // 存储每个用户的最新成就
    mapping(address => string) public latestAchievement;

    // 设置用户的成就
    function setAchievement(address user, string memory achievement) public {
        latestAchievement[user] = achievement;
    }

    // 获取用户的最新成就
    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }
}

// ==================== 使用示例 ====================
// pluginStore.runPlugin("weapon", "setWeapon(address,string)", msg.sender, "Golden Axe");
// 这将调用名为 "weapon" 的插件的 setWeapon 函数，为用户装备 "Golden Axe"

// ==================== 核心概念总结 ====================
//
// 1. 结构体 (struct):
//    - 将多个相关数据组合成自定义类型
//    - PlayerProfile 包含 name 和 avatar
//
// 2. 映射 (mapping):
//    - 键值对存储，O(1) 读写效率
//    - profiles: address => PlayerProfile
//    - plugins: string => address
//
// 3. 低级别调用 (call/staticcall):
//    - call: 可修改状态的动态调用
//    - staticcall: 只读调用，保证不修改状态
//    - 返回 (bool success, bytes result)
//
// 4. ABI编码:
//    - abi.encodeWithSignature: 编码函数调用
//    - abi.decode: 解码返回值
//    - 函数选择器: 函数签名的前4字节(keccak256哈希)
//
// 5. 插件架构:
//    - 核心合约管理插件注册表
//    - 插件合约实现具体功能
//    - 动态委托实现功能扩展`:t===17?`// ==================== day17-SubscriptionStorageLayout.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SubscriptionStorageLayout - 订阅存储布局合约
// 这是可升级合约架构中的基础合约
// 定义了所有存储变量，确保代理合约和逻辑合约的存储布局一致
// 存储布局的一致性是可升级合约的关键！
contract SubscriptionStorageLayout {

    // 当前逻辑合约地址
    // 代理合约使用此地址进行 delegatecall
    address public logicContract;

    // 合约所有者地址
    // 拥有升级合约等特权操作权限
    address public owner;

    // 订阅信息结构体
    // planId: 订阅计划 ID（如 1=基础版, 2=高级版）
    // expiry: 订阅过期时间戳（秒）
    // paused: 是否处于暂停状态（V2 新增字段）
    struct Subscription {
        uint8 planId;
        uint256 expiry;
        bool paused;
    }

    // 用户地址到订阅信息的映射
    // 存储每个用户的订阅详情
    mapping(address => Subscription) public subscriptions;

    // 计划 ID 到价格的映射
    // 存储每个订阅计划的价格（wei）
    mapping(uint8 => uint256) public planPrices;

    // 计划 ID 到持续时间的映射
    // 存储每个订阅计划的有效期（秒）
    mapping(uint8 => uint256) public planDuration;

    // 安全间隙 - 防止未来升级时存储冲突
    // 这是一个预留的存储空间，用于未来的存储变量
    // 如果不预留，添加新变量可能会与继承合约的存储发生冲突
    // 50 个 uint256 槽位提供了充足的安全缓冲
    uint256[50] private __gap;
}

// ==================== day17-SubscriptionStorage.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入存储布局合约
import "./day17-SubscriptionStorageLayout.sol";

// SubscriptionStorage - 订阅存储代理合约
// 这是可升级合约架构中的代理合约（Proxy）
// 负责存储所有数据，并将函数调用委托给逻辑实现合约
// 使用 delegatecall 实现数据和逻辑的分离
contract SubscriptionStorage is SubscriptionStorageLayout {

    // 构造函数
    // _logicContract: 初始逻辑合约地址
    constructor(address _logicContract) {
        owner = msg.sender;           // 设置合约所有者
        logicContract = _logicContract;  // 设置初始逻辑合约
    }

    // 升级逻辑合约（仅合约所有者）
    // _newLogic: 新的逻辑合约地址
    // 这是可升级合约的核心功能
    function upgradeTo(address _newLogic) external {
        require(msg.sender == owner, "Not owner");
        logicContract = _newLogic;
    }

    // 回退函数（fallback）- 处理所有未匹配的函数调用
    // 使用 delegatecall 将调用委托给逻辑合约
    // delegatecall 会在当前合约的存储上下文中执行逻辑合约的代码
    fallback() external payable {
        // 获取当前逻辑合约地址
        address impl = logicContract;
        require(impl != address(0), "Implementation not set");

        // 使用内联汇编执行 delegatecall
        assembly {
            // 1. 将调用数据（calldata）复制到内存位置 0
            calldatacopy(0, 0, calldatasize())

            // 2. 执行 delegatecall
            // delegatecall(gas, target, inOffset, inSize, outOffset, outSize)
            // 这会在当前合约的存储上下文中执行 impl 合约的代码
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)

            // 3. 将返回数据复制到内存
            returndatacopy(0, 0, returndatasize())

            // 4. 根据调用结果返回或回滚
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    // 接收函数（receive）- 处理纯 ETH 转账
    receive() external payable {}
}

// ==================== day17-SubscriptionLogicV1.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入存储布局合约
import "./day17-SubscriptionStorageLayout.sol";

// SubscriptionLogicV1 - 订阅逻辑合约 V1
// 这是可升级合约架构中的逻辑实现合约
// 使用代理模式（Proxy Pattern）实现合约升级
// 注意: 逻辑合约本身不存储数据，数据存储在代理合约中
contract SubscriptionLogicV1 is SubscriptionStorageLayout {

    // 初始化函数
    function initialize() external {
        // 可用于设置初始状态
    }

    // 创建订阅计划（仅合约所有者）
    function createPlan(uint8 planId, uint256 price, uint256 duration) external {
        require(msg.sender == owner, "Only owner");
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    // 订阅计划
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Plan does not exist");
        require(msg.value == planPrices[planId], "Incorrect ETH amount");

        subscriptions[msg.sender] = Subscription({
            planId: planId,
            expiry: block.timestamp + planDuration[planId],
            paused: false
        });
    }

    // 检查用户是否处于有效订阅状态
    function isSubscribed(address user) external view returns (bool) {
        return subscriptions[user].expiry > block.timestamp;
    }
}

// ==================== day17-SubscriptionLogicV2.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入存储布局合约
import "./day17-SubscriptionStorageLayout.sol";

// SubscriptionLogicV2 - 订阅逻辑合约 V2
// 这是 V1 的升级版本，新增了暂停订阅功能
// 展示了可升级合约模式如何添加新功能而不丢失数据
contract SubscriptionLogicV2 is SubscriptionStorageLayout {

    // 创建订阅计划（仅合约所有者）
    function createPlan(uint8 planId, uint256 price, uint256 duration) external {
        require(msg.sender == owner, "Only owner");
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    // 订阅计划
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Plan does not exist");
        require(msg.value == planPrices[planId], "Incorrect ETH amount");

        subscriptions[msg.sender] = Subscription({
            planId: planId,
            expiry: block.timestamp + planDuration[planId],
            paused: false
        });
    }

    // 暂停订阅（V2 新增功能）
    function pauseSubscription() external {
        Subscription storage sub = subscriptions[msg.sender];
        require(sub.expiry > block.timestamp, "Subscription expired");
        require(!sub.paused, "Already paused");

        sub.paused = true;
        // 计算并保存剩余时间
        sub.expiry = sub.expiry - block.timestamp;
    }

    // 恢复订阅（V2 新增功能）
    function resumeSubscription() external {
        Subscription storage sub = subscriptions[msg.sender];
        require(sub.paused, "Not paused");

        sub.paused = false;
        // 重新计算过期时间: 当前时间 + 之前保存的剩余时间
        sub.expiry = block.timestamp + sub.expiry;
    }

    // 检查用户是否处于有效订阅状态（V2 更新）
    function isSubscribed(address user) external view returns (bool) {
         Subscription memory sub = subscriptions[user];
         if (sub.paused) return false;
         return sub.expiry > block.timestamp;
    }
}

// ==================== 可升级合约架构说明 ====================
//
// 1. 代理合约（SubscriptionStorage）:
//    - 存储所有数据（subscriptions, planPrices 等）
//    - 持有用户的 ETH
//    - 通过 delegatecall 将函数调用转发给逻辑合约
//
// 2. 逻辑合约（SubscriptionLogicV1/V2）:
//    - 包含业务逻辑代码
//    - 不存储数据（数据存储在代理合约中）
//    - 可以被替换（升级）而不丢失数据
//
// 3. 升级流程:
//    - 部署新的逻辑合约（如 V2）
//    - 调用 upgradeTo() 更新 logicContract 地址
//    - 所有后续调用都会使用新的逻辑
//    - 数据保持不变
//
// 4. delegatecall 关键点:
//    - 在代理合约的存储上下文中执行
//    - msg.sender 保持为原始调用者
//    - msg.value 保持不变`:t===18?`// ==================== day18-MockWeatherOracle.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Chainlink 预言机接口定义 - 直接内联，无需外部依赖
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function getRoundData(uint80 _roundId) external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

// 简单的所有权管理合约 - 直接内联，无需外部依赖
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// MockWeatherOracle - 模拟天气预言机合约
// 实现了 Chainlink 的 AggregatorV3Interface 接口
// 用于开发和测试环境，模拟真实的天气数据预言机
contract MockWeatherOracle is AggregatorV3Interface, Ownable {
    uint8 private _decimals;
    string private _description;
    uint80 private _roundId;
    uint256 private _timestamp;
    uint256 private _lastUpdateBlock;

    constructor() Ownable(msg.sender) {
        _decimals = 0; // 降雨量以整毫米为单位
        _description = "MOCK/RAINFALL/USD";
        _roundId = 1;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function description() external view override returns (string memory) {
        return _description;
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function getRoundData(uint80 _roundId_)
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    // 计算当前降雨量（内部函数）
    // 使用区块信息生成伪随机数，模拟降雨量变化
    function _rainfall() public view returns (int256) {
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;

        uint256 randomFactor = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.coinbase,
            blocksSinceLastUpdate
        ))) % 1000;

        return int256(randomFactor);
    }

    function _updateRandomRainfall() private {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}

// ==================== day18-CropInsurance.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// CropInsurance - 农作物保险合约（升级版）
// 这是一个参数保险合约，使用 Chainlink 预言机获取降雨量和 ETH/USD 价格
// 当降雨量低于阈值时，自动向投保农民赔付
contract CropInsurance is Ownable {
    // 天气预言机接口，用于获取降雨量数据
    AggregatorV3Interface private weatherOracle;
    // ETH/USD 价格预言机，用于将美元金额转换为 ETH
    AggregatorV3Interface private ethUsdPriceFeed;

    // 常量定义
    uint256 public constant RAINFALL_THRESHOLD = 500;        // 降雨阈值（毫米）
    uint256 public constant INSURANCE_PREMIUM_USD = 10;      // 保险保费（美元）
    uint256 public constant INSURANCE_PAYOUT_USD = 50;       // 保险赔付金额（美元）

    // 存储每个地址的投保状态
    mapping(address => bool) public hasInsurance;
    // 存储每个地址上次索赔的时间戳，用于限制索赔频率
    mapping(address => uint256) public lastClaimTimestamp;

    // 事件定义
    event InsurancePurchased(address indexed farmer, uint256 amount);
    event ClaimSubmitted(address indexed farmer);
    event ClaimPaid(address indexed farmer, uint256 amount);
    event RainfallChecked(address indexed farmer, uint256 rainfall);

    // 构造函数
    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender) {
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }

    // 购买保险函数
    // 农民支付保费购买保险，保费金额根据当前 ETH 价格动态计算
    function purchaseInsurance() external payable {
        uint256 ethPrice = getEthPrice();
        // 价格转换公式: (USD金额 × 1e26) / ETH价格 = ETH数量（wei）
        // 1e26 = 1e18(wei精度) × 1e8(Chainlink价格精度)
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e26) / ethPrice;

        require(msg.value >= premiumInEth, "Insufficient premium amount");
        require(!hasInsurance[msg.sender], "Already insured");

        hasInsurance[msg.sender] = true;
        emit InsurancePurchased(msg.sender, msg.value);
    }

    // 检查降雨量并索赔函数
    // 农民调用此函数检查降雨量，如果低于阈值则自动获得赔付
    function checkRainfallAndClaim() external {
        require(hasInsurance[msg.sender], "No active insurance");
        // 24小时冷却期限制
        require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 24h between claims");

        (
            uint80 roundId,
            int256 rainfall,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = weatherOracle.latestRoundData();

        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale data");

        uint256 currentRainfall = uint256(rainfall);
        emit RainfallChecked(msg.sender, currentRainfall);

        // 参数化赔付：自动检查条件并执行
        if (currentRainfall < RAINFALL_THRESHOLD) {
            lastClaimTimestamp[msg.sender] = block.timestamp;
            emit ClaimSubmitted(msg.sender);

            uint256 ethPrice = getEthPrice();
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e26) / ethPrice;

            (bool success, ) = msg.sender.call{value: payoutInEth}("");
            require(success, "Transfer failed");

            emit ClaimPaid(msg.sender, payoutInEth);
        }
    }

    // 获取 ETH/USD 价格函数
    // 返回: ETH 价格（美元），精度为 8 位小数
    function getEthPrice() public view returns (uint256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        return uint256(price);
    }

    // 获取当前降雨量函数
    function getCurrentRainfall() public view returns (uint256) {
        (, int256 rainfall, , , ) = weatherOracle.latestRoundData();
        return uint256(rainfall);
    }

    // 提取合约余额（仅合约所有者）
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // 接收 ETH 函数
    receive() external payable {}

    // 获取合约余额函数
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

// ==================== 预言机与参数保险架构说明 ====================
//
// 1. 双预言机设计:
//    - Weather Oracle: 提供降雨量数据
//    - ETH/USD PriceFeed: 提供价格数据用于货币转换
//    - 两者都遵循 Chainlink 的 AggregatorV3Interface 标准
//
// 2. 价格转换机制:
//    - Chainlink 价格预言机返回 8 位小数精度的价格
//    - 公式: ETH数量 = (USD金额 × 1e26) / ETH价格
//    - 1e26 = 1e18(wei精度) × 1e8(Chainlink精度)
//
// 3. 参数保险特点:
//    - 自动触发：无需人工审核，条件满足自动赔付
//    - 透明可信：使用预言机数据，避免争议
//    - 高效低成本：无需理赔调查，降低运营成本
//
// 4. 冷却期机制:
//    - 24小时内只能索赔一次
//    - 防止滥用和频繁索赔
//    - 使用 block.timestamp 记录时间`:t===19?`// ==================== day19-SignThis.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SignThis {
    // 存储活动组织者地址
    address public organizer;

    // 记录用户是否已参加活动
    mapping(address => bool) public hasEntered;

    // 记录参与者列表
    address[] public participants;

    // 事件：用户参与活动
    event UserEntered(address indexed user);

    // 构造函数：设置组织者
    constructor() {
        organizer = msg.sender;
    }

    // 验证签名并记录参与者
    function enter(bytes memory signature) external {
        // 验证签名
        require(_verifySignature(msg.sender, signature), "Invalid signature");

        // 检查是否已参与（防止重入）
        require(!hasEntered[msg.sender], "Already entered");

        // 记录参与者
        hasEntered[msg.sender] = true;
        participants.push(msg.sender);

        // 触发事件
        emit UserEntered(msg.sender);
    }

    // 内部函数：验证签名
    function _verifySignature(address user, bytes memory signature) internal view returns (bool) {
        // 对用户地址进行哈希
        bytes32 messageHash = keccak256(abi.encodePacked(user));

        // 添加 EIP-191 前缀
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\\x19Ethereum Signed Message:\\n32", messageHash)
        );

        // 恢复签名者地址
        (bytes32 r, bytes32 s, uint8 v) = _splitSignature(signature);
        address recovered = ecrecover(ethSignedMessageHash, v, r, s);

        // 验证签名者是否为组织者
        return recovered == organizer;
    }

    // 拆分签名为 r, s, v 三个组件
    function _splitSignature(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    // 获取参与者数量
    function getParticipantCount() external view returns (uint256) {
        return participants.length;
    }

    // 检查特定地址是否已参与
    function checkEntered(address user) external view returns (bool) {
        return hasEntered[user];
    }
}

// ==================== 签名验证与无Gas空投说明 ====================
//
// 1. 签名验证原理:
//    - 组织者使用私钥对用户地址进行签名
//    - 用户调用合约时提供签名
//    - 合约使用 ecrecover 恢复签名者地址
//    - 验证恢复的地址是否为组织者
//
// 2. EIP-191 签名标准:
//    - 目的：防止签名被误用于其他场景
//    - 方法：在消息前添加 "\\x19Ethereum Signed Message:\\n32" 前缀
//    - 效果：签名的消息与普通文本签名不同
//
// 3. 无 Gas 空投优势:
//    - 用户无需持有 ETH 即可参与
//    - 组织者承担 Gas 费用
//    - 适用于代币空投、白名单、邀请奖励等场景
//
// 4. 安全考虑:
//    - 使用 nonce 防止重放攻击（可扩展）
//    - 验证签名长度
//    - 使用 require 进行输入验证`:t===20?`// ==================== day20-GoldVault.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// GoldVault - 金库合约
// 演示重入攻击漏洞及其防护措施
contract GoldVault {
    // 存储每个用户的黄金（ETH）余额
    mapping(address => uint256) public goldBalance;

    // 重入锁状态变量
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // 构造函数 - 初始化重入锁状态
    constructor() {
        _status = _NOT_ENTERED;
    }

    // 自定义 nonReentrant 修饰符 - 防止重入攻击
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call blocked");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    // 存款函数
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0");
        goldBalance[msg.sender] += msg.value;
    }

    // 有漏洞的提款函数 - 演示重入攻击风险
    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // 漏洞所在: 先发送ETH（外部调用）
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");

        // 后更新余额 - 如果外部调用重入，余额还未更新！
        goldBalance[msg.sender] = 0;
    }

    // 安全的提款函数 - 使用重入锁保护
    function safeWithdraw() external nonReentrant {
        // 1. Checks: 验证条件
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // 2. Effects: 先更新状态
        goldBalance[msg.sender] = 0;

        // 3. Interactions: 最后进行外部调用
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
    }
}

// ==================== day20-GoldThief.sol ====================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IVault {
    function deposit() external payable;
    function vulnerableWithdraw() external;
    function safeWithdraw() external;
}

// GoldThief - 重入攻击演示合约
contract GoldThief {
    IVault public targetVault;
    address public owner;
    uint public attackCount;
    bool public attackingSafe;

    constructor(address _vaultAddress) {
        targetVault = IVault(_vaultAddress);
        owner = msg.sender;
    }

    // 攻击有漏洞的金库
    function attackVulnerable() external payable {
        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH");

        attackingSafe = false;
        attackCount = 0;

        targetVault.deposit{value: msg.value}();
        targetVault.vulnerableWithdraw();
    }

    // 攻击有防护的金库
    function attackSafe() external payable {
        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH");

        attackingSafe = true;
        attackCount = 0;

        targetVault.deposit{value: msg.value}();
        targetVault.safeWithdraw();
    }

    // 接收函数 - 重入攻击的核心
    receive() external payable {
        attackCount++;

        if (!attackingSafe && address(targetVault).balance >= 1 ether && attackCount < 5) {
            targetVault.vulnerableWithdraw();
        }

        if (attackingSafe) {
            targetVault.safeWithdraw();
        }
    }

    // 提取窃取的 ETH
    function stealLoot() external {
        require(msg.sender == owner, "Only owner");
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "ETH transfer failed");
    }
}

// ==================== 安全最佳实践总结 ====================
//
// 1. Checks-Effects-Interactions 模式:
//    - Checks: 首先验证所有条件（require）
//    - Effects: 然后更新合约状态
//    - Interactions: 最后进行外部调用
//
// 2. 重入锁（Reentrancy Guard）:
//    - 使用布尔值或状态变量跟踪执行状态
//    - 在函数执行期间锁定合约
//
// 3. 实际案例 - The DAO 攻击:
//    - 2016年发生，损失360万ETH
//    - 攻击者利用递归调用漏洞
//    - 导致以太坊硬分叉（ETH/ETC）
//
// 4. 其他防护措施:
//    - 使用 transfer 或 send（2300 gas限制）
//    - 使用 pull 模式代替 push 模式
//    - 限制单次提款金额
//    - 进行专业的安全审计`:"",Yf=()=>Object.keys(xr).reduce((t,e)=>(t[e]={unlockedConcepts:[],totalConcepts:xr[e].concepts.length,interactionCount:0},t),{}),Ue=Do("progress",()=>{const t=F(Yf()),e=c=>String(c),n=(c,l)=>{const u=e(c),d=t.value[u];d&&!d.unlockedConcepts.includes(l)&&d.unlockedConcepts.push(l)},r=c=>{const l=e(c),u=t.value[l];u&&u.interactionCount++},s=c=>{const l=e(c);return t.value[l]},i=c=>{var u;const l=e(c);return((u=t.value[l])==null?void 0:u.unlockedConcepts)||[]};return{dayProgress:t,unlockConcept:n,incrementInteraction:r,getDayProgress:s,getUnlockedConcepts:i,isConceptUnlocked:(c,l)=>i(c).includes(l),getProgressPercentage:c=>{const l=e(c),u=t.value[l];return!u||u.totalConcepts===0?0:Math.floor(u.unlockedConcepts.length/u.totalConcepts*100)}}}),ft=Do("contract",()=>{const t=F({day1:{count:0,interactionCount:0},day2:{name:"",bio:"",interactionCount:0,hasStored:!1,hasRetrieved:!1},day3:{candidates:[],voteCount:{},interactionCount:0},day4:{owner:"",item:"",auctionEndTime:0,highestBidder:"",highestBid:0,ended:!1,bids:{},bidders:[],interactionCount:0},day5:{owner:"",treasureAmount:0,withdrawalAllowance:{},hasWithdrawn:{},userAddress:"0x"+Math.random().toString(16).substr(2,40),userAllowance:0,interactionCount:0},day6:{bankManager:"",members:[],registeredMembers:{},balance:{},userAddress:"0x"+Math.random().toString(16).substr(2,40),interactionCount:0,depositCount:0,withdrawCount:0},day7:{owner:"",userAddress:"",registeredFriends:{},friendList:[],balances:{},debts:{},interactionCount:0},day8:{owner:"",userAddress:"",isUserAdmin:!1,totalTipsReceived:0,tipPerPerson:{},tipsPerCurrency:{},supportedCurrencies:["USD","EUR","JPY","INR"],conversionRates:{USD:5e14,EUR:6e14,JPY:4e12,INR:7e12},interactionCount:0},day9:{owner:"",userAddress:"",isUserAdmin:!1,scientificCalculatorAddress:"",isAddressSet:!1,operationCount:0,operationHistory:[],interactionCount:0,challengeTasks:{setAddress:!1,powerCalc:!1,sqrtCalc:!1,permissionCheck:!1}},day10:{owner:"",userAddress:"",userProfile:{name:"",weight:0,isRegistered:!1},workoutHistory:[],totalWorkouts:0,totalDistance:0,milestones:{weightGoal:{achieved:!1,timestamp:0,title:"减重目标达成",icon:"⚖️"},workouts10:{achieved:!1,timestamp:0,title:"10次运动",icon:"🏃"},workouts50:{achieved:!1,timestamp:0,title:"50次运动大师",icon:"🏆"},distance100K:{achieved:!1,timestamp:0,title:"100公里里程碑",icon:"🌍"}},interactionCount:0},day11:{owner:"",userAddress:"",contractBalance:0,eventLog:[],interactionCount:0}}),e=()=>"0x"+Math.random().toString(16).substr(2,40),n=i=>{const o=`day${i}`,a=t.value[o];if(!a){console.warn(`Contract for day ${i} not found`);return}switch(i){case 5:a.owner||(a.owner=e()),a.userAddress||(a.userAddress=e());break;case 6:a.bankManager===""&&(a.bankManager=e(),a.members=[a.bankManager],a.registeredMembers={[a.bankManager]:!0,[a.userAddress]:!0},a.balance={[a.bankManager]:0,[a.userAddress]:0},a.members.push(a.userAddress));break;case 7:if(a.owner===""){const c=e();a.owner=c,a.userAddress=c,a.registeredFriends[c]=!0,a.friendList.push(c)}break;case 8:a.owner===""&&(a.owner=e(),a.userAddress=e());break;case 9:a.owner===""&&(a.owner=e(),a.userAddress=e(),a.isUserAdmin=!1);break;case 10:a.owner===""&&(a.owner=e(),a.userAddress=e());break;case 11:if(a.owner===""){const c=e();a.owner=c,a.userAddress=c,a.contractBalance=0,a.eventLog=[]}break}},r=i=>t.value[`day${i}`];return{contracts:t,initializeContract:n,getContract:r,updateContract:(i,o)=>{const a=r(i);a&&Object.assign(a,o)},generateAddress:e}}),Da={increment:21e3,reset:21e3,addData:4e4,retrieveData:0,addCandidate:5e4,vote:35e3,placeBid:45e3,endAuction:25e3,addTreasure:3e4,approveWithdrawal:4e4,withdrawTreasure:5e4,resetWithdrawalStatus:25e3,transferOwnership:35e3,getTreasureDetails:0,addMembers:45e3,depositAmountEther:35e3,withdrawAmount:4e4,getMembers:0,addFriend:45e3,depositIntoWallet:35e3,recordDebt:45e3,payFromWallet:5e4,transferEther:35e3,transferEtherViaCall:4e4,withdraw:35e3,checkBalance:0,addCurrency:45e3,tipInEth:4e4,tipInCurrency:5e4,withdrawTips:35e3,transferOwnership8:35e3,transfer13:35e3,approve13:3e4,transferFrom13:4e4,getBalance13:0,getAllowance13:0,createBasicBox:8e4,createPremiumBox:1e5,createTimeLockedBox:12e4,storeSecret:35e3,getSecret:0,transferOwnership14:4e4,setMetadata:3e4,getMetadata:0,getUnlockTime:0,getRemainingLockTime:0,completeOwnershipTransfer:45e3,createProposal15:6e4,vote15:4e4,executeProposal15:35e3,setProfile16:35e3,registerPlugin16:25e3,runPlugin16:45e3,runPluginView16:0,createPlan17:45e3,upgradeTo17:35e3,subscribe17:5e4,pauseSubscription17:3e4,resumeSubscription17:3e4,isSubscribed17:0,checkRainfall18:0,purchaseInsurance18:45e3,claimPayout18:5e4,fastForwardTime18:0,withdrawBalance18:35e3,generateSignature19:0,enterEvent19:65e3,checkEntered19:0,getParticipants19:0,deposit20:45e3,vulnerableWithdraw20:5e4,safeWithdraw20:35e3,checkVaultStatus20:0},Ba=4e-8,Zf={function:{name:"函数交互",icon:"🎯",unlockAt:1,message:"你刚刚调用了 Solidity 中的第一个函数！在区块链上，用户与合约的所有交互都是通过函数完成的。",code:`function click() public {
    // 你的点击在这里触发
}`},increment:{name:"自增操作",icon:"➕",unlockAt:2,message:'你发现了 `++` 这个操作符的作用！它的意思是"在原来的基础上加 1"。',code:"count++;  // 等同于 count = count + 1;"},uint256:{name:"uint256 变量",icon:"🔢",unlockAt:3,message:"你刚刚修改了一个 `uint256` 类型的变量。`uint` = 无符号整数（只能存正数），`256` = 能存超级大的数字。",code:"uint256 public count;  // 能存储超大数字"},contract:{name:"contract 结构",icon:"🏗️",unlockAt:4,message:'欢迎来到你的第一个 `contract`！你现在看到的交互界面，就是这个"合约"的前端。没有它，就没有智能合约世界！',code:`contract ClickCounter {
    uint256 public count;
    
    function click() public {
        count++;
    }
}`},string:{name:"string 类型",icon:"📝",unlockAt:1,message:"你刚刚使用了 `string` 类型！它可以存储文本数据，比如名字、描述等信息。",code:`string name;  // 存储文本数据
string bio;   // 存储简介`},private:{name:"private 变量",icon:"🔒",unlockAt:2,message:"你发现了 `private` 关键字！表示这个变量只能在合约内部访问，外部无法直接读取。",code:"string private name;  // 只能在合约内部访问"},memory:{name:"memory 存储",icon:"💾",unlockAt:3,message:"你使用了 `memory` 关键字！表示数据存储在内存中，只在函数执行期间存在，执行完毕后自动清除。",code:`function add(string memory _name) public {
    // _name 存储在内存中，临时使用
}`},view:{name:"view 函数",icon:"👁️",unlockAt:4,message:"你调用了 `view` 函数！它只读取数据不修改状态，因此不消耗 Gas，这是优化合约的重要方法。",code:`function retrieve() public view returns (string memory) {
    return name;  // 只读取，不修改
}`},parameters:{name:"函数参数",icon:"📥",unlockAt:5,message:"你使用了函数参数！参数让函数能够接收外部传入的数据，使函数更加灵活。",code:`function add(string memory _name, string memory _bio) public {
    // _name 和 _bio 是参数
}`},returns:{name:"返回值",icon:"📤",unlockAt:6,message:"你使用了 `returns` 关键字！它定义了函数返回的数据类型，让函数能够向调用者返回结果。",code:`function retrieve() public view returns (string memory, string memory) {
    return (name, bio);  // 返回多个值
}`},array:{name:"数组类型",icon:"📋",unlockAt:1,message:"你刚刚创建了数组！`candidateNames` 数组用来存储所有候选人的姓名。",code:`string[] public candidateNames;  // 声明字符串数组
candidateNames.push("Alice");  // 添加第一个候选人`},push:{name:"push 方法",icon:"➕",unlockAt:2,message:"你使用了 `push` 方法！它在数组末尾添加新元素，每次添加候选人都会用到它。",code:`candidateNames.push("Alice");  // 添加 Alice 到数组末尾
candidateNames.push("Bob");    // 添加 Bob 到数组末尾`},mapping:{name:"映射类型",icon:"🗺️",unlockAt:3,message:"你发现了 `mapping` 映射！它用候选人姓名作为键，票数作为值，存储投票结果。",code:`mapping(string => uint256) voteCount;  // 声明映射
voteCount["Alice"] = 0;  // 初始化票数为0`},compound_assignment:{name:"复合赋值",icon:"⚡",unlockAt:4,message:"你使用了 `+=` 复合赋值运算符！每次投票都会将候选人的票数加1。",code:'voteCount["Alice"] += 1;  // 票数加1，等同于 voteCount["Alice"] = voteCount["Alice"] + 1;'},constructor:{name:"构造函数",icon:"🏗️",unlockAt:1,message:"你刚刚调用了构造函数！它只在合约部署时执行一次，用于初始化合约的状态变量。",code:`constructor(string memory _item, uint _biddingTime) {
    owner = msg.sender;
    item = _item;
    auctionEndTime = block.timestamp + _biddingTime;
}`},msg_sender:{name:"msg.sender",icon:"📧",unlockAt:2,message:"你使用了 `msg.sender`！它表示当前调用合约的地址，可以是用户钱包或其他合约。",code:`address public owner = msg.sender;  // 部署者成为所有者
function bid() external {
    bids[msg.sender] = amount;  // 记录竞拍者出价
}`},block_timestamp:{name:"block.timestamp",icon:"⏰",unlockAt:3,message:"你使用了 `block.timestamp`！它返回当前区块的时间戳（Unix时间，秒），常用于时间相关的逻辑。",code:`uint public auctionEndTime = block.timestamp + _biddingTime;  // 设置拍卖结束时间
require(block.timestamp < auctionEndTime, "Auction has ended.");  // 检查时间`},require:{name:"条件检查",icon:"✅",unlockAt:4,message:"你使用了 `require` 语句！它在条件不满足时回滚交易，是合约安全的重要机制。",code:`require(amount > 0, "Bid amount must be greater than zero.");
require(block.timestamp < auctionEndTime, "Auction has already ended.");`},external:{name:"external 函数",icon:"🌐",unlockAt:5,message:"你使用了 `external` 函数！它只能从合约外部调用，比 `public` 更节省 Gas。",code:`function bid(uint amount) external {
    // 只能从外部调用，不能在合约内部调用
}`},address_type:{name:"地址类型",icon:"🏠",unlockAt:6,message:"你使用了 `address` 类型！它存储以太坊地址（钱包地址或合约地址），是区块链交互的核心。",code:`address public owner;  // 所有者地址
address private highestBidder;  // 最高出价者地址
mapping(address => uint) public bids;  // 地址到出价的映射`},bool_type:{name:"布尔类型",icon:"🔘",unlockAt:7,message:"你使用了 `bool` 类型！它只有 `true` 或 `false` 两个值，用于标记状态。",code:`bool public ended;  // 拍卖是否已结束
ended = true;  // 标记拍卖结束
require(!ended, "Auction already ended.");  // 检查状态`},modifier:{name:"修饰符",icon:"🛡️",unlockAt:1,message:"你使用了 `modifier`！它用于为函数添加前置条件检查，确保只有满足条件的调用者才能执行函数。",code:`modifier onlyOwner() {
    require(msg.sender == owner, "Only owner");
    _;  // 继续执行被修饰的函数
}`},zero_address:{name:"零地址检查",icon:"⚠️",unlockAt:2,message:"你检查了 `address(0)` 零地址！它表示一个无效的地址，通常用于检查地址参数是否有效。",code:`require(newOwner != address(0), "Invalid address");  // 确保不是零地址
address(0)  // 零地址，表示无效地址`},return_statement:{name:"返回语句",icon:"↩️",unlockAt:3,message:"你了解了返回语句的用法！继续解锁更多概念吧！",code:`function withdrawTreasure(uint256 amount) public {
    if (msg.sender == owner) {
        return;  // 所有者提前退出，不执行后续逻辑
    }
    
    require(allowance > 0, "No allowance");
    treasureAmount -= allowance;
}`},address_mapping_balance:{name:"地址映射余额",icon:"💰",unlockAt:1,message:"你刚刚使用了地址映射来存储每个用户的余额！mapping(address => uint256) 是存储用户资产的核心数据结构。",code:`mapping(address => uint256) balance;

balance[0x123...] = 1000000;  // 存储余额
uint256 amount = balance[msg.sender];  // 读取余额`},payable:{name:"可支付函数",icon:"💵",unlockAt:2,message:"你使用了 `payable` 关键字！它让函数能够接收以太币，这是处理资金交易的关键。",code:`function deposit() public payable {
    // 这个函数可以接收以太币
    require(msg.value > 0, "Must send ETH");
    balance[msg.sender] += msg.value;
}`},msg_value:{name:"发送金额",icon:"💳",unlockAt:3,message:"你使用了 `msg.value`！它表示调用函数时发送的以太币数量（以wei为单位），是获取转账金额的标准方式。",code:`function deposit() public payable {
    uint256 amount = msg.value;  // 获取发送的ETH数量
    balance[msg.sender] += amount;
}`},wei_unit:{name:"Wei 单位",icon:"⚖️",unlockAt:4,message:"你了解了以太币的最小单位 wei！1 ETH = 10^18 wei，这是以太坊计价的基础单位。",code:`// 以太币单位
1 wei = 0.000000000000000001 ETH
1 gwei = 0.000000001 ETH
1 ETH = 1000000000000000000 wei

balance[msg.sender] += 1000000000000000000;  // 增加 1 ETH`},ether_deposit_withdraw:{name:"存取逻辑",icon:"🏦",unlockAt:5,message:"你掌握了以太币的存取核心逻辑！检查余额、增减余额、验证输入，这是任何金融合约的基础。",code:`function deposit() public payable {
    require(msg.value > 0, "Invalid amount");
    balance[msg.sender] += msg.value;
}

function withdraw(uint256 amount) public {
    require(amount > 0, "Invalid amount");
    require(balance[msg.sender] >= amount, "Insufficient balance");
    balance[msg.sender] -= amount;
}`},withdraw_pattern:{name:"提现模式 (Withdraw)",icon:"🏧",unlockAt:7,message:"你掌握了提现模式！与其主动将资金发送给用户（易受攻击），不如让用户自己来提取他们的资金，这是智能合约安全的核心原则之一。",code:`function withdraw(uint256 _amount) public {
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] -= _amount;
    (bool success, ) = payable(msg.sender).call{value: _amount}("");
    require(success);
}`},nested_mapping:{name:"嵌套映射",icon:"🗂️",unlockAt:1,message:"你掌握了如何使用嵌套映射 (mapping in mapping)！这是处理复杂关系（如“谁欠谁多少钱”）的终极武器。",code:"mapping(address => mapping(address => uint256)) public debts;"},address_payable:{name:"Payable 地址",icon:"💸",unlockAt:2,message:"你使用了 address payable！只有标记为 payable 的地址才能接收 Ether，否则编译器会报错保护资金安全。",code:"address payable user = payable(msg.sender);"},debt_tracking:{name:"债务追踪",icon:"📊",unlockAt:3,message:"区块链就是一本账本！你刚刚在链上永久记录了一笔债权关系，且任何人无法抵赖。",code:"debts[debtor][msg.sender] += amount;"},internal_transfer:{name:"内部记账转账",icon:"🔄",unlockAt:4,message:"你完成了一次“内部转账”！这并没有发生真实的链上交易，只是在合约账本里扣减了一个人的余额并增加给另一个人，非常省 Gas。",code:`balances[msg.sender] -= amount;
balances[creditor] += amount;`},transfer_method:{name:"transfer() 转账",icon:"📤",unlockAt:5,message:"你使用了经典的 .transfer() 方法。它会自动在转账失败时触发 revert，是最简单安全的转账方式。",code:"payable(to).transfer(amount);"},call_method:{name:"call() 转账",icon:"📡",unlockAt:6,message:"你使用了更强大的 .call() 方法！它是目前以太坊开发中最推荐的转账方式，因为它允许你灵活处理 Gas 限制和错误结果。",code:`(bool success, ) = to.call{value: amount}("");
require(success, "Transfer failed");`},modifier_onlyOwner:{name:"onlyOwner 修饰符",icon:"🛡️",unlockAt:1,message:"你发现了 `onlyOwner`！这是一个自定义修饰符，专门用来限制只有管理员（合约拥有者）才能执行特定的函数（如提现、改汇率）。",code:`modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can perform this action");
    _;
}`},payable_tip:{name:"payable 支付关键字",icon:"💰",unlockAt:2,message:"你成功进行了一次带钱的交互！在 Solidity 中，只有标记为 `payable` 的函数才能接收随交易发送的以太币。",code:`function tipInEth() public payable {
    // 带有 payable 才能收钱
}`},msg_value_tip:{name:"msg.value 发送金额",icon:"💸",unlockAt:3,message:"你发送了 ETH！`msg.value` 是一个全局变量，代表了你在调用这个函数时额外付出的金钱（单位是 wei）。",code:`tipPerPerson[msg.sender] += msg.value;
totalTipsReceived += msg.value;`},address_balance:{name:"合约余额查询",icon:"🏦",unlockAt:4,message:"想要知道存钱柜里有多少钱？`address(this).balance` 会返回当前智能合约在链上的全部实时余额。",code:`uint256 contractBalance = address(this).balance;
require(contractBalance > 0, "No tips to withdraw");`},call_withdraw:{name:"底层 call 转账",icon:"📡",unlockAt:5,message:'管理员提现成功！使用 `.call{value: ...}("")` 是目前以太坊开发中推荐的由合约向外部地址转账的最灵活方式。',code:`(bool success, ) = payable(owner).call{value: contractBalance}("");
require(success, "Transfer failed");`},mapping_rates:{name:"法币汇率映射",icon:"💹",unlockAt:6,message:"智能合约也能换钱！这里使用了 `mapping(string => uint256)` 来存储不同法币（字符串）对应的 ETH 汇率（数字）。",code:`mapping(string => uint256) public conversionRates;

conversionRates["USD"] = 5 * 10**14;`},pure_function:{name:"Pure 纯函数",icon:"⚡",unlockAt:1,message:"你使用了 `pure` 函数！pure函数不读取也不修改区块链状态，执行快速且不消耗Gas，适合简单的数学计算。",code:`function add(uint256 a, uint256 b) public pure returns(uint256) {
    return a + b;  // 纯计算，不访问状态
}`},view_function:{name:"View 视图函数",icon:"👁️",unlockAt:2,message:"你使用了 `view` 函数！view函数可以读取状态变量但不修改它们，适合查询操作，不消耗Gas。",code:`function calculatePower(uint256 base, uint256 exponent) public view returns(uint256) {
    // 读取 scientificCalculatorAddress 状态变量
    ScientificCalculator calc = ScientificCalculator(scientificCalculatorAddress);
    return calc.power(base, exponent);
}`},cross_contract_call:{name:"跨合约调用",icon:"📡",unlockAt:3,message:"你完成了跨合约调用！一个合约可以通过地址调用另一个合约的函数，实现合约间的组合与协作。",code:`// Calculator合约调用ScientificCalculator合约
ScientificCalculator scientificCalc = 
    ScientificCalculator(scientificCalculatorAddress);
uint256 result = scientificCalc.power(base, exponent);`},interface_call:{name:"接口方式调用",icon:"🔌",unlockAt:4,message:"你使用了接口方式调用外部合约！通过创建接口实例，可以像调用本地函数一样调用外部合约。",code:`// 创建外部合约接口实例
ScientificCalculator scientificCalc = 
    ScientificCalculator(scientificCalculatorAddress);

// 调用外部合约函数
uint256 result = scientificCalc.power(base, exponent);`},low_level_call:{name:"底层 Call 调用",icon:"🔧",unlockAt:5,message:"你使用了底层 `call` 方法！这是最灵活的跨合约调用方式，通过 `abi.encodeWithSignature` 编码函数调用。",code:`// 编码函数签名
bytes memory data = abi.encodeWithSignature(
    "squareRoot(int256)", number
);

// 发起底层call调用
(bool success, bytes memory returnData) = 
    scientificCalculatorAddress.call(data);

// 解码返回数据
uint256 result = abi.decode(returnData, (uint256));`},newton_iteration:{name:"牛顿迭代法",icon:"📐",unlockAt:7,message:"你了解了牛顿迭代法！Solidity不支持浮点数，通过迭代逼近真实值是常用的数学算法实现方式。",code:`function squareRoot(int256 number) public pure returns(int256) {
    int256 result = number / 2;
    // 限制10轮，防止Gas耗尽
    for(uint256 i = 0; i < 10; i++) {
        result = (result + number / result) / 2;
    }
    return result;
}`},contract_composition:{name:"合约组合",icon:"🧩",unlockAt:8,message:"恭喜你掌握了合约组合！合约可以像乐高积木一样组合复用，构建复杂的去中心化应用。",code:`// Calculator合约组合了ScientificCalculator合约
contract Calculator {
    address public scientificCalculatorAddress;
    
    // 通过接口调用外部合约功能
    function calculatePower(uint256 base, uint256 exponent) 
        public view returns(uint256) {
        ScientificCalculator calc = 
            ScientificCalculator(scientificCalculatorAddress);
        return calc.power(base, exponent);
    }
}`},struct_definition:{name:"结构体定义",icon:"📦",unlockAt:1,message:"你刚刚使用了 `struct` 结构体！它可以打包多个不同类型的变量，创建自定义数据类型。",code:`struct UserProfile {
    string name;       // 用户姓名
    uint256 weight;    // 用户体重
    bool isRegistered; // 是否已注册
}

// 创建结构体实例
UserProfile memory newUser = UserProfile({
    name: "张三",
    weight: 70,
    isRegistered: true
});`},array_in_mapping:{name:"映射中的数组",icon:"🗂️",unlockAt:2,message:"你发现了 mapping 到数组的用法！这可以为每个用户存储一个运动记录列表。",code:`// mapping 到数组
mapping(address => WorkoutActivity[]) private workoutHistory;

// 添加新记录
workoutHistory[msg.sender].push(newWorkout);

// 获取记录数量
uint256 count = workoutHistory[msg.sender].length;`},multiple_mappings:{name:"多个映射组合",icon:"🗺️",unlockAt:3,message:"你看到了多个映射如何协同工作！userProfiles、totalWorkouts、totalDistance 分别存储不同维度的数据。",code:`// 多个映射协同工作
mapping(address => UserProfile) public userProfiles;        // 用户资料
mapping(address => WorkoutActivity[]) private workoutHistory;  // 运动历史
mapping(address => uint256) public totalWorkouts;            // 运动次数
mapping(address => uint256) public totalDistance;            // 总距离

// 它们共同构建了完整的数据视图`},storage_keyword:{name:"storage 关键字",icon:"💾",unlockAt:4,message:"你使用了 `storage` 关键字！它创建状态变量的引用，直接修改原数据而不是创建副本，非常节省 Gas。",code:`function updateWeight(uint256 _newWeight) public {
    // storage 关键字创建引用
    UserProfile storage profile = userProfiles[msg.sender];
    
    // 直接修改原数据，不创建副本
    profile.weight = _newWeight;
    
    // ❌ 如果用 memory，会创建副本，修改不会生效
    // UserProfile memory profile = userProfiles[msg.sender];
}`},event_logging:{name:"事件日志",icon:"📋",unlockAt:1,message:"你触发了事件！事件记录在区块链日志中，前端可以监听事件来获取实时通知。",code:`// 定义事件
event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
event WorkoutLogged(address indexed user, string activityType, uint256 duration);

// 触发事件
emit UserRegistered(msg.sender, "张三", block.timestamp);
emit WorkoutLogged(msg.sender, "跑步", 1800);`},milestone_detection:{name:"里程碑检测",icon:"🏆",unlockAt:5,message:"你完成了里程碑检测！通过条件判断检测用户是否达成特定目标，并触发相应奖励。",code:`// 运动次数里程碑
if (totalWorkouts == 10) {
    emit MilestoneAchieved(msg.sender, "10次运动达成！");
} else if (totalWorkouts == 50) {
    emit MilestoneAchieved(msg.sender, "50次运动大师！");
}

// 距离里程碑（跨越检测）
if (totalDistance >= 100000 && totalDistance - distance < 100000) {
    emit MilestoneAchieved(msg.sender, "100公里里程碑！");
}`},timestamp_usage:{name:"时间戳使用",icon:"⏰",unlockAt:2,message:"你使用了 `block.timestamp`！它记录当前区块的时间戳，用于标记运动记录的时间。",code:`WorkoutActivity memory newWorkout = WorkoutActivity({
    activityType: "跑步",
    duration: 1800,
    distance: 5000,
    timestamp: block.timestamp  // 记录运动时间
});`},onlyRegistered_modifier:{name:"onlyRegistered 修饰符",icon:"🛡️",unlockAt:1,message:"你使用了 `onlyRegistered` 修饰符！它确保只有注册用户才能调用特定函数，保护合约安全。",code:`// 定义修饰符
modifier onlyRegistered() {
    require(userProfiles[msg.sender].isRegistered, "User not registered");
    _;  // 继续执行函数
}

// 使用修饰符
function logWorkout(...) public onlyRegistered {
    // 只有注册用户才能执行
}`}},Qf={inheritance:{name:"合约继承",icon:"🧬",unlockAt:1,message:"你刚刚体验了合约继承！VaultMaster 通过 `is Ownable` 继承了父合约的所有功能，这是代码复用的核心机制。",code:`// 父合约
contract Ownable {
    address private owner;
    // ...
}

// 子合约继承父合约
contract VaultMaster is Ownable {
    // 自动拥有 Ownable 的所有功能
    function withdraw() public onlyOwner {
        // 可以使用继承的 onlyOwner 修饰符
    }
}`},import_statement:{name:"导入语句",icon:"📥",unlockAt:2,message:"你了解了 `import` 语句！它允许合约引用其他文件中的合约定义，是模块化开发的基础。",code:`// 导入外部合约
import "./Ownable.sol";

// 现在可以使用 Ownable 合约了
contract VaultMaster is Ownable {
    // ...
}`},constructor:{name:"构造函数",icon:"🏗️",unlockAt:1,message:"你刚刚了解了构造函数！它在合约部署时自动执行一次，用于初始化关键状态变量。",code:`contract Ownable {
    address private owner;
    
    // 构造函数：部署时自动执行
    constructor() {
        owner = msg.sender;  // 设置部署者为所有者
    }
}`},private_visibility:{name:"私有可见性",icon:"🔒",unlockAt:2,message:"你了解了 `private` 可见性！它确保变量只能在当前合约内部访问，提供最强的封装保护。",code:`contract Ownable {
    // private：只有当前合约可以访问
    address private owner;
    
    // public：任何人都可以访问
    function ownerAddress() public view returns (address) {
        return owner;  // 通过函数间接访问
    }
}`},event_logging:{name:"事件日志",icon:"📋",unlockAt:1,message:"你触发了事件！事件是合约与前端通信的重要机制，记录关键操作到区块链日志中。",code:`// 定义事件
event DepositSuccessful(
    address indexed depositor,
    uint256 amount
);

// 触发事件
function deposit() public payable {
    emit DepositSuccessful(msg.sender, msg.value);
}`},indexed_parameter:{name:"索引参数",icon:"🏷️",unlockAt:2,message:"你了解了 `indexed` 关键字！它允许前端按特定参数过滤事件日志，提高查询效率。",code:`// indexed 参数可以被过滤查询
event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
);

// 前端可以按地址过滤事件
// 例如：查找特定用户的所有转账记录`},transfer_ownership:{name:"所有权转移",icon:"🔑",unlockAt:1,message:"你刚刚完成了所有权转移！这是合约管理的核心功能，确保合约可以安全地更换管理者。",code:`function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Invalid address");
    
    address oldOwner = owner;
    owner = newOwner;
    
    emit OwnershipTransferred(oldOwner, newOwner);
}`},onlyOwner_modifier:{name:"onlyOwner 修饰符",icon:"🛡️",unlockAt:1,message:"你体验了 `onlyOwner` 修饰符的权限控制！它确保只有合约所有者才能执行敏感操作。",code:`// 定义修饰符
modifier onlyOwner() {
    require(msg.sender == owner, "Only owner");
    _;  // 继续执行被修饰的函数
}

// 使用修饰符保护函数
function withdraw() public onlyOwner {
    // 只有所有者可以执行
}`}},ep={constructor_mint:{name:"构造函数铸造",icon:"🪙",unlockAt:1,message:"你了解了构造函数铸造机制！合约部署时，构造函数会自动执行，从 address(0) 铸造代币给部署者。",code:`constructor(uint256 _initialSupply){
    // 计算实际总供应量
    totalSupply = _initialSupply * (10 ** decimals);
    // 将所有代币分配给部署者
    balanceOf[msg.sender] = totalSupply;
    // 触发转账事件，from地址为0表示新铸造
    emit Transfer(address(0), msg.sender, _initialSupply);
}`},zero_address_mint:{name:"零地址铸造",icon:"📍",unlockAt:1,message:"你了解了零地址的特殊含义！在 ERC20 中，Transfer(address(0), to, amount) 表示铸造新代币，Transfer(from, address(0), amount) 表示销毁代币。",code:`// 从零地址转出 = 铸造（创建新代币）
emit Transfer(address(0), msg.sender, amount);

// 转入零地址 = 销毁（永久移除代币）
emit Transfer(msg.sender, address(0), amount);`},internal_function:{name:"internal 函数",icon:"🔒",unlockAt:2,message:"你了解了 internal 函数！它只能在合约内部调用，外部无法直接访问。这是代码封装的重要手段，_transfer 就是典型的内部函数。",code:`// internal 函数：只能在合约内部调用
function _transfer(address _from, address _to, uint256 _value) 
    internal virtual {
    // 实际执行转账逻辑
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
    emit Transfer(_from, _to, _value);
}

// public 函数调用 internal 函数
function transfer(address _to, uint256 _value) public returns (bool) {
    _transfer(msg.sender, _to, _value);  // 内部调用
    return true;
}`},virtual_function:{name:"virtual 函数",icon:"🧬",unlockAt:3,message:"你了解了 virtual 关键字！它允许子合约重写（override）父合约的函数。这是实现 ERC20 扩展（如 ERC20Pausable、ERC20Votes）的基础机制。",code:`// 父合约：标记函数可被重写
contract MyToken {
    function _transfer(address _from, address _to, uint256 _value) 
        internal virtual {  // ← virtual 允许重写
        // 基础转账逻辑
    }
}

// 子合约：重写父合约函数
contract MyTokenWithFee is MyToken {
    function _transfer(address _from, address _to, uint256 _value) 
        internal override {  // ← override 重写
        // 自定义逻辑（如收取手续费）
        super._transfer(_from, _to, _value);  // 调用父函数
    }
}`}},Gh=t=>({function:"📖 这是函数的基本概念，它是智能合约的基本构建模块。",increment:"📖 自增操作是编程中常见的操作，用于快速增加数值。",uint256:"📖 uint256 是 Solidity 中最常用的整数类型，了解它很重要。",contract:"📖 智能合约是区块链上的自动执行代码，理解它的结构很关键。",string:"📖 string 类型用于存储文本数据，是智能合约中常用的数据类型之一。",private:"📖 private 关键字限制变量的访问范围，提高合约的安全性。",memory:"📖 memory 数据位置用于临时存储，只在函数执行期间存在。",view:"📖 view 函数不修改状态，不消耗 Gas，是优化合约性能的重要方法。",parameters:"📖 函数参数让函数能够接收外部数据，使函数更加灵活和可复用。",returns:"📖 returns 关键字定义函数返回值，让函数能够向调用者返回结果。",array:"📖 数组是存储多个相同类型数据的容器，在 Solidity 中广泛使用。",mapping:"📖 映射是 Solidity 中的键值对存储结构，通过键快速查找对应的值。",push:"📖 push 方法是数组的常用操作，可以在数组末尾动态添加元素。",compound_assignment:"📖 复合赋值运算符将运算和赋值结合在一起，使代码更加简洁。",constructor:"📖 构造函数只在合约部署时执行一次，用于初始化合约的状态变量。",msg_sender:"📖 msg.sender 表示当前调用合约的地址，是区块链交互的核心。",block_timestamp:"📖 block.timestamp 返回当前区块的时间戳，常用于时间相关的逻辑。",require:"📖 require 语句在条件不满足时回滚交易，是保证合约安全的重要机制。",external:"📖 external 函数只能从合约外部调用，比 public 更节省 Gas。",address_type:"📖 address 类型存储以太坊地址，是区块链交互的核心数据类型。",bool_type:"📖 bool 类型只有 true 或 false 两个值，用于标记状态。",modifier:"📖 修饰符用于为函数添加前置条件检查，是权限控制的重要机制。",zero_address:"📖 零地址 address(0) 表示一个无效的地址，通常用于检查地址参数是否有效。",return_statement:"📖 return 语句让函数返回指定的值给调用者，是函数输出结果的方式。",address_mapping_balance:"📖 地址映射 mapping(address => uint256) 是存储用户资产的核心数据结构，通过地址快速查找对应的余额。",payable:"📖 payable 关键字让函数能够接收以太币，这是处理资金交易的关键特性。",msg_value:"📖 msg.value 表示调用函数时发送的以太币数量（以wei为单位），是获取转账金额的标准方式。",wei_unit:"📖 wei 是以太币的最小单位，1 ETH = 10^18 wei，这是以太坊计价的基础单位。",ether_deposit_withdraw:"📖 存取逻辑包括检查余额、增减余额、验证输入，这是任何金融合约的基础。",nested_mapping:"📖 嵌套映射 mapping(A => mapping(B => C)) 允许你在 Solidity 中创建像多维数组或字典中嵌套字典的复杂数据结构。",address_payable:"📖 payable 地址类型拥有 transfer 和 call 方法来发送 Ether。没有 fallback 且非 payable 的地址无法接收以太币。",debt_tracking:"📖 债务追踪展示了区块链账本的不变性和透明性，确保每一笔债权和债务都在链上清晰可查的特性。",internal_transfer:"📖 内部账本系统(Internal Accounting)只改变合约内存的数字而不进行链上交易转账，是处理多高频微支付的最佳实操。",transfer_method:"📖 .transfer() 将转账可用 gas 固定为 2300 防止重入，但当目标接收方智能合约的 fallback 逻辑超过一定 gas 时会导致资金卡死。",call_method:"📖 .call() 提供低级别的外部调用功能，转账时能够转发所有剩余 gas 或自定义数量的 gas 以保证外部操作能顺利执行并返回回调状态。",withdraw_pattern:"📖 提现优于发送。要求用户主动调用 withdraw()，避免了遍历用户数组发钱（可能超出 block gas 限制）以及转账失败阻塞整个合约的风险。",modifier_onlyOwner:"📖 修饰符（Modifier）允许你在不重复编写核心检查逻辑的情况下，重用访问控制代码。`_` 符号代表了目标函数体的执行位置。",payable_tip:"📖 `payable` 是一个函数可见性/状态修饰符。如果没有它，任何尝试向该函数发送 Ether 的交易都会被以太坊虚拟机拒绝并回滚。",msg_value_tip:"📖 `msg.value` 是当前交易附带的以太币数量，以 wei 为单位。它是智能合约处理实时支付的桥梁。",address_balance:"📖 合约不仅可以操作别人的钱，还可以管理属于它自己的钱。`address(this).balance` 让你能实时掌控合约金库的‘水位’。",call_withdraw:"📖 `.call()` 是一个底层原语。在转账时，它能够处理复杂的 Fallback 逻辑，并明确返回一个成功/失败的布尔值，比旧的 `transfer` 更具鲁活性。",mapping_rates:"📖 虽然以太坊没有内置汇率，但我们可以通过合约内部的映射来手动维护一组兑换比例，从而实现'打赏 1 美元 = 支付 X 数量 ETH'的功能。",pure_function:"📖 pure 函数承诺不读取也不修改区块链的状态变量。这意味着它的执行结果完全取决于输入参数，可以在本地快速计算，不需要消耗 Gas。",view_function:"📖 view 函数可以读取状态变量但不修改它们。由于不修改状态，view 函数也可以在本地执行，不消耗 Gas，适合用于查询操作。",cross_contract_call:"📖 跨合约调用是 Solidity 的核心特性之一。通过合约地址，一个合约可以调用另一个合约的函数，实现功能的组合和复用，就像乐高积木一样。",interface_call:"📖 接口方式调用是最常用的跨合约调用方法。通过创建外部合约的接口实例，可以像调用本地函数一样调用外部合约，代码清晰易读。",low_level_call:"📖 底层 call 方法提供了最大的灵活性。它通过 abi.encodeWithSignature 编码函数调用，可以调用任何函数，即使接口未知。但使用起来更复杂，需要手动处理返回值。",newton_iteration:"📖 牛顿迭代法是一种快速逼近方程根的算法。在 Solidity 中，由于不支持浮点数运算，我们使用整数运算通过多次迭代来逼近真实值。限制迭代次数可以防止 Gas 耗尽。",contract_composition:"📖 合约组合是 Solidity 的重要设计理念。通过将功能拆分到多个合约，可以实现代码复用、降低复杂度、提高可维护性。这是构建复杂 DApp 的基础。",struct_definition:"📖 `struct` 结构体允许你定义自定义的数据类型，将多个不同类型的变量打包在一起。这是组织复杂数据的有效方式，让代码更加清晰和易于维护。",array_in_mapping:"📖 Solidity 允许将映射指向数组，如 `mapping(address => WorkoutActivity[])`。这样每个地址都有一个动态数组，非常适合存储用户的历史记录、交易列表等一对多的数据关系。",multiple_mappings:"📖 在实际应用中，经常使用多个 mapping 来存储不同维度的数据。比如一个 mapping 存用户资料，另一个存用户余额。通过同一个 key（如用户地址）可以关联访问多个数据结构。",storage_keyword:"📖 `storage` 和 `memory` 是 Solidity 中两个重要的数据位置关键字。`storage` 变量永久存储在区块链状态中，而 `memory` 变量只在函数执行期间临时存在。使用 `storage` 引用可以直接修改状态变量，节省 Gas。",event_logging:"📖 事件（Event）是 Solidity 的日志机制。通过 `emit` 触发事件，数据会被记录在区块链的交易日志中。前端可以监听事件来实现实时通知、记录历史等功能，事件是 DApp 前后端通信的重要桥梁。",milestone_detection:"📖 里程碑检测是游戏化应用的核心机制。通过条件判断（如 `if (count == 10)`）检测用户是否达成特定目标，并触发相应奖励或通知。这能激励用户持续使用产品。",timestamp_usage:"📖 `block.timestamp` 是当前区块的时间戳（Unix 时间，秒）。它常用于记录事件发生时间、设置时间限制、计算时间差等。注意它由矿工设置，存在约15秒的误差，不应用于精确计时。",onlyRegistered_modifier:"📖 修饰符（Modifier）是 Solidity 的复用机制，用于在函数执行前添加前置条件检查。`onlyRegistered` 确保只有满足条件的用户（已注册）才能调用函数。这简化了代码，避免了在每个函数中重复写检查逻辑。"})[t]||"📖 点击其他概念标签查看更多详细解释。",Kh=t=>({inheritance:"📖 合约继承是 Solidity 的核心特性之一。通过 `contract VaultMaster is Ownable`，子合约可以继承父合约的所有状态变量和函数，实现代码复用和模块化设计。",import_statement:"📖 `import` 语句用于导入其他合约文件，让你可以在当前合约中使用外部定义的合约。这是实现合约组合和代码复用的基础。",constructor:"📖 构造函数 `constructor()` 在合约部署时自动执行一次，用于初始化合约的状态变量。在 Ownable 中，它将合约部署者设置为初始所有者。",private_visibility:"📖 `private` 可见性修饰符表示变量只能在当前合约内部访问，即使是子合约也无法直接访问。这提供了最强的封装性，保护敏感数据。",event_logging:"📖 事件（Event）用于记录重要的合约操作到区块链日志中。前端可以监听事件来实现实时通知。`DepositSuccessful` 和 `WithdrawSuccessful` 记录了资金流动。",indexed_parameter:"📖 `indexed` 关键字标记事件参数，允许前端按该参数过滤和搜索事件日志。这在处理大量事件时非常有用，可以快速找到特定地址相关的事件。",transfer_ownership:"📖 `transferOwnership()` 函数实现了合约所有权的转移。只有当前所有者可以调用此函数，并且通常会检查新地址是否有效（非零地址）。",onlyOwner_modifier:"📖 `onlyOwner` 修饰符是权限控制的核心机制。它检查 `msg.sender` 是否等于 `owner`，如果不是则回滚交易。这是保护敏感操作（如提款）的标准做法。"})[t]||"📖 点击其他概念标签查看更多详细解释。",tp={erc20_standard:{name:"ERC20 标准",icon:"🪙",unlockAt:1,message:"你了解了 ERC20 代币标准！它是以太坊上最通用的代币规范，定义了代币的基本功能接口。",code:`// ERC20 标准接口
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}`},mapping_nested:{name:"嵌套映射",icon:"🗂️",unlockAt:2,message:"你发现了嵌套映射 mapping(address => mapping(address => uint256))！这是存储授权额度的核心数据结构。",code:`// 嵌套映射：记录每个地址授权给其他地址的额度
mapping(address => mapping(address => uint256)) public allowance;

// 示例：Alice 授权 Carol 使用 500 COM
allowance[Alice][Carol] = 500;  // Carol 可以使用 Alice 的 500 COM`},event:{name:"事件日志",icon:"📋",unlockAt:3,message:"你触发了事件！Transfer 和 Approval 事件记录了代币的转移和授权操作，前端可以监听这些事件。",code:`// 定义事件
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);

// 触发事件
emit Transfer(msg.sender, _to, _value);
emit Approval(msg.sender, _spender, _value);`},transfer:{name:"转账函数",icon:"💸",unlockAt:4,message:"你使用了 transfer 函数！它是 ERC20 最核心的功能，允许用户将自己的代币转给他人。",code:`// 转账函数：调用者将自己的代币转给他人
function transfer(address _to, uint256 _value) public returns (bool) {
    require(balanceOf[msg.sender] >= _value, "Not enough balance");
    _transfer(msg.sender, _to, _value);
    return true;
}`},approve:{name:"授权函数",icon:"✅",unlockAt:5,message:"你使用了 approve 函数！它允许你授权他人使用你的代币，这是 DeFi 应用的基础机制。",code:`// 授权函数：允许 spender 使用调用者的代币
function approve(address _spender, uint256 _value) public returns (bool) {
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
}`},allowance:{name:"授权额度",icon:"🔍",unlockAt:6,message:"你查询了 allowance！它返回被授权者可以使用的代币数量，是授权机制的重要组成部分。",code:`// 查询授权额度
function allowance(address _owner, address _spender) 
    public view returns (uint256) {
    return allowance[_owner][_spender];
}

// 使用场景：检查 Carol 还能使用 Alice 多少代币
uint256 remaining = allowance(Alice, Carol);  // 返回剩余额度`},transferFrom:{name:"代转账函数",icon:"🔄",unlockAt:7,message:"你使用了 transferFrom 函数！它允许被授权者代替他人转账，实现了'第三方代付'功能。",code:`// 代转账函数：被授权者从他人账户转账
function transferFrom(address _from, address _to, uint256 _value) 
    public returns (bool) {
    require(balanceOf[_from] >= _value, "Not enough balance");
    require(allowance[_from][msg.sender] >= _value, "Allowance too low");
    
    allowance[_from][msg.sender] -= _value;  // 减少授权额度
    _transfer(_from, _to, _value);
    return true;
}`}},jh=t=>({erc20_standard:"🪙 太棒了！你了解了 ERC20 代币标准！这是以太坊上最通用的代币规范。👉 查询 Alice 余额来学习 mapping 存储机制！",mapping_nested:"🗂️ 优秀！你了解了嵌套映射！这是 ERC20 授权机制的核心数据结构。👉 转账给 Bob 来学习事件和转账函数！",event:"📋 很好！你触发了事件日志！👉 继续探索更多功能！",transfer:"💸 太棒了！你使用了 transfer 函数！👉 授权给 Carol 来学习授权机制！",approve:"✅ 很好！你使用了 approve 函数！👉 查询 allowance 来学习授权额度查询！",allowance:"🔍 优秀！你了解了授权额度查询！👉 切换到 Carol 执行代转账来学习 transferFrom！",transferFrom:"🔄 太棒了！你使用了 transferFrom 函数！🎉 你已掌握 ERC20 全部核心功能！"})[t]||"📖 点击其他概念标签查看更多详细解释。",Xh=t=>({constructor_mint:"📖 构造函数铸造是 ERC20 代币的常见模式。合约部署时，构造函数自动执行，创建所有代币并分配给部署者。Transfer(address(0), ...) 事件表示这是铸造操作。",zero_address_mint:"📖 零地址 address(0) 在 ERC20 中有特殊含义。Transfer 事件中 from=address(0) 表示铸造（创建新代币），to=address(0) 表示销毁（移除代币）。这是行业标准约定。",internal_function:"📖 internal 是 Solidity 的可见性修饰符之一。与 public/external 不同，internal 函数只能在当前合约内部调用，不能从外部访问。这是代码封装的重要手段，_transfer 就是典型的内部辅助函数。",virtual_function:"📖 virtual 关键字标记函数可以被继承合约重写（override）。这是实现可扩展 ERC20（如带手续费的代币、可暂停代币）的基础。子合约使用 override 关键字重写，并用 super 调用父合约函数。"})[t]||"📖 点击其他概念标签查看更多详细解释。",Jh=t=>({erc20_standard:"📖 ERC20 是以太坊上最常用的代币标准，定义了代币的基本功能接口，包括转账、授权、查询余额等。所有符合 ERC20 标准的代币都可以在支持该标准的钱包和交易所中使用。",mapping_nested:"📖 嵌套映射 mapping(address => mapping(address => uint256)) 是 ERC20 中存储授权额度的核心数据结构。外层映射的 key 是代币持有者，内层映射的 key 是被授权者，value 是授权额度。",event:"📖 事件（Event）是 Solidity 的日志机制。ERC20 定义了 Transfer 和 Approval 两个标准事件，分别记录代币转移和授权操作。前端可以监听这些事件来实时更新界面。",transfer:"📖 transfer 函数是 ERC20 最核心的功能，允许代币持有者将自己的代币转给他人。函数会检查余额是否充足，然后更新双方余额并触发 Transfer 事件。",approve:"📖 approve 函数实现了授权机制，允许代币持有者授权他人使用自己的代币。这在 DeFi 应用中非常重要，比如授权 DEX 使用你的代币进行交易。",allowance:"📖 allowance 函数用于查询授权额度，返回被授权者还可以使用持有者的代币数量。在执行 transferFrom 之前，通常需要先检查 allowance 是否充足。",transferFrom:"📖 transferFrom 函数实现了代转账功能，允许被授权者代替持有者转账。这是 ERC20 的高级功能，常用于需要第三方代为执行转账的场景，如自动扣款、代理交易等。"})[t]||"📖 点击其他概念标签查看更多详细解释。",np={interface_definition:{name:"接口定义",icon:"🔌",unlockAt:1,message:"你了解了接口！接口定义了合约必须实现的功能规范，是实现多态和解耦的基础。",code:`// IDepositBox.sol - 定义存款盒的标准接口
interface IDepositBox {
    function storeSecret(string calldata secret) external;
    function getSecret() external view returns (string memory);
    function transferOwnership(address newOwner) external;
    function getBoxType() external view returns (string memory);
    function getOwner() external view returns (address);
}`},abstract_contract:{name:"抽象合约",icon:"🎭",unlockAt:2,message:"你了解了抽象合约！抽象合约可以包含未实现的函数（纯虚函数），不能被直接部署，只能被继承。",code:`// BaseDepositBox.sol - 抽象基础合约
abstract contract BaseDepositBox is IDepositBox {
    string internal secret;
    address internal owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    // 纯虚函数：必须由子合约实现
    function getBoxType() public view virtual returns (string memory);
}`},inheritance:{name:"合约继承",icon:"🧬",unlockAt:3,message:"你体验了合约继承！BasicDepositBox 继承了 BaseDepositBox 的所有功能，无需额外代码。",code:`// BasicDepositBox.sol - 简单继承
contract BasicDepositBox is BaseDepositBox {
    // 只继承父合约，不添加新功能
    
    function getBoxType() public view override returns (string memory) {
        return "Basic";
    }
}`},override_keyword:{name:"重写关键字",icon:"📝",unlockAt:4,message:"你使用了 override 关键字！子合约使用 override 重写父合约的虚函数，实现自定义行为。",code:`// 父合约中的虚函数
function getBoxType() public view virtual returns (string memory);

// 子合约重写
function getBoxType() public view override returns (string memory) {
    return "Premium";  // 自定义实现
}`},virtual_function:{name:"虚函数",icon:"🔮",unlockAt:5,message:"你了解了 virtual 关键字！它标记函数可以被继承合约重写，是实现多态的基础。",code:`// 父合约：标记函数可被重写
function storeSecret(string calldata _secret) 
    public virtual onlyOwner {
    secret = _secret;
}

// 子合约：重写并扩展功能
function storeSecret(string calldata _secret) 
    public override onlyOwner {
    // 自定义逻辑...
    secret = _secret;
}`},super_keyword:{name:"父类调用",icon:"⬆️",unlockAt:6,message:"你使用了 super 关键字！super 调用父合约的函数，在重写时复用父类的逻辑。",code:`// TimeLocked 重写 getSecret
function getSecret() public view override onlyOwner timeUnlocked 
    returns (string memory) {
    // 可以在这里添加自定义逻辑
    return super.getSecret();  // 调用父合约的实现
}`},modifier_combination:{name:"修饰器组合",icon:"🔗",unlockAt:7,message:"你体验了修饰器组合！多个修饰器可以组合使用，函数必须同时满足所有条件才能执行。",code:`// 修饰器组合：同时检查所有者和时间
function getSecret() public view 
    onlyOwner           // 检查1：必须是所有者
    timeUnlocked        // 检查2：必须已解锁
    returns (string memory) {
    return secret;
}`},factory_pattern:{name:"工厂模式",icon:"🏭",unlockAt:8,message:"你体验了工厂模式！VaultManager 负责创建和管理所有存款盒，是创建型设计模式的经典应用。",code:`// VaultManager.sol - 工厂合约
contract VaultManager {
    function createBasicBox() public returns (address) {
        BasicDepositBox newBox = new BasicDepositBox();
        allBoxes.push(address(newBox));
        userBoxes[msg.sender].push(address(newBox));
        return address(newBox);
    }
}`},metadata_storage:{name:"元数据存储",icon:"🏷️",unlockAt:9,message:"你使用了元数据功能！Premium 版本可以存储额外信息，展示了继承扩展的实际应用。",code:`// PremiumDepositBox - 扩展功能
contract PremiumDepositBox is BaseDepositBox {
    string private metadata;  // 额外状态变量
    
    function setMetadata(string calldata _metadata) public onlyOwner {
        metadata = _metadata;
    }
    
    function getMetadata() public view onlyOwner returns (string memory) {
        return metadata;
    }
}`},time_lock:{name:"时间锁定",icon:"⏰",unlockAt:10,message:"你创建了时间锁定存款盒！解锁前无法取出秘密，展示了修饰器在权限控制中的强大作用。",code:`// TimeLockedDepositBox - 时间锁
contract TimeLockedDepositBox is BaseDepositBox {
    uint256 private unlockTime;
    
    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Still locked");
        _;
    }
    
    function getSecret() public view 
        override onlyOwner timeUnlocked returns (string memory) {
        return secret;
    }
}`}},rp={compact_datatype:{name:"紧凑数据类型",icon:"📦",unlockAt:1,message:"你了解了紧凑数据类型！uint8、uint32 等小整数类型相比 uint256 可以节省大量存储空间和 Gas。",code:`// 使用紧凑数据类型优化存储
uint8 public proposalCount;       // 只占 1 字节 (0-255)
uint32 public voteCount;          // 只占 4 字节 (0-42亿)
// 相比 uint256 的 32 字节，节省了大量存储！`},uint8_uint32:{name:"小整数类型",icon:"🔢",unlockAt:2,message:"你了解了 uint8 和 uint32！它们分别只需 1 字节和 4 字节，远小于 uint256 的 32 字节。",code:`// 紧凑整数类型对比
uint8  a;  // 1 字节:  0 - 255
uint16 b;  // 2 字节:  0 - 65535
uint32 c;  // 4 字节:  0 - 42亿
uint256 d; // 32 字节: 0 - 超大数字

// 根据需求选择合适的类型，节省 Gas！`},bytes32_string:{name:"bytes32 vs string",icon:"📝",unlockAt:3,message:"你了解了 bytes32 和 string 的区别！bytes32 使用固定存储，更节省 Gas，适合存储短文本和哈希值。",code:`// bytes32 vs string 对比
string public name;           // 动态长度，存储成本高
bytes32 public proposalHash;  // 固定 32 字节，更省 Gas

// 对于固定长度的短文本，bytes32 更优！`},storage_optimization:{name:"存储优化",icon:"💾",unlockAt:4,message:"你体验了存储优化！通过使用紧凑数据类型和合理的数据结构，可以大幅降低合约的存储成本。",code:`// 存储优化技巧
// 1. 使用最小够用的整数类型
uint8 count;  // 而非 uint256

// 2. 将多个小变量打包到同一槽位
uint8 a;  // 槽位 1 (前 1 字节)
uint8 b;  // 槽位 1 (第 2 字节)
address c;  // 槽位 1 (后 20 字节)

// 3. 使用位运算存储布尔数组
uint256 flags;  // 可存储 256 个布尔值`},bit_operation:{name:"位运算技巧",icon:"⚡",unlockAt:5,message:"你了解了位运算的强大之处！通过位运算，1 个 uint256 可以存储 256 个提案的投票状态，节省约 40% Gas！",code:`// 位运算存储投票状态
uint256 public voterData;  // 选民的投票位图

// 检查是否对提案 n 投票
uint256 mask = 1 << n;
bool hasVoted = (voterData & mask) != 0;

// 记录投票
voterData = voterData | mask;  // 设置对应位为 1

// 1 个 uint256 存储 256 个提案状态！`},mapping_storage:{name:"映射存储",icon:"🗺️",unlockAt:6,message:"你了解了映射的高效存储！mapping 是 Solidity 中最常用的数据结构，通过哈希表实现快速查找。",code:`// 映射存储投票记录
mapping(address => uint256) public voterRegistry;
// 地址 → 投票位图

mapping(uint256 => uint32) public proposalVotes;
// 提案ID → 投票数

// 映射提供 O(1) 时间复杂度的查找！`},mask_check:{name:"掩码检查",icon:"🎭",unlockAt:7,message:"你了解了掩码检查的机制！通过与运算，可以快速检查某个位是否已设置，防止重复投票。",code:`// 掩码检查防止重复投票
uint256 mask = 1 << proposalId;
uint256 voterData = voterRegistry[msg.sender];

// 检查是否已投票
if ((voterData & mask) != 0) {
    revert("Already voted");
}

// 位运算检查高效且节省 Gas！`},timestamp_block:{name:"时间戳使用",icon:"⏰",unlockAt:8,message:"你了解了 block.timestamp 的使用！它提供了当前区块的时间戳，常用于实现时间锁和投票截止。",code:`// 使用 block.timestamp 实现投票时间窗口
uint256 public startTime;
uint256 public duration;

modifier withinDeadline() {
    require(
        block.timestamp >= startTime &&
        block.timestamp <= startTime + duration,
        "Voting closed"
    );
    _;
}`},event_logging:{name:"事件日志",icon:"📋",unlockAt:9,message:"你了解了事件日志的作用！事件记录在链上日志中，可供链下应用索引和监听，是实现前端通知的基础。",code:`// 事件记录提案状态变化
event ProposalCreated(
    uint256 indexed id,
    string name,
    uint256 endTime
);

event Voted(
    address indexed voter,
    uint256 indexed proposalId
);

// indexed 参数可被链下高效检索！`}},Yh=t=>({compact_datatype:"📦 太棒了！你了解了紧凑数据类型优化！uint8、uint32 相比 uint256 节省大量存储！👆 点击上方「存储可视化」区域学习更多！",uint8_uint32:"🔢 优秀！你了解了 uint8 和 uint32！它们分别只需 1 字节和 4 字节，远小于 uint256 的 32 字节！👝 创建提案查看 bytes32！",bytes32_string:"📝 很好！你了解了 bytes32 vs string！bytes32 固定 32 字节，比动态 string 更省 Gas！👝 继续创建提案或尝试投票学习位运算！",storage_optimization:"💾 太棒了！你体验了存储优化！通过紧凑数据类型和合理结构，大幅降低存储成本！⚡ 现在尝试投票来学习位运算！",bit_operation:"⚡ 太棒了！你了解了位运算的强大！1 个 uint256 存储 256 个投票状态，节省约 40% Gas！🗺️ 映射高效存储选民数据！⏰ 使用时间戳验证投票窗口！👉 尝试重复投票体验掩码检查！",mapping_storage:"🗺️ 优秀！你了解了映射的高效存储！mapping 通过哈希表实现 O(1) 查找，是 Solidity 最常用的数据结构！👉 继续探索其他功能！",mask_check:"🎭 很好！你体验了掩码检查！通过与运算快速检查位状态，防止重复投票！👉 等待提案结束执行提案学习事件日志！",timestamp_block:"⏰ 不错！你了解了 block.timestamp 的使用！它提供当前区块时间戳，用于实现时间锁和投票截止！👉 尝试重复投票或执行提案！",event_logging:"📋 恭喜！你了解了事件日志！事件记录在链上日志中，可供链下应用索引和监听！🎉 你已掌握 Day 15 所有核心概念！"})[t]||"📖 点击其他概念标签查看更多详细解释。",Zh=t=>({compact_datatype:"📖 紧凑数据类型是 Solidity Gas 优化的基础。uint8 只占 1 字节（存储范围 0-255），uint32 只占 4 字节（0-42亿），而 uint256 占 32 字节。根据数据范围选择最小够用的类型，可以显著降低存储成本。",uint8_uint32:"📖 uint8、uint16、uint32 等小整数类型相比 uint256 可以节省大量存储空间。当变量值范围有限时，应该优先使用这些紧凑类型。例如：提案数量（uint8）、投票数（uint32）都不需要 uint256 的巨大范围。",bytes32_string:"📖 bytes32 是固定长度的字节数组，始终占用 32 字节。string 是动态长度，存储成本更高且引入额外的 Gas 消耗。对于固定长度的短文本（如提案名称、哈希值），bytes32 是更优的选择。",storage_optimization:"📖 存储优化是智能合约 Gas 优化的核心。技巧包括：1. 使用最小够用的整数类型（uint8 而非 uint256）；2. 将多个小变量打包到同一存储槽位；3. 使用位运算存储布尔数组。这些优化可节省 30-50% 的存储成本。",bit_operation:"📖 位运算利用整数类型的二进制位存储多个布尔值。1 个 uint256 有 256 个位，可以存储 256 个布尔状态（如是否对某提案投票）。相比使用 mapping(uint256 => bool)，位运算节省约 40% 的 Gas。关键操作：左移(1<<n)生成掩码、与(&)检查、或(|)设置。",mapping_storage:"📖 mapping 是 Solidity 的哈希表实现，提供 O(1) 时间复杂度的查找。mapping(address => uint256) 存储地址到数据的映射，mapping(uint256 => uint32) 存储索引到数据的映射。mapping 是状态变量最常用的数据结构，高效且灵活。",mask_check:"📖 掩码（Mask）是位运算的核心概念。掩码是一个二进制数，只有特定位为 1。通过 & 运算检查位：(data & mask) != 0 表示该位已设置。通过 | 运算设置位：data | mask 将对应位设为 1。这种方法快速且节省 Gas。",timestamp_block:"📖 block.timestamp 是当前区块的时间戳（秒级）。它由矿工/验证者提供，可能有少许偏差（几秒到几分钟），但适合大多数场景。常用于实现时间锁、投票截止、合约到期等需要时间判断的功能。",event_logging:"📖 事件（Event）是 Solidity 的日志机制，记录在链上日志中（不占用状态存储）。事件可以有 indexed 参数（最多 3 个），可被链下应用高效检索。事件是实现前端通知、链下索引、历史记录查询的基础，是 DApp 交互的关键。"})[t]||"📖 点击其他概念标签查看更多详细解释。",Qh=t=>({interface_definition:"🔌 欢迎来到 Day 14！你了解了接口定义 - 它规定了所有存款盒必须实现的功能。👉 创建任意存款盒来解锁抽象合约！",abstract_contract:"🎭 太棒了！你了解了抽象合约 - 它实现了通用功能但不能直接部署。👉 创建 Basic 存款盒来学习合约继承！",inheritance:"🧬 优秀！你体验了合约继承！BasicDepositBox 继承了 BaseDepositBox 的所有功能。👉 创建 Premium 或 TimeLocked 来学习 override！",override_keyword:"📝 很好！你使用了 override 关键字重写父合约函数。👉 创建 TimeLocked 存款盒来学习 virtual 和修饰器组合！",virtual_function:"🔮 太棒了！你了解了 virtual 关键字 - 它允许子合约重写父函数。👉 在锁定期间尝试取秘密来体验修饰器组合！",super_keyword:"⬆️ 优秀！你使用了 super 调用父合约函数。👉 创建第2个存款盒来体验工厂模式！",modifier_combination:"🔗 太棒了！你体验了修饰器组合 - 需要同时满足 onlyOwner 和 timeUnlocked！👉 创建 Premium 存款盒来学习元数据存储！",factory_pattern:"🏭 优秀！你体验了工厂模式！VaultManager 负责创建和管理所有存款盒。👉 转移所有权并更新记录来完成体验！",metadata_storage:"🏷️ 很好！你使用了元数据功能！Premium 版本可以存储额外信息。👉 查看完整代码来复习所有知识点！",time_lock:"⏰ 太棒了！你创建了时间锁定存款盒！解锁前无法取出秘密。🎉 你已掌握抽象合约、接口与工厂模式！",store_secret:"🔐 太棒了！你成功存入了秘密！Secret 已被安全存储在合约中。👉 尝试取出秘密来体验访问控制！",get_secret:"🔓 不错！你取出了秘密！只有所有者才能访问存储的秘密。👉 尝试设置元数据或创建更多存款盒！",transfer_ownership:"🔑 很好！你转移了存款盒的所有权！新的所有者现在可以管理这个存款盒。👉 切换到新所有者完成转移流程！"})[t]||"📖 点击其他概念标签查看更多详细解释。",e0=t=>({interface_definition:"📖 接口（Interface）是 Solidity 中定义合约规范的方式。它只声明函数签名，不包含实现。任何实现该接口的合约都必须提供所有函数的具体实现。接口实现了多态和解耦，让不同的合约可以以统一的方式交互。",abstract_contract:"📖 抽象合约（Abstract Contract）是不能被直接部署的合约，它通常包含一个或多个纯虚函数（没有实现的函数）。抽象合约用于定义子合约必须实现的接口，同时提供一些通用的实现代码，是代码复用的重要机制。",inheritance:"📖 合约继承是 Solidity 的核心特性之一。通过 `contract Child is Parent`，子合约可以继承父合约的所有状态变量和函数。继承实现了代码复用，让开发者可以基于现有合约构建更复杂的功能。",override_keyword:"📖 override 关键字用于显式声明子合约重写了父合约的虚函数。从 Solidity 0.6.0 开始，重写函数必须使用 override 关键字，这提高了代码的可读性和安全性，防止意外重写。",virtual_function:"📖 virtual 关键字标记函数可以被继承合约重写。父合约的函数默认不能被重写，必须显式标记为 virtual。这是 Solidity 的设计选择，防止意外的函数重写导致安全问题。",super_keyword:"📖 super 关键字用于调用父合约的函数。在重写函数时，super 让你可以复用父类的逻辑，然后添加或修改特定行为。这在需要扩展而非完全替换父类功能时非常有用。",modifier_combination:"📖 多个修饰器可以组合使用，函数必须同时满足所有修饰器的条件才能执行。修饰器按声明顺序执行，每个修饰器的 `_` 代表被修饰函数的代码。这是实现复杂权限控制的有效方式。",factory_pattern:"📖 工厂模式是一种创建型设计模式，使用专门的工厂合约来创建和管理其他合约。VaultManager 就是工厂合约，它负责创建存款盒并追踪所有权。工厂模式实现了创建逻辑与使用逻辑的分离。",metadata_storage:"📖 元数据存储展示了继承扩展的实际应用。PremiumDepositBox 在继承 BaseDepositBox 的基础上，添加了 metadata 状态变量和相关函数，实现了功能的扩展，而不影响基础功能。",time_lock:"📖 时间锁定是一种常见的 DeFi 安全机制。TimeLockedDepositBox 使用 block.timestamp 和修饰器实现时间锁，只有在指定时间后才能执行特定操作。这保护了用户资产，防止冲动操作。"})[t]||"📖 点击其他概念标签查看更多详细解释。",sp={struct_definition:{name:"结构体定义",icon:"🏗️",unlockAt:1,message:"你了解了结构体定义！struct 允许你将多个相关数据组合成一个自定义类型。",code:`// 定义玩家资料结构体
struct PlayerProfile {
    string name;    // 玩家名称
    string avatar;  // 头像标识
}

// 创建结构体实例
PlayerProfile memory profile = PlayerProfile("Alice", "avatar1");`},mapping_storage:{name:"映射存储",icon:"🗺️",unlockAt:2,message:"你了解了映射存储！mapping 是 Solidity 中最常用的键值对存储结构，提供 O(1) 查找效率。",code:`// 映射存储键值对
mapping(address => PlayerProfile) public profiles;
mapping(string => address) public plugins;

// 存储和读取
profiles[msg.sender] = PlayerProfile(name, avatar);
PlayerProfile memory p = profiles[user];`},plugin_registration:{name:"插件注册",icon:"🔌",unlockAt:3,message:"你体验了插件注册！通过 mapping 将字符串标识符映射到合约地址，实现动态插件管理。",code:`// 注册插件
function registerPlugin(string memory key, address pluginAddress) external {
    plugins[key] = pluginAddress;
}

// 使用示例
registerPlugin("weapon", 0x1234...);`},low_level_call:{name:"低级别调用",icon:"⚡",unlockAt:4,message:"你使用了低级别调用！call 是 EVM 的底层指令，允许动态调用任何合约函数。",code:`// 使用 call 动态调用插件
(bool success, ) = plugin.call(data);
require(success, "Plugin execution failed");

// call 可以修改状态，返回 (bool, bytes)`},abi_encoding:{name:"ABI编码",icon:"🔢",unlockAt:4,message:"你了解了 ABI 编码！Solidity 使用 ABI 标准将函数调用编码为字节码，函数选择器是前4字节。",code:`// ABI 编码函数调用
bytes memory data = abi.encodeWithSignature(
    "setWeapon(address,string)", 
    user, 
    weapon
);

// 函数选择器: keccak256("setWeapon(address,string)")[0:4]`},staticcall:{name:"静态调用",icon:"👁️",unlockAt:5,message:"你使用了静态调用！staticcall 保证被调用的合约不会修改状态，适合查询操作。",code:`// 使用 staticcall 进行只读调用
(bool success, bytes memory result) = plugin.staticcall(data);
require(success, "Call failed");

// 解码返回值
string memory value = abi.decode(result, (string));`},dynamic_delegation:{name:"动态委托",icon:"🔄",unlockAt:6,message:"你体验了动态委托！一个核心合约可以管理多个插件，实现功能的模块化扩展。",code:`// PluginStore 作为核心，动态委托给不同插件
pluginStore.runPlugin("weapon", ...);
pluginStore.runPlugin("achievement", ...);

// 新增插件无需修改核心合约代码`},contract_interop:{name:"合约互操作",icon:"🌐",unlockAt:7,message:"你掌握了合约互操作！多个合约通过标准接口无缝协作，构建复杂的去中心化应用。",code:`// 插件系统实现合约间的松耦合协作
// PluginStore (核心) → WeaponPlugin (功能)
//                    → AchievementPlugin (功能)

// 合约像乐高积木一样组合使用`}},ip={proxy_pattern:{name:"代理模式",icon:"📦",unlockAt:1,message:"你了解了代理模式！这是可升级合约的核心架构，将数据存储与逻辑执行分离。",code:`// 代理合约存储数据，逻辑合约执行业务逻辑
// 用户调用 Proxy → Proxy 通过 delegatecall 调用 Logic
// 数据存储在 Proxy 中，Logic 只包含代码`},delegatecall:{name:"委托调用",icon:"🔄",unlockAt:2,message:"你了解了 delegatecall！它在调用者（代理合约）的存储上下文中执行被调用合约（逻辑合约）的代码。",code:`// delegatecall 关键点：
// 1. 在代理合约的存储上下文中执行
// 2. msg.sender 保持为原始调用者
// 3. msg.value 保持不变
// 4. 代码在逻辑合约，数据在代理合约

assembly {
    let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
}`},storage_layout:{name:"存储布局",icon:"🔀",unlockAt:3,message:"你了解了存储布局！代理合约和逻辑合约必须使用完全相同的存储变量顺序，否则升级后数据会错乱。",code:`// 存储布局必须一致！
contract SubscriptionStorageLayout {
    address public logicContract;  // slot 0
    address public owner;          // slot 1
    mapping(address => Subscription) public subscriptions;  // slot 2
    mapping(uint8 => uint256) public planPrices;           // slot 3
    mapping(uint8 => uint256) public planDuration;         // slot 4
    uint256[50] private __gap;     // 预留空间，防止未来冲突
}`},upgrade_mechanism:{name:"升级机制",icon:"🚀",unlockAt:4,message:"你体验了合约升级！通过更新 logicContract 地址，可以替换业务逻辑而不丢失数据。",code:`// 升级逻辑合约
function upgradeTo(address _newLogic) external {
    require(msg.sender == owner, "Not owner");
    logicContract = _newLogic;  // 更新逻辑合约地址
}

// 升级后：
// - 数据保持不变（存储在代理合约）
// - 逻辑更新为新版本
// - 用户无感知切换`},logic_contract:{name:"逻辑合约",icon:"⚙️",unlockAt:4,message:"你了解了逻辑合约！它只包含业务逻辑代码，不存储数据，可以被替换升级。",code:`// 逻辑合约 V1
contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    function subscribe(uint8 planId) external payable {
        // 业务逻辑...
    }
}

// 逻辑合约 V2（升级版本）
contract SubscriptionLogicV2 is SubscriptionStorageLayout {
    // 新增功能...
    function pauseSubscription() external { ... }
}`},fallback_function:{name:"回退函数",icon:"🔙",unlockAt:5,message:"你了解了 fallback 函数！代理合约使用它捕获所有未匹配的函数调用，并通过 delegatecall 转发给逻辑合约。",code:`// fallback 函数处理所有未匹配的调用
fallback() external payable {
    address impl = logicContract;
    require(impl != address(0), "Not set");
    
    assembly {
        calldatacopy(0, 0, calldatasize())
        let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
        returndatacopy(0, 0, returndatasize())
        switch result
        case 0 { revert(0, returndatasize()) }
        default { return(0, returndatasize()) }
    }
}`},data_persistence:{name:"数据持久化",icon:"💾",unlockAt:6,message:"你验证了数据持久化！升级合约后，之前创建的计划和订阅数据仍然保持不变。",code:`// 升级前：
// - 用户订阅了计划 1
// - 过期时间为 2024-12-31

// 升级后：
// - 订阅数据仍然存在
// - 过期时间不变
// - 可以查询到之前的订阅记录`},version_control:{name:"版本控制",icon:"📊",unlockAt:7,message:"你体验了版本控制！V2 新增了暂停/恢复功能，展示了如何在升级中添加新特性。",code:`// V1 功能：
// - createPlan
// - subscribe
// - isSubscribed

// V2 新增：
// - pauseSubscription  ⭐ 新功能
// - resumeSubscription ⭐ 新功能

// 升级后，V1 和 V2 的数据格式兼容`}},t0=t=>({struct_definition:"🏗️ 你了解了结构体定义！PlayerProfile 将 name 和 avatar 组合在一起。👉 设置玩家资料来解锁映射存储！",mapping_storage:"🗺️ 你的资料已保存到 mapping！通过键值对高效存储。👉 注册 weapon 插件来学习插件系统！",plugin_registration:"🔌 插件注册成功！地址已存入 plugins[key]。👉 点击「调用」执行插件函数！",low_level_call:"⚡ 低级别调用成功！使用了 EVM 的 call 指令。👉 查看 ABI 编码可视化！",abi_encoding:"🔢 ABI 编码完成！函数选择器是 keccak256 哈希的前4字节。👉 切换 staticcall 模式查询数据！",staticcall:"👁️ 静态调用成功！不消耗 Gas 的只读操作。👉 尝试切换到 achievement 插件！",dynamic_delegation:"🔄 动态委托系统运行中！一个核心管理多个插件。👉 在不同插件间切换体验互操作！",contract_interop:"🌐 合约互操作掌握！多个合约无缝协作。🎉 你已掌握 Day 16 所有核心概念！"})[t]||"📖 点击其他概念标签查看更多详细解释。",n0=t=>({struct_definition:"📖 结构体(struct)允许你将多个相关的变量组合成一个自定义类型。PlayerProfile 包含 name 和 avatar 两个字段，可以像单个变量一样传递和存储。结构体是组织复杂数据的基础。",mapping_storage:"📖 映射(mapping)是哈希表结构，提供 O(1) 的读写效率。profiles 用 address 作为键存储玩家资料，plugins 用 string 作为键存储插件地址。mapping 是 Solidity 最常用的状态变量类型。",plugin_registration:"📖 插件注册将字符串标识符映射到合约地址，实现动态插件管理。这种设计模式被称为注册表模式(Registry Pattern)，允许运行时添加新功能而无需修改核心合约代码。",low_level_call:"📖 call 是 EVM 的低级别调用指令，允许你动态调用任何函数。它返回 (bool, bytes) 元组表示成功状态和返回值。call 非常灵活但不如普通调用安全，需要仔细检查返回值。",abi_encoding:"📖 ABI(Application Binary Interface)编码将函数签名和参数转换为字节码。函数选择器是函数签名的 keccak256 哈希的前4字节。abi.encodeWithSignature 自动处理编码过程。",staticcall:"📖 staticcall 与 call 类似，但被调用的合约不能修改状态(发送ETH、写存储等)。它适合查询操作，更安全且通常不消耗 Gas。staticcall 是 view 函数的底层实现。",dynamic_delegation:"📖 动态委托允许核心合约将操作转发给不同的插件合约，实现功能的模块化扩展。这种架构让系统可以灵活添加新功能，无需修改核心代码，是插件系统的基础。",contract_interop:"📖 合约互操作是 DeFi 和 DApp 的基础。通过标准接口和动态调用，不同合约可以像乐高积木一样组合使用。PluginStore 展示了如何通过统一接口协调多个独立合约。"})[t]||"📖 点击其他概念标签查看更多详细解释。",r0=t=>({proxy_pattern:"📦 你了解了代理模式！这是可升级合约的核心架构。👉 点击 delegatecall 说明来学习委托调用！",delegatecall:"🔄 你了解了 delegatecall！它在代理合约的存储上下文中执行逻辑合约的代码。👉 点击存储布局说明了解变量顺序的重要性！",storage_layout:"🔀 你了解了存储布局！代理合约和逻辑合约必须使用相同的存储变量顺序。👉 切换到 Owner 身份，创建第一个订阅计划！",upgrade_mechanism:"🚀 你体验了合约升级！通过更新 logicContract 地址，可以替换业务逻辑而不丢失数据。👉 切换到 User 身份，执行订阅操作！",logic_contract:"⚙️ 你了解了逻辑合约！它只包含业务逻辑代码，不存储数据。👉 订阅后查看 fallback 如何工作！",fallback_function:"🔙 你了解了 fallback 函数！代理合约使用它捕获所有未匹配的函数调用。👉 升级合约后查看数据是否仍然存在！",data_persistence:"💾 你验证了数据持久化！升级合约后，之前的数据仍然保持不变。👉 使用 V2 新功能（暂停/恢复）来对比版本差异！",version_control:"📊 你体验了版本控制！V2 新增了暂停/恢复功能。🎉 你已掌握 Day 17 所有核心概念！"})[t]||"📖 点击其他概念标签查看更多详细解释。",s0=t=>({proxy_pattern:"📖 代理模式(Proxy Pattern)是可升级合约的核心架构。代理合约负责存储所有数据和 ETH，逻辑合约只包含业务代码。用户始终与代理合约交互，代理通过 delegatecall 将调用转发给当前逻辑合约。",delegatecall:"📖 delegatecall 是 EVM 的特殊调用方式，它在调用者（代理合约）的存储上下文中执行被调用合约（逻辑合约）的代码。这意味着逻辑合约可以读写代理合约的存储，但代码来自逻辑合约。msg.sender 和 msg.value 保持不变。",storage_layout:"📖 存储布局一致性是可升级合约的关键。代理合约和逻辑合约必须继承相同的存储布局基础合约（如 SubscriptionStorageLayout），确保变量顺序完全一致。如果顺序不同，升级后数据会错位，导致严重错误。",upgrade_mechanism:"📖 升级机制通过更新代理合约中的 logicContract 地址实现。upgradeTo() 函数只有 owner 可以调用，更新后所有新调用都会使用新逻辑。旧数据保持不变，因为数据存储在代理合约中，不在逻辑合约里。",logic_contract:"📖 逻辑合约(Logic Contract)只包含业务逻辑代码，不存储任何状态数据。它可以被替换升级而不影响数据。V1 和 V2 都是逻辑合约，它们继承相同的存储布局，但实现不同的功能。",fallback_function:"📖 fallback 函数是代理合约的核心。当用户调用代理合约中不存在的函数时，fallback 会被触发。它使用 delegatecall 将调用转发给逻辑合约，并返回执行结果。这是实现透明代理的关键。",data_persistence:"📖 数据持久化是可升级合约的重要特性。由于所有数据都存储在代理合约中，升级逻辑合约不会影响已有数据。用户升级前创建的订阅、计划等数据在升级后仍然可以正常访问和使用。",version_control:"📖 版本控制展示了如何在升级中添加新功能。V2 在 V1 的基础上新增了 pauseSubscription 和 resumeSubscription 功能，但保持数据格式兼容。这展示了可升级合约的灵活性和扩展性。"})[t]||"📖 点击其他概念标签查看更多详细解释。",op={oracle_interface:{name:"Chainlink接口",icon:"🔌",unlockAt:1,message:"你了解了 Chainlink 预言机接口！AggregatorV3Interface 是 Chainlink 标准接口，让智能合约能够获取链外数据。",code:`interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}`},eth_usd_oracle:{name:"ETH/USD喂价",icon:"💰",unlockAt:2,message:"你使用了 ETH/USD 价格预言机！Chainlink 返回的价格有 8 位小数精度，需要正确处理。",code:`function getEthPrice() public view returns (uint256) {
    (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
    // price = 300000000000 表示 $3000.00
    return uint256(price);
}`},random_generation:{name:"伪随机数生成",icon:"🎲",unlockAt:3,message:"你看到了伪随机数生成！使用区块信息生成随机数，适合测试但不适合生产环境。",code:`function _rainfall() public view returns (int256) {
    uint256 randomFactor = uint256(keccak256(abi.encodePacked(
        block.timestamp,
        block.coinbase,
        block.number
    ))) % 1000;
    return int256(randomFactor);
}`},purchase_insurance:{name:"购买保险",icon:"🛡️",unlockAt:4,message:"你购买了保险！支付保费后获得保障，当条件满足时可获得赔付。",code:`function purchaseInsurance() external payable {
    require(msg.value >= premiumInEth, "Insufficient premium");
    require(!hasInsurance[msg.sender], "Already insured");
    hasInsurance[msg.sender] = true;
    emit InsurancePurchased(msg.sender, msg.value);
}`},price_conversion:{name:"价格转换",icon:"🔄",unlockAt:5,message:"你了解了价格转换！Chainlink 价格有 8 位小数，需要使用 1e26 来正确计算 ETH 数量。",code:`uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e26) / ethPrice;
// 1e26 = 1e18(wei精度) × 1e8(Chainlink精度)
// 例如: (10 * 1e26) / 300000000000 = 0.0033 ETH`},parametric_payout:{name:"参数化赔付",icon:"💸",unlockAt:6,message:"你体验了参数化赔付！无需人工审核，条件满足自动赔付，这是区块链保险的核心优势。",code:`if (currentRainfall < RAINFALL_THRESHOLD) {
    // 自动执行赔付
    (bool success, ) = msg.sender.call{value: payoutInEth}("");
    require(success, "Transfer failed");
    emit ClaimPaid(msg.sender, payoutInEth);
}`},cooldown_mechanism:{name:"冷却期机制",icon:"⏱️",unlockAt:7,message:"你了解了冷却期机制！24小时内只能索赔一次，防止滥用和频繁索赔。",code:`require(
    block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days,
    "Must wait 24h between claims"
);
lastClaimTimestamp[msg.sender] = block.timestamp;`},contract_balance:{name:"合约余额",icon:"🏦",unlockAt:8,message:"你查看了合约余额！管理员可以提取合约中的 ETH，这是保险池资金管理的重要功能。",code:`function withdraw() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
}

function getBalance() public view returns (uint256) {
    return address(this).balance;
}`}},ap={keccak256_hash:{name:"Keccak256哈希算法",icon:"🔐",unlockAt:1,message:"你使用了 Keccak256 哈希算法！这是以太坊标准的哈希函数，将任意数据转换为固定长度的哈希值。",code:`bytes32 messageHash = keccak256(abi.encodePacked(_user));
// Keccak256 是以太坊原生哈希函数
// 输入任意长度数据，输出 32 字节固定长度哈希`},ecdsa_signature:{name:"ECDSA椭圆曲线签名",icon:"🎯",unlockAt:2,message:"你了解了 ECDSA 椭圆曲线签名！这是以太坊使用的数字签名算法，基于椭圆曲线密码学实现身份验证。",code:`// ECDSA = Elliptic Curve Digital Signature Algorithm
// 使用私钥签名，公钥验证
// 签名后得到 r, s, v 三个值`},signature_rsv:{name:"签名组件R/S/V",icon:"📝",unlockAt:3,message:"你分解了签名的 R/S/V 组件！以太坊签名由 65 字节组成：r(32) + s(32) + v(1)。",code:`(bytes32 r, bytes32 s, uint8 v) = splitSignature(sig);
// r: 签名前32字节
// s: 签名中间32字节
// v: 最后1字节，用于恢复公钥`},eip191_prefix:{name:"EIP-191以太坊签名前缀",icon:"📋",unlockAt:5,message:"你了解了 EIP-191 签名前缀！\\x19Ethereum Signed Message:\\n32 是以太坊个人签名的标准前缀，防止签名被滥用。",code:`bytes32 ethSignedMessageHash = keccak256(
    abi.encodePacked(
        "\\x19Ethereum Signed Message:\\n32",
        messageHash
    )
);
// 前缀确保签名只能用于以太坊消息`},ecrecover:{name:"签名者恢复函数",icon:"🔓",unlockAt:5,message:"你使用了 ecrecover 函数！这是 Solidity 内置函数，通过签名数据恢复签名者的以太坊地址。",code:`address signer = ecrecover(
    ethSignedMessageHash,
    v,
    r,
    s
);
// ecrecover 是 EVM 内置函数
// 输入签名哈希和 r,s,v，返回签名者地址`},require_statement:{name:"Require验证语句",icon:"⚠️",unlockAt:6,message:"你使用了 require 验证语句！这是 Solidity 中最常用的条件检查，不满足时回滚交易并显示错误消息。",code:`require(!hasEntered[msg.sender], "Already entered");
// 第一个参数：条件表达式
// 第二个参数：错误消息（可选）
// 条件为 false 时，交易回滚`},mapping_storage:{name:"映射存储",icon:"🗂️",unlockAt:7,message:"你使用了映射存储！mapping 是 Solidity 中的键值对数据结构，用于高效存储用户状态。",code:`mapping(address => bool) public hasEntered;
// mapping(keyType => valueType)
// keyType: 地址类型
// valueType: 布尔类型（是否已参与）
hasEntered[userAddress] = true;  // 写入`},msg_sender:{name:"消息发送者",icon:"👤",unlockAt:8,message:"你使用了 msg.sender！这是 Solidity 中的全局变量，表示当前交易的发送者地址。",code:`constructor() {
    organizer = msg.sender;
}
// msg.sender: 当前调用者地址
// 在构造函数中，部署者成为组织者`}},i0=t=>({oracle_interface:"🔌 你了解了 Chainlink 预言机接口！AggregatorV3Interface 是标准接口。👉 查看 ETH/USD 价格面板学习价格预言机！",eth_usd_oracle:"💰 你使用了 ETH/USD 价格预言机！注意 Chainlink 返回 8 位小数精度。👉 购买保险体验价格转换！",random_generation:"🎲 你看到了伪随机数生成！使用区块信息生成随机降雨量。👉 更新天气数据体验随机性！",purchase_insurance:"🛡️ 保险购买成功！支付保费获得保障。👉 当干旱发生时申请赔付！",price_conversion:"🔄 你了解了价格转换！1e26 = 1e18 × 1e8 抵消 Chainlink 精度。👉 申请赔付体验参数化保险！",parametric_payout:"💸 赔付成功！参数化保险自动执行无需审核。👉 了解冷却期机制防止滥用！",cooldown_mechanism:"⏱️ 你了解了冷却期！24小时内只能索赔一次。👉 快进时间或查看合约余额！",contract_balance:"🏦 你查看了合约余额！管理员可提取保险池资金。🎉 你已掌握 Day 18 所有核心概念！"})[t]||"📖 点击其他概念标签查看更多详细解释。",o0=t=>({oracle_interface:"📖 Chainlink 预言机接口(AggregatorV3Interface)是行业标准，定义了 latestRoundData() 等函数。它让智能合约能够安全地获取链外数据，如价格、天气等。接口标准化确保不同预言机可以互换使用。",eth_usd_oracle:"📖 ETH/USD 价格预言机返回的价格有 8 位小数精度。例如 $3000 返回 300000000000。这是因为金融数据通常需要高精度，而 Solidity 不支持浮点数。使用时需要注意精度转换。",random_generation:"📖 伪随机数生成使用区块信息（timestamp, coinbase, number）作为种子。这种方式适合测试和演示，但不适合生产环境，因为矿工可以影响结果。生产环境应使用 Chainlink VRF 等安全随机数方案。",purchase_insurance:"📖 购买保险函数检查用户支付足够的 ETH 且尚未投保。保费根据当前 ETH 价格动态计算，确保合约收到正确金额。投保状态存储在 hasInsurance 映射中，永久记录在区块链上。",price_conversion:"📖 价格转换公式 (USD × 1e26) / ETH价格 考虑了 Chainlink 的 8 位小数精度。1e26 = 1e18(wei精度) × 1e8(价格精度)。例如 $10 保费在 ETH $3000 时约为 0.0033 ETH。",parametric_payout:"📖 参数化保险(Parametric Insurance)是区块链保险的核心创新。传统保险需要人工审核理赔，而参数保险根据预设条件（如降雨量 < 500mm）自动赔付，无需信任第三方，大幅降低运营成本。",cooldown_mechanism:"📖 冷却期机制使用 block.timestamp 记录上次索赔时间，限制 24 小时内只能索赔一次。这是防止滥用的安全措施。在真实区块链上时间无法篡改，确保机制可靠。",contract_balance:"📖 合约余额管理是 DeFi 应用的基础。管理员可以提取合约中的 ETH，用于保险池资金管理。balance 操作需要注意重入攻击防护，使用 checks-effects-interactions 模式。"})[t]||"📖 点击其他概念标签查看更多详细解释。",a0=t=>({keccak256_hash:"🔐 你使用了 Keccak256 哈希算法！这是以太坊标准的哈希函数，将任意数据转换为 32 字节哈希值。👉 点击展开签名详情查看 R/S/V 组件！",ecdsa_signature:"🎯 你了解了 ECDSA 椭圆曲线签名！这是以太坊使用的数字签名算法，基于椭圆曲线密码学。👉 点击生成签名来体验完整流程！",signature_rsv:"📝 你分解了签名的 R/S/V 组件！以太坊签名由 65 字节组成：r(32) + s(32) + v(1)。👉 使用签名参与活动来解锁 ecrecover！",eip191_prefix:"📋 你了解了 EIP-191 签名前缀！\\x19Ethereum Signed Message:\\n32 是以太坊个人签名的标准，防止签名被滥用。👉 查看参与者列表完成所有概念！",ecrecover:"🔓 你使用了 ecrecover 函数！这是 Solidity 内置函数，通过签名恢复签名者地址。👉 查看参与者列表了解映射存储！",require_statement:"⚠️ 你使用了 require 验证语句！这是 Solidity 安全编程的基础，不满足条件时回滚交易。👉 查看参与者列表完成所有概念！",mapping_storage:"🗂️ 你使用了映射存储！mapping 是 Solidity 高效的键值对结构，用于存储用户参与状态。🎉 你已掌握 Day 19 所有核心概念！",msg_sender:"👤 你使用了 msg.sender！这是 Solidity 的全局变量，表示当前交易的发送者地址。👉 点击展开签名详情查看 R/S/V 组件！"})[t]||"📖 点击其他概念标签查看更多详细解释。",c0=t=>({keccak256_hash:"📖 Keccak256 是以太坊原生的哈希函数（SHA-3 算法变体）。它将任意长度的输入转换为 32 字节的固定长度输出。在签名验证中，我们需要先对用户地址进行哈希，生成唯一的消息标识。",ecdsa_signature:"📖 ECDSA（椭圆曲线数字签名算法）是以太坊使用的签名方案。它基于椭圆曲线密码学，使用私钥生成签名，任何人可以用公钥验证签名。签名过程不可逆，无法从签名推导出私钥。",signature_rsv:"📖 以太坊签名由 65 字节组成：r（32字节）+ s（32字节）+ v（1字节）。r 和 s 是签名曲线坐标，v 是恢复标识符（27 或 28）。通过 v 可以推导出对应的公钥地址。",eip191_prefix:"📖 EIP-191 定义了以太坊签名的标准格式：\\x19Ethereum Signed Message:\\n32 前缀。这个前缀确保签名只能用于以太坊消息，防止签名被滥用到其他区块链或应用中。",ecrecover:"📖 ecrecover 是 EVM 内置函数，用于从签名数据恢复签名者地址。它接受消息哈希和 r、s、v 作为参数，返回签名的公钥对应的地址。这是签名验证的核心函数。",require_statement:"📖 require 是 Solidity 中最常用的错误处理语句。第一个参数是布尔条件，第二个参数是可选的错误消息。当条件为 false 时，交易回滚，消耗所有 Gas。",mapping_storage:"📖 mapping 是 Solidity 中的键值对数据结构，类似于哈希表。mapping(address => bool) 表示地址到布尔值的映射。访问不存在的键会返回默认值（false），写入时会创建键值对。",msg_sender:"📖 msg.sender 是 Solidity 的全局变量，表示当前调用者的地址。在构造函数中，msg.sender 是合约的部署者，因此成为组织者。这是权限控制的基础。"})[t]||"📖 点击其他概念标签查看更多详细解释。",cp={reentrancy_attack:{name:"重入攻击",icon:"🔥",unlockAt:1,message:"你了解了重入攻击！这是最著名的智能合约漏洞，攻击者通过递归调用窃取资金。",code:`// 重入攻击原理:
// 1. 攻击者存入 1 ETH
// 2. 调用 withdraw() 提款
// 3. 合约发送 ETH，触发攻击者的 receive()
// 4. receive() 再次调用 withdraw()
// 5. 重复直到资金耗尽！
receive() external payable {
    if (attackCount < 5) {
        targetVault.vulnerableWithdraw(); // 递归调用！
    }
}`},fallback_receive:{name:"回退函数",icon:"⚡",unlockAt:2,message:"你使用了回退函数！receive() 在合约接收 ETH 时自动触发，是重入攻击的入口点。",code:`// receive() 函数 - 接收 ETH 时触发
receive() external payable {
    attackCount++;
    
    // 如果金库还有余额，继续攻击
    if (address(targetVault).balance >= 1 ether) {
        targetVault.vulnerableWithdraw(); // 再次提款！
    }
}`},vulnerable_withdraw:{name:"漏洞提款函数",icon:"🔴",unlockAt:3,message:"你发现了漏洞提款函数！它先发送 ETH 后更新余额，让攻击者有机可乘。",code:`// ❌ 有漏洞的代码
function vulnerableWithdraw() external {
    uint256 amount = goldBalance[msg.sender];
    require(amount > 0, "Nothing");

    // ⚠️ 漏洞: 先发送 ETH
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "Failed");

    // ❌ 后更新余额 - 攻击者可以重入！
    goldBalance[msg.sender] = 0;
}`},deposit_function:{name:"存款函数",icon:"💰",unlockAt:4,message:"你使用了存款函数！用户存入 ETH 增加余额，是攻击的前提条件。",code:`// 存款函数
function deposit() external payable {
    require(msg.value > 0, "Deposit > 0");
    goldBalance[msg.sender] += msg.value;
}

// 调用方式:
// vault.deposit{value: 1 ether}();`},checks_effects_interactions:{name:"CEI模式",icon:"✅",unlockAt:5,message:"你了解了 CEI 模式！Checks-Effects-Interactions 是防止重入攻击的核心设计模式。",code:`// ✅ Checks-Effects-Interactions 模式
function safeWithdraw() external {
    // 1. Checks: 验证条件
    uint256 amount = goldBalance[msg.sender];
    require(amount > 0, "Nothing");

    // 2. Effects: 先更新状态 ✅
    goldBalance[msg.sender] = 0;

    // 3. Interactions: 最后外部调用 ✅
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "Failed");
}`},reentrancy_guard:{name:"重入锁",icon:"🔒",unlockAt:6,message:"你使用了重入锁！nonReentrant 修饰符阻止函数在锁定期间被重入调用。",code:`// 重入锁实现
uint256 private _status;
uint256 private constant _NOT_ENTERED = 1;
uint256 private constant _ENTERED = 2;

modifier nonReentrant() {
    require(_status != _ENTERED, "Blocked!");
    _status = _ENTERED;      // 🔒 锁定
    _;
    _status = _NOT_ENTERED;  // 🔓 解锁
}

function safeWithdraw() external nonReentrant {
    // 函数体...
}`},contract_balance:{name:"合约余额",icon:"🏦",unlockAt:7,message:"你查看了合约余额！address(this).balance 返回合约持有的 ETH 数量。",code:`// 查询合约余额
function getBalance() public view returns (uint256) {
    return address(this).balance;
}

// 在攻击合约中检查目标余额
if (address(targetVault).balance >= 1 ether) {
    // 继续攻击...
}`},code_comparison:{name:"代码对比",icon:"📜",unlockAt:8,message:"你对比了漏洞代码和安全代码！理解差异是学习安全编程的关键。",code:`// ❌ 漏洞版本: 先发送 ETH，后更新余额
(bool sent, ) = msg.sender.call{value: amount}("");
goldBalance[msg.sender] = 0; // 攻击者已重入！

// ✅ 安全版本: 先更新余额，后发送 ETH
goldBalance[msg.sender] = 0; // 先更新！(nonReentrant 保护)
(bool sent, ) = msg.sender.call{value: amount}("");`}},l0=t=>({reentrancy_attack:"🔥 你了解了重入攻击！这是最著名的智能合约漏洞。👉 存入ETH到金库开始攻击演示！",fallback_receive:"⚡ 你使用了回退函数！receive() 在接收ETH时触发，是重入攻击的入口点。👉 现在尝试攻击漏洞版本！",vulnerable_withdraw:"🔴 你发现了漏洞提款函数！它先发送ETH后更新余额。👉 查看防护机制了解如何修复！",deposit_function:"💰 你使用了存款函数！用户存入ETH增加余额。👉 现在尝试攻击漏洞版本！",checks_effects_interactions:"✅ 你了解了CEI模式！先更新状态再发送ETH是防止重入的关键。👉 尝试攻击安全版本！",reentrancy_guard:"🔒 你使用了重入锁！nonReentrant修饰符阻止函数重入调用。👉 查看代码对比巩固知识！",contract_balance:"🏦 你查看了合约余额！address(this).balance返回合约ETH数量。🎉 恭喜完成Day20学习！",code_comparison:"📜 你对比了漏洞代码和安全代码！理解差异是学习安全编程的关键。🎉 恭喜完成Day20学习！"})[t]||"📖 点击其他概念标签查看更多详细解释。",u0=t=>({reentrancy_attack:"📖 重入攻击(Reentrancy Attack)是智能合约最著名的漏洞。攻击者利用合约在发送ETH后、更新状态前的窗口期，通过递归调用重复提款。2016年的The DAO攻击就是利用此漏洞，损失360万ETH，导致以太坊硬分叉。",fallback_receive:"📖 receive() 是 Solidity 的特殊函数，当合约接收 ETH 且没有附带数据时触发。在重入攻击中，攻击者的 receive() 函数会再次调用目标合约的提款函数，形成递归调用链。这是重入攻击的核心机制。",vulnerable_withdraw:"📖 漏洞提款函数违反了 Checks-Effects-Interactions 模式。它先执行外部调用（发送ETH），后更新状态（清零余额）。当外部调用触发攻击者的 receive() 时，余额还未更新，攻击者可以再次提款。",deposit_function:"📖 存款函数是重入攻击的前提条件。攻击者必须先存入一定数量的 ETH，获得提款资格。deposit() 使用 payable 修饰符接收 ETH，并使用 require 验证金额大于0。",checks_effects_interactions:"📖 CEI模式是 Solidity 安全编程的黄金法则。Checks（检查条件）→ Effects（更新状态）→ Interactions（外部调用）。关键是先更新状态再外部调用，这样即使被重入，状态已经是最新的，攻击者无法重复获利。",reentrancy_guard:"📖 重入锁(Reentrancy Guard)使用状态变量跟踪函数执行状态。_NOT_ENTERED(1) 表示未锁定，_ENTERED(2) 表示已锁定。modifier 在函数执行前锁定，执行后解锁。如果函数被重入调用，require 会阻止执行。OpenZeppelin 提供了标准实现。",contract_balance:"📖 address(this).balance 返回合约当前持有的 ETH 数量（以 wei 为单位）。在攻击合约中，它用于判断目标金库是否还有资金可以继续攻击。在管理函数中，它用于查询和提取合约资金。",code_comparison:"📖 通过对比漏洞代码和安全代码，可以清晰看到修复方法：1) 调整代码顺序，先更新状态再外部调用；2) 添加 nonReentrant 修饰符作为双重保护。理解这种差异对编写安全智能合约至关重要。"})[t]||"📖 点击其他概念标签查看更多详细解释。",Be=Do("operationLog",()=>{const t=F([]),e=F({}),n=F({}),r=(d,w,m,S=null)=>{const h=new Date().toLocaleTimeString("zh-CN",{hour12:!1});let D=0,I=0;S&&Da[S]&&(D=Da[S],I=D*Ba,e.value[d]||(e.value[d]=0),e.value[d]+=D),n.value[d]||(n.value[d]=0),n.value[d]++;const b={id:`${d}-${Date.now()}-${Math.random()}`,day:d,timestamp:h,operation:w,details:m,gasUsed:D,ethCost:I};return t.value.unshift(b),b},s=d=>{t.value=t.value.filter(w=>w.day!==d)},i=()=>{t.value=[],e.value={},n.value={}},o=d=>t.value.filter(w=>w.day===d).slice(0,10),a=d=>e.value[d]||0,c=d=>(e.value[d]||0)*Ba,l=d=>n.value[d]||0,u=B(()=>t.value.slice(0,20));return{logs:t,dayGasUsage:e,dayOperationCounts:n,recentLogs:u,addLog:r,clearDayLogs:s,clearAllLogs:i,getDayLogs:o,getDayGasUsage:a,getDayEthCost:c,getDayOperationCount:l}});function lp(){const t=ft(),e=Ue(),n=Be(),r=t.contracts.day1,s=B(()=>r.count),i=B(()=>r.interactionCount),o=()=>{r.count++,r.interactionCount++,n.addLog(1,"点击计数器","Counter +1","increment"),e.incrementInteraction(1);const w=r.count;w===1?e.unlockConcept(1,"function"):w===2?e.unlockConcept(1,"increment"):w===3?e.unlockConcept(1,"uint256"):w===4&&e.unlockConcept(1,"contract")},a=()=>{r.count=0,n.addLog(1,"重置计数器","Counter reset to 0","reset")},c=B(()=>e.dayProgress[1]),l=B(()=>e.getProgressPercentage(1)),u=B(()=>e.dayProgress[1].unlockedConcepts),d=B(()=>({gasUsage:n.getDayGasUsage(1),ethCost:n.getDayEthCost(1),operationCount:n.getDayOperationCount(1)}));return{counter:s,interactionCount:i,progress:c,progressPercentage:l,unlockedConcepts:u,realtimeData:d,clickCounter:o,resetCounter:a}}function up(){const t=ft(),e=Ue(),n=Be(),r=t.contracts.day2,s=e.dayProgress[2],i=B(()=>r.name),o=B(()=>r.bio),a=B(()=>r.hasStored),c=B(()=>r.hasRetrieved),l=B(()=>r.interactionCount),u=(D,I)=>{r.name=D,r.bio=I,r.hasStored=!0,r.interactionCount++,s.interactionCount++,n.addLog(2,"存储数据",`存储: ${D}`,"addData"),["string","private","memory"].forEach(C=>{e.unlockConcept(2,C)})},d=()=>(r.hasRetrieved=!0,r.interactionCount++,s.interactionCount++,n.addLog(2,"检索数据",`查询: ${i.value}`),["view","parameters","returns"].forEach(I=>{e.unlockConcept(2,I)}),{name:i.value,bio:o.value}),w=B(()=>s),m=B(()=>!s||s.totalConcepts===0?0:Math.floor(s.unlockedConcepts.length/s.totalConcepts*100)),S=B(()=>s.unlockedConcepts),h=B(()=>({gasUsage:n.getDayGasUsage(2),ethCost:n.getDayEthCost(2),operationCount:n.getDayOperationCount(2)}));return{name:i,bio:o,hasStored:a,hasRetrieved:c,interactionCount:l,progress:w,progressPercentage:m,unlockedConcepts:S,realtimeData:h,storeData:u,retrieveData:d}}function dp(){const t=ft(),e=Ue(),n=Be(),r=t.contracts.day3,s=B(()=>r.candidates),i=B(()=>r.voteCount),o=B(()=>r.interactionCount),a=m=>{if(!m||m.trim()==="")return;r.candidates.push(m),r.voteCount[m]=0,r.interactionCount++,e.incrementInteraction(3),n.addLog(3,"添加候选人",`候选人: ${m}`,"addCandidate");const S=r.candidates.length;S===1?e.unlockConcept(3,"array"):S===2?e.unlockConcept(3,"push"):S===3&&e.unlockConcept(3,"mapping")},c=m=>{r.voteCount[m]!==void 0&&(r.voteCount[m]++,r.interactionCount++,e.incrementInteraction(3),n.addLog(3,"投票",`投给 ${m}`,"vote"),e.unlockConcept(3,"compound_assignment"))},l=B(()=>e.dayProgress[3]),u=B(()=>e.getProgressPercentage(3)),d=B(()=>e.dayProgress[3].unlockedConcepts),w=B(()=>({gasUsage:n.getDayGasUsage(3),ethCost:n.getDayEthCost(3),operationCount:n.getDayOperationCount(3)}));return{candidates:s,voteCount:i,interactionCount:o,progress:l,progressPercentage:u,unlockedConcepts:d,realtimeData:w,addCandidate:a,voteCandidate:c}}function fp(){const t=ft(),e=Ue(),n=Be(),r=t.contracts.day4,s=e.dayProgress[4],i=F(null),o=B(()=>r.owner),a=B(()=>r.item),c=B(()=>r.auctionEndTime),l=B(()=>r.highestBidder),u=B(()=>r.highestBid),d=B(()=>r.ended),w=B(()=>r.bids),m=B(()=>r.bidders),S=B(()=>r.interactionCount),h=(g,T)=>{r.owner=t.generateAddress(),r.item=g,r.auctionEndTime=Math.floor(Date.now()/1e3)+T,r.interactionCount++,s.interactionCount++,n.addLog(4,"初始化拍卖",`物品: ${g}, 时长: ${T}秒`),e.unlockConcept(4,"constructor"),e.unlockConcept(4,"block_timestamp")},D=(g,T)=>{if(r.ended||Math.floor(Date.now()/1e3)>=r.auctionEndTime||g<=0)return!1;const L=r.bids[T]||0;return g<=L?!1:(r.bids[T]=g,r.interactionCount++,s.interactionCount++,L===0&&r.bidders.push(T),g>r.highestBid&&(r.highestBid=g,r.highestBidder=T),n.addLog(4,"出价",`出价 ${g}`,"placeBid"),e.unlockConcept(4,"require"),r.bidders.length>=1&&e.unlockConcept(4,"msg_sender"),(r.bidders.length>=2||r.interactionCount>=2)&&e.unlockConcept(4,"external"),!0)},I=()=>Math.floor(Date.now()/1e3)<r.auctionEndTime||r.ended?!1:(r.ended=!0,r.interactionCount++,s.interactionCount++,n.addLog(4,"结束拍卖","拍卖已结束","endAuction"),e.unlockConcept(4,"bool_type"),!0),b=()=>r.ended?(r.interactionCount++,s.interactionCount++,n.addLog(4,"查看获胜者",`获胜者: ${r.highestBidder}`),e.unlockConcept(4,"address_type"),i.value={winner:r.highestBidder,bid:r.highestBid},i.value):null,C=g=>g?new Date(g*1e3).toLocaleString("zh-CN"):"未设置",f=()=>Math.floor(Date.now()/1e3)>=r.auctionEndTime,p=B(()=>s),v=B(()=>!s||s.totalConcepts===0?0:Math.floor(s.unlockedConcepts.length/s.totalConcepts*100)),k=B(()=>s.unlockedConcepts),x=B(()=>({gasUsage:n.getDayGasUsage(4),ethCost:n.getDayEthCost(4),operationCount:n.getDayOperationCount(4)}));return{owner:o,item:a,auctionEndTime:c,highestBidder:l,highestBid:u,ended:d,bids:w,bidders:m,interactionCount:S,winner:i,progress:p,progressPercentage:v,unlockedConcepts:k,realtimeData:x,initializeAuction:h,placeBid:D,endAuction:I,getWinner:b,formatTime:C,checkAuctionEnded:f}}function pp(){const t=ft(),e=Ue(),n=Be(),r=F(""),s=F(""),i=F(""),o=F(""),a=F(""),c=B(()=>(t.initializeContract(5),t.getContract(5))),l=B(()=>{var x;return((x=c.value)==null?void 0:x.owner)||""}),u=B(()=>{var x;return((x=c.value)==null?void 0:x.treasureAmount)||0}),d=B(()=>{var x;return((x=c.value)==null?void 0:x.userAddress)||""}),w=B(()=>{var x;return((x=c.value)==null?void 0:x.userAllowance)||0}),m=B(()=>{var x;return(x=c.value)!=null&&x.hasWithdrawn?!!c.value.hasWithdrawn[d.value]:!1}),S=x=>!x||x<=0?!1:(c.value.treasureAmount+=x,c.value.interactionCount++,e.incrementInteraction(5),n.addLog(5,"添加宝藏",`数量: ${x}`,"addTreasure"),e.unlockConcept(5,"modifier"),!0),h=(x,g)=>!x||!g||g<=0?!1:(g<=c.value.treasureAmount&&(c.value.withdrawalAllowance[x]=g,x===c.value.userAddress&&(c.value.userAllowance=g)),c.value.interactionCount++,e.incrementInteraction(5),n.addLog(5,"批准提款",`批准 ${x}: ${g}`,"approveWithdrawal"),e.unlockConcept(5,"return_statement"),!0),D=(x,g)=>{if(!x||!g||g<=0)return!1;let T=!1;if(x===c.value.owner)g<=c.value.treasureAmount&&(c.value.treasureAmount-=g,T=!0);else{const A=c.value.withdrawalAllowance[x];A>0&&!c.value.hasWithdrawn[x]&&A<=c.value.treasureAmount&&A>=g&&(c.value.hasWithdrawn[x]=!0,c.value.treasureAmount-=A,c.value.withdrawalAllowance[x]=0,x===c.value.userAddress&&(c.value.userAllowance=0),T=!0)}return c.value.interactionCount++,e.incrementInteraction(5),T&&n.addLog(5,"提取宝藏",`提取: ${g}`,"withdrawTreasure"),!0},I=x=>(x||(x=c.value.userAddress),c.value.hasWithdrawn[x]=!1,c.value.interactionCount++,e.incrementInteraction(5),n.addLog(5,"重置提款状态",`重置: ${x}`),!0),b=x=>!x||x==="0x0000000000000000000000000000000000000000"?!1:(c.value.owner=x,c.value.interactionCount++,e.incrementInteraction(5),n.addLog(5,"转移所有权",`新所有者: ${x}`,"transferOwnership"),e.unlockConcept(5,"zero_address"),!0),C=()=>(c.value.interactionCount++,e.incrementInteraction(5),n.addLog(5,"查询宝藏",`宝藏数量: ${c.value.treasureAmount}`),e.unlockConcept(5,"return_statement"),c.value.treasureAmount),f=B(()=>e.dayProgress[5]),p=B(()=>{const x=e.dayProgress[5];return!x||x.totalConcepts===0?0:Math.floor(x.unlockedConcepts.length/x.totalConcepts*100)}),v=B(()=>e.dayProgress[5].unlockedConcepts),k=B(()=>({gasUsage:n.getDayGasUsage(5),ethCost:n.getDayEthCost(5),operationCount:n.getDayOperationCount(5)}));return{inputTreasureAmount:r,inputRecipient:s,inputAllowance:i,inputWithdrawAmount:o,inputNewOwner:a,owner:l,treasureAmount:u,userAddress:d,userAllowance:w,hasWithdrawn:m,progress:f,progressPercentage:p,unlockedConcepts:v,realtimeData:k,addTreasure:S,approveWithdrawal:h,withdrawTreasure:D,resetWithdrawalStatus:I,transferOwnership:b,getTreasureDetails:C}}function gp(){const t=ft(),e=Ue(),n=Be(),r=t.contracts.day6,s=e.dayProgress[6],i=F(null),o=F([]),a=B(()=>r.bankManager),c=B(()=>r.members),l=B(()=>r.userAddress),u=B(()=>r.balance[r.userAddress]||0),d=B(()=>r.interactionCount),w=v=>(t.initializeContract(6),v==="0x0000000000000000000000000000000000000000"||v===r.bankManager||r.registeredMembers[v]?!1:(r.registeredMembers[v]=!0,r.members.push(v),r.balance[v]=0,r.interactionCount++,s.interactionCount++,n.addLog(6,"添加会员",`会员: ${v}`,"addMembers"),e.unlockConcept(6,"address_mapping_balance"),!0)),m=v=>{t.initializeContract(6);const k=r.userAddress;if(!r.registeredMembers[k])return!1;const x=v*1e18;return r.balance[k]+=x,r.interactionCount++,s.interactionCount++,n.addLog(6,"存入ETH",`存入 ${v} ETH`,"depositAmountEther"),e.unlockConcept(6,"payable"),e.unlockConcept(6,"msg_value"),!0},S=v=>{t.initializeContract(6);const k=r.userAddress;if(!r.registeredMembers[k])return!1;const x=v*1e18;return r.balance[k]<x?!1:(r.balance[k]-=x,r.interactionCount++,s.interactionCount++,n.addLog(6,"提取ETH",`提取 ${v} ETH`,"withdrawAmount"),e.unlockConcept(6,"wei_unit"),e.unlockConcept(6,"ether_deposit_withdraw"),!0)},h=v=>(t.initializeContract(6),r.interactionCount++,s.interactionCount++,i.value=r.balance[v]||0,n.addLog(6,"查询余额",`查询: ${v}`),i.value),D=()=>(t.initializeContract(6),r.interactionCount++,s.interactionCount++,o.value=[...r.members],o.value),I=v=>(v/1e18).toFixed(4)+" ETH",b=B(()=>s),C=B(()=>!s||s.totalConcepts===0?0:Math.floor(s.unlockedConcepts.length/s.totalConcepts*100)),f=B(()=>s.unlockedConcepts),p=B(()=>({gasUsage:n.getDayGasUsage(6),ethCost:n.getDayEthCost(6),operationCount:n.getDayOperationCount(6)}));return{bankManager:a,members:c,userAddress:l,userBalance:u,interactionCount:d,queryBalance:i,membersList:o,progress:b,progressPercentage:C,unlockedConcepts:f,realtimeData:p,addMembers:w,depositEther:m,withdrawEth:S,getBalance:h,getMembers:D,formatBalance:I}}function mp(){const t=ft(),e=Ue(),n=Be(),r=t.contracts.day7,s=e.dayProgress[7],i=F(null),o=B(()=>r.owner),a=B(()=>r.userAddress),c=B(()=>r.friendList),l=B(()=>r.balances[r.userAddress]||0),u=B(()=>r.debts),d=B(()=>r.interactionCount),w=g=>(t.initializeContract(7),r.registeredFriends[g]?!1:(r.registeredFriends[g]=!0,r.friendList.push(g),r.balances[g]=0,r.interactionCount++,s.interactionCount++,n.addLog(7,"添加好友",`好友: ${g}`,"addFriend"),e.unlockConcept(7,"nested_mapping"),!0)),m=g=>{t.initializeContract(7);const T=r.userAddress;if(!r.registeredFriends[T])return!1;const A=g*1e18;return r.balances[T]=(r.balances[T]||0)+A,r.interactionCount++,s.interactionCount++,n.addLog(7,"存款",`存入 ${g} ETH`,"depositIntoWallet"),e.unlockConcept(7,"address_payable"),!0},S=(g,T)=>{t.initializeContract(7);const A=r.userAddress,L=T*1e18;return r.debts[g]||(r.debts[g]={}),r.debts[g][A]=(r.debts[g][A]||0)+L,r.interactionCount++,s.interactionCount++,n.addLog(7,"记录债务",`债务人: ${g}, 金额: ${T} ETH`,"recordDebt"),e.unlockConcept(7,"debt_tracking"),!0},h=(g,T)=>{t.initializeContract(7);const A=r.userAddress,L=T*1e18;return(r.balances[A]||0)<L?"余额不足：你的钱包可用余额小于还款金额！":(r.balances[A]-=L,r.balances[g]=(r.balances[g]||0)+L,r.debts[A]&&r.debts[A][g]&&(r.debts[A][g]-=L,r.debts[A][g]<0&&(r.debts[A][g]=0)),r.interactionCount++,s.interactionCount++,n.addLog(7,"还款",`债权人: ${g}, 金额: ${T} ETH`,"payFromWallet"),e.unlockConcept(7,"internal_transfer"),!0)},D=(g,T)=>{t.initializeContract(7);const A=r.userAddress,L=T*1e18;return(r.balances[A]||0)<L?"余额不足：试图转账的金额超过了你拥有的钱包余额！":(r.balances[A]-=L,r.balances[g]=(r.balances[g]||0)+L,r.interactionCount++,s.interactionCount++,n.addLog(7,"转账(transfer)",`收款方: ${g}, 金额: ${T} ETH`,"transferEther"),e.unlockConcept(7,"transfer_method"),!0)},I=(g,T)=>{t.initializeContract(7);const A=r.userAddress,L=T*1e18;return(r.balances[A]||0)<L?"余额不足：低级调用失败，因为你的钱包没有足够的以太币！":(r.balances[A]-=L,r.balances[g]=(r.balances[g]||0)+L,r.interactionCount++,s.interactionCount++,n.addLog(7,"转账call",`收款方: ${g}, 金额: ${T} ETH`,"transferEtherViaCall"),e.unlockConcept(7,"call_method"),!0)},b=g=>{t.initializeContract(7);const T=r.userAddress,A=g*1e18;return(r.balances[T]||0)<A?"余额不足：你无法提取超过拥有额度的资金！":(r.balances[T]-=A,r.interactionCount++,s.interactionCount++,n.addLog(7,"提款",`提取 ${g} ETH`,"withdraw"),e.unlockConcept(7,"withdraw_pattern"),!0)},C=()=>{t.initializeContract(7);const g=r.userAddress;return i.value=r.balances[g]||0,r.interactionCount++,s.interactionCount++,n.addLog(7,"查询余额",`余额: ${(i.value/1e18).toFixed(4)} ETH`),e.unlockConcept(7,"withdraw_pattern"),i.value},f=g=>(g/1e18).toFixed(4)+" ETH",p=B(()=>s),v=B(()=>!s||s.totalConcepts===0?0:Math.floor(s.unlockedConcepts.length/s.totalConcepts*100)),k=B(()=>s.unlockedConcepts),x=B(()=>({gasUsage:n.getDayGasUsage(7),ethCost:n.getDayEthCost(7),operationCount:n.getDayOperationCount(7)}));return{owner:o,userAddress:a,friendsList:c,userBalance:l,debts:u,interactionCount:d,checkedBalance:i,progress:p,progressPercentage:v,unlockedConcepts:k,realtimeData:x,iouAddFriend:w,iouDeposit:m,iouRecordDebt:S,iouPayDebt:h,iouTransferMethod:D,iouCallMethod:I,iouWithdraw:b,iouCheckBalance:C,formatBalance:f}}function hp(){const t=ft(),e=Ue(),n=Be(),r=t.contracts.day8,s=e.dayProgress[8],i=B(()=>r.owner),o=B(()=>r.userAddress),a=B(()=>r.isUserAdmin),c=B(()=>r.totalTipsReceived),l=B(()=>r.supportedCurrencies),u=B(()=>r.conversionRates),d=B(()=>r.interactionCount),w=()=>{t.initializeContract(8),r.isUserAdmin=!r.isUserAdmin,r.interactionCount++,s.interactionCount++,n.addLog(8,"切换管理员模式",r.isUserAdmin?"开启管理员模式":"关闭管理员模式"),e.unlockConcept(8,"modifier_onlyOwner")},m=v=>{t.initializeContract(8);const k=v*1e18;r.totalTipsReceived+=k;const x=r.userAddress;r.tipPerPerson[x]=(r.tipPerPerson[x]||0)+k,r.interactionCount++,s.interactionCount++,n.addLog(8,"打赏ETH",`打赏 ${v} ETH`,"tipInEth"),e.unlockConcept(8,"payable_tip")},S=(v,k)=>{t.initializeContract(8);const x=r.conversionRates[v];if(!x)return!1;const g=k*x;r.totalTipsReceived+=g;const T=r.userAddress;return r.tipPerPerson[T]=(r.tipPerPerson[T]||0)+g,r.tipsPerCurrency[v]||(r.tipsPerCurrency[v]=0),r.tipsPerCurrency[v]+=k,r.interactionCount++,s.interactionCount++,n.addLog(8,"打赏货币",`打赏 ${k} ${v}`,"tipInCurrency"),e.unlockConcept(8,"msg_value_tip"),e.unlockConcept(8,"mapping_rates"),!0},h=()=>(t.initializeContract(8),r.isUserAdmin?r.totalTipsReceived===0?"revert: No tips to withdraw":(r.totalTipsReceived=0,r.interactionCount++,s.interactionCount++,n.addLog(8,"提取小费","提取所有小费","withdrawTips"),e.unlockConcept(8,"address_balance"),e.unlockConcept(8,"call_withdraw"),!0):"revert: Only owner can perform this action"),D=()=>{const v=r.userAddress,k=r.tipPerPerson[v]||0;return n.addLog(8,"查询打赏",`累计打赏: ${(k/1e18).toFixed(4)} ETH`),k},I=v=>(v/1e18).toFixed(4)+" ETH",b=B(()=>s),C=B(()=>!s||s.totalConcepts===0?0:Math.floor(s.unlockedConcepts.length/s.totalConcepts*100)),f=B(()=>s.unlockedConcepts),p=B(()=>({gasUsage:n.getDayGasUsage(8),ethCost:n.getDayEthCost(8),operationCount:n.getDayOperationCount(8)}));return{owner:i,userAddress:o,isAdmin:a,totalTips:c,supportedCurrencies:l,conversionRates:u,interactionCount:d,progress:b,progressPercentage:C,unlockedConcepts:f,realtimeData:p,tipJarToggleAdmin:w,tipJarTipInEth:m,tipJarTipInCurrency:S,tipJarWithdraw:h,getUserTips:D,formatBalance:I}}function yp(){const t=ft(),e=Ue(),n=Be(),r=t.contracts.day9,s=e.dayProgress[9],i=B(()=>r.owner),o=B(()=>r.userAddress),a=B(()=>r.isUserAdmin),c=B(()=>r.scientificCalculatorAddress),l=B(()=>r.isAddressSet),u=B(()=>r.operationCount),d=B(()=>r.operationHistory),w=B(()=>r.interactionCount),m=B(()=>r.challengeTasks||{setAddress:!1,powerCalc:!1,sqrtCalc:!1,permissionCheck:!1}),S=()=>{t.initializeContract(9),r.isUserAdmin=!r.isUserAdmin,n.addLog(9,"切换身份",r.isUserAdmin?"切换为管理员":"切换为用户")},h=(A,L,K)=>{if(t.initializeContract(9),isNaN(L)||isNaN(K))throw new Error("请输入有效的数字");let ee;switch(A){case"add":ee=L+K;break;case"subtract":ee=L-K;break;case"multiply":ee=L*K;break;case"divide":if(K===0)throw new Error("不能除以零");ee=L/K;break;default:throw new Error("未知运算符")}r.operationCount++,r.operationHistory.push({operator:A,a:L,b:K,result:ee,timestamp:Date.now()}),r.interactionCount++,s.interactionCount++;const M={add:"加法",subtract:"减法",multiply:"乘法",divide:"除法"};return n.addLog(9,"基础运算",`${M[A]}: ${L} ${A==="add"?"+":A==="subtract"?"-":A==="multiply"?"×":"÷"} ${K} = ${ee}`),r.operationCount>=3&&e.unlockConcept(9,"pure_function"),ee},D=A=>{if(t.initializeContract(9),!r.isUserAdmin)throw new Error("Only owner can do this action");if(!A||A.length<3)throw new Error("请输入合约地址");if(!A.startsWith("0x"))throw new Error("合约地址必须以 0x 开头");return r.scientificCalculatorAddress=A,r.isAddressSet=!0,r.interactionCount++,s.interactionCount++,n.addLog(9,"设置合约地址",`科学计算器地址: ${A}`),r.challengeTasks||(r.challengeTasks={setAddress:!1,powerCalc:!1,sqrtCalc:!1,permissionCheck:!1}),r.challengeTasks.setAddress=!0,e.unlockConcept(9,"modifier_onlyOwner"),!0},I=(A,L)=>{if(t.initializeContract(9),!r.isAddressSet)throw new Error("请先设置ScientificCalculator合约地址");if(isNaN(A)||isNaN(L))throw new Error("请输入有效的数字");let K=1;for(let ee=0;ee<L;ee++)K*=A;return r.interactionCount++,s.interactionCount++,n.addLog(9,"指数运算",`${A}^${L} = ${K}`),r.challengeTasks||(r.challengeTasks={setAddress:!1,powerCalc:!1,sqrtCalc:!1,permissionCheck:!1}),r.challengeTasks.powerCalc=!0,e.unlockConcept(9,"view_function"),e.unlockConcept(9,"cross_contract_call"),e.unlockConcept(9,"interface_call"),K},b=A=>{if(t.initializeContract(9),!r.isAddressSet)throw new Error("请先设置ScientificCalculator合约地址");if(isNaN(A)||A<0)throw new Error("请输入有效的非负数字");let L=A/2;const K=[];for(let ee=0;ee<10;ee++){const M=L;L=(L+A/L)/2,K.push({round:ee+1,value:L,prevValue:M,formula:`(${M.toFixed(4)} + ${A}/${M.toFixed(4)}) / 2 = ${L.toFixed(4)}`})}return r.interactionCount++,s.interactionCount++,n.addLog(9,"平方根计算",`√${A} ≈ ${Math.floor(L)}`),r.challengeTasks||(r.challengeTasks={setAddress:!1,powerCalc:!1,sqrtCalc:!1,permissionCheck:!1}),r.challengeTasks.sqrtCalc=!0,e.unlockConcept(9,"low_level_call"),{result:Math.floor(L),steps:K}},C=async(A,L=!1)=>{if(t.initializeContract(9),isNaN(A)||A<0)throw new Error("请输入有效的非负数字");const K=[];let ee=A/2;for(let M=0;M<10;M++){const O=ee;ee=(ee+A/ee)/2,K.push({round:M+1,value:ee,prevValue:O,formula:`(${O.toFixed(4)} + ${A}/${O.toFixed(4)}) / 2 = ${ee.toFixed(4)}`}),L&&await new Promise(E=>setTimeout(E,500))}return r.interactionCount++,s.interactionCount++,n.addLog(9,"牛顿迭代",`计算 √${A} 的迭代过程`),e.unlockConcept(9,"newton_iteration"),K},f=A=>(t.initializeContract(9),n.addLog(9,"权限验证",A?"以管理员身份验证":"以用户身份验证"),A?(r.challengeTasks||(r.challengeTasks={setAddress:!1,powerCalc:!1,sqrtCalc:!1,permissionCheck:!1}),r.challengeTasks.permissionCheck=!0,{success:!0,message:"验证通过：Owner权限确认"}):{success:!1,message:"验证失败：Only owner can do this action"}),p=()=>{t.initializeContract(9);const A=r.challengeTasks||{setAddress:!1,powerCalc:!1,sqrtCalc:!1,permissionCheck:!1},L=Object.values(A).filter(K=>K).length;return L===4?(e.unlockConcept(9,"contract_composition"),{success:!0,message:"🎉 恭喜！你已完成所有挑战任务！"}):{success:!1,message:`还有 ${4-L} 个任务未完成`}},v=B(()=>s),k=B(()=>e.getProgressPercentage(9)),x=B(()=>e.getUnlockedConcepts(9)),g=B(()=>{const A=r.challengeTasks||{setAddress:!1,powerCalc:!1,sqrtCalc:!1,permissionCheck:!1};return Object.values(A).filter(L=>L).length}),T=B(()=>({gasUsage:n.getDayGasUsage(9),ethCost:n.getDayEthCost(9),operationCount:n.getDayOperationCount(9)}));return{owner:i,userAddress:o,isOwner:a,scientificCalculatorAddress:c,isAddressSet:l,operationCount:u,operationHistory:d,interactionCount:w,challengeTasks:m,progress:v,progressPercentage:k,unlockedConcepts:x,completedChallengeCount:g,realtimeData:T,toggleIdentity:S,calculate:h,setScientificCalculator:D,calculatePower:I,calculateSquareRoot:b,runNewtonIteration:C,checkPermission:f,completeChallenge:p}}function bp(){const t=ft(),e=Ue(),n=Be(),r=t.contracts.day10,s=e.dayProgress[10],i=B(()=>r.owner),o=B(()=>r.userAddress),a=B(()=>r.userProfile),c=B(()=>r.workoutHistory),l=B(()=>r.totalWorkouts),u=B(()=>r.totalDistance),d=B(()=>r.milestones),w=B(()=>r.userProfile.isRegistered),m=()=>{t.initializeContract(10)},S=O=>({struct_definition:"📦 太棒了！你学会了使用结构体打包数据！👉 记录一次运动来看看时间戳如何工作！",event_logging:"📋 不错！你触发了事件日志！👉 记录运动来查看运动历史如何存储！",onlyRegistered_modifier:"🛡️ 太棒了！你了解了修饰符如何保护函数！👉 记录运动来解锁更多概念！",timestamp_usage:"⏰ 很好！你学会了记录时间戳！👉 查看运动历史来解锁 array_in_mapping！",array_in_mapping:"🗂️ 很好！你看到了映射到数组的用法！👉 查看统计数据来解锁 multiple_mappings！",multiple_mappings:"🗺️ 优秀！你了解了多个映射如何协同工作！👉 更新体重来解锁 storage_keyword！",storage_keyword:"💾 太棒了！你了解了 storage 的威力！👉 继续记录运动，达成里程碑来解锁 milestone_detection！",milestone_detection:"🏆 恭喜！你达成了里程碑！👉 查看完整代码来复习所有知识！"})[O]||"",h=(O,E)=>{if(m(),r.userProfile.isRegistered)return{success:!1,error:"User already registered"};r.userProfile={name:O,weight:E,isRegistered:!0},r.interactionCount++,s.interactionCount++,n.addLog(10,"注册用户",`用户: ${O}, 体重: ${E}kg`);const $=[];return e.unlockConcept(10,"struct_definition"),$.push(S("struct_definition")),e.unlockConcept(10,"event_logging"),$.push(S("event_logging")),e.unlockConcept(10,"onlyRegistered_modifier"),$.push(S("onlyRegistered_modifier")),{success:!0,unlockedHints:$}},D=(O,E,$)=>{if(m(),!r.userProfile.isRegistered)return{success:!1,error:"User not registered"};const Y={activityType:O,duration:E,distance:$,timestamp:Date.now()};r.workoutHistory.unshift(Y);const ne=r.totalDistance;r.totalWorkouts++,r.totalDistance+=$,r.interactionCount++,s.interactionCount++,n.addLog(10,"记录运动",`${O} ${$}米 ${v(E)}`);const ce=!e.isConceptUnlocked(10,"timestamp_usage"),pe=!e.isConceptUnlocked(10,"array_in_mapping");e.unlockConcept(10,"timestamp_usage"),e.unlockConcept(10,"array_in_mapping");const st=b(ne),ze=[];return ce&&ze.push(S("timestamp_usage")),pe&&ze.push(S("array_in_mapping")),st&&ze.push(S("milestone_detection")),{success:!0,unlockedHints:ze}},I=O=>{if(m(),!r.userProfile.isRegistered)return{success:!1,error:"User not registered"};const E=r.userProfile.weight;let $=!1;O<E&&E>0&&(E-O)*100/E>=5&&(C("weightGoal"),$=!0),r.userProfile.weight=O,r.interactionCount++,s.interactionCount++,n.addLog(10,"更新体重",`${E}kg → ${O}kg`);const Y=!e.isConceptUnlocked(10,"storage_keyword"),ne=!e.isConceptUnlocked(10,"multiple_mappings");e.unlockConcept(10,"storage_keyword"),e.unlockConcept(10,"multiple_mappings");const ce=[];return Y&&ce.push(S("storage_keyword")),ne&&ce.push(S("multiple_mappings")),$&&ce.push(S("milestone_detection")),{success:!0,unlockedHints:ce}},b=(O,E)=>{const $=r.totalWorkouts,Y=r.totalDistance;let ne=!1;return $===10?(C("workouts10"),ne=!0):$===50&&(C("workouts50"),ne=!0),Y>=1e5&&O<1e5&&(C("distance100K"),ne=!0),ne},C=O=>{const E=r.milestones[O];E&&!E.achieved&&(E.achieved=!0,E.timestamp=Date.now(),e.unlockConcept(10,"milestone_detection"))},f=(O,E)=>E==="minutes"?O*60:E==="hours"?O*3600:O,p=(O,E)=>E==="kilometers"?O*1e3:O,v=O=>{if(O<60)return`${O}秒`;if(O<3600)return`${Math.floor(O/60)}分钟`;{const E=Math.floor(O/3600),$=Math.floor(O%3600/60);return $>0?`${E}小时${$}分钟`:`${E}小时`}},k=O=>O<1e3?`${O}米`:`${(O/1e3).toFixed(2)}公里`,x=O=>new Date(O).toLocaleString("zh-CN",{year:"numeric",month:"2-digit",day:"2-digit",hour:"2-digit",minute:"2-digit"}),g=O=>({跑步:"🏃",Running:"🏃",骑行:"🚴",Cycling:"🚴",游泳:"🏊",Swimming:"🏊",步行:"🚶",Walking:"🚶",瑜伽:"🧘",Yoga:"🧘",篮球:"⛹️",Basketball:"⛹️"})[O]||"💪",T=()=>{const O=!e.isConceptUnlocked(10,"array_in_mapping");return e.unlockConcept(10,"array_in_mapping"),n.addLog(10,"查看运动历史",`共 ${r.workoutHistory.length} 条记录`),O?S("array_in_mapping"):null},A=()=>{const O=!e.isConceptUnlocked(10,"multiple_mappings");return e.unlockConcept(10,"multiple_mappings"),n.addLog(10,"查看统计",`总运动: ${r.totalWorkouts}次, 总距离: ${k(r.totalDistance)}`),O?S("multiple_mappings"):null},L=B(()=>s),K=B(()=>!s||s.totalConcepts===0?0:Math.floor(s.unlockedConcepts.length/s.totalConcepts*100)),ee=B(()=>s.unlockedConcepts),M=B(()=>({gasUsage:n.getDayGasUsage(10),ethCost:n.getDayEthCost(10),operationCount:n.getDayOperationCount(10)}));return{owner:i,userAddress:o,userProfile:a,workoutHistory:c,totalWorkouts:l,totalDistance:u,milestones:d,isRegistered:w,progress:L,progressPercentage:K,unlockedConcepts:ee,realtimeData:M,registerUser:h,logWorkout:D,updateWeight:I,convertToSeconds:f,convertToMeters:p,formatDuration:v,formatDistance:k,formatTimestamp:x,getActivityIcon:g,viewWorkoutHistory:T,viewStatistics:A,initializeContract:m}}function wp(){const t=ft(),e=Ue(),n=Be(),r=B(()=>(t.initializeContract(11),t.getContract(11))),s=B(()=>{var p;return((p=r.value)==null?void 0:p.owner)||""}),i=B(()=>{var p;return((p=r.value)==null?void 0:p.contractBalance)||0}),o=B(()=>{var p;return((p=r.value)==null?void 0:p.userAddress)||""}),a=B(()=>o.value===s.value),c=B(()=>{var p;return((p=r.value)==null?void 0:p.eventLog)||[]}),l=p=>({inheritance:"📦 太棒了！你看到 VaultMaster 继承了 Ownable 的功能！👉 存入 ETH 来学习 import 机制！",constructor:"🏗️ 太棒了！你了解了构造函数！👉 存入 ETH 来学习导入语句和私有变量！",import_statement:"📥 不错！你了解了导入语句！👉 继续存入 ETH 来学习事件日志！",event_logging:"📋 很好！你触发了事件日志！👉 尝试转移所有权来解锁更多概念！",private_visibility:"🔒 优秀！你学会了 private 变量的使用！合约余额等敏感数据都使用 private 保护！",transfer_ownership:"🔑 很好！你了解了所有权转移！👉 尝试以用户身份提取来学习修饰符！",indexed_parameter:"🏷️ 不错！你了解了索引参数！👉 切换到用户身份体验权限控制！",onlyOwner_modifier:"🛡️ 太棒了！你了解了 onlyOwner 修饰符！👉 查看完整代码来学习更多！"})[p]||"",u=p=>{var x;const v=e.dayProgress[11];return((x=v==null?void 0:v.unlockedConcepts)==null?void 0:x.includes(p))?null:(e.unlockConcept(11,p),l(p))},d=()=>"0x"+Array(40).fill(0).map(()=>Math.floor(Math.random()*16).toString(16)).join(""),w=()=>r.value?(r.value.userAddress=r.value.owner,e.incrementInteraction(11),n.addLog(11,"切换身份","切换为所有者身份"),{hint:"✅ 已切换到所有者身份！👉 现在可以转移所有权和提取资金了！"}):null,m=()=>{if(r.value){const p=d();return r.value.userAddress=p,e.incrementInteraction(11),n.addLog(11,"切换身份",`切换为用户身份: ${p.slice(0,10)}...`),{hint:"👤 已切换到用户身份！👉 现在尝试提取资金来体验权限控制！"}}return null},S=()=>{e.incrementInteraction(11),n.addLog(11,"查询所有者",`所有者: ${s.value.slice(0,10)}...`);const p=[],v=u("inheritance");v&&p.push(v);const k=u("constructor");return k&&p.push(k),{address:s.value,hint:p.length>0?p.join(`
`):null}},h=()=>(e.incrementInteraction(11),n.addLog(11,"查询余额",`合约余额: ${(i.value/1e18).toFixed(4)} ETH`),i.value),D=p=>{if(!p||p<=0)return{success:!1,error:"金额无效"};const v=Math.floor(p*1e18);r.value.contractBalance+=v,r.value.eventLog.push({name:"DepositSuccessful",icon:"💰",details:`存入 ${p} ETH (${v} wei)`,timestamp:Date.now()}),r.value.interactionCount++,e.incrementInteraction(11),n.addLog(11,"存款",`存入 ${p} ETH`);const k=[],x=u("import_statement");x&&k.push(x);const g=u("event_logging");g&&k.push(g);const T=u("private_visibility");return T&&k.push(T),{success:!0,hints:k}},I=(p,v)=>{if(!p||!v||v<=0)return{success:!1,error:"参数无效"};if(!a.value)return u("onlyOwner_modifier"),e.incrementInteraction(11),n.addLog(11,"提取失败","权限不足：非所有者尝试提取"),{success:!1,error:"❌ 权限不足：只有所有者才能提取资金 🛡️ 解锁知识点：onlyOwner 修饰符！"};const k=Math.floor(v*1e18);return k>i.value?{success:!1,error:"余额不足"}:(r.value.contractBalance-=k,r.value.eventLog.push({name:"WithdrawSuccessful",icon:"💸",details:`提取 ${v} ETH 到 ${p.slice(0,6)}...${p.slice(-4)}`,timestamp:Date.now()}),r.value.interactionCount++,e.incrementInteraction(11),n.addLog(11,"提取资金",`提取 ${v} ETH 到 ${p.slice(0,10)}...`),{success:!0})},b=p=>{var A;if(!p||p==="0x0000000000000000000000000000000000000000")return{success:!1,error:"无效地址"};if(!a.value)return{success:!1,error:"权限不足"};const v=r.value.owner;r.value.owner=p,r.value.userAddress===v&&(r.value.userAddress=p),r.value.eventLog.push({name:"OwnershipTransferred",icon:"🔑",details:`所有权从 ${v.slice(0,6)}... 转移到 ${p.slice(0,6)}...`,timestamp:Date.now()}),r.value.interactionCount++,e.incrementInteraction(11),n.addLog(11,"转移所有权",`${v.slice(0,10)}... → ${p.slice(0,10)}...`);const k=[],x=u("transfer_ownership");x&&k.push(x);const g=u("indexed_parameter");g&&k.push(g);const T=e.dayProgress[11];return(A=T==null?void 0:T.unlockedConcepts)!=null&&A.includes("onlyOwner_modifier")||k.push('🛡️ 想体验权限控制吗？👉 切换到"用户"身份，尝试提取资金！'),{success:!0,hints:k}},C=()=>(e.incrementInteraction(11),n.addLog(11,"查看代码","查看完整合约代码"),{hints:["📖 你已了解所有核心概念！查看完整代码来巩固知识吧！"]}),f=B(()=>({gasUsage:n.getDayGasUsage(11),ethCost:n.getDayEthCost(11),operationCount:n.getDayOperationCount(11)}));return{owner:s,contractBalance:i,userAddress:o,isOwner:a,eventLog:c,realtimeData:f,getOwner:S,getBalance:h,deposit:D,withdraw:I,transferOwnership:b,setOwnerMode:w,setUserMode:m,viewFullCode:C,unlockConceptWithHint:u,getUnlockHint:l}}function vp(){const t=Be(),e=F({name:"Web3 Compass",symbol:"COM",decimals:18,totalSupply:1e6}),n={alice:"0xAlice7429aC95B2cF0e4b5F1F4E4e8e7D6c5B4A3210",bob:"0xBob8F3a2B1c0D9e8F7A6B5C4D3E2F1A0B9C8D7E6F",carol:"0xCarol5A6B7C8D9E0F1A2B3C4D5E6F7A8B9C0D1E2F"},r=F({[n.alice]:1e6,[n.bob]:0,[n.carol]:0}),s=F({[n.alice]:{[n.carol]:0},[n.bob]:{},[n.carol]:{}}),i=F("alice"),o=F([{icon:"🟢",name:"Transfer",details:"从: 0x0000...0000 到: Alice 数量: 1,000,000 COM (铸币)",timestamp:Date.now()}]),a=B(()=>n[i.value]),c=b=>b===n.alice?"Alice":b===n.bob?"Bob":b===n.carol?"Carol":b.slice(0,6)+"..."+b.slice(-4),l=b=>b?b===n.alice?"Alice (0xAlice...3210)":b===n.bob?"Bob (0xBob...7E6F)":b===n.carol?"Carol (0xCarol...E2F)":b.slice(0,10)+"..."+b.slice(-8):"",u=b=>{i.value=b;const C={alice:"👑 已切换到 Alice（代币持有者）",bob:"👤 已切换到 Bob（普通用户）",carol:"🔑 已切换到 Carol（可被授权者）"};return t.addLog(12,"切换角色",C[b]),{success:!0,message:C[b],hints:[],nextStep:""}},d=b=>{const C=r.value[b]||0,f=c(b);return t.addLog(12,"查询余额",`${f}: ${C.toLocaleString()} COM`),{success:!0,balance:C,message:`📊 查询成功！${f} 余额: ${C.toLocaleString()} COM`,hints:[],nextStep:"💡 余额使用 mapping(address => uint256) 存储！👉 转账给 Bob 来学习事件机制！"}},w=(b,C)=>{const f=a.value,p=c(f),v=c(b);return r.value[f]<C?(t.addLog(12,"转账失败",`余额不足: ${p} → ${v}`),{success:!1,message:`❌ 转账失败！余额不足。当前余额: ${r.value[f].toLocaleString()} COM，尝试转账: ${C.toLocaleString()} COM`,hints:[],nextStep:""}):b==="0x0000000000000000000000000000000000000000"?(t.addLog(12,"转账失败","接收地址不能是零地址"),{success:!1,message:"❌ 转账失败！接收地址不能是零地址。",hints:[],nextStep:""}):f===b?(t.addLog(12,"转账失败","不能转账给自己"),{success:!1,message:"❌ 转账失败！不能转账给自己。",hints:[],nextStep:""}):(r.value[f]-=C,r.value[b]=(r.value[b]||0)+C,o.value.push({icon:"🟢",name:"Transfer",details:`从: ${p} 到: ${v} 数量: ${C.toLocaleString()} COM`,timestamp:Date.now()}),t.addLog(12,"转账",`${p} → ${v}: ${C.toLocaleString()} COM`),{success:!0,message:`✅ 转账成功！${p} 向 ${v} 转账 ${C.toLocaleString()} COM 📋 恭喜解锁：事件日志！💸 恭喜解锁：转账函数！`,hints:["event","transfer"],nextStep:"👉 授权给 Carol 来学习授权机制！"})},m=(b,C)=>{const f=a.value,p=c(f),v=c(b);return i.value!=="alice"?(t.addLog(12,"授权失败","只有 Alice 才能授权"),{success:!1,message:"❌ 授权失败！只有代币持有者 Alice 才能授权。请切换到 Alice。",hints:[],nextStep:""}):f===b?(t.addLog(12,"授权失败","不能授权给自己"),{success:!1,message:"❌ 授权失败！不能授权给自己。",hints:[],nextStep:""}):(s.value[f]||(s.value[f]={}),s.value[f][b]=C,o.value.push({icon:"🟡",name:"Approval",details:`持有者: ${p} 被授权者: ${v} 额度: ${C.toLocaleString()} COM`,timestamp:Date.now()}),t.addLog(12,"授权",`${p} → ${v}: ${C.toLocaleString()} COM`),{success:!0,message:`✅ 授权成功！${p} 授权 ${v} 可以使用 ${C.toLocaleString()} COM ✅ 恭喜解锁：授权函数！`,hints:["approve"],nextStep:"👉 查询 allowance 来学习授权额度查询！"})},S=(b,C)=>{var k;const f=((k=s.value[b])==null?void 0:k[C])||0,p=c(b),v=c(C);return t.addLog(12,"查询授权额度",`${v} 可用 ${p}: ${f.toLocaleString()} COM`),{success:!0,allowance:f,message:`🔍 查询成功！${v} 可使用 ${p} 的额度: ${f.toLocaleString()} COM 🗂️ 恭喜解锁：嵌套映射！🔍 恭喜解锁：授权额度查询！`,hints:["mapping_nested","allowance"],nextStep:"👉 切换到 Carol 执行代转账来学习 transferFrom！"}},h=(b,C,f)=>{var T;const p=a.value,v=c(p),k=c(b),x=c(C);if(i.value!=="carol")return t.addLog(12,"代转账失败","只有 Carol 才能执行代转账"),{success:!1,message:"❌ 代转账失败！只有被授权者 Carol 才能执行代转账。请切换到 Carol。",hints:[],nextStep:""};if(b!==n.alice)return t.addLog(12,"代转账失败","Carol 只被 Alice 授权"),{success:!1,message:"❌ 代转账失败！Carol 只被 Alice 授权，只能从 Alice 账户代转账。",hints:[],nextStep:""};const g=((T=s.value[b])==null?void 0:T[p])||0;return g<f?(t.addLog(12,"代转账失败",`授权额度不足: ${g.toLocaleString()} COM`),{success:!1,message:`❌ 授权额度不足！Carol 只能使用 Alice 的 ${g.toLocaleString()} COM，尝试转账: ${f.toLocaleString()} COM`,hints:[],nextStep:""}):r.value[b]<f?(t.addLog(12,"代转账失败",`余额不足: ${k}`),{success:!1,message:`❌ 余额不足！${k} 当前余额: ${r.value[b].toLocaleString()} COM`,hints:[],nextStep:""}):(r.value[b]-=f,r.value[C]=(r.value[C]||0)+f,s.value[b][p]-=f,o.value.push({icon:"🟢",name:"Transfer",details:`从: ${k} 到: ${x} 数量: ${f.toLocaleString()} COM (by ${v})`,timestamp:Date.now()}),t.addLog(12,"代转账",`${v} 代替 ${k} → ${x}: ${f.toLocaleString()} COM`),{success:!0,message:`✅ 代转账成功！${v} 代替 ${k} 向 ${x} 转账 ${f.toLocaleString()} COM 🔄 恭喜解锁：代转账函数！`,hints:["transferFrom"],nextStep:"🎉 你已掌握 ERC20 全部核心功能！"})},D=b=>new Date(b).toLocaleTimeString("zh-CN",{hour:"2-digit",minute:"2-digit",second:"2-digit"}),I=B(()=>({gasUsage:t.getDayGasUsage(12),ethCost:t.getDayEthCost(12),operationCount:t.getDayOperationCount(12)}));return{tokenInfo:e,roles:n,balances:r,allowances:s,currentRole:i,currentAddress:a,eventLog:o,realtimeData:I,switchRole:u,getBalance:d,transfer:w,approve:m,getAllowance:S,transferFrom:h,getRoleName:c,formatAddress:l,formatTime:D}}function _p(){const t=Be(),e=F({name:"Web3 Compass",symbol:"WBT",decimals:18,totalSupply:1e6}),n={deployer:"0xDeployer7429aC95B2cF0e4b5F1F4E4e8e7D6c5B4A3210",alice:"0xAlice8F3a2B1c0D9e8F7A6B5C4D3E2F1A0B9C8D7E6F",bob:"0xBob5A6B7C8D9E0F1A2B3C4D5E6F7A8B9C0D1E2F"},r=F({[n.deployer]:1e6,[n.alice]:0,[n.bob]:0}),s=F({[n.deployer]:{[n.alice]:0,[n.bob]:0},[n.alice]:{},[n.bob]:{}}),i=F("deployer"),o=F([{icon:"🪙",name:"Mint",details:"Transfer(address(0), Deployer, 1,000,000 WBT) - 合约部署时铸造",timestamp:Date.now(),type:"mint"}]),a=B(()=>n[i.value]),c=b=>b===n.deployer?"Deployer":b===n.alice?"Alice":b===n.bob?"Bob":b.slice(0,6)+"..."+b.slice(-4),l=b=>b?b===n.deployer?"Deployer (0xDeployer...3210)":b===n.alice?"Alice (0xAlice...7E6F)":b===n.bob?"Bob (0xBob...E2F)":b.slice(0,10)+"..."+b.slice(-8):"",u=b=>{i.value=b;const C={deployer:"✅ 已切换到 Deployer（合约部署者/代币持有者）！👉 执行转账操作来解锁 internal 和 virtual 函数！",alice:"✅ 已切换到 Alice（普通用户）！👉 让 Deployer 授权给你，然后执行代转账！",bob:"✅ 已切换到 Bob（可被授权者）！👉 让 Deployer 授权给你，然后执行代转账！"};return t.addLog(13,"切换角色",C[b]),{success:!0,message:C[b],hints:[],nextStep:""}},d=b=>{const C=r.value[b]||0,f=c(b);return t.addLog(13,"查询余额",`${f}: ${C.toLocaleString()} WBT`),{success:!0,balance:C,message:`📊 查询成功！${f} 余额: ${C.toLocaleString()} WBT 👉 执行转账来解锁 internal 和 virtual 函数！`,hints:[],nextStep:"💡 余额使用 mapping(address => uint256) 存储！👉 执行转账来解锁 internal 和 virtual 函数！"}},w=(b,C)=>{const f=a.value,p=c(f),v=c(b);return r.value[f]<C?(t.addLog(13,"转账失败",`余额不足: ${p} → ${v}`),{success:!1,message:`❌ 转账失败！余额不足。当前余额: ${r.value[f].toLocaleString()} WBT，尝试转账: ${C.toLocaleString()} WBT`,hints:[],nextStep:""}):b==="0x0000000000000000000000000000000000000000"?(t.addLog(13,"转账失败","接收地址不能是零地址"),{success:!1,message:"❌ 转账失败！接收地址不能是零地址。",hints:[],nextStep:""}):f===b?(t.addLog(13,"转账失败","不能转账给自己"),{success:!1,message:"❌ 转账失败！不能转账给自己。",hints:[],nextStep:""}):(r.value[f]-=C,r.value[b]=(r.value[b]||0)+C,o.value.push({icon:"🟢",name:"Transfer",details:`从: ${p} 到: ${v} 数量: ${C.toLocaleString()} WBT`,timestamp:Date.now(),type:"transfer"}),t.addLog(13,"转账",`${p} → ${v}: ${C.toLocaleString()} WBT`,"transfer13"),{success:!0,message:`✅ 转账成功！${p} 向 ${v} 转账 ${C.toLocaleString()} WBT 🎉 恭喜解锁：internal 和 virtual 函数！👉 点击查看代码了解所有知识点！`,hints:["internal_function"],nextStep:"🔒 太棒了！transfer() 内部调用了 _transfer() 这个 internal 函数！同时解锁了 virtual 关键字！👉 点击查看代码了解所有知识点！"})},m=(b,C)=>{const f=a.value,p=c(f),v=c(b);return i.value!=="deployer"?(t.addLog(13,"授权失败","只有 Deployer 才能授权"),{success:!1,message:"❌ 授权失败！只有代币持有者 Deployer 才能授权。请切换到 Deployer。",hints:[],nextStep:""}):f===b?(t.addLog(13,"授权失败","不能授权给自己"),{success:!1,message:"❌ 授权失败！不能授权给自己。",hints:[],nextStep:""}):(s.value[f]||(s.value[f]={}),s.value[f][b]=C,o.value.push({icon:"🟡",name:"Approval",details:`持有者: ${p} 被授权者: ${v} 额度: ${C.toLocaleString()} WBT`,timestamp:Date.now(),type:"approval"}),t.addLog(13,"授权",`${p} → ${v}: ${C.toLocaleString()} WBT`,"approve13"),{success:!0,message:`✅ 授权成功！${p} 授权 ${v} 可以使用 ${C.toLocaleString()} WBT`,hints:[],nextStep:"👉 切换到 Bob 执行代转账来学习更多！"})},S=(b,C)=>{var k;const f=((k=s.value[b])==null?void 0:k[C])||0,p=c(b),v=c(C);return t.addLog(13,"查询授权额度",`${v} 可用 ${p}: ${f.toLocaleString()} WBT`),{success:!0,allowance:f,message:`🔍 查询成功！${v} 可使用 ${p} 的额度: ${f.toLocaleString()} WBT 👉 切换到 Bob 执行代转账！`,hints:[],nextStep:"👉 切换到 Bob 执行代转账来学习 transferFrom！"}},h=(b,C,f)=>{var T;const p=a.value,v=c(p),k=c(b),x=c(C);if(i.value!=="bob")return t.addLog(13,"代转账失败","只有 Bob 才能执行代转账"),{success:!1,message:"❌ 代转账失败！只有被授权者 Bob 才能执行代转账。请切换到 Bob。",hints:[],nextStep:""};if(b!==n.deployer)return t.addLog(13,"代转账失败","Bob 只被 Deployer 授权"),{success:!1,message:"❌ 代转账失败！Bob 只被 Deployer 授权，只能从 Deployer 账户代转账。",hints:[],nextStep:""};const g=((T=s.value[b])==null?void 0:T[p])||0;return g<f?(t.addLog(13,"代转账失败",`授权额度不足: ${g.toLocaleString()} WBT`),{success:!1,message:`❌ 授权额度不足！Bob 只能使用 Deployer 的 ${g.toLocaleString()} WBT，尝试转账: ${f.toLocaleString()} WBT`,hints:[],nextStep:""}):r.value[b]<f?(t.addLog(13,"代转账失败",`余额不足: ${k}`),{success:!1,message:`❌ 余额不足！${k} 当前余额: ${r.value[b].toLocaleString()} WBT`,hints:[],nextStep:""}):(r.value[b]-=f,r.value[C]=(r.value[C]||0)+f,s.value[b][p]-=f,o.value.push({icon:"🟢",name:"Transfer",details:`从: ${k} 到: ${x} 数量: ${f.toLocaleString()} WBT (by ${v})`,timestamp:Date.now(),type:"transfer"}),t.addLog(13,"代转账",`${v} 代替 ${k} → ${x}: ${f.toLocaleString()} WBT`,"transferFrom13"),{success:!0,message:`✅ 代转账成功！${v} 代替 ${k} 向 ${x} 转账 ${f.toLocaleString()} WBT 👉 点击查看代码了解 virtual 关键字！`,hints:[],nextStep:"🎉 太棒了！你已掌握 MyToken 全部核心功能！👉 点击查看代码了解 virtual 关键字！"})},D=b=>new Date(b).toLocaleTimeString("zh-CN",{hour:"2-digit",minute:"2-digit",second:"2-digit"}),I=B(()=>({gasUsage:t.getDayGasUsage(13),ethCost:t.getDayEthCost(13),operationCount:t.getDayOperationCount(13)}));return{tokenInfo:e,roles:n,balances:r,allowances:s,currentRole:i,currentAddress:a,eventLog:o,realtimeData:I,switchRole:u,getBalance:d,transfer:w,approve:m,getAllowance:S,transferFrom:h,getRoleName:c,formatAddress:l,formatTime:D}}function xp(){const t=Be(),e={alice:"0xAlice8F3a2B1c0D9e8F7A6B5C4D3E2F1A0B9C8D7E6F",bob:"0xBob5A6B7C8D9E0F1A2B3C4D5E6F7A8B9C0D1E2F"},n=F("alice"),r=F(0),s=F([]),i=F([]),o=B(()=>e[n.value]),a=B(()=>s.value.filter(g=>g.owner===o.value)),c=g=>g===e.alice?"Alice":g===e.bob?"Bob":g.slice(0,6)+"..."+g.slice(-4),l=g=>g?g===e.alice?"Alice (0xAlice...7E6F)":g===e.bob?"Bob (0xBob...E2F)":g.slice(0,10)+"..."+g.slice(-8):"",u=g=>new Date(g).toLocaleTimeString("zh-CN",{hour:"2-digit",minute:"2-digit",second:"2-digit"}),d=g=>{switch(g){case"Basic":return"📦";case"Premium":return"🏷️";case"TimeLocked":return"⏰";default:return"📦"}},w=g=>{n.value=g;const T={alice:"✅ 已切换到 Alice！👉 创建存款盒开始学习！",bob:"✅ 已切换到 Bob！👉 让 Alice 转移一个存款盒给你！"};return t.addLog(14,"切换角色",`切换到 ${g}`),{success:!0,message:T[g],hints:[],nextStep:""}},m=()=>{r.value++;const g=r.value,T=o.value,A=c(T),L={id:g,type:"Basic",owner:T,createdBy:n.value,secret:"",createdAt:Date.now(),unlockTime:null,metadata:null};return s.value.push(L),i.value.push({icon:"📦",name:"BoxCreated",details:`${A} 创建了 Basic 存款盒 #${g}`,timestamp:Date.now(),type:"create"}),t.addLog(14,"创建Basic存款盒",`Box #${g} by ${A}`,"createBasicBox"),{success:!0,box:L,message:`✅ 创建 Basic 存款盒 #${g} 成功！🧬 恭喜解锁：合约继承！🎭 恭喜解锁：抽象合约！${r.value>=2?"🏭 恭喜解锁：工厂模式！":""}👉 创建 Premium 或 TimeLocked 来学习 override！`,hints:r.value>=2?["inheritance","abstract_contract","factory_pattern"]:["inheritance","abstract_contract"],nextStep:r.value>=2?"🧬 BasicDepositBox 继承了 BaseDepositBox 的所有功能！🎭 抽象合约定义了通用接口！🏭 你体验了工厂模式！VaultManager 负责创建和管理所有存款盒！👉 创建 Premium 存款盒来学习 override 关键字！":"📦 BasicDepositBox 继承了 BaseDepositBox 的所有功能！🎭 抽象合约定义了通用接口！👉 创建 Premium 存款盒来学习 override 关键字！"}},S=()=>{r.value++;const g=r.value,T=o.value,A=c(T),L={id:g,type:"Premium",owner:T,createdBy:n.value,secret:"",createdAt:Date.now(),unlockTime:null,metadata:""};return s.value.push(L),i.value.push({icon:"🏷️",name:"BoxCreated",details:`${A} 创建了 Premium 存款盒 #${g}`,timestamp:Date.now(),type:"create"}),t.addLog(14,"创建Premium存款盒",`Box #${g} by ${A}`,"createPremiumBox"),{success:!0,box:L,message:`✅ 创建 Premium 存款盒 #${g} 成功！📝 恭喜解锁：override 关键字和 virtual 函数！🎭 恭喜解锁：抽象合约！${r.value>=2?"🏭 恭喜解锁：工厂模式！":""}👉 设置元数据来学习更多！`,hints:r.value>=2?["override_keyword","virtual_function","abstract_contract","factory_pattern"]:["override_keyword","virtual_function","abstract_contract"],nextStep:r.value>=2?"🏷️ PremiumDepositBox 使用 override 重写了 getBoxType()！🎭 抽象合约定义了通用接口！🏭 你体验了工厂模式！VaultManager 负责创建和管理所有存款盒！👉 设置元数据来学习 metadata_storage！":"🏷️ PremiumDepositBox 使用 override 重写了 getBoxType()！🎭 抽象合约定义了通用接口！👉 设置元数据来学习 metadata_storage！"}},h=g=>{r.value++;const T=r.value,A=o.value,L=c(A),K=Date.now()+g*1e3,ee={id:T,type:"TimeLocked",owner:A,createdBy:n.value,secret:"",createdAt:Date.now(),unlockTime:K,metadata:null};return s.value.push(ee),i.value.push({icon:"⏰",name:"BoxCreated",details:`${L} 创建了 TimeLocked 存款盒 #${T}，锁定 ${g} 秒`,timestamp:Date.now(),type:"create"}),t.addLog(14,"创建TimeLocked存款盒",`Box #${T} by ${L}, 锁定 ${g}秒`,"createTimeLockedBox"),{success:!0,box:ee,message:`✅ 创建 TimeLocked 存款盒 #${T} 成功！⏰ 恭喜解锁：时间锁定和抽象合约！${r.value>=2?"🏭 恭喜解锁：工厂模式！":""}👉 存入秘密并在锁定期间尝试取出！`,hints:r.value>=2?["abstract_contract","time_lock","factory_pattern"]:["abstract_contract","time_lock"],nextStep:r.value>=2?"⏰ TimeLockedDepositBox 使用修饰器组合保护 getSecret()！🏭 你体验了工厂模式！VaultManager 负责创建和管理所有存款盒！👉 存入秘密并在锁定期间尝试取出！":"⏰ TimeLockedDepositBox 使用修饰器组合保护 getSecret()！👉 存入秘密并在锁定期间尝试取出！"}},D=(g,T)=>{const A=s.value.find(K=>K.id===g);if(!A)return{success:!1,message:"❌ 存款盒不存在！",hints:[],nextStep:""};if(A.owner!==o.value)return t.addLog(14,"存入秘密失败",`无权操作 Box #${g}`),{success:!1,message:"❌ 只有所有者才能存入秘密！🔒 这展示了修饰器在权限控制中的作用！",hints:[],nextStep:"👉 切换到存款盒的所有者角色来尝试存入秘密！"};A.secret=T;const L=c(A.owner);return i.value.push({icon:"🔐",name:"SecretStored",details:`${L} 向 Box #${g} 存入了秘密`,timestamp:Date.now(),type:"store"}),t.addLog(14,"存入秘密",`Box #${g} by ${L}`,"storeSecret"),{success:!0,message:`✅ 秘密已存入 Box #${g}！👉 尝试取出秘密！`,hints:[],nextStep:"🔐 秘密已安全存储！👉 尝试取出秘密！"}},I=g=>{const T=s.value.find(L=>L.id===g);if(!T)return{success:!1,message:"❌ 存款盒不存在！",hints:[],nextStep:""};if(T.owner!==o.value)return t.addLog(14,"取出秘密失败",`无权操作 Box #${g}`),{success:!1,message:"❌ 只有所有者才能取出秘密！🔒 这展示了修饰器在权限控制中的作用！",hints:[],nextStep:"👉 切换到存款盒的所有者角色来尝试取出秘密！"};if(T.type==="TimeLocked"&&T.unlockTime&&Date.now()<T.unlockTime){const L=Math.ceil((T.unlockTime-Date.now())/1e3);return t.addLog(14,"取出秘密失败",`Box #${g} 仍锁定，剩余 ${L} 秒`),{success:!1,message:`❌ Box #${g} 仍处于锁定状态！剩余 ${L} 秒。🔗 修饰器组合阻止了操作！`,hints:["modifier_combination","super_keyword"],nextStep:"🔗 修饰器组合 timeUnlocked 阻止了操作！👉 等待解锁或创建其他类型的存款盒！"}}const A=c(T.owner);return t.addLog(14,"取出秘密",`Box #${g} by ${A}`),{success:!0,secret:T.secret,message:`✅ 成功取出 Box #${g} 的秘密！`,hints:[],nextStep:T.type==="TimeLocked"?"🔓 不错！你取出了秘密！只有所有者才能访问存储的秘密。TimeLocked 使用 super.getSecret() 调用父合约实现！👉 设置元数据或转移所有权来学习更多！":"🔓 不错！你取出了秘密！只有所有者才能访问存储的秘密。👉 转移所有权给 Bob 来学习所有权转移流程！"}},b=(g,T)=>{const A=s.value.find(K=>K.id===g);if(!A)return{success:!1,message:"❌ 存款盒不存在！",hints:[],nextStep:""};if(A.type!=="Premium")return{success:!1,message:"❌ 只有 Premium 存款盒支持元数据！",hints:[],nextStep:""};if(A.owner!==o.value)return t.addLog(14,"设置元数据失败",`无权操作 Box #${g}`),{success:!1,message:"❌ 只有所有者才能设置元数据！🔒 这展示了修饰器在权限控制中的作用！",hints:[],nextStep:"👉 切换到 Premium 存款盒的所有者角色来尝试设置元数据！"};A.metadata=T;const L=c(A.owner);return i.value.push({icon:"🏷️",name:"MetadataSet",details:`${L} 设置了 Box #${g} 的元数据`,timestamp:Date.now(),type:"metadata"}),t.addLog(14,"设置元数据",`Box #${g} by ${L}`,"setMetadata"),{success:!0,message:`✅ 元数据已设置到 Box #${g}！🏷️ 恭喜解锁：元数据存储！`,hints:["metadata_storage"],nextStep:"🏷️ Premium 版本通过继承扩展了功能！👉 创建第2个存款盒来体验工厂模式！"}},C=g=>{const T=s.value.find(A=>A.id===g);return!T||T.type!=="Premium"?{success:!1,metadata:""}:(t.addLog(14,"获取元数据",`Box #${g}`),{success:!0,metadata:T.metadata||""})},f=g=>{const T=s.value.find(L=>L.id===g);if(!T||T.type!=="TimeLocked")return{success:!1,unlockTime:0,remaining:0};const A=T.unlockTime?Math.max(0,Math.ceil((T.unlockTime-Date.now())/1e3)):0;return t.addLog(14,"查询解锁时间",`Box #${g}, 剩余 ${A} 秒`),{success:!0,unlockTime:T.unlockTime||0,remaining:A}},p=(g,T)=>{const A=s.value.find(M=>M.id===g);if(!A)return{success:!1,message:"❌ 存款盒不存在！",hints:[],nextStep:""};if(A.owner!==o.value)return t.addLog(14,"转移所有权失败",`无权操作 Box #${g}`),{success:!1,message:"❌ 只有所有者才能转移所有权！🔒 这展示了修饰器在权限控制中的作用！",hints:[],nextStep:"👉 切换到存款盒的所有者角色来尝试转移所有权！"};const L=A.owner,K=c(L),ee=c(T);return A.owner=T,i.value.push({icon:"🔑",name:"OwnershipTransferred",details:`Box #${g} 从 ${K} 转移到 ${ee}`,timestamp:Date.now(),type:"transfer"}),t.addLog(14,"转移所有权",`Box #${g} 从 ${K} 到 ${ee}`,"transferOwnership14"),{success:!0,message:`✅ Box #${g} 所有权已从 ${K} 转移到 ${ee}！👉 新所有者需要调用 completeOwnershipTransfer 来更新记录！`,hints:r.value>=2?["factory_pattern"]:[],nextStep:r.value>=2?"🏭 你体验了工厂模式！VaultManager 负责创建和管理所有存款盒！👉 切换到新所有者完成所有权转移！":"👉 切换到新所有者调用 completeOwnershipTransfer 来更新记录！"}},v=g=>{const T=s.value.find(L=>L.id===g);if(!T)return{success:!1,message:"❌ 存款盒不存在！",hints:[],nextStep:""};if(T.owner!==o.value)return t.addLog(14,"完成所有权转移失败",`不是新所有者 Box #${g}`),{success:!1,message:"❌ 你不是该存款盒的新所有者！",hints:[],nextStep:""};const A=c(T.owner);return t.addLog(14,"完成所有权转移",`Box #${g} 新所有者 ${A}`,"completeOwnershipTransfer"),{success:!0,message:`✅ 所有权转移完成！${A} 现在拥有 Box #${g}！`,hints:[],nextStep:"👉 查看完整代码来复习所有知识点！"}},k=g=>f(g).remaining||0,x=B(()=>({gasUsage:t.getDayGasUsage(14),ethCost:t.getDayEthCost(14),operationCount:t.getDayOperationCount(14)}));return{roles:e,currentRole:n,depositBoxes:s,myBoxes:a,eventLog:i,boxCounter:r,currentAddress:o,realtimeData:x,switchRole:w,getRoleName:c,formatAddress:l,formatTime:u,getBoxIcon:d,createBasicBox:m,createPremiumBox:S,createTimeLockedBox:h,storeSecret:D,getSecret:I,setMetadata:b,getMetadata:C,getUnlockTime:f,getRemainingLockTime:k,transferOwnership:p,completeOwnershipTransfer:v}}function Cp(){const t=Be(),e=F(0),n=F([]),r=F({"0xUser1234567890abcdef":0n,"0xAlice1234567890abcdef":0n,"0xBob1234567890abcdef":0n}),s=F("0xUser1234567890abcdef"),i=F([]),o=B(()=>r.value[s.value]||0n),a=B(()=>{const f=Date.now();return n.value.filter(p=>p.endTime>f&&!p.executed)}),c=B(()=>{const f=Date.now();return n.value.filter(p=>p.endTime<=f&&!p.executed)}),l=B(()=>n.value.filter(f=>f.executed)),u=f=>f?f===s.value?"你 (0xUser...cdef)":f==="0xAlice1234567890abcdef"?"Alice (0xAl...cdef)":f==="0xBob1234567890abcdef"?"Bob (0xBob...cdef)":f.slice(0,10)+"..."+f.slice(-8):"",d=f=>new Date(f).toLocaleTimeString("zh-CN",{hour:"2-digit",minute:"2-digit",second:"2-digit"}),w=f=>{const p=Date.now(),v=Math.max(0,f-p),k=Math.floor(v/1e3);return k<60?`${k}秒`:`${Math.floor(k/60)}分${k%60}秒`},m=f=>{const p=Date.now();return f.executed?{text:"已执行",class:"executed"}:f.endTime<=p?{text:"已结束",class:"ended"}:{text:"活跃",class:"active"}},S=(f,p)=>{if(!f||f.trim()==="")return{success:!1,error:"❌ 请输入提案名称！",hint:"👝 提案名称不能为空！"};if(!p||p<1)return{success:!1,error:"❌ 请输入有效的持续时间（至少1分钟）！",hint:"⏰ 持续时间必须大于0！"};e.value++;const v=e.value-1,k={id:v,name:f.trim(),voteCount:0,startTime:Date.now(),endTime:Date.now()+p*60*1e3,executed:!1,creator:s.value};n.value.push(k),i.value.unshift({icon:"📝",name:"ProposalCreated",details:`创建提案 "${k.name}" (ID: ${v})`,timestamp:Date.now(),type:"create"}),t.addLog(15,"创建提案",`Proposal #${v}: ${f}`,"createProposal15");const x=["bytes32_string"];e.value>=3&&x.push("storage_optimization");const g=e.value>=3?`✅ 创建提案 #${v} 成功！📝 恭喜解锁：bytes32 vs string！💾 恭喜解锁：存储优化！👉 现在尝试投票来学习位运算！`:`✅ 创建提案 #${v} 成功！📝 恭喜解锁：bytes32 vs string！👉 继续创建提案或尝试投票来学习位运算！`;return{success:!0,proposal:k,message:g,hints:x,nextStep:e.value>=3?"📝 bytes32 比 string 更省 Gas！💾 创建3个提案展示了 uint8 类型的存储优化！👉 现在尝试投票来学习位运算！":"📝 bytes32 比 string 更省 Gas！👉 继续创建提案或尝试投票来学习位运算！"}},h=f=>{const p=n.value[f];if(!p)return{success:!1,error:"❌ 提案不存在！",hint:"👝 请选择有效的提案！"};const v=Date.now();if(p.endTime<=v)return{success:!1,error:"❌ 提案已结束，无法投票！",hint:"⏰ 投票窗口已关闭！"};const k=1n<<BigInt(f),x=o.value;return(x&k)!==0n?{success:!1,error:"❌ 已经对此提案投过票了！",hint:"🎭 掩码检查防止重复投票！",hasVoted:!0}:(r.value[s.value]=x|k,p.voteCount++,i.value.unshift({icon:"🗳️",name:"Voted",details:`${u(s.value)} 对提案 #${f} 投票`,timestamp:Date.now(),type:"vote"}),t.addLog(15,"投票",`Proposal #${f}`,"vote15"),{success:!0,proposal:p,message:"✅ 投票成功！⚡ 恭喜解锁：位运算技巧！🗺️ 恭喜解锁：映射存储！⏰ 恭喜解锁：时间戳验证！👉 尝试重复投票来体验掩码检查！",hints:["bit_operation","mapping_storage","timestamp_block"],nextStep:"⚡ 位运算让1个uint256存储256个投票状态！🗺️ 映射高效存储选民数据！⏰ 使用block.timestamp进行时间验证！👉 尝试对同一提案再次投票来体验掩码检查！"})},D=f=>{const p=n.value[f];if(!p)return{success:!1,error:"❌ 提案不存在！",hint:"👝 请选择有效的提案！"};if(p.executed)return{success:!1,error:"❌ 提案已经执行过了！",hint:"✅ 该提案已执行！"};const v=Date.now();return p.endTime>v?{success:!1,error:"❌ 提案还在进行中，无法执行！",hint:"⏰ 请等待投票结束后再执行！"}:(p.executed=!0,i.value.unshift({icon:"✅",name:"ProposalExecuted",details:`执行提案 "${p.name}" (ID: ${f}, 得票: ${p.voteCount})`,timestamp:Date.now(),type:"execute"}),t.addLog(15,"执行提案",`Proposal #${f}`,"executeProposal15"),{success:!0,proposal:p,message:`✅ 执行提案 #${f} 成功！📋 恭喜解锁：事件日志！🎉 你已解锁所有知识点！`,hints:["event_logging"],nextStep:"📋 事件日志用于链下索引和前端监听！🎉 恭喜！你已掌握Day 15所有核心概念！"})},I=f=>{const p=1n<<BigInt(f),v=o.value,k=(v&p)!==0n;return{proposalId:f,mask:p.toString(2),voterData:v.toString(2),hasVoted:k,operation:k?"已投票 (AND检查)":"未投票 (OR设置)",gasSaving:"使用位运算，1个uint256可存储256个提案的投票状态，节省约40% Gas！"}},b=()=>({slots:[{slot:0,name:"proposalCount",type:"uint8",value:e.value,description:"提案总数（使用uint8节省存储）"},{slot:1,name:"proposals mapping",type:"mapping",value:`${n.value.length} 个提案`,description:"提案映射（每个提案使用紧凑数据类型）"},{slot:"X",name:"voterRegistry mapping",type:"mapping(uint256)",value:`${Object.keys(r.value).length} 个选民`,description:"选民投票位图（1个uint256存储256个投票状态）"},{slot:"Y",name:"proposalVoterCount",type:"mapping(uint32)",value:"按提案统计",description:"提案投票数（uint32足够大）"}]}),C=B(()=>({gasUsage:t.getDayGasUsage(15),ethCost:t.getDayEthCost(15),operationCount:t.getDayOperationCount(15)}));return{proposals:n,eventLog:i,currentAddress:s,proposalCounter:e,currentVoterData:o,activeProposals:a,endedProposals:c,executedProposals:l,createProposal:S,vote:h,executeProposal:D,getBitOperationDemo:I,getStorageVisualization:b,formatAddress:u,formatTime:d,formatRemainingTime:w,getProposalStatus:m,realtimeData:C}}const Sp="6.16.0";function Ep(t,e,n){const r=e.split("|").map(i=>i.trim());for(let i=0;i<r.length;i++)switch(e){case"any":return;case"bigint":case"boolean":case"number":case"string":if(typeof t===e)return}const s=new Error(`invalid value for type ${e}`);throw s.code="INVALID_ARGUMENT",s.argument=`value.${n}`,s.value=t,s}function _e(t,e,n){for(let r in e){let s=e[r];const i=n?n[r]:null;i&&Ep(s,i,r),Object.defineProperty(t,r,{enumerable:!0,value:s,writable:!1})}}function ar(t,e){if(t==null)return"null";if(e==null&&(e=new Set),typeof t=="object"){if(e.has(t))return"[Circular]";e.add(t)}if(Array.isArray(t))return"[ "+t.map(n=>ar(n,e)).join(", ")+" ]";if(t instanceof Uint8Array){const n="0123456789abcdef";let r="0x";for(let s=0;s<t.length;s++)r+=n[t[s]>>4],r+=n[t[s]&15];return r}if(typeof t=="object"&&typeof t.toJSON=="function")return ar(t.toJSON(),e);switch(typeof t){case"boolean":case"number":case"symbol":return t.toString();case"bigint":return BigInt(t).toString();case"string":return JSON.stringify(t);case"object":{const n=Object.keys(t);return n.sort(),"{ "+n.map(r=>`${ar(r,e)}: ${ar(t[r],e)}`).join(", ")+" }"}}return"[ COULD NOT SERIALIZE ]"}function Ia(t,e){return t&&t.code===e}function El(t,e,n){let r=t;{const i=[];if(n){if("message"in n||"code"in n||"name"in n)throw new Error(`value will overwrite populated values: ${ar(n)}`);for(const o in n){if(o==="shortMessage")continue;const a=n[o];i.push(o+"="+ar(a))}}i.push(`code=${e}`),i.push(`version=${Sp}`),i.length&&(t+=" ("+i.join(", ")+")")}let s;switch(e){case"INVALID_ARGUMENT":s=new TypeError(t);break;case"NUMERIC_FAULT":case"BUFFER_OVERRUN":s=new RangeError(t);break;default:s=new Error(t)}return _e(s,{code:e}),n&&Object.assign(s,n),s.shortMessage==null&&_e(s,{shortMessage:r}),s}function Ae(t,e,n,r){if(!t)throw El(e,n,r)}function z(t,e,n,r){Ae(t,e,"INVALID_ARGUMENT",{argument:n,value:r})}function kl(t,e,n){n==null&&(n=""),n&&(n=": "+n),Ae(t>=e,"missing argument"+n,"MISSING_ARGUMENT",{count:t,expectedCount:e}),Ae(t<=e,"too many arguments"+n,"UNEXPECTED_ARGUMENT",{count:t,expectedCount:e})}["NFD","NFC","NFKD","NFKC"].reduce((t,e)=>{try{if("test".normalize(e)!=="test")throw new Error("bad");if(e==="NFD"&&"é".normalize("NFD")!=="é")throw new Error("broken");t.push(e)}catch{}return t},[]);function li(t,e,n){if(n==null&&(n=""),t!==e){let r=n,s="new";n&&(r+=".",s+=" "+n),Ae(!1,`private constructor; use ${r}from* methods`,"UNSUPPORTED_OPERATION",{operation:s})}}function Al(t,e,n){if(t instanceof Uint8Array)return n?new Uint8Array(t):t;if(typeof t=="string"&&t.length%2===0&&t.match(/^0x[0-9a-f]*$/i)){const r=new Uint8Array((t.length-2)/2);let s=2;for(let i=0;i<r.length;i++)r[i]=parseInt(t.substring(s,s+2),16),s+=2;return r}z(!1,"invalid BytesLike value",e||"value",t)}function We(t,e){return Al(t,e,!1)}function je(t,e){return Al(t,e,!0)}function Fn(t,e){return!(typeof t!="string"||!t.match(/^0x[0-9A-Fa-f]*$/)||typeof e=="number"&&t.length!==2+2*e||e===!0&&t.length%2!==0)}const Oa="0123456789abcdef";function fe(t){const e=We(t);let n="0x";for(let r=0;r<e.length;r++){const s=e[r];n+=Oa[(s&240)>>4]+Oa[s&15]}return n}function un(t){return"0x"+t.map(e=>fe(e).substring(2)).join("")}function Kr(t){return Fn(t,!0)?(t.length-2)/2:We(t).length}function sr(t,e,n){const r=We(t);return n!=null&&n>r.length&&Ae(!1,"cannot slice beyond data bounds","BUFFER_OVERRUN",{buffer:r,length:r.length,offset:n}),fe(r.slice(e??0,n??r.length))}function Tl(t,e,n){const r=We(t);Ae(e>=r.length,"padding exceeds data length","BUFFER_OVERRUN",{buffer:new Uint8Array(r),length:e,offset:e+1});const s=new Uint8Array(e);return s.fill(0),n?s.set(r,e-r.length):s.set(r,0),fe(s)}function Dl(t,e){return Tl(t,e,!0)}function kp(t,e){return Tl(t,e,!1)}const ls=BigInt(0),xt=BigInt(1),cr=9007199254740991;function Ap(t,e){const n=ui(t,"value"),r=BigInt(Et(e,"width"));if(Ae(n>>r===ls,"overflow","NUMERIC_FAULT",{operation:"fromTwos",fault:"overflow",value:t}),n>>r-xt){const s=(xt<<r)-xt;return-((~n&s)+xt)}return n}function Tp(t,e){let n=qt(t,"value");const r=BigInt(Et(e,"width")),s=xt<<r-xt;if(n<ls){n=-n,Ae(n<=s,"too low","NUMERIC_FAULT",{operation:"toTwos",fault:"overflow",value:t});const i=(xt<<r)-xt;return(~n&i)+xt}else Ae(n<s,"too high","NUMERIC_FAULT",{operation:"toTwos",fault:"overflow",value:t});return n}function ys(t,e){const n=ui(t,"value"),r=BigInt(Et(e,"bits"));return n&(xt<<r)-xt}function qt(t,e){switch(typeof t){case"bigint":return t;case"number":return z(Number.isInteger(t),"underflow",e||"value",t),z(t>=-cr&&t<=cr,"overflow",e||"value",t),BigInt(t);case"string":try{if(t==="")throw new Error("empty string");return t[0]==="-"&&t[1]!=="-"?-BigInt(t.substring(1)):BigInt(t)}catch(n){z(!1,`invalid BigNumberish string: ${n.message}`,e||"value",t)}}z(!1,"invalid BigNumberish value",e||"value",t)}function ui(t,e){const n=qt(t,e);return Ae(n>=ls,"unsigned value cannot be negative","NUMERIC_FAULT",{fault:"overflow",operation:"getUint",value:t}),n}const Pa="0123456789abcdef";function Bl(t){if(t instanceof Uint8Array){let e="0x0";for(const n of t)e+=Pa[n>>4],e+=Pa[n&15];return BigInt(e)}return qt(t)}function Et(t,e){switch(typeof t){case"bigint":return z(t>=-cr&&t<=cr,"overflow",e||"value",t),Number(t);case"number":return z(Number.isInteger(t),"underflow",e||"value",t),z(t>=-cr&&t<=cr,"overflow",e||"value",t),t;case"string":try{if(t==="")throw new Error("empty string");return Et(BigInt(t),e)}catch(n){z(!1,`invalid numeric string: ${n.message}`,e||"value",t)}}z(!1,"invalid numeric value",e||"value",t)}function Dp(t){return Et(Bl(t))}function Fs(t,e){const n=ui(t,"value");let r=n.toString(16);if(e==null)r.length%2&&(r="0"+r);else{const s=Et(e,"width");if(s===0&&n===ls)return"0x";for(Ae(s*2>=r.length,`value exceeds width (${s} bytes)`,"NUMERIC_FAULT",{operation:"toBeHex",fault:"overflow",value:t});r.length<s*2;)r="0"+r}return"0x"+r}function Il(t,e){const n=ui(t,"value");if(n===ls)return new Uint8Array(0);let r=n.toString(16);r.length%2&&(r="0"+r);const s=new Uint8Array(r.length/2);for(let i=0;i<s.length;i++){const o=i*2;s[i]=parseInt(r.substring(o,o+2),16)}return s}function Bp(t,e,n,r,s){z(!1,`invalid codepoint at offset ${e}; ${t}`,"bytes",n)}function Ol(t,e,n,r,s){if(t==="BAD_PREFIX"||t==="UNEXPECTED_CONTINUE"){let i=0;for(let o=e+1;o<n.length&&n[o]>>6===2;o++)i++;return i}return t==="OVERRUN"?n.length-e-1:0}function Ip(t,e,n,r,s){return t==="OVERLONG"?(z(typeof s=="number","invalid bad code point for replacement","badCodepoint",s),r.push(s),0):(r.push(65533),Ol(t,e,n))}const Op=Object.freeze({error:Bp,ignore:Ol,replace:Ip});function Pp(t,e){e==null&&(e=Op.error);const n=We(t,"bytes"),r=[];let s=0;for(;s<n.length;){const i=n[s++];if(!(i>>7)){r.push(i);continue}let o=null,a=null;if((i&224)===192)o=1,a=127;else if((i&240)===224)o=2,a=2047;else if((i&248)===240)o=3,a=65535;else{(i&192)===128?s+=e("UNEXPECTED_CONTINUE",s-1,n,r):s+=e("BAD_PREFIX",s-1,n,r);continue}if(s-1+o>=n.length){s+=e("OVERRUN",s-1,n,r);continue}let c=i&(1<<8-o-1)-1;for(let l=0;l<o;l++){let u=n[s];if((u&192)!=128){s+=e("MISSING_CONTINUE",s,n,r),c=null;break}c=c<<6|u&63,s++}if(c!==null){if(c>1114111){s+=e("OUT_OF_RANGE",s-1-o,n,r,c);continue}if(c>=55296&&c<=57343){s+=e("UTF16_SURROGATE",s-1-o,n,r,c);continue}if(c<=a){s+=e("OVERLONG",s-1-o,n,r,c);continue}r.push(c)}}return r}function di(t,e){z(typeof t=="string","invalid string value","str",t);let n=[];for(let r=0;r<t.length;r++){const s=t.charCodeAt(r);if(s<128)n.push(s);else if(s<2048)n.push(s>>6|192),n.push(s&63|128);else if((s&64512)==55296){r++;const i=t.charCodeAt(r);z(r<t.length&&(i&64512)===56320,"invalid surrogate pair","str",t);const o=65536+((s&1023)<<10)+(i&1023);n.push(o>>18|240),n.push(o>>12&63|128),n.push(o>>6&63|128),n.push(o&63|128)}else n.push(s>>12|224),n.push(s>>6&63|128),n.push(s&63|128)}return new Uint8Array(n)}function $p(t){return t.map(e=>e<=65535?String.fromCharCode(e):(e-=65536,String.fromCharCode((e>>10&1023)+55296,(e&1023)+56320))).join("")}function Lp(t,e){return $p(Pp(t,e))}const Xe=32,ji=new Uint8Array(Xe),Rp=["then"],bs={},Pl=new WeakMap;function Mn(t){return Pl.get(t)}function $a(t,e){Pl.set(t,e)}function Pr(t,e){const n=new Error(`deferred error during ABI decoding triggered accessing ${t}`);throw n.error=e,n}function Xi(t,e,n){return t.indexOf(null)>=0?e.map((r,s)=>r instanceof Cr?Xi(Mn(r),r,n):r):t.reduce((r,s,i)=>{let o=e.getValue(s);return s in r||(n&&o instanceof Cr&&(o=Xi(Mn(o),o,n)),r[s]=o),r},{})}var pr;const lr=class lr extends Array{constructor(...n){const r=n[0];let s=n[1],i=(n[2]||[]).slice(),o=!0;r!==bs&&(s=n,i=[],o=!1);super(s.length);he(this,pr);s.forEach((l,u)=>{this[u]=l});const a=i.reduce((l,u)=>(typeof u=="string"&&l.set(u,(l.get(u)||0)+1),l),new Map);if($a(this,Object.freeze(s.map((l,u)=>{const d=i[u];return d!=null&&a.get(d)===1?d:null}))),oe(this,pr,[]),N(this,pr)==null&&N(this,pr),!o)return;Object.freeze(this);const c=new Proxy(this,{get:(l,u,d)=>{if(typeof u=="string"){if(u.match(/^[0-9]+$/)){const m=Et(u,"%index");if(m<0||m>=this.length)throw new RangeError("out of result range");const S=l[m];return S instanceof Error&&Pr(`index ${m}`,S),S}if(Rp.indexOf(u)>=0)return Reflect.get(l,u,d);const w=l[u];if(w instanceof Function)return function(...m){return w.apply(this===d?l:this,m)};if(!(u in l))return l.getValue.apply(this===d?l:this,[u])}return Reflect.get(l,u,d)}});return $a(c,Mn(this)),c}toArray(n){const r=[];return this.forEach((s,i)=>{s instanceof Error&&Pr(`index ${i}`,s),n&&s instanceof lr&&(s=s.toArray(n)),r.push(s)}),r}toObject(n){const r=Mn(this);return r.reduce((s,i,o)=>(Ae(i!=null,`value at index ${o} unnamed`,"UNSUPPORTED_OPERATION",{operation:"toObject()"}),Xi(r,this,n)),{})}slice(n,r){n==null&&(n=0),n<0&&(n+=this.length,n<0&&(n=0)),r==null&&(r=this.length),r<0&&(r+=this.length,r<0&&(r=0)),r>this.length&&(r=this.length);const s=Mn(this),i=[],o=[];for(let a=n;a<r;a++)i.push(this[a]),o.push(s[a]);return new lr(bs,i,o)}filter(n,r){const s=Mn(this),i=[],o=[];for(let a=0;a<this.length;a++){const c=this[a];c instanceof Error&&Pr(`index ${a}`,c),n.call(r,c,a,this)&&(i.push(c),o.push(s[a]))}return new lr(bs,i,o)}map(n,r){const s=[];for(let i=0;i<this.length;i++){const o=this[i];o instanceof Error&&Pr(`index ${i}`,o),s.push(n.call(r,o,i,this))}return s}getValue(n){const r=Mn(this).indexOf(n);if(r===-1)return;const s=this[r];return s instanceof Error&&Pr(`property ${JSON.stringify(n)}`,s.error),s}static fromItems(n,r){return new lr(bs,n,r)}};pr=new WeakMap;let Cr=lr;function La(t){let e=Il(t);return Ae(e.length<=Xe,"value out-of-bounds","BUFFER_OVERRUN",{buffer:e,length:Xe,offset:e.length}),e.length!==Xe&&(e=je(un([ji.slice(e.length%Xe),e]))),e}class yn{constructor(e,n,r,s){Z(this,"name");Z(this,"type");Z(this,"localName");Z(this,"dynamic");_e(this,{name:e,type:n,localName:r,dynamic:s},{name:"string",type:"string",localName:"string",dynamic:"boolean"})}_throwError(e,n){z(!1,e,this.localName,n)}}var tn,Wn,gr,Ds;class Ji{constructor(){he(this,gr);he(this,tn);he(this,Wn);oe(this,tn,[]),oe(this,Wn,0)}get data(){return un(N(this,tn))}get length(){return N(this,Wn)}appendWriter(e){return xe(this,gr,Ds).call(this,je(e.data))}writeBytes(e){let n=je(e);const r=n.length%Xe;return r&&(n=je(un([n,ji.slice(r)]))),xe(this,gr,Ds).call(this,n)}writeValue(e){return xe(this,gr,Ds).call(this,La(e))}writeUpdatableValue(){const e=N(this,tn).length;return N(this,tn).push(ji),oe(this,Wn,N(this,Wn)+Xe),n=>{N(this,tn)[e]=La(n)}}}tn=new WeakMap,Wn=new WeakMap,gr=new WeakSet,Ds=function(e){return N(this,tn).push(e),oe(this,Wn,N(this,Wn)+e.length),e.length};var Qe,at,zn,Gn,kn,tr,Zi,$l;const Mo=class Mo{constructor(e,n,r){he(this,tr);Z(this,"allowLoose");he(this,Qe);he(this,at);he(this,zn);he(this,Gn);he(this,kn);_e(this,{allowLoose:!!n}),oe(this,Qe,je(e)),oe(this,zn,0),oe(this,Gn,null),oe(this,kn,r??1024),oe(this,at,0)}get data(){return fe(N(this,Qe))}get dataLength(){return N(this,Qe).length}get consumed(){return N(this,at)}get bytes(){return new Uint8Array(N(this,Qe))}subReader(e){const n=new Mo(N(this,Qe).slice(N(this,at)+e),this.allowLoose,N(this,kn));return oe(n,Gn,this),n}readBytes(e,n){let r=xe(this,tr,$l).call(this,0,e,!!n);return xe(this,tr,Zi).call(this,e),oe(this,at,N(this,at)+r.length),r.slice(0,e)}readValue(){return Bl(this.readBytes(Xe))}readIndex(){return Dp(this.readBytes(Xe))}};Qe=new WeakMap,at=new WeakMap,zn=new WeakMap,Gn=new WeakMap,kn=new WeakMap,tr=new WeakSet,Zi=function(e){var n;if(N(this,Gn))return xe(n=N(this,Gn),tr,Zi).call(n,e);oe(this,zn,N(this,zn)+e),Ae(N(this,kn)<1||N(this,zn)<=N(this,kn)*this.dataLength,`compressed ABI data exceeds inflation ratio of ${N(this,kn)} ( see: https://github.com/ethers-io/ethers.js/issues/4537 )`,"BUFFER_OVERRUN",{buffer:je(N(this,Qe)),offset:N(this,at),length:e,info:{bytesRead:N(this,zn),dataLength:this.dataLength}})},$l=function(e,n,r){let s=Math.ceil(n/Xe)*Xe;return N(this,at)+s>N(this,Qe).length&&(this.allowLoose&&r&&N(this,at)+n<=N(this,Qe).length?s=n:Ae(!1,"data out-of-bounds","BUFFER_OVERRUN",{buffer:je(N(this,Qe)),length:N(this,Qe).length,offset:N(this,at)+s})),N(this,Qe).slice(N(this,at),N(this,at)+s)};let Yi=Mo;function qs(t){if(!Number.isSafeInteger(t)||t<0)throw new Error(`Wrong positive integer: ${t}`)}function Bo(t,...e){if(!(t instanceof Uint8Array))throw new Error("Expected Uint8Array");if(e.length>0&&!e.includes(t.length))throw new Error(`Expected Uint8Array of length ${e}, not of length=${t.length}`)}function Np(t){if(typeof t!="function"||typeof t.create!="function")throw new Error("Hash should be wrapped by utils.wrapConstructor");qs(t.outputLen),qs(t.blockLen)}function Sr(t,e=!0){if(t.destroyed)throw new Error("Hash instance has been destroyed");if(e&&t.finished)throw new Error("Hash#digest() has already been called")}function Ll(t,e){Bo(t);const n=e.outputLen;if(t.length<n)throw new Error(`digestInto() expects output buffer of length at least ${n}`)}const Ti=typeof globalThis=="object"&&"crypto"in globalThis?globalThis.crypto:void 0;/*! noble-hashes - MIT License (c) 2022 Paul Miller (paulmillr.com) */const Rl=t=>t instanceof Uint8Array,Mp=t=>new Uint32Array(t.buffer,t.byteOffset,Math.floor(t.byteLength/4)),Di=t=>new DataView(t.buffer,t.byteOffset,t.byteLength),$t=(t,e)=>t<<32-e|t>>>e,Up=new Uint8Array(new Uint32Array([287454020]).buffer)[0]===68;if(!Up)throw new Error("Non little-endian hardware is not supported");function Hp(t){if(typeof t!="string")throw new Error(`utf8ToBytes expected string, got ${typeof t}`);return new Uint8Array(new TextEncoder().encode(t))}function fi(t){if(typeof t=="string"&&(t=Hp(t)),!Rl(t))throw new Error(`expected Uint8Array, got ${typeof t}`);return t}function Vp(...t){const e=new Uint8Array(t.reduce((r,s)=>r+s.length,0));let n=0;return t.forEach(r=>{if(!Rl(r))throw new Error("Uint8Array expected");e.set(r,n),n+=r.length}),e}class Io{clone(){return this._cloneInto()}}function Nl(t){const e=r=>t().update(fi(r)).digest(),n=t();return e.outputLen=n.outputLen,e.blockLen=n.blockLen,e.create=()=>t(),e}function Fp(t=32){if(Ti&&typeof Ti.getRandomValues=="function")return Ti.getRandomValues(new Uint8Array(t));throw new Error("crypto.getRandomValues must be defined")}class Ml extends Io{constructor(e,n){super(),this.finished=!1,this.destroyed=!1,Np(e);const r=fi(n);if(this.iHash=e.create(),typeof this.iHash.update!="function")throw new Error("Expected instance of class which extends utils.Hash");this.blockLen=this.iHash.blockLen,this.outputLen=this.iHash.outputLen;const s=this.blockLen,i=new Uint8Array(s);i.set(r.length>s?e.create().update(r).digest():r);for(let o=0;o<i.length;o++)i[o]^=54;this.iHash.update(i),this.oHash=e.create();for(let o=0;o<i.length;o++)i[o]^=106;this.oHash.update(i),i.fill(0)}update(e){return Sr(this),this.iHash.update(e),this}digestInto(e){Sr(this),Bo(e,this.outputLen),this.finished=!0,this.iHash.digestInto(e),this.oHash.update(e),this.oHash.digestInto(e),this.destroy()}digest(){const e=new Uint8Array(this.oHash.outputLen);return this.digestInto(e),e}_cloneInto(e){e||(e=Object.create(Object.getPrototypeOf(this),{}));const{oHash:n,iHash:r,finished:s,destroyed:i,blockLen:o,outputLen:a}=this;return e=e,e.finished=s,e.destroyed=i,e.blockLen=o,e.outputLen=a,e.oHash=n._cloneInto(e.oHash),e.iHash=r._cloneInto(e.iHash),e}destroy(){this.destroyed=!0,this.oHash.destroy(),this.iHash.destroy()}}const Ul=(t,e,n)=>new Ml(t,e).update(n).digest();Ul.create=(t,e)=>new Ml(t,e);function qp(t,e,n,r){if(typeof t.setBigUint64=="function")return t.setBigUint64(e,n,r);const s=BigInt(32),i=BigInt(4294967295),o=Number(n>>s&i),a=Number(n&i),c=r?4:0,l=r?0:4;t.setUint32(e+c,o,r),t.setUint32(e+l,a,r)}class Wp extends Io{constructor(e,n,r,s){super(),this.blockLen=e,this.outputLen=n,this.padOffset=r,this.isLE=s,this.finished=!1,this.length=0,this.pos=0,this.destroyed=!1,this.buffer=new Uint8Array(e),this.view=Di(this.buffer)}update(e){Sr(this);const{view:n,buffer:r,blockLen:s}=this;e=fi(e);const i=e.length;for(let o=0;o<i;){const a=Math.min(s-this.pos,i-o);if(a===s){const c=Di(e);for(;s<=i-o;o+=s)this.process(c,o);continue}r.set(e.subarray(o,o+a),this.pos),this.pos+=a,o+=a,this.pos===s&&(this.process(n,0),this.pos=0)}return this.length+=e.length,this.roundClean(),this}digestInto(e){Sr(this),Ll(e,this),this.finished=!0;const{buffer:n,view:r,blockLen:s,isLE:i}=this;let{pos:o}=this;n[o++]=128,this.buffer.subarray(o).fill(0),this.padOffset>s-o&&(this.process(r,0),o=0);for(let d=o;d<s;d++)n[d]=0;qp(r,s-8,BigInt(this.length*8),i),this.process(r,0);const a=Di(e),c=this.outputLen;if(c%4)throw new Error("_sha2: outputLen should be aligned to 32bit");const l=c/4,u=this.get();if(l>u.length)throw new Error("_sha2: outputLen bigger than state");for(let d=0;d<l;d++)a.setUint32(4*d,u[d],i)}digest(){const{buffer:e,outputLen:n}=this;this.digestInto(e);const r=e.slice(0,n);return this.destroy(),r}_cloneInto(e){e||(e=new this.constructor),e.set(...this.get());const{blockLen:n,buffer:r,length:s,finished:i,destroyed:o,pos:a}=this;return e.length=s,e.pos=a,e.finished=i,e.destroyed=o,s%n&&e.buffer.set(r),e}}const zp=(t,e,n)=>t&e^~t&n,Gp=(t,e,n)=>t&e^t&n^e&n,Kp=new Uint32Array([1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298]),wn=new Uint32Array([1779033703,3144134277,1013904242,2773480762,1359893119,2600822924,528734635,1541459225]),vn=new Uint32Array(64);class jp extends Wp{constructor(){super(64,32,8,!1),this.A=wn[0]|0,this.B=wn[1]|0,this.C=wn[2]|0,this.D=wn[3]|0,this.E=wn[4]|0,this.F=wn[5]|0,this.G=wn[6]|0,this.H=wn[7]|0}get(){const{A:e,B:n,C:r,D:s,E:i,F:o,G:a,H:c}=this;return[e,n,r,s,i,o,a,c]}set(e,n,r,s,i,o,a,c){this.A=e|0,this.B=n|0,this.C=r|0,this.D=s|0,this.E=i|0,this.F=o|0,this.G=a|0,this.H=c|0}process(e,n){for(let d=0;d<16;d++,n+=4)vn[d]=e.getUint32(n,!1);for(let d=16;d<64;d++){const w=vn[d-15],m=vn[d-2],S=$t(w,7)^$t(w,18)^w>>>3,h=$t(m,17)^$t(m,19)^m>>>10;vn[d]=h+vn[d-7]+S+vn[d-16]|0}let{A:r,B:s,C:i,D:o,E:a,F:c,G:l,H:u}=this;for(let d=0;d<64;d++){const w=$t(a,6)^$t(a,11)^$t(a,25),m=u+w+zp(a,c,l)+Kp[d]+vn[d]|0,h=($t(r,2)^$t(r,13)^$t(r,22))+Gp(r,s,i)|0;u=l,l=c,c=a,a=o+m|0,o=i,i=s,s=r,r=m+h|0}r=r+this.A|0,s=s+this.B|0,i=i+this.C|0,o=o+this.D|0,a=a+this.E|0,c=c+this.F|0,l=l+this.G|0,u=u+this.H|0,this.set(r,s,i,o,a,c,l,u)}roundClean(){vn.fill(0)}destroy(){this.set(0,0,0,0,0,0,0,0),this.buffer.fill(0)}}const Xp=Nl(()=>new jp),ws=BigInt(2**32-1),Ra=BigInt(32);function Jp(t,e=!1){return e?{h:Number(t&ws),l:Number(t>>Ra&ws)}:{h:Number(t>>Ra&ws)|0,l:Number(t&ws)|0}}function Yp(t,e=!1){let n=new Uint32Array(t.length),r=new Uint32Array(t.length);for(let s=0;s<t.length;s++){const{h:i,l:o}=Jp(t[s],e);[n[s],r[s]]=[i,o]}return[n,r]}const Zp=(t,e,n)=>t<<n|e>>>32-n,Qp=(t,e,n)=>e<<n|t>>>32-n,eg=(t,e,n)=>e<<n-32|t>>>64-n,tg=(t,e,n)=>t<<n-32|e>>>64-n,[Hl,Vl,Fl]=[[],[],[]],ng=BigInt(0),$r=BigInt(1),rg=BigInt(2),sg=BigInt(7),ig=BigInt(256),og=BigInt(113);for(let t=0,e=$r,n=1,r=0;t<24;t++){[n,r]=[r,(2*n+3*r)%5],Hl.push(2*(5*r+n)),Vl.push((t+1)*(t+2)/2%64);let s=ng;for(let i=0;i<7;i++)e=(e<<$r^(e>>sg)*og)%ig,e&rg&&(s^=$r<<($r<<BigInt(i))-$r);Fl.push(s)}const[ag,cg]=Yp(Fl,!0),Na=(t,e,n)=>n>32?eg(t,e,n):Zp(t,e,n),Ma=(t,e,n)=>n>32?tg(t,e,n):Qp(t,e,n);function lg(t,e=24){const n=new Uint32Array(10);for(let r=24-e;r<24;r++){for(let o=0;o<10;o++)n[o]=t[o]^t[o+10]^t[o+20]^t[o+30]^t[o+40];for(let o=0;o<10;o+=2){const a=(o+8)%10,c=(o+2)%10,l=n[c],u=n[c+1],d=Na(l,u,1)^n[a],w=Ma(l,u,1)^n[a+1];for(let m=0;m<50;m+=10)t[o+m]^=d,t[o+m+1]^=w}let s=t[2],i=t[3];for(let o=0;o<24;o++){const a=Vl[o],c=Na(s,i,a),l=Ma(s,i,a),u=Hl[o];s=t[u],i=t[u+1],t[u]=c,t[u+1]=l}for(let o=0;o<50;o+=10){for(let a=0;a<10;a++)n[a]=t[o+a];for(let a=0;a<10;a++)t[o+a]^=~n[(a+2)%10]&n[(a+4)%10]}t[0]^=ag[r],t[1]^=cg[r]}n.fill(0)}class Oo extends Io{constructor(e,n,r,s=!1,i=24){if(super(),this.blockLen=e,this.suffix=n,this.outputLen=r,this.enableXOF=s,this.rounds=i,this.pos=0,this.posOut=0,this.finished=!1,this.destroyed=!1,qs(r),0>=this.blockLen||this.blockLen>=200)throw new Error("Sha3 supports only keccak-f1600 function");this.state=new Uint8Array(200),this.state32=Mp(this.state)}keccak(){lg(this.state32,this.rounds),this.posOut=0,this.pos=0}update(e){Sr(this);const{blockLen:n,state:r}=this;e=fi(e);const s=e.length;for(let i=0;i<s;){const o=Math.min(n-this.pos,s-i);for(let a=0;a<o;a++)r[this.pos++]^=e[i++];this.pos===n&&this.keccak()}return this}finish(){if(this.finished)return;this.finished=!0;const{state:e,suffix:n,pos:r,blockLen:s}=this;e[r]^=n,n&128&&r===s-1&&this.keccak(),e[s-1]^=128,this.keccak()}writeInto(e){Sr(this,!1),Bo(e),this.finish();const n=this.state,{blockLen:r}=this;for(let s=0,i=e.length;s<i;){this.posOut>=r&&this.keccak();const o=Math.min(r-this.posOut,i-s);e.set(n.subarray(this.posOut,this.posOut+o),s),this.posOut+=o,s+=o}return e}xofInto(e){if(!this.enableXOF)throw new Error("XOF is not possible for this instance");return this.writeInto(e)}xof(e){return qs(e),this.xofInto(new Uint8Array(e))}digestInto(e){if(Ll(e,this),this.finished)throw new Error("digest() was already called");return this.writeInto(e),this.destroy(),e}digest(){return this.digestInto(new Uint8Array(this.outputLen))}destroy(){this.destroyed=!0,this.state.fill(0)}_cloneInto(e){const{blockLen:n,suffix:r,outputLen:s,rounds:i,enableXOF:o}=this;return e||(e=new Oo(n,r,s,o,i)),e.state32.set(this.state32),e.pos=this.pos,e.posOut=this.posOut,e.finished=this.finished,e.rounds=i,e.suffix=r,e.outputLen=s,e.enableXOF=o,e.destroyed=this.destroyed,e}}const ug=(t,e,n)=>Nl(()=>new Oo(e,t,n)),dg=ug(1,136,256/8);let ql=!1;const Wl=function(t){return dg(t)};let zl=Wl;function jt(t){const e=We(t,"data");return fe(zl(e))}jt._=Wl;jt.lock=function(){ql=!0};jt.register=function(t){if(ql)throw new TypeError("keccak256 is locked");zl=t};Object.freeze(jt);/*! noble-curves - MIT License (c) 2022 Paul Miller (paulmillr.com) */BigInt(0);const fg=BigInt(1),pg=BigInt(2),pi=t=>t instanceof Uint8Array,gg=Array.from({length:256},(t,e)=>e.toString(16).padStart(2,"0"));function Er(t){if(!pi(t))throw new Error("Uint8Array expected");let e="";for(let n=0;n<t.length;n++)e+=gg[t[n]];return e}function Po(t){if(typeof t!="string")throw new Error("hex string expected, got "+typeof t);return BigInt(t===""?"0":`0x${t}`)}function es(t){if(typeof t!="string")throw new Error("hex string expected, got "+typeof t);const e=t.length;if(e%2)throw new Error("padded hex string expected, got unpadded hex of length "+e);const n=new Uint8Array(e/2);for(let r=0;r<n.length;r++){const s=r*2,i=t.slice(s,s+2),o=Number.parseInt(i,16);if(Number.isNaN(o)||o<0)throw new Error("Invalid byte sequence");n[r]=o}return n}function Jn(t){return Po(Er(t))}function $o(t){if(!pi(t))throw new Error("Uint8Array expected");return Po(Er(Uint8Array.from(t).reverse()))}function kr(t,e){return es(t.toString(16).padStart(e*2,"0"))}function Lo(t,e){return kr(t,e).reverse()}function vt(t,e,n){let r;if(typeof e=="string")try{r=es(e)}catch(i){throw new Error(`${t} must be valid hex string, got "${e}". Cause: ${i}`)}else if(pi(e))r=Uint8Array.from(e);else throw new Error(`${t} must be hex string or Uint8Array`);const s=r.length;if(typeof n=="number"&&s!==n)throw new Error(`${t} expected ${n} bytes, got ${s}`);return r}function ts(...t){const e=new Uint8Array(t.reduce((r,s)=>r+s.length,0));let n=0;return t.forEach(r=>{if(!pi(r))throw new Error("Uint8Array expected");e.set(r,n),n+=r.length}),e}const Ro=t=>(pg<<BigInt(t-1))-fg,Bi=t=>new Uint8Array(t),Ua=t=>Uint8Array.from(t);function Gl(t,e,n){if(typeof t!="number"||t<2)throw new Error("hashLen must be a number");if(typeof e!="number"||e<2)throw new Error("qByteLen must be a number");if(typeof n!="function")throw new Error("hmacFn must be a function");let r=Bi(t),s=Bi(t),i=0;const o=()=>{r.fill(1),s.fill(0),i=0},a=(...d)=>n(s,r,...d),c=(d=Bi())=>{s=a(Ua([0]),d),r=a(),d.length!==0&&(s=a(Ua([1]),d),r=a())},l=()=>{if(i++>=1e3)throw new Error("drbg: tried 1000 values");let d=0;const w=[];for(;d<e;){r=a();const m=r.slice();w.push(m),d+=r.length}return ts(...w)};return(d,w)=>{o(),c(d);let m;for(;!(m=w(l()));)c();return o(),m}}const mg={bigint:t=>typeof t=="bigint",function:t=>typeof t=="function",boolean:t=>typeof t=="boolean",string:t=>typeof t=="string",stringOrUint8Array:t=>typeof t=="string"||t instanceof Uint8Array,isSafeInteger:t=>Number.isSafeInteger(t),array:t=>Array.isArray(t),field:(t,e)=>e.Fp.isValid(t),hash:t=>typeof t=="function"&&Number.isSafeInteger(t.outputLen)};function us(t,e,n={}){const r=(s,i,o)=>{const a=mg[i];if(typeof a!="function")throw new Error(`Invalid validator "${i}", expected function`);const c=t[s];if(!(o&&c===void 0)&&!a(c,t))throw new Error(`Invalid param ${String(s)}=${c} (${typeof c}), expected ${i}`)};for(const[s,i]of Object.entries(e))r(s,i,!1);for(const[s,i]of Object.entries(n))r(s,i,!0);return t}const hg=Object.freeze(Object.defineProperty({__proto__:null,bitMask:Ro,bytesToHex:Er,bytesToNumberBE:Jn,bytesToNumberLE:$o,concatBytes:ts,createHmacDrbg:Gl,ensureBytes:vt,hexToBytes:es,hexToNumber:Po,numberToBytesBE:kr,numberToBytesLE:Lo,validateObject:us},Symbol.toStringTag,{value:"Module"}));/*! noble-curves - MIT License (c) 2022 Paul Miller (paulmillr.com) */const Pe=BigInt(0),De=BigInt(1),Un=BigInt(2),yg=BigInt(3),Qi=BigInt(4),Ha=BigInt(5),Va=BigInt(8);BigInt(9);BigInt(16);function et(t,e){const n=t%e;return n>=Pe?n:e+n}function bg(t,e,n){if(n<=Pe||e<Pe)throw new Error("Expected power/modulo > 0");if(n===De)return Pe;let r=De;for(;e>Pe;)e&De&&(r=r*t%n),t=t*t%n,e>>=De;return r}function gt(t,e,n){let r=t;for(;e-- >Pe;)r*=r,r%=n;return r}function eo(t,e){if(t===Pe||e<=Pe)throw new Error(`invert: expected positive integers, got n=${t} mod=${e}`);let n=et(t,e),r=e,s=Pe,i=De;for(;n!==Pe;){const a=r/n,c=r%n,l=s-i*a;r=n,n=c,s=i,i=l}if(r!==De)throw new Error("invert: does not exist");return et(s,e)}function wg(t){const e=(t-De)/Un;let n,r,s;for(n=t-De,r=0;n%Un===Pe;n/=Un,r++);for(s=Un;s<t&&bg(s,e,t)!==t-De;s++);if(r===1){const o=(t+De)/Qi;return function(c,l){const u=c.pow(l,o);if(!c.eql(c.sqr(u),l))throw new Error("Cannot find square root");return u}}const i=(n+De)/Un;return function(a,c){if(a.pow(c,e)===a.neg(a.ONE))throw new Error("Cannot find square root");let l=r,u=a.pow(a.mul(a.ONE,s),n),d=a.pow(c,i),w=a.pow(c,n);for(;!a.eql(w,a.ONE);){if(a.eql(w,a.ZERO))return a.ZERO;let m=1;for(let h=a.sqr(w);m<l&&!a.eql(h,a.ONE);m++)h=a.sqr(h);const S=a.pow(u,De<<BigInt(l-m-1));u=a.sqr(S),d=a.mul(d,S),w=a.mul(w,u),l=m}return d}}function vg(t){if(t%Qi===yg){const e=(t+De)/Qi;return function(r,s){const i=r.pow(s,e);if(!r.eql(r.sqr(i),s))throw new Error("Cannot find square root");return i}}if(t%Va===Ha){const e=(t-Ha)/Va;return function(r,s){const i=r.mul(s,Un),o=r.pow(i,e),a=r.mul(s,o),c=r.mul(r.mul(a,Un),o),l=r.mul(a,r.sub(c,r.ONE));if(!r.eql(r.sqr(l),s))throw new Error("Cannot find square root");return l}}return wg(t)}const _g=["create","isValid","is0","neg","inv","sqrt","sqr","eql","add","sub","mul","pow","div","addN","subN","mulN","sqrN"];function xg(t){const e={ORDER:"bigint",MASK:"bigint",BYTES:"isSafeInteger",BITS:"isSafeInteger"},n=_g.reduce((r,s)=>(r[s]="function",r),e);return us(t,n)}function Cg(t,e,n){if(n<Pe)throw new Error("Expected power > 0");if(n===Pe)return t.ONE;if(n===De)return e;let r=t.ONE,s=e;for(;n>Pe;)n&De&&(r=t.mul(r,s)),s=t.sqr(s),n>>=De;return r}function Sg(t,e){const n=new Array(e.length),r=e.reduce((i,o,a)=>t.is0(o)?i:(n[a]=i,t.mul(i,o)),t.ONE),s=t.inv(r);return e.reduceRight((i,o,a)=>t.is0(o)?i:(n[a]=t.mul(i,n[a]),t.mul(i,o)),s),n}function Kl(t,e){const n=e!==void 0?e:t.toString(2).length,r=Math.ceil(n/8);return{nBitLength:n,nByteLength:r}}function Eg(t,e,n=!1,r={}){if(t<=Pe)throw new Error(`Expected Field ORDER > 0, got ${t}`);const{nBitLength:s,nByteLength:i}=Kl(t,e);if(i>2048)throw new Error("Field lengths over 2048 bytes are not supported");const o=vg(t),a=Object.freeze({ORDER:t,BITS:s,BYTES:i,MASK:Ro(s),ZERO:Pe,ONE:De,create:c=>et(c,t),isValid:c=>{if(typeof c!="bigint")throw new Error(`Invalid field element: expected bigint, got ${typeof c}`);return Pe<=c&&c<t},is0:c=>c===Pe,isOdd:c=>(c&De)===De,neg:c=>et(-c,t),eql:(c,l)=>c===l,sqr:c=>et(c*c,t),add:(c,l)=>et(c+l,t),sub:(c,l)=>et(c-l,t),mul:(c,l)=>et(c*l,t),pow:(c,l)=>Cg(a,c,l),div:(c,l)=>et(c*eo(l,t),t),sqrN:c=>c*c,addN:(c,l)=>c+l,subN:(c,l)=>c-l,mulN:(c,l)=>c*l,inv:c=>eo(c,t),sqrt:r.sqrt||(c=>o(a,c)),invertBatch:c=>Sg(a,c),cmov:(c,l,u)=>u?l:c,toBytes:c=>n?Lo(c,i):kr(c,i),fromBytes:c=>{if(c.length!==i)throw new Error(`Fp.fromBytes: expected ${i}, got ${c.length}`);return n?$o(c):Jn(c)}});return Object.freeze(a)}function jl(t){if(typeof t!="bigint")throw new Error("field order must be bigint");const e=t.toString(2).length;return Math.ceil(e/8)}function Xl(t){const e=jl(t);return e+Math.ceil(e/2)}function kg(t,e,n=!1){const r=t.length,s=jl(e),i=Xl(e);if(r<16||r<i||r>1024)throw new Error(`expected ${i}-1024 bytes of input, got ${r}`);const o=n?Jn(t):$o(t),a=et(o,e-De)+De;return n?Lo(a,s):kr(a,s)}/*! noble-curves - MIT License (c) 2022 Paul Miller (paulmillr.com) */const Ag=BigInt(0),Ii=BigInt(1);function Tg(t,e){const n=(s,i)=>{const o=i.negate();return s?o:i},r=s=>{const i=Math.ceil(e/s)+1,o=2**(s-1);return{windows:i,windowSize:o}};return{constTimeNegate:n,unsafeLadder(s,i){let o=t.ZERO,a=s;for(;i>Ag;)i&Ii&&(o=o.add(a)),a=a.double(),i>>=Ii;return o},precomputeWindow(s,i){const{windows:o,windowSize:a}=r(i),c=[];let l=s,u=l;for(let d=0;d<o;d++){u=l,c.push(u);for(let w=1;w<a;w++)u=u.add(l),c.push(u);l=u.double()}return c},wNAF(s,i,o){const{windows:a,windowSize:c}=r(s);let l=t.ZERO,u=t.BASE;const d=BigInt(2**s-1),w=2**s,m=BigInt(s);for(let S=0;S<a;S++){const h=S*c;let D=Number(o&d);o>>=m,D>c&&(D-=w,o+=Ii);const I=h,b=h+Math.abs(D)-1,C=S%2!==0,f=D<0;D===0?u=u.add(n(C,i[I])):l=l.add(n(f,i[b]))}return{p:l,f:u}},wNAFCached(s,i,o,a){const c=s._WINDOW_SIZE||1;let l=i.get(s);return l||(l=this.precomputeWindow(s,c),c!==1&&i.set(s,a(l))),this.wNAF(c,l,o)}}}function Jl(t){return xg(t.Fp),us(t,{n:"bigint",h:"bigint",Gx:"field",Gy:"field"},{nBitLength:"isSafeInteger",nByteLength:"isSafeInteger"}),Object.freeze({...Kl(t.n,t.nBitLength),...t,p:t.Fp.ORDER})}/*! noble-curves - MIT License (c) 2022 Paul Miller (paulmillr.com) */function Dg(t){const e=Jl(t);us(e,{a:"field",b:"field"},{allowedPrivateKeyLengths:"array",wrapPrivateKey:"boolean",isTorsionFree:"function",clearCofactor:"function",allowInfinityPoint:"boolean",fromBytes:"function",toBytes:"function"});const{endo:n,Fp:r,a:s}=e;if(n){if(!r.eql(s,r.ZERO))throw new Error("Endomorphism can only be defined for Koblitz curves that have a=0");if(typeof n!="object"||typeof n.beta!="bigint"||typeof n.splitScalar!="function")throw new Error("Expected endomorphism with beta: bigint and splitScalar: function")}return Object.freeze({...e})}const{bytesToNumberBE:Bg,hexToBytes:Ig}=hg,qn={Err:class extends Error{constructor(e=""){super(e)}},_parseInt(t){const{Err:e}=qn;if(t.length<2||t[0]!==2)throw new e("Invalid signature integer tag");const n=t[1],r=t.subarray(2,n+2);if(!n||r.length!==n)throw new e("Invalid signature integer: wrong length");if(r[0]&128)throw new e("Invalid signature integer: negative");if(r[0]===0&&!(r[1]&128))throw new e("Invalid signature integer: unnecessary leading zero");return{d:Bg(r),l:t.subarray(n+2)}},toSig(t){const{Err:e}=qn,n=typeof t=="string"?Ig(t):t;if(!(n instanceof Uint8Array))throw new Error("ui8a expected");let r=n.length;if(r<2||n[0]!=48)throw new e("Invalid signature tag");if(n[1]!==r-2)throw new e("Invalid signature: incorrect length");const{d:s,l:i}=qn._parseInt(n.subarray(2)),{d:o,l:a}=qn._parseInt(i);if(a.length)throw new e("Invalid signature: left bytes after parsing");return{r:s,s:o}},hexFromSig(t){const e=l=>Number.parseInt(l[0],16)&8?"00"+l:l,n=l=>{const u=l.toString(16);return u.length&1?`0${u}`:u},r=e(n(t.s)),s=e(n(t.r)),i=r.length/2,o=s.length/2,a=n(i),c=n(o);return`30${n(o+i+4)}02${c}${s}02${a}${r}`}},on=BigInt(0),yt=BigInt(1);BigInt(2);const Fa=BigInt(3);BigInt(4);function Og(t){const e=Dg(t),{Fp:n}=e,r=e.toBytes||((S,h,D)=>{const I=h.toAffine();return ts(Uint8Array.from([4]),n.toBytes(I.x),n.toBytes(I.y))}),s=e.fromBytes||(S=>{const h=S.subarray(1),D=n.fromBytes(h.subarray(0,n.BYTES)),I=n.fromBytes(h.subarray(n.BYTES,2*n.BYTES));return{x:D,y:I}});function i(S){const{a:h,b:D}=e,I=n.sqr(S),b=n.mul(I,S);return n.add(n.add(b,n.mul(S,h)),D)}if(!n.eql(n.sqr(e.Gy),i(e.Gx)))throw new Error("bad generator point: equation left != right");function o(S){return typeof S=="bigint"&&on<S&&S<e.n}function a(S){if(!o(S))throw new Error("Expected valid bigint: 0 < bigint < curve.n")}function c(S){const{allowedPrivateKeyLengths:h,nByteLength:D,wrapPrivateKey:I,n:b}=e;if(h&&typeof S!="bigint"){if(S instanceof Uint8Array&&(S=Er(S)),typeof S!="string"||!h.includes(S.length))throw new Error("Invalid key");S=S.padStart(D*2,"0")}let C;try{C=typeof S=="bigint"?S:Jn(vt("private key",S,D))}catch{throw new Error(`private key must be ${D} bytes, hex or bigint, not ${typeof S}`)}return I&&(C=et(C,b)),a(C),C}const l=new Map;function u(S){if(!(S instanceof d))throw new Error("ProjectivePoint expected")}class d{constructor(h,D,I){if(this.px=h,this.py=D,this.pz=I,h==null||!n.isValid(h))throw new Error("x required");if(D==null||!n.isValid(D))throw new Error("y required");if(I==null||!n.isValid(I))throw new Error("z required")}static fromAffine(h){const{x:D,y:I}=h||{};if(!h||!n.isValid(D)||!n.isValid(I))throw new Error("invalid affine point");if(h instanceof d)throw new Error("projective point not allowed");const b=C=>n.eql(C,n.ZERO);return b(D)&&b(I)?d.ZERO:new d(D,I,n.ONE)}get x(){return this.toAffine().x}get y(){return this.toAffine().y}static normalizeZ(h){const D=n.invertBatch(h.map(I=>I.pz));return h.map((I,b)=>I.toAffine(D[b])).map(d.fromAffine)}static fromHex(h){const D=d.fromAffine(s(vt("pointHex",h)));return D.assertValidity(),D}static fromPrivateKey(h){return d.BASE.multiply(c(h))}_setWindowSize(h){this._WINDOW_SIZE=h,l.delete(this)}assertValidity(){if(this.is0()){if(e.allowInfinityPoint&&!n.is0(this.py))return;throw new Error("bad point: ZERO")}const{x:h,y:D}=this.toAffine();if(!n.isValid(h)||!n.isValid(D))throw new Error("bad point: x or y not FE");const I=n.sqr(D),b=i(h);if(!n.eql(I,b))throw new Error("bad point: equation left != right");if(!this.isTorsionFree())throw new Error("bad point: not in prime-order subgroup")}hasEvenY(){const{y:h}=this.toAffine();if(n.isOdd)return!n.isOdd(h);throw new Error("Field doesn't support isOdd")}equals(h){u(h);const{px:D,py:I,pz:b}=this,{px:C,py:f,pz:p}=h,v=n.eql(n.mul(D,p),n.mul(C,b)),k=n.eql(n.mul(I,p),n.mul(f,b));return v&&k}negate(){return new d(this.px,n.neg(this.py),this.pz)}double(){const{a:h,b:D}=e,I=n.mul(D,Fa),{px:b,py:C,pz:f}=this;let p=n.ZERO,v=n.ZERO,k=n.ZERO,x=n.mul(b,b),g=n.mul(C,C),T=n.mul(f,f),A=n.mul(b,C);return A=n.add(A,A),k=n.mul(b,f),k=n.add(k,k),p=n.mul(h,k),v=n.mul(I,T),v=n.add(p,v),p=n.sub(g,v),v=n.add(g,v),v=n.mul(p,v),p=n.mul(A,p),k=n.mul(I,k),T=n.mul(h,T),A=n.sub(x,T),A=n.mul(h,A),A=n.add(A,k),k=n.add(x,x),x=n.add(k,x),x=n.add(x,T),x=n.mul(x,A),v=n.add(v,x),T=n.mul(C,f),T=n.add(T,T),x=n.mul(T,A),p=n.sub(p,x),k=n.mul(T,g),k=n.add(k,k),k=n.add(k,k),new d(p,v,k)}add(h){u(h);const{px:D,py:I,pz:b}=this,{px:C,py:f,pz:p}=h;let v=n.ZERO,k=n.ZERO,x=n.ZERO;const g=e.a,T=n.mul(e.b,Fa);let A=n.mul(D,C),L=n.mul(I,f),K=n.mul(b,p),ee=n.add(D,I),M=n.add(C,f);ee=n.mul(ee,M),M=n.add(A,L),ee=n.sub(ee,M),M=n.add(D,b);let O=n.add(C,p);return M=n.mul(M,O),O=n.add(A,K),M=n.sub(M,O),O=n.add(I,b),v=n.add(f,p),O=n.mul(O,v),v=n.add(L,K),O=n.sub(O,v),x=n.mul(g,M),v=n.mul(T,K),x=n.add(v,x),v=n.sub(L,x),x=n.add(L,x),k=n.mul(v,x),L=n.add(A,A),L=n.add(L,A),K=n.mul(g,K),M=n.mul(T,M),L=n.add(L,K),K=n.sub(A,K),K=n.mul(g,K),M=n.add(M,K),A=n.mul(L,M),k=n.add(k,A),A=n.mul(O,M),v=n.mul(ee,v),v=n.sub(v,A),A=n.mul(ee,L),x=n.mul(O,x),x=n.add(x,A),new d(v,k,x)}subtract(h){return this.add(h.negate())}is0(){return this.equals(d.ZERO)}wNAF(h){return m.wNAFCached(this,l,h,D=>{const I=n.invertBatch(D.map(b=>b.pz));return D.map((b,C)=>b.toAffine(I[C])).map(d.fromAffine)})}multiplyUnsafe(h){const D=d.ZERO;if(h===on)return D;if(a(h),h===yt)return this;const{endo:I}=e;if(!I)return m.unsafeLadder(this,h);let{k1neg:b,k1:C,k2neg:f,k2:p}=I.splitScalar(h),v=D,k=D,x=this;for(;C>on||p>on;)C&yt&&(v=v.add(x)),p&yt&&(k=k.add(x)),x=x.double(),C>>=yt,p>>=yt;return b&&(v=v.negate()),f&&(k=k.negate()),k=new d(n.mul(k.px,I.beta),k.py,k.pz),v.add(k)}multiply(h){a(h);let D=h,I,b;const{endo:C}=e;if(C){const{k1neg:f,k1:p,k2neg:v,k2:k}=C.splitScalar(D);let{p:x,f:g}=this.wNAF(p),{p:T,f:A}=this.wNAF(k);x=m.constTimeNegate(f,x),T=m.constTimeNegate(v,T),T=new d(n.mul(T.px,C.beta),T.py,T.pz),I=x.add(T),b=g.add(A)}else{const{p:f,f:p}=this.wNAF(D);I=f,b=p}return d.normalizeZ([I,b])[0]}multiplyAndAddUnsafe(h,D,I){const b=d.BASE,C=(p,v)=>v===on||v===yt||!p.equals(b)?p.multiplyUnsafe(v):p.multiply(v),f=C(this,D).add(C(h,I));return f.is0()?void 0:f}toAffine(h){const{px:D,py:I,pz:b}=this,C=this.is0();h==null&&(h=C?n.ONE:n.inv(b));const f=n.mul(D,h),p=n.mul(I,h),v=n.mul(b,h);if(C)return{x:n.ZERO,y:n.ZERO};if(!n.eql(v,n.ONE))throw new Error("invZ was invalid");return{x:f,y:p}}isTorsionFree(){const{h,isTorsionFree:D}=e;if(h===yt)return!0;if(D)return D(d,this);throw new Error("isTorsionFree() has not been declared for the elliptic curve")}clearCofactor(){const{h,clearCofactor:D}=e;return h===yt?this:D?D(d,this):this.multiplyUnsafe(e.h)}toRawBytes(h=!0){return this.assertValidity(),r(d,this,h)}toHex(h=!0){return Er(this.toRawBytes(h))}}d.BASE=new d(e.Gx,e.Gy,n.ONE),d.ZERO=new d(n.ZERO,n.ONE,n.ZERO);const w=e.nBitLength,m=Tg(d,e.endo?Math.ceil(w/2):w);return{CURVE:e,ProjectivePoint:d,normPrivateKeyToScalar:c,weierstrassEquation:i,isWithinCurveOrder:o}}function Pg(t){const e=Jl(t);return us(e,{hash:"hash",hmac:"function",randomBytes:"function"},{bits2int:"function",bits2int_modN:"function",lowS:"boolean"}),Object.freeze({lowS:!0,...e})}function $g(t){const e=Pg(t),{Fp:n,n:r}=e,s=n.BYTES+1,i=2*n.BYTES+1;function o(M){return on<M&&M<n.ORDER}function a(M){return et(M,r)}function c(M){return eo(M,r)}const{ProjectivePoint:l,normPrivateKeyToScalar:u,weierstrassEquation:d,isWithinCurveOrder:w}=Og({...e,toBytes(M,O,E){const $=O.toAffine(),Y=n.toBytes($.x),ne=ts;return E?ne(Uint8Array.from([O.hasEvenY()?2:3]),Y):ne(Uint8Array.from([4]),Y,n.toBytes($.y))},fromBytes(M){const O=M.length,E=M[0],$=M.subarray(1);if(O===s&&(E===2||E===3)){const Y=Jn($);if(!o(Y))throw new Error("Point is not on curve");const ne=d(Y);let ce=n.sqrt(ne);const pe=(ce&yt)===yt;return(E&1)===1!==pe&&(ce=n.neg(ce)),{x:Y,y:ce}}else if(O===i&&E===4){const Y=n.fromBytes($.subarray(0,n.BYTES)),ne=n.fromBytes($.subarray(n.BYTES,2*n.BYTES));return{x:Y,y:ne}}else throw new Error(`Point of length ${O} was invalid. Expected ${s} compressed bytes or ${i} uncompressed bytes`)}}),m=M=>Er(kr(M,e.nByteLength));function S(M){const O=r>>yt;return M>O}function h(M){return S(M)?a(-M):M}const D=(M,O,E)=>Jn(M.slice(O,E));class I{constructor(O,E,$){this.r=O,this.s=E,this.recovery=$,this.assertValidity()}static fromCompact(O){const E=e.nByteLength;return O=vt("compactSignature",O,E*2),new I(D(O,0,E),D(O,E,2*E))}static fromDER(O){const{r:E,s:$}=qn.toSig(vt("DER",O));return new I(E,$)}assertValidity(){if(!w(this.r))throw new Error("r must be 0 < r < CURVE.n");if(!w(this.s))throw new Error("s must be 0 < s < CURVE.n")}addRecoveryBit(O){return new I(this.r,this.s,O)}recoverPublicKey(O){const{r:E,s:$,recovery:Y}=this,ne=k(vt("msgHash",O));if(Y==null||![0,1,2,3].includes(Y))throw new Error("recovery id invalid");const ce=Y===2||Y===3?E+e.n:E;if(ce>=n.ORDER)throw new Error("recovery id 2 or 3 invalid");const pe=Y&1?"03":"02",st=l.fromHex(pe+m(ce)),ze=c(ce),bn=a(-ne*ze),wt=a($*ze),it=l.BASE.multiplyAndAddUnsafe(st,bn,wt);if(!it)throw new Error("point at infinify");return it.assertValidity(),it}hasHighS(){return S(this.s)}normalizeS(){return this.hasHighS()?new I(this.r,a(-this.s),this.recovery):this}toDERRawBytes(){return es(this.toDERHex())}toDERHex(){return qn.hexFromSig({r:this.r,s:this.s})}toCompactRawBytes(){return es(this.toCompactHex())}toCompactHex(){return m(this.r)+m(this.s)}}const b={isValidPrivateKey(M){try{return u(M),!0}catch{return!1}},normPrivateKeyToScalar:u,randomPrivateKey:()=>{const M=Xl(e.n);return kg(e.randomBytes(M),e.n)},precompute(M=8,O=l.BASE){return O._setWindowSize(M),O.multiply(BigInt(3)),O}};function C(M,O=!0){return l.fromPrivateKey(M).toRawBytes(O)}function f(M){const O=M instanceof Uint8Array,E=typeof M=="string",$=(O||E)&&M.length;return O?$===s||$===i:E?$===2*s||$===2*i:M instanceof l}function p(M,O,E=!0){if(f(M))throw new Error("first arg must be private key");if(!f(O))throw new Error("second arg must be public key");return l.fromHex(O).multiply(u(M)).toRawBytes(E)}const v=e.bits2int||function(M){const O=Jn(M),E=M.length*8-e.nBitLength;return E>0?O>>BigInt(E):O},k=e.bits2int_modN||function(M){return a(v(M))},x=Ro(e.nBitLength);function g(M){if(typeof M!="bigint")throw new Error("bigint expected");if(!(on<=M&&M<x))throw new Error(`bigint expected < 2^${e.nBitLength}`);return kr(M,e.nByteLength)}function T(M,O,E=A){if(["recovered","canonical"].some(Dt=>Dt in E))throw new Error("sign() legacy options not supported");const{hash:$,randomBytes:Y}=e;let{lowS:ne,prehash:ce,extraEntropy:pe}=E;ne==null&&(ne=!0),M=vt("msgHash",M),ce&&(M=vt("prehashed msgHash",$(M)));const st=k(M),ze=u(O),bn=[g(ze),g(st)];if(pe!=null){const Dt=pe===!0?Y(n.BYTES):pe;bn.push(vt("extraEntropy",Dt))}const wt=ts(...bn),it=st;function Pn(Dt){const pt=v(Dt);if(!w(pt))return;const hi=c(pt),y=l.BASE.multiply(pt).toAffine(),_=a(y.x);if(_===on)return;const P=a(hi*a(it+_*ze));if(P===on)return;let U=(y.x===_?0:2)|Number(y.y&yt),R=P;return ne&&S(P)&&(R=h(P),U^=1),new I(_,R,U)}return{seed:wt,k2sig:Pn}}const A={lowS:e.lowS,prehash:!1},L={lowS:e.lowS,prehash:!1};function K(M,O,E=A){const{seed:$,k2sig:Y}=T(M,O,E),ne=e;return Gl(ne.hash.outputLen,ne.nByteLength,ne.hmac)($,Y)}l.BASE._setWindowSize(8);function ee(M,O,E,$=L){var y;const Y=M;if(O=vt("msgHash",O),E=vt("publicKey",E),"strict"in $)throw new Error("options.strict was renamed to lowS");const{lowS:ne,prehash:ce}=$;let pe,st;try{if(typeof Y=="string"||Y instanceof Uint8Array)try{pe=I.fromDER(Y)}catch(_){if(!(_ instanceof qn.Err))throw _;pe=I.fromCompact(Y)}else if(typeof Y=="object"&&typeof Y.r=="bigint"&&typeof Y.s=="bigint"){const{r:_,s:P}=Y;pe=new I(_,P)}else throw new Error("PARSE");st=l.fromHex(E)}catch(_){if(_.message==="PARSE")throw new Error("signature must be Signature instance, Uint8Array or hex string");return!1}if(ne&&pe.hasHighS())return!1;ce&&(O=e.hash(O));const{r:ze,s:bn}=pe,wt=k(O),it=c(bn),Pn=a(wt*it),Dt=a(ze*it),pt=(y=l.BASE.multiplyAndAddUnsafe(st,Pn,Dt))==null?void 0:y.toAffine();return pt?a(pt.x)===ze:!1}return{CURVE:e,getPublicKey:C,getSharedSecret:p,sign:K,verify:ee,ProjectivePoint:l,Signature:I,utils:b}}/*! noble-curves - MIT License (c) 2022 Paul Miller (paulmillr.com) */function Lg(t){return{hash:t,hmac:(e,...n)=>Ul(t,e,Vp(...n)),randomBytes:Fp}}function Rg(t,e){const n=r=>$g({...t,...Lg(r)});return Object.freeze({...n(e),create:n})}/*! noble-curves - MIT License (c) 2022 Paul Miller (paulmillr.com) */const Yl=BigInt("0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f"),qa=BigInt("0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141"),Ng=BigInt(1),to=BigInt(2),Wa=(t,e)=>(t+e/to)/e;function Mg(t){const e=Yl,n=BigInt(3),r=BigInt(6),s=BigInt(11),i=BigInt(22),o=BigInt(23),a=BigInt(44),c=BigInt(88),l=t*t*t%e,u=l*l*t%e,d=gt(u,n,e)*u%e,w=gt(d,n,e)*u%e,m=gt(w,to,e)*l%e,S=gt(m,s,e)*m%e,h=gt(S,i,e)*S%e,D=gt(h,a,e)*h%e,I=gt(D,c,e)*D%e,b=gt(I,a,e)*h%e,C=gt(b,n,e)*u%e,f=gt(C,o,e)*S%e,p=gt(f,r,e)*l%e,v=gt(p,to,e);if(!no.eql(no.sqr(v),t))throw new Error("Cannot find square root");return v}const no=Eg(Yl,void 0,void 0,{sqrt:Mg}),xn=Rg({a:BigInt(0),b:BigInt(7),Fp:no,n:qa,Gx:BigInt("55066263022277343669578718895168534326250603453777594175500187360389116729240"),Gy:BigInt("32670510020758816978083085130507043184471273380659243275938904335757337482424"),h:BigInt(1),lowS:!0,endo:{beta:BigInt("0x7ae96a2b657c07106e64479eac3434e99cf0497512f58995c1396c28719501ee"),splitScalar:t=>{const e=qa,n=BigInt("0x3086d221a7d46bcde86c90e49284eb15"),r=-Ng*BigInt("0xe4437ed6010e88286f547fa90abfe4c3"),s=BigInt("0x114ca50f7a8e2f3f657c1108d9d44cfd8"),i=n,o=BigInt("0x100000000000000000000000000000000"),a=Wa(i*t,e),c=Wa(-r*t,e);let l=et(t-a*n-c*s,e),u=et(-a*r-c*i,e);const d=l>o,w=u>o;if(d&&(l=e-l),w&&(u=e-u),l>o||u>o)throw new Error("splitScalar: Endomorphism failed, k="+t);return{k1neg:d,k1:l,k2neg:w,k2:u}}}},Xp);BigInt(0);xn.ProjectivePoint;const za="0x0000000000000000000000000000000000000000000000000000000000000000",Ga=BigInt(0),Ka=BigInt(1),ro=BigInt(2),ja=BigInt(27),Xa=BigInt(28),vs=BigInt(35),Zl=BigInt("0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141"),Ug=Zl/ro,Hg=Symbol.for("nodejs.util.inspect.custom"),Rn={};function Oi(t){return Dl(Il(t),32)}var mr,Rt,hr,An;const mt=class mt{constructor(e,n,r,s){he(this,mr);he(this,Rt);he(this,hr);he(this,An);li(e,Rn,"Signature"),oe(this,mr,n),oe(this,Rt,r),oe(this,hr,s),oe(this,An,null)}get r(){return N(this,mr)}set r(e){z(Kr(e)===32,"invalid r","value",e),oe(this,mr,fe(e))}get s(){return z(parseInt(N(this,Rt).substring(0,3))<8,"non-canonical s; use ._s","s",N(this,Rt)),N(this,Rt)}set s(e){z(Kr(e)===32,"invalid s","value",e),oe(this,Rt,fe(e))}get _s(){return N(this,Rt)}isValid(){return BigInt(N(this,Rt))<=Ug}get v(){return N(this,hr)}set v(e){const n=Et(e,"value");z(n===27||n===28,"invalid v","v",e),oe(this,hr,n)}get networkV(){return N(this,An)}get legacyChainId(){const e=this.networkV;return e==null?null:mt.getChainId(e)}get yParity(){return this.v===27?0:1}get yParityAndS(){const e=We(this.s);return this.yParity&&(e[0]|=128),fe(e)}get compactSerialized(){return un([this.r,this.yParityAndS])}get serialized(){return un([this.r,this.s,this.yParity?"0x1c":"0x1b"])}getCanonical(){if(this.isValid())return this;const e=Zl-BigInt(this._s),n=55-this.v,r=new mt(Rn,this.r,Oi(e),n);return this.networkV&&oe(r,An,this.networkV),r}clone(){const e=new mt(Rn,this.r,this._s,this.v);return this.networkV&&oe(e,An,this.networkV),e}toJSON(){const e=this.networkV;return{_type:"signature",networkV:e!=null?e.toString():null,r:this.r,s:this._s,v:this.v}}[Hg](){return this.toString()}toString(){return this.isValid()?`Signature { r: ${this.r}, s: ${this._s}, v: ${this.v} }`:`Signature { r: ${this.r}, s: ${this._s}, v: ${this.v}, valid: false }`}static getChainId(e){const n=qt(e,"v");return n==ja||n==Xa?Ga:(z(n>=vs,"invalid EIP-155 v","v",e),(n-vs)/ro)}static getChainIdV(e,n){return qt(e)*ro+BigInt(35+n-27)}static getNormalizedV(e){const n=qt(e);return n===Ga||n===ja?27:n===Ka||n===Xa?28:(z(n>=vs,"invalid v","v",e),n&Ka?27:28)}static from(e){function n(l,u){z(l,u,"signature",e)}if(e==null)return new mt(Rn,za,za,27);if(typeof e=="string"){const l=We(e,"signature");if(l.length===64){const u=fe(l.slice(0,32)),d=l.slice(32,64),w=d[0]&128?28:27;return d[0]&=127,new mt(Rn,u,fe(d),w)}if(l.length===65){const u=fe(l.slice(0,32)),d=fe(l.slice(32,64)),w=mt.getNormalizedV(l[64]);return new mt(Rn,u,d,w)}n(!1,"invalid raw signature length")}if(e instanceof mt)return e.clone();const r=e.r;n(r!=null,"missing r");const s=Oi(r),i=function(l,u){if(l!=null)return Oi(l);if(u!=null){n(Fn(u,32),"invalid yParityAndS");const d=We(u);return d[0]&=127,fe(d)}n(!1,"missing s")}(e.s,e.yParityAndS),{networkV:o,v:a}=function(l,u,d){if(l!=null){const w=qt(l);return{networkV:w>=vs?w:void 0,v:mt.getNormalizedV(w)}}if(u!=null)return n(Fn(u,32),"invalid yParityAndS"),{v:We(u)[0]&128?28:27};if(d!=null){switch(Et(d,"sig.yParity")){case 0:return{v:27};case 1:return{v:28}}n(!1,"invalid yParity")}n(!1,"missing v")}(e.v,e.yParityAndS,e.yParity),c=new mt(Rn,s,i,a);return o&&oe(c,An,o),n(e.yParity==null||Et(e.yParity,"sig.yParity")===c.yParity,"yParity mismatch"),n(e.yParityAndS==null||e.yParityAndS===c.yParityAndS,"yParityAndS mismatch"),c}};mr=new WeakMap,Rt=new WeakMap,hr=new WeakMap,An=new WeakMap;let Ws=mt;var nn;const Hn=class Hn{constructor(e){he(this,nn);z(Kr(e)===32,"invalid private key","privateKey","[REDACTED]"),oe(this,nn,fe(e))}get privateKey(){return N(this,nn)}get publicKey(){return Hn.computePublicKey(N(this,nn))}get compressedPublicKey(){return Hn.computePublicKey(N(this,nn),!0)}sign(e){z(Kr(e)===32,"invalid digest length","digest",e);const n=xn.sign(je(e),je(N(this,nn)),{lowS:!0});return Ws.from({r:Fs(n.r,32),s:Fs(n.s,32),v:n.recovery?28:27})}computeSharedSecret(e){const n=Hn.computePublicKey(e);return fe(xn.getSharedSecret(je(N(this,nn)),We(n),!1))}static computePublicKey(e,n){let r=We(e,"key");if(r.length===32){const i=xn.getPublicKey(r,!!n);return fe(i)}if(r.length===64){const i=new Uint8Array(65);i[0]=4,i.set(r,1),r=i}const s=xn.ProjectivePoint.fromHex(r);return fe(s.toRawBytes(n))}static recoverPublicKey(e,n){z(Kr(e)===32,"invalid digest length","digest",e);const r=Ws.from(n);let s=xn.Signature.fromCompact(je(un([r.r,r.s])));s=s.addRecoveryBit(r.yParity);const i=s.recoverPublicKey(je(e));return z(i!=null,"invalid signature for digest","signature",n),"0x"+i.toHex(!1)}static addPoints(e,n,r){const s=xn.ProjectivePoint.fromHex(Hn.computePublicKey(e).substring(2)),i=xn.ProjectivePoint.fromHex(Hn.computePublicKey(n).substring(2));return"0x"+s.add(i).toHex(!!r)}};nn=new WeakMap;let so=Hn;const Vg=BigInt(0),Fg=BigInt(36);function Ja(t){t=t.toLowerCase();const e=t.substring(2).split(""),n=new Uint8Array(40);for(let s=0;s<40;s++)n[s]=e[s].charCodeAt(0);const r=We(jt(n));for(let s=0;s<40;s+=2)r[s>>1]>>4>=8&&(e[s]=e[s].toUpperCase()),(r[s>>1]&15)>=8&&(e[s+1]=e[s+1].toUpperCase());return"0x"+e.join("")}const No={};for(let t=0;t<10;t++)No[String(t)]=String(t);for(let t=0;t<26;t++)No[String.fromCharCode(65+t)]=String(10+t);const Ya=15;function qg(t){t=t.toUpperCase(),t=t.substring(4)+t.substring(0,2)+"00";let e=t.split("").map(r=>No[r]).join("");for(;e.length>=Ya;){let r=e.substring(0,Ya);e=parseInt(r,10)%97+e.substring(r.length)}let n=String(98-parseInt(e,10)%97);for(;n.length<2;)n="0"+n;return n}const Wg=function(){const t={};for(let e=0;e<36;e++){const n="0123456789abcdefghijklmnopqrstuvwxyz"[e];t[n]=BigInt(e)}return t}();function zg(t){t=t.toLowerCase();let e=Vg;for(let n=0;n<t.length;n++)e=e*Fg+Wg[t[n]];return e}function Ar(t){if(z(typeof t=="string","invalid address","address",t),t.match(/^(0x)?[0-9a-fA-F]{40}$/)){t.startsWith("0x")||(t="0x"+t);const e=Ja(t);return z(!t.match(/([A-F].*[a-f])|([a-f].*[A-F])/)||e===t,"bad address checksum","address",t),e}if(t.match(/^XE[0-9]{2}[0-9A-Za-z]{30,31}$/)){z(t.substring(2,4)===qg(t),"bad icap checksum","address",t);let e=zg(t.substring(4)).toString(16);for(;e.length<40;)e="0"+e;return Ja("0x"+e)}z(!1,"invalid address","address",t)}const Yt={};function X(t,e){let n=!1;return e<0&&(n=!0,e*=-1),new nt(Yt,`${n?"":"u"}int${e}`,t,{signed:n,width:e})}function le(t,e){return new nt(Yt,`bytes${e||""}`,t,{size:e})}const Za=Symbol.for("_ethers_typed");var Kn;const Zt=class Zt{constructor(e,n,r,s){Z(this,"type");Z(this,"value");he(this,Kn);Z(this,"_typedSymbol");s==null&&(s=null),li(Yt,e,"Typed"),_e(this,{_typedSymbol:Za,type:n,value:r}),oe(this,Kn,s),this.format()}format(){if(this.type==="array")throw new Error("");if(this.type==="dynamicArray")throw new Error("");return this.type==="tuple"?`tuple(${this.value.map(e=>e.format()).join(",")})`:this.type}defaultValue(){return 0}minValue(){return 0}maxValue(){return 0}isBigInt(){return!!this.type.match(/^u?int[0-9]+$/)}isData(){return this.type.startsWith("bytes")}isString(){return this.type==="string"}get tupleName(){if(this.type!=="tuple")throw TypeError("not a tuple");return N(this,Kn)}get arrayLength(){if(this.type!=="array")throw TypeError("not an array");return N(this,Kn)===!0?-1:N(this,Kn)===!1?this.value.length:null}static from(e,n){return new Zt(Yt,e,n)}static uint8(e){return X(e,8)}static uint16(e){return X(e,16)}static uint24(e){return X(e,24)}static uint32(e){return X(e,32)}static uint40(e){return X(e,40)}static uint48(e){return X(e,48)}static uint56(e){return X(e,56)}static uint64(e){return X(e,64)}static uint72(e){return X(e,72)}static uint80(e){return X(e,80)}static uint88(e){return X(e,88)}static uint96(e){return X(e,96)}static uint104(e){return X(e,104)}static uint112(e){return X(e,112)}static uint120(e){return X(e,120)}static uint128(e){return X(e,128)}static uint136(e){return X(e,136)}static uint144(e){return X(e,144)}static uint152(e){return X(e,152)}static uint160(e){return X(e,160)}static uint168(e){return X(e,168)}static uint176(e){return X(e,176)}static uint184(e){return X(e,184)}static uint192(e){return X(e,192)}static uint200(e){return X(e,200)}static uint208(e){return X(e,208)}static uint216(e){return X(e,216)}static uint224(e){return X(e,224)}static uint232(e){return X(e,232)}static uint240(e){return X(e,240)}static uint248(e){return X(e,248)}static uint256(e){return X(e,256)}static uint(e){return X(e,256)}static int8(e){return X(e,-8)}static int16(e){return X(e,-16)}static int24(e){return X(e,-24)}static int32(e){return X(e,-32)}static int40(e){return X(e,-40)}static int48(e){return X(e,-48)}static int56(e){return X(e,-56)}static int64(e){return X(e,-64)}static int72(e){return X(e,-72)}static int80(e){return X(e,-80)}static int88(e){return X(e,-88)}static int96(e){return X(e,-96)}static int104(e){return X(e,-104)}static int112(e){return X(e,-112)}static int120(e){return X(e,-120)}static int128(e){return X(e,-128)}static int136(e){return X(e,-136)}static int144(e){return X(e,-144)}static int152(e){return X(e,-152)}static int160(e){return X(e,-160)}static int168(e){return X(e,-168)}static int176(e){return X(e,-176)}static int184(e){return X(e,-184)}static int192(e){return X(e,-192)}static int200(e){return X(e,-200)}static int208(e){return X(e,-208)}static int216(e){return X(e,-216)}static int224(e){return X(e,-224)}static int232(e){return X(e,-232)}static int240(e){return X(e,-240)}static int248(e){return X(e,-248)}static int256(e){return X(e,-256)}static int(e){return X(e,-256)}static bytes1(e){return le(e,1)}static bytes2(e){return le(e,2)}static bytes3(e){return le(e,3)}static bytes4(e){return le(e,4)}static bytes5(e){return le(e,5)}static bytes6(e){return le(e,6)}static bytes7(e){return le(e,7)}static bytes8(e){return le(e,8)}static bytes9(e){return le(e,9)}static bytes10(e){return le(e,10)}static bytes11(e){return le(e,11)}static bytes12(e){return le(e,12)}static bytes13(e){return le(e,13)}static bytes14(e){return le(e,14)}static bytes15(e){return le(e,15)}static bytes16(e){return le(e,16)}static bytes17(e){return le(e,17)}static bytes18(e){return le(e,18)}static bytes19(e){return le(e,19)}static bytes20(e){return le(e,20)}static bytes21(e){return le(e,21)}static bytes22(e){return le(e,22)}static bytes23(e){return le(e,23)}static bytes24(e){return le(e,24)}static bytes25(e){return le(e,25)}static bytes26(e){return le(e,26)}static bytes27(e){return le(e,27)}static bytes28(e){return le(e,28)}static bytes29(e){return le(e,29)}static bytes30(e){return le(e,30)}static bytes31(e){return le(e,31)}static bytes32(e){return le(e,32)}static address(e){return new Zt(Yt,"address",e)}static bool(e){return new Zt(Yt,"bool",!!e)}static bytes(e){return new Zt(Yt,"bytes",e)}static string(e){return new Zt(Yt,"string",e)}static array(e,n){throw new Error("not implemented yet")}static tuple(e,n){throw new Error("not implemented yet")}static overrides(e){return new Zt(Yt,"overrides",Object.assign({},e))}static isTyped(e){return e&&typeof e=="object"&&"_typedSymbol"in e&&e._typedSymbol===Za}static dereference(e,n){if(Zt.isTyped(e)){if(e.type!==n)throw new Error(`invalid type: expecetd ${n}, got ${e.type}`);return e.value}return e}};Kn=new WeakMap;let nt=Zt;class Gg extends yn{constructor(e){super("address","address",e,!1)}defaultValue(){return"0x0000000000000000000000000000000000000000"}encode(e,n){let r=nt.dereference(n,"string");try{r=Ar(r)}catch(s){return this._throwError(s.message,n)}return e.writeValue(r)}decode(e){return Ar(Fs(e.readValue(),20))}}class Kg extends yn{constructor(n){super(n.name,n.type,"_",n.dynamic);Z(this,"coder");this.coder=n}defaultValue(){return this.coder.defaultValue()}encode(n,r){return this.coder.encode(n,r)}decode(n){return this.coder.decode(n)}}function Ql(t,e,n){let r=[];if(Array.isArray(n))r=n;else if(n&&typeof n=="object"){let c={};r=e.map(l=>{const u=l.localName;return Ae(u,"cannot encode object for signature with missing names","INVALID_ARGUMENT",{argument:"values",info:{coder:l},value:n}),Ae(!c[u],"cannot encode object for signature with duplicate names","INVALID_ARGUMENT",{argument:"values",info:{coder:l},value:n}),c[u]=!0,n[u]})}else z(!1,"invalid tuple value","tuple",n);z(e.length===r.length,"types/value length mismatch","tuple",n);let s=new Ji,i=new Ji,o=[];e.forEach((c,l)=>{let u=r[l];if(c.dynamic){let d=i.length;c.encode(i,u);let w=s.writeUpdatableValue();o.push(m=>{w(m+d)})}else c.encode(s,u)}),o.forEach(c=>{c(s.length)});let a=t.appendWriter(s);return a+=t.appendWriter(i),a}function eu(t,e){let n=[],r=[],s=t.subReader(0);return e.forEach(i=>{let o=null;if(i.dynamic){let a=t.readIndex(),c=s.subReader(a);try{o=i.decode(c)}catch(l){if(Ia(l,"BUFFER_OVERRUN"))throw l;o=l,o.baseType=i.name,o.name=i.localName,o.type=i.type}}else try{o=i.decode(t)}catch(a){if(Ia(a,"BUFFER_OVERRUN"))throw a;o=a,o.baseType=i.name,o.name=i.localName,o.type=i.type}if(o==null)throw new Error("investigate");n.push(o),r.push(i.localName||null)}),Cr.fromItems(n,r)}class jg extends yn{constructor(n,r,s){const i=n.type+"["+(r>=0?r:"")+"]",o=r===-1||n.dynamic;super("array",i,s,o);Z(this,"coder");Z(this,"length");_e(this,{coder:n,length:r})}defaultValue(){const n=this.coder.defaultValue(),r=[];for(let s=0;s<this.length;s++)r.push(n);return r}encode(n,r){const s=nt.dereference(r,"array");Array.isArray(s)||this._throwError("expected array value",s);let i=this.length;i===-1&&(i=s.length,n.writeValue(s.length)),kl(s.length,i,"coder array"+(this.localName?" "+this.localName:""));let o=[];for(let a=0;a<s.length;a++)o.push(this.coder);return Ql(n,o,s)}decode(n){let r=this.length;r===-1&&(r=n.readIndex(),Ae(r*Xe<=n.dataLength,"insufficient data length","BUFFER_OVERRUN",{buffer:n.bytes,offset:r*Xe,length:n.dataLength}));let s=[];for(let i=0;i<r;i++)s.push(new Kg(this.coder));return eu(n,s)}}class Xg extends yn{constructor(e){super("bool","bool",e,!1)}defaultValue(){return!1}encode(e,n){const r=nt.dereference(n,"bool");return e.writeValue(r?1:0)}decode(e){return!!e.readValue()}}class tu extends yn{constructor(e,n){super(e,e,n,!0)}defaultValue(){return"0x"}encode(e,n){n=je(n);let r=e.writeValue(n.length);return r+=e.writeBytes(n),r}decode(e){return e.readBytes(e.readIndex(),!0)}}class Jg extends tu{constructor(e){super("bytes",e)}decode(e){return fe(super.decode(e))}}class Yg extends yn{constructor(n,r){let s="bytes"+String(n);super(s,s,r,!1);Z(this,"size");_e(this,{size:n},{size:"number"})}defaultValue(){return"0x0000000000000000000000000000000000000000000000000000000000000000".substring(0,2+this.size*2)}encode(n,r){let s=je(nt.dereference(r,this.type));return s.length!==this.size&&this._throwError("incorrect data length",r),n.writeBytes(s)}decode(n){return fe(n.readBytes(this.size))}}const Zg=new Uint8Array([]);class Qg extends yn{constructor(e){super("null","",e,!1)}defaultValue(){return null}encode(e,n){return n!=null&&this._throwError("not null",n),e.writeBytes(Zg)}decode(e){return e.readBytes(0),null}}const em=BigInt(0),tm=BigInt(1),nm=BigInt("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");class rm extends yn{constructor(n,r,s){const i=(r?"int":"uint")+n*8;super(i,i,s,!1);Z(this,"size");Z(this,"signed");_e(this,{size:n,signed:r},{size:"number",signed:"boolean"})}defaultValue(){return 0}encode(n,r){let s=qt(nt.dereference(r,this.type)),i=ys(nm,Xe*8);if(this.signed){let o=ys(i,this.size*8-1);(s>o||s<-(o+tm))&&this._throwError("value out-of-bounds",r),s=Tp(s,8*Xe)}else(s<em||s>ys(i,this.size*8))&&this._throwError("value out-of-bounds",r);return n.writeValue(s)}decode(n){let r=ys(n.readValue(),this.size*8);return this.signed&&(r=Ap(r,this.size*8)),r}}class sm extends tu{constructor(e){super("string",e)}defaultValue(){return""}encode(e,n){return super.encode(e,di(nt.dereference(n,"string")))}decode(e){return Lp(super.decode(e))}}class _s extends yn{constructor(n,r){let s=!1;const i=[];n.forEach(a=>{a.dynamic&&(s=!0),i.push(a.type)});const o="tuple("+i.join(",")+")";super("tuple",o,r,s);Z(this,"coders");_e(this,{coders:Object.freeze(n.slice())})}defaultValue(){const n=[];this.coders.forEach(s=>{n.push(s.defaultValue())});const r=this.coders.reduce((s,i)=>{const o=i.localName;return o&&(s[o]||(s[o]=0),s[o]++),s},{});return this.coders.forEach((s,i)=>{let o=s.localName;!o||r[o]!==1||(o==="length"&&(o="_length"),n[o]==null&&(n[o]=n[i]))}),Object.freeze(n)}encode(n,r){const s=nt.dereference(r,"tuple");return Ql(n,this.coders,s)}decode(n){return eu(n,this.coders)}}function ns(t){return jt(di(t))}function Je(t){const e=new Set;return t.forEach(n=>e.add(n)),Object.freeze(e)}const im="external public payable override",om=Je(im.split(" ")),nu="constant external internal payable private public pure view override",am=Je(nu.split(" ")),ru="constructor error event fallback function receive struct",su=Je(ru.split(" ")),iu="calldata memory storage payable indexed",cm=Je(iu.split(" ")),lm="tuple returns",um=[ru,iu,lm,nu].join(" "),dm=Je(um.split(" ")),fm={"(":"OPEN_PAREN",")":"CLOSE_PAREN","[":"OPEN_BRACKET","]":"CLOSE_BRACKET",",":"COMMA","@":"AT"},pm=new RegExp("^(\\s*)"),gm=new RegExp("^([0-9]+)"),mm=new RegExp("^([a-zA-Z$_][a-zA-Z0-9$_]*)"),ou=new RegExp("^([a-zA-Z$_][a-zA-Z0-9$_]*)$"),au=new RegExp("^(address|bool|bytes([0-9]*)|string|u?int([0-9]*))$");var $e,_t,ss,io;const zs=class zs{constructor(e){he(this,ss);he(this,$e);he(this,_t);oe(this,$e,0),oe(this,_t,e.slice())}get offset(){return N(this,$e)}get length(){return N(this,_t).length-N(this,$e)}clone(){return new zs(N(this,_t))}reset(){oe(this,$e,0)}popKeyword(e){const n=this.peek();if(n.type!=="KEYWORD"||!e.has(n.text))throw new Error(`expected keyword ${n.text}`);return this.pop().text}popType(e){if(this.peek().type!==e){const n=this.peek();throw new Error(`expected ${e}; got ${n.type} ${JSON.stringify(n.text)}`)}return this.pop().text}popParen(){const e=this.peek();if(e.type!=="OPEN_PAREN")throw new Error("bad start");const n=xe(this,ss,io).call(this,N(this,$e)+1,e.match+1);return oe(this,$e,e.match+1),n}popParams(){const e=this.peek();if(e.type!=="OPEN_PAREN")throw new Error("bad start");const n=[];for(;N(this,$e)<e.match-1;){const r=this.peek().linkNext;n.push(xe(this,ss,io).call(this,N(this,$e)+1,r)),oe(this,$e,r)}return oe(this,$e,e.match+1),n}peek(){if(N(this,$e)>=N(this,_t).length)throw new Error("out-of-bounds");return N(this,_t)[N(this,$e)]}peekKeyword(e){const n=this.peekType("KEYWORD");return n!=null&&e.has(n)?n:null}peekType(e){if(this.length===0)return null;const n=this.peek();return n.type===e?n.text:null}pop(){const e=this.peek();return qo(this,$e)._++,e}toString(){const e=[];for(let n=N(this,$e);n<N(this,_t).length;n++){const r=N(this,_t)[n];e.push(`${r.type}:${r.text}`)}return`<TokenString ${e.join(" ")}>`}};$e=new WeakMap,_t=new WeakMap,ss=new WeakSet,io=function(e=0,n=0){return new zs(N(this,_t).slice(e,n).map(r=>Object.freeze(Object.assign({},r,{match:r.match-e,linkBack:r.linkBack-e,linkNext:r.linkNext-e}))))};let At=zs;function On(t){const e=[],n=o=>{const a=i<t.length?JSON.stringify(t[i]):"$EOI";throw new Error(`invalid token ${a} at ${i}: ${o}`)};let r=[],s=[],i=0;for(;i<t.length;){let o=t.substring(i),a=o.match(pm);a&&(i+=a[1].length,o=t.substring(i));const c={depth:r.length,linkBack:-1,linkNext:-1,match:-1,type:"",text:"",offset:i,value:-1};e.push(c);let l=fm[o[0]]||"";if(l){if(c.type=l,c.text=o[0],i++,l==="OPEN_PAREN")r.push(e.length-1),s.push(e.length-1);else if(l=="CLOSE_PAREN")r.length===0&&n("no matching open bracket"),c.match=r.pop(),e[c.match].match=e.length-1,c.depth--,c.linkBack=s.pop(),e[c.linkBack].linkNext=e.length-1;else if(l==="COMMA")c.linkBack=s.pop(),e[c.linkBack].linkNext=e.length-1,s.push(e.length-1);else if(l==="OPEN_BRACKET")c.type="BRACKET";else if(l==="CLOSE_BRACKET"){let u=e.pop().text;if(e.length>0&&e[e.length-1].type==="NUMBER"){const d=e.pop().text;u=d+u,e[e.length-1].value=Et(d)}if(e.length===0||e[e.length-1].type!=="BRACKET")throw new Error("missing opening bracket");e[e.length-1].text+=u}continue}if(a=o.match(mm),a){if(c.text=a[1],i+=c.text.length,dm.has(c.text)){c.type="KEYWORD";continue}if(c.text.match(au)){c.type="TYPE";continue}c.type="ID";continue}if(a=o.match(gm),a){c.text=a[1],c.type="NUMBER",i+=c.text.length;continue}throw new Error(`unexpected token ${JSON.stringify(o[0])} at position ${i}`)}return new At(e.map(o=>Object.freeze(o)))}function Qa(t,e){let n=[];for(const r in e.keys())t.has(r)&&n.push(r);if(n.length>1)throw new Error(`conflicting types: ${n.join(", ")}`)}function gi(t,e){if(e.peekKeyword(su)){const n=e.pop().text;if(n!==t)throw new Error(`expected ${t}, got ${n}`)}return e.popType("ID")}function mn(t,e){const n=new Set;for(;;){const r=t.peekType("KEYWORD");if(r==null||e&&!e.has(r))break;if(t.pop(),n.has(r))throw new Error(`duplicate keywords: ${JSON.stringify(r)}`);n.add(r)}return Object.freeze(n)}function cu(t){let e=mn(t,am);return Qa(e,Je("constant payable nonpayable".split(" "))),Qa(e,Je("pure view payable nonpayable".split(" "))),e.has("view")?"view":e.has("pure")?"pure":e.has("payable")?"payable":e.has("nonpayable")?"nonpayable":e.has("constant")?"view":"nonpayable"}function dn(t,e){return t.popParams().map(n=>Ne.from(n,e))}function lu(t){if(t.peekType("AT")){if(t.pop(),t.peekType("NUMBER"))return qt(t.pop().text);throw new Error("invalid gas")}return null}function Qn(t){if(t.length)throw new Error(`unexpected tokens at offset ${t.offset}: ${t.toString()}`)}const hm=new RegExp(/^(.*)\[([0-9]*)\]$/);function ec(t){const e=t.match(au);if(z(e,"invalid type","type",t),t==="uint")return"uint256";if(t==="int")return"int256";if(e[2]){const n=parseInt(e[2]);z(n!==0&&n<=32,"invalid bytes length","type",t)}else if(e[3]){const n=parseInt(e[3]);z(n!==0&&n<=256&&n%8===0,"invalid numeric width","type",t)}return t}const Ce={},rt=Symbol.for("_ethers_internal"),tc="_ParamTypeInternal",nc="_ErrorInternal",rc="_EventInternal",sc="_ConstructorInternal",ic="_FallbackInternal",oc="_FunctionInternal",ac="_StructInternal";var yr,Bs;const ht=class ht{constructor(e,n,r,s,i,o,a,c){he(this,yr);Z(this,"name");Z(this,"type");Z(this,"baseType");Z(this,"indexed");Z(this,"components");Z(this,"arrayLength");Z(this,"arrayChildren");if(li(e,Ce,"ParamType"),Object.defineProperty(this,rt,{value:tc}),o&&(o=Object.freeze(o.slice())),s==="array"){if(a==null||c==null)throw new Error("")}else if(a!=null||c!=null)throw new Error("");if(s==="tuple"){if(o==null)throw new Error("")}else if(o!=null)throw new Error("");_e(this,{name:n,type:r,baseType:s,indexed:i,components:o,arrayLength:a,arrayChildren:c})}format(e){if(e==null&&(e="sighash"),e==="json"){const r=this.name||"";if(this.isArray()){const i=JSON.parse(this.arrayChildren.format("json"));return i.name=r,i.type+=`[${this.arrayLength<0?"":String(this.arrayLength)}]`,JSON.stringify(i)}const s={type:this.baseType==="tuple"?"tuple":this.type,name:r};return typeof this.indexed=="boolean"&&(s.indexed=this.indexed),this.isTuple()&&(s.components=this.components.map(i=>JSON.parse(i.format(e)))),JSON.stringify(s)}let n="";return this.isArray()?(n+=this.arrayChildren.format(e),n+=`[${this.arrayLength<0?"":String(this.arrayLength)}]`):this.isTuple()?n+="("+this.components.map(r=>r.format(e)).join(e==="full"?", ":",")+")":n+=this.type,e!=="sighash"&&(this.indexed===!0&&(n+=" indexed"),e==="full"&&this.name&&(n+=" "+this.name)),n}isArray(){return this.baseType==="array"}isTuple(){return this.baseType==="tuple"}isIndexable(){return this.indexed!=null}walk(e,n){if(this.isArray()){if(!Array.isArray(e))throw new Error("invalid array value");if(this.arrayLength!==-1&&e.length!==this.arrayLength)throw new Error("array is wrong length");const r=this;return e.map(s=>r.arrayChildren.walk(s,n))}if(this.isTuple()){if(!Array.isArray(e))throw new Error("invalid tuple value");if(e.length!==this.components.length)throw new Error("array is wrong length");const r=this;return e.map((s,i)=>r.components[i].walk(s,n))}return n(this.type,e)}async walkAsync(e,n){const r=[],s=[e];return xe(this,yr,Bs).call(this,r,e,n,i=>{s[0]=i}),r.length&&await Promise.all(r),s[0]}static from(e,n){if(ht.isParamType(e))return e;if(typeof e=="string")try{return ht.from(On(e),n)}catch{z(!1,"invalid param type","obj",e)}else if(e instanceof At){let a="",c="",l=null;mn(e,Je(["tuple"])).has("tuple")||e.peekType("OPEN_PAREN")?(c="tuple",l=e.popParams().map(h=>ht.from(h)),a=`tuple(${l.map(h=>h.format()).join(",")})`):(a=ec(e.popType("TYPE")),c=a);let u=null,d=null;for(;e.length&&e.peekType("BRACKET");){const h=e.pop();u=new ht(Ce,"",a,c,null,l,d,u),d=h.value,a+=h.text,c="array",l=null}let w=null;if(mn(e,cm).has("indexed")){if(!n)throw new Error("");w=!0}const S=e.peekType("ID")?e.pop().text:"";if(e.length)throw new Error("leftover tokens");return new ht(Ce,S,a,c,w,l,d,u)}const r=e.name;z(!r||typeof r=="string"&&r.match(ou),"invalid name","obj.name",r);let s=e.indexed;s!=null&&(z(n,"parameter cannot be indexed","obj.indexed",e.indexed),s=!!s);let i=e.type,o=i.match(hm);if(o){const a=parseInt(o[2]||"-1"),c=ht.from({type:o[1],components:e.components});return new ht(Ce,r||"",i,"array",s,null,a,c)}if(i==="tuple"||i.startsWith("tuple(")||i.startsWith("(")){const a=e.components!=null?e.components.map(l=>ht.from(l)):null;return new ht(Ce,r||"",i,"tuple",s,a,null,null)}return i=ec(e.type),new ht(Ce,r||"",i,i,s,null,null,null)}static isParamType(e){return e&&e[rt]===tc}};yr=new WeakSet,Bs=function(e,n,r,s){if(this.isArray()){if(!Array.isArray(n))throw new Error("invalid array value");if(this.arrayLength!==-1&&n.length!==this.arrayLength)throw new Error("array is wrong length");const o=this.arrayChildren,a=n.slice();a.forEach((c,l)=>{var u;xe(u=o,yr,Bs).call(u,e,c,r,d=>{a[l]=d})}),s(a);return}if(this.isTuple()){const o=this.components;let a;if(Array.isArray(n))a=n.slice();else{if(n==null||typeof n!="object")throw new Error("invalid tuple value");a=o.map(c=>{if(!c.name)throw new Error("cannot use object value with unnamed components");if(!(c.name in n))throw new Error(`missing value for component ${c.name}`);return n[c.name]})}if(a.length!==this.components.length)throw new Error("array is wrong length");a.forEach((c,l)=>{var u;xe(u=o[l],yr,Bs).call(u,e,c,r,d=>{a[l]=d})}),s(a);return}const i=r(this.type,n);i.then?e.push(async function(){s(await i)}()):s(i)};let Ne=ht;class er{constructor(e,n,r){Z(this,"type");Z(this,"inputs");li(e,Ce,"Fragment"),r=Object.freeze(r.slice()),_e(this,{type:n,inputs:r})}static from(e){if(typeof e=="string"){try{er.from(JSON.parse(e))}catch{}return er.from(On(e))}if(e instanceof At)switch(e.peekKeyword(su)){case"constructor":return an.from(e);case"error":return tt.from(e);case"event":return Vt.from(e);case"fallback":case"receive":return en.from(e);case"function":return Ft.from(e);case"struct":return Yn.from(e)}else if(typeof e=="object"){switch(e.type){case"constructor":return an.from(e);case"error":return tt.from(e);case"event":return Vt.from(e);case"fallback":case"receive":return en.from(e);case"function":return Ft.from(e);case"struct":return Yn.from(e)}Ae(!1,`unsupported type: ${e.type}`,"UNSUPPORTED_OPERATION",{operation:"Fragment.from"})}z(!1,"unsupported frgament object","obj",e)}static isConstructor(e){return an.isFragment(e)}static isError(e){return tt.isFragment(e)}static isEvent(e){return Vt.isFragment(e)}static isFunction(e){return Ft.isFragment(e)}static isStruct(e){return Yn.isFragment(e)}}class mi extends er{constructor(n,r,s,i){super(n,r,i);Z(this,"name");z(typeof s=="string"&&s.match(ou),"invalid identifier","name",s),i=Object.freeze(i.slice()),_e(this,{name:s})}}function rs(t,e){return"("+e.map(n=>n.format(t)).join(t==="full"?", ":",")+")"}class tt extends mi{constructor(e,n,r){super(e,"error",n,r),Object.defineProperty(this,rt,{value:nc})}get selector(){return ns(this.format("sighash")).substring(0,10)}format(e){if(e==null&&(e="sighash"),e==="json")return JSON.stringify({type:"error",name:this.name,inputs:this.inputs.map(r=>JSON.parse(r.format(e)))});const n=[];return e!=="sighash"&&n.push("error"),n.push(this.name+rs(e,this.inputs)),n.join(" ")}static from(e){if(tt.isFragment(e))return e;if(typeof e=="string")return tt.from(On(e));if(e instanceof At){const n=gi("error",e),r=dn(e);return Qn(e),new tt(Ce,n,r)}return new tt(Ce,e.name,e.inputs?e.inputs.map(Ne.from):[])}static isFragment(e){return e&&e[rt]===nc}}class Vt extends mi{constructor(n,r,s,i){super(n,"event",r,s);Z(this,"anonymous");Object.defineProperty(this,rt,{value:rc}),_e(this,{anonymous:i})}get topicHash(){return ns(this.format("sighash"))}format(n){if(n==null&&(n="sighash"),n==="json")return JSON.stringify({type:"event",anonymous:this.anonymous,name:this.name,inputs:this.inputs.map(s=>JSON.parse(s.format(n)))});const r=[];return n!=="sighash"&&r.push("event"),r.push(this.name+rs(n,this.inputs)),n!=="sighash"&&this.anonymous&&r.push("anonymous"),r.join(" ")}static getTopicHash(n,r){return r=(r||[]).map(i=>Ne.from(i)),new Vt(Ce,n,r,!1).topicHash}static from(n){if(Vt.isFragment(n))return n;if(typeof n=="string")try{return Vt.from(On(n))}catch{z(!1,"invalid event fragment","obj",n)}else if(n instanceof At){const r=gi("event",n),s=dn(n,!0),i=!!mn(n,Je(["anonymous"])).has("anonymous");return Qn(n),new Vt(Ce,r,s,i)}return new Vt(Ce,n.name,n.inputs?n.inputs.map(r=>Ne.from(r,!0)):[],!!n.anonymous)}static isFragment(n){return n&&n[rt]===rc}}class an extends er{constructor(n,r,s,i,o){super(n,r,s);Z(this,"payable");Z(this,"gas");Object.defineProperty(this,rt,{value:sc}),_e(this,{payable:i,gas:o})}format(n){if(Ae(n!=null&&n!=="sighash","cannot format a constructor for sighash","UNSUPPORTED_OPERATION",{operation:"format(sighash)"}),n==="json")return JSON.stringify({type:"constructor",stateMutability:this.payable?"payable":"undefined",payable:this.payable,gas:this.gas!=null?this.gas:void 0,inputs:this.inputs.map(s=>JSON.parse(s.format(n)))});const r=[`constructor${rs(n,this.inputs)}`];return this.payable&&r.push("payable"),this.gas!=null&&r.push(`@${this.gas.toString()}`),r.join(" ")}static from(n){if(an.isFragment(n))return n;if(typeof n=="string")try{return an.from(On(n))}catch{z(!1,"invalid constuctor fragment","obj",n)}else if(n instanceof At){mn(n,Je(["constructor"]));const r=dn(n),s=!!mn(n,om).has("payable"),i=lu(n);return Qn(n),new an(Ce,"constructor",r,s,i)}return new an(Ce,"constructor",n.inputs?n.inputs.map(Ne.from):[],!!n.payable,n.gas!=null?n.gas:null)}static isFragment(n){return n&&n[rt]===sc}}class en extends er{constructor(n,r,s){super(n,"fallback",r);Z(this,"payable");Object.defineProperty(this,rt,{value:ic}),_e(this,{payable:s})}format(n){const r=this.inputs.length===0?"receive":"fallback";if(n==="json"){const s=this.payable?"payable":"nonpayable";return JSON.stringify({type:r,stateMutability:s})}return`${r}()${this.payable?" payable":""}`}static from(n){if(en.isFragment(n))return n;if(typeof n=="string")try{return en.from(On(n))}catch{z(!1,"invalid fallback fragment","obj",n)}else if(n instanceof At){const r=n.toString(),s=n.peekKeyword(Je(["fallback","receive"]));if(z(s,"type must be fallback or receive","obj",r),n.popKeyword(Je(["fallback","receive"]))==="receive"){const c=dn(n);return z(c.length===0,"receive cannot have arguments","obj.inputs",c),mn(n,Je(["payable"])),Qn(n),new en(Ce,[],!0)}let o=dn(n);o.length?z(o.length===1&&o[0].type==="bytes","invalid fallback inputs","obj.inputs",o.map(c=>c.format("minimal")).join(", ")):o=[Ne.from("bytes")];const a=cu(n);if(z(a==="nonpayable"||a==="payable","fallback cannot be constants","obj.stateMutability",a),mn(n,Je(["returns"])).has("returns")){const c=dn(n);z(c.length===1&&c[0].type==="bytes","invalid fallback outputs","obj.outputs",c.map(l=>l.format("minimal")).join(", "))}return Qn(n),new en(Ce,o,a==="payable")}if(n.type==="receive")return new en(Ce,[],!0);if(n.type==="fallback"){const r=[Ne.from("bytes")],s=n.stateMutability==="payable";return new en(Ce,r,s)}z(!1,"invalid fallback description","obj",n)}static isFragment(n){return n&&n[rt]===ic}}class Ft extends mi{constructor(n,r,s,i,o,a){super(n,"function",r,i);Z(this,"constant");Z(this,"outputs");Z(this,"stateMutability");Z(this,"payable");Z(this,"gas");Object.defineProperty(this,rt,{value:oc}),o=Object.freeze(o.slice()),_e(this,{constant:s==="view"||s==="pure",gas:a,outputs:o,payable:s==="payable",stateMutability:s})}get selector(){return ns(this.format("sighash")).substring(0,10)}format(n){if(n==null&&(n="sighash"),n==="json")return JSON.stringify({type:"function",name:this.name,constant:this.constant,stateMutability:this.stateMutability!=="nonpayable"?this.stateMutability:void 0,payable:this.payable,gas:this.gas!=null?this.gas:void 0,inputs:this.inputs.map(s=>JSON.parse(s.format(n))),outputs:this.outputs.map(s=>JSON.parse(s.format(n)))});const r=[];return n!=="sighash"&&r.push("function"),r.push(this.name+rs(n,this.inputs)),n!=="sighash"&&(this.stateMutability!=="nonpayable"&&r.push(this.stateMutability),this.outputs&&this.outputs.length&&(r.push("returns"),r.push(rs(n,this.outputs))),this.gas!=null&&r.push(`@${this.gas.toString()}`)),r.join(" ")}static getSelector(n,r){return r=(r||[]).map(i=>Ne.from(i)),new Ft(Ce,n,"view",r,[],null).selector}static from(n){if(Ft.isFragment(n))return n;if(typeof n=="string")try{return Ft.from(On(n))}catch{z(!1,"invalid function fragment","obj",n)}else if(n instanceof At){const s=gi("function",n),i=dn(n),o=cu(n);let a=[];mn(n,Je(["returns"])).has("returns")&&(a=dn(n));const c=lu(n);return Qn(n),new Ft(Ce,s,o,i,a,c)}let r=n.stateMutability;return r==null&&(r="payable",typeof n.constant=="boolean"?(r="view",n.constant||(r="payable",typeof n.payable=="boolean"&&!n.payable&&(r="nonpayable"))):typeof n.payable=="boolean"&&!n.payable&&(r="nonpayable")),new Ft(Ce,n.name,r,n.inputs?n.inputs.map(Ne.from):[],n.outputs?n.outputs.map(Ne.from):[],n.gas!=null?n.gas:null)}static isFragment(n){return n&&n[rt]===oc}}class Yn extends mi{constructor(e,n,r){super(e,"struct",n,r),Object.defineProperty(this,rt,{value:ac})}format(){throw new Error("@TODO")}static from(e){if(typeof e=="string")try{return Yn.from(On(e))}catch{z(!1,"invalid struct fragment","obj",e)}else if(e instanceof At){const n=gi("struct",e),r=dn(e);return Qn(e),new Yn(Ce,n,r)}return new Yn(Ce,e.name,e.inputs?e.inputs.map(Ne.from):[])}static isFragment(e){return e&&e[rt]===ac}}const Tt=new Map;Tt.set(0,"GENERIC_PANIC");Tt.set(1,"ASSERT_FALSE");Tt.set(17,"OVERFLOW");Tt.set(18,"DIVIDE_BY_ZERO");Tt.set(33,"ENUM_RANGE_ERROR");Tt.set(34,"BAD_STORAGE_DATA");Tt.set(49,"STACK_UNDERFLOW");Tt.set(50,"ARRAY_RANGE_ERROR");Tt.set(65,"OUT_OF_MEMORY");Tt.set(81,"UNINITIALIZED_FUNCTION_CALL");const ym=new RegExp(/^bytes([0-9]*)$/),bm=new RegExp(/^(u?int)([0-9]*)$/);let Pi=null,cc=1024;function wm(t,e,n,r){let s="missing revert data",i=null;const o=null;let a=null;if(n){s="execution reverted";const l=We(n);if(n=fe(n),l.length===0)s+=" (no data present; likely require(false) occurred",i="require(false)";else if(l.length%32!==4)s+=" (could not decode reason; invalid data length)";else if(fe(l.slice(0,4))==="0x08c379a0")try{i=r.decode(["string"],l.slice(4))[0],a={signature:"Error(string)",name:"Error",args:[i]},s+=`: ${JSON.stringify(i)}`}catch{s+=" (could not decode reason; invalid string data)"}else if(fe(l.slice(0,4))==="0x4e487b71")try{const u=Number(r.decode(["uint256"],l.slice(4))[0]);a={signature:"Panic(uint256)",name:"Panic",args:[u]},i=`Panic due to ${Tt.get(u)||"UNKNOWN"}(${u})`,s+=`: ${i}`}catch{s+=" (could not decode panic code)"}else s+=" (unknown custom error)"}const c={to:e.to?Ar(e.to):null,data:e.data||"0x"};return e.from&&(c.from=Ar(e.from)),El(s,"CALL_EXCEPTION",{action:t,data:n,reason:i,transaction:c,invocation:o,revert:a})}var Tn,or;const Gs=class Gs{constructor(){he(this,Tn)}getDefaultValue(e){const n=e.map(s=>xe(this,Tn,or).call(this,Ne.from(s)));return new _s(n,"_").defaultValue()}encode(e,n){kl(n.length,e.length,"types/values length mismatch");const r=e.map(o=>xe(this,Tn,or).call(this,Ne.from(o))),s=new _s(r,"_"),i=new Ji;return s.encode(i,n),i.data}decode(e,n,r){const s=e.map(o=>xe(this,Tn,or).call(this,Ne.from(o)));return new _s(s,"_").decode(new Yi(n,r,cc))}static _setDefaultMaxInflation(e){z(typeof e=="number"&&Number.isInteger(e),"invalid defaultMaxInflation factor","value",e),cc=e}static defaultAbiCoder(){return Pi==null&&(Pi=new Gs),Pi}static getBuiltinCallException(e,n,r){return wm(e,n,r,Gs.defaultAbiCoder())}};Tn=new WeakSet,or=function(e){if(e.isArray())return new jg(xe(this,Tn,or).call(this,e.arrayChildren),e.arrayLength,e.name);if(e.isTuple())return new _s(e.components.map(r=>xe(this,Tn,or).call(this,r)),e.name);switch(e.baseType){case"address":return new Gg(e.name);case"bool":return new Xg(e.name);case"string":return new sm(e.name);case"bytes":return new Jg(e.name);case"":return new Qg(e.name)}let n=e.type.match(bm);if(n){let r=parseInt(n[2]||"256");return z(r!==0&&r<=256&&r%8===0,"invalid "+n[1]+" bit length","param",e),new rm(r/8,n[1]==="int",e.name)}if(n=e.type.match(ym),n){let r=parseInt(n[1]);return z(r!==0&&r<=32,"invalid bytes length","param",e),new Yg(r,e.name)}z(!1,"invalid type","type",e.type)};let Tr=Gs;class vm{constructor(e,n,r){Z(this,"fragment");Z(this,"name");Z(this,"signature");Z(this,"topic");Z(this,"args");const s=e.name,i=e.format();_e(this,{fragment:e,name:s,signature:i,topic:n,args:r})}}class _m{constructor(e,n,r,s){Z(this,"fragment");Z(this,"name");Z(this,"args");Z(this,"signature");Z(this,"selector");Z(this,"value");const i=e.name,o=e.format();_e(this,{fragment:e,name:i,args:r,signature:o,selector:n,value:s})}}class xm{constructor(e,n,r){Z(this,"fragment");Z(this,"name");Z(this,"args");Z(this,"signature");Z(this,"selector");const s=e.name,i=e.format();_e(this,{fragment:e,name:s,args:r,signature:i,selector:n})}}class lc{constructor(e){Z(this,"hash");Z(this,"_isIndexed");_e(this,{hash:e,_isIndexed:!0})}static isIndexed(e){return!!(e&&e._isIndexed)}}const uc={0:"generic panic",1:"assert(false)",17:"arithmetic overflow",18:"division or modulo by zero",33:"enum overflow",34:"invalid encoded storage byte array accessed",49:"out-of-bounds array access; popping on an empty array",50:"out-of-bounds access of an array or bytesN",65:"out of memory",81:"uninitialized function"},dc={"0x08c379a0":{signature:"Error(string)",name:"Error",inputs:["string"],reason:t=>`reverted with reason string ${JSON.stringify(t)}`},"0x4e487b71":{signature:"Panic(uint256)",name:"Panic",inputs:["uint256"],reason:t=>{let e="unknown panic code";return t>=0&&t<=255&&uc[t.toString()]&&(e=uc[t.toString()]),`reverted with panic code 0x${t.toString(16)} (${e})`}}};var Nt,Mt,Ut,He,zt,Is,Os;const Vn=class Vn{constructor(e){he(this,zt);Z(this,"fragments");Z(this,"deploy");Z(this,"fallback");Z(this,"receive");he(this,Nt);he(this,Mt);he(this,Ut);he(this,He);let n=[];typeof e=="string"?n=JSON.parse(e):n=e,oe(this,Ut,new Map),oe(this,Nt,new Map),oe(this,Mt,new Map);const r=[];for(const o of n)try{r.push(er.from(o))}catch(a){console.log(`[Warning] Invalid Fragment ${JSON.stringify(o)}:`,a.message)}_e(this,{fragments:Object.freeze(r)});let s=null,i=!1;oe(this,He,this.getAbiCoder()),this.fragments.forEach((o,a)=>{let c;switch(o.type){case"constructor":if(this.deploy){console.log("duplicate definition - constructor");return}_e(this,{deploy:o});return;case"fallback":o.inputs.length===0?i=!0:(z(!s||o.payable!==s.payable,"conflicting fallback fragments",`fragments[${a}]`,o),s=o,i=s.payable);return;case"function":c=N(this,Ut);break;case"event":c=N(this,Mt);break;case"error":c=N(this,Nt);break;default:return}const l=o.format();c.has(l)||c.set(l,o)}),this.deploy||_e(this,{deploy:an.from("constructor()")}),_e(this,{fallback:s,receive:i})}format(e){const n=e?"minimal":"full";return this.fragments.map(s=>s.format(n))}formatJson(){const e=this.fragments.map(n=>n.format("json"));return JSON.stringify(e.map(n=>JSON.parse(n)))}getAbiCoder(){return Tr.defaultAbiCoder()}getFunctionName(e){const n=xe(this,zt,Is).call(this,e,null,!1);return z(n,"no matching function","key",e),n.name}hasFunction(e){return!!xe(this,zt,Is).call(this,e,null,!1)}getFunction(e,n){return xe(this,zt,Is).call(this,e,n||null,!0)}forEachFunction(e){const n=Array.from(N(this,Ut).keys());n.sort((r,s)=>r.localeCompare(s));for(let r=0;r<n.length;r++){const s=n[r];e(N(this,Ut).get(s),r)}}getEventName(e){const n=xe(this,zt,Os).call(this,e,null,!1);return z(n,"no matching event","key",e),n.name}hasEvent(e){return!!xe(this,zt,Os).call(this,e,null,!1)}getEvent(e,n){return xe(this,zt,Os).call(this,e,n||null,!0)}forEachEvent(e){const n=Array.from(N(this,Mt).keys());n.sort((r,s)=>r.localeCompare(s));for(let r=0;r<n.length;r++){const s=n[r];e(N(this,Mt).get(s),r)}}getError(e,n){if(Fn(e)){const s=e.toLowerCase();if(dc[s])return tt.from(dc[s].signature);for(const i of N(this,Nt).values())if(s===i.selector)return i;return null}if(e.indexOf("(")===-1){const s=[];for(const[i,o]of N(this,Nt))i.split("(")[0]===e&&s.push(o);if(s.length===0)return e==="Error"?tt.from("error Error(string)"):e==="Panic"?tt.from("error Panic(uint256)"):null;if(s.length>1){const i=s.map(o=>JSON.stringify(o.format())).join(", ");z(!1,`ambiguous error description (i.e. ${i})`,"name",e)}return s[0]}if(e=tt.from(e).format(),e==="Error(string)")return tt.from("error Error(string)");if(e==="Panic(uint256)")return tt.from("error Panic(uint256)");const r=N(this,Nt).get(e);return r||null}forEachError(e){const n=Array.from(N(this,Nt).keys());n.sort((r,s)=>r.localeCompare(s));for(let r=0;r<n.length;r++){const s=n[r];e(N(this,Nt).get(s),r)}}_decodeParams(e,n){return N(this,He).decode(e,n)}_encodeParams(e,n){return N(this,He).encode(e,n)}encodeDeploy(e){return this._encodeParams(this.deploy.inputs,e||[])}decodeErrorResult(e,n){if(typeof e=="string"){const r=this.getError(e);z(r,"unknown error","fragment",e),e=r}return z(sr(n,0,4)===e.selector,`data signature does not match error ${e.name}.`,"data",n),this._decodeParams(e.inputs,sr(n,4))}encodeErrorResult(e,n){if(typeof e=="string"){const r=this.getError(e);z(r,"unknown error","fragment",e),e=r}return un([e.selector,this._encodeParams(e.inputs,n||[])])}decodeFunctionData(e,n){if(typeof e=="string"){const r=this.getFunction(e);z(r,"unknown function","fragment",e),e=r}return z(sr(n,0,4)===e.selector,`data signature does not match function ${e.name}.`,"data",n),this._decodeParams(e.inputs,sr(n,4))}encodeFunctionData(e,n){if(typeof e=="string"){const r=this.getFunction(e);z(r,"unknown function","fragment",e),e=r}return un([e.selector,this._encodeParams(e.inputs,n||[])])}decodeFunctionResult(e,n){if(typeof e=="string"){const i=this.getFunction(e);z(i,"unknown function","fragment",e),e=i}let r="invalid length for result data";const s=je(n);if(s.length%32===0)try{return N(this,He).decode(e.outputs,s)}catch{r="could not decode result data"}Ae(!1,r,"BAD_DATA",{value:fe(s),info:{method:e.name,signature:e.format()}})}makeError(e,n){const r=We(e,"data"),s=Tr.getBuiltinCallException("call",n,r);if(s.message.startsWith("execution reverted (unknown custom error)")){const a=fe(r.slice(0,4)),c=this.getError(a);if(c)try{const l=N(this,He).decode(c.inputs,r.slice(4));s.revert={name:c.name,signature:c.format(),args:l},s.reason=s.revert.signature,s.message=`execution reverted: ${s.reason}`}catch{s.message="execution reverted (coult not decode custom error)"}}const o=this.parseTransaction(n);return o&&(s.invocation={method:o.name,signature:o.signature,args:o.args}),s}encodeFunctionResult(e,n){if(typeof e=="string"){const r=this.getFunction(e);z(r,"unknown function","fragment",e),e=r}return fe(N(this,He).encode(e.outputs,n||[]))}encodeFilterTopics(e,n){if(typeof e=="string"){const i=this.getEvent(e);z(i,"unknown event","eventFragment",e),e=i}Ae(n.length<=e.inputs.length,`too many arguments for ${e.format()}`,"UNEXPECTED_ARGUMENT",{count:n.length,expectedCount:e.inputs.length});const r=[];e.anonymous||r.push(e.topicHash);const s=(i,o)=>i.type==="string"?ns(o):i.type==="bytes"?jt(fe(o)):(i.type==="bool"&&typeof o=="boolean"?o=o?"0x01":"0x00":i.type.match(/^u?int/)?o=Fs(o):i.type.match(/^bytes/)?o=kp(o,32):i.type==="address"&&N(this,He).encode(["address"],[o]),Dl(fe(o),32));for(n.forEach((i,o)=>{const a=e.inputs[o];if(!a.indexed){z(i==null,"cannot filter non-indexed parameters; must be null","contract."+a.name,i);return}i==null?r.push(null):a.baseType==="array"||a.baseType==="tuple"?z(!1,"filtering with tuples or arrays not supported","contract."+a.name,i):Array.isArray(i)?r.push(i.map(c=>s(a,c))):r.push(s(a,i))});r.length&&r[r.length-1]===null;)r.pop();return r}encodeEventLog(e,n){if(typeof e=="string"){const o=this.getEvent(e);z(o,"unknown event","eventFragment",e),e=o}const r=[],s=[],i=[];return e.anonymous||r.push(e.topicHash),z(n.length===e.inputs.length,"event arguments/values mismatch","values",n),e.inputs.forEach((o,a)=>{const c=n[a];if(o.indexed)if(o.type==="string")r.push(ns(c));else if(o.type==="bytes")r.push(jt(c));else{if(o.baseType==="tuple"||o.baseType==="array")throw new Error("not implemented");r.push(N(this,He).encode([o.type],[c]))}else s.push(o),i.push(c)}),{data:N(this,He).encode(s,i),topics:r}}decodeEventLog(e,n,r){if(typeof e=="string"){const m=this.getEvent(e);z(m,"unknown event","eventFragment",e),e=m}if(r!=null&&!e.anonymous){const m=e.topicHash;z(Fn(r[0],32)&&r[0].toLowerCase()===m,"fragment/topic mismatch","topics[0]",r[0]),r=r.slice(1)}const s=[],i=[],o=[];e.inputs.forEach((m,S)=>{m.indexed?m.type==="string"||m.type==="bytes"||m.baseType==="tuple"||m.baseType==="array"?(s.push(Ne.from({type:"bytes32",name:m.name})),o.push(!0)):(s.push(m),o.push(!1)):(i.push(m),o.push(!1))});const a=r!=null?N(this,He).decode(s,un(r)):null,c=N(this,He).decode(i,n,!0),l=[],u=[];let d=0,w=0;return e.inputs.forEach((m,S)=>{let h=null;if(m.indexed)if(a==null)h=new lc(null);else if(o[S])h=new lc(a[w++]);else try{h=a[w++]}catch(D){h=D}else try{h=c[d++]}catch(D){h=D}l.push(h),u.push(m.name||null)}),Cr.fromItems(l,u)}parseTransaction(e){const n=We(e.data,"tx.data"),r=qt(e.value!=null?e.value:0,"tx.value"),s=this.getFunction(fe(n.slice(0,4)));if(!s)return null;const i=N(this,He).decode(s.inputs,n.slice(4));return new _m(s,s.selector,i,r)}parseCallResult(e){throw new Error("@TODO")}parseLog(e){const n=this.getEvent(e.topics[0]);return!n||n.anonymous?null:new vm(n,n.topicHash,this.decodeEventLog(n,e.data,e.topics))}parseError(e){const n=fe(e),r=this.getError(sr(n,0,4));if(!r)return null;const s=N(this,He).decode(r.inputs,sr(n,4));return new xm(r,r.selector,s)}static from(e){return e instanceof Vn?e:typeof e=="string"?new Vn(JSON.parse(e)):typeof e.formatJson=="function"?new Vn(e.formatJson()):typeof e.format=="function"?new Vn(e.format("json")):new Vn(e)}};Nt=new WeakMap,Mt=new WeakMap,Ut=new WeakMap,He=new WeakMap,zt=new WeakSet,Is=function(e,n,r){if(Fn(e)){const i=e.toLowerCase();for(const o of N(this,Ut).values())if(i===o.selector)return o;return null}if(e.indexOf("(")===-1){const i=[];for(const[o,a]of N(this,Ut))o.split("(")[0]===e&&i.push(a);if(n){const o=n.length>0?n[n.length-1]:null;let a=n.length,c=!0;nt.isTyped(o)&&o.type==="overrides"&&(c=!1,a--);for(let l=i.length-1;l>=0;l--){const u=i[l].inputs.length;u!==a&&(!c||u!==a-1)&&i.splice(l,1)}for(let l=i.length-1;l>=0;l--){const u=i[l].inputs;for(let d=0;d<n.length;d++)if(nt.isTyped(n[d])){if(d>=u.length){if(n[d].type==="overrides")continue;i.splice(l,1);break}if(n[d].type!==u[d].baseType){i.splice(l,1);break}}}}if(i.length===1&&n&&n.length!==i[0].inputs.length){const o=n[n.length-1];(o==null||Array.isArray(o)||typeof o!="object")&&i.splice(0,1)}if(i.length===0)return null;if(i.length>1&&r){const o=i.map(a=>JSON.stringify(a.format())).join(", ");z(!1,`ambiguous function description (i.e. matches ${o})`,"key",e)}return i[0]}const s=N(this,Ut).get(Ft.from(e).format());return s||null},Os=function(e,n,r){if(Fn(e)){const i=e.toLowerCase();for(const o of N(this,Mt).values())if(i===o.topicHash)return o;return null}if(e.indexOf("(")===-1){const i=[];for(const[o,a]of N(this,Mt))o.split("(")[0]===e&&i.push(a);if(n){for(let o=i.length-1;o>=0;o--)i[o].inputs.length<n.length&&i.splice(o,1);for(let o=i.length-1;o>=0;o--){const a=i[o].inputs;for(let c=0;c<n.length;c++)if(nt.isTyped(n[c])&&n[c].type!==a[c].baseType){i.splice(o,1);break}}}if(i.length===0)return null;if(i.length>1&&r){const o=i.map(a=>JSON.stringify(a.format())).join(", ");z(!1,`ambiguous event description (i.e. matches ${o})`,"key",e)}return i[0]}const s=N(this,Mt).get(Vt.from(e).format());return s||null};let oo=Vn;function Cm(){ft();const t=Ue(),e=Be(),n=F({}),r=F({}),s=F(0),i=F("0xAb5801a7D398351b8bE11C439e05C5B9ebB6AA0c"),o=F(new Set),a={weapon:"0x1234567890123456789012345678901234567890",achievement:"0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"},c=F({weapon:{},achievement:{}}),l=(f,p)=>!f||!p?{success:!1,message:"❌ 请输入名称和头像！",hints:[],nextStep:"👉 填写名称和头像后点击保存",error:"EMPTY_INPUT"}:(n.value[i.value]={name:f,avatar:p},e.addLog(16,"设置资料",`名称: ${f}, 头像: ${p}`,"setProfile16"),{success:!0,message:"✅ 资料已保存！",hints:["mapping_storage"],nextStep:"🗺️ 你的资料已保存到 mapping！👉 注册 weapon 插件来学习插件系统！"}),u=f=>{const p=n.value[f];return e.addLog(16,"查询资料",`地址: ${I(f)}`),p||{name:"",avatar:""}},d=(f,p)=>{if(!f||!p)return{success:!1,message:"❌ 请输入插件标识符和地址！",hints:[],nextStep:"👉 填写插件标识符和合约地址",error:"EMPTY_INPUT"};if(r.value[f])return{success:!1,message:`❌ 插件 "${f}" 已存在！`,hints:[],nextStep:"👉 使用其他标识符或先注销现有插件",error:"PLUGIN_EXISTS"};r.value[f]=p,s.value++,e.addLog(16,"注册插件",`标识: ${f}, 地址: ${I(p)}`,"registerPlugin16");const v=["plugin_registration"];let k=`🔌 插件 "${f}" 注册成功！👉 点击「调用」执行插件函数！`;return s.value>=2&&(v.push("dynamic_delegation"),k="🔄 动态委托系统运行中！👉 在不同插件间切换体验互操作！"),{success:!0,message:`✅ 插件 "${f}" 注册成功！`,hints:v,nextStep:k,registeredAddress:p}},w=f=>r.value[f]||"",m=(f,p,v)=>{try{const k=f.split("(")[0],g=new oo([`function ${f}`]).getFunction(k).selector,T=new Tr,A=Ar(p),L=f.includes("string"),K=L?["address","string"]:["address"],ee=L?[A,v||""]:[A],M=T.encode(K,ee),O=g+M.slice(2),E=[{type:"selector",value:g,desc:"函数选择器 (4 bytes)",detail:`keccak256("${f}").slice(0,10)`},{type:"address",value:A,desc:"address 参数",detail:"zero-padded to 32 bytes"}];if(L){const $=v||"";E.push({type:"offset",value:"0x0000000000000000000000000000000000000000000000000000000000000040",desc:"string 偏移量 (64 bytes)"},{type:"length",value:"0x"+$.length.toString(16).padStart(64,"0"),desc:`string 长度 (${$.length})`},{type:"data",value:fe(di($)).slice(2).padEnd(64,"0"),desc:"string 数据 (padded)",detail:`"${$}"`})}return{selector:g,encodedParams:"0x"+M.slice(2),fullEncodedData:O,breakdown:E}}catch(k){return console.error("ABI编码错误:",k),console.error("参数:",{functionSignature:f,user:p,argument:v}),null}},S=(f,p,v,k)=>{if(!r.value[f])return{success:!1,message:`❌ 插件 "${f}" 未注册！`,hints:[],nextStep:`👉 先点击「插件管理中心」注册 ${f} 插件！`,error:"PLUGIN_NOT_REGISTERED"};const x=m(p,v,k);if(!x)return{success:!1,message:"❌ ABI编码失败！",hints:[],nextStep:"👉 检查函数签名格式，例如: setWeapon(address,string)",error:"ABI_ENCODE_FAILED"};if(Math.random()<.1)return{success:!1,message:"❌ 插件调用失败！（演示错误场景）",hints:[],nextStep:"👉 可能是 Gas 不足或函数 revert。检查参数是否满足插件要求。",error:"CALL_FAILED"};const g=p.split("(")[0];c.value[f]||(c.value[f]={}),c.value[f][v]=k,o.value.add(f),e.addLog(16,"执行插件",`插件: ${f}, 函数: ${g}, 参数: ${k}`,"runPlugin16");const T=["low_level_call","abi_encoding"];let A="⚡ 低级别调用成功！👉 查看 ABI 编码可视化或切换 staticcall 模式查询数据！";return o.value.size>=2&&(T.push("contract_interop"),A="🌐 合约互操作掌握！👉 查看完整代码了解所有实现细节！"),{success:!0,message:`✅ 调用 ${f}.${g} 成功！`,hints:T,nextStep:A,encoded:x.breakdown}},h=(f,p,v)=>{var g;if(!r.value[f])return{success:!1,message:`❌ 插件 "${f}" 未注册！`,hints:[],nextStep:`👉 先注册 ${f} 插件！`,error:"PLUGIN_NOT_REGISTERED"};const k=p.split("(")[0],x=((g=c.value[f])==null?void 0:g[v])||"";return e.addLog(16,"查询插件",`插件: ${f}, 函数: ${k}, 返回值: ${x||"(空)"}`),{success:!0,message:`✅ 查询 ${f}.${k} 成功！`,hints:["staticcall"],nextStep:x?`👁️ 返回值: "${x}" 👉 尝试切换到其他插件！`:"👁️ 查询成功但无数据 👉 先用 call 模式写入数据！",result:x}},D=(f,p)=>{var v;return((v=c.value[f])==null?void 0:v[p])||""},I=f=>!f||f.length<10?f:f.slice(0,6)+"..."+f.slice(-4),b=f=>{t.unlockConcept(16,f)},C=B(()=>({gasUsage:e.getDayGasUsage(16),ethCost:e.getDayEthCost(16),operationCount:e.getDayOperationCount(16)}));return{profiles:n,plugins:r,pluginCounter:s,currentUser:i,pluginData:c,interactedPlugins:o,predefinedPlugins:a,setProfile:l,getProfile:u,registerPlugin:d,getPlugin:w,runPlugin:S,runPluginView:h,getPluginData:D,encodeFunctionCall:m,unlockConcept:b,shortenAddress:I,realtimeData:C}}function Sm(){const t=ft(),e=Ue(),n=Be();t.contracts.day17;const r=F("owner"),s=F("V1"),i=F(!1),o=F(!1),a=F(!1),c=F([]),l=F(1),u=F(.1),d=F(30),w=F(1),m=F(null),S=F("0xV1LogicContractAddress"),h=F("0xOwnerAddress"),D=B(()=>c.value.length),I=B(()=>m.value?1:0),b=B(()=>m.value!==null),C=B(()=>{const E=c.value.find($=>$.id===w.value);return E?E.price:0}),f=B(()=>!m.value||!m.value.paused?0:m.value.expiry),p=B(()=>{if(!m.value)return"未订阅";if(m.value.paused)return"已暂停";const E=Math.floor(Date.now()/1e3);return m.value.expiry>E?"有效":"已过期"}),v=B(()=>{if(!m.value)return"status-inactive";if(m.value.paused)return"status-paused";const E=Math.floor(Date.now()/1e3);return m.value.expiry>E?"status-active":"status-expired"}),k=()=>{const E=l.value,$=parseFloat(u.value),Y=d.value*24*60*60;return c.value.find(ce=>ce.id===E)?{success:!1,message:"❌ 计划 ID 已存在",hints:[],nextStep:""}:(c.value.push({id:E,price:$,duration:Y,durationDays:d.value}),w.value=E,n.addLog(17,"创建计划",`计划 ${E}: ${$} ETH, ${d.value}天`,"createPlan17"),e.incrementInteraction(17),c.value.length===1?{success:!0,message:`✅ 计划 ${E} 创建成功！存储在 planPrices[${E}] 中！`,hints:[],nextStep:"📊 再创建 1 个计划即可解锁升级功能！👉 创建第2个计划！"}:{success:!0,message:`✅ 计划 ${E} 创建成功！`,hints:[],nextStep:'🎉 现在可以升级到 V2 了！👉 点击"升级到 V2"按钮，体验合约升级！'})},x=()=>i.value?{success:!1,message:"❌ 合约已经升级过了",hints:[],nextStep:""}:c.value.length<2?{success:!1,message:"❌ 需要至少 2 个计划才能升级",hints:[],nextStep:`💡 当前只有 ${c.value.length} 个计划，请再创建 ${2-c.value.length} 个！`}:(o.value=!0,setTimeout(()=>{i.value=!0,s.value="V2",S.value="0xV2LogicContractAddress",a.value=!0,o.value=!1,setTimeout(()=>{a.value=!1},3e3)},1e3),n.addLog(17,"升级合约","V1 → V2","upgradeTo17"),e.incrementInteraction(17),e.unlockConcept(17,"upgrade_mechanism"),e.unlockConcept(17,"logic_contract"),{success:!0,message:"🚀 合约已升级到 V2！逻辑合约地址已更新！",hints:["upgrade_mechanism","logic_contract"],nextStep:"⚡ 恭喜解锁：升级机制 + 逻辑合约！👉 切换到 User 身份，执行订阅操作！"}),g=()=>i.value?(s.value="V1",S.value="0xV1LogicContractAddress",{success:!0,message:"⚙️ 已切换到 V1 逻辑合约",hints:[],nextStep:""}):{success:!1,message:"❌ 合约尚未升级",hints:[],nextStep:""},T=()=>i.value?(s.value="V2",S.value="0xV2LogicContractAddress",{success:!0,message:"⚡ 已切换到 V2 逻辑合约",hints:[],nextStep:""}):{success:!1,message:"❌ 合约尚未升级",hints:[],nextStep:""},A=()=>{const E=w.value,$=c.value.find(pe=>pe.id===E);if(!$)return{success:!1,message:"❌ 计划不存在",hints:[],nextStep:""};const ne=Math.floor(Date.now()/1e3)+$.duration;return m.value={planId:E,expiry:ne,paused:!1},n.addLog(17,"订阅计划",`计划 ${E}: ${$.price} ETH`,"subscribe17"),e.incrementInteraction(17),e.getDayProgress(17).unlockedConcepts.includes("fallback_function")?{success:!0,message:`✅ 订阅成功！您已订阅计划 ${E}！`,hints:[],nextStep:""}:(e.unlockConcept(17,"fallback_function"),{success:!0,message:`✅ 订阅成功！您已订阅计划 ${E}！`,hints:["fallback_function"],nextStep:"🔒 恭喜解锁：回退函数！调用通过 fallback 委托给逻辑合约！👉 查询订阅状态，查看升级后数据是否仍然存在！"})},L=()=>{if(!m.value)return{success:!1,message:"❌ 您没有订阅",hints:[],nextStep:""};if(m.value.paused)return{success:!1,message:"❌ 订阅已经处于暂停状态",hints:[],nextStep:""};const E=Math.floor(Date.now()/1e3);if(m.value.expiry<=E)return{success:!1,message:"❌ 订阅已过期",hints:[],nextStep:""};const $=m.value.expiry-E;return m.value.paused=!0,m.value.expiry=$,n.addLog(17,"暂停订阅",`剩余时间: ${$} 秒`,"pauseSubscription17"),e.incrementInteraction(17),e.getDayProgress(17).unlockedConcepts.includes("version_control")?{success:!0,message:"⏸️ 订阅已暂停！剩余时间已保存！",hints:[],nextStep:""}:(e.unlockConcept(17,"version_control"),{success:!0,message:"⏸️ 订阅已暂停！剩余时间已保存！",hints:["version_control"],nextStep:"🚀 恭喜解锁：版本控制！这是 V2 新增的功能！👉 恢复订阅来完成所有学习！"})},K=()=>{if(!m.value)return{success:!1,message:"❌ 您没有订阅",hints:[],nextStep:""};if(!m.value.paused)return{success:!1,message:"❌ 订阅未处于暂停状态",hints:[],nextStep:""};const E=Math.floor(Date.now()/1e3),$=m.value.expiry;return m.value.paused=!1,m.value.expiry=E+$,n.addLog(17,"恢复订阅",`新的过期时间: ${m.value.expiry}`,"resumeSubscription17"),e.incrementInteraction(17),{success:!0,message:"▶️ 订阅已恢复！过期时间已重新计算！",hints:[],nextStep:"🎉 恭喜你已掌握 Day 17 全部核心功能！👉 查看完整代码来巩固知识！"}},ee=()=>{if(!m.value)return{success:!1,message:"❌ 您没有订阅",hints:[],nextStep:""};const E=Math.floor(Date.now()/1e3);let $="";if(m.value.paused)$=`已暂停，剩余 ${m.value.expiry} 秒`;else if(m.value.expiry>E){const ne=m.value.expiry-E;$=`有效，剩余 ${Math.floor(ne/86400)} 天 ${Math.floor(ne%86400/3600)} 小时`}else $="已过期";n.addLog(17,"查询订阅",`计划 ${m.value.planId}: ${$}`,null),e.incrementInteraction(17);const Y=e.getDayProgress(17).unlockedConcepts;return i.value&&!Y.includes("data_persistence")?(e.unlockConcept(17,"data_persistence"),{success:!0,message:`📊 您的订阅状态: ${$}`,hints:["data_persistence"],nextStep:"🏗️ 恭喜解锁：数据持久化！升级后数据保持不变！👉 使用 V2 新功能（暂停/恢复）来对比版本差异！"}):{success:!0,message:`📊 您的订阅状态: ${$}`,hints:[],nextStep:""}},M=E=>(r.value=E,E==="owner"?{success:!0,message:"✅ 已切换到 Owner 身份！",hints:[],nextStep:"👉 创建订阅计划来体验数据存储！"}:{success:!0,message:"✅ 已切换到 User 身份！",hints:[],nextStep:"👉 选择计划并执行订阅，体验 fallback 委托调用！"}),O=B(()=>({gasUsage:n.getDayGasUsage(17),ethCost:n.getDayEthCost(17),operationCount:n.getDayOperationCount(17)}));return{currentRole:r,currentVersion:s,upgraded:i,isUpgrading:o,justUpgraded:a,plans:c,newPlanId:l,newPlanPrice:u,newPlanDuration:d,selectedPlanId:w,subscription:m,logicContractAddress:S,ownerAddress:h,plansCount:D,subscriptionsCount:I,hasSubscription:b,selectedPlanPrice:C,remainingTime:f,subscriptionStatusText:p,subscriptionStatusClass:v,createPlan:k,upgradeToV2:x,switchToV1:g,switchToV2:T,subscribe:A,pauseSubscription:L,resumeSubscription:K,checkSubscription:ee,switchRole:M,realtimeData:O}}function Em(){const t=Be();Ue();const e=F("Alice"),n=F("farmer"),r=F(3e11),s=F(350),i=F({Alice:!1,Bob:!1,Carol:!1}),o=F({Alice:0,Bob:0,Carol:0}),a=F(5e18),c=F(0),l=F(0),u=500,d=10,w=50,m=24*60*60*1e3,S=B(()=>d*1e26/r.value),h=B(()=>w*1e26/r.value),D=B(()=>s.value<u),I=B(()=>{const E=e.value,$=o.value[E]||0,Y=Date.now();return i.value[E]&&Y-$>=m}),b=B(()=>{const E=e.value,$=o.value[E]||0,Y=Date.now(),ne=m-(Y-$);return ne>0?ne:0}),C=B(()=>i.value[e.value]?I.value?{status:"available",text:"可索赔"}:{status:"cooldown",text:"冷却中"}:{status:"no_insurance",text:"未投保"}),f=E=>(E/1e18).toFixed(4),p=E=>(E/1e8).toFixed(2),v=E=>{if(E<=0)return"00:00:00";const $=Math.floor(E/(1e3*60*60)),Y=Math.floor(E%(1e3*60*60)/(1e3*60)),ne=Math.floor(E%(1e3*60)/1e3);return`${$.toString().padStart(2,"0")}:${Y.toString().padStart(2,"0")}:${ne.toString().padStart(2,"0")}`},k=()=>(s.value=Math.floor(Math.random()*1e3),t.addLog(18,"更新天气数据",`降雨量更新为 ${s.value}mm`,"checkRainfall18"),{success:!0,message:`🌧️ 天气数据已更新！当前降雨量: ${s.value}mm`,rainfall:s.value,hints:["random_generation"],nextStep:D.value?"⚠️ 干旱警报！降雨量低于阈值，可以申请赔付。":"✅ 天气正常，降雨量高于阈值。"}),x=()=>(t.addLog(18,"查询天气数据",`当前降雨量: ${s.value}mm`,"checkRainfall18"),{success:!0,message:`🔍 查询结果：当前降雨量 ${s.value}mm，阈值 ${u}mm`,rainfall:s.value,isDrought:D.value,nextStep:D.value?"⚠️ 干旱状态！符合索赔条件。":"✅ 正常状态，不符合索赔条件。"}),g=()=>{const E=e.value;if(i.value[E])return{success:!1,message:"❌ 您已经购买了保险！"};const $=S.value;return i.value[E]=!0,l.value+=$,a.value+=$,t.addLog(18,"购买保险",`支付保费 ${f($)} ETH`,"purchaseInsurance18"),{success:!0,message:`🎉 保险购买成功！支付保费 ${f($)} ETH ($${d})`,hints:["purchase_insurance","price_conversion"],nextStep:"👉 当降雨量低于500mm时，可以申请赔付。注意：24小时内只能索赔一次！"}},T=()=>{const E=e.value;if(!i.value[E])return{success:!1,message:"❌ 您尚未购买保险！请先购买保险。",nextStep:'👉 点击"购买保险"按钮购买保险。'};if(!D.value)return{success:!1,message:`❌ 当前降雨量 ${s.value}mm 高于阈值 ${u}mm，不符合索赔条件。`,nextStep:"👉 等待干旱发生或更新天气数据。"};const $=o.value[E]||0,Y=Date.now();if(Y-$<m){const ce=m-(Y-$);return{success:!1,message:`⏱️ 冷却期中！剩余时间: ${v(ce)}`,hints:["cooldown_mechanism"],nextStep:'👉 使用"⏩ 快进24小时"按钮跳过冷却期，或等待时间结束。'}}const ne=h.value;return a.value<ne?{success:!1,message:"❌ 合约余额不足，无法赔付！"}:(o.value[E]=Y,c.value+=ne,a.value-=ne,t.addLog(18,"申请赔付",`获得赔付 ${f(ne)} ETH`,"claimPayout18"),{success:!0,message:`💸 赔付成功！获得 ${f(ne)} ETH ($${w})`,hints:["parametric_payout"],nextStep:'⏱️ 已触发24小时冷却期！点击"了解冷却期机制"学习更多。'})},A=()=>{const E=e.value,$=o.value[E]||0;return $===0?{success:!1,message:"❌ 您还没有进行过索赔！"}:I.value?{success:!1,message:"✅ 您已经可以索赔了，无需快进！"}:(o.value[E]=$-m,t.addLog(18,"快进时间","跳过24小时冷却期","fastForwardTime18"),{success:!0,message:"⏩ 时间已快进24小时！冷却期已结束。",hints:["cooldown_mechanism"],nextStep:"👉 现在可以再次申请赔付了！"})},L=()=>{if(n.value!=="admin")return{success:!1,message:"❌ 只有管理员可以提取余额！"};const E=a.value;return a.value=0,t.addLog(18,"提取余额",`提取 ${f(E)} ETH`,"withdrawBalance18"),{success:!0,message:`💸 提取成功！共提取 ${f(E)} ETH`,hints:["contract_balance"],nextStep:"👉 合约余额已清零。"}},K=E=>{e.value=E,n.value="farmer"},ee=()=>{n.value="admin",e.value="Owner"},M=()=>{const E=.95+Math.random()*.1;return r.value=Math.floor(3e11*E),{success:!0,message:`💰 ETH价格已更新！当前价格: $${p(r.value)}`}},O=B(()=>({gasUsage:t.getDayGasUsage(18),ethCost:t.getDayEthCost(18),operationCount:t.getDayOperationCount(18)}));return{currentUser:e,currentRole:n,ethPrice:r,rainfall:s,hasInsurance:i,lastClaimTimestamp:o,contractBalance:a,totalPayout:c,totalPremium:l,RAINFALL_THRESHOLD:u,INSURANCE_PREMIUM_USD:d,INSURANCE_PAYOUT_USD:w,premiumInEth:S,payoutInEth:h,isDrought:D,canClaim:I,cooldownRemaining:b,cooldownStatus:C,formatEth:f,formatUsd:p,formatTime:v,updateRainfall:k,checkRainfall:x,purchaseInsurance:g,claimPayout:T,fastForwardTime:A,withdrawBalance:L,switchUser:K,switchToAdmin:ee,updateEthPrice:M,realtimeData:O}}function km(){const t=Be();Ue();const e="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",n="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",r=F("organizer"),s=F("0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc"),i=F({"0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc":!1,"0x976EA74026E726554dB657fA54763abd0C3a0aa9":!1,"0x14dC79964da2C08b23698B3d3cc7Ca32193d9955":!1}),o=F(null),a=F(!1),c=B(()=>n),l=B(()=>s.value),u=B(()=>i.value[s.value]||!1),d=B(()=>Object.entries(i.value).filter(([p,v])=>v).map(([p])=>p)),w=p=>p?p.substring(0,6)+"..."+p.substring(p.length-4):"",m=()=>{try{const p=s.value,v=Ar(p),x=new Tr().encode(["address"],[v]),g=jt(x),A=jt(di(`Ethereum Signed Message:
32`+g.slice(2))),K=new so(e).sign(A);return o.value={r:K.r,s:K.s,v:K.v,full:K.serialized,messageHash:g,ethSignedMessageHash:A},t.addLog(19,"生成签名",`为用户 ${w(p)} 生成签名`,"generateSignature19"),{success:!0,message:`✅ 签名生成成功！
签名: ${K.serialized.substring(0,20)}...`,signature:K.serialized,hints:["keccak256_hash","msg_sender"],nextStep:"👉 点击展开签名详情，查看 R/S/V 组件！"}}catch(p){return{success:!1,message:`❌ 签名生成失败: ${p.message}`}}},S=()=>{const p=s.value;return o.value?i.value[p]?{success:!1,message:"❌ 你已经参与过此活动！"}:(i.value[p]=!0,t.addLog(19,"参与活动",`用户 ${w(p)} 使用签名参与活动`,"enterEvent19"),{success:!0,message:`🎉 参与成功！
你已使用签名成功参与活动！`,hints:["ecrecover","require_statement","eip191_prefix"],nextStep:"👉 点击参与者列表查看映射存储，完成所有概念解锁！"}):{success:!1,message:"❌ 请先生成签名！"}},h=()=>{const p=s.value,v=i.value[p]||!1;return t.addLog(19,"查询参与状态",`查询用户 ${w(p)} 参与状态: ${v}`,"checkEntered19"),{success:!0,message:v?"✅ 该用户已参与活动":"❌ 该用户尚未参与活动",entered:v}},D=()=>{const p=d.value;return t.addLog(19,"获取参与者列表",`当前参与者数量: ${p.length}`,"getParticipants19"),{success:!0,message:`📋 当前参与者数量: ${p.length}`,participants:p,hints:["mapping_storage"],nextStep:"🎉 你已掌握 Day 19 所有核心概念！"}},I=()=>(a.value=!a.value,a.value&&o.value?{success:!0,hints:["signature_rsv"],nextStep:"👉 使用签名参与活动来解锁 ecrecover！"}:{success:!1}),b=(p=null)=>(p?r.value=p:r.value=r.value==="organizer"?"participant":"organizer",r.value==="participant"?{success:!0,message:`👤 已切换为参与者角色
地址: ${w(s.value)}`}:{success:!0,message:`👤 已切换为组织者角色
地址: ${w(n)}`}),C=p=>{s.value=p,o.value=null},f=B(()=>({gasUsage:t.getDayGasUsage(19),ethCost:t.getDayEthCost(19),operationCount:t.getDayOperationCount(19)}));return{currentRole:r,currentUserAddress:s,organizer:c,hasEntered:i,generatedSignature:o,showSignatureDetails:a,participantAddress:l,isEntered:u,participantsList:d,formatAddress:w,generateSignature:m,enterEvent:S,checkEntered:h,getParticipants:D,toggleSignatureDetails:I,toggleRole:b,changeUserAddress:C,realtimeData:f}}function Am(){const t=Be(),e=Ue(),n=F(10),r=F({"0xAttacker":1,"0xUserA":5,"0xUserB":3}),s=F(1),i=F(0),o=F(0),a=F(!1),c=F([]),l=1,u=2,d=C=>r.value[C]||0,w=(C,f)=>{const p="deposit20";return f<=0?(t.addLog(20,"deposit","存款金额必须大于0",!1,p),{success:!1,message:"❌ 存款金额必须大于0",hints:[],nextStep:""}):(r.value[C]=(r.value[C]||0)+f,n.value+=f,t.addLog(20,"deposit",`用户 ${C} 存入 ${f} ETH`,!0,p),{success:!0,message:`✅ 成功存入 ${f} ETH！`,hints:["deposit_function"],nextStep:"👉 现在尝试攻击漏洞版本，观察重入攻击如何工作！"})},m=(C,f=5)=>{var L;const p="vulnerableWithdraw20",v=((L=e.getDayProgress(20))==null?void 0:L.unlockedConcepts)||[],k=r.value[C]||0;if(k<=0)return t.addLog(20,"vulnerableWithdraw","余额不足",!1,p),{success:!1,message:"❌ 余额不足，无法提款",hints:[],nextStep:""};let x=0,g=0;const T=[];for(;g<f&&n.value>=k;)x+=k,n.value-=k,T.push({round:g+1,amount:k,vaultBalance:n.value}),g++;r.value[C]=0,i.value=g,o.value=x,c.value=T,a.value=!0,t.addLog(20,"vulnerableWithdraw",`重入攻击成功！${g}次调用，窃取${x}ETH`,!0,p);const A=["vulnerable_withdraw"];return v.includes("fallback_receive")||A.push("fallback_receive"),{success:!0,message:`🚨 重入攻击成功！通过 ${g} 次递归调用，窃取了 ${x} ETH！`,hints:A,nextStep:"💡 观察攻击如何重复提款！👉 查看防护机制了解如何修复！",attackDetails:{count:g,stolen:x,history:T}}},S=C=>{const f="safeWithdraw20",p=r.value[C]||0;return p<=0?(t.addLog(20,"safeWithdraw","余额不足",!1,f),{success:!1,message:"❌ 余额不足，无法提款",hints:[],nextStep:""}):s.value===u?(t.addLog(20,"safeWithdraw","重入调用被阻止",!1,f),{success:!1,message:"🔒 重入调用被阻止！Reentrant call blocked",hints:["reentrancy_guard"],nextStep:"✅ 攻击被阻止！👉 查看代码对比巩固知识！",blocked:!0}):(s.value=u,r.value[C]=0,n.value-=p,s.value=l,t.addLog(20,"safeWithdraw",`安全提款成功！提取${p}ETH`,!0,f),{success:!0,message:`✅ 安全提款成功！提取了 ${p} ETH（重入锁保护）`,hints:["reentrancy_guard"],nextStep:"✅ 攻击被阻止！👉 查看代码对比巩固知识！"})},h=()=>{i.value=0,o.value=0,a.value=!1,c.value=[],s.value=l},D=()=>(n.value=10,r.value={"0xAttacker":1,"0xUserA":5,"0xUserB":3},h(),t.addLog(20,"reset","重置金库状态",!0,null),{success:!0,message:"✅ 金库状态已重置",hints:[],nextStep:""}),I=()=>({balance:n.value,userBalances:{...r.value},reentrancyStatus:s.value===u?"🔒 已锁定":"🔓 未锁定",isLocked:s.value===u}),b=B(()=>({gasUsage:t.getDayGasUsage(20),ethCost:t.getDayEthCost(20),operationCount:t.getDayOperationCount(20)}));return{vaultBalance:n,userBalances:r,reentrancyStatus:s,attackCount:i,stolenAmount:o,isAttacking:a,attackHistory:c,_NOT_ENTERED:l,_ENTERED:u,deposit:w,vulnerableWithdraw:m,safeWithdraw:S,resetAttack:h,resetVault:D,getVaultStatus:I,getUserBalance:d,realtimeData:b}}function Tm(t){return{realtimeData:B(()=>{switch(t.value){case 1:return lp().realtimeData.value;case 2:return up().realtimeData.value;case 3:return dp().realtimeData.value;case 4:return fp().realtimeData.value;case 5:return pp().realtimeData.value;case 6:return gp().realtimeData.value;case 7:return mp().realtimeData.value;case 8:return hp().realtimeData.value;case 9:return yp().realtimeData.value;case 10:return bp().realtimeData.value;case 11:return wp().realtimeData.value;case 12:return vp().realtimeData.value;case 13:return _p().realtimeData.value;case 14:return xp().realtimeData.value;case 15:return Cp().realtimeData.value;case 16:return Cm().realtimeData.value;case 17:return Sm().realtimeData.value;case 18:return Em().realtimeData.value;case 19:return km().realtimeData.value;case 20:return Am().realtimeData.value;default:return{gasUsage:0,ethCost:0,operationCount:0}}})}}const ds=(t,e)=>{const n=t.__vccOpts||t;for(const[r,s]of e)n[r]=s;return n},Dm={class:"header"},Bm={class:"header-center"},Im={class:"main-title"},Om={class:"easter-egg-container"},Pm={__name:"AppHeader",props:{showLeftSidebar:{type:Boolean,default:!0},showRightSidebar:{type:Boolean,default:!0}},emits:["toggle-left-sidebar","toggle-right-sidebar"],setup(t){const e=F(!1),n=()=>{e.value=!e.value,e.value?(document.documentElement.dataset.theme="dark",localStorage.setItem("theme","dark")):(document.documentElement.dataset.theme="light",localStorage.setItem("theme","light"))},r=F(!1),s=F(!1),i=F("");let o=null;const a=["In Code We Trust!","🔮 今日宜：部署主网；忌：未 Audit","⚠️ 注意你的 Reentrancy 漏洞！","Gas 费太高了，先在这练练手！","HODL! 到下一个牛市！","🎉 签运：大吉！编译一遍过","🚀 To the Moon!","智能合约，不可篡改！","🧐 别忘了测边缘情况"],c=()=>{if(r.value)return;r.value=!0,setTimeout(()=>{r.value=!1},600);const l=a[Math.floor(Math.random()*a.length)];i.value=l,s.value=!0,o&&clearTimeout(o),o=setTimeout(()=>{s.value=!1},3e3)};return Co(()=>{(localStorage.getItem("theme")||(window.matchMedia("(prefers-color-scheme: dark)").matches?"dark":"light"))==="dark"&&(e.value=!0,document.documentElement.dataset.theme="dark")}),(l,u)=>(ve(),Se("div",Dm,[J("button",{class:Ct(["sidebar-toggle-btn left-toggle",{active:t.showLeftSidebar}]),onClick:u[0]||(u[0]=d=>l.$emit("toggle-left-sidebar"))}," 📅 日程 ",2),J("div",Bm,[J("h1",Im,[J("div",Om,[J("button",{class:Ct(["easter-egg-btn",{animating:r.value}]),onClick:c,title:"点这里有惊喜"}," 🎓 ",2),J("div",{class:Ct(["toast-message",{show:s.value}])},Te(i.value),3)]),u[2]||(u[2]=J("span",null,"Solidity 学习互动演示",-1)),J("button",{class:"theme-toggle-btn",onClick:n,title:"切换模式"},Te(e.value?"☀️":"🌙"),1)]),u[3]||(u[3]=J("div",{class:"warning-banner"},[J("span",null,"模拟环境，不消耗真实 Gas 或 ETH"),J("span",{class:"author-credit"},[zr("by "),J("a",{href:"https://github.com/Tenlossiby",target:"_blank",rel:"noopener noreferrer"},"Tenlossiby")])],-1))]),J("button",{class:Ct(["sidebar-toggle-btn right-toggle",{active:t.showRightSidebar}]),onClick:u[1]||(u[1]=d=>l.$emit("toggle-right-sidebar"))}," 📊 进度 ",2)]))}},$m=ds(Pm,[["__scopeId","data-v-024c6279"]]),Lm={class:"left-sidebar"},Rm={class:"sidebar-header"},Nm=["title"],Mm=["onClick"],Um={class:"day-nav-header"},Hm={class:"day-title"},Vm={class:"day-subtitle"},Fm={__name:"DayNavigation",props:{currentDay:{type:Number,required:!0}},emits:["switchDay"],setup(t){const e=F(!0),n=()=>{e.value=!e.value},r=B(()=>{const i=Object.keys(xr).map(Number);return e.value?i:i.reverse()}),s=i=>{var o;return i===14?"安全存款盒/SafeDeposit":((o=xr[i])==null?void 0:o.subtitle)||"待定内容"};return(i,o)=>(ve(),Se("div",Lm,[J("div",Rm,[o[0]||(o[0]=J("h3",null,"📚 学习导航",-1)),J("button",{class:"sort-toggle-btn",onClick:n,title:e.value?"点击切换倒序":"点击切换正序"},Te(e.value?"🔼 正序":"🔽 倒序"),9,Nm)]),(ve(!0),Se(ct,null,Ms(r.value,a=>(ve(),Se("div",{key:a,class:Ct(["day-nav-item",{active:t.currentDay===a}]),onClick:c=>i.$emit("switchDay",a)},[J("div",Um,[J("div",Hm,"Day "+Te(a),1)]),J("div",Vm,Te(s(a)),1)],10,Mm))),128))]))}},qm=ds(Fm,[["__scopeId","data-v-562b1087"]]),Wm="modulepreload",zm=function(t,e){return new URL(t,e).href},fc={},Oe=function(e,n,r){let s=Promise.resolve();if(n&&n.length>0){const o=document.getElementsByTagName("link"),a=document.querySelector("meta[property=csp-nonce]"),c=(a==null?void 0:a.nonce)||(a==null?void 0:a.getAttribute("nonce"));s=Promise.allSettled(n.map(l=>{if(l=zm(l,r),l in fc)return;fc[l]=!0;const u=l.endsWith(".css"),d=u?'[rel="stylesheet"]':"";if(!!r)for(let S=o.length-1;S>=0;S--){const h=o[S];if(h.href===l&&(!u||h.rel==="stylesheet"))return}else if(document.querySelector(`link[href="${l}"]${d}`))return;const m=document.createElement("link");if(m.rel=u?"stylesheet":Wm,u||(m.as="script"),m.crossOrigin="",m.href=l,c&&m.setAttribute("nonce",c),document.head.appendChild(m),u)return new Promise((S,h)=>{m.addEventListener("load",S),m.addEventListener("error",()=>h(new Error(`Unable to preload CSS for ${l}`)))})}))}function i(o){const a=new Event("vite:preloadError",{cancelable:!0});if(a.payload=o,window.dispatchEvent(a),!a.defaultPrevented)throw o}return s.then(o=>{for(const a of o||[])a.status==="rejected"&&i(a.reason);return e().catch(i)})},Gm={class:"coming-soon-content"},Km={class:"coming-soon-card"},jm={class:"description"},Xm={class:"suggestion"},Jm={class:"available-days"},Ym=["onClick"],Zm={__name:"ComingSoon",props:{day:{type:Number,default:0}},emits:["switchDay"],setup(t,{emit:e}){const n=e,r=Object.keys(xr).map(Number).sort((i,o)=>i-o),s=i=>{n("switchDay",i)};return(i,o)=>(ve(),Se("div",Gm,[J("div",Km,[o[1]||(o[1]=J("div",{class:"icon"},"🚧",-1)),o[2]||(o[2]=J("h2",null,"内容建设中",-1)),o[3]||(o[3]=J("p",{class:"subtitle"},"Coming Soon",-1)),J("p",jm," Day "+Te(t.day)+" 的内容正在开发中，敬请期待！ ",1),J("div",Xm,[o[0]||(o[0]=J("p",null,"💡 提示：目前可用的学习内容：",-1)),J("div",Jm,[(ve(!0),Se(ct,null,Ms(Jr(r),a=>(ve(),Se("span",{key:a,class:"day-tag",onClick:c=>s(a)}," Day "+Te(a),9,Ym))),128))])])])]))}},Qm=ds(Zm,[["__scopeId","data-v-5d301d5d"]]),eh={class:"center-content"},th={__name:"DayContent",props:{currentDay:{type:Number,required:!0}},emits:["switchDay"],setup(t,{emit:e}){const n={1:Ie(()=>Oe(()=>import("./ClickCounter-9JyJGixa.js"),__vite__mapDeps([0,1,2,3]),import.meta.url)),2:Ie(()=>Oe(()=>import("./SaveMyName-BIqESgan.js"),__vite__mapDeps([4,1,2,5]),import.meta.url)),3:Ie(()=>Oe(()=>import("./PollStation-BisNinLf.js"),__vite__mapDeps([6,1,2,7]),import.meta.url)),4:Ie(()=>Oe(()=>import("./AuctionHouse-BDAtGYUw.js"),__vite__mapDeps([8,1,2,9]),import.meta.url)),5:Ie(()=>Oe(()=>import("./AdminOnly-C5zWahh4.js"),__vite__mapDeps([10,1,2,11]),import.meta.url)),6:Ie(()=>Oe(()=>import("./EtherPiggyBank-D8NFv8s2.js"),__vite__mapDeps([12,1,2,13]),import.meta.url)),7:Ie(()=>Oe(()=>import("./SimpleIOUApp-CRgK-VGp.js"),__vite__mapDeps([14,1,2,15]),import.meta.url)),8:Ie(()=>Oe(()=>import("./TipJar-9T_O6kqq.js"),__vite__mapDeps([16,1,2,17]),import.meta.url)),9:Ie(()=>Oe(()=>import("./SmartCalculator-Cg3DyfGC.js"),__vite__mapDeps([18,1,2,19]),import.meta.url)),10:Ie(()=>Oe(()=>import("./ActivityTracker-BizV9rH3.js"),__vite__mapDeps([20,1,2,21]),import.meta.url)),11:Ie(()=>Oe(()=>import("./MasterkeyContract-CkQn-8AA.js"),__vite__mapDeps([22,1,2,23]),import.meta.url)),12:Ie(()=>Oe(()=>import("./ERC20Token-DWxeg8i2.js"),__vite__mapDeps([24,1,2,25]),import.meta.url)),13:Ie(()=>Oe(()=>import("./MyToken-BgUsXMDi.js"),__vite__mapDeps([26,1,2,27]),import.meta.url)),14:Ie(()=>Oe(()=>import("./SafeDeposit-B01DGgze.js"),__vite__mapDeps([28,1,2,29]),import.meta.url)),15:Ie(()=>Oe(()=>import("./GasEfficientVoting-BlBaerag.js"),__vite__mapDeps([30,1,2,31]),import.meta.url)),16:Ie(()=>Oe(()=>import("./PluginStore-DYqQQwuK.js"),__vite__mapDeps([32,1,2,33]),import.meta.url)),17:Ie(()=>Oe(()=>import("./UpgradeHub-C_DdyWp-.js"),__vite__mapDeps([34,1,2,35]),import.meta.url)),18:Ie(()=>Oe(()=>import("./OracleContract-Q2WE0VuW.js"),__vite__mapDeps([36,1,2,37]),import.meta.url)),19:Ie(()=>Oe(()=>import("./SignThis-BeIFG3Lk.js"),__vite__mapDeps([38,1,2,39]),import.meta.url)),20:Ie(()=>Oe(()=>import("./ReentryAttack-BlkWNHdb.js"),__vite__mapDeps([40,1,2,41]),import.meta.url))},r=t,s=e,i=B(()=>n[r.currentDay]||Qm),o=a=>{s("switchDay",a)};return(a,c)=>(ve(),Se("div",eh,[(ve(),pl(Td(i.value),{key:t.currentDay,day:t.currentDay,onSwitchDay:o},null,40,["day"]))]))}},nh=ds(th,[["__scopeId","data-v-a9040a2a"]]),rh={class:"right-sidebar"},sh={class:"sidebar-card"},ih={class:"progress-bar"},oh={class:"progress-stats"},ah={class:"sidebar-card"},ch={class:"unlocked-list"},lh={key:0,class:"locked"},uh={class:"icon"},dh={key:0,class:"sidebar-card"},fh={class:"realtime-data"},ph={key:0},gh={class:"data-row"},mh={class:"value"},hh={class:"data-row"},yh={class:"value"},bh={class:"data-row"},wh={class:"value"},vh={key:1,class:"no-operations"},_h={class:"sidebar-card"},xh={class:"operation-log"},Ch={key:0,class:"no-operations"},Sh={key:1},Eh={class:"data-row"},kh={class:"timestamp"},Ah={key:0,class:"data-row gas-info"},Th={class:"value"},Dh={class:"value"},Bh={__name:"Sidebar",props:{realtimeData:{type:Object,default:null},dayProgress:{type:Object,required:!0},currentDay:{type:Number,required:!0}},setup(t){const e=t,n=Be(),r=B(()=>n.getDayLogs(e.currentDay)),s=B(()=>{const c=e.dayProgress[e.currentDay];return!c||c.totalConcepts===0?0:Math.floor(c.unlockedConcepts.length/c.totalConcepts*100)}),i=B(()=>{const c=e.dayProgress[e.currentDay];return(c==null?void 0:c.unlockedConcepts.length)||0}),o=B(()=>{const c=e.dayProgress[e.currentDay];return(c==null?void 0:c.totalConcepts)||0}),a=B(()=>{const c=xr[e.currentDay];if(!c||!c.concepts)return[];const l=e.dayProgress[e.currentDay],u=(l==null?void 0:l.unlockedConcepts)||[];let d=Zf;return e.currentDay===11?d=Qf:e.currentDay===12?d=tp:e.currentDay===13?d=ep:e.currentDay===14?d=np:e.currentDay===15?d=rp:e.currentDay===16?d=sp:e.currentDay===17?d=ip:e.currentDay===18?d=op:e.currentDay===19?d=ap:e.currentDay===20&&(d=cp),c.concepts.map(w=>{const m=d[w];return{key:w,name:(m==null?void 0:m.name)||w,icon:u.includes(w)?m==null?void 0:m.icon:"🔒",isUnlocked:u.includes(w)}})});return(c,l)=>(ve(),Se("div",rh,[J("div",sh,[l[0]||(l[0]=J("h3",null,"🎓 学习进度",-1)),J("div",ih,[J("div",{class:"progress-fill",style:ei({width:s.value+"%"})},null,4)]),J("div",oh,[J("span",null,"完成度 "+Te(s.value)+"%",1),J("span",null,"已解锁 "+Te(i.value)+"/"+Te(o.value),1)])]),J("div",ah,[l[2]||(l[2]=J("h3",null,"✅ 已解锁概念",-1)),J("ul",ch,[a.value.length===0?(ve(),Se("li",lh,[...l[1]||(l[1]=[J("span",{class:"icon"},"🚧",-1),zr(" 内容开发中... ",-1)])])):As("",!0),(ve(!0),Se(ct,null,Ms(a.value,u=>(ve(),Se("li",{key:u.key,class:Ct({locked:!u.isUnlocked})},[J("span",uh,Te(u.icon),1),zr(" "+Te(u.name),1)],2))),128))])]),t.realtimeData?(ve(),Se("div",dh,[l[6]||(l[6]=J("h3",null,"📊 实时数据",-1)),J("div",fh,[t.realtimeData.operationCount>0?(ve(),Se("div",ph,[J("div",gh,[l[3]||(l[3]=J("span",{class:"label"},"操作次数：",-1)),J("span",mh,Te(t.realtimeData.operationCount),1)]),J("div",hh,[l[4]||(l[4]=J("span",{class:"label"},"Gas 消耗：",-1)),J("span",yh,Te(t.realtimeData.gasUsage.toLocaleString()),1)]),J("div",bh,[l[5]||(l[5]=J("span",{class:"label"},"ETH 费用：",-1)),J("span",wh,Te(t.realtimeData.ethCost.toFixed(6)),1)])])):(ve(),Se("div",vh," 暂无操作记录 "))])])):As("",!0),J("div",_h,[l[9]||(l[9]=J("h3",null,"📋 操作日志",-1)),J("div",xh,[r.value.length===0?(ve(),Se("p",Ch,"暂无操作记录")):(ve(),Se("div",Sh,[(ve(!0),Se(ct,null,Ms(r.value.slice(0,10),u=>(ve(),Se("div",{key:u.id,class:"log-entry"},[J("div",Eh,[J("span",kh,Te(u.timestamp),1),J("span",null,[J("strong",null,Te(u.operation),1),zr(" "+Te(u.details),1)])]),u.gasUsed>0?(ve(),Se("div",Ah,[l[7]||(l[7]=J("span",{class:"label"},"Gas:",-1)),J("span",Th,Te(u.gasUsed.toLocaleString()),1),l[8]||(l[8]=J("span",{class:"label",style:{"margin-left":"15px"}},"ETH:",-1)),J("span",Dh,Te(u.ethCost.toFixed(6)),1)])):As("",!0)]))),128))]))])])]))}},Ih=ds(Bh,[["__scopeId","data-v-59a99b80"]]),Oh={class:"app-container"},Ph={class:"main-layout"},$h={__name:"App",setup(t){const e=Ue(),n=F(!0),r=F(!0),s=F(1),i=F(!1),{realtimeData:o}=Tm(s),a=()=>{const w=window.innerWidth<=1100;!i.value&&w&&(n.value=!1,r.value=!1),i.value&&!w&&(n.value=!0,r.value=!0),i.value=w},c=B(()=>i.value&&(n.value||r.value));Co(()=>{a(),window.addEventListener("resize",a)}),So(()=>{window.removeEventListener("resize",a)});const l=d=>{s.value=d},u=()=>{n.value=!1,r.value=!1};return(d,w)=>(ve(),Se("div",Oh,[Re($m,{"show-left-sidebar":n.value,"show-right-sidebar":r.value,onToggleLeftSidebar:w[0]||(w[0]=m=>n.value=!n.value),onToggleRightSidebar:w[1]||(w[1]=m=>r.value=!r.value)},null,8,["show-left-sidebar","show-right-sidebar"]),c.value?(ve(),Se("div",{key:0,class:"sidebar-overlay active",onClick:Mf(u,["stop"])})):As("",!0),J("div",Ph,[Re(qm,{"current-day":s.value,onSwitchDay:l,class:Ct({hidden:!n.value&&!i.value,"mobile-visible":i.value&&n.value,show:n.value&&i.value})},null,8,["current-day","class"]),Re(nh,{"current-day":s.value,onSwitchDay:l},null,8,["current-day"]),Re(Ih,{"current-day":s.value,"day-progress":Jr(e).dayProgress,"realtime-data":Jr(o),class:Ct({hidden:!r.value&&!i.value,"mobile-visible":i.value&&r.value,show:r.value&&i.value})},null,8,["current-day","day-progress","realtime-data","class"])])]))}},uu=Ff($h),Lh=zf();uu.use(Lh);uu.mount("#app");export{tp as $,mp as A,hp as B,qh as C,yp as D,Cs as E,ct as F,Co as G,Uh as H,ei as I,bp as J,wp as K,vp as L,_p as M,xp as N,Qh as O,Cp as P,Yh as Q,Be as R,Cm as S,Fh as T,Hh as U,Sm as V,Em as W,km as X,Am as Y,Qf as Z,ds as _,J as a,ep as a0,np as a1,rp as a2,sp as a3,ip as a4,op as a5,Zf as a6,jh as a7,t0 as a8,r0 as a9,i0 as aa,a0 as ab,l0 as ac,Kh as ad,Jh as ae,Xh as af,e0 as ag,Zh as ah,n0 as ai,s0 as aj,o0 as ak,c0 as al,u0 as am,Gh as an,ap as ao,cp as ap,Mh as aq,Jr as b,Se as c,pl as d,As as e,Re as f,up as g,Wh as h,B as i,zh as j,dp as k,Ms as l,fp as m,Ct as n,ve as o,Mf as p,Ue as q,F as r,pp as s,Te as t,lp as u,Vh as v,Nh as w,Ee as x,zr as y,gp as z};
