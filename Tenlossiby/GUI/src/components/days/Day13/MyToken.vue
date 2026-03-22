<template>
  <div class="day-13-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <div class="left-column">
        <div class="interaction-area">
          <h3>🎮 交互操作</h3>

          <!-- 代币信息区块 -->
          <div class="token-info-block day13" @click="handleTokenInfoClick">
            <div class="token-header">
              <h4>🪙 {{ tokenInfo.name }} ({{ tokenInfo.symbol }})</h4>
              <span class="day-badge">Day 13</span>
            </div>
            <div class="comparison-badge">
              <span class="day12-ref">Day 12: COM</span>
              <span class="arrow">→</span>
              <span class="day13-ref">Day 13: WBT</span>
              <span class="difference-tag">差异: virtual</span>
            </div>
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
            <div class="token-hint">💡 点击了解 decimals 和构造函数铸造</div>
          </div>

          <!-- 身份切换栏 -->
          <div class="identity-toggle-bar compact">
            <div class="role-selector">
              <button 
                :class="['role-btn', { active: currentRole === 'deployer' }]" 
                @click="handleSwitchRole('deployer')"
                title="Deployer - 合约部署者/代币持有者"
              >
                <span class="role-icon">🚀</span>
                <span class="role-name">Deployer</span>
              </button>
              <button 
                :class="['role-btn', { active: currentRole === 'alice' }]" 
                @click="handleSwitchRole('alice')"
                title="Alice - 普通用户"
              >
                <span class="role-icon">👑</span>
                <span class="role-name">Alice</span>
              </button>
              <button 
                :class="['role-btn', { active: currentRole === 'bob' }]" 
                @click="handleSwitchRole('bob')"
                title="Bob - 可被授权者"
              >
                <span class="role-icon">🔑</span>
                <span class="role-name">Bob</span>
              </button>
            </div>
          </div>

          <!-- 余额状态显示 -->
          <div class="status-indicator">
            <div class="status-item">
              <span class="status-label">💰 账户余额</span>
            </div>
            <div class="status-details">
              <div><strong>Deployer:</strong> {{ balances[roles.deployer].toLocaleString() }} WBT 🚀</div>
              <div><strong>Alice:</strong> {{ balances[roles.alice].toLocaleString() }} WBT 👑</div>
              <div><strong>Bob:</strong> {{ balances[roles.bob].toLocaleString() }} WBT</div>
              <div :class="['role-badge', currentRole]">
                <strong>当前:</strong> {{ currentRole === 'deployer' ? '🚀 Deployer (合约部署者)' : currentRole === 'alice' ? '👑 Alice (用户)' : '🔑 Bob (被授权者)' }}
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
                  <option :value="roles.deployer">Deployer</option>
                  <option :value="roles.alice">Alice</option>
                  <option :value="roles.bob">Bob</option>
                </select>
              </div>
              <button @click="handleGetBalance" class="day-action-btn cyan">🔍 查询余额</button>
              <div v-if="balanceResult !== null" class="result-display">
                余额: <strong>{{ balanceResult.toLocaleString() }} WBT</strong>
              </div>
            </div>
          </div>

          <!-- 转账功能 -->
          <div class="function-block">
            <h4 class="block-title">💰 转账 - transfer</h4>
            <div class="sub-function">
              <code class="function-signature">函数：transfer(address to, uint256 value) returns (bool)</code>
              <div class="code-highlight">
                <span class="highlight-note">→ 内部调用</span>
                <code class="highlight-code">_transfer(msg.sender, _to, _value)</code>
              </div>
              <div class="input-group">
                <label>接收地址：</label>
                <select v-model="transferTo" class="role-select">
                  <option :value="roles.alice">Alice</option>
                  <option :value="roles.bob">Bob</option>
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
                <span class="unit">WBT</span>
              </div>
              <button @click="handleTransfer" class="day-action-btn yellow">💸 执行转账</button>
              <div class="info-message">
                💡 当前身份: {{ currentRole === 'deployer' ? 'Deployer' : currentRole === 'alice' ? 'Alice' : 'Bob' }}
                <span v-if="currentRole !== 'deployer'" class="warning"> (注意：只有 Deployer 有余额可以转账)</span>
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
                  <option :value="roles.alice">Alice</option>
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
                <span class="unit">WBT</span>
              </div>
              <button @click="handleApprove" class="day-action-btn magenta">✅ 授权</button>
              <div v-if="currentRole !== 'deployer'" class="error-message">
                ⚠️ 只有 Deployer 可以授权他人使用他的代币
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
                  <option :value="roles.deployer">Deployer</option>
                </select>
              </div>
              <div class="input-group">
                <label>被授权者：</label>
                <select v-model="allowanceSpender" class="role-select">
                  <option :value="roles.alice">Alice</option>
                  <option :value="roles.bob">Bob</option>
                </select>
              </div>
              <button @click="handleGetAllowance" class="day-action-btn cyan">🔍 查询额度</button>
              <div v-if="allowanceResult !== null" class="result-display">
                授权额度: <strong>{{ allowanceResult }} WBT</strong>
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
                  <option :value="roles.deployer">Deployer</option>
                </select>
              </div>
              <div class="input-group">
                <label>到地址：</label>
                <select v-model="transferFromTo" class="role-select">
                  <option :value="roles.alice">Alice</option>
                  <option :value="roles.bob">Bob</option>
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
                <span class="unit">WBT</span>
              </div>
              <button @click="handleTransferFrom" class="day-action-btn orange">🔄 执行代转账</button>
              <div v-if="currentRole !== 'bob'" class="info-message">
                💡 提示：请切换到 Bob 身份来执行代转账
              </div>
              <div v-else class="info-message">
                💡 Bob 当前可用 Deployer 的额度: {{ allowances[roles.deployer]?.[roles.bob] || 0 }} WBT
              </div>
            </div>
          </div>

          <!-- 继承演示区 -->
          <div class="inheritance-demo-block">
            <h4 class="block-title">🧬 继承演示区 - Virtual 的用途</h4>
            <div class="demo-content">
              <div class="code-comparison">
                <div class="code-section">
                  <div class="code-label">// MyToken.sol (父合约)</div>
                  <pre class="code-block"><code>function _transfer(address _from, 
         address _to, 
         uint256 _value)
    <span class="highlight">internal virtual</span> {
    // 基础转账逻辑
}</code></pre>
                </div>
                <div class="code-section">
                  <div class="code-label">// MyTokenWithFee.sol (子合约)</div>
                  <pre class="code-block"><code>contract MyTokenWithFee 
    <span class="highlight">is MyToken</span> {
    function _transfer(...)
        internal <span class="highlight">override</span> {
        // 收取手续费
        <span class="highlight">super</span>._transfer(...);
    }
}</code></pre>
                </div>
              </div>
              <div class="demo-explanation">
                <div class="exp-item">
                  <span class="exp-icon">🔓</span>
                  <span class="exp-text"><strong>virtual:</strong> 父合约允许函数被重写</span>
                </div>
                <div class="exp-item">
                  <span class="exp-icon">📝</span>
                  <span class="exp-text"><strong>override:</strong> 子合约重写父合约函数</span>
                </div>
                <div class="exp-item">
                  <span class="exp-icon">⬆️</span>
                  <span class="exp-text"><strong>super:</strong> 调用父合约的原始函数</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 事件日志 -->
          <div class="event-timeline" v-if="eventLog.length > 0">
            <h4>📜 事件日志</h4>
            <div v-for="(event, index) in eventLog.slice().reverse()" :key="index" 
                 :class="['timeline-item', event.type]">
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
          :current-day="13"
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
      title="MyToken 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useDay13 } from '@/composables/useDay13'
