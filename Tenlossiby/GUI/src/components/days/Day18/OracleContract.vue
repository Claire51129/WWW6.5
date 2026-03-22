<template>
  <div class="day-18-content day-content">
    <!-- 消息提示 -->
    <div v-if="message" :class="['message-toast', { error: isError }]">
      {{ message }}
    </div>

    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <!-- 左侧：交互区域 -->
      <div class="left-column">
        <div class="interaction-area">

          <!-- 区块1: 双预言机架构 -->
          <div class="section oracle-architecture-section">
            <div class="section-header">
              <h4>📡 双预言机架构</h4>
              <span class="hover-hint">👆 点击了解预言机</span>
            </div>

            <div class="architecture-diagram" @click="handleArchitectureClick">
              <div class="oracle-flow">
                <!-- 天气预言机 -->
                <div class="oracle-box weather"
                  :class="{ highlighted: unlockedConcepts.includes('oracle_interface') }">
                  <span>🌧️ Weather Oracle</span>
                  <small>降雨量数据</small>
                </div>

                <div class="arrow down">↓</div>

                <!-- 主合约 -->
                <div class="main-contract-box"
                  :class="{ highlighted: unlockedConcepts.includes('oracle_interface') }">
                  <span>🌾 CropInsurance</span>
                  <small>农作物保险合约</small>
                </div>

                <div class="arrow down">↓</div>

                <!-- 价格预言机 -->
                <div class="oracle-box price"
                  :class="{ highlighted: unlockedConcepts.includes('eth_usd_oracle') }">
                  <span>💰 ETH/USD PriceFeed</span>
                  <small>价格数据</small>
                </div>
              </div>
            </div>

            <div class="architecture-explanation" v-if="unlockedConcepts.includes('oracle_interface')">
              <p>🔌 <strong>Chainlink 接口</strong>：智能合约通过预言机获取链外数据</p>
              <code>AggregatorV3Interface</code> 是 Chainlink 标准接口
            </div>
          </div>

          <!-- 区块2: 天气模拟器 -->
          <div class="section weather-section">
            <div class="section-header">
              <h4>🌧️ 天气数据模拟器</h4>
              <span class="status-badge" :class="{ danger: isDrought, normal: !isDrought }">
                {{ isDrought ? '🔴 干旱' : '🟢 正常' }}
              </span>
            </div>

            <div class="weather-display">
              <div class="rainfall-gauge">
                <div class="gauge-label">
                  <span>降雨量</span>
                  <span class="rainfall-value">{{ rainfall }} mm</span>
                </div>
                <div class="gauge-bar">
                  <div class="gauge-fill" :style="{ width: Math.min(rainfall / 10, 100) + '%' }"
                    :class="{ danger: isDrought }"></div>
                  <div class="threshold-marker" :style="{ left: (RAINFALL_THRESHOLD / 10) + '%' }">
                    <span>阈值 {{ RAINFALL_THRESHOLD }}</span>
                  </div>
                </div>
                <div class="gauge-scale">
                  <span>0</span>
                  <span>500</span>
                  <span>999</span>
                </div>
              </div>

              <div class="weather-status">
                <span v-if="isDrought" class="drought-alert">
                  ⚠️ 干旱警报！降雨量低于阈值 {{ RAINFALL_THRESHOLD }}mm
                </span>
                <span v-else class="normal-status">
                  ✅ 天气正常，降雨量高于阈值
                </span>
              </div>
            </div>

            <div class="weather-actions">
              <button class="day-action-btn cyan" @click="handleUpdateRainfall">
                🔄 更新天气数据
              </button>
              <button class="day-action-btn blue small" @click="handleCheckRainfall">
                🔍 查询当前降雨量
              </button>
            </div>
          </div>

          <!-- 区块3: ETH/USD 价格面板 -->
          <div class="section price-section">
            <div class="section-header">
              <h4>💰 ETH/USD 价格面板</h4>
              <span class="price-badge">Chainlink 8位小数精度</span>
            </div>

            <div class="price-display">
              <div class="eth-price">
                <span class="label">当前 ETH 价格</span>
                <span class="value">${{ formatUsd(ethPrice) }}</span>
                <span class="raw">原始值: {{ ethPrice }}</span>
              </div>

              <div class="conversion-table">
                <div class="conversion-row">
                  <span class="label">保费 (USD)</span>
                  <span class="arrow">→</span>
                  <span class="label">保费 (ETH)</span>
                </div>
                <div class="conversion-row values">
                  <span class="value">${{ INSURANCE_PREMIUM_USD }}</span>
                  <span class="arrow">→</span>
                  <span class="value">{{ formatEth(premiumInEth) }} ETH</span>
                </div>

                <div class="conversion-row">
                  <span class="label">赔付 (USD)</span>
                  <span class="arrow">→</span>
                  <span class="label">赔付 (ETH)</span>
                </div>
                <div class="conversion-row values">
                  <span class="value">${{ INSURANCE_PAYOUT_USD }}</span>
                  <span class="arrow">→</span>
                  <span class="value">{{ formatEth(payoutInEth) }} ETH</span>
                </div>
              </div>

              <div class="formula-explanation" v-if="unlockedConcepts.includes('price_conversion')">
                <p>🧮 <strong>价格转换公式</strong>：</p>
                <code>ETH数量 = (USD金额 × 1e26) / ETH价格</code>
                <p class="note">1e26 = 1e18(wei精度) × 1e8(Chainlink精度)</p>
              </div>
            </div>

            <div class="price-actions">
              <button class="day-action-btn green small" @click="handleUpdateEthPrice">
                🔄 更新价格
              </button>
            </div>
          </div>

          <!-- 区块4: 保险操作 -->
          <div class="section insurance-section">
            <div class="section-header">
              <h4>🛡️ 保险操作</h4>
              <div class="user-selector">
                <button v-for="user in ['Alice', 'Bob', 'Carol']" :key="user"
                  class="user-btn" :class="{ active: currentUser === user }"
                  @click="handleSwitchUser(user)">
                  👨‍🌾 {{ user }}
                </button>
              </div>
            </div>

            <div class="insurance-status">
              <div class="status-card">
                <div class="status-row">
                  <span>当前用户:</span>
                  <span class="highlight">{{ currentUser }}</span>
                </div>
                <div class="status-row">
                  <span>保险状态:</span>
                  <span :class="hasInsurance[currentUser] ? 'insured' : 'uninsured'">
                    {{ hasInsurance[currentUser] ? '✅ 已投保' : '❌ 未投保' }}
                  </span>
                </div>
                <div class="status-row" v-if="hasInsurance[currentUser]">
                  <span>上次索赔:</span>
                  <span>{{ formatLastClaim(currentUser) }}</span>
                </div>
              </div>
            </div>

            <div class="insurance-actions">
              <button class="day-action-btn green" @click="handlePurchaseInsurance"
                :disabled="hasInsurance[currentUser]">
                💰 购买保险 ({{ formatEth(premiumInEth) }} ETH)
              </button>

              <button class="day-action-btn blue" @click="handleCheckRainfall"
                :disabled="!hasInsurance[currentUser]">
                🔍 查询天气数据
              </button>

              <button class="day-action-btn orange" @click="handleClaimPayout"
                :disabled="!canClaim || !isDrought">
                💸 申请赔付
                <span v-if="!hasInsurance[currentUser]" class="badge">需先投保</span>
                <span v-else-if="!isDrought" class="badge">非干旱</span>
                <span v-else-if="!canClaim" class="badge">冷却中</span>
              </button>
            </div>
          </div>

          <!-- 区块5: 冷却期演示 -->
          <div class="section cooldown-section" v-if="hasInsurance[currentUser]">
            <div class="section-header">
              <h4>⏱️ 索赔冷却期机制</h4>
              <span class="cooldown-badge" :class="cooldownStatus.status">
                {{ cooldownStatus.text }}
              </span>
            </div>

            <div class="cooldown-display">
              <div class="cooldown-timer" v-if="cooldownRemaining > 0">
                <span class="timer-label">剩余冷却时间:</span>
                <span class="timer-value">{{ formatTime(cooldownRemaining) }}</span>
              </div>
              <div class="cooldown-ready" v-else>
                <span class="ready-text">✅ 可以索赔</span>
              </div>

              <div class="cooldown-info">
                <p>💡 24小时内只能索赔一次，防止滥用</p>
              </div>
            </div>

            <div class="cooldown-actions">
              <button class="day-action-btn purple" @click="handleFastForwardTime"
                :disabled="cooldownRemaining === 0">
                ⏩ 快进24小时
              </button>
              <button class="day-action-btn cyan small" @click="handleLearnCooldown">
                📝 了解冷却期机制
              </button>
            </div>
          </div>

          <!-- 区块6: 管理员功能 -->
          <div class="section admin-section">
            <div class="section-header">
              <h4>👑 管理员功能</h4>
              <button class="role-toggle" @click="handleToggleRole">
                {{ currentRole === 'admin' ? '切换到农民' : '切换到管理员' }}
              </button>
            </div>

            <div class="admin-panel" v-if="currentRole === 'admin'">
              <div class="balance-display">
                <div class="balance-item">
                  <span>合约余额:</span>
                  <span class="value">{{ formatEth(contractBalance) }} ETH</span>
                </div>
                <div class="balance-item">
                  <span>已赔付总额:</span>
                  <span class="value">{{ formatEth(totalPayout) }} ETH</span>
                </div>
                <div class="balance-item">
                  <span>收取保费:</span>
                  <span class="value">{{ formatEth(totalPremium) }} ETH</span>
                </div>
              </div>

              <div class="admin-actions">
                <button class="day-action-btn red" @click="handleWithdrawBalance"
                  :disabled="contractBalance === 0">
                  💸 提取余额
                </button>
              </div>
            </div>

            <div class="admin-hint" v-else>
              <p>💡 切换到管理员角色可查看合约余额和提取资金</p>
            </div>
          </div>

        </div>
      </div>

      <!-- 右侧：知识点面板 -->
      <div class="right-column">
        <KnowledgePanel
          :current-day="18"
          :unlocked-concepts="unlockedConcepts"
          :progress-percentage="progressPercentage"
          :full-code="fullCode"
          :custom-hint="currentHint"
          @show-full-code="showFullCode = true"
        />
      </div>
    </div>

    <!-- 完整代码弹窗 -->
    <FullCodeModal
      :show="showFullCode"
      :code="fullCode"
      title="Day 18 - 预言机与参数保险"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useDay18 } from '@/composables/useDay18'
