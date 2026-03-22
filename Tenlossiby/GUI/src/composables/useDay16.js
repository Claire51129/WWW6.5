import { ref, computed } from 'vue'
import { useContractStore } from '@/stores/contractStore'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'
import { Interface, AbiCoder, toUtf8Bytes, hexlify, getAddress } from 'ethers'

export function useDay16() {
    const contractStore = useContractStore()
    const progressStore = useProgressStore()
    const logStore = useOperationLogStore()

    // 状态
    const profiles = ref({})
    const plugins = ref({})
    const pluginCounter = ref(0)
    const currentUser = ref('0xAb5801a7D398351b8bE11C439e05C5B9ebB6AA0c')
    const interactedPlugins = ref(new Set())

    // 预设的插件地址
    const predefinedPlugins = {
        weapon: '0x1234567890123456789012345678901234567890',
        achievement: '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd'
    }

    // 插件数据存储
    const pluginData = ref({
        weapon: {},
        achievement: {}
    })

    // 设置玩家资料
    const setProfile = (name, avatar) => {
        if (!name || !avatar) {
            return {
                success: false,
                message: '❌ 请输入名称和头像！',
                hints: [],
                nextStep: '👉 填写名称和头像后点击保存',
                error: 'EMPTY_INPUT'
            }
        }

        profiles.value[currentUser.value] = { name, avatar }

        // 记录操作日志
        logStore.addLog(
            16,
            '设置资料',
            `名称: ${name}, 头像: ${avatar}`,
            'setProfile16'
        )

        return {
            success: true,
            message: `✅ 资料已保存！`,
            hints: ['mapping_storage'],
            nextStep: '🗺️ 你的资料已保存到 mapping！👉 注册 weapon 插件来学习插件系统！'
        }
    }

    // 获取玩家资料
    const getProfile = (address) => {
        const profile = profiles.value[address]
        
        logStore.addLog(
            16,
            '查询资料',
            `地址: ${shortenAddress(address)}`
        )

        return profile || { name: '', avatar: '' }
    }

    // 注册插件
    const registerPlugin = (key, address) => {
        if (!key || !address) {
            return {
                success: false,
                message: '❌ 请输入插件标识符和地址！',
                hints: [],
                nextStep: '👉 填写插件标识符和合约地址',
                error: 'EMPTY_INPUT'
            }
        }

        if (plugins.value[key]) {
            return {
                success: false,
                message: `❌ 插件 "${key}" 已存在！`,
                hints: [],
                nextStep: '👉 使用其他标识符或先注销现有插件',
                error: 'PLUGIN_EXISTS'
            }
        }

        plugins.value[key] = address
        pluginCounter.value++

        // 记录操作日志
        logStore.addLog(
            16,
            '注册插件',
            `标识: ${key}, 地址: ${shortenAddress(address)}`,
            'registerPlugin16'
        )

        const hints = ['plugin_registration']
        let nextStep = `🔌 插件 "${key}" 注册成功！👉 点击「调用」执行插件函数！`

        // 注册第2个插件时解锁 dynamic_delegation
        if (pluginCounter.value >= 2) {
            hints.push('dynamic_delegation')
            nextStep = `🔄 动态委托系统运行中！👉 在不同插件间切换体验互操作！`
        }

        return {
            success: true,
            message: `✅ 插件 "${key}" 注册成功！`,
            hints,
            nextStep,
            registeredAddress: address
        }
    }

    // 获取插件地址
    const getPlugin = (key) => {
        return plugins.value[key] || ''
    }

    // ABI 编码（用于可视化）
    const encodeFunctionCall = (functionSignature, user, argument) => {
        try {
            const functionName = functionSignature.split('(')[0]
            const iface = new Interface([`function ${functionSignature}`])
            const functionSelector = iface.getFunction(functionName).selector
            
            const abiCoder = new AbiCoder()
            
            // 规范化地址（处理 checksum）
            const normalizedUser = getAddress(user)
            
            // 根据函数签名确定参数类型
            const hasStringParam = functionSignature.includes('string')
            const paramTypes = hasStringParam ? ['address', 'string'] : ['address']
            const paramValues = hasStringParam ? [normalizedUser, argument || ''] : [normalizedUser]
            
            const encodedParams = abiCoder.encode(paramTypes, paramValues)
            const fullEncodedData = functionSelector + encodedParams.slice(2)

            // 分解展示
            const breakdown = [
                { 
                    type: 'selector', 
                    value: functionSelector, 
                    desc: '函数选择器 (4 bytes)',
                    detail: `keccak256("${functionSignature}").slice(0,10)`
                },
                { 
                    type: 'address', 
                    value: normalizedUser, 
                    desc: 'address 参数',
                    detail: 'zero-padded to 32 bytes'
                }
            ]
            
            // 如果有 string 参数，添加相关分解
            if (hasStringParam) {
                const argValue = argument || ''
                breakdown.push(
                    { 
                        type: 'offset', 
                        value: '0x0000000000000000000000000000000000000000000000000000000000000040', 
                        desc: 'string 偏移量 (64 bytes)'
                    },
                    { 
                        type: 'length', 
                        value: '0x' + argValue.length.toString(16).padStart(64, '0'), 
                        desc: `string 长度 (${argValue.length})`
                    },
                    { 
                        type: 'data', 
                        value: hexlify(toUtf8Bytes(argValue)).slice(2).padEnd(64, '0'), 
                        desc: 'string 数据 (padded)',
                        detail: `"${argValue}"`
                    }
                )
            }

            return {
                selector: functionSelector,
                encodedParams: '0x' + encodedParams.slice(2),
                fullEncodedData,
                breakdown
            }
        } catch (e) {
            console.error('ABI编码错误:', e)
            console.error('参数:', { functionSignature, user, argument })
            return null
        }
    }

    // 执行插件函数（call）
    const runPlugin = (key, functionSignature, user, argument) => {
        // 错误1: 插件未注册
        if (!plugins.value[key]) {
            return {
                success: false,
                message: `❌ 插件 "${key}" 未注册！`,
                hints: [],
                nextStep: `👉 先点击「插件管理中心」注册 ${key} 插件！`,
                error: 'PLUGIN_NOT_REGISTERED'
            }
        }

        // 错误2: ABI编码失败
        const encoded = encodeFunctionCall(functionSignature, user, argument)
        if (!encoded) {
            return {
                success: false,
                message: '❌ ABI编码失败！',
                hints: [],
                nextStep: '👉 检查函数签名格式，例如: setWeapon(address,string)',
                error: 'ABI_ENCODE_FAILED'
            }
        }

        // 模拟调用失败（演示错误处理，10%概率）
        if (Math.random() < 0.1) {
            return {
                success: false,
                message: '❌ 插件调用失败！（演示错误场景）',
                hints: [],
                nextStep: '👉 可能是 Gas 不足或函数 revert。检查参数是否满足插件要求。',
                error: 'CALL_FAILED'
            }
        }

        // 执行成功 - 更新插件数据
        const functionName = functionSignature.split('(')[0]
        if (!pluginData.value[key]) {
            pluginData.value[key] = {}
        }
        pluginData.value[key][user] = argument

        // 记录交互过的插件
        interactedPlugins.value.add(key)

        // 记录操作日志
        logStore.addLog(
            16,
            '执行插件',
            `插件: ${key}, 函数: ${functionName}, 参数: ${argument}`,
            'runPlugin16'
        )

        const hints = ['low_level_call', 'abi_encoding']
        let nextStep = '⚡ 低级别调用成功！👉 查看 ABI 编码可视化或切换 staticcall 模式查询数据！'

        // 如果已经交互过多个插件，解锁 contract_interop
        if (interactedPlugins.value.size >= 2) {
            hints.push('contract_interop')
            nextStep = '🌐 合约互操作掌握！👉 查看完整代码了解所有实现细节！'
        }

        return {
            success: true,
            message: `✅ 调用 ${key}.${functionName} 成功！`,
            hints,
            nextStep,
            encoded: encoded.breakdown
        }
    }

    // 执行插件函数（staticcall）
    const runPluginView = (key, functionSignature, user) => {
        // 错误: 插件未注册
        if (!plugins.value[key]) {
            return {
                success: false,
                message: `❌ 插件 "${key}" 未注册！`,
                hints: [],
                nextStep: `👉 先注册 ${key} 插件！`,
                error: 'PLUGIN_NOT_REGISTERED'
            }
        }

        // 获取存储的数据
        const functionName = functionSignature.split('(')[0]
        const storedValue = pluginData.value[key]?.[user] || ''

        // 记录操作日志（view函数不消耗Gas）
        logStore.addLog(
            16,
            '查询插件',
            `插件: ${key}, 函数: ${functionName}, 返回值: ${storedValue || '(空)'}`
        )

        return {
            success: true,
            message: `✅ 查询 ${key}.${functionName} 成功！`,
            hints: ['staticcall'],
            nextStep: storedValue 
                ? `👁️ 返回值: "${storedValue}" 👉 尝试切换到其他插件！`
                : '👁️ 查询成功但无数据 👉 先用 call 模式写入数据！',
            result: storedValue
        }
    }

    // 获取插件数据
    const getPluginData = (key, user) => {
        return pluginData.value[key]?.[user] || ''
    }

    // 辅助函数：缩短地址显示
    const shortenAddress = (addr) => {
        if (!addr || addr.length < 10) return addr
        return addr.slice(0, 6) + '...' + addr.slice(-4)
    }

    // 解锁概念
    const unlockConcept = (conceptKey) => {
        progressStore.unlockConcept(16, conceptKey)
    }

    // 实时数据接口
    const realtimeData = computed(() => ({
        gasUsage: logStore.getDayGasUsage(16),
        ethCost: logStore.getDayEthCost(16),
        operationCount: logStore.getDayOperationCount(16)
    }))

    return {
        // 状态
        profiles,
        plugins,
        pluginCounter,
        currentUser,
        pluginData,
        interactedPlugins,
        predefinedPlugins,
        
        // 方法
        setProfile,
        getProfile,
        registerPlugin,
        getPlugin,
        runPlugin,
        runPluginView,
        getPluginData,
        encodeFunctionCall,
        unlockConcept,
        shortenAddress,
        
        // 实时数据
        realtimeData
    }
}
