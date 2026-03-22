<template>
  <div class="day-14-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <div class="left-column">
        <div class="interaction-area">
          <h3>🎮 交互操作</h3>

          <!-- 合约架构图 -->
          <div class="contract-architecture" @click="handleArchitectureClick" title="点击了解接口定义">
            <h4 class="block-title">📦 合约架构图</h4>
            <div class="architecture-diagram">
              <div class="arch-level interface-level">
                <div class="arch-box interface">
                  <div class="arch-icon">🔌</div>
                  <div class="arch-name">IDepositBox</div>
                  <div class="arch-type">Interface</div>
                </div>
              </div>
              <div class="arch-arrow">▼</div>
              <div class="arch-level abstract-level">
                <div class="arch-box abstract">
                  <div class="arch-icon">🎭</div>
                  <div class="arch-name">BaseDepositBox</div>
                  <div class="arch-type">Abstract</div>
                </div>
              </div>
              <div class="arch-arrow">▼</div>
              <div class="arch-level concrete-level">
                <div class="arch-box concrete basic">
                  <div class="arch-icon">📦</div>
                  <div class="arch-name">Basic</div>
                </div>
                <div class="arch-box concrete premium">
                  <div class="arch-icon">🏷️</div>
                  <div class="arch-name">Premium</div>
                </div>
                <div class="arch-box concrete timelocked">
                  <div class="arch-icon">⏰</div>
                  <div class="arch-name">TimeLocked</div>
                </div>
              </div>
            </div>
          </div>

          <!-- 身份切换栏 -->
          <div class="identity-toggle-bar compact">
            <div class="role-selector">
              <button 
                :class="['role-btn', { active: currentRole === 'alice' }]" 
                @click="handleSwitchRole('alice')"
                title="Alice - 初始用户"
              >
                <span class="role-icon">👩</span>
                <span class="role-name">Alice</span>
              </button>
              <button 
                :class="['role-btn', { active: currentRole === 'bob' }]" 
                @click="handleSwitchRole('bob')"
                title="Bob - 可接收转移的用户"
              >
                <span class="role-icon">👨</span>
                <span class="role-name">Bob</span>
              </button>
            </div>
          </div>

          <!-- 当前状态显示 -->
          <div class="status-indicator">
            <div class="status-item">
              <span class="status-label">👤 当前身份</span>
              <span :class="['role-badge', currentRole]">{{ currentRole === 'alice' ? '👩 Alice' : '👨 Bob' }}</span>
            </div>
            <div class="status-item">
              <span class="status-label">📦 我的存款盒</span>
              <span class="status-value">{{ myBoxes.length }} 个</span>
            </div>
          </div>

          <!-- 创建存款盒 -->
          <div class="function-block">
            <h4 class="block-title">① 创建存款盒</h4>
            <div class="create-box-buttons">
              <button @click="handleCreateBasicBox" class="day-action-btn blue">
                📦 创建基础版
              </button>
              <button @click="handleCreatePremiumBox" class="day-action-btn magenta">
                🏷️ 创建高级版
              </button>
              <div class="time-locked-row">
                <input 
                  v-model="lockDuration" 
                  type="number" 
                  placeholder="锁定时长(秒)"
                  min="10"
                  class="lock-duration-input"
                >
                <button @click="handleCreateTimeLockedBox" class="day-action-btn orange">
                  ⏰ 创建时间锁定版
                </button>
              </div>
            </div>
          </div>

          <!-- 我的存款盒列表 -->
          <div class="function-block" v-if="myBoxes.length > 0">
            <h4 class="block-title">② 我的存款盒列表</h4>
            <div class="deposit-box-list">
              <div 
                v-for="box in myBoxes" 
                :key="box.id"
                :class="['deposit-box-card', box.type.toLowerCase(), { selected: selectedBox?.id === box.id }]"
                @click="selectBox(box)"
              >
                <div class="box-header">
                  <span class="box-icon">{{ getBoxIcon(box.type) }}</span>
                  <span class="box-title">Box #{{ box.id }} ({{ box.type }})</span>
                </div>
                <div class="box-info">
                  <div class="info-row">
                    <span class="info-label">创建时间:</span>
                    <span class="info-value">{{ formatTime(box.createdAt) }}</span>
                  </div>
                  <div class="info-row" v-if="box.type === 'TimeLocked' && box.unlockTime">
                    <span class="info-label">锁定状态:</span>
                    <span :class="['lock-status', isUnlocked(box) ? 'unlocked' : 'locked']">
                      {{ isUnlocked(box) ? '✅ 已解锁' : `⏰ 剩余 ${getRemainingTime(box)}秒` }}
                    </span>
                  </div>
                  <div class="info-row" v-if="box.type === 'Premium' && box.metadata">
                    <span class="info-label">元数据:</span>
                    <span class="info-value metadata-preview">{{ box.metadata }}</span>
                  </div>
                  <div class="info-row" v-if="box.secret">
                    <span class="info-label">秘密:</span>
                    <span class="info-value secret-stored">🔐 已存储</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 操作选中存款盒 -->
          <div class="function-block" v-if="selectedBox">
            <h4 class="block-title">③ 操作 Box #{{ selectedBox.id }} ({{ selectedBox.type }})</h4>
            
            <!-- 存秘密 -->
            <div class="sub-function">
              <code class="function-signature">函数：storeSecret(string secret)</code>
              <div class="input-group">
                <input 
                  v-model="secretInput" 
                  type="text" 
                  placeholder="输入要存储的秘密"
                  class="secret-input"
                >
              </div>
              <button @click="handleStoreSecret" class="day-action-btn green small">🔐 存秘密</button>
            </div>

            <!-- 取秘密 -->
            <div class="sub-function">
              <code class="function-signature">函数：getSecret()</code>
              <button @click="handleGetSecret" class="day-action-btn cyan small">🔓 取秘密</button>
              <div v-if="retrievedSecret !== null" class="result-display">
                秘密: <strong>{{ retrievedSecret }}</strong>
              </div>
            </div>

            <!-- Premium 特有功能 -->
            <template v-if="selectedBox.type === 'Premium'">
              <div class="sub-function">
                <code class="function-signature">函数：setMetadata(string metadata)</code>
                <div class="input-group">
                  <input 
                    v-model="metadataInput" 
                    type="text" 
                    placeholder="输入元数据"
                    class="metadata-input"
                  >
                </div>
                <button @click="handleSetMetadata" class="day-action-btn magenta small">🏷️ 设置元数据</button>
              </div>
            </template>

            <!-- TimeLocked 特有功能 -->
            <template v-if="selectedBox.type === 'TimeLocked'">
              <div class="sub-function">
                <code class="function-signature">函数：getRemainingLockTime()</code>
                <button @click="handleGetRemainingTime" class="day-action-btn cyan small">⏱️ 查询剩余时间</button>
                <div v-if="remainingTimeResult !== null" class="result-display">
                  剩余锁定时间: <strong>{{ remainingTimeResult }} 秒</strong>
                </div>
              </div>
            </template>

            <!-- 转移所有权 -->
            <div class="sub-function">
              <code class="function-signature">函数：transferOwnership(address newOwner)</code>
              <div class="input-group">
                <label>新所有者：</label>
                <select v-model="newOwner" class="role-select">
                  <option :value="roles.alice">Alice</option>
                  <option :value="roles.bob">Bob</option>
                </select>
              </div>
              <button @click="handleTransferOwnership" class="day-action-btn yellow small">🔑 转移所有权</button>
            </div>
          </div>

          <!-- 完成所有权转移 -->
          <div class="function-block" v-if="hasTransferredBoxes">
            <h4 class="block-title">④ 完成所有权转移</h4>
            <div class="sub-function">
              <code class="function-signature">函数：VaultManager.completeOwnershipTransfer(address boxAddress)</code>
              <p class="info-text">有新存款盒转移给你，点击完成转移流程：</p>
              <button @click="handleCompleteTransfer" class="day-action-btn orange">✅ 完成所有权转移</button>
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
          :current-day="14"
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
      title="SafeDeposit 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useDay14 } from '@/composables/useDay14'