import { useProgressStore } from '@/stores/progressStore'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

const progressStore = useProgressStore()

// Day18 composable
const {
  currentUser,
  currentRole,
  ethPrice,
  rainfall,
  hasInsurance,
  lastClaimTimestamp,
  contractBalance,
  totalPayout,
  totalPremium,
  RAINFALL_THRESHOLD,
  INSURANCE_PREMIUM_USD,
  INSURANCE_PAYOUT_USD,
  premiumInEth,
  payoutInEth,
  isDrought,
  canClaim,
  cooldownRemaining,
  cooldownStatus,
  formatEth,
  formatUsd,
  formatTime,
  updateRainfall,
  checkRainfall,
  purchaseInsurance,
  claimPayout,
  fastForwardTime,
  withdrawBalance,
  switchUser,
  updateEthPrice
} = useDay18()

// 计算属性：已解锁概念
const unlockedConcepts = computed(() =>
  progressStore.getDayProgress(18)?.unlockedConcepts || []
)

// 计算属性：进度百分比
const progressPercentage = computed(() => {
  const progress = progressStore.getDayProgress(18)
  if (!progress || progress.totalConcepts === 0) return 0
  return Math.round((progress.unlockedConcepts.length / progress.totalConcepts) * 100)
})

// 状态
const message = ref('')
const isError = ref(false)
const showFullCode = ref(false)
const currentHint = ref('')

