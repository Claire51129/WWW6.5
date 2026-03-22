<template>
  <div class="day-15-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <div class="left-column">
        <div class="interaction-area">
          <h3>🎮 交互操作</h3>

          <!-- 存储可视化区 -->
          <div class="storage-visualizer" @click="handleStorageClick" title="点击了解紧凑数据类型">
            <h4 class="block-title">📊 合约存储可视化 (已创建 {{ proposalCounter }} 个提案)</h4>
            <div class="storage-slots">
              <div v-for="(slot, index) in storageData.slots" :key="slot.name || index" class="storage-slot">
                <div class="slot-header">
                  <span class="slot-name">{{ slot.name }}</span>
                  <span class="slot-type" :class="getSlotTypeClass(slot.type)">{{ slot.type }}</span>
                </div>
                <div class="slot-value">{{ slot.value }}</div>
                <div class="slot-description">{{ slot.description }}</div>
              </div>
            </div>
            <div class="click-prompt">👆 点击查看 uint8 如何节省存储</div>
          </div>

          <!-- 提案列表 -->
          <div class="proposals-section">
            <h4 class="block-title">🗳️ 提案列表 (已创建 {{ proposals.length }} 个)</h4>
            <div v-if="proposals.length === 0" class="empty-state">
              还没有提案，创建第一个提案吧！
            </div>
            <div v-else-if="proposals.length < 3 && !unlockedConcepts.includes('storage_optimization')" class="hint-message">
              💡 提示：再创建 {{ 3 - proposals.length }} 个提案即可解锁「存储优化」知识点！
            </div>
            <div v-else class="proposals-table-wrapper">
              <table class="proposals-table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>名称</th>
                    <th>投票数</th>
                    <th>结束时间</th>
                    <th>状态</th>
                    <th>操作</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="proposal in proposals" :key="proposal.id" :class="getProposalStatus(proposal).class">
                    <td>{{ proposal.id }}</td>
                    <td>{{ proposal.name }}</td>
                    <td>{{ proposal.voteCount }}</td>
                    <td>{{ proposal.endTime <= Date.now() ? '已结束' : formatRemainingTime(proposal.endTime) }}</td>
                    <td>
                      <span :class="['status-badge', getProposalStatus(proposal).class]">
                        {{ getProposalStatus(proposal).text }}
                      </span>
                    </td>
                    <td>
                      <button
                        v-if="proposal.endTime > Date.now() && !proposal.executed"
                        @click="handleVote(proposal.id)"
                        class="day-action-btn purple small"
                        title="投票"
                      >
                        🗳️ 投票
                      </button>
                      <button
                        v-if="proposal.endTime <= Date.now() && !proposal.executed"
                        @click="handleExecute(proposal.id)"
                        class="day-action-btn orange small"
                        title="执行"
                      >
                        ✅ 执行
                      </button>
                      <span v-if="proposal.executed" class="executed-icon">✓ 完成</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- 操作面板 -->
          <div class="operations-panel">
            <h4 class="block-title">⚡ 操作面板</h4>

            <!-- 创建提案 -->
            <div class="function-block">
              <code class="function-signature">函数：createProposal(bytes32 _name, uint256 _durationMinutes)</code>
              <h5>📝 创建提案</h5>
              <div class="input-group">
                <input
                  v-model="proposalName"
                  type="text"
                  placeholder="提案名称"
                  class="text-input"
                  maxlength="50"
                />
                <input
                  v-model="duration"
                  type="number"
                  placeholder="持续时间(分钟)"
                  class="number-input"
                  min="1"
                  max="60"
                />
              </div>
              <button @click="handleCreateProposal" class="day-action-btn blue full-width">
                📝 创建提案
              </button>
            </div>
          </div>

          <!-- 位运算可视化区 -->
          <div class="bit-operation-section">
            <h4 class="block-title">🔍 位运算可视化 (Bit Operation)</h4>
            <div class="bit-operation-content">
              <div class="bit-info">
                <div class="bit-info-row">
                  <span class="bit-label">选民地址:</span>
                  <span class="bit-value">{{ formatAddress(currentAddress) }}</span>
                </div>
                <div class="bit-info-row">
                  <span class="bit-label">投票位图:</span>
                  <span class="bit-value bit-binary">{{ currentVoterData.toString(2).padStart(8, '0') }}...</span>
                </div>
                <div class="bit-demo" v-if="lastVotedProposal !== null">
                  <div class="bit-demo-row">
                    <span class="bit-label">当前掩码:</span>
                    <span class="bit-value bit-highlight">{{ (1n << BigInt(lastVotedProposal)).toString(2) }}</span>
                  </div>
                  <div class="bit-demo-row">
                    <span class="bit-label">操作演示:</span>
                    <span class="bit-value"> voterData | mask (设置投票)</span>
                  </div>
                  <div class="gas-saving-tip">
                    ⚡ <strong>Gas 节省:</strong> 使用位运算，1个uint256可存储256个提案的投票状态，相比布尔映射节省约40% Gas！
                  </div>
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

          <!-- 消息提示 -->
          <div v-if="message" :class="['message-toast', { error: isError }]">
            {{ message }}
          </div>
        </div>
      </div>

      <div class="right-column">
        <!-- 知识点面板 -->
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="15"
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
      title="GasEfficientVoting 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useDay15 } from '@/composables/useDay15'