import { useProgressStore } from '@/stores/progressStore'
import { getFullCode } from '@/data/days'
import { getDay14Hint, getDay14ExplanationHint } from '@/data/concepts'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

const progressStore = useProgressStore()

// Day14 业务逻辑
const {
  roles,
  currentRole,
  depositBoxes,
  currentAddress,
  myBoxes,
  eventLog,
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
  completeOwnershipTransfer,
  switchRole,
  getBoxIcon,
  formatTime
} = useDay14()

// 输入状态
const lockDuration = ref('30')
const selectedBox = ref(null)
const secretInput = ref('')
const metadataInput = ref('')
const newOwner = ref('')
const retrievedSecret = ref(null)
const remainingTimeResult = ref(null)

// 消息提示
const message = ref('')
const isError = ref(false)

// 完整代码弹窗
const showFullCode = ref(false)
const fullCode = computed(() => getFullCode(14))

// 当前提示
const currentHint = ref('')

// 解锁的概念
const unlockedConcepts = computed(() => {
  return progressStore.getDayProgress(14)?.unlockedConcepts || []
})

// 进度百分比
const progressPercentage = computed(() => {
  return progressStore.getProgressPercentage(14) || 0
})

// 检查是否有转移给当前用户的存款盒
const hasTransferredBoxes = computed(() => {
  // 检查是否有转移给当前用户但尚未完成的盒子
  // 通过检查 depositBoxes 中 owner 是当前用户，但 createdBy 不是当前用户的盒子
  const currentAddr = currentAddress.value
  const transferredBoxes = depositBoxes.value.filter(box => {
    // 盒子属于当前用户
    const isOwnedByCurrent = box.owner === currentAddr
    // 盒子不是当前用户创建的（即转移来的）
    const isNotCreatedByCurrent = box.createdBy !== currentRole.value
    return isOwnedByCurrent && isNotCreatedByCurrent
  })
  return transferredBoxes.length > 0
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
    progressStore.unlockConcept(14, concept)
  }
}

