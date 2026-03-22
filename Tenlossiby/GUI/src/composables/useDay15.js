import { ref, computed } from 'vue'
import { useOperationLogStore } from '@/stores/operationLogStore'

export function useDay15() {
    const logStore = useOperationLogStore()

    // ========== 状态 ==========

    // 提案计数器（用于生成唯一ID）
    const proposalCounter = ref(0)

    // 提案列表
    const proposals = ref([])

    // 选民投票记录（位运算存储）
    // 每个 uint256 可以存储 256 个提案的投票状态
    const voterRegistry = ref({
        '0xUser1234567890abcdef': 0n,  // 用户地址
        '0xAlice1234567890abcdef': 0n,  // Alice
        '0xBob1234567890abcdef': 0n     // Bob
    })

    // 当前用户地址
    const currentAddress = ref('0xUser1234567890abcdef')

    // 事件日志
    const eventLog = ref([])

    // ========== 计算属性 ==========

    // 获取当前用户的投票位图
    const currentVoterData = computed(() => {
        return voterRegistry.value[currentAddress.value] || 0n
    })

    // 获取活跃提案
    const activeProposals = computed(() => {
        const now = Date.now()
        return proposals.value.filter(p => p.endTime > now && !p.executed)
    })

    // 获取已结束提案
    const endedProposals = computed(() => {
        const now = Date.now()
        return proposals.value.filter(p => p.endTime <= now && !p.executed)
    })

    // 获取已执行提案
    const executedProposals = computed(() => {
        return proposals.value.filter(p => p.executed)
    })

    // 格式化地址显示
    const formatAddress = (address) => {
        if (!address) return ''
        if (address === currentAddress.value) return '你 (0xUser...cdef)'
        if (address === '0xAlice1234567890abcdef') return 'Alice (0xAl...cdef)'
        if (address === '0xBob1234567890abcdef') return 'Bob (0xBob...cdef)'
        return address.slice(0, 10) + '...' + address.slice(-8)
    }

    // 格式化时间显示
    const formatTime = (timestamp) => {
        const date = new Date(timestamp)
        return date.toLocaleTimeString('zh-CN', {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        })
    }

    // 格式化剩余时间
    const formatRemainingTime = (endTime) => {
        const now = Date.now()
        const remaining = Math.max(0, endTime - now)
        const seconds = Math.floor(remaining / 1000)
        if (seconds < 60) return `${seconds}秒`
        const minutes = Math.floor(seconds / 60)
        return `${minutes}分${seconds % 60}秒`
    }

    // 获取提案状态
    const getProposalStatus = (proposal) => {
        const now = Date.now()
        if (proposal.executed) return { text: '已执行', class: 'executed' }
        if (proposal.endTime <= now) return { text: '已结束', class: 'ended' }
        return { text: '活跃', class: 'active' }
    }

    // ========== 方法 ==========

    // 创建提案
    const createProposal = (name, durationMinutes) => {
        if (!name || name.trim() === '') {
            return {
                success: false,
                error: '❌ 请输入提案名称！',
                hint: '👝 提案名称不能为空！'
            }
        }

        if (!durationMinutes || durationMinutes < 1) {
            return {
                success: false,
                error: '❌ 请输入有效的持续时间（至少1分钟）！',
                hint: '⏰ 持续时间必须大于0！'
            }
        }

        proposalCounter.value++
        const proposalId = proposalCounter.value - 1  // 从0开始

        const newProposal = {
            id: proposalId,
            name: name.trim(),
            voteCount: 0,
            startTime: Date.now(),
            endTime: Date.now() + durationMinutes * 60 * 1000,
            executed: false,
            creator: currentAddress.value
        }

        proposals.value.push(newProposal)

        // 记录事件
        eventLog.value.unshift({
            icon: '📝',
            name: 'ProposalCreated',
            details: `创建提案 "${newProposal.name}" (ID: ${proposalId})`,
            timestamp: Date.now(),
            type: 'create'
        })

        // 记录操作日志
        logStore.addLog(15, '创建提案', `Proposal #${proposalId}: ${name}`, 'createProposal15')

        // 判断解锁的概念
        const hints = ['bytes32_string']
        if (proposalCounter.value >= 3) {
            hints.push('storage_optimization')
        }

        const message = proposalCounter.value >= 3
            ? `✅ 创建提案 #${proposalId} 成功！📝 恭喜解锁：bytes32 vs string！💾 恭喜解锁：存储优化！👉 现在尝试投票来学习位运算！`
            : `✅ 创建提案 #${proposalId} 成功！📝 恭喜解锁：bytes32 vs string！👉 继续创建提案或尝试投票来学习位运算！`

        return {
            success: true,
            proposal: newProposal,
            message,
            hints,
            nextStep: proposalCounter.value >= 3
                ? '📝 bytes32 比 string 更省 Gas！💾 创建3个提案展示了 uint8 类型的存储优化！👉 现在尝试投票来学习位运算！'
                : '📝 bytes32 比 string 更省 Gas！👉 继续创建提案或尝试投票来学习位运算！'
        }
    }

    // 投票
    const vote = (proposalId) => {
        const proposal = proposals.value[proposalId]

        if (!proposal) {
            return {
                success: false,
                error: '❌ 提案不存在！',
                hint: '👝 请选择有效的提案！'
            }
        }

        // 检查提案是否已结束
        const now = Date.now()
        if (proposal.endTime <= now) {
            return {
                success: false,
                error: '❌ 提案已结束，无法投票！',
                hint: '⏰ 投票窗口已关闭！'
            }
        }

        // 位运算：检查是否已投票
        const mask = 1n << BigInt(proposalId)
        const voterData = currentVoterData.value

        if ((voterData & mask) !== 0n) {
            return {
                success: false,
                error: '❌ 已经对此提案投过票了！',
                hint: '🎭 掩码检查防止重复投票！',
                hasVoted: true
            }
        }

        // 位运算：记录投票
        voterRegistry.value[currentAddress.value] = voterData | mask
        proposal.voteCount++

        // 记录事件
        eventLog.value.unshift({
            icon: '🗳️',
            name: 'Voted',
            details: `${formatAddress(currentAddress.value)} 对提案 #${proposalId} 投票`,
            timestamp: Date.now(),
            type: 'vote'
        })

        // 记录操作日志
        logStore.addLog(15, '投票', `Proposal #${proposalId}`, 'vote15')

        return {
            success: true,
            proposal,
            message: `✅ 投票成功！⚡ 恭喜解锁：位运算技巧！🗺️ 恭喜解锁：映射存储！⏰ 恭喜解锁：时间戳验证！👉 尝试重复投票来体验掩码检查！`,
            hints: ['bit_operation', 'mapping_storage', 'timestamp_block'],
            nextStep: '⚡ 位运算让1个uint256存储256个投票状态！🗺️ 映射高效存储选民数据！⏰ 使用block.timestamp进行时间验证！👉 尝试对同一提案再次投票来体验掩码检查！'
        }
    }

    // 执行提案
    const executeProposal = (proposalId) => {
        const proposal = proposals.value[proposalId]

        if (!proposal) {
            return {
                success: false,
                error: '❌ 提案不存在！',
                hint: '👝 请选择有效的提案！'
            }
        }

        if (proposal.executed) {
            return {
                success: false,
                error: '❌ 提案已经执行过了！',
                hint: '✅ 该提案已执行！'
            }
        }

        // 检查提案是否已结束
        const now = Date.now()
        if (proposal.endTime > now) {
            return {
                success: false,
                error: '❌ 提案还在进行中，无法执行！',
                hint: '⏰ 请等待投票结束后再执行！'
            }
        }

        proposal.executed = true

        // 记录事件
        eventLog.value.unshift({
            icon: '✅',
            name: 'ProposalExecuted',
            details: `执行提案 "${proposal.name}" (ID: ${proposalId}, 得票: ${proposal.voteCount})`,
            timestamp: Date.now(),
            type: 'execute'
        })

        // 记录操作日志
        logStore.addLog(15, '执行提案', `Proposal #${proposalId}`, 'executeProposal15')

        return {
            success: true,
            proposal,
            message: `✅ 执行提案 #${proposalId} 成功！📋 恭喜解锁：事件日志！🎉 你已解锁所有知识点！`,
            hints: ['event_logging'],
            nextStep: '📋 事件日志用于链下索引和前端监听！🎉 恭喜！你已掌握Day 15所有核心概念！'
        }
    }

    // 获取位运算演示数据
    const getBitOperationDemo = (proposalId) => {
        const mask = 1n << BigInt(proposalId)
        const voterData = currentVoterData.value
        const hasVoted = (voterData & mask) !== 0n

        return {
            proposalId,
            mask: mask.toString(2),
            voterData: voterData.toString(2),
            hasVoted,
            operation: hasVoted ? '已投票 (AND检查)' : '未投票 (OR设置)',
            gasSaving: '使用位运算，1个uint256可存储256个提案的投票状态，节省约40% Gas！'
        }
    }

    // 获取存储可视化数据
    const getStorageVisualization = () => {
        return {
            slots: [
                {
                    slot: 0,
                    name: 'proposalCount',
                    type: 'uint8',
                    value: proposalCounter.value,
                    description: '提案总数（使用uint8节省存储）'
                },
                {
                    slot: 1,
                    name: 'proposals mapping',
                    type: 'mapping',
                    value: `${proposals.value.length} 个提案`,
                    description: '提案映射（每个提案使用紧凑数据类型）'
                },
                {
                    slot: 'X',
                    name: 'voterRegistry mapping',
                    type: 'mapping(uint256)',
                    value: `${Object.keys(voterRegistry.value).length} 个选民`,
                    description: '选民投票位图（1个uint256存储256个投票状态）'
                },
                {
                    slot: 'Y',
                    name: 'proposalVoterCount',
                    type: 'mapping(uint32)',
                    value: '按提案统计',
                    description: '提案投票数（uint32足够大）'
                }
            ]
        }
    }

    // 实时数据接口（供 Sidebar 使用）
    const realtimeData = computed(() => ({
        gasUsage: logStore.getDayGasUsage(15),
        ethCost: logStore.getDayEthCost(15),
        operationCount: logStore.getDayOperationCount(15)
    }))

    return {
        // 状态
        proposals,
        eventLog,
        currentAddress,
        proposalCounter,

        // 计算属性
        currentVoterData,
        activeProposals,
        endedProposals,
        executedProposals,

        // 方法
        createProposal,
        vote,
        executeProposal,
        getBitOperationDemo,
        getStorageVisualization,
        formatAddress,
        formatTime,
        formatRemainingTime,
        getProposalStatus,

        // 实时数据
        realtimeData
    }
}
