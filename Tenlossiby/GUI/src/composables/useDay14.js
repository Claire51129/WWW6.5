import { ref, computed } from 'vue'
import { useOperationLogStore } from '@/stores/operationLogStore'

export function useDay14() {
    const logStore = useOperationLogStore()
    
    // ========== 状态 ==========
    
    // 角色地址定义
    const roles = {
        alice: '0xAlice8F3a2B1c0D9e8F7A6B5C4D3E2F1A0B9C8D7E6F',
        bob: '0xBob5A6B7C8D9E0F1A2B3C4D5E6F7A8B9C0D1E2F'
    }
    
    // 当前角色
    const currentRole = ref('alice')
    
    // 存款盒计数器（用于生成唯一ID）
    const boxCounter = ref(0)
    
    // 所有存款盒
    const depositBoxes = ref([])
    
    // 事件日志
    const eventLog = ref([])
    
    // ========== 计算属性 ==========
    
    const currentAddress = computed(() => roles[currentRole.value])
    
    // 获取当前用户的存款盒
    const myBoxes = computed(() => {
        return depositBoxes.value.filter(box => box.owner === currentAddress.value)
    })
    
    // 获取角色名称
    const getRoleName = (address) => {
        if (address === roles.alice) return 'Alice'
        if (address === roles.bob) return 'Bob'
        return address.slice(0, 6) + '...' + address.slice(-4)
    }
    
    // 格式化地址显示
    const formatAddress = (address) => {
        if (!address) return ''
        if (address === roles.alice) return 'Alice (0xAlice...7E6F)'
        if (address === roles.bob) return 'Bob (0xBob...E2F)'
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
    
    // 获取盒子类型图标
    const getBoxIcon = (type) => {
        switch (type) {
            case 'Basic': return '📦'
            case 'Premium': return '🏷️'
            case 'TimeLocked': return '⏰'
            default: return '📦'
        }
    }
    
    // ========== 方法 ==========
    
    // 切换角色
    const switchRole = (role) => {
        currentRole.value = role
        const messages = {
            alice: '✅ 已切换到 Alice！👉 创建存款盒开始学习！',
            bob: '✅ 已切换到 Bob！👉 让 Alice 转移一个存款盒给你！'
        }

        // 记录操作日志
        logStore.addLog(14, '切换角色', `切换到 ${role}`)

        return {
            success: true,
            message: messages[role],
            hints: [],
            nextStep: ''
        }
    }
    
    // 创建基础存款盒
    const createBasicBox = () => {
        boxCounter.value++
        const boxId = boxCounter.value
        const owner = currentAddress.value
        const ownerName = getRoleName(owner)
        
        const newBox = {
            id: boxId,
            type: 'Basic',
            owner: owner,
            createdBy: currentRole.value,
            secret: '',
            createdAt: Date.now(),
            unlockTime: null,
            metadata: null
        }
        
        depositBoxes.value.push(newBox)
        
        // 记录事件
        eventLog.value.push({
            icon: '📦',
            name: 'BoxCreated',
            details: `${ownerName} 创建了 Basic 存款盒 #${boxId}`,
            timestamp: Date.now(),
            type: 'create'
        })
        
        // 记录操作日志
        logStore.addLog(14, '创建Basic存款盒', `Box #${boxId} by ${ownerName}`, 'createBasicBox')
        
        return {
            success: true,
            box: newBox,
            message: `✅ 创建 Basic 存款盒 #${boxId} 成功！🧬 恭喜解锁：合约继承！🎭 恭喜解锁：抽象合约！${boxCounter.value >= 2 ? '🏭 恭喜解锁：工厂模式！' : ''}👉 创建 Premium 或 TimeLocked 来学习 override！`,
            hints: boxCounter.value >= 2
                ? ['inheritance', 'abstract_contract', 'factory_pattern']
                : ['inheritance', 'abstract_contract'],
            nextStep: boxCounter.value >= 2
                ? '🧬 BasicDepositBox 继承了 BaseDepositBox 的所有功能！🎭 抽象合约定义了通用接口！🏭 你体验了工厂模式！VaultManager 负责创建和管理所有存款盒！👉 创建 Premium 存款盒来学习 override 关键字！'
                : '📦 BasicDepositBox 继承了 BaseDepositBox 的所有功能！🎭 抽象合约定义了通用接口！👉 创建 Premium 存款盒来学习 override 关键字！'
        }
    }
    
    // 创建高级存款盒
    const createPremiumBox = () => {
        boxCounter.value++
        const boxId = boxCounter.value
        const owner = currentAddress.value
        const ownerName = getRoleName(owner)
        
        const newBox = {
            id: boxId,
            type: 'Premium',
            owner: owner,
            createdBy: currentRole.value,
            secret: '',
            createdAt: Date.now(),
            unlockTime: null,
            metadata: ''
        }
        
        depositBoxes.value.push(newBox)
        
        // 记录事件
        eventLog.value.push({
            icon: '🏷️',
            name: 'BoxCreated',
            details: `${ownerName} 创建了 Premium 存款盒 #${boxId}`,
            timestamp: Date.now(),
            type: 'create'
        })
        
        // 记录操作日志
        logStore.addLog(14, '创建Premium存款盒', `Box #${boxId} by ${ownerName}`, 'createPremiumBox')
        
        return {
            success: true,
            box: newBox,
            message: `✅ 创建 Premium 存款盒 #${boxId} 成功！📝 恭喜解锁：override 关键字和 virtual 函数！🎭 恭喜解锁：抽象合约！${boxCounter.value >= 2 ? '🏭 恭喜解锁：工厂模式！' : ''}👉 设置元数据来学习更多！`,
            hints: boxCounter.value >= 2
                ? ['override_keyword', 'virtual_function', 'abstract_contract', 'factory_pattern']
                : ['override_keyword', 'virtual_function', 'abstract_contract'],
            nextStep: boxCounter.value >= 2
                ? '🏷️ PremiumDepositBox 使用 override 重写了 getBoxType()！🎭 抽象合约定义了通用接口！🏭 你体验了工厂模式！VaultManager 负责创建和管理所有存款盒！👉 设置元数据来学习 metadata_storage！'
                : '🏷️ PremiumDepositBox 使用 override 重写了 getBoxType()！🎭 抽象合约定义了通用接口！👉 设置元数据来学习 metadata_storage！'
        }
    }
    
    // 创建时间锁定存款盒
    const createTimeLockedBox = (lockDuration) => {
        boxCounter.value++
        const boxId = boxCounter.value
        const owner = currentAddress.value
        const ownerName = getRoleName(owner)
        const unlockTime = Date.now() + (lockDuration * 1000) // 转换为毫秒
        
        const newBox = {
            id: boxId,
            type: 'TimeLocked',
            owner: owner,
            createdBy: currentRole.value,
            secret: '',
            createdAt: Date.now(),
            unlockTime: unlockTime,
            metadata: null
        }
        
        depositBoxes.value.push(newBox)
        
        // 记录事件
        eventLog.value.push({
            icon: '⏰',
            name: 'BoxCreated',
            details: `${ownerName} 创建了 TimeLocked 存款盒 #${boxId}，锁定 ${lockDuration} 秒`,
            timestamp: Date.now(),
            type: 'create'
        })
        
        // 记录操作日志
        logStore.addLog(14, '创建TimeLocked存款盒', `Box #${boxId} by ${ownerName}, 锁定 ${lockDuration}秒`, 'createTimeLockedBox')
        
        return {
            success: true,
            box: newBox,
            message: `✅ 创建 TimeLocked 存款盒 #${boxId} 成功！⏰ 恭喜解锁：时间锁定和抽象合约！${boxCounter.value >= 2 ? '🏭 恭喜解锁：工厂模式！' : ''}👉 存入秘密并在锁定期间尝试取出！`,
            hints: boxCounter.value >= 2
                ? ['abstract_contract', 'time_lock', 'factory_pattern']
                : ['abstract_contract', 'time_lock'],
            nextStep: boxCounter.value >= 2
                ? '⏰ TimeLockedDepositBox 使用修饰器组合保护 getSecret()！🏭 你体验了工厂模式！VaultManager 负责创建和管理所有存款盒！👉 存入秘密并在锁定期间尝试取出！'
                : '⏰ TimeLockedDepositBox 使用修饰器组合保护 getSecret()！👉 存入秘密并在锁定期间尝试取出！'
        }
    }
    
    // 存入秘密
    const storeSecret = (boxId, secret) => {
        const box = depositBoxes.value.find(b => b.id === boxId)
        if (!box) {
            return {
                success: false,
                message: '❌ 存款盒不存在！',
                hints: [],
                nextStep: ''
            }
        }
        
        // 验证所有权
        if (box.owner !== currentAddress.value) {
            logStore.addLog(14, '存入秘密失败', `无权操作 Box #${boxId}`)
            return {
                success: false,
                message: '❌ 只有所有者才能存入秘密！🔒 这展示了修饰器在权限控制中的作用！',
                hints: [],
                nextStep: '👉 切换到存款盒的所有者角色来尝试存入秘密！'
            }
        }
        
        box.secret = secret
        const ownerName = getRoleName(box.owner)
        
        // 记录事件
        eventLog.value.push({
            icon: '🔐',
            name: 'SecretStored',
            details: `${ownerName} 向 Box #${boxId} 存入了秘密`,
            timestamp: Date.now(),
            type: 'store'
        })
        
        // 记录操作日志
        logStore.addLog(14, '存入秘密', `Box #${boxId} by ${ownerName}`, 'storeSecret')
        
        return {
            success: true,
            message: `✅ 秘密已存入 Box #${boxId}！👉 尝试取出秘密！`,
            hints: [],
            nextStep: '🔐 秘密已安全存储！👉 尝试取出秘密！'
        }
    }
    
    // 取出秘密
    const getSecret = (boxId) => {
        const box = depositBoxes.value.find(b => b.id === boxId)
        if (!box) {
            return {
                success: false,
                message: '❌ 存款盒不存在！',
                hints: [],
                nextStep: ''
            }
        }
        
        // 验证所有权
        if (box.owner !== currentAddress.value) {
            logStore.addLog(14, '取出秘密失败', `无权操作 Box #${boxId}`)
            return {
                success: false,
                message: '❌ 只有所有者才能取出秘密！🔒 这展示了修饰器在权限控制中的作用！',
                hints: [],
                nextStep: '👉 切换到存款盒的所有者角色来尝试取出秘密！'
            }
        }
        
        // 检查时间锁
        if (box.type === 'TimeLocked' && box.unlockTime && Date.now() < box.unlockTime) {
            const remaining = Math.ceil((box.unlockTime - Date.now()) / 1000)
            logStore.addLog(14, '取出秘密失败', `Box #${boxId} 仍锁定，剩余 ${remaining} 秒`)
            return {
                success: false,
                message: `❌ Box #${boxId} 仍处于锁定状态！剩余 ${remaining} 秒。🔗 修饰器组合阻止了操作！`,
                hints: ['modifier_combination', 'super_keyword'],
                nextStep: '🔗 修饰器组合 timeUnlocked 阻止了操作！👉 等待解锁或创建其他类型的存款盒！'
            }
        }
        
        const ownerName = getRoleName(box.owner)
        
        // 记录操作日志（view 函数，无 Gas）
        logStore.addLog(14, '取出秘密', `Box #${boxId} by ${ownerName}`)
        
        return {
            success: true,
            secret: box.secret,
            message: `✅ 成功取出 Box #${boxId} 的秘密！`,
            hints: [],
            nextStep: box.type === 'TimeLocked'
                ? '🔓 不错！你取出了秘密！只有所有者才能访问存储的秘密。TimeLocked 使用 super.getSecret() 调用父合约实现！👉 设置元数据或转移所有权来学习更多！'
                : '🔓 不错！你取出了秘密！只有所有者才能访问存储的秘密。👉 转移所有权给 Bob 来学习所有权转移流程！'
        }
    }
    
    // 设置元数据（仅 Premium）
    const setMetadata = (boxId, metadata) => {
        const box = depositBoxes.value.find(b => b.id === boxId)
        if (!box) {
            return {
                success: false,
                message: '❌ 存款盒不存在！',
                hints: [],
                nextStep: ''
            }
        }
        
        if (box.type !== 'Premium') {
            return {
                success: false,
                message: '❌ 只有 Premium 存款盒支持元数据！',
                hints: [],
                nextStep: ''
            }
        }
        
        // 验证所有权
        if (box.owner !== currentAddress.value) {
            logStore.addLog(14, '设置元数据失败', `无权操作 Box #${boxId}`)
            return {
                success: false,
                message: '❌ 只有所有者才能设置元数据！🔒 这展示了修饰器在权限控制中的作用！',
                hints: [],
                nextStep: '👉 切换到 Premium 存款盒的所有者角色来尝试设置元数据！'
            }
        }
        
        box.metadata = metadata
        const ownerName = getRoleName(box.owner)
        
        // 记录事件
        eventLog.value.push({
            icon: '🏷️',
            name: 'MetadataSet',
            details: `${ownerName} 设置了 Box #${boxId} 的元数据`,
            timestamp: Date.now(),
            type: 'metadata'
        })
        
        // 记录操作日志
        logStore.addLog(14, '设置元数据', `Box #${boxId} by ${ownerName}`, 'setMetadata')
        
        return {
            success: true,
            message: `✅ 元数据已设置到 Box #${boxId}！🏷️ 恭喜解锁：元数据存储！`,
            hints: ['metadata_storage'],
            nextStep: '🏷️ Premium 版本通过继承扩展了功能！👉 创建第2个存款盒来体验工厂模式！'
        }
    }
    
    // 获取元数据
    const getMetadata = (boxId) => {
        const box = depositBoxes.value.find(b => b.id === boxId)
        if (!box || box.type !== 'Premium') {
            return { success: false, metadata: '' }
        }
        
        // 记录操作日志（view 函数，无 Gas）
        logStore.addLog(14, '获取元数据', `Box #${boxId}`)
        
        return { success: true, metadata: box.metadata || '' }
    }
    
    // 获取解锁时间
    const getUnlockTime = (boxId) => {
        const box = depositBoxes.value.find(b => b.id === boxId)
        if (!box || box.type !== 'TimeLocked') {
            return { success: false, unlockTime: 0, remaining: 0 }
        }
        
        const remaining = box.unlockTime ? Math.max(0, Math.ceil((box.unlockTime - Date.now()) / 1000)) : 0
        
        // 记录操作日志（view 函数，无 Gas）
        logStore.addLog(14, '查询解锁时间', `Box #${boxId}, 剩余 ${remaining} 秒`)
        
        return { 
            success: true, 
            unlockTime: box.unlockTime || 0, 
            remaining: remaining 
        }
    }
    
    // 转移所有权
    const transferOwnership = (boxId, newOwner) => {
        const box = depositBoxes.value.find(b => b.id === boxId)
        if (!box) {
            return {
                success: false,
                message: '❌ 存款盒不存在！',
                hints: [],
                nextStep: ''
            }
        }
        
        // 验证所有权
        if (box.owner !== currentAddress.value) {
            logStore.addLog(14, '转移所有权失败', `无权操作 Box #${boxId}`)
            return {
                success: false,
                message: '❌ 只有所有者才能转移所有权！🔒 这展示了修饰器在权限控制中的作用！',
                hints: [],
                nextStep: '👉 切换到存款盒的所有者角色来尝试转移所有权！'
            }
        }
        
        const oldOwner = box.owner
        const oldOwnerName = getRoleName(oldOwner)
        const newOwnerName = getRoleName(newOwner)
        
        box.owner = newOwner
        
        // 记录事件
        eventLog.value.push({
            icon: '🔑',
            name: 'OwnershipTransferred',
            details: `Box #${boxId} 从 ${oldOwnerName} 转移到 ${newOwnerName}`,
            timestamp: Date.now(),
            type: 'transfer'
        })
        
        // 记录操作日志
        logStore.addLog(14, '转移所有权', `Box #${boxId} 从 ${oldOwnerName} 到 ${newOwnerName}`, 'transferOwnership14')
        
        return {
            success: true,
            message: `✅ Box #${boxId} 所有权已从 ${oldOwnerName} 转移到 ${newOwnerName}！👉 新所有者需要调用 completeOwnershipTransfer 来更新记录！`,
            hints: boxCounter.value >= 2 ? ['factory_pattern'] : [],
            nextStep: boxCounter.value >= 2
                ? '🏭 你体验了工厂模式！VaultManager 负责创建和管理所有存款盒！👉 切换到新所有者完成所有权转移！'
                : '👉 切换到新所有者调用 completeOwnershipTransfer 来更新记录！'
        }
    }
    
    // 完成所有权转移（新所有者调用）
    const completeOwnershipTransfer = (boxId) => {
        const box = depositBoxes.value.find(b => b.id === boxId)
        if (!box) {
            return {
                success: false,
                message: '❌ 存款盒不存在！',
                hints: [],
                nextStep: ''
            }
        }
        
        // 验证当前用户是新所有者
        if (box.owner !== currentAddress.value) {
            logStore.addLog(14, '完成所有权转移失败', `不是新所有者 Box #${boxId}`)
            return {
                success: false,
                message: '❌ 你不是该存款盒的新所有者！',
                hints: [],
                nextStep: ''
            }
        }
        
        const ownerName = getRoleName(box.owner)
        
        // 记录操作日志
        logStore.addLog(14, '完成所有权转移', `Box #${boxId} 新所有者 ${ownerName}`, 'completeOwnershipTransfer')
        
        return {
            success: true,
            message: `✅ 所有权转移完成！${ownerName} 现在拥有 Box #${boxId}！`,
            hints: [],
            nextStep: '👉 查看完整代码来复习所有知识点！'
        }
    }
    
    // 获取剩余锁定时间
    const getRemainingLockTime = (boxId) => {
        const result = getUnlockTime(boxId)
        return result.remaining || 0
    }
    
    // 实时数据接口（供 Sidebar 使用）
    const realtimeData = computed(() => ({
        gasUsage: logStore.getDayGasUsage(14),
        ethCost: logStore.getDayEthCost(14),
        operationCount: logStore.getDayOperationCount(14)
    }))
    
    return {
        // 状态
        roles,
        currentRole,
        depositBoxes,
        myBoxes,
        eventLog,
        boxCounter,
        
        // 计算属性
        currentAddress,
        realtimeData,
        
        // 方法
        switchRole,
        getRoleName,
        formatAddress,
        formatTime,
        getBoxIcon,
        createBasicBox,
        createPremiumBox,
        createTimeLockedBox,
        storeSecret,
        getSecret,
        setMetadata,
        getMetadata,
        getUnlockTime,
        getRemainingLockTime,
        transferOwnership,
        completeOwnershipTransfer
    }
}