// 完整代码
const fullCode = getFullCode(18)

// 显示消息
const showMessage = (msg, error = false) => {
  message.value = msg
  isError.value = error
  setTimeout(() => {
    message.value = ''
  }, 5000)
}

// 解锁概念
const unlockConcept = (conceptKey) => {
  if (!unlockedConcepts.value.includes(conceptKey)) {
    progressStore.unlockConcept(18, conceptKey)
  }
}

// 处理函数
const handleArchitectureClick = () => {
  unlockConcept('oracle_interface')
  currentHint.value = '🔌 太棒了！你了解了 Chainlink 预言机接口！👉 查看 ETH/USD 价格面板学习价格预言机！'
  showMessage('✅ 已查看合约架构图！🎉 恭喜解锁：Chainlink接口！预言机让智能合约能够获取链外数据。👉 查看ETH/USD价格面板学习价格预言机！')
}

const handleUpdateRainfall = () => {
  const result = updateRainfall()
  showMessage(result.message, !result.success)

  if (result.success) {
    unlockConcept('random_generation')
    currentHint.value = '🎲 太棒了！你看到了伪随机数生成！👉 购买保险来体验价格转换！'
    if (result.hints) {
      result.hints.forEach(hint => unlockConcept(hint))
    }
  }
}

const handleCheckRainfall = () => {
  const result = checkRainfall()
  showMessage(result.message, !result.success)
}

