import { ref, computed } from 'vue'
import { useOperationLogStore } from '@/stores/operationLogStore'
import { useProgressStore } from '@/stores/progressStore'

export function useDay18() {
    const logStore = useOperationLogStore()
    const progressStore = useProgressStore()

    // 状态变量
    const currentUser = ref('Alice')
    const currentRole = ref('farmer') // farmer, admin
    const ethPrice = ref(300000000000) // Chainlink 返回的价格 (8位小数精度)
    const rainfall = ref(350) // 当前降雨量 (mm)
    const hasInsurance = ref({
        'Alice': false,
        'Bob': false,
        'Carol': false
    })
    const lastClaimTimestamp = ref({
        'Alice': 0,
        'Bob': 0,
        'Carol': 0
    })
    const contractBalance = ref(5000000000000000000) // 5 ETH
    const totalPayout = ref(0)
    const totalPremium = ref(0)

    // 常量
    const RAINFALL_THRESHOLD = 500
    const INSURANCE_PREMIUM_USD = 10
    const INSURANCE_PAYOUT_USD = 50
    const COOLDOWN_PERIOD = 24 * 60 * 60 * 1000 // 24小时（毫秒）

    // 计算属性
    const premiumInEth = computed(() => {
        // (USD金额 × 1e26) / ETH价格
        // 1e26 = 1e18(wei) × 1e8(Chainlink精度)
        return (INSURANCE_PREMIUM_USD * 1e26) / ethPrice.value
    })

    const payoutInEth = computed(() => {
        return (INSURANCE_PAYOUT_USD * 1e26) / ethPrice.value
    })

    const isDrought = computed(() => {
        return rainfall.value < RAINFALL_THRESHOLD
    })

    const canClaim = computed(() => {
        const user = currentUser.value
        const lastClaim = lastClaimTimestamp.value[user] || 0
        const now = Date.now()
        return hasInsurance.value[user] && (now - lastClaim >= COOLDOWN_PERIOD)
    })

    const cooldownRemaining = computed(() => {
        const user = currentUser.value
        const lastClaim = lastClaimTimestamp.value[user] || 0
        const now = Date.now()
        const remaining = COOLDOWN_PERIOD - (now - lastClaim)
        return remaining > 0 ? remaining : 0
    })

    const cooldownStatus = computed(() => {
        if (!hasInsurance.value[currentUser.value]) {
            return { status: 'no_insurance', text: '未投保' }
        }
        if (canClaim.value) {
            return { status: 'available', text: '可索赔' }
        }
        return { status: 'cooldown', text: '冷却中' }
    })

    // 格式化函数
    const formatEth = (wei) => {
        return (wei / 1e18).toFixed(4)
    }

    const formatUsd = (price) => {
        return (price / 1e8).toFixed(2)
    }

    const formatTime = (ms) => {
        if (ms <= 0) return '00:00:00'
        const hours = Math.floor(ms / (1000 * 60 * 60))
        const minutes = Math.floor((ms % (1000 * 60 * 60)) / (1000 * 60))
        const seconds = Math.floor((ms % (1000 * 60)) / 1000)
        return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
    }

    // 操作函数
    const updateRainfall = () => {
        // 生成随机降雨量 (0-999)
        rainfall.value = Math.floor(Math.random() * 1000)

        logStore.addLog(18, '更新天气数据', `降雨量更新为 ${rainfall.value}mm`, 'checkRainfall18')

        return {
            success: true,
            message: `🌧️ 天气数据已更新！当前降雨量: ${rainfall.value}mm`,
            rainfall: rainfall.value,
            hints: ['random_generation'],
            nextStep: isDrought.value
                ? '⚠️ 干旱警报！降雨量低于阈值，可以申请赔付。'
                : '✅ 天气正常，降雨量高于阈值。'
        }
    }

    const checkRainfall = () => {
        logStore.addLog(18, '查询天气数据', `当前降雨量: ${rainfall.value}mm`, 'checkRainfall18')

        return {
            success: true,
            message: `🔍 查询结果：当前降雨量 ${rainfall.value}mm，阈值 ${RAINFALL_THRESHOLD}mm`,
            rainfall: rainfall.value,
            isDrought: isDrought.value,
            nextStep: isDrought.value
                ? '⚠️ 干旱状态！符合索赔条件。'
                : '✅ 正常状态，不符合索赔条件。'
        }
    }

    const purchaseInsurance = () => {
        const user = currentUser.value

        if (hasInsurance.value[user]) {
            return {
                success: false,
                message: '❌ 您已经购买了保险！'
            }
        }

        const premium = premiumInEth.value

        // 模拟扣除 ETH
        hasInsurance.value[user] = true
        totalPremium.value += premium
        contractBalance.value += premium

        logStore.addLog(18, '购买保险', `支付保费 ${formatEth(premium)} ETH`, 'purchaseInsurance18')

        return {
            success: true,
            message: `🎉 保险购买成功！支付保费 ${formatEth(premium)} ETH ($${INSURANCE_PREMIUM_USD})`,
            hints: ['purchase_insurance', 'price_conversion'],
            nextStep: '👉 当降雨量低于500mm时，可以申请赔付。注意：24小时内只能索赔一次！'
        }
    }

    const claimPayout = () => {
        const user = currentUser.value

        if (!hasInsurance.value[user]) {
            return {
                success: false,
                message: '❌ 您尚未购买保险！请先购买保险。',
                nextStep: '👉 点击"购买保险"按钮购买保险。'
            }
        }

        if (!isDrought.value) {
            return {
                success: false,
                message: `❌ 当前降雨量 ${rainfall.value}mm 高于阈值 ${RAINFALL_THRESHOLD}mm，不符合索赔条件。`,
                nextStep: '👉 等待干旱发生或更新天气数据。'
            }
        }

        const lastClaim = lastClaimTimestamp.value[user] || 0
        const now = Date.now()

        if (now - lastClaim < COOLDOWN_PERIOD) {
            const remaining = COOLDOWN_PERIOD - (now - lastClaim)
            return {
                success: false,
                message: `⏱️ 冷却期中！剩余时间: ${formatTime(remaining)}`,
                hints: ['cooldown_mechanism'],
                nextStep: '👉 使用"⏩ 快进24小时"按钮跳过冷却期，或等待时间结束。'
            }
        }

        const payout = payoutInEth.value

        if (contractBalance.value < payout) {
            return {
                success: false,
                message: '❌ 合约余额不足，无法赔付！'
            }
        }

        // 执行赔付
        lastClaimTimestamp.value[user] = now
        totalPayout.value += payout
        contractBalance.value -= payout

        logStore.addLog(18, '申请赔付', `获得赔付 ${formatEth(payout)} ETH`, 'claimPayout18')

        return {
            success: true,
            message: `💸 赔付成功！获得 ${formatEth(payout)} ETH ($${INSURANCE_PAYOUT_USD})`,
            hints: ['parametric_payout'],
            nextStep: '⏱️ 已触发24小时冷却期！点击"了解冷却期机制"学习更多。'
        }
    }

    const fastForwardTime = () => {
        const user = currentUser.value
        const lastClaim = lastClaimTimestamp.value[user] || 0

        if (lastClaim === 0) {
            return {
                success: false,
                message: '❌ 您还没有进行过索赔！'
            }
        }

        if (canClaim.value) {
            return {
                success: false,
                message: '✅ 您已经可以索赔了，无需快进！'
            }
        }

        // 快进24小时
        lastClaimTimestamp.value[user] = lastClaim - COOLDOWN_PERIOD

        logStore.addLog(18, '快进时间', '跳过24小时冷却期', 'fastForwardTime18')

        return {
            success: true,
            message: '⏩ 时间已快进24小时！冷却期已结束。',
            hints: ['cooldown_mechanism'],
            nextStep: '👉 现在可以再次申请赔付了！'
        }
    }

    const withdrawBalance = () => {
        if (currentRole.value !== 'admin') {
            return {
                success: false,
                message: '❌ 只有管理员可以提取余额！'
            }
        }

        const amount = contractBalance.value
        contractBalance.value = 0

        logStore.addLog(18, '提取余额', `提取 ${formatEth(amount)} ETH`, 'withdrawBalance18')

        return {
            success: true,
            message: `💸 提取成功！共提取 ${formatEth(amount)} ETH`,
            hints: ['contract_balance'],
            nextStep: '👉 合约余额已清零。'
        }
    }

    const switchUser = (user) => {
        currentUser.value = user
        currentRole.value = 'farmer'
    }

    const switchToAdmin = () => {
        currentRole.value = 'admin'
        currentUser.value = 'Owner'
    }

    const updateEthPrice = () => {
        // 模拟价格波动 (±5%)
        const variation = 0.95 + Math.random() * 0.1
        ethPrice.value = Math.floor(300000000000 * variation)

        return {
            success: true,
            message: `💰 ETH价格已更新！当前价格: $${formatUsd(ethPrice.value)}`
        }
    }

    // 实时数据 - 使用标准格式
    const realtimeData = computed(() => ({
        gasUsage: logStore.getDayGasUsage(18),
        ethCost: logStore.getDayEthCost(18),
        operationCount: logStore.getDayOperationCount(18)
    }))

    return {
        // 状态
        currentUser,
        currentRole,
        ethPrice,
        rainfall,
        hasInsurance,
        lastClaimTimestamp,
        contractBalance,
        totalPayout,
        totalPremium,

        // 常量
        RAINFALL_THRESHOLD,
        INSURANCE_PREMIUM_USD,
        INSURANCE_PAYOUT_USD,

        // 计算属性
        premiumInEth,
        payoutInEth,
        isDrought,
        canClaim,
        cooldownRemaining,
        cooldownStatus,

        // 格式化函数
        formatEth,
        formatUsd,
        formatTime,

        // 操作函数
        updateRainfall,
        checkRainfall,
        purchaseInsurance,
        claimPayout,
        fastForwardTime,
        withdrawBalance,
        switchUser,
        switchToAdmin,
        updateEthPrice,

        // 实时数据
        realtimeData
    }
}
