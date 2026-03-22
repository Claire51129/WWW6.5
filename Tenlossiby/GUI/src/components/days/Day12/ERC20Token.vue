<template>
  <div class="day-12-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <div class="left-column">
        <div class="interaction-area">
          <h3>🎮 交互操作</h3>

          <!-- 代币信息区块 -->
          <div class="token-info-block" @click="handleTokenInfoClick">
            <h4>🪙 {{ tokenInfo.name }} ({{ tokenInfo.symbol }})</h4>
            <div class="token-details">
              <div class="token-item">
                <span class="token-label">名称:</span>
                <span class="token-value">{{ tokenInfo.name }}</span>
              </div>
              <div class="token-item">
                <span class="token-label">符号:</span>
                <span class="token-value">{{ tokenInfo.symbol }}</span>
              </div>
              <div class="token-item">
                <span class="token-label">小数位:</span>
                <span class="token-value">{{ tokenInfo.decimals }}</span>
              </div>
              <div class="token-item">
                <span class="token-label">总供应量:</span>
                <span class="token-value">{{ tokenInfo.totalSupply.toLocaleString() }} {{ tokenInfo.symbol }}</span>
              </div>
            </div>
            <div class="token-hint">💡 点击了解 ERC20 标准</div>
          </div>

          <!-- 身份切换栏 -->
          <div class="identity-toggle-bar compact">
            <div class="role-selector">
              <button 
                :class="['role-btn', { active: currentRole === 'alice' }]" 
                @click="handleSwitchRole('alice')"
                title="Alice - 代币持有者"
              >
                <span class="role-icon">👑</span>
                <span class="role-name">Alice</span>
              </button>
              <button 
                :class="['role-btn', { active: currentRole === 'bob' }]" 
                @click="handleSwitchRole('bob')"
                title="Bob - 普通用户"
              >
                <span class="role-icon">👤</span>
                <span class="role-name">Bob</span>
              </button>
              <button 
                :class="['role-btn', { active: currentRole === 'carol' }]" 
                @click="handleSwitchRole('carol')"
                title="Carol - 被授权者"
              >
                <span class="role-icon">🔑</span>
                <span class="role-name">Carol</span>
              </button>
            </div>
          </div>

          <!-- 余额状态显示 -->
          <div class="status-indicator">
            <div class="status-item">
              <span class="status-label">💰 账户余额</span>
            </div>
            <div class="status-details">
              <div><strong>Alice:</strong> {{ balances[roles.alice].toLocaleString() }} COM</div>
              <div><strong>Bob:</strong> {{ balances[roles.bob].toLocaleString() }} COM</div>
              <div><strong>Carol:</strong> {{ balances[roles.carol].toLocaleString() }} COM</div>
              <div :class="['role-badge', currentRole]">
                <strong>当前:</strong> {{ currentRole === 'alice' ? '👑 Alice (持有者)' : currentRole === 'bob' ? '👤 Bob (用户)' : '🔑 Carol (被授权者)' }}
              </div>
            </div>
          </div>

          <!-- 查询余额功能 -->
          <div class="function-block">
            <h4 class="block-title">📊 查询余额 - balanceOf</h4>
            <div class="sub-function">
              <code class="function-signature">函数：balanceOf(address account) view returns (uint256)</code>
              <div class="input-group">
                <label>查询地址：</label>
                <select v-model="selectedBalanceAddress" class="role-select">
                  <option :value="roles.alice">Alice</option>
                  <option :value="roles.bob">Bob</option>
                  <option :value="roles.carol">Carol</option>
                </select>
              </div>
              <button @click="handleGetBalance" class="day-action-btn cyan">🔍 查询余额</button>
              <div v-if="balanceResult !== null" class="result-display">
                余额: <strong>{{ balanceResult.toLocaleString() }} COM</strong>
              </div>
            </div>
          </div>

          <!-- 转账功能 -->
          <div class="function-block">
            <h4 class="block-title">💰 转账 - transfer</h4>
            <div class="sub-function">
              <code class="function-signature">函数：transfer(address to, uint256 value) returns (bool)</code>
              <div class="input-group">
                <label>接收地址：</label>
                <select v-model="transferTo" class="role-select">
                  <option :value="roles.bob">Bob</option>
                  <option :value="roles.carol">Carol</option>
                </select>
              </div>
              <div class="input-group">
                <label>转账数量：</label>
                <input 
                  v-model="transferAmount" 
                  type="number" 
                  placeholder="请输入数量"
                  min="1"
                  @click.stop
                >
                <span class="unit">COM</span>
              </div>
              <button @click="handleTransfer" class="day-action-btn yellow">💸 执行转账</button>
              <div class="info-message">
                💡 当前身份: {{ currentRole === 'alice' ? 'Alice' : currentRole === 'bob' ? 'Bob' : 'Carol' }}
                <span v-if="currentRole !== 'alice'" class="warning"> (注意：只有 Alice 有余额可以转账)</span>
              </div>
            </div>
          </div>

          <!-- 授权功能 -->
          <div class="function-block">
            <h4 class="block-title">✅ 授权 - approve</h4>
            <div class="sub-function">
              <code class="function-signature">函数：approve(address spender, uint256 value) returns (bool)</code>
              <div class="input-group">
                <label>被授权者：</label>
                <select v-model="approveSpender" class="role-select">
                  <option :value="roles.carol">Carol</option>
                  <option :value="roles.bob">Bob</option>
                </select>
              </div>
              <div class="input-group">
                <label>授权额度：</label>
                <input 
                  v-model="approveAmount" 
                  type="number" 
                  placeholder="请输入额度"
                  min="1"
                  @click.stop
                >
                <span class="unit">COM</span>
              </div>
              <button @click="handleApprove" class="day-action-btn magenta">✅ 授权</button>
              <div v-if="currentRole !== 'alice'" class="error-message">
                ⚠️ 只有 Alice 可以授权他人使用她的代币
              </div>
            </div>
          </div>

          <!-- 查询授权额度 -->
          <div class="function-block">
            <h4 class="block-title">🔍 查询授权额度 - allowance</h4>
            <div class="sub-function">
              <code class="function-signature">函数：allowance(address owner, address spender) view returns (uint256)</code>
              <div class="input-group">
                <label>持有者：</label>
                <select v-model="allowanceOwner" class="role-select">
                  <option :value="roles.alice">Alice</option>
                </select>
              </div>
              <div class="input-group">
                <label>被授权者：</label>
                <select v-model="allowanceSpender" class="role-select">
                  <option :value="roles.carol">Carol</option>
                  <option :value="roles.bob">Bob</option>
                </select>
              </div>
              <button @click="handleGetAllowance" class="day-action-btn cyan">🔍 查询额度</button>
              <div v-if="allowanceResult !== null" class="result-display">
                授权额度: <strong>{{ allowanceResult }} COM</strong>
              </div>
            </div>
          </div>

          <!-- 代转账功能 -->
          <div class="function-block">
            <h4 class="block-title">🔄 代转账 - transferFrom</h4>
            <div class="sub-function">
              <code class="function-signature">函数：transferFrom(address from, address to, uint256 value) returns (bool)</code>
              <div class="input-group">
                <label>从地址：</label>
                <select v-model="transferFromAddress" class="role-select">
                  <option :value="roles.alice">Alice</option>
                </select>
              </div>
              <div class="input-group">
                <label>到地址：</label>
                <select v-model="transferFromTo" class="role-select">
                  <option :value="roles.bob">Bob</option>
                  <option :value="roles.carol">Carol</option>
                </select>
              </div>
              <div class="input-group">
                <label>转账数量：</label>
                <input 
                  v-model="transferFromAmount" 
                  type="number" 
                  placeholder="请输入数量"
                  min="1"
                  @click.stop
                >
                <span class="unit">COM</span>
              </div>
              <button @click="handleTransferFrom" class="day-action-btn orange">🔄 执行代转账</button>
              <div v-if="currentRole !== 'carol'" class="info-message">
                💡 提示：请切换到 Carol 身份来执行代转账
              </div>
              <div v-else class="info-message">
                💡 Carol 当前可用 Alice 的额度: {{ allowances[roles.alice]?.[roles.carol] || 0 }} COM
              </div>
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
        
        <!-- 消息提示 -->
        <div v-if="message" :class="['message-toast', { error: isError }]">
          {{ message }}
        </div>
      </div>

      <!-- 右侧：知识面板 -->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="12"
          :unlocked-concepts="unlockedConcepts"
          :progress-percentage="progressPercentage"
          :full-code="fullCode"
          :custom-hint="currentHint"
          @show-full-code="handleShowFullCode"
        />
      </div>
    </div>

    <!-- 完整代码弹窗 -->
    <FullCodeModal
      :show="showFullCode"
      title="SimpleERC20 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useDay12 } from '@/composables/useDay12'
