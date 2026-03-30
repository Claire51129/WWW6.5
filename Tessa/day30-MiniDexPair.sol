// 迷你版去中心化交易所（Mini DEX）——MiniDexPair：真正负责“放币、取币、换币”的池子(真正装水，让大家来游泳的池子)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";   //导入 IERC20 接口,就像你拿来一个“遥控器说明书”，这样你知道怎么控制别人的 ERC20 代币
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";  //导入 防重入攻击工具

contract MiniDexPair is ReentrancyGuard {   //定义一个合约，名字叫 MiniDexPair,它继承了 ReentrancyGuard。即该池子合约自带“防重入保护”
    address public immutable tokenA;   //tokenA：池子里的第 1 种代币
    address public immutable tokenB;   //tokenB：池子里的第 2 种代币
    // 定义两种代币地址；immutable：只允许在构造函数里设置一次，之后就不能改

    uint256 public reserveA;    //池子里现在存着多少个 A 币
    uint256 public reserveB;   //
    uint256 public totalLPSupply;   //总共发出了多少 LP 份额(池子的股份)

    mapping(address => uint256) public lpBalances;   //“地址 => 数量”的表，记录每个人有多少 LP 份额(股东登记表)

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpMinted);   //添加流动性时发出通知，记录：谁加的 provider、加了多少 A、加了多少 B、得到了多少 LP；indexed 的意思是这个参数更方便后面搜索过滤
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpBurned);   //移除流动性时发出通知，记录：谁移除的、取回多少 A、取回多少 B、销毁了多少 LP
    event Swapped(address indexed user, address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount);   //有人交换代币时发出通知，记录：谁换的、拿什么币来换、拿了多少、换出什么币、换到了多少

    constructor(address _tokenA, address _tokenB) {    //部署时要传入tokenA&B两个参数
        require(_tokenA != _tokenB, "Identical tokens");    //要求 A 和 B 不能是同一个代币
        require(_tokenA != address(0) && _tokenB != address(0), "Zero address");   //A 和 B 都不能是零地址

        tokenA = _tokenA;    //把传进来的两个地址，保存到合约里。
        tokenB = _tokenB;    //这个池子正式记住自己服务哪两种币了
    }

    // 实用工具
    function sqrt(uint y) internal pure returns (uint z) {   //定义一个函数叫 sqrt，作用是求平方根;pure：这个函数只做数学计算，不读区块链数据，也不改数据;returns (uint z)：最后返回一个叫 z 的数字
        if (y > 3) {    //如果 y 大于 3，就进入这段逻辑。
            z = y;    //先把 z 暂时设成 y 本身。
            uint x = y / 2 + 1;    //再造一个变量 x，初始值设成 y/2 + 1
            while (x < z) {    //只要 x 比 z 小，就不断重复循环。(在慢慢逼近平方根)
                z = x;     //先把 z 更新成 x
                x = (y / x + x) / 2;   //经典的“牛顿法”近似公式，用来一步步求平方根(在反复试，越来越接近正确答案)
            }
        } else if (y != 0) {    //如果 y 不大于 3，但是 y 也不等于 0，那么执行这里。
            z = 1;    //那就把平方根结果设成 1。——因为sqrt(1)=1、sqrt(2)约等于1点多、sqrt(3)约等于1点多、整数里就记成 1。
        }    //第一次往池子里加币时，LP 数量按两种币乘积的平方根来算(AMM经典做法)
    }

    // 取较小值
    function min(uint256 a, uint256 b) internal pure returns (uint256) {   //定义一个函数，输入两个数 a 和 b，返回较小的那个
        return a < b ? a : b;   //如果 a < b，就返回 a；否则返回 b(三元运算符)
    }

    // 更新储备量
    function _updateReserves() private {    //定义一个私有函数 _updateReserves
        reserveA = IERC20(tokenA).balanceOf(address(this));   //去问tokenA合约“当前这个池子地址里，实际有多少 A 币？”然后把这个值保存到 reserveA
        reserveB = IERC20(tokenB).balanceOf(address(this));   //同理↑
    }   //池子加减流动性和交换代币，真实余额都会变化，以便更新记录

    // 添加流动性
    function addLiquidity(uint256 amountA, uint256 amountB) external nonReentrant {   //调用时要告诉它想放多少A&B
        require(amountA > 0 && amountB > 0, "Invalid amounts");   //A 和 B 的数量都必须大于 0

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);   //从调用者 msg.sender 那里，把 amountA 个 A 币转到池子里
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);   //同样地，把 B 币也从用户那里转进池子

        uint256 lpToMint;   //定义一个变量 lpToMint,表示这次要给用户铸造多少 LP 份额
        if (totalLPSupply == 0) {    //如果总 LP 供应量是 0，说明：这是第一次有人往这个池子里加流动性
            lpToMint = sqrt(amountA * amountB);   //第一次加流动性时，LP 数量 = sqrt(amountA * amountB)
        } else {    //如果不是第一次加流动性，就进入这里(即池子里已经有人放过币了)
            lpToMint = min(     //分别从 A 和 B 两个方向算一次，然后取较小值
                (amountA * totalLPSupply) / reserveA,
                (amountB * totalLPSupply) / reserveB
            );    //后来的新用户加流动性时，要按池子当前比例来算能拿多少 LP。
        }    //池子希望你按原来的比例加币，系统会用较小的那部分来算 LP，避免你“多带了一边”

        require(lpToMint > 0, "Zero LP minted");   //要求铸造出来的 LP 必须大于 0，否则报错

        lpBalances[msg.sender] += lpToMint;   //把用户的 LP 余额增加,即把份额记到他名下
        totalLPSupply += lpToMint;   //总 LP 供应量也增加

        _updateReserves();    //更新池子的 A 和 B 储备记录

        emit LiquidityAdded(msg.sender, amountA, amountB, lpToMint);    //发出“添加流动性”的事件通知
    }

    // 移除流动性
    function removeLiquidity(uint256 lpAmount) external nonReentrant {   //用户要告诉合约：“我要拿多少 LP 份额来赎回。”
        require(lpAmount > 0 && lpAmount <= lpBalances[msg.sender], "Invalid LP amount");   //赎回数量必须大于 0，而且不能超过你自己拥有的 LP 数量(不能拿别人的份额来领钱)

        uint256 amountA = (lpAmount * reserveA) / totalLPSupply;   //按比例计算这次能领回多少 A
        uint256 amountB = (lpAmount * reserveB) / totalLPSupply;   //你占总股份多少，就拿走池子里对应比例的 B

        lpBalances[msg.sender] -= lpAmount;    //把你的 LP 余额扣掉
        totalLPSupply -= lpAmount;    //总 LP 供应量也减少。

        IERC20(tokenA).transfer(msg.sender, amountA);   //把 A 币转回给用户
        IERC20(tokenB).transfer(msg.sender, amountB);

        _updateReserves();    //更新池子最新储备量

        emit LiquidityRemoved(msg.sender, amountA, amountB, lpAmount);   //发出移除流动性的事件
    }

    // 公开只读函数：算能换出多少币
    function getAmountOut(uint256 inputAmount, address inputToken) public view returns (uint256 outputAmount) {   //输入——inputAmount：你打算拿进去多少币；inputToken：你拿进去的是哪种币。输出——outputAmount：你最终能换出来多少另一种币
        require(inputToken == tokenA || inputToken == tokenB, "Invalid input token");   //要求输入的币必须是 A 或 B(不能有第三种)

        bool isTokenA = inputToken == tokenA;   //定义一个布尔变量 isTokenA：如果输入币是 A，就是真；否则是假
        (uint256 inputReserve, uint256 outputReserve) = isTokenA ? (reserveA, reserveB) : (reserveB, reserveA);   //如果输入是A，就出来B；如果输入B，就出来A(根据你从哪边换入，自动决定哪边是进、哪边是出)

        uint256 inputWithFee = inputAmount * 997;    //扣手续费，997给兑换公式，3是手续费，所以手续费=3/1000=0.3%
        uint256 numerator = inputWithFee * outputReserve;    //分子 = 扣完手续费后的输入量 × 输出池储备
        uint256 denominator = (inputReserve * 1000) + inputWithFee;    //分母 = 输入池储备 × 1000 + 扣费后的输入量

        outputAmount = numerator / denominator;    //最后输出量 = 分子 / 分母(经典AMM定价公式写法)
    }

    // 执行换币
    function swap(uint256 inputAmount, address inputToken) external nonReentrant {    //定义一个外部函数：交换代币。拿多少币来换，拿的是哪种币
        require(inputAmount > 0, "Zero input");    //输入数量必须大于 0
        require(inputToken == tokenA || inputToken == tokenB, "Invalid token");    //输入币必须是 A 或 B

        address outputToken = inputToken == tokenA ? tokenB : tokenA;   //如果输入的是 A，输出就是 B；如果输入的是 B，输出就是 A
        uint256 outputAmount = getAmountOut(inputAmount, inputToken);   //调用刚才那个计算函数，先算出你应该得到多少输出币

        require(outputAmount > 0, "Insufficient output");    //要求输出数量必须大于 0,否则""

        IERC20(inputToken).transferFrom(msg.sender, address(this), inputAmount);   //先把用户输入的代币转进池子
        IERC20(outputToken).transfer(msg.sender, outputAmount);    //然后把应得的输出代币转给用户

        _updateReserves();    //更新池子最新储备量

        emit Swapped(msg.sender, inputToken, inputAmount, outputToken, outputAmount);    //发出“交换成功”的事件通知
    }

    // 查看函数
    function getReserves() external view returns (uint256, uint256) {   //定义一个外部只读函数，用来查看池子的两个储备值
        return (reserveA, reserveB);   //返回池子里 A 和 B 的储备数量
    }

    function getLPBalance(address user) external view returns (uint256) {   //定义一个函数，用来查看某个用户有多少 LP
        return lpBalances[user];   //返回这个地址对应的 LP 数量
    }

    function getTotalLPSupply() external view returns (uint256) {   //定义一个函数，用来查看当前总 LP 供应量
        return totalLPSupply;    //返回总 LP 数量
    }
}













// Factory 工厂 = 造游泳池的人,pair 池子 = 真正装水、让大家来游泳的池子.“水”其实就是两种代币,“往池子里加水” = 添加流动性,“从池子里取水” = 移除流动性,“拿一种币换另一种币” = swap 交换,“LP” = 你给池子贡献了多少的凭证
// transferFrom：是“代扣式转账”，意思是：“先授权，再由合约替你把币拿过来。”所以用户在调这个函数前，通常要先 approve。
// 池子想尽量维持一个平衡关系。你拿一种币进来，池子另一种币出去，价格就会变化。可以把它理解成：池子里 A 很多、B 很少时，B 会显得更贵;池子里 B 很多、A 很少时，B 会显得更便宜。所以不是“固定价”，而是会随着池子里数量变化而变。
// 【总结】这是一个两种代币组成的自动做市池子(交易池)，支持：加流动性、取流动性、按公式换币(swap)、记录LP份额、更新储备、防重入攻击。