// 解锁多个概念
const unlockConcepts = (concepts) => {
  concepts.forEach(concept => unlockConcept(concept))
}

// 选择存款盒
const selectBox = (box) => {
  selectedBox.value = box
  retrievedSecret.value = null
  remainingTimeResult.value = null
  secretInput.value = ''
  metadataInput.value = ''
}

// 检查盒子是否已解锁
const isUnlocked = (box) => {
  if (box.type !== 'TimeLocked' || !box.unlockTime) return true
  return Date.now() >= box.unlockTime
}

// 获取剩余时间
const getRemainingTime = (box) => {
  if (!box.unlockTime) return 0
  return Math.max(0, Math.ceil((box.unlockTime - Date.now()) / 1000))
}

// 页面加载时不自动解锁任何概念，等待用户交互

// 处理点击合约架构图
const handleArchitectureClick = () => {
  // 检查是否已解锁
  if (unlockedConcepts.value.includes('interface_definition')) {
    currentHint.value = getDay14Hint('interface_definition')
    return
  }

  // 解锁接口定义
  unlockConcept('interface_definition')
  showMessage('🎉 恭喜解锁：接口定义！🔌 接口定义了所有存款盒必须实现的功能规范！', false)
  currentHint.value = getDay14Hint('interface_definition')
  progressStore.incrementInteraction(14)
}

// 处理切换角色
const handleSwitchRole = (role) => {
  const result = switchRole(role)
  showMessage(result.message, !result.success)
  selectedBox.value = null
}

// 处理创建基础存款盒
const handleCreateBasicBox = () => {
  const result = createBasicBox()
  showMessage(result.message, !result.success)

  if (result.success) {
    unlockConcepts(result.hints)
    // 根据解锁的概念更新提示
    if (result.hints && result.hints.includes('factory_pattern')) {
      currentHint.value = getDay14Hint('factory_pattern')
    } else if (result.hints && result.hints.includes('inheritance')) {
      currentHint.value = getDay14Hint('inheritance')
    }
  }

  progressStore.incrementInteraction(14)
}

// 处理创建高级存款盒
const handleCreatePremiumBox = () => {
  const result = createPremiumBox()
  showMessage(result.message, !result.success)

  if (result.success) {
    unlockConcepts(result.hints)
    // 根据解锁的概念更新提示
    if (result.hints && result.hints.includes('factory_pattern')) {
      currentHint.value = getDay14Hint('factory_pattern')
    } else if (result.hints && result.hints.includes('virtual_function')) {
      currentHint.value = getDay14Hint('virtual_function')
    }
  }

  progressStore.incrementInteraction(14)
}

// 处理创建时间锁定存款盒
const handleCreateTimeLockedBox = () => {
  const duration = parseInt(lockDuration.value)
  if (!duration || duration <= 0) {
    showMessage('❌ 请输入有效的锁定时长', true)
    return
  }
  
  const result = createTimeLockedBox(duration)
  showMessage(result.message, !result.success)

  if (result.success) {
    unlockConcepts(result.hints)
    // 根据解锁的概念更新提示
    if (result.hints && result.hints.includes('factory_pattern')) {
      currentHint.value = getDay14Hint('factory_pattern')
    } else {
      currentHint.value = getDay14Hint('abstract_contract')
    }
  }

  progressStore.incrementInteraction(14)
}

