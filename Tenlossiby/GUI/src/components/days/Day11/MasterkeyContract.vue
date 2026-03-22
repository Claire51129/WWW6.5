<template>
  <div class="day-11-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <div class="left-column">
        <div class="interaction-area">
          <h3>🎮 交互操作</h3>

          <!-- 身份切换栏 -->
          <div class="identity-toggle-bar">
            <span class="identity-label">🎭 当前身份：</span>
            <div class="toggle-buttons">
              <button 
                :class="{ active: !isOwner }" 
                @click="handleSetUserMode"
                class="day-action-btn small"
              >
                👤 用户/User
              </button>
              <button 
                :class="{ active: isOwner }" 
                @click="handleSetOwnerMode"
                class="day-action-btn small"
              >
                👑 所有者/Owner
              </button>
            </div>
          </div>

          <!-- 状态显示 -->
          <div class="status-indicator">
            <div class="status-item">
              <span class="status-label">🏦 合约状态</span>
            </div>
            <div class="status-details">
              <div><strong>当前所有者：</strong>{{ formatAddress(owner) }}</div>
              <div><strong>合约余额：</strong>{{ formatWeiToEth(contractBalance) }} ETH ({{ contractBalance }} wei)</div>
              <div><strong>当前用户：</strong>{{ formatAddress(userAddress) }}</div>
              <div :class="['role-badge', isOwner ? 'owner' : 'user']">
                <strong>身份：</strong>{{ isOwner ? '👑 所有者/Owner' : '👤 普通用户/User' }}
              </div>
            </div>
          </div>

          <!-- Ownable 功能区块 -->
          <div class="function-block">
            <h4 class="block-title">🔐 Ownable - 所有权管理</h4>
            
            <div class="sub-function">
              <code class="function-signature">函数：ownerAddress() view returns (address)</code>
              <button @click="handleGetOwner" class="day-action-btn cyan">👤 查看当前所有者/GetOwner</button>
            </div>

            <div class="sub-function">
              <code class="function-signature">函数：transferOwnership(address newOwner) onlyOwner</code>
              <div class="input-group label-input-row">
                <label>新所有者地址：</label>
                <input 
                  v-model="inputNewOwner" 
                  type="text" 
                  placeholder="0x..."
                  @click.stop
                >
              </div>
              <div class="button-row">
                <button @click="generateRandomAddress" class="day-action-btn cyan small">🎲 随机生成</button>
                <button @click="handleTransferOwnership" class="day-action-btn orange">🔑 转移所有权/TransferOwnership</button>
              </div>
              <div v-if="!isOwner" class="error-message">⚠️ 只有所有者才能转移所有权</div>
            </div>
          </div>

          <!-- VaultMaster 功能区块 -->
          <div class="function-block">
            <h4 class="block-title">💰 VaultMaster - 资金管理</h4>
            
            <div class="sub-function">
              <code class="function-signature">函数：deposit() payable</code>
              <div class="input-group">
                <label>存入数量 (ETH)：</label>
                <input 
                  v-model="inputDepositAmount" 
                  type="number" 
                  placeholder="请输入数量"
                  min="0"
                  step="0.01"
                  @click.stop
                >
              </div>
              <button @click="handleDeposit" class="day-action-btn yellow">💰 存入 ETH/Deposit</button>
            </div>

            <div class="sub-function">
              <code class="function-signature">函数：withdraw(address recipient, uint256 amount) onlyOwner</code>
              <div class="input-group label-input-row">
                <label>接收地址：</label>
                <input 
                  v-model="inputWithdrawRecipient" 
                  type="text" 
                  placeholder="0x..."
                  @click.stop
                >
              </div>
              <div class="input-group">
                <label>提取数量 (ETH)：</label>
                <input 
                  v-model="inputWithdrawAmount" 
                  type="number" 
                  placeholder="请输入数量"
                  min="0"
                  step="0.01"
                  @click.stop
                >
              </div>
              <div class="button-row">
                <button @click="generateRandomRecipient" class="day-action-btn cyan small">🎲 随机生成地址</button>
                <button @click="handleWithdraw" class="day-action-btn cyan">💸 提取 ETH/Withdraw</button>
              </div>
              <div v-if="!isOwner" class="info-message">💡 提示：只有所有者才能成功提取，但你可以尝试点击来体验权限控制！</div>
            </div>

            <div class="sub-function query-block">
              <code class="function-signature">函数：getBalance() view returns (uint256)</code>
              <button @click="handleGetBalance" class="day-action-btn cyan">📊 查询合约余额/GetBalance</button>
            </div>
          </div>

          <!-- 事件日志 -->
          <div class="event-timeline" v-if="eventLog.length > 0">
            <h4>📜 事件日志</h4>
            <div v-for="(event, index) in eventLog.slice().reverse()" :key="index" class="timeline-item">
              <div class="timeline-icon">{{ event.icon }}</div>
              <div class="timeline-content">
                <div class="event-title">{{ event.name }}</div>
                <div class="event-meta">{{ event.details }}</div>
                <div class="event-time">{{ formatTime(event.timestamp) }}</div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 消息提示（参考 Day 10 样式） -->
        <div v-if="message" :class="['message-toast', { error: isError }]">
          {{ message }}
        </div>
      </div>

      <!-- 右侧：知识面板 -->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="11"
          :unlocked-concepts="unlockedConcepts"
          :progress-percentage="progressPercentage"
          :full-code="fullCode"
          @show-full-code="handleShowFullCode"
        />
      </div>
    </div>

    <!-- 完整代码弹窗 -->
    <FullCodeModal
      :show="showFullCode"
      title="MasterkeyContract 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useDay11 } from '@/composables/useDay11'