const handleUpdateEthPrice = () => {
  const result = updateEthPrice()
  showMessage(result.message, !result.success)

  if (result.success) {
    unlockConcept('eth_usd_oracle')
    currentHint.value = '💰 太棒了！你使用了 ETH/USD 价格预言机！注意 Chainlink 返回 8 位小数精度。👉 购买保险体验价格转换！'
  }
}

const handlePurchaseInsurance = () => {
  const result = purchaseInsurance()
  showMessage(result.message, !result.success)

  if (result.success) {
    unlockConcept('purchase_insurance')
    unlockConcept('price_conversion')
    currentHint.value = '🛡️ 保险购买成功！支付保费获得保障。👉 当干旱发生时申请赔付体验参数化保险！'
  }
}

const handleClaimPayout = () => {
  const result = claimPayout()
  showMessage(result.message, !result.success)

  if (result.success) {
    unlockConcept('parametric_payout')
    currentHint.value = '💸 赔付成功！参数化保险自动执行无需审核。👉 了解冷却期机制防止滥用！'
  } else if (result.hints) {
    result.hints.forEach(hint => unlockConcept(hint))
  }
}

const handleFastForwardTime = () => {
  const result = fastForwardTime()
  showMessage(result.message, !result.success)

  if (result.success && result.hints) {
    result.hints.forEach(hint => unlockConcept(hint))
    currentHint.value = '⏱️ 时间已快进24小时！冷却期已结束。👉 现在可以再次申请赔付了！'
  }
}

const handleLearnCooldown = () => {
  unlockConcept('cooldown_mechanism')
  currentHint.value = '⏱️ 你了解了冷却期机制！24小时内只能索赔一次。👉 快进时间或查看合约余额！'
  showMessage('✅ 已了解冷却期机制！🎉 恭喜解锁：冷却期机制！24小时内只能索赔一次，防止滥用。👉 快进时间或查看合约余额！')
}

const handleWithdrawBalance = () => {
  const result = withdrawBalance()
  showMessage(result.message, !result.success)

  if (result.success) {
    unlockConcept('contract_balance')
    currentHint.value = '🏦 你查看了合约余额！管理员可提取保险池资金。🎉 你已掌握 Day 18 所有核心概念！'
  }
}

