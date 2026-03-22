<template>
  <div class="day-19-content day-content">
    <div v-if="message" :class="['message-toast', { error: isError }]">
      {{ message }}
    </div>

    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <div class="left-column">
        <div class="interaction-area">

          <div class="section signature-flow-section" @click="handleFlowClick">
            <div class="section-header">
              <h4>🔐 签名验证流程</h4>
              <span class="hover-hint">👆 点击了解 ECDSA 签名</span>
            </div>
            <div class="signature-flow">
              <div class="flow-step">
                <span class="icon">👤</span>
                <span class="label">用户地址</span>
                <span class="value">{{ formatAddress(currentUserAddress) }}</span>
              </div>
              <div class="arrow">↓ 🔐 keccak256</div>
              <div class="flow-step">
                <span class="icon">🔢</span>
                <span class="label">消息哈希</span>
                <span class="value" v-if="generatedSignature">
                  {{ generatedSignature.messageHash?.substring(0, 10) }}...
                </span>
                <span class="value placeholder" v-else>?</span>
              </div>
              <div class="arrow">↓ 📋 添加前缀</div>
              <div class="flow-step">
                <span class="icon">📝</span>
                <span class="label">ETH签名消息</span>
                <span class="value" v-if="generatedSignature">
                  {{ generatedSignature.ethSignedMessageHash?.substring(0, 10) }}...
                </span>
                <span class="value placeholder" v-else>?</span>
              </div>
              <div class="arrow">↓ 🔓 ecrecover</div>
              <div class="flow-step success">
                <span class="icon">✅</span>
                <span class="label">恢复签名者</span>
                <span class="value">{{ formatAddress(organizer) }}</span>
              </div>
            </div>
          </div>

          <div class="section role-section">
            <div class="section-header">
              <h4>👤 角色切换</h4>
            </div>
            <div class="role-toggle-buttons">
              <button
                class="role-btn"
                :class="{ active: currentRole === 'organizer' }"
                @click="handleToggleRole('organizer')"
              >
                🏢 组织者
              </button>
              <button
                class="role-btn"
                :class="{ active: currentRole === 'participant' }"
                @click="handleToggleRole('participant')"
              >
                👤 参与者
              </button>
            </div>
          </div>

          <div class="section info-section">
            <div class="section-header">
              <h4>📋 信息面板</h4>
            </div>
            <div class="info-display">
              <div class="info-row">
                <span class="label">组织者地址:</span>
                <span class="value address">{{ formatAddress(organizer) }}</span>
              </div>
              <div class="info-row">
                <span class="label">当前用户地址:</span>
                <span class="value address">{{ formatAddress(currentUserAddress) }}</span>
              </div>
              <div class="info-row">
                <span class="label">当前状态:</span>
                <span :class="['value', isEntered ? 'entered' : 'not-entered']">
                  {{ isEntered ? '✅ 已参与' : '❌ 未参与' }}
                </span>
              </div>
            </div>
            <div class="user-selector" v-if="currentRole === 'participant'">
              <span class="selector-label">切换测试用户:</span>
              <div class="user-buttons">
                <button
                  v-for="addr in testAddresses"
                  :key="addr"
                  class="user-btn"
                  :class="{ active: currentUserAddress === addr }"
                  @click="handleChangeUser(addr)"
                >
                  {{ formatAddress(addr) }}
                </button>
              </div>
            </div>
          </div>

          <div class="section participate-section">
            <div class="section-header">
              <h4>🎫 参与活动</h4>
            </div>
            <div class="signature-generator">
              <button class="day-action-btn purple" @click="handleGenerateSignature">
                🔐 生成签名
              </button>
              <div class="signature-display" v-if="generatedSignature">
                <div class="signature-full">
                  <span class="sig-label">完整签名:</span>
                  <span class="sig-value">{{ generatedSignature.full?.substring(0, 20) }}...</span>
                </div>
                <button class="toggle-details-btn" @click="handleToggleSignatureDetails">
                  {{ showSignatureDetails ? '🔽 收起详情' : '🔼 展开 R/S/V 详情' }}
                </button>
                <div class="signature-details" v-if="showSignatureDetails">
                  <div class="detail-row">
                    <span class="detail-label">r:</span>
                    <span class="detail-value">{{ generatedSignature.r?.substring(0, 18) }}...</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">s:</span>
                    <span class="detail-value">{{ generatedSignature.s?.substring(0, 18) }}...</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">v:</span>
                    <span class="detail-value">{{ generatedSignature.v }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div class="participate-action">
              <button
                class="day-action-btn green"
                @click="handleEnterEvent"
                :disabled="!generatedSignature"
              >
                🎫 使用签名参与活动
              </button>
              <p class="hint" v-if="!generatedSignature">
                💡 请先点击"生成签名"获取有效的活动参与凭证
              </p>
            </div>
          </div>

          <div class="section participants-section">
            <div class="section-header">
              <h4>📊 参与者列表</h4>
            </div>
            <div class="participants-display">
              <div class="participant-count">
                <span>已参与用户数:</span>
                <span class="count">{{ participantsList.length }}</span>
              </div>
              <div class="participant-list" v-if="participantsList.length > 0">
                <div
                  v-for="addr in participantsList"
                  :key="addr"
                  class="participant-item"
                >
                  {{ formatAddress(addr) }}
                </div>
              </div>
              <div class="empty-list" v-else>
                暂无参与者
              </div>
            </div>
            <div class="participants-actions">
              <button class="day-action-btn cyan" @click="handleGetParticipants">
                🔄 刷新参与者列表
              </button>
            </div>
          </div>

          <div class="section gasless-info-section">
            <div class="section-header">
              <h4>💡 无 Gas 空投说明</h4>
            </div>
            <div class="gasless-info">
              <p>使用签名验证，用户<strong>不需要持有 ETH</strong> 就能参与活动！</p>
              <ul>
                <li>📝 组织者签名授权特定用户</li>
                <li>💰 用户无需支付 Gas 费用</li>
                <li>🎯 适用于代币空投、白名单等场景</li>
              </ul>
            </div>
          </div>

        </div>
      </div>

      <div class="right-column">
        <KnowledgePanel
          :current-day="19"
          :unlocked-concepts="unlockedConcepts"
          :progress-percentage="progressPercentage"
          :full-code="fullCode"
          :custom-hint="currentHint"
          @show-full-code="handleShowFullCode"
        />
      </div>
    </div>

    <FullCodeModal
      :show="showFullCode"
      :code="fullCode"
      title="SignThis 完整代码"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useDay19 } from '@/composables/useDay19'