import { useProgressStore } from '@/stores/progressStore'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

const progressStore = useProgressStore()

// Day12 业务逻辑
const {
  tokenInfo,
  roles,
  balances,
  allowances,
  currentRole,
  currentAddress,
  eventLog,
  switchRole,
  getBalance,
  transfer,
  approve,
  getAllowance,
  transferFrom,
  formatTime
} = useDay12()

// 输入状态
const selectedBalanceAddress = ref(roles.alice)
const balanceResult = ref(null)

const transferTo = ref(roles.bob)
const transferAmount = ref('')

const approveSpender = ref(roles.carol)
const approveAmount = ref('')

const allowanceOwner = ref(roles.alice)
const allowanceSpender = ref(roles.carol)
const allowanceResult = ref(null)

const transferFromAddress = ref(roles.alice)
const transferFromTo = ref(roles.bob)
const transferFromAmount = ref('')

// 弹窗状态
const showFullCode = ref(false)
const fullCode = computed(() => getFullCode(12))

// 消息提示
const message = ref('')
const isError = ref(false)

// 当前交互提示
const currentHint = ref('')

// 显示消息
const showMessage = (msg, error = false) => {
  message.value = msg
  isError.value = error
  setTimeout(() => {
    message.value = ''
  }, 3000)
}

