import { computed, ref } from 'vue'
import { useContractStore } from '@/stores/contractStore'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'

export function useDay17() {
    const contractStore = useContractStore()
    const progressStore = useProgressStore()
    const logStore = useOperationLogStore()

    const day17Contract = contractStore.contracts.day17

    // ========== 状态定义 ==========
    const currentRole = ref('owner')  // 'owner' | 'user'
    const currentVersion = ref('V1')  // 'V1' | 'V2'
    const upgraded = ref(false)
    const isUpgrading = ref(false)
    const justUpgraded = ref(false)

    // 计划管理
    const plans = ref([])
    const newPlanId = ref(1)
    const newPlanPrice = ref(0.1)
    const newPlanDuration = ref(30)

    // 订阅状态
    const selectedPlanId = ref(1)
    const subscription = ref(null)

    // 存储状态
    const logicContractAddress = ref('0xV1LogicContractAddress')
    const ownerAddress = ref('0xOwnerAddress')

    // ========== 计算属性 ==========
    const plansCount = computed(() => plans.value.length)
    const subscriptionsCount = computed(() => subscription.value ? 1 : 0)
    const hasSubscription = computed(() => subscription.value !== null)
    const selectedPlanPrice = computed(() => {
        const plan = plans.value.find(p => p.id === selectedPlanId.value)
        return plan ? plan.price : 0
    })

    const remainingTime = computed(() => {
        if (!subscription.value || !subscription.value.paused) return 0
        return subscription.value.expiry
    })

    const subscriptionStatusText = computed(() => {
        if (!subscription.value) return '未订阅'
        if (subscription.value.paused) return '已暂停'
        const now = Math.floor(Date.now() / 1000)
        if (subscription.value.expiry > now) return '有效'
        return '已过期'
    })

    const subscriptionStatusClass = computed(() => {
        if (!subscription.value) return 'status-inactive'
        if (subscription.value.paused) return 'status-paused'
        const now = Math.floor(Date.now() / 1000)
        if (subscription.value.expiry > now) return 'status-active'
        return 'status-expired'
    })

    // ========== 操作方法 ==========

    // 创建计划
    const createPlan = () => {
        const planId = newPlanId.value
        const price = parseFloat(newPlanPrice.value)
        const duration = newPlanDuration.value * 24 * 60 * 60 // 转换为秒

        if (plans.value.find(p => p.id === planId)) {
            return {
                success: false,
                message: '❌ 计划 ID 已存在',
                hints: [],
                nextStep: ''
            }
        }

        plans.value.push({
            id: planId,
            price: price,
            duration: duration,
            durationDays: newPlanDuration.value
        })

        // 自动选择新创建的计划
        selectedPlanId.value = planId

        // 记录操作日志
        logStore.addLog(
            17,
            '创建计划',
            `计划 ${planId}: ${price} ETH, ${newPlanDuration.value}天`,
            'createPlan17'
        )

        progressStore.incrementInteraction(17)

        const plansCount = plans.value.length
        if (plansCount === 1) {
            return {
                success: true,
                message: `✅ 计划 ${planId} 创建成功！存储在 planPrices[${planId}] 中！`,
                hints: [],
                nextStep: '📊 再创建 1 个计划即可解锁升级功能！👉 创建第2个计划！'
            }
        } else {
            return {
                success: true,
                message: `✅ 计划 ${planId} 创建成功！`,
                hints: [],
                nextStep: '🎉 现在可以升级到 V2 了！👉 点击"升级到 V2"按钮，体验合约升级！'
            }
        }
    }

    // 升级合约
    const upgradeToV2 = () => {
        if (upgraded.value) {
            return {
                success: false,
                message: '❌ 合约已经升级过了',
                hints: [],
                nextStep: ''
            }
        }

        if (plans.value.length < 2) {
            return {
                success: false,
                message: '❌ 需要至少 2 个计划才能升级',
                hints: [],
                nextStep: `💡 当前只有 ${plans.value.length} 个计划，请再创建 ${2 - plans.value.length} 个！`
            }
        }

        isUpgrading.value = true

        // 模拟升级过程
        setTimeout(() => {
            upgraded.value = true
            currentVersion.value = 'V2'
            logicContractAddress.value = '0xV2LogicContractAddress'
            justUpgraded.value = true
            isUpgrading.value = false

            // 3秒后重置动画状态
            setTimeout(() => {
                justUpgraded.value = false
            }, 3000)
        }, 1000)

        // 记录操作日志
        logStore.addLog(
            17,
            '升级合约',
            'V1 → V2',
            'upgradeTo17'
        )

        progressStore.incrementInteraction(17)
        progressStore.unlockConcept(17, 'upgrade_mechanism')
        progressStore.unlockConcept(17, 'logic_contract')

        return {
            success: true,
            message: '🚀 合约已升级到 V2！逻辑合约地址已更新！',
            hints: ['upgrade_mechanism', 'logic_contract'],
            nextStep: '⚡ 恭喜解锁：升级机制 + 逻辑合约！👉 切换到 User 身份，执行订阅操作！'
        }
    }

    // 切换到 V1
    const switchToV1 = () => {
        if (!upgraded.value) {
            return {
                success: false,
                message: '❌ 合约尚未升级',
                hints: [],
                nextStep: ''
            }
        }
        currentVersion.value = 'V1'
        logicContractAddress.value = '0xV1LogicContractAddress'

        return {
            success: true,
            message: '⚙️ 已切换到 V1 逻辑合约',
            hints: [],
            nextStep: ''
        }
    }

    // 切换到 V2
    const switchToV2 = () => {
        if (!upgraded.value) {
            return {
                success: false,
                message: '❌ 合约尚未升级',
                hints: [],
                nextStep: ''
            }
        }
        currentVersion.value = 'V2'
        logicContractAddress.value = '0xV2LogicContractAddress'

        return {
            success: true,
            message: '⚡ 已切换到 V2 逻辑合约',
            hints: [],
            nextStep: ''
        }
    }

    // 订阅
    const subscribe = () => {
        const planId = selectedPlanId.value
        const plan = plans.value.find(p => p.id === planId)

        if (!plan) {
            return {
                success: false,
                message: '❌ 计划不存在',
                hints: [],
                nextStep: ''
            }
        }

        const now = Math.floor(Date.now() / 1000)
        const expiry = now + plan.duration

        subscription.value = {
            planId: planId,
            expiry: expiry,
            paused: false
        }

        // 记录操作日志
        logStore.addLog(
            17,
            '订阅计划',
            `计划 ${planId}: ${plan.price} ETH`,
            'subscribe17'
        )

        progressStore.incrementInteraction(17)

        // 首次订阅解锁 fallback_function
        const unlockedConcepts = progressStore.getDayProgress(17).unlockedConcepts
        if (!unlockedConcepts.includes('fallback_function')) {
            progressStore.unlockConcept(17, 'fallback_function')
            return {
                success: true,
                message: `✅ 订阅成功！您已订阅计划 ${planId}！`,
                hints: ['fallback_function'],
                nextStep: '🔒 恭喜解锁：回退函数！调用通过 fallback 委托给逻辑合约！👉 查询订阅状态，查看升级后数据是否仍然存在！'
            }
        }

        return {
            success: true,
            message: `✅ 订阅成功！您已订阅计划 ${planId}！`,
            hints: [],
            nextStep: ''
        }
    }

    // 暂停订阅
    const pauseSubscription = () => {
        if (!subscription.value) {
            return {
                success: false,
                message: '❌ 您没有订阅',
                hints: [],
                nextStep: ''
            }
        }

        if (subscription.value.paused) {
            return {
                success: false,
                message: '❌ 订阅已经处于暂停状态',
                hints: [],
                nextStep: ''
            }
        }

        const now = Math.floor(Date.now() / 1000)
        if (subscription.value.expiry <= now) {
            return {
                success: false,
                message: '❌ 订阅已过期',
                hints: [],
                nextStep: ''
            }
        }

        // 保存剩余时间
        const remaining = subscription.value.expiry - now
        subscription.value.paused = true
        subscription.value.expiry = remaining

        // 记录操作日志
        logStore.addLog(
            17,
            '暂停订阅',
            `剩余时间: ${remaining} 秒`,
            'pauseSubscription17'
        )

        progressStore.incrementInteraction(17)

        // 首次暂停解锁 version_control
        const unlockedConcepts = progressStore.getDayProgress(17).unlockedConcepts
        if (!unlockedConcepts.includes('version_control')) {
            progressStore.unlockConcept(17, 'version_control')
            return {
                success: true,
                message: '⏸️ 订阅已暂停！剩余时间已保存！',
                hints: ['version_control'],
                nextStep: '🚀 恭喜解锁：版本控制！这是 V2 新增的功能！👉 恢复订阅来完成所有学习！'
            }
        }

        return {
            success: true,
            message: '⏸️ 订阅已暂停！剩余时间已保存！',
            hints: [],
            nextStep: ''
        }
    }

    // 恢复订阅
    const resumeSubscription = () => {
        if (!subscription.value) {
            return {
                success: false,
                message: '❌ 您没有订阅',
                hints: [],
                nextStep: ''
            }
        }

        if (!subscription.value.paused) {
            return {
                success: false,
                message: '❌ 订阅未处于暂停状态',
                hints: [],
                nextStep: ''
            }
        }

        const now = Math.floor(Date.now() / 1000)
        const remaining = subscription.value.expiry

        // 重新计算过期时间
        subscription.value.paused = false
        subscription.value.expiry = now + remaining

        // 记录操作日志
        logStore.addLog(
            17,
            '恢复订阅',
            `新的过期时间: ${subscription.value.expiry}`,
            'resumeSubscription17'
        )

        progressStore.incrementInteraction(17)

        return {
            success: true,
            message: '▶️ 订阅已恢复！过期时间已重新计算！',
            hints: [],
            nextStep: '🎉 恭喜你已掌握 Day 17 全部核心功能！👉 查看完整代码来巩固知识！'
        }
    }

    // 查询订阅状态
    const checkSubscription = () => {
        if (!subscription.value) {
            return {
                success: false,
                message: '❌ 您没有订阅',
                hints: [],
                nextStep: ''
            }
        }

        const now = Math.floor(Date.now() / 1000)
        let status = ''

        if (subscription.value.paused) {
            status = `已暂停，剩余 ${subscription.value.expiry} 秒`
        } else if (subscription.value.expiry > now) {
            const remaining = subscription.value.expiry - now
            status = `有效，剩余 ${Math.floor(remaining / 86400)} 天 ${Math.floor((remaining % 86400) / 3600)} 小时`
        } else {
            status = '已过期'
        }

        // 记录操作日志
        logStore.addLog(
            17,
            '查询订阅',
            `计划 ${subscription.value.planId}: ${status}`,
            null
        )

        progressStore.incrementInteraction(17)

        // 升级后首次查询解锁 data_persistence
        const unlockedConcepts = progressStore.getDayProgress(17).unlockedConcepts
        if (upgraded.value && !unlockedConcepts.includes('data_persistence')) {
            progressStore.unlockConcept(17, 'data_persistence')
            return {
                success: true,
                message: `📊 您的订阅状态: ${status}`,
                hints: ['data_persistence'],
                nextStep: '🏗️ 恭喜解锁：数据持久化！升级后数据保持不变！👉 使用 V2 新功能（暂停/恢复）来对比版本差异！'
            }
        }

        return {
            success: true,
            message: `📊 您的订阅状态: ${status}`,
            hints: [],
            nextStep: ''
        }
    }

    // 切换角色
    const switchRole = (role) => {
        currentRole.value = role

        if (role === 'owner') {
            return {
                success: true,
                message: '✅ 已切换到 Owner 身份！',
                hints: [],
                nextStep: '👉 创建订阅计划来体验数据存储！'
            }
        } else {
            return {
                success: true,
                message: '✅ 已切换到 User 身份！',
                hints: [],
                nextStep: '👉 选择计划并执行订阅，体验 fallback 委托调用！'
            }
        }
    }

    // ========== 实时数据 ==========
    const realtimeData = computed(() => ({
        gasUsage: logStore.getDayGasUsage(17),
        ethCost: logStore.getDayEthCost(17),
        operationCount: logStore.getDayOperationCount(17)
    }))

    return {
        // 状态
        currentRole,
        currentVersion,
        upgraded,
        isUpgrading,
        justUpgraded,
        plans,
        newPlanId,
        newPlanPrice,
        newPlanDuration,
        selectedPlanId,
        subscription,
        logicContractAddress,
        ownerAddress,

        // 计算属性
        plansCount,
        subscriptionsCount,
        hasSubscription,
        selectedPlanPrice,
        remainingTime,
        subscriptionStatusText,
        subscriptionStatusClass,

        // 方法
        createPlan,
        upgradeToV2,
        switchToV1,
        switchToV2,
        subscribe,
        pauseSubscription,
        resumeSubscription,
        checkSubscription,
        switchRole,

        // 实时数据
        realtimeData
    }
}