// 处理存入秘密
const handleStoreSecret = () => {
  if (!selectedBox.value) {
    showMessage('❌ 请先选择一个存款盒', true)
    return
  }

  if (!secretInput.value.trim()) {
    showMessage('❌ 请输入秘密内容', true)
    return
  }

  const result = storeSecret(selectedBox.value.id, secretInput.value.trim())
  showMessage(result.message, !result.success)

  if (result.success) {
    secretInput.value = ''
    // 解锁概念
    if (result.hints) {
      unlockConcepts(result.hints)
    }
    // 更新提示
    currentHint.value = getDay14Hint('store_secret')
  } else {
    // 失败时也显示引导提示
    if (result.nextStep) {
      currentHint.value = result.nextStep
    }
  }

  progressStore.incrementInteraction(14)
}

// 处理取出秘密
const handleGetSecret = () => {
  if (!selectedBox.value) {
    showMessage('❌ 请先选择一个存款盒', true)
    return
  }

  const result = getSecret(selectedBox.value.id)
  showMessage(result.message, !result.success)

  if (result.success) {
    retrievedSecret.value = result.secret
    // 成功时直接设置提示，不解锁概念
    currentHint.value = getDay14Hint('get_secret')
  }

  if (result.hints) {
    unlockConcepts(result.hints)
    // 根据解锁的概念更新提示
    if (result.hints.includes('modifier_combination')) {
      currentHint.value = getDay14Hint('modifier_combination')
    } else if (result.hints.includes('super_keyword')) {
      currentHint.value = getDay14Hint('super_keyword')
    }
  } else if (!result.success && result.nextStep) {
    // 失败时显示引导提示
    currentHint.value = result.nextStep
  }

  progressStore.incrementInteraction(14)
}

// 处理设置元数据
const handleSetMetadata = () => {
  if (!selectedBox.value) {
    showMessage('❌ 请先选择一个存款盒', true)
    return
  }

  if (!metadataInput.value.trim()) {
    showMessage('❌ 请输入元数据', true)
    return
  }

  const result = setMetadata(selectedBox.value.id, metadataInput.value.trim())
  showMessage(result.message, !result.success)

  if (result.success) {
    unlockConcepts(result.hints)
    metadataInput.value = ''
    // 更新提示
    currentHint.value = getDay14Hint('metadata_storage')
  } else if (result.nextStep) {
    // 失败时显示引导提示
    currentHint.value = result.nextStep
  }

  progressStore.incrementInteraction(14)
}

// 处理查询剩余时间
const handleGetRemainingTime = () => {
  if (!selectedBox.value) {
    showMessage('❌ 请先选择一个存款盒', true)
    return
  }
  
  const result = getRemainingLockTime(selectedBox.value.id)
  remainingTimeResult.value = result
  
  progressStore.incrementInteraction(14)
}

// 处理转移所有权
const handleTransferOwnership = () => {
  if (!selectedBox.value) {
    showMessage('❌ 请先选择一个存款盒', true)
    return
  }
  
  if (!newOwner.value) {
    showMessage('❌ 请选择新所有者', true)
    return
  }
  
  if (newOwner.value === currentRole.value) {
    showMessage('❌ 不能转移给自己', true)
    return
  }
  
  const result = transferOwnership(selectedBox.value.id, newOwner.value)
  showMessage(result.message, !result.success)

  if (result.success) {
    unlockConcepts(result.hints)
    selectedBox.value = null
    newOwner.value = ''
    // 如果有解锁 factory_pattern，更新提示
    if (result.hints && result.hints.includes('factory_pattern')) {
      currentHint.value = getDay14Hint('factory_pattern')
    } else {
      currentHint.value = getDay14Hint('transfer_ownership')
    }
  } else if (result.nextStep) {
    // 失败时显示引导提示
    currentHint.value = result.nextStep
  }

  progressStore.incrementInteraction(14)
}

// 处理完成所有权转移
const handleCompleteTransfer = () => {
  showMessage('✅ 所有权转移流程演示完成！')
  progressStore.incrementInteraction(14)
}

// 处理显示完整代码
const handleShowFullCode = () => {
  showFullCode.value = true
}
</script>

<style scoped>
.day-14-content {
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
  border-bottom: 2px solid var(--accent-blue);
  padding-bottom: 8px;
}