import { useProgressStore } from '@/stores/progressStore'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

const progressStore = useProgressStore()

// Day11 业务逻辑
const {
  owner,
  contractBalance,
  userAddress,
  isOwner,
  eventLog,
  deposit,
  withdraw,
  getOwner,
  getBalance,
  transferOwnership,
  setOwnerMode,
  setUserMode,
  viewFullCode
} = useDay11()

// 输入状态
const inputNewOwner = ref('')
const inputDepositAmount = ref('')
const inputWithdrawRecipient = ref('')
const inputWithdrawAmount = ref('')

// 弹窗状态
const showFullCode = ref(false)

// 消息提示状态（参考 Day 10）
const message = ref('')
const isError = ref(false)

// 完整代码
const fullCode = computed(() => getFullCode(11))

// 已解锁概念
const unlockedConcepts = computed(() => {
  return progressStore.dayProgress[11]?.unlockedConcepts || []
})

// 进度百分比
const progressPercentage = computed(() => {
  const progress = progressStore.dayProgress[11]
  if (!progress || progress.totalConcepts === 0) return 0
  return Math.floor((progress.unlockedConcepts.length / progress.totalConcepts) * 100)
})

// 格式化地址
const formatAddress = (addr) => {
  if (!addr) return '未设置'
  if (addr.length <= 12) return addr
  return addr.slice(0, 6) + '...' + addr.slice(-4)
}

// 格式化 wei 为 ETH
const formatWeiToEth = (wei) => {
  return (wei / 1e18).toFixed(4)
}

// 格式化时间
const formatTime = (timestamp) => {
  return new Date(timestamp).toLocaleTimeString()
}

// 验证地址格式
const isValidAddress = (address) => {
  return /^0x[a-fA-F0-9]{40}$/.test(address)
}

// 生成随机地址
const generateRandomAddress = () => {
  inputNewOwner.value = '0x' + Array(40).fill(0).map(() => Math.floor(Math.random() * 16).toString(16)).join('')
}

const generateRandomRecipient = () => {
  inputWithdrawRecipient.value = '0x' + Array(40).fill(0).map(() => Math.floor(Math.random() * 16).toString(16)).join('')
}

// 显示消息（参考 Day 10 实现）
const showMessage = (msg, error = false) => {
  message.value = msg
  isError.value = error
  setTimeout(() => {
    message.value = ''
  }, 3000)
}

// 处理切换到用户模式
const handleSetUserMode = () => {
  const result = setUserMode()
  if (result && result.hint) {
    showMessage(result.hint, false)
  }
}

// 处理切换到所有者模式
const handleSetOwnerMode = () => {
  const result = setOwnerMode()
  if (result && result.hint) {
    showMessage(result.hint, false)
  }
}