import { useProgressStore } from '@/stores/progressStore'
import { getFullCode } from '@/data/days'
import { getDay15Hint, getDay15ExplanationHint } from '@/data/concepts'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

const progressStore = useProgressStore()
const {
  proposals,
  eventLog,
  currentVoterData,
  currentAddress,
  proposalCounter,
  createProposal,
  vote,
  executeProposal,
  getStorageVisualization,
  formatAddress,
  formatTime,
  formatRemainingTime,
  getProposalStatus
} = useDay15()

// 完整代码
const fullCode = computed(() => getFullCode(15))

// 当前提示
const currentHint = ref('')

// 解锁的概念
const unlockedConcepts = computed(() => {
  return progressStore.getDayProgress(15)?.unlockedConcepts || []
})

// 进度百分比
const progressPercentage = computed(() => {
  const progress = progressStore.getDayProgress(15)
  if (!progress || progress.totalConcepts === 0) return 0
  return Math.round((progress.unlockedConcepts.length / progress.totalConcepts) * 100)
})

// 存储数据
const storageData = computed(() => getStorageVisualization())

// 表单数据
const proposalName = ref('')
const duration = ref('')
const lastVotedProposal = ref(null)

// 消息提示
const message = ref('')
const isError = ref(false)

// 显示消息
const showMessage = (msg, error = false) => {
  message.value = msg
  isError.value = error
  setTimeout(() => {
    message.value = ''
  }, 5000)
}

// 显示完整代码
const showFullCode = ref(false)

// 处理显示完整代码
const handleShowFullCode = () => {
  showFullCode.value = true
}

// 解锁概念
const unlockConcept = (concept) => {
  if (!unlockedConcepts.value.includes(concept)) {
    progressStore.unlockConcept(15, concept)
  }
}

// 获取存储槽位类型样式
const getSlotTypeClass = (type) => {
  if (type.includes('uint8') || type.includes('uint32')) return 'compact-type'
  if (type.includes('mapping')) return 'mapping-type'
  return ''
}

// 处理存储可视化点击
const handleStorageClick = () => {
  // 第一次交互：解锁 compact_datatype 和 uint8_uint32
  const hasUnlockedAny = unlockedConcepts.value.length > 0

  if (!unlockedConcepts.value.includes('compact_datatype')) {
    unlockConcept('compact_datatype')
    showMessage('📦 欢迎来到 Day 15！本合约使用紧凑数据类型优化Gas！👆 继续点击查看 uint8/uint32')
  }

  if (!unlockedConcepts.value.includes('uint8_uint32')) {
    unlockConcept('uint8_uint32')
    showMessage('🔢 uint8只需1字节，uint32只需4字节！👝 创建提案查看bytes32')
  }

  currentHint.value = getDay15Hint('uint8_uint32')
  progressStore.incrementInteraction(15)
}
const handleCreateProposal = () => {
  const result = createProposal(proposalName.value, parseInt(duration.value))

  if (result.success) {
    showMessage(result.message)

    // 解锁概念
    if (result.hints) {
      result.hints.forEach(hint => unlockConcept(hint))

      // 根据解锁的概念更新提示
      if (result.hints.includes('storage_optimization')) {
        currentHint.value = getDay15Hint('storage_optimization')
      } else if (result.hints.includes('bytes32_string')) {
        currentHint.value = getDay15Hint('bytes32_string')
      } else {
        currentHint.value = result.nextStep
      }
    } else {
      currentHint.value = result.nextStep
    }

    // 清空表单
    proposalName.value = ''
    duration.value = ''
  } else {
    showMessage(result.error, true)
    if (result.hint) {
      showMessage(result.hint)
    }
  }

  progressStore.incrementInteraction(15)
}