// 解锁的概念
const unlockedConcepts = computed(() => {
  return progressStore.getDayProgress(12)?.unlockedConcepts || []
})

// 进度百分比
const progressPercentage = computed(() => {
  const progress = progressStore.getDayProgress(12)
  if (!progress || progress.totalConcepts === 0) return 0
  return Math.round((progress.unlockedConcepts.length / progress.totalConcepts) * 100)
})

// 解锁概念
const unlockConcept = (concept) => {
  if (!unlockedConcepts.value.includes(concept)) {
    progressStore.unlockConcept(12, concept)
  }
}

// 解锁多个概念
const unlockConcepts = (concepts) => {
  concepts.forEach(concept => unlockConcept(concept))
}

// 处理代币信息点击
const handleTokenInfoClick = () => {
  unlockConcept('erc20_standard')
  showMessage('📦 太棒了！你了解了 ERC20 代币标准！这是以太坊上最通用的代币规范。👉 查询 Alice 余额来学习 mapping 存储机制！')
}

// 处理角色切换
const handleSwitchRole = (role) => {
  const result = switchRole(role)
  if (result.success) {
    showMessage(result.message)
  }
}

// 处理查询余额
const handleGetBalance = () => {
  const result = getBalance(selectedBalanceAddress.value)
  if (result.success) {
    balanceResult.value = result.balance
    currentHint.value = result.nextStep
    showMessage(result.message + ' ' + result.nextStep)
  }
}

// 处理转账
const handleTransfer = () => {
  const amount = parseInt(transferAmount.value)
  if (isNaN(amount) || amount <= 0 || !Number.isInteger(amount)) {
    showMessage('❌ 请输入有效的转账数量（正整数）！', true)
    return
  }
  if (amount > balances.value[currentAddress.value]) {
    showMessage(`❌ 余额不足！当前余额: ${balances.value[currentAddress.value].toLocaleString()} COM`, true)
    return
  }
  
  const result = transfer(transferTo.value, amount)
  if (result.success) {
    unlockConcepts(result.hints)
    currentHint.value = result.nextStep
    showMessage(result.message + ' ' + result.nextStep)
    transferAmount.value = ''
  } else {
    showMessage(result.message, true)
  }
}

// 处理授权
const handleApprove = () => {
  const amount = parseInt(approveAmount.value)
  if (isNaN(amount) || amount <= 0 || !Number.isInteger(amount)) {
    showMessage('❌ 请输入有效的授权额度（正整数）！', true)
    return
  }
  
  const result = approve(approveSpender.value, amount)
  if (result.success) {
    unlockConcepts(result.hints)
    currentHint.value = result.nextStep
    showMessage(result.message + ' ' + result.nextStep)
    approveAmount.value = ''
  } else {
    showMessage(result.message, true)
  }
}

// 处理查询授权额度
const handleGetAllowance = () => {
  const result = getAllowance(allowanceOwner.value, allowanceSpender.value)
  if (result.success) {
    allowanceResult.value = result.allowance
    unlockConcepts(result.hints)
    currentHint.value = result.nextStep
    showMessage(result.message + ' ' + result.nextStep)
  }
}