import { useProgressStore } from '@/stores/progressStore'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

const progressStore = useProgressStore()

const {
  currentRole,
  currentUserAddress,
  organizer,
  generatedSignature,
  showSignatureDetails,
  isEntered,
  participantsList,
  formatAddress,
  generateSignature,
  enterEvent,
  getParticipants,
  toggleSignatureDetails,
  toggleRole,
  changeUserAddress
} = useDay19()

const testAddresses = [
  '0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc',
  '0x976EA74026E726554dB657fA54763abd0C3a0aa9',
  '0x14dC79964da2C08b23698B3d3cc7Ca32193d9955'
]

const unlockedConcepts = computed(() =>
  progressStore.getDayProgress(19)?.unlockedConcepts || []
)

const progressPercentage = computed(() => {
  const progress = progressStore.getDayProgress(19)
  if (!progress || progress.totalConcepts === 0) return 0
  return Math.round((progress.unlockedConcepts.length / progress.totalConcepts) * 100)
})

const fullCode = getFullCode(19)

const message = ref('')
const isError = ref(false)
const showFullCode = ref(false)
const currentHint = ref('')

const showMessage = (msg, error = false) => {
  message.value = msg
  isError.value = error
  setTimeout(() => {
    message.value = ''
  }, 5000)
}

const unlockConcept = (conceptKey) => {
  if (!unlockedConcepts.value.includes(conceptKey)) {
    progressStore.unlockConcept(19, conceptKey)
  }
}

const handleToggleRole = (role) => {
  if (role === currentRole.value) return

  const result = toggleRole(role)
  showMessage(result.message, !result.success)
  
  if (role === 'organizer') {
    currentHint.value = '🏢 你现在是组织者身份！组织者是合约部署者，拥有特殊权限。👉 点击签名流程图了解 ECDSA 签名！'
  } else {
    currentHint.value = '👤 你现在是参与者身份！参与者可以通过签名参与活动。👉 点击签名流程图了解 ECDSA 签名！'
  }
}