// 处理投票
const handleVote = (proposalId) => {
  const result = vote(proposalId)

  if (result.success) {
    lastVotedProposal.value = proposalId
    showMessage(result.message)

    // 解锁概念
    if (result.hints) {
      result.hints.forEach(hint => unlockConcept(hint))

      // 根据解锁的概念更新提示
      if (result.hints.includes('bit_operation')) {
        currentHint.value = getDay15Hint('bit_operation')
      } else if (result.hints.includes('mask_check')) {
        currentHint.value = getDay15Hint('mask_check')
      }
    } else {
      currentHint.value = result.nextStep
    }
  } else {
    showMessage(result.error, true)
    if (result.hint) {
      // 重复投票时解锁掩码检查
      if (result.hasVoted && !unlockedConcepts.value.includes('mask_check')) {
        unlockConcept('mask_check')
        showMessage(result.hint)
        currentHint.value = getDay15Hint('mask_check')
      }
    }
  }

  progressStore.incrementInteraction(15)
}

// 处理执行提案
const handleExecute = (proposalId) => {
  const result = executeProposal(proposalId)

  if (result.success) {
    showMessage(result.message)

    // 解锁概念
    if (result.hints) {
      result.hints.forEach(hint => unlockConcept(hint))

      // 根据解锁的概念更新提示
      if (result.hints.includes('event_logging')) {
        currentHint.value = getDay15Hint('event_logging')
      }
    } else {
      currentHint.value = result.nextStep
    }
  } else {
    showMessage(result.error, true)
    if (result.hint) {
      showMessage(result.hint)
    }
  }

  progressStore.incrementInteraction(15)
}

// 页面加载时不自动解锁任何概念，等待用户交互
onMounted(() => {
  // 页面加载时不解锁概念，不显示提示
  // 用户需要主动点击存储可视化区才开始学习
})
</script>

<style scoped>
.day-15-content {
  width: 100%;
  padding: 12px;
}

/* 布局样式已迁移到 day-common.css */

.interaction-area {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.block-title {
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 12px 0;
  color: var(--text-primary);
}

/* 存储可视化区 */
.storage-visualizer {
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.08) 0%, rgba(59, 130, 246, 0.08) 100%);
  border: 2px solid var(--border-main);
  border-radius: 12px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.storage-visualizer:hover {
  border-color: #22c55e;
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.2);
}

.storage-slots {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
}

.storage-slot {
  background: var(--bg-base);
  border: 1px solid var(--border-secondary);
  border-radius: 8px;
  padding: 12px;
}

.slot-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.slot-name {
  font-weight: 600;
  font-size: 13px;
  color: var(--text-primary);
}

.slot-type {
  font-size: 11px;
  padding: 2px 6px;
  border-radius: 4px;
  background: var(--bg-secondary);
}

.slot-type.compact-type {
  background: rgba(34, 197, 94, 0.2);
  color: #22c55e;
  font-weight: 600;
}

.slot-type.mapping-type {
  background: rgba(59, 130, 246, 0.2);
  color: #3b82f6;
}

.slot-value {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 4px;
}

.slot-description {
  font-size: 11px;
  color: var(--text-secondary);
  line-height: 1.4;
}

.click-prompt {
  margin-top: 12px;
  text-align: center;
  font-size: 12px;
  color: #22c55e;
  font-weight: 500;
}

/* 提案列表 */
.proposals-section {
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 10px;
  padding: 16px;
}

.empty-state {
  text-align: center;
  padding: 20px;
  color: var(--text-secondary);
  font-size: 14px;
}

.hint-message {
  background: rgba(34, 197, 94, 0.1);
  border-left: 3px solid #22c55e;
  padding: 10px 14px;
  margin-bottom: 12px;
  border-radius: 4px;
  color: var(--text-primary);
  font-size: 13px;
}

.proposals-table-wrapper {
  overflow-x: auto;
}

.proposals-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}

.proposals-table th {
  background: var(--bg-secondary);
  padding: 10px 8px;
  text-align: left;
  font-weight: 600;
  color: var(--text-primary);
  border-bottom: 2px solid var(--border-main);
}

.proposals-table td {
  padding: 10px 8px;
  border-bottom: 1px solid var(--border-secondary);
  color: var(--text-primary);
}

.proposals-table tr:hover {
  background: var(--bg-secondary);
}

.proposals-table tr.active {
  background: rgba(34, 197, 94, 0.05);
}

.proposals-table tr.ended {
  background: rgba(251, 191, 36, 0.05);
}

.proposals-table tr.executed {
  background: rgba(156, 163, 175, 0.05);
}

.status-badge {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
}

.status-badge.active {
  background: rgba(34, 197, 94, 0.2);
  color: #22c55e;
}