// 处理查看所有者
const handleGetOwner = () => {
  const result = getOwner()
  let message = `👤 当前所有者：${result.address}`
  if (result.hint) {
    // hint 中的换行符改为空格，统一单行显示
    const cleanHint = result.hint.replace(/\n/g, ' ')
    message += ` ${cleanHint}`
  }
  showMessage(message, false)
}

// 处理转移所有权
const handleTransferOwnership = () => {
  if (!inputNewOwner.value.trim()) {
    showMessage('请输入新所有者地址！', true)
    return
  }
  if (!isValidAddress(inputNewOwner.value)) {
    showMessage('请输入有效的以太坊地址（42位十六进制字符，以 0x 开头）！', true)
    return
  }
  const result = transferOwnership(inputNewOwner.value)
  if (result.success) {
    const messages = ['✅ 所有权转移成功！']
    if (result.hints && result.hints.length > 0) {
      messages.push(...result.hints)
    }
    showMessage(messages.join('\n'), false)
    inputNewOwner.value = ''
  } else {
    showMessage(`❌ ${result.error}`, true)
  }
}

// 处理存款
const handleDeposit = () => {
  const amount = Number(inputDepositAmount.value)
  if (!amount || amount <= 0) {
    showMessage('请输入有效的存入数量！', true)
    return
  }
  const result = deposit(amount)
  if (result.success) {
    const messages = ['✅ 存款成功！']
    if (result.hints && result.hints.length > 0) {
      messages.push(...result.hints)
    }
    showMessage(messages.join('\n'), false)
    inputDepositAmount.value = ''
  } else {
    showMessage(`❌ ${result.error}`, true)
  }
}

// 处理提款
const handleWithdraw = () => {
  if (!inputWithdrawRecipient.value.trim()) {
    showMessage('请输入接收地址！', true)
    return
  }
  if (!isValidAddress(inputWithdrawRecipient.value)) {
    showMessage('请输入有效的接收地址（42位十六进制字符，以 0x 开头）！', true)
    return
  }
  const amount = Number(inputWithdrawAmount.value)
  if (!amount || amount <= 0) {
    showMessage('请输入有效的提取数量！', true)
    return
  }
  
  const result = withdraw(inputWithdrawRecipient.value, amount)
  
  if (result.success) {
    inputWithdrawRecipient.value = ''
    inputWithdrawAmount.value = ''
    showMessage('✅ 提款成功！', false)
  } else {
    // 错误信息已经包含了解锁提示，直接显示
    showMessage(result.error, false)
  }
}

// 处理查询余额
const handleGetBalance = () => {
  const balance = getBalance()
  showMessage(`📊 合约余额：${formatWeiToEth(balance)} ETH (${balance} wei)`, false)
}

// 处理显示完整代码
const handleShowFullCode = () => {
  const result = viewFullCode()
  if (result.hints && result.hints.length > 0) {
    showMessage(result.hints.join('\n'), false)
  }
  showFullCode.value = true
}
</script>

<style scoped>
/* 身份切换栏 */
.identity-toggle-bar {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 20px;
  padding: 12px 15px;
  background: var(--bg-surface-2);
  border-radius: 8px;
  flex-wrap: wrap;
}

.identity-label {
  font-weight: bold;
  color: var(--text-main);
}

.toggle-buttons {
  display: flex;
  gap: 10px;
}

.toggle-buttons button {
  opacity: 0.6;
  transition: all 0.3s ease;
  background: var(--accent-blue);
  color: white;
}

.toggle-buttons button.active {
  opacity: 1;
  transform: scale(1.05);
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
  background: var(--accent-green);
}

/* 状态指示器 */
.status-indicator {
  margin-bottom: 20px;
  padding: 15px;
  background: var(--bg-surface-1);
  border-radius: 8px;
  border: 1px solid var(--border-main);
}

.status-item {
  margin-bottom: 10px;
  padding-bottom: 10px;
  border-bottom: 1px solid var(--border-main);
}

.status-label {
  font-weight: bold;
  font-size: 1.1em;
  color: var(--accent-blue);
}

.status-details {
  line-height: 1.8;
  color: var(--text-main);
}

.role-badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.9em;
  margin-top: 5px;
}

.role-badge.owner {
  background: rgba(34, 197, 94, 0.2);
  color: var(--accent-green);
}