const handleChangeUser = (addr) => {
  changeUserAddress(addr)
  showMessage(`🔄 已切换用户\n地址: ${formatAddress(addr)}\n\n⚠️ 签名已清空，请重新生成`)
}

const handleShowFullCode = () => {
  showFullCode.value = true
}

const handleFlowClick = () => {
  if (!unlockedConcepts.value.includes('ecdsa_signature')) {
    unlockConcept('ecdsa_signature')
    currentHint.value = '🎯 你了解了 ECDSA 椭圆曲线签名！这是以太坊使用的数字签名算法。👉 点击生成签名来体验完整流程！'
    showMessage('✅ 已查看签名流程图！🎉 恭喜解锁：ECDSA椭圆曲线签名！')
  }
}

const handleGenerateSignature = () => {
  const result = generateSignature()
  showMessage(result.message, !result.success)

  if (result.success) {
    if (!unlockedConcepts.value.includes('keccak256_hash')) {
      unlockConcept('keccak256_hash')
    }
    if (!unlockedConcepts.value.includes('msg_sender')) {
      unlockConcept('msg_sender')
    }
    currentHint.value = result.nextStep
  }
}

const handleToggleSignatureDetails = () => {
  const result = toggleSignatureDetails()

  if (result.success && !unlockedConcepts.value.includes('signature_rsv')) {
    unlockConcept('signature_rsv')
    currentHint.value = result.nextStep
    showMessage('✅ 已展开签名详情！🎉 恭喜解锁：签名组件R/S/V！')
  }
}

const handleEnterEvent = () => {
  const result = enterEvent()
  showMessage(result.message, !result.success)

  if (result.success) {
    if (!unlockedConcepts.value.includes('ecrecover')) {
      unlockConcept('ecrecover')
    }
    if (!unlockedConcepts.value.includes('require_statement')) {
      unlockConcept('require_statement')
    }
    if (!unlockedConcepts.value.includes('eip191_prefix')) {
      unlockConcept('eip191_prefix')
    }
    currentHint.value = result.nextStep
  }
}

const handleGetParticipants = () => {
  const result = getParticipants()
  showMessage(result.message, !result.success)

  if (result.success) {
    if (!unlockedConcepts.value.includes('mapping_storage')) {
      unlockConcept('mapping_storage')
    }
    currentHint.value = result.nextStep
  }
}

onMounted(() => {
  if (unlockedConcepts.value.length === 0) {
    currentHint.value = '👆 欢迎来到 Day 19！点击签名流程图了解 ECDSA 签名，或点击角色切换了解组织者/参与者身份！'
  }
})
</script>

<style scoped>
.section {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.1) 0%, rgba(139, 92, 246, 0.1) 100%);
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
  transition: all 0.3s ease;
}

.section:hover {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.15) 0%, rgba(139, 92, 246, 0.15) 100%);
  border-color: rgba(59, 130, 246, 0.3);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
}