import { useProgressStore } from '@/stores/progressStore'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

const progressStore = useProgressStore()

// Day13 业务逻辑
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
} = useDay13()

// 输入状态
const selectedBalanceAddress = ref(roles.deployer)
const balanceResult = ref(null)

const transferTo = ref(roles.alice)
const transferAmount = ref('')

const approveSpender = ref(roles.bob)
const approveAmount = ref('')

const allowanceOwner = ref(roles.deployer)
const allowanceSpender = ref(roles.bob)
const allowanceResult = ref(null)

const transferFromAddress = ref(roles.deployer)
const transferFromTo = ref(roles.alice)
const transferFromAmount = ref('')

// 消息提示
const message = ref('')
const isError = ref(false)

// 完整代码弹窗
const showFullCode = ref(false)
const fullCode = computed(() => getFullCode(13))

// 当前提示
const currentHint = ref('')

// 解锁的概念
const unlockedConcepts = computed(() => {
  return progressStore.getDayProgress(13)?.unlockedConcepts || []
})

// 进度百分比
const progressPercentage = computed(() => {
  return progressStore.getProgressPercentage(13) || 0
})

// 显示消息
const showMessage = (msg, error = false) => {
  message.value = msg
  isError.value = error
  setTimeout(() => {
    message.value = ''
  }, 5000)
}