/* 合约架构图 */
.contract-architecture {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.1) 0%, rgba(139, 92, 246, 0.1) 100%);
  border: 1px solid var(--border-main);
  border-radius: 10px;
  padding: 16px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
}

.contract-architecture:hover {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.15) 0%, rgba(139, 92, 246, 0.15) 100%);
  border-color: var(--accent-blue);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.2);
}

.contract-architecture:active {
  transform: translateY(0);
}

.contract-architecture::after {
  content: '👆 点击了解接口定义';
  position: absolute;
  top: 8px;
  right: 8px;
  font-size: 0.75rem;
  color: var(--text-muted);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.contract-architecture:hover::after {
  opacity: 1;
}

.architecture-diagram {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.arch-level {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: center;
}

.arch-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 12px 16px;
  border-radius: 8px;
  min-width: 100px;
  text-align: center;
}

.arch-box.interface {
  background: rgba(59, 130, 246, 0.2);
  border: 2px solid #3b82f6;
}

.arch-box.abstract {
  background: rgba(139, 92, 246, 0.2);
  border: 2px solid #8b5cf6;
}

.arch-box.concrete {
  background: rgba(16, 185, 129, 0.2);
  border: 2px solid #10b981;
}

.arch-box.concrete.premium {
  border-color: #d946ef;
  background: rgba(217, 70, 239, 0.2);
}

.arch-box.concrete.timelocked {
  border-color: #f97316;
  background: rgba(249, 115, 22, 0.2);
}

.arch-icon {
  font-size: 1.5rem;
  margin-bottom: 4px;
}

.arch-name {
  font-weight: 600;
  font-size: 0.85rem;
  color: var(--text-main);
}

.arch-type {
  font-size: 0.7rem;
  color: var(--text-secondary);
  margin-top: 2px;
}

.arch-arrow {
  font-size: 1.2rem;
  color: var(--text-secondary);
}

/* 身份切换栏 */
.identity-toggle-bar {
  margin-bottom: 12px;
}

.identity-toggle-bar.compact {
  padding: 8px;
  background: var(--bg-surface);
  border-radius: 8px;
  border: 1px solid var(--border-main);
}

.role-selector {
  display: flex;
  gap: 8px;
}

.role-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 8px 12px;
  border: 1px solid var(--border-main);
  border-radius: 6px;
  background: var(--bg-surface);
  color: var(--text-secondary);
  cursor: pointer;
  transition: all 0.2s ease;
}

.role-btn:hover {
  border-color: var(--accent-blue);
  background: rgba(59, 130, 246, 0.1);
}

.role-btn.active {
  border-color: var(--accent-blue);
  background: rgba(59, 130, 246, 0.2);
  color: var(--text-main);
}

.role-icon {
  font-size: 1.1rem;
}

.role-name {
  font-size: 0.85rem;
  font-weight: 500;
}

/* 状态指示器 */
.status-indicator {
  display: flex;
  gap: 16px;
  padding: 12px;
  background: var(--bg-surface);
  border-radius: 8px;
  margin-bottom: 12px;
  border: 1px solid var(--border-main);
}

.status-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-label {
  font-size: 0.85rem;
  color: var(--text-secondary);
}

.status-value {
  font-weight: 600;
  color: var(--text-main);
}

.role-badge {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 600;
}

.role-badge.alice {
  background: rgba(236, 72, 153, 0.2);
  color: #ec4899;
}

.role-badge.bob {
  background: rgba(59, 130, 246, 0.2);
  color: #3b82f6;
}

/* 功能块 */
.function-block {
  background: var(--bg-surface);
  border: 1px solid var(--border-main);
  border-radius: 8px;
  padding: 14px;
  margin-bottom: 12px;
}

.block-title {
  margin: 0 0 12px 0;
  font-size: 1rem;
  color: var(--text-main);
  border-bottom: 1px solid var(--border-main);
  padding-bottom: 8px;
}

