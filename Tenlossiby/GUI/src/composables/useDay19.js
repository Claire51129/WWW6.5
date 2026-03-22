import { ref, computed } from 'vue'
import { useOperationLogStore } from '@/stores/operationLogStore'
import { useProgressStore } from '@/stores/progressStore'
import { SigningKey, keccak256, toUtf8Bytes, AbiCoder, getAddress } from 'ethers'

export function useDay19() {
    const logStore = useOperationLogStore()
    const progressStore = useProgressStore()

    const organizerPrivateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
    const organizerAddress = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'

    const currentRole = ref('organizer')
    const currentUserAddress = ref('0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc')
    const hasEntered = ref({
        '0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc': false,
        '0x976EA74026E726554dB657fA54763abd0C3a0aa9': false,
        '0x14dC79964da2C08b23698B3d3cc7Ca32193d9955': false
    })
    const generatedSignature = ref(null)
    const showSignatureDetails = ref(false)

    const organizer = computed(() => organizerAddress)

    const participantAddress = computed(() => currentUserAddress.value)

    const isEntered = computed(() => hasEntered.value[currentUserAddress.value] || false)

    const participantsList = computed(() => {
        return Object.entries(hasEntered.value)
            .filter(([address, entered]) => entered)
            .map(([address]) => address)
    })

    const formatAddress = (addr) => {
        if (!addr) return ''
        return addr.substring(0, 6) + '...' + addr.substring(addr.length - 4)
    }

    const generateSignature = () => {
        try {
            const userAddress = currentUserAddress.value
            const normalizedAddress = getAddress(userAddress)

            const abiCoder = new AbiCoder()
            const encodedAddress = abiCoder.encode(['address'], [normalizedAddress])
            const messageHash = keccak256(encodedAddress)

            const prefix = '\x19Ethereum Signed Message:\n32'
            const ethSignedMessageHash = keccak256(toUtf8Bytes(prefix + messageHash.slice(2)))

            const signingKey = new SigningKey(organizerPrivateKey)
            const signature = signingKey.sign(ethSignedMessageHash)

            generatedSignature.value = {
                r: signature.r,
                s: signature.s,
                v: signature.v,
                full: signature.serialized,
                messageHash,
                ethSignedMessageHash
            }

            logStore.addLog(19, '生成签名', `为用户 ${formatAddress(userAddress)} 生成签名`, 'generateSignature19')

            return {
                success: true,
                message: `✅ 签名生成成功！\n签名: ${signature.serialized.substring(0, 20)}...`,
                signature: signature.serialized,
                hints: ['keccak256_hash', 'msg_sender'],
                nextStep: '👉 点击展开签名详情，查看 R/S/V 组件！'
            }
        } catch (error) {
            return {
                success: false,
                message: `❌ 签名生成失败: ${error.message}`
            }
        }
    }

    const enterEvent = () => {
        const user = currentUserAddress.value

        if (!generatedSignature.value) {
            return {
                success: false,
                message: '❌ 请先生成签名！'
            }
        }

        if (hasEntered.value[user]) {
            return {
                success: false,
                message: '❌ 你已经参与过此活动！'
            }
        }

        hasEntered.value[user] = true

        logStore.addLog(19, '参与活动', `用户 ${formatAddress(user)} 使用签名参与活动`, 'enterEvent19')

        return {
            success: true,
            message: `🎉 参与成功！\n你已使用签名成功参与活动！`,
            hints: ['ecrecover', 'require_statement', 'eip191_prefix'],
            nextStep: '👉 点击参与者列表查看映射存储，完成所有概念解锁！'
        }
    }

    const checkEntered = () => {
        const user = currentUserAddress.value
        const entered = hasEntered.value[user] || false

        logStore.addLog(19, '查询参与状态', `查询用户 ${formatAddress(user)} 参与状态: ${entered}`, 'checkEntered19')

        return {
            success: true,
            message: entered ? '✅ 该用户已参与活动' : '❌ 该用户尚未参与活动',
            entered
        }
    }

    const getParticipants = () => {
        const list = participantsList.value

        logStore.addLog(19, '获取参与者列表', `当前参与者数量: ${list.length}`, 'getParticipants19')

        return {
            success: true,
            message: `📋 当前参与者数量: ${list.length}`,
            participants: list,
            hints: ['mapping_storage'],
            nextStep: '🎉 你已掌握 Day 19 所有核心概念！'
        }
    }

    const toggleSignatureDetails = () => {
        showSignatureDetails.value = !showSignatureDetails.value

        if (showSignatureDetails.value && generatedSignature.value) {
            return {
                success: true,
                hints: ['signature_rsv'],
                nextStep: '👉 使用签名参与活动来解锁 ecrecover！'
            }
        }

        return { success: false }
    }

    const toggleRole = (targetRole = null) => {
        if (targetRole) {
            currentRole.value = targetRole
        } else {
            currentRole.value = currentRole.value === 'organizer' ? 'participant' : 'organizer'
        }

        if (currentRole.value === 'participant') {
            return {
                success: true,
                message: `👤 已切换为参与者角色\n地址: ${formatAddress(currentUserAddress.value)}`
            }
        } else {
            return {
                success: true,
                message: `👤 已切换为组织者角色\n地址: ${formatAddress(organizerAddress)}`
            }
        }
    }

    const changeUserAddress = (address) => {
        currentUserAddress.value = address
        generatedSignature.value = null
    }

    const realtimeData = computed(() => {
        return {
            gasUsage: logStore.getDayGasUsage(19),
            ethCost: logStore.getDayEthCost(19),
            operationCount: logStore.getDayOperationCount(19)
        }
    })

    return {
        currentRole,
        currentUserAddress,
        organizer,
        hasEntered,
        generatedSignature,
        showSignatureDetails,
        participantAddress,
        isEntered,
        participantsList,
        formatAddress,
        generateSignature,
        enterEvent,
        checkEntered,
        getParticipants,
        toggleSignatureDetails,
        toggleRole,
        changeUserAddress,
        realtimeData
    }
}