const handleSwitchUser = (user) => {
  switchUser(user)
  showMessage(`👨‍🌾 已切换到用户: ${user}`)
}

const handleToggleRole = () => {
  if (currentRole.value === 'admin') {
    switchUser('Alice')
    showMessage('👨‍🌾 已切换到农民角色')
  } else {
    currentRole.value = 'admin'
    currentUser.value = 'Owner'
    showMessage('👑 已切换到管理员角色')
  }
}

// 格式化上次索赔时间
const formatLastClaim = (user) => {
  const timestamp = lastClaimTimestamp.value[user]
  if (!timestamp || timestamp === 0) return '从未'
  return new Date(timestamp).toLocaleString()
}

onMounted(() => {
  if (unlockedConcepts.value.length === 0) {
    currentHint.value = '👆 欢迎来到 Day 18！点击合约架构图了解预言机接口，或查看 ETH/USD 价格面板学习价格预言机！'
  }
})
</script>

<style scoped>
/* Day 18 特有样式 - 通用布局样式已在全局定义 */
.day-18-content {
  padding: 20px;
}

/* 消息提示 - 统一为底部弹出 */
.message-toast {
  position: fixed;
  bottom: 100px;
  left: 50%;
  transform: translateX(-50%);
  padding: 12px 24px;
  border-radius: 8px;
  background: #10b981;
  color: white;
  font-weight: 500;
  z-index: 1000;
  animation: slideUp 0.3s ease;
  max-width: 90%;
  width: auto;
  text-align: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.message-toast.error {
  background: #ef4444;
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

/* 区块样式 - 透明背景 */
.section {
  background: transparent;
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
}

.section:last-child {
  margin-bottom: 0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid rgba(148, 163, 184, 0.3);
}

.section-header h4 {
  margin: 0;
  color: var(--text-main);
  font-size: 1rem;
  font-weight: 600;
}

.hover-hint {
  font-size: 0.75rem;
  color: var(--text-muted);
  font-style: italic;
}

/* 双预言机架构 - 渐变背景 */
.architecture-diagram {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.1) 0%, rgba(139, 92, 246, 0.1) 100%);
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 10px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.architecture-diagram:hover {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.15) 0%, rgba(139, 92, 246, 0.15) 100%);
  border-color: rgba(59, 130, 246, 0.4);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
}

.oracle-flow {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.oracle-box {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.1) 0%, rgba(139, 92, 246, 0.1) 100%);
  border: 2px solid rgba(148, 163, 184, 0.3);
  border-radius: 8px;
  padding: 12px 24px;
  text-align: center;
  min-width: 180px;
  color: var(--text-main);
  transition: all 0.3s ease;
}

.oracle-box:hover {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.15) 0%, rgba(139, 92, 246, 0.15) 100%);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
}

.oracle-box.weather {
  border-color: #3b82f6;
}

.oracle-box.price {
  border-color: #10b981;
}

.oracle-box.highlighted {
  border-color: #8b5cf6;
  box-shadow: 0 0 15px rgba(139, 92, 246, 0.15);
}

.main-contract-box {
  background: linear-gradient(135deg, rgba(245, 158, 11, 0.1) 0%, rgba(251, 191, 36, 0.1) 100%);
  border: 2px solid #f59e0b;
  border-radius: 8px;
  padding: 16px 32px;
  text-align: center;
  color: var(--text-main);
  transition: all 0.3s ease;
}

.main-contract-box:hover {
  background: linear-gradient(135deg, rgba(245, 158, 11, 0.15) 0%, rgba(251, 191, 36, 0.15) 100%);
  box-shadow: 0 4px 12px rgba(245, 158, 11, 0.2);
}

.main-contract-box.highlighted {
  box-shadow: 0 0 15px rgba(251, 191, 36, 0.15);
}

