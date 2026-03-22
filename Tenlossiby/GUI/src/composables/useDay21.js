import { ref, computed } from 'vue'
import { useOperationLogStore } from '../stores/operationLogStore'

export function useDay21() {
    const logStore = useOperationLogStore()

    // NFT数据存储
    const nfts = ref([])
    const tokenIdCounter = ref(1)
    const owners = ref({}) // tokenId => address
    const balances = ref({}) // address => count
    const tokenApprovals = ref({}) // tokenId => approvedAddress
    const operatorApprovals = ref({}) // owner => { operator => bool }
    const tokenURIs = ref({}) // tokenId => uri

    // 当前选中的NFT
    const selectedTokenId = ref(null)

    // 铸造表单
    const mintForm = ref({
        to: '',
        uri: ''
    })

    // 转移表单
    const transferForm = ref({
        to: ''
    })

    // 授权表单
    const approveForm = ref({
        to: ''
    })

    // 操作员授权表单
    const operatorForm = ref({
        operator: '',
        approved: true
    })

    // 查询表单
    const queryForm = ref({
        address: ''
    })

    // 消息提示
    const message = ref('')
    const isError = ref(false)

    // 显示消息
    const showMessage = (msg, error = false) => {
        message.value = msg
        isError.value = error
        setTimeout(() => {
            message.value = ''
        }, 3000)
    }

    // 铸造NFT
    const mintNFT = (to, uri) => {
        if (!to || !uri) {
            showMessage('请输入接收地址和元数据URI', true)
            return { success: false, message: '请输入接收地址和元数据URI' }
        }

        const tokenId = tokenIdCounter.value
        tokenIdCounter.value++

        // 更新状态
        owners.value[tokenId] = to
        balances.value[to] = (balances.value[to] || 0) + 1
        tokenURIs.value[tokenId] = uri

        // 添加到NFT列表
        nfts.value.push({
            tokenId,
            owner: to,
            uri
        })

        // 记录日志
        logStore.addLog(21, '铸造NFT', `Token ID: ${tokenId} 接收者: ${to}`, 'mint21')

        showMessage(`🎉 NFT铸造成功！Token ID: ${tokenId}`)

        return {
            success: true,
            message: `NFT铸造成功！Token ID: ${tokenId}`,
            hints: ['铸造函数从0地址创建新NFT', 'Token ID计数器自动递增'],
            nextStep: '查询地址余额了解持有情况'
        }
    }

    // 查询余额
    const balanceOf = (owner) => {
        if (!owner) {
            showMessage('请输入查询地址', true)
            return { success: false, message: '请输入查询地址' }
        }

        const balance = balances.value[owner] || 0

        // 记录日志
        logStore.addLog(21, '查询余额', `地址: ${owner} 持有: ${balance} 个NFT`, 'balanceOf21')

        showMessage(`✅ 查询成功！${owner.slice(0, 10)}... 持有 ${balance} 个NFT`)

        return {
            success: true,
            message: `地址 ${owner.slice(0, 10)}... 持有 ${balance} 个NFT`,
            balance,
            hints: ['balanceOf使用_balances映射存储', '映射查询时间复杂度为O(1)'],
            nextStep: '👉 1.在画廊点击NFT选中 → 2.切换到"授权"标签 → 3.输入授权地址 → 4.点击批准授权！'
        }
    }

    // 查询所有者
    const ownerOf = (tokenId) => {
        const owner = owners.value[tokenId]
        if (!owner) {
            showMessage('Token不存在', true)
            return { success: false, message: 'Token不存在' }
        }
        return { success: true, owner }
    }

    // 转移NFT
    const transferFrom = (from, to, tokenId) => {
        if (!to) {
            showMessage('请输入目标地址', true)
            return { success: false, message: '请输入目标地址' }
        }

        const owner = owners.value[tokenId]
        if (!owner) {
            showMessage('Token不存在', true)
            return { success: false, message: 'Token不存在' }
        }

        if (owner !== from) {
            showMessage('你不是该NFT的所有者', true)
            return { success: false, message: '你不是该NFT的所有者' }
        }

        // 清除授权
        delete tokenApprovals.value[tokenId]

        // 更新余额
        balances.value[from] = (balances.value[from] || 0) - 1
        balances.value[to] = (balances.value[to] || 0) + 1
        owners.value[tokenId] = to

        // 更新NFT列表
        const nft = nfts.value.find(n => n.tokenId === tokenId)
        if (nft) {
            nft.owner = to
        }

        // 记录日志
        logStore.addLog(21, '转移NFT', `Token #${tokenId} 从 ${from.slice(0, 10)}... 到 ${to.slice(0, 10)}...`, 'transferFrom21')

        showMessage(`✅ NFT转移成功！Token #${tokenId} 已转移到 ${to.slice(0, 10)}...`)

        return {
            success: true,
            message: `NFT转移成功！Token #${tokenId}`,
            hints: ['transferFrom需要事先授权或自己是所有者', '转移后清除原有授权'],
            nextStep: '尝试授权其他地址管理你的NFT'
        }
    }

    // 安全转移NFT
    const safeTransferFrom = (from, to, tokenId) => {
        if (!to) {
            showMessage('请输入目标地址', true)
            return { success: false, message: '请输入目标地址' }
        }

        // 模拟检查接收方是否支持ERC721
        const isContract = to.length > 20 // 简化判断
        if (isContract) {
            // 模拟检查IERC721Receiver
            const supports = Math.random() > 0.3 // 70%概率支持
            if (!supports) {
                showMessage('❌ 接收方合约不支持ERC721！转移被拒绝。', true)
                return { success: false, message: '接收方合约不支持ERC721' }
            }
        }

        const result = transferFrom(from, to, tokenId)
        if (result.success) {
            // 记录日志
            logStore.addLog(21, '安全转移NFT', `Token #${tokenId} 从 ${from.slice(0, 10)}... 到 ${to.slice(0, 10)}...`, 'safeTransferFrom21')

            showMessage(`🔒 安全转移完成！接收方支持ERC721！`)

            return {
                success: true,
                message: '安全转移成功！',
                hints: ['safeTransferFrom检查接收方是否实现IERC721Receiver', '防止代币被锁定在不支持的合约中'],
                nextStep: '尝试授权功能'
            }
        }
        return result
    }

    // 授权单个代币
    const approve = (to, tokenId) => {
        if (!to) {
            showMessage('请输入授权地址', true)
            return { success: false, message: '请输入授权地址' }
        }

        const owner = owners.value[tokenId]
        if (!owner) {
            showMessage('Token不存在', true)
            return { success: false, message: 'Token不存在' }
        }

        tokenApprovals.value[tokenId] = to

        // 记录日志
        logStore.addLog(21, '授权NFT', `Token #${tokenId} 授权给 ${to.slice(0, 10)}...`, 'approve21')

        showMessage(`🔑 授权成功！Token #${tokenId} 已授权给 ${to.slice(0, 10)}...`)

        return {
            success: true,
            message: `授权成功！Token #${tokenId}`,
            hints: ['approve授权单个代币', '被授权地址可以转移该代币'],
            nextStep: '尝试设置操作员授权'
        }
    }

    // 查询授权
    const getApproved = (tokenId) => {
        const approved = tokenApprovals.value[tokenId] || ''
        return { success: true, approved }
    }

    // 设置操作员授权
    const setApprovalForAll = (operator, approved) => {
        if (!operator) {
            showMessage('请输入操作员地址', true)
            return { success: false, message: '请输入操作员地址' }
        }

        if (!operatorApprovals.value['currentUser']) {
            operatorApprovals.value['currentUser'] = {}
        }
        operatorApprovals.value['currentUser'][operator] = approved

        // 记录日志
        logStore.addLog(21, '操作员授权', `${operator.slice(0, 10)}... ${approved ? '已授权' : '已取消'}`, 'setApprovalForAll21')

        showMessage(`${approved ? '✅' : '❌'} 操作员授权${approved ? '已设置' : '已取消'}！${operator.slice(0, 10)}...`)

        return {
            success: true,
            message: `操作员授权${approved ? '已设置' : '已取消'}`,
            hints: ['setApprovalForAll授权/取消操作员', '操作员可以管理所有代币'],
            nextStep: '查看所有权追踪'
        }
    }

    // 查询操作员授权
    const isApprovedForAll = (owner, operator) => {
        return operatorApprovals.value[owner]?.[operator] || false
    }

    // 获取用户拥有的NFT列表
    const getTokensByOwner = (owner) => {
        return nfts.value.filter(nft => nft.owner === owner)
    }

    // 实时数据
    const realtimeData = computed(() => ({
        gasUsage: logStore.getDayGasUsage(21),
        ethCost: logStore.getDayEthCost(21),
        operationCount: logStore.getDayOperationCount(21)
    }))

    return {
        // 状态
        nfts,
        tokenIdCounter,
        owners,
        balances,
        tokenApprovals,
        operatorApprovals,
        tokenURIs,
        selectedTokenId,
        mintForm,
        transferForm,
        approveForm,
        operatorForm,
        queryForm,
        message,
        isError,

        // 方法
        showMessage,
        mintNFT,
        balanceOf,
        ownerOf,
        transferFrom,
        safeTransferFrom,
        approve,
        getApproved,
        setApprovalForAll,
        isApprovedForAll,
        getTokensByOwner,

        // 计算属性
        realtimeData
    }
}