.status-badge.ended {
  background: rgba(251, 191, 36, 0.2);
  color: #fbbf24;
}

.status-badge.executed {
  background: rgba(156, 163, 175, 0.2);
  color: #9ca3af;
}

.executed-icon {
  font-size: 12px;
  color: var(--text-secondary);
  opacity: 0.8;
}

/* 操作面板 */
.operations-panel {
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 10px;
  padding: 16px;
}

.function-block {
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 10px;
  padding: 16px;
  margin-bottom: 16px;
}

.function-block:last-child {
  margin-bottom: 0;
}

.function-signature {
  display: block;
  background: var(--bg-secondary);
  padding: 6px 12px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 0.85em;
  color: var(--text-primary);
  margin: 0 0 15px 0;
  border-left: 3px solid #3b82f6;
  line-height: 1.4;
}

.operation-group {
  margin-bottom: 16px;
}

.operation-group:last-child {
  margin-bottom: 0;
}

.operation-group h5 {
  font-size: 13px;
  font-weight: 600;
  margin: 0 0 10px 0;
  color: var(--text-primary);
}

.input-group {
  display: flex;
  gap: 10px;
  align-items: center;
  margin-bottom: 10px;
}

.full-width {
  width: 100%;
}

.text-input,
.number-input {
  flex: 1;
  padding: 10px 14px;
  border: 1px solid var(--border-main);
  border-radius: 8px;
  background: var(--bg-secondary);
  color: var(--text-primary);
  font-size: 13px;
  transition: border-color 0.2s;
}

.text-input:focus,
.number-input:focus {
  outline: none;
  border-color: #3b82f6;
}

.text-input {
  flex: 2;
}

.number-input {
  flex: 1;
  max-width: 150px;
}

/* 位运算可视化区 */
.bit-operation-section {
  background: linear-gradient(135deg, rgba(168, 85, 247, 0.08) 0%, rgba(236, 72, 153, 0.08) 100%);
  border: 1px solid var(--border-main);
  border-radius: 10px;
  padding: 16px;
}

.bit-operation-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.bit-info {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.bit-info-row,
.bit-demo-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: var(--bg-base);
  border-radius: 6px;
}

.bit-label {
  font-size: 12px;
  font-weight: 600;
  color: var(--text-secondary);
}

.bit-value {
  font-size: 13px;
  color: var(--text-primary);
  font-family: 'Courier New', monospace;
}

.bit-binary {
  color: #a855f7;
  font-weight: 600;
}

.bit-highlight {
  color: #fbbf24;
  font-weight: 600;
}

.bit-demo {
  margin-top: 8px;
  padding: 12px;
  background: rgba(168, 85, 247, 0.1);
  border-radius: 8px;
}

.gas-saving-tip {
  margin-top: 10px;
  padding: 10px 12px;
  background: rgba(34, 197, 94, 0.15);
  border-left: 3px solid #22c55e;
  border-radius: 4px;
  font-size: 12px;
  color: var(--text-primary);
  line-height: 1.5;
}

/* 滚动条样式 */
/* 滚动条样式已迁移到 day-common.css */

/* 响应式布局已迁移到 day-common.css */

/* 事件日志样式 */
.event-timeline {
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 10px;
  padding: 16px;
  margin-top: 0;
}

.event-timeline h4 {
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 12px 0;
  color: var(--text-primary);
}

.timeline-item {
  display: flex;
  gap: 12px;
  padding: 12px;
  background: var(--bg-secondary);
  border-radius: 8px;
  margin-bottom: 10px;
  transition: all 0.2s ease;
}

.timeline-item:hover {
  background: var(--bg-base);
  transform: translateX(4px);
}

.timeline-item:last-child {
  margin-bottom: 0;
}

.timeline-icon {
  font-size: 24px;
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-base);
  border-radius: 8px;
}

.timeline-content {
  flex: 1;
  min-width: 0;
}

.event-title {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 4px;
}

.event-meta {
  font-size: 12px;
  color: var(--text-secondary);
  margin-bottom: 4px;
  word-break: break-word;
}

.event-time {
  font-size: 11px;
  color: var(--text-tertiary);
}

.timeline-item.create .timeline-icon {
  background: rgba(59, 130, 246, 0.15);
}

.timeline-item.vote .timeline-icon {
  background: rgba(168, 85, 247, 0.15);
}

.timeline-item.execute .timeline-icon {
  background: rgba(34, 197, 94, 0.15);
}

/* 消息提示 */
.message-toast {
  position: fixed;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(34, 197, 94, 0.95);
  color: white;
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 0.95rem;
  z-index: 1000;
  animation: slideUp 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
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
</style>
