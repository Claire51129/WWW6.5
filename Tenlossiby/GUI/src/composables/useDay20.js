import { ref, computed } from 'vue'
import { useOperationLogStore } from '@/stores/operationLogStore'
import { useProgressStore } from '@/stores/progressStore'

export function useDay20() {
    const logStore = useOperationLogStore()
    const progressStore = useProgressStore()

    // 合约状态
    const vaultBalance = ref(10) // 金库总余额 (ETH)
    const userBalances = ref({
        '0xAttacker': 1,  // 攻击者存入的余额
        '0xUserA': 5,     // 用户A存入的余额
        '0xUserB': 3      // 用户B存入的余额
    })
    const reentrancyStatus = ref(1) // 1 = _NOT_ENTERED, 2 = _ENTERED
    const attackCount = ref(0) // 攻击次数计数
    const stolenAmount = ref(0) // 窃取金额
    const isAttacking = ref(false) // 是否正在攻击
    const attackHistory = ref([]) // 攻击历史记录

    // 常量
    const _NOT_ENTERED = 1
    const _ENTERED = 2

    // 获取用户余额
    const getUserBalance = (user) => {
        return userBalances.value[user] || 0
    }

    // 存款函数
    const deposit = (user, amount) => {
        const gasKey = 'deposit20'
        
        if (amount <= 0) {
            logStore.addLog(20, 'deposit', '存款金额必须大于0', false, gasKey)
            return {
                success: false,
                message: '❌ 存款金额必须大于0',
                hints: [],
                nextStep: ''
            }
        }

        // 更新余额
        userBalances.value[user] = (userBalances.value[user] || 0) + amount
        vaultBalance.value += amount

        logStore.addLog(20, 'deposit', `用户 ${user} 存入 ${amount} ETH`, true, gasKey)

        return {
            success: true,
            message: `✅ 成功存入 ${amount} ETH！`,
            hints: ['deposit_function'],
            nextStep: '👉 现在尝试攻击漏洞版本，观察重入攻击如何工作！'
        }
    }

    // 有漏洞的提款函数 - 先发送ETH，后更新余额
    const vulnerableWithdraw = (user, maxReentrancy = 5) => {
        const gasKey = 'vulnerableWithdraw20'
        const unlockedConcepts = progressStore.getDayProgress(20)?.unlockedConcepts || []
        
        const userBalance = userBalances.value[user] || 0
        
        if (userBalance <= 0) {
            logStore.addLog(20, 'vulnerableWithdraw', '余额不足', false, gasKey)
            return {
                success: false,
                message: '❌ 余额不足，无法提款',
                hints: [],
                nextStep: ''
            }
        }

        // 开始攻击，设置状态为true
        isAttacking.value = true

        // 模拟重入攻击
        let totalStolen = 0
        let reentrancyCount = 0
        const history = []
        
        // 漏洞：先发送ETH，后更新余额
        // 攻击者可以在receive()中再次调用withdraw
        while (reentrancyCount < maxReentrancy && vaultBalance.value >= userBalance) {
            // 发送ETH（这会触发攻击者的receive()函数）
            totalStolen += userBalance
            vaultBalance.value -= userBalance
            
            history.push({
                round: reentrancyCount + 1,
                amount: userBalance,
                vaultBalance: vaultBalance.value
            })
            
            reentrancyCount++
            
            // 在漏洞版本中，余额还未更新，攻击者可以再次提款
            // 模拟攻击者的receive()函数再次调用withdraw
        }
        
        // 最后才更新余额（漏洞所在！）
        userBalances.value[user] = 0

        // 更新攻击状态
        attackCount.value = reentrancyCount
        stolenAmount.value = totalStolen
        attackHistory.value = history
        // 攻击动画完成后重置状态（通过setTimeout模拟攻击过程）
        setTimeout(() => {
            isAttacking.value = false
        }, 1000)

        logStore.addLog(20, 'vulnerableWithdraw', 
            `重入攻击成功！${reentrancyCount}次调用，窃取${totalStolen}ETH`, true, gasKey)

        const hints = ['vulnerable_withdraw']
        if (!unlockedConcepts.includes('fallback_receive')) {
            hints.push('fallback_receive')
        }

        return {
            success: true,
            message: `🚨 重入攻击成功！通过 ${reentrancyCount} 次递归调用，窃取了 ${totalStolen} ETH！`,
            hints,
            nextStep: '💡 观察攻击如何重复提款！👉 查看防护机制了解如何修复！',
            attackDetails: {
                count: reentrancyCount,
                stolen: totalStolen,
                history
            }
        }
    }

    // 安全的提款函数 - 使用重入锁和CEI模式
    const safeWithdraw = (user) => {
        const gasKey = 'safeWithdraw20'
        
        const userBalance = userBalances.value[user] || 0
        
        if (userBalance <= 0) {
            logStore.addLog(20, 'safeWithdraw', '余额不足', false, gasKey)
            return {
                success: false,
                message: '❌ 余额不足，无法提款',
                hints: [],
                nextStep: ''
            }
        }

        // 开始攻击，设置状态为true
        isAttacking.value = true

        // 检查重入锁
        if (reentrancyStatus.value === _ENTERED) {
            isAttacking.value = false
            logStore.addLog(20, 'safeWithdraw', '重入调用被阻止', false, gasKey)
            return {
                success: false,
                message: '🔒 重入调用被阻止！Reentrant call blocked',
                hints: ['reentrancy_guard'],
                nextStep: '✅ 攻击被阻止！👉 查看代码对比巩固知识！',
                blocked: true
            }
        }

        // 1. Checks: 验证条件
        // 已在上面的检查中完成
        
        // 2. Effects: 先更新状态（CEI模式）
        reentrancyStatus.value = _ENTERED // 锁定
        userBalances.value[user] = 0 // 先更新余额！
        vaultBalance.value -= userBalance
        
        // 3. Interactions: 最后进行外部调用
        // 发送ETH
        
        // 解锁
        reentrancyStatus.value = _NOT_ENTERED

        logStore.addLog(20, 'safeWithdraw',
            `安全提款成功！提取${userBalance}ETH`, true, gasKey)

        // 攻击完成后重置状态
        isAttacking.value = false

        return {
            success: true,
            message: `✅ 安全提款成功！提取了 ${userBalance} ETH（重入锁保护）`,
            hints: ['reentrancy_guard'],
            nextStep: '✅ 攻击被阻止！👉 查看代码对比巩固知识！'
        }
    }

    // 重置攻击状态
    const resetAttack = () => {
        attackCount.value = 0
        stolenAmount.value = 0
        isAttacking.value = false
        attackHistory.value = []
        reentrancyStatus.value = _NOT_ENTERED
    }

    // 重置合约状态
    const resetVault = () => {
        vaultBalance.value = 10
        userBalances.value = {
            '0xAttacker': 1,
            '0xUserA': 5,
            '0xUserB': 3
        }
        resetAttack()
        
        logStore.addLog(20, 'reset', '重置金库状态', true, null)
        
        return {
            success: true,
            message: '✅ 金库状态已重置',
            hints: [],
            nextStep: ''
        }
    }

    // 获取金库状态
    const getVaultStatus = () => {
        return {
            balance: vaultBalance.value,
            userBalances: { ...userBalances.value },
            reentrancyStatus: reentrancyStatus.value === _ENTERED ? '🔒 已锁定' : '🔓 未锁定',
            isLocked: reentrancyStatus.value === _ENTERED
        }
    }

    // 实时数据
    const realtimeData = computed(() => {
        return {
            gasUsage: logStore.getDayGasUsage(20),
            ethCost: logStore.getDayEthCost(20),
            operationCount: logStore.getDayOperationCount(20)
        }
    })

    return {
        // 状态
        vaultBalance,
        userBalances,
        reentrancyStatus,
        attackCount,
        stolenAmount,
        isAttacking,
        attackHistory,
        
        // 常量
        _NOT_ENTERED,
        _ENTERED,
        
        // 方法
        deposit,
        vulnerableWithdraw,
        safeWithdraw,
        resetAttack,
        resetVault,
        getVaultStatus,
        getUserBalance,
        
        // 实时数据
        realtimeData
    }
}