// 解锁概念
const unlockConcept = (concept) => {
  if (!unlockedConcepts.value.includes(concept)) {
    progressStore.unlockConcept(13, concept)
  }
}

// 解锁多个概念
const unlockConcepts = (concepts) => {
  concepts.forEach(concept => unlockConcept(concept))
}

// 处理代币信息点击
const handleTokenInfoClick = () => {
  // 解锁 constructor_mint 和 zero_address_mint
  unlockConcept('constructor_mint')
  unlockConcept('zero_address_mint')
  showMessage('🪙 太棒了！你了解了构造函数铸造和零地址！合约部署时自动铸造代币给部署者。👉 执行转账操作来解锁 internal 和 virtual 函数！')
}

// 处理切换角色
const handleSwitchRole = (role) => {
  const result = switchRole(role)
  showMessage(result.message, !result.success)
}

// 处理查询余额
const handleGetBalance = () => {
  const result = getBalance(selectedBalanceAddress.value)
  balanceResult.value = result.balance
  showMessage(result.message, !result.success)
  
  // 增加交互计数
  progressStore.incrementInteraction(13)
}

// 处理转账
const handleTransfer = () => {
  const amount = parseInt(transferAmount.value)
  if (!amount || amount <= 0) {
    showMessage('❌ 请输入有效的转账数量', true)
    return
  }
  
  const result = transfer(transferTo.value, amount)
  showMessage(result.message, !result.success)
  
  // 解锁概念
  if (result.hints) {
    unlockConcepts(result.hints)
    // 转账成功后同时解锁 virtual_function
    unlockConcept('virtual_function')
  }
  
  // 增加交互计数
  progressStore.incrementInteraction(13)
  
  // 清空输入
  if (result.success) {
    transferAmount.value = ''
  }
}

// 处理授权
const handleApprove = () => {
  const amount = parseInt(approveAmount.value)
  if (!amount || amount <= 0) {
    showMessage('❌ 请输入有效的授权额度', true)
    return
  }
  
  const result = approve(approveSpender.value, amount)
  showMessage(result.message, !result.success)
  
  // 增加交互计数
  progressStore.incrementInteraction(13)
  
  // 清空输入
  if (result.success) {
    approveAmount.value = ''
  }
}

// 处理查询授权额度
const handleGetAllowance = () => {
  const result = getAllowance(allowanceOwner.value, allowanceSpender.value)
  allowanceResult.value = result.allowance
  showMessage(result.message, !result.success)
  
  // 增加交互计数
  progressStore.incrementInteraction(13)
}

// 处理代转账
const handleTransferFrom = () => {
  const amount = parseInt(transferFromAmount.value)
  if (!amount || amount <= 0) {
    showMessage('❌ 请输入有效的转账数量', true)
    return
  }
  
  const result = transferFrom(transferFromAddress.value, transferFromTo.value, amount)
  showMessage(result.message, !result.success)
  
  // 增加交互计数
  progressStore.incrementInteraction(13)
  
  // 清空输入
  if (result.success) {
    transferFromAmount.value = ''
  }
}

// 处理显示完整代码
const handleShowFullCode = () => {
  // 解锁 virtual_function
  unlockConcept('virtual_function')
  showFullCode.value = true
}
</script>