/* 创建盒子按钮 */
.create-box-buttons {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.time-locked-row {
  display: flex;
  gap: 8px;
  align-items: center;
}

.lock-duration-input {
  flex: 0 0 120px;
  padding: 8px 12px;
  border: 1px solid var(--border-main);
  border-radius: 6px;
  background: var(--bg-base);
  color: var(--text-main);
  font-size: 0.9rem;
}

/* 存款盒列表 */
.deposit-box-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.deposit-box-card {
  background: var(--bg-base);
  border: 2px solid var(--border-main);
  border-radius: 8px;
  padding: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.deposit-box-card:hover {
  border-color: var(--accent-blue);
  transform: translateY(-2px);
}

.deposit-box-card.selected {
  border-color: var(--accent-blue);
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
}

.deposit-box-card.premium {
  border-color: rgba(217, 70, 239, 0.3);
}

.deposit-box-card.premium:hover,
.deposit-box-card.premium.selected {
  border-color: #d946ef;
}

.deposit-box-card.timelocked {
  border-color: rgba(249, 115, 22, 0.3);
}

.deposit-box-card.timelocked:hover,
.deposit-box-card.timelocked.selected {
  border-color: #f97316;
}

.box-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.box-icon {
  font-size: 1.2rem;
}

.box-title {
  font-weight: 600;
  color: var(--text-main);
}

.box-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.info-row {
  display: flex;
  gap: 8px;
  font-size: 0.8rem;
}

.info-label {
  color: var(--text-secondary);
  min-width: 70px;
}

.info-value {
  color: var(--text-main);
}

.info-value.metadata-preview {
  color: #d946ef;
  font-style: italic;
}

.info-value.secret-stored {
  color: #10b981;
}

.lock-status {
  font-size: 0.8rem;
  font-weight: 500;
}

.lock-status.locked {
  color: #f97316;
}

.lock-status.unlocked {
  color: #10b981;
}

/* 子功能块 */
.sub-function {
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 6px;
  padding: 12px;
  margin-bottom: 10px;
}

.sub-function:last-child {
  margin-bottom: 0;
}

.function-signature {
  display: block;
  font-size: 0.8rem;
  color: var(--text-secondary);
  background: rgba(0, 0, 0, 0.2);
  padding: 6px 8px;
  border-radius: 4px;
  margin-bottom: 10px;
  font-family: monospace;
}

/* 输入组 */
.input-group {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
}

.input-group label {
  font-size: 0.85rem;
  color: var(--text-secondary);
  min-width: 80px;
}

.secret-input,
.metadata-input {
  flex: 1;
  padding: 8px 12px;
  border: 1px solid var(--border-main);
  border-radius: 6px;
  background: var(--bg-base);
  color: var(--text-main);
  font-size: 0.9rem;
}

.role-select {
  flex: 1;
  padding: 8px 12px;
  border: 1px solid var(--border-main);
  border-radius: 6px;
  background: var(--bg-base);
  color: var(--text-main);
  font-size: 0.9rem;
}

/* 结果显示 */
.result-display {
  margin-top: 8px;
  padding: 8px 12px;
  background: rgba(16, 185, 129, 0.1);
  border: 1px solid rgba(16, 185, 129, 0.3);
  border-radius: 6px;
  color: var(--text-main);
  font-size: 0.9rem;
}

/* 信息文本 */
.info-text {
  font-size: 0.85rem;
  color: var(--text-secondary);
  margin-bottom: 10px;
}

/* 事件时间线 */
.event-timeline {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--border-main);
}

.event-timeline h4 {
  margin: 0 0 12px 0;
  color: var(--text-main);
  font-size: 1rem;
}

.timeline-item {
  display: flex;
  gap: 10px;
  padding: 10px;
  background: var(--bg-surface);
  border-radius: 6px;
  margin-bottom: 8px;
  border-left: 3px solid var(--accent-blue);
}

.timeline-icon {
  font-size: 1.2rem;
  flex-shrink: 0;
}

.timeline-content {
  flex: 1;
  min-width: 0;
}

.event-title {
  font-weight: 600;
  color: var(--text-main);
  font-size: 0.9rem;
}

.event-meta {
  color: var(--text-secondary);
  font-size: 0.8rem;
  margin-top: 2px;
}

.event-time {
  color: var(--text-secondary);
  font-size: 0.75rem;
  margin-top: 4px;
}

/* 消息提示 */
.message-toast {
  position: fixed;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(16, 185, 129, 0.9);
  color: white;
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 0.95rem;
  z-index: 1000;
  animation: slideUp 0.3s ease;
}

.message-toast.error {
  background: rgba(239, 68, 68, 0.9);
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

/* 响应式布局已移至全局CSS */

@media (max-width: 768px) {
  
  .time-locked-row {
    flex-direction: column;
    align-items: stretch;
  }
  
  .lock-duration-input {
    flex: 1;
  }
}
</style>