.section:last-child {
  margin-bottom: 0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.section-header h4 {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
  color: var(--text-main);
}

.role-toggle-buttons {
  display: flex;
  gap: 12px;
}

.role-btn {
  flex: 1;
  padding: 12px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  background: linear-gradient(135deg, rgba(248, 250, 252, 0.8) 0%, rgba(241, 245, 249, 0.8) 100%);
  color: var(--text-secondary);
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s;
}

.role-btn.active {
  background: linear-gradient(135deg, rgba(240, 253, 244, 0.9) 0%, rgba(220, 252, 231, 0.9) 100%);
  border-color: #22c55e;
  color: #16a34a;
}

.role-btn:hover:not(.active) {
  background: linear-gradient(135deg, rgba(241, 245, 249, 0.95) 0%, rgba(226, 232, 240, 0.95) 100%);
}

.info-display {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 12px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.info-row .label {
  color: var(--text-muted);
  font-size: 13px;
}

.info-row .value {
  font-size: 13px;
  color: var(--text-main);
}

.info-row .value.address {
  font-family: monospace;
  color: #7c3aed;
}

.info-row .value.entered {
  color: #22c55e;
}

.info-row .value.not-entered {
  color: #ef4444;
}

.user-selector {
  padding-top: 12px;
  border-top: 1px solid #e2e8f0;
}

.selector-label {
  font-size: 12px;
  color: var(--text-muted);
  display: block;
  margin-bottom: 8px;
}

.user-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.user-btn {
  padding: 6px 12px;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  background: #f8fafc;
  color: var(--text-muted);
  font-size: 11px;
  cursor: pointer;
  font-family: monospace;
}

.user-btn.active {
  background: #eff6ff;
  border-color: #3b82f6;
  color: #2563eb;
}

.user-btn:hover:not(.active) {
  background: #f1f5f9;
}

.signature-flow-section {
  cursor: pointer;
  transition: all 0.3s;
}

.signature-flow-section:hover {
  border-color: rgba(34, 197, 94, 0.5);
}

.hover-hint {
  font-size: 11px;
  color: var(--text-muted);
}

.signature-flow {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.flow-step {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: #f8fafc;
  border-radius: 6px;
  width: 100%;
  justify-content: space-between;
}

.flow-step .icon {
  font-size: 16px;
}

.flow-step .label {
  flex: 1;
  font-size: 12px;
  color: var(--text-muted);
}

.flow-step .value {
  font-size: 11px;
  font-family: monospace;
  color: #22c55e;
}

.flow-step .value.placeholder {
  color: #cbd5e1;
}

.flow-step.success {
  background: #f0fdf4;
  border: 1px solid rgba(34, 197, 94, 0.3);
}

.arrow {
  font-size: 11px;
  color: var(--text-muted);
}

.signature-generator {
  margin-bottom: 12px;
}

.signature-display {
  margin-top: 12px;
  padding: 12px;
  background: linear-gradient(135deg, rgba(250, 245, 255, 0.9) 0%, rgba(245, 243, 255, 0.9) 100%);
  border-radius: 8px;
  border: 1px solid rgba(168, 85, 247, 0.2);
  transition: all 0.3s ease;
}

.signature-display:hover {
  background: linear-gradient(135deg, rgba(250, 245, 255, 1) 0%, rgba(245, 243, 255, 1) 100%);
  border-color: rgba(168, 85, 247, 0.3);
  box-shadow: 0 4px 12px rgba(168, 85, 247, 0.1);
}

.signature-full {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.sig-label {
  font-size: 12px;
  color: var(--text-muted);
}

.sig-value {
  font-size: 11px;
  font-family: monospace;
  color: #7c3aed;
}

.toggle-details-btn {
  width: 100%;
  padding: 6px;
  border: 1px solid rgba(168, 85, 247, 0.3);
  border-radius: 4px;
  background: transparent;
  color: #7c3aed;
  font-size: 11px;
  cursor: pointer;
  margin-bottom: 8px;
}

.toggle-details-btn:hover {
  background: #faf5ff;
}

.signature-details {
  padding-top: 8px;
  border-top: 1px solid rgba(168, 85, 247, 0.2);
}

.detail-row {
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  margin-bottom: 4px;
}

.detail-label {
  color: var(--text-muted);
}

.detail-value {
  font-family: monospace;
  color: #7c3aed;
}

.participate-action {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.hint {
  font-size: 11px;
  color: var(--text-muted);
  text-align: center;
}

.participants-display {
  margin-bottom: 12px;
}

.participant-count {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.participant-count span:first-child {
  color: var(--text-muted);
}

.participant-count .count {
  font-size: 20px;
  font-weight: bold;
  color: #f97316;
}

.participant-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.participant-item {
  padding: 6px 10px;
  background: linear-gradient(135deg, rgba(255, 247, 237, 0.9) 0%, rgba(254, 243, 224, 0.9) 100%);
  border-radius: 4px;
  font-size: 12px;
  font-family: monospace;
  color: #9a3412;
  transition: all 0.3s ease;
}

.participant-item:hover {
  background: linear-gradient(135deg, rgba(255, 247, 237, 1) 0%, rgba(254, 243, 224, 1) 100%);
  box-shadow: 0 2px 8px rgba(249, 115, 22, 0.15);
}

.empty-list {
  color: var(--text-muted);
  font-size: 13px;
  text-align: center;
  padding: 12px;
}

.gasless-info p {
  font-size: 13px;
  color: var(--text-main);
  margin-bottom: 8px;
}

.gasless-info ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.gasless-info li {
  font-size: 12px;
  color: var(--text-muted);
  margin-bottom: 4px;
  padding-left: 12px;
  position: relative;
}

.gasless-info li::before {
  content: "•";
  position: absolute;
  left: 0;
  color: #3b82f6;
}
</style>
