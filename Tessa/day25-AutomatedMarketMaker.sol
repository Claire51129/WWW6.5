// 用数字公式自动定价格的换币池，核心是x*y=k、添加/移除流动性、LP 代币、0.3% 手续费和滑点保护。
// 造出一个AMM(Automated Market Maker，自动做市商)池子，让大家可以：往池子里放 A 和 B(变成“流动性提供者”)、流动性提供者会拿到LP份额币、AB代币互换、取回自己的流动性
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";   //该合约继承ERC20的功能


/// @title Automated Market Maker with Liquidity Token 这个合约叫“带流动性代币的自动做市商”。
contract AutomatedMarketMaker is ERC20 {   //该合约本身也是一个ERC20代币合约；“这个机器不只是会换币，它还会印“股东证”。”
    IERC20 public tokenA;   // 定义了TokenA: 池子里的第一种代币；IERC20 表示它符合 ERC20 接口标准
    IERC20 public tokenB;   //池子里的第二种代币,可以想成：tokenA = 左边饮料，okenB = 右边饮料

    uint256 public reserveA;   //定义 reserveA——A币库存:“池子里现在存着多少个 A 币”;reserve=储备量
    uint256 public reserveB;    //B币库存

    address public owner;    //这个合约的拥有者是谁

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);   //provider=是谁加的池子;amountA/B=加了多少A/B；liquidity=拿到了多少流动性代币(LP)
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);   //有人移除了流动性，记录：谁取走、取走多少A/B、销毁了多少流动性代币
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);   //有人换币了，记录：谁、换入币类型、放币数量、换出币类型、换出数量

    constructor(address _tokenA, address _tokenB, string memory _name, string memory _symbol) ERC20(_name, _symbol) {   //A/B币地址、流动性代币名称及符号
        tokenA = IERC20(_tokenA);   //把这个合约自己的ERC20份额币名字和符号也设好；“这个池子知道 A 币是谁了。”
        tokenB = IERC20(_tokenB);   //“外面传进来的 B 币地址保存成 tokenB”
        owner = msg.sender;   //把部署者记为 owner;msg.sender 就是当前执行这个函数的人
    }

    // 往池子里加两种币(增加流动性)，@notice Add liquidity to the pool
    function addLiquidity(uint256 amountA, uint256 amountB) external {   //你可以往池子里放入 amountA 个 A 币和 amountB 个 B 币
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");   //检查A 和 B 都必须大于 0

        tokenA.transferFrom(msg.sender, address(this), amountA);   //把调用者钱包里的 A 币，转到这个合约地址里
        tokenB.transferFrom(msg.sender, address(this), amountB);   //“你把 B 币也存进池子”

        uint256 liquidity;    //定义一个变量 liquidity,等会要算出这次应该给你多少“流动性代币(LP)”
        if (totalSupply() == 0) {   //如果流动性代币总供应量是 0，即第一个往池子里加钱的人
            liquidity = sqrt(amountA * amountB);    //流动性份额公式：A 数量 × B 数量，再开平方(确保放得越多，拿到的股份越多-公平性)
        } else {
            liquidity = min(   //计算应该给你多少流动性代币，会取两个值里更小的那个
                amountA * totalSupply() / reserveA,   //如果只根据你放进去的 A 币来算，你应该拿多少流动性代币
                amountB * totalSupply() / reserveB   //如果只根据你放进去的 B 币来算，你应该拿多少流动性代币
            );   //把上面两个结果比较，取较小值(因为池子要尽量保持原本比例，不能随便乱加)
        }

        _mint(msg.sender, liquidity);   //给调用者铸造 liquidity 数量的流动性代币(股份证明卡/股东票/收据)

        reserveA += amountA;   //池子里的 A 币库存增加
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);   //谁加了多少 A、多少 B、拿到了多少股份币。
    }

    // 从池子里移除流动性 @notice Remove liquidity from the pool
    function removeLiquidity(uint256 liquidityToRemove) external returns (uint256 amountAOut, uint256 amountBOut) {   //用户输入想移除多少LP代币；你可以拿着自己的股份币，来换回池子里的 A 和 B。
        require(liquidityToRemove > 0, "Liquidity to remove must be > 0");   //检查：你想移除的股份数量必须大于 0
        require(balanceOf(msg.sender) >= liquidityToRemove, "Insufficient liquidity tokens");   //检查：你持有的股份币必须够。

        uint256 totalLiquidity = totalSupply();   //先看看整个池子的“总股份”一共有多少
        require(totalLiquidity > 0, "No liquidity in the pool");   //池子里必须有东西

        amountAOut = liquidityToRemove * reserveA / totalLiquidity;   //你拿出的股份，占总股份多少比例，就可以拿走 A 储备里的同样比例
        amountBOut = liquidityToRemove * reserveB / totalLiquidity;   //你要拿回多少 B；“如果你是池子的 10% 股东，你就拿走B储备的 10%”

        require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves for requested liquidity");   //算出来的 A 和 B 都必须大于 0

        reserveA -= amountAOut;   //从池子库存里减掉要给你的 A
        reserveB -= amountBOut;   //从池子储备里减掉即将还给用户的 B(更新储备是为了保证后面的价格和换币公式仍然准确)

        _burn(msg.sender, liquidityToRemove);   //把你交回来的股份币销毁掉(股东证明作废)

        tokenA.transfer(msg.sender, amountAOut);   //把对应的 A 转给你
        tokenB.transfer(msg.sender, amountBOut);   //对应数量的 B 也发还给用户

        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);   //广播：告诉大家谁移除了多少流动性，拿走了多少 A 和 B、烧掉多少 LP
        return (amountAOut, amountBOut);   //结果返回：告诉调用者你这次拿到了多少 A、多少 B、烧掉多少 LP(方便前端/别的合约提取结果)
    }

    // “用 A 换 B” @notice Swap token A for token B
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {   //你可以放进 amountAIn 个 A，然后想换出 minBOut个B
        require(amountAIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");   //检查：池子里必须同时有 A 和 B

        uint256 amountAInWithFee = amountAIn * 997 / 1000;   //先把手续费扣掉，再看真正参与换币的 A 是多少,997 / 1000 就表示保留 99.7%,即手续费0.3%
        uint256 amountBOut = reserveB * amountAInWithFee / (reserveA + amountAInWithFee);   //计算你最终可以换出多少 B

        require(amountBOut >= minBOut, "Slippage too high");   //算出来的 B 至少要大于等于你能接受的最低值 minBOut(滑点保护)

        //用户交 A，池子给 B
        tokenA.transferFrom(msg.sender, address(this), amountAIn);   //真正把用户的 A 转进池子(前提是用户先 approve 授权 AMM 合约)
        tokenB.transfer(msg.sender, amountBOut);   //把算好的 B 转给用户

        reserveA += amountAInWithFee;   //把 reserveA 加上的是扣完手续费后的 A
        reserveB -= amountBOut;   //池子里的 B 被用户拿走了一部分，所以 B 储备减少

        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }   //事件广播：谁换了币、放进来多少A、拿走多少B

    //  “用 B 换 A” @notice Swap token B for token A
    function swapBforA(uint256 amountBIn, uint256 minAOut) external {   //你可以放进 B，然后换出 A;minAOut 是你最低能接受拿到多少 A
        require(amountBIn > 0, "Amount must be > 0");   //检查：放进来的 B 必须大于 0
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");   //检查：池子里 A 和 B 都必须有库存

        uint256 amountBInWithFee = amountBIn * 997 / 1000;   //同上，先扣掉 0.3% 手续费，再拿剩下的数量参与计算
        uint256 amountAOut = reserveA * amountBInWithFee / (reserveB + amountBInWithFee);   //计算这次你能换到多少A(逻辑与swapAforB对称)——“常数乘积计算（B -> A）”

        require(amountAOut >= minAOut, "Slippage too high");   //检查：如果最后能拿到的 A 比你设定的最低值还少，那就取消交易(回滚交易)——滑点保护

        tokenB.transferFrom(msg.sender, address(this), amountBIn);   //把用户的 B 转进池子
        tokenA.transfer(msg.sender, amountAOut);   //把池子里算好的A转给用户

        reserveB += amountBInWithFee;   //池子的 B 储备增加，增加的是扣完手续费的那部分
        reserveA -= amountAOut;   //池子的 A 储备减少，因为用户拿走了一些 A

        emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }   //事件广播：这次是拿 B 换 A，换了多少

    // 查看当前储备量 @notice View the current reserves
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);   //把当前 A 储备和 B 储备返回出去
    }

    // 工具函数：用来返回两个数里更小的那个 @dev Utility: Return the smaller of two values
    function min(uint256 a, uint256 b) internal pure returns (uint256) {   //给你两个数，返回较小的那个
        return a < b ? a : b;   //三元运算符：如果 a < b，就返回 a，否则返回 b(即取最小值)
    }

    // 工具函数：开平方根小工具——用“巴比伦算法”来算平方根 @dev Utility: Babylonian square root
    function sqrt(uint256 y) internal pure returns (uint256 z) {   //定义函数 sqrt，作用：输入一个数字 y，算它的平方根，结果放在 z 里
        if (y > 3) {
            z = y;   //先把 z 暂时设成 y 本身,相当于：先乱猜一个比较大的答案
            uint256 x = y / 2 + 1;   //再造一个临时变量 x，先猜成 y/2 + 1(这也是一个“先随便猜一个起点”的做法)
            while (x < z) {   //当 x 还比 z 小的时候，就继续循环慢慢逼近真正答案(不断修正猜测，直到猜得差不多)
                z = x;   //先把目前更好的猜测 x 存到 z 里
                x = (y / x + x) / 2;   //【巴比伦算法核心更新公式】 为不断修正答案的步骤
            }   //循环结束
        } else if (y != 0) {   //如果 y 没有大于 3，但又不是 0，那说明它可能是 1、2、3
            z = 1;   //这种情况下，平方根整数结果就直接给 1
        }
    }
}