.arrow {
  font-size: 1.5rem;
  color: var(--text-muted);
}

.architecture-explanation {
  margin-top: 12px;
  padding: 12px;
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.1) 0%, rgba(139, 92, 246, 0.1) 100%);
  border: 1px solid rgba(59, 130, 246, 0.2);
  border-radius: 6px;
  font-size: 0.9rem;
  color: var(--text-main);
  transition: all 0.3s ease;
}

.architecture-explanation:hover {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.15) 0%, rgba(139, 92, 246, 0.15) 100%);
  border-color: rgba(59, 130, 246, 0.3);
}

.architecture-explanation code {
  background: rgba(241, 245, 249, 0.5);
  padding: 2px 6px;
  border-radius: 4px;
  font-family: monospace;
  color: #2563eb;
}

/* 天气模拟器 */
.weather-display {
  margin-bottom: 16px;
}

.rainfall-gauge {
  margin-bottom: 12px;
}

.gauge-label {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.rainfall-value {
  font-weight: bold;
  color: #3b82f6;
}

.gauge-bar {
  position: relative;
  height: 24px;
  background: #e5e7eb;
  border-radius: 12px;
  overflow: hidden;
}

.gauge-fill {
  height: 100%;
  background: #10b981;
  border-radius: 12px;
  transition: width 0.5s ease;
}

.gauge-fill.danger {
  background: #ef4444;
}

.threshold-marker {
  position: absolute;
  top: 0;
  bottom: 0;
  width: 2px;
  background: #f59e0b;
}

.threshold-marker span {
  position: absolute;
  top: -20px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 0.75rem;
  color: #f59e0b;
  white-space: nowrap;
}

.gauge-scale {
  display: flex;
  justify-content: space-between;
  margin-top: 4px;
  font-size: 0.75rem;
  color: var(--text-muted);
}

.weather-status {
  text-align: center;
  padding: 12px;
  border-radius: 6px;
}

.drought-alert {
  color: #ef4444;
  font-weight: 500;
}

.normal-status {
  color: #10b981;
  font-weight: 500;
}

.status-badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: 500;
}

.status-badge.danger {
  background: rgba(239, 68, 68, 0.15);
  color: #ef4444;
}

.status-badge.normal {
  background: rgba(16, 185, 129, 0.15);
  color: #10b981;
}

.weather-actions {
  display: flex;
  gap: 12px;
}

/* 价格面板 */
.price-display {
  margin-bottom: 16px;
}

.eth-price {
  text-align: center;
  padding: 16px;
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.1) 0%, rgba(52, 211, 153, 0.1) 100%);
  border-radius: 8px;
  margin-bottom: 16px;
}

.eth-price .label {
  display: block;
  font-size: 0.9rem;
  color: var(--text-muted);
  margin-bottom: 4px;
}

.eth-price .value {
  display: block;
  font-size: 1.5rem;
  font-weight: bold;
  color: #10b981;
}

.eth-price .raw {
  display: block;
  font-size: 0.75rem;
  color: var(--text-muted);
  margin-top: 4px;
}

.price-badge {
  font-size: 0.75rem;
  color: var(--text-muted);
  background: var(--bg-surface-2);
  padding: 2px 8px;
  border-radius: 4px;
}

.conversion-table {
  background: var(--bg-surface-2);
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 16px;
}

.conversion-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
}

.conversion-row.values {
  border-bottom: 1px solid #e5e7eb;
  margin-bottom: 8px;
  padding-bottom: 12px;
}

.conversion-row:last-child {
  border-bottom: none;
  margin-bottom: 0;
}

.conversion-row .label {
  font-size: 0.85rem;
  color: var(--text-muted);
}

.conversion-row .value {
  font-weight: 500;
  color: var(--text-main);
}

.conversion-row .arrow {
  color: var(--text-muted);
  font-size: 1rem;
}

