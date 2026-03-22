import { ref, computed } from 'vue'
import { useOperationLogStore } from '@/stores/operationLogStore'

export function useDay13() {
    const logStore = useOperationLogStore()
    
    // ========== 状态 ==========
    
    // 代币基本信息
    const tokenInfo = ref({
        name: 'Web3 Compass',
        symbol: 'WBT',
        decimals: 18,
        totalSupply: 1000000
    })
    
    // 角色地址定义
    const roles = {
        deployer: '0xDeployer7429aC95B2cF0e4b5F1F4E4e8e7D6c5B4A3210',
        alice: '0xAlice8F3a2B1c0D9e8F7A6B5C4D3E2F1A0B9C8D7E6F',
        bob: '0xBob5A6B7C8D9E0F1A2B3C4D5E6F7A8B9C0D1E2F'
    }
    
    // 余额映射: address => balance
    const balances = ref({
        [roles.deployer]: 1000000,
        [roles.alice]: 0,
        [roles.bob]: 0
    })
    
    // 授权额度映射: owner => spender => amount (嵌套mapping)
    const allowances = ref({
        [roles.deployer]: {
            [roles.alice]: 0,
            [roles.bob]: 0
        },
        [roles.alice]: {},
        [roles.bob]: {}
    })
    
    // 当前角色
    const currentRole = ref('deployer')
    
    // 事件日志
    const eventLog = ref([
        {
            icon: '🪙',
            name: 'Mint',
            details: 'Transfer(address(0), Deployer, 1,000,000 WBT) - 合约部署时铸造',
            timestamp: Date.now(),
            type: 'mint'
        }
    ])
    
    // ========== 计算属性 ==========
    
    const currentAddress = computed(() => roles[currentRole.value])
    
    // 获取角色名称
    const getRoleName = (address) => {
        if (address === roles.deployer) return 'Deployer'
        if (address === roles.alice) return 'Alice'
        if (address === roles.bob) return 'Bob'
        return address.slice(0, 6) + '...' + address.slice(-4)
    }
    
    // 格式化地址显示
    const formatAddress = (address) => {
        if (!address) return ''
        if (address === roles.deployer) return 'Deployer (0xDeployer...3210)'
        if (address === roles.alice) return 'Alice (0xAlice...7E6F)'
        if (address === roles.bob) return 'Bob (0xBob...E2F)'
        return address.slice(0, 10) + '...' + address.slice(-8)
    }
    
    // ========== 方法 ==========
    
    // 切换角色
    const switchRole = (role) => {
        currentRole.value = role
        const messages = {
            deployer: '✅ 已切换到 Deployer（合约部署者/代币持有者）！👉 执行转账操作来解锁 internal 和 virtual 函数！',
            alice: '✅ 已切换到 Alice（普通用户）！👉 让 Deployer 授权给你，然后执行代转账！',
            bob: '✅ 已切换到 Bob（可被授权者）！👉 让 Deployer 授权给你，然后执行代转账！'
        }

        // 记录操作日志
        logStore.addLog(13, '切换角色', messages[role])

        return {
            success: true,
            message: messages[role],
            hints: [],
            nextStep: ''
        }
    }
    
    // 查询余额
    const getBalance = (address) => {
        const balance = balances.value[address] || 0
        const roleName = getRoleName(address)

        // 记录操作日志（view 函数，无 Gas）
        logStore.addLog(13, '查询余额', `${roleName}: ${balance.toLocaleString()} WBT`)

        return {
            success: true,
            balance,
            message: `📊 查询成功！${roleName} 余额: ${balance.toLocaleString()} WBT 👉 执行转账来解锁 internal 和 virtual 函数！`,
            hints: [],
            nextStep: '💡 余额使用 mapping(address => uint256) 存储！👉 执行转账来解锁 internal 和 virtual 函数！'
        }
    }
    
    // 转账
    const transfer = (to, amount) => {
        const from = currentAddress.value
        const fromName = getRoleName(from)
        const toName = getRoleName(to)

        // 验证余额
        if (balances.value[from] < amount) {
            // 记录失败操作
            logStore.addLog(13, '转账失败', `余额不足: ${fromName} → ${toName}`)
            return {
                success: false,
                message: `❌ 转账失败！余额不足。当前余额: ${balances.value[from].toLocaleString()} WBT，尝试转账: ${amount.toLocaleString()} WBT`,
                hints: [],
                nextStep: ''
            }
        }

        // 验证地址
        if (to === '0x0000000000000000000000000000000000000000') {
            logStore.addLog(13, '转账失败', '接收地址不能是零地址')
            return {
                success: false,
                message: '❌ 转账失败！接收地址不能是零地址。',
                hints: [],
                nextStep: ''
            }
        }

        // 验证不能转给自己
        if (from === to) {
            logStore.addLog(13, '转账失败', '不能转账给自己')
            return {
                success: false,
                message: '❌ 转账失败！不能转账给自己。',
                hints: [],
                nextStep: ''
            }
        }

        // 执行转账
        balances.value[from] -= amount
        balances.value[to] = (balances.value[to] || 0) + amount

        // 记录事件
        eventLog.value.push({
            icon: '🟢',
            name: 'Transfer',
            details: `从: ${fromName} 到: ${toName} 数量: ${amount.toLocaleString()} WBT`,
            timestamp: Date.now(),
            type: 'transfer'
        })

        // 记录操作日志
        logStore.addLog(13, '转账', `${fromName} → ${toName}: ${amount.toLocaleString()} WBT`, 'transfer13')

        return {
            success: true,
            message: `✅ 转账成功！${fromName} 向 ${toName} 转账 ${amount.toLocaleString()} WBT 🎉 恭喜解锁：internal 和 virtual 函数！👉 点击查看代码了解所有知识点！`,
            hints: ['internal_function'],
            nextStep: '🔒 太棒了！transfer() 内部调用了 _transfer() 这个 internal 函数！同时解锁了 virtual 关键字！👉 点击查看代码了解所有知识点！'
        }
    }
    
    // 授权
    const approve = (spender, amount) => {
        const owner = currentAddress.value
        const ownerName = getRoleName(owner)
        const spenderName = getRoleName(spender)

        // 验证当前身份是 Deployer
        if (currentRole.value !== 'deployer') {
            logStore.addLog(13, '授权失败', '只有 Deployer 才能授权')
            return {
                success: false,
                message: '❌ 授权失败！只有代币持有者 Deployer 才能授权。请切换到 Deployer。',
                hints: [],
                nextStep: ''
            }
        }

        // 验证不能授权给自己
        if (owner === spender) {
            logStore.addLog(13, '授权失败', '不能授权给自己')
            return {
                success: false,
                message: '❌ 授权失败！不能授权给自己。',
                hints: [],
                nextStep: ''
            }
        }

        // 设置授权额度
        if (!allowances.value[owner]) {
            allowances.value[owner] = {}
        }
        allowances.value[owner][spender] = amount

        // 记录事件
        eventLog.value.push({
            icon: '🟡',
            name: 'Approval',
            details: `持有者: ${ownerName} 被授权者: ${spenderName} 额度: ${amount.toLocaleString()} WBT`,
            timestamp: Date.now(),
            type: 'approval'
        })

        // 记录操作日志
        logStore.addLog(13, '授权', `${ownerName} → ${spenderName}: ${amount.toLocaleString()} WBT`, 'approve13')

        return {
            success: true,
            message: `✅ 授权成功！${ownerName} 授权 ${spenderName} 可以使用 ${amount.toLocaleString()} WBT`,
            hints: [],
            nextStep: '👉 切换到 Bob 执行代转账来学习更多！'
        }
    }
    
    // 查询授权额度
    const getAllowance = (owner, spender) => {
        const allowance = allowances.value[owner]?.[spender] || 0
        const ownerName = getRoleName(owner)
        const spenderName = getRoleName(spender)

        // 记录操作日志（view 函数，无 Gas）
        logStore.addLog(13, '查询授权额度', `${spenderName} 可用 ${ownerName}: ${allowance.toLocaleString()} WBT`)

        return {
            success: true,
            allowance,
            message: `🔍 查询成功！${spenderName} 可使用 ${ownerName} 的额度: ${allowance.toLocaleString()} WBT 👉 切换到 Bob 执行代转账！`,
            hints: [],
            nextStep: '👉 切换到 Bob 执行代转账来学习 transferFrom！'
        }
    }
    
    // 代转账
    const transferFrom = (from, to, amount) => {
        const spender = currentAddress.value
        const spenderName = getRoleName(spender)
        const fromName = getRoleName(from)
        const toName = getRoleName(to)

        // 验证当前身份是 Bob
        if (currentRole.value !== 'bob') {
            logStore.addLog(13, '代转账失败', '只有 Bob 才能执行代转账')
            return {
                success: false,
                message: '❌ 代转账失败！只有被授权者 Bob 才能执行代转账。请切换到 Bob。',
                hints: [],
                nextStep: ''
            }
        }

        // 验证只能从 Deployer 转账
        if (from !== roles.deployer) {
            logStore.addLog(13, '代转账失败', 'Bob 只被 Deployer 授权')
            return {
                success: false,
                message: '❌ 代转账失败！Bob 只被 Deployer 授权，只能从 Deployer 账户代转账。',
                hints: [],
                nextStep: ''
            }
        }

        // 验证授权额度
        const currentAllowance = allowances.value[from]?.[spender] || 0
        if (currentAllowance < amount) {
            logStore.addLog(13, '代转账失败', `授权额度不足: ${currentAllowance.toLocaleString()} WBT`)
            return {
                success: false,
                message: `❌ 授权额度不足！Bob 只能使用 Deployer 的 ${currentAllowance.toLocaleString()} WBT，尝试转账: ${amount.toLocaleString()} WBT`,
                hints: [],
                nextStep: ''
            }
        }

        // 验证余额
        if (balances.value[from] < amount) {
            logStore.addLog(13, '代转账失败', `余额不足: ${fromName}`)
            return {
                success: false,
                message: `❌ 余额不足！${fromName} 当前余额: ${balances.value[from].toLocaleString()} WBT`,
                hints: [],
                nextStep: ''
            }
        }

        // 执行代转账
        balances.value[from] -= amount
        balances.value[to] = (balances.value[to] || 0) + amount
        allowances.value[from][spender] -= amount

        // 记录事件
        eventLog.value.push({
            icon: '🟢',
            name: 'Transfer',
            details: `从: ${fromName} 到: ${toName} 数量: ${amount.toLocaleString()} WBT (by ${spenderName})`,
            timestamp: Date.now(),
            type: 'transfer'
        })

        // 记录操作日志
        logStore.addLog(13, '代转账', `${spenderName} 代替 ${fromName} → ${toName}: ${amount.toLocaleString()} WBT`, 'transferFrom13')

        return {
            success: true,
            message: `✅ 代转账成功！${spenderName} 代替 ${fromName} 向 ${toName} 转账 ${amount.toLocaleString()} WBT 👉 点击查看代码了解 virtual 关键字！`,
            hints: [],
            nextStep: '🎉 太棒了！你已掌握 MyToken 全部核心功能！👉 点击查看代码了解 virtual 关键字！'
        }
    }
    
    // 格式化时间
    const formatTime = (timestamp) => {
        const date = new Date(timestamp)
        return date.toLocaleTimeString('zh-CN', {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        })
    }

    // 实时数据接口（供 Sidebar 使用）
    const realtimeData = computed(() => ({
        gasUsage: logStore.getDayGasUsage(13),
        ethCost: logStore.getDayEthCost(13),
        operationCount: logStore.getDayOperationCount(13)
    }))

    return {
        // 状态
        tokenInfo,
        roles,
        balances,
        allowances,
        currentRole,
        currentAddress,
        eventLog,

        // 实时数据接口
        realtimeData,

        // 方法
        switchRole,
        getBalance,
        transfer,
        approve,
        getAllowance,
        transferFrom,
        getRoleName,
        formatAddress,
        formatTime
    }
}