.role-badge.user {
  background: rgba(59, 130, 246, 0.2);
  color: var(--accent-blue);
}

/* 函数区块 */
.function-block {
  border: 1px solid var(--border-main);
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
  background: var(--bg-surface-1);
}

.block-title {
  color: var(--accent-magenta);
  margin: 0 0 15px 0;
  font-size: 1.1em;
  padding-bottom: 10px;
  border-bottom: 2px solid var(--border-main);
}

.sub-function {
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px dashed var(--border-main);
}

.sub-function:last-child {
  margin-bottom: 0;
  padding-bottom: 0;
  border-bottom: none;
}

.function-signature {
  display: block;
  background: var(--bg-surface-2);
  padding: 6px 12px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 0.85em;
  color: var(--text-main);
  margin: 0 0 15px 0;
  border-left: 3px solid var(--accent-yellow);
  line-height: 1.4;
}

.query-block {
  background: var(--bg-surface-2);
  border-radius: 8px;
  padding: 15px;
}

/* 输入组 */
.input-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 15px;
}

.input-group.label-input-row {
  flex-direction: row;
  align-items: center;
  gap: 10px;
}

.input-group.label-input-row label {
  white-space: nowrap;
  min-width: 100px;
}

.input-group label {
  font-weight: bold;
  color: var(--text-main);
}

.input-group input {
  padding: 10px 12px;
  border: 2px solid var(--accent-magenta);
  border-radius: 6px;
  font-size: 0.95em;
  background: var(--bg-base);
  color: var(--text-main);
  transition: border-color 0.3s ease;
  font-family: inherit;
  flex: 1;
}

.input-group input:focus {
  outline: none;
  border-color: var(--accent-cyan);
  box-shadow: 0 0 0 3px rgba(42, 161, 152, 0.2);
}

.input-group input::placeholder {
  color: var(--text-muted);
}

/* 按钮行 */
.button-row {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

/* 错误消息 */
.error-message {
  margin-top: 10px;
  padding: 10px;
  background: rgba(239, 68, 68, 0.1);
  color: var(--accent-red);
  border-radius: 6px;
  font-size: 0.9em;
  border-left: 3px solid var(--accent-red);
}

/* 提示消息 */
.info-message {
  margin-top: 10px;
  padding: 10px;
  background: rgba(59, 130, 246, 0.1);
  color: var(--accent-blue);
  border-radius: 6px;
  font-size: 0.9em;
  border-left: 3px solid var(--accent-blue);
}

/* 事件时间线 */
.event-timeline {
  margin-top: 20px;
  padding: 15px;
  background: var(--bg-surface-1);
  border-radius: 8px;
  border: 1px solid var(--border-main);
}

.event-timeline h4 {
  color: var(--accent-cyan);
  margin-bottom: 15px;
}

.timeline-item {
  display: flex;
  gap: 12px;
  padding: 12px;
  margin-bottom: 10px;
  background: var(--bg-surface-2);
  border-radius: 8px;
  border-left: 3px solid var(--accent-green);
}

.timeline-icon {
  font-size: 1.5em;
  display: flex;
  align-items: center;
}

.timeline-content {
  flex: 1;
}

.event-title {
  font-weight: bold;
  color: var(--text-main);
  margin-bottom: 4px;
}

.event-meta {
  font-size: 0.9em;
  color: var(--text-muted);
  margin-bottom: 4px;
}

.event-time {
  font-size: 0.8em;
  color: var(--text-muted);
}

/* 消息提示（参考 Day 10） */
.day-11-content .message-toast {
  position: fixed;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  padding: 12px 24px;
  border-radius: 8px;
  background: var(--accent-green);
  color: #fff;
  font-weight: bold;
  z-index: 1000;
  animation: slideUp 0.3s ease;
  max-width: 90%;
  text-align: center;
  white-space: pre-line;
}

.day-11-content .message-toast.error {
  background: var(--accent-red);
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateX(-50%) translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateX(-50%) translateY(0);
  }
}

/* 响应式 */
@media (max-width: 768px) {
  .identity-toggle-bar {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .input-group.label-input-row {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .input-group.label-input-row label {
    min-width: auto;
  }
  
  .button-row {
    flex-direction: column;
  }
  
  .button-row button {
    width: 100%;
  }
}
</style>