.formula-explanation {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.1) 0%, rgba(96, 165, 250, 0.1) 100%);
  padding: 12px;
  border-radius: 6px;
  font-size: 0.9rem;
}

.formula-explanation code {
  display: block;
  background: rgba(59, 130, 246, 0.15);
  padding: 8px;
  border-radius: 4px;
  margin: 8px 0;
  font-family: monospace;
}

.formula-explanation .note {
  font-size: 0.8rem;
  color: var(--text-muted);
}

/* 保险操作 */
.user-selector {
  display: flex;
  gap: 8px;
}

.user-btn {
  padding: 6px 12px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  background: var(--bg-surface-1);
  cursor: pointer;
  font-size: 0.85rem;
  transition: all 0.2s;
}

.user-btn:hover {
  background: var(--bg-surface-2);
}

.user-btn.active {
  background: #3b82f6;
  color: white;
  border-color: #3b82f6;
}

.insurance-status {
  margin-bottom: 16px;
}

.status-card {
  background: var(--bg-surface-2);
  border-radius: 8px;
  padding: 12px;
}

.status-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #e5e7eb;
}

.status-row:last-child {
  border-bottom: none;
}

.status-row .highlight {
  font-weight: 500;
  color: #3b82f6;
}

.status-row .insured {
  color: #10b981;
  font-weight: 500;
}

.status-row .uninsured {
  color: #ef4444;
  font-weight: 500;
}

.insurance-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.insurance-actions button {
  position: relative;
}

.insurance-actions .badge {
  position: absolute;
  top: -8px;
  right: -8px;
  background: #f59e0b;
  color: white;
  font-size: 0.65rem;
  padding: 2px 6px;
  border-radius: 10px;
}

/* 冷却期 */
.cooldown-display {
  margin-bottom: 16px;
}

.cooldown-timer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: linear-gradient(135deg, rgba(245, 158, 11, 0.15) 0%, rgba(251, 191, 36, 0.15) 100%);
  border-radius: 8px;
  margin-bottom: 12px;
}

.timer-value {
  font-size: 1.5rem;
  font-weight: bold;
  color: #f59e0b;
  font-family: monospace;
}

.cooldown-ready {
  text-align: center;
  padding: 16px;
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.1) 0%, rgba(52, 211, 153, 0.1) 100%);
  border-radius: 8px;
  margin-bottom: 12px;
}

.ready-text {
  font-size: 1.2rem;
  font-weight: 500;
  color: #10b981;
}

.cooldown-info {
  text-align: center;
  color: var(--text-muted);
  font-size: 0.9rem;
}

.cooldown-badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: 500;
}

.cooldown-badge.available {
  background: rgba(16, 185, 129, 0.15);
  color: #10b981;
}

.cooldown-badge.cooldown {
  background: rgba(245, 158, 11, 0.15);
  color: #f59e0b;
}

.cooldown-badge.no_insurance {
  background: var(--bg-surface-2);
  color: var(--text-muted);
}

.cooldown-actions {
  display: flex;
  gap: 12px;
}

/* 管理员功能 */
.role-toggle {
  padding: 6px 12px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  background: var(--bg-surface-1);
  cursor: pointer;
  font-size: 0.85rem;
  transition: all 0.2s;
}

.role-toggle:hover {
  background: var(--bg-surface-2);
}

.admin-panel {
  margin-bottom: 16px;
}

.balance-display {
  background: var(--bg-surface-2);
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 16px;
}

.balance-item {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #e5e7eb;
}

.balance-item:last-child {
  border-bottom: none;
}

.balance-item .value {
  font-weight: 500;
  color: #3b82f6;
}

.admin-hint {
  text-align: center;
  color: var(--text-muted);
  padding: 20px;
}

/* 响应式 - Day18特有 */
@media (max-width: 640px) {
  .weather-actions,
  .cooldown-actions,
  .insurance-actions {
    flex-direction: column;
  }

  .user-selector {
    flex-wrap: wrap;
  }
}
</style>