// 处理代转账
const handleTransferFrom = () => {
  const amount = parseInt(transferFromAmount.value)
  if (isNaN(amount) || amount <= 0 || !Number.isInteger(amount)) {
    showMessage('❌ 请输入有效的转账数量（正整数）！', true)
    return
  }
  
  const result = transferFrom(transferFromAddress.value, transferFromTo.value, amount)
  if (result.success) {
    unlockConcepts(result.hints)
    currentHint.value = result.nextStep
    showMessage(result.message + ' ' + result.nextStep)
    transferFromAmount.value = ''
  } else {
    showMessage(result.message, true)
  }
}

// 显示完整代码
const handleShowFullCode = () => {
  showFullCode.value = true
}
</script>

<style scoped>
.day-12-content {
  padding: 12px;
}

/* 布局样式已移至全局CSS day-common.css */

.interaction-area {
  background: var(--bg-surface-1);
  border-radius: 10px;
  padding: 16px;
  border: 1px solid var(--border-main);
}

.interaction-area h3 {
  margin: 0 0 12px 0;
  color: var(--text-main);
  font-size: 1.25rem;
  border-bottom: 2px solid var(--accent-cyan);
  padding-bottom: 8px;
}

/* 代币信息区块 */
.token-info-block {
  background: linear-gradient(135deg, rgba(42, 161, 152, 0.1) 0%, rgba(133, 153, 0, 0.1) 100%);
  border: 2px solid var(--accent-cyan);
  border-radius: 10px;
  padding: 14px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.token-info-block:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(42, 161, 152, 0.2);
}

.token-info-block h4 {
  margin: 0 0 15px 0;
  color: var(--accent-cyan);
  font-size: 1.2rem;
}

.token-details {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-bottom: 10px;
}

.token-item {
  display: flex;
  justify-content: space-between;
  padding: 8px 12px;
  background: var(--bg-base);
  border-radius: 6px;
}

.token-label {
  color: var(--text-muted);
  font-size: 0.9rem;
}

.token-value {
  color: var(--text-main);
  font-weight: 600;
}

.token-hint {
  text-align: center;
  color: var(--accent-cyan);
  font-size: 0.85rem;
  margin-top: 10px;
  opacity: 0.8;
}

/* 身份切换栏 */
.identity-toggle-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  padding: 10px;
  background: var(--bg-base);
  border-radius: 8px;
  border: 1px solid var(--border-main);
}

.identity-toggle-bar.compact {
  padding: 8px;
  margin-bottom: 10px;
}

.identity-label {
  font-weight: 600;
  color: var(--text-main);
  white-space: nowrap;
}

.toggle-buttons {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.toggle-buttons button {
  min-width: 100px;
}

.toggle-buttons button.active {
  background: var(--accent-cyan);
  color: white;
}

/* 紧凑式身份选择器 */
.role-selector {
  display: flex;
  gap: 8px;
  width: 100%;
}

.role-btn {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  padding: 8px 4px;
  border: 2px solid var(--border-main);
  border-radius: 8px;
  background: var(--bg-surface-1);
  cursor: pointer;
  transition: all 0.2s ease;
  min-width: 60px;
}

.role-btn:hover {
  border-color: var(--accent-cyan);
  transform: translateY(-1px);
}

.role-btn.active {
  border-color: var(--accent-cyan);
  background: rgba(42, 161, 152, 0.15);
}

.role-btn.active .role-icon {
  transform: scale(1.1);
}

.role-icon {
  font-size: 1.2rem;
  transition: transform 0.2s ease;
}

.role-name {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--text-main);
}

/* 状态显示 */
.status-indicator {
  background: var(--bg-base);
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 12px;
  border: 1px solid var(--border-main);
}

.status-item {
  font-weight: 600;
  color: var(--text-main);
  margin-bottom: 8px;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--border-main);
}

.status-details {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  font-size: 0.9rem;
}

.status-details div {
  color: var(--text-muted);
}

.role-badge {
  grid-column: 1 / -1;
  margin-top: 8px;
  padding: 8px 12px;
  border-radius: 6px;
  text-align: center;
}

.role-badge.alice {
  background: rgba(234, 179, 8, 0.2);
  color: #eab308;
}

.role-badge.bob {
  background: rgba(59, 130, 246, 0.2);
  color: #3b82f6;
}

.role-badge.carol {
  background: rgba(168, 85, 247, 0.2);
  color: #a855f7;
}

/* 功能区块 */
.function-block {
  background: var(--bg-base);
  border-radius: 8px;
  padding: 14px;
  margin-bottom: 12px;
  border: 1px solid var(--border-main);
}