<style scoped>
.day-13-content {
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
  border-bottom: 2px solid var(--accent-purple);
  padding-bottom: 8px;
}

/* 代币信息区块 - Day 13 紫色主题 */
.token-info-block {
  background: linear-gradient(135deg, rgba(168, 85, 247, 0.1) 0%, rgba(236, 72, 153, 0.1) 100%);
  border: 1px solid var(--border-main);
  border-radius: 10px;
  padding: 16px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.token-info-block:hover {
  border-color: rgba(168, 85, 247, 0.6);
  box-shadow: 0 4px 12px rgba(168, 85, 247, 0.15);
}

.token-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.token-info-block h4 {
  margin: 0;
  color: var(--text-primary);
  font-size: 1.1rem;
}

.day-badge {
  background: rgba(168, 85, 247, 0.2);
  color: #a855f7;
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
}

.comparison-badge {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
  padding: 8px 12px;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 8px;
  font-size: 0.85rem;
}

.day12-ref {
  color: #06b6d4;
  font-weight: 500;
}

.arrow {
  color: var(--text-secondary);
}

.day13-ref {
  color: #a855f7;
  font-weight: 600;
}

.difference-tag {
  margin-left: auto;
  background: rgba(168, 85, 247, 0.3);
  color: #d8b4fe;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 0.75rem;
}

.token-details {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.token-item {
  display: flex;
  justify-content: space-between;
  font-size: 0.9rem;
}

.token-label {
  color: var(--text-secondary);
}

.token-value {
  color: var(--text-primary);
  font-weight: 500;
}

.token-hint {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid rgba(168, 85, 247, 0.2);
  color: #d8b4fe;
  font-size: 0.8rem;
  text-align: center;
}

/* 身份切换栏 */
.identity-toggle-bar {
  margin-bottom: 12px;
}

.identity-toggle-bar.compact {
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 8px;
  padding: 10px;
}

.role-selector {
  display: flex;
  gap: 10px;
}

.role-btn {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 12px 8px;
  background: var(--bg-secondary);
  border: 2px solid transparent;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.role-btn:hover {
  background: var(--bg-primary);
}

.role-btn.active {
  border-color: #a855f7;
  background: rgba(168, 85, 247, 0.1);
}

.role-icon {
  font-size: 1.5rem;
}

.role-name {
  font-size: 0.8rem;
  color: var(--text-primary);
  font-weight: 500;
}

/* 状态指示器 */
.status-indicator {
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 12px;
}

.status-item {
  margin-bottom: 12px;
}

.status-label {
  font-weight: 600;
  color: var(--text-primary);
}

.status-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
  font-size: 0.9rem;
  color: var(--text-secondary);
}

.role-badge {
  margin-top: 8px;
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 0.85rem;
}

.role-badge.deployer {
  background: rgba(168, 85, 247, 0.15);
  color: #d8b4fe;
}

.role-badge.alice {
  background: rgba(6, 182, 212, 0.15);
  color: #67e8f9;
}

.role-badge.bob {
  background: rgba(245, 158, 11, 0.15);
  color: #fcd34d;
}

/* 功能区块 */
.function-block {
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 8px;
  padding: 14px;
  margin-bottom: 12px;
}

.block-title {
  margin: 0 0 12px 0;
  color: var(--text-primary);
  font-size: 1rem;
}

.sub-function {
  margin-bottom: 12px;
}

.sub-function:last-child {
  margin-bottom: 0;
}

.function-signature {
  display: block;
  background: rgba(0, 0, 0, 0.3);
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 0.8rem;
  color: var(--text-secondary);
  margin-bottom: 12px;
  font-family: monospace;
}

.code-highlight {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  padding: 8px 12px;
  background: rgba(168, 85, 247, 0.1);
  border-radius: 6px;
  border-left: 3px solid #a855f7;
}

.highlight-note {
  font-size: 0.75rem;
  color: #d8b4fe;
  font-weight: 500;
}

.highlight-code {
  font-family: monospace;
  font-size: 0.8rem;
  color: var(--text-primary);
}

.input-group {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}

.input-group label {
  min-width: 80px;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.input-group input,
.input-group select {
  flex: 1;
  padding: 8px 12px;
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: 6px;
  color: var(--text-primary);
  font-size: 0.9rem;
}

.input-group input:focus,
.input-group select:focus {
  outline: none;
  border-color: #a855f7;
}

.unit {
  color: var(--text-secondary);
  font-size: 0.85rem;
}

.result-display {
  margin-top: 12px;
  padding: 10px;
  background: rgba(168, 85, 247, 0.1);
  border-radius: 6px;
  color: var(--text-primary);
}

.info-message {
  margin-top: 12px;
  padding: 10px;
  background: rgba(6, 182, 212, 0.1);
  border-radius: 6px;
  color: #67e8f9;
  font-size: 0.85rem;
}

.info-message .warning {
  color: #fbbf24;
}

.error-message {
  margin-top: 12px;
  padding: 10px;
  background: rgba(239, 68, 68, 0.1);
  border-radius: 6px;
  color: #f87171;
  font-size: 0.85rem;
}

/* 继承演示区 */
.inheritance-demo-block {
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 8px;
  padding: 14px;
  margin-bottom: 12px;
}

.demo-content {
  margin-top: 12px;
}

.code-comparison {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  margin-bottom: 16px;
}

.code-section {
  background: rgba(0, 0, 0, 0.3);
  border-radius: 8px;
  padding: 12px;
}

.code-label {
  font-size: 0.75rem;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

.code-block {
  margin: 0;
  font-size: 0.75rem;
  line-height: 1.5;
  color: var(--text-primary);
  overflow-x: auto;
}

.code-block .highlight {
  color: #a855f7;
  font-weight: 600;
}

.demo-explanation {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.exp-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
  color: var(--text-secondary);
}

.exp-icon {
  font-size: 1rem;
}

.exp-text strong {
  color: #d8b4fe;
}

/* 事件时间线 */
.event-timeline {
  background: var(--bg-tertiary);
  border-radius: 10px;
  padding: 16px;
}

.event-timeline h4 {
  margin: 0 0 16px 0;
  color: var(--text-primary);
}

.timeline-item {
  display: flex;
  gap: 12px;
  padding: 12px;
  border-radius: 8px;
  margin-bottom: 8px;
  background: var(--bg-secondary);
}

.timeline-item.mint {
  background: rgba(168, 85, 247, 0.15);
  border-left: 3px solid #a855f7;
}

.timeline-item.transfer {
  background: rgba(34, 197, 94, 0.1);
  border-left: 3px solid #22c55e;
}

.timeline-item.approval {
  background: rgba(245, 158, 11, 0.1);
  border-left: 3px solid #f59e0b;
}

.timeline-icon {
  font-size: 1.25rem;
}

.timeline-content {
  flex: 1;
}

.event-title {
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 4px;
}

.event-meta {
  font-size: 0.85rem;
  color: var(--text-secondary);
  margin-bottom: 4px;
}

.event-time {
  font-size: 0.75rem;
  color: var(--text-tertiary);
}

/* 消息提示 */
.message-toast {
  position: fixed;
  bottom: 24px;
  left: 50%;
  transform: translateX(-50%);
  padding: 12px 24px;
  border-radius: 8px;
  background: var(--accent-green);
  color: white;
  font-weight: 500;
  z-index: 1000;
  animation: slideUp 0.3s ease;
}

.message-toast.error {
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

/* 按钮样式 */
.day-action-btn {
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  color: white;
}

.day-action-btn.cyan {
  background: linear-gradient(135deg, #06b6d4, #0891b2);
}

.day-action-btn.yellow {
  background: linear-gradient(135deg, #eab308, #ca8a04);
}

.day-action-btn.magenta {
  background: linear-gradient(135deg, #d946ef, #c026d3);
}

.day-action-btn.orange {
  background: linear-gradient(135deg, #f97316, #ea580c);
}

.day-action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

/* 响应式布局已移至全局CSS */

@media (max-width: 768px) {

  .code-comparison {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 640px) {
  .day-13-content {
    padding: 8px;
  }
  
  .interaction-area {
    padding: 12px;
  }
}
</style>