// ERC20: 区块链里非常常见的一种代币标准。导入它之后，这个合约就能更方便地创建和管理一种自己的代币。
// Q:为什么该合约需要ERC20？ A:因为AMM合约自己也要发一种LP代币(即股份币)，作为流动性份额证明。OpenZeppelin 的 ERC20 允许你在继承它的合约里调用 _mint 和 _burn 来创建或销毁这种份额代币。
// AMM核心数学部分：你往池子里放 A，池子就会按现在的 A、B 储备比例自动算出应该给你多少 B，而且因为你买得越多，价格会越变越贵，所以不可能一直按同样比例拿走。池子像一个跷跷板，你这边倒进很多 A，另一边能拿走的 B 会按规则变少。
// 滑点：你原本以为能换到这么多，结果真正到手比预想少太多，如果少得太夸张，这笔交易就取消。(保护用户措施)
// internal: 智能合约内部用
// pure:只做数学计算，不读链上状态、不改链上状态
// reserveA 和 reserveB 就是池子的库存
// addLiquidity() 是往池子里存两种币。
// removeLiquidity() 是拿股份币换回池子里的币
// swapAforB() 和 swapBforA() 是自动换币
// 把合约想象成一个自动饮料机，里面有两种饮料：A 和 B，有人可以往里面补货，补货的人拿到“股份票”，有人可以拿 A 换 B，或者拿 B 换 A，机器按数学规则自动定价，每次换饮料收一点手续费，奖励给补货的人
// transferFrom 是 ERC20 的标准函数，用在“由合约代替用户挪币”的情况，前提是用户先 approve 授权。OpenZeppelin 的 ERC20 文档也说明了 transferFrom 要求调用者有足够授权。
// min() 是为了在后续添加流动性时，按较小贡献来决定 LP 代币，避免多发。
// Solidity 没有内置 sqrt()，所以这里自己写了一个巴比伦算法版本，用来在第一次加流动性时计算 sqrt(amountA * amountB)