.block-title {
  margin: 0 0 10px 0;
  color: var(--text-main);
  font-size: 1rem;
  padding-bottom: 10px;
  border-bottom: 1px solid var(--border-main);
}

.sub-function {
  margin-bottom: 15px;
}

.sub-function:last-child {
  margin-bottom: 0;
}

.function-signature {
  display: block;
  background: var(--bg-surface-2);
  padding: 10px;
  border-radius: 6px;
  font-size: 0.85rem;
  color: var(--accent-cyan);
  margin-bottom: 15px;
  font-family: 'Fira Code', monospace;
  overflow-x: auto;
}

/* 输入组 */
.input-group {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}

.input-group label {
  min-width: 80px;
  color: var(--text-muted);
  font-size: 0.9rem;
}

.input-group input,
.input-group select {
  flex: 1;
  padding: 10px 12px;
  border: 1px solid var(--border-main);
  border-radius: 6px;
  background: var(--bg-surface-2);
  color: var(--text-main);
  font-size: 0.95rem;
}

.input-group input:focus,
.input-group select:focus {
  outline: none;
  border-color: var(--accent-cyan);
}

.role-select {
  cursor: pointer;
}

.unit {
  color: var(--text-muted);
  font-size: 0.9rem;
  white-space: nowrap;
}

/* 结果显示 */
.result-display {
  margin-top: 12px;
  padding: 12px;
  background: rgba(133, 153, 0, 0.1);
  border-radius: 6px;
  color: var(--text-main);
}

.result-display strong {
  color: var(--accent-green);
  font-size: 1.1rem;
}

/* 消息提示 */
.message-toast {
  position: fixed;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(34, 197, 94, 0.95);
  color: white;
  padding: 15px 25px;
  border-radius: 8px;
  font-weight: 500;
  z-index: 1000;
  animation: slideUp 0.3s ease;
  max-width: 90%;
  text-align: center;
  white-space: pre-line;
}

.message-toast.error {
  background: rgba(239, 68, 68, 0.95);
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

/* 信息/错误消息 */
.info-message {
  margin-top: 10px;
  padding: 10px;
  background: rgba(59, 130, 246, 0.1);
  border-radius: 6px;
  color: #3b82f6;
  font-size: 0.9rem;
}

.info-message .warning {
  color: #f59e0b;
}

.error-message {
  margin-top: 10px;
  padding: 10px;
  background: rgba(239, 68, 68, 0.1);
  border-radius: 6px;
  color: #ef4444;
  font-size: 0.9rem;
}

/* 事件时间线 */
.event-timeline {
  margin-top: 12px;
  padding: 14px;
  background: var(--bg-base);
  border-radius: 8px;
  border: 1px solid var(--border-main);
}

.event-timeline h4 {
  margin: 0 0 10px 0;
  color: var(--text-main);
  font-size: 1rem;
}

.timeline-item {
  display: flex;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid var(--border-main);
}

.timeline-item:last-child {
  border-bottom: none;
}

.timeline-icon {
  font-size: 1.2rem;
  flex-shrink: 0;
}

.timeline-content {
  flex: 1;
}

.event-title {
  font-weight: 600;
  color: var(--text-main);
  margin-bottom: 4px;
}

.event-meta {
  color: var(--text-muted);
  font-size: 0.9rem;
  margin-bottom: 4px;
}

.event-time {
  color: var(--text-muted);
  font-size: 0.8rem;
  opacity: 0.7;
}

/* 响应式布局已移至全局CSS */

@media (max-width: 640px) {
  .token-details {
    grid-template-columns: 1fr;
  }
  
  .status-details {
    grid-template-columns: 1fr;
  }
  
  .identity-toggle-bar {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .toggle-buttons {
    width: 100%;
  }
  
  .toggle-buttons button {
    flex: 1;
  }
  
  .role-selector {
    gap: 6px;
  }
  
  .role-btn {
    padding: 6px 2px;
    min-width: 50px;
  }
  
  .role-icon {
    font-size: 1rem;
  }
  
  .role-name {
    font-size: 0.75rem;
  }
  
  .input-group {
    flex-wrap: wrap;
    gap: 8px;
  }
  
  .input-group label {
    min-width: auto;
    width: 100%;
    margin-bottom: 4px;
  }
  
  .input-group input,
  .input-group select {
    flex: 1;
    min-width: 0;
  }
  
  .unit {
    font-size: 0.85rem;
  }
}
</style>
