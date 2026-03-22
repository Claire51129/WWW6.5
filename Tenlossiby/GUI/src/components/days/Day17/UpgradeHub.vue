<template>
  <div class="day-17-content day-content">
    <!-- 消息提示 -->
    <div v-if="message" :class="['message-toast', { error: isError }]">
      {{ message }}
    </div>

    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <!-- 左侧：交互区域 -->
      <div class="left-column">
        <div class="interaction-area">
        <!-- 1. 合约架构可视化 -->
        <div class="section architecture-section">
          <div class="section-header">
            <h4>🏗️ 可升级合约架构</h4>
            <span class="hover-hint">👆 点击了解代理模式</span>
          </div>

          <div class="architecture-diagram" @click="handleArchitectureClick">
            <div class="architecture-flow">
              <!-- 用户调用 -->
              <div class="user-box">
                <span>👤 User</span>
                <small>调用 subscribe()</small>
              </div>

              <div class="arrow down">↓</div>

              <!-- 代理合约 -->
              <div class="proxy-box"
                :class="{ highlighted: unlockedConcepts.includes('proxy_pattern') }">
                <span>📦 Proxy</span>
                <small>SubscriptionStorage</small>
                <div class="storage-tag">💾 存储数据</div>
              </div>

              <div class="arrow down">
                <span class="delegatecall-label">delegatecall</span>
              </div>

              <!-- 逻辑合约 -->
              <div class="logic-boxes">
                <div class="logic-v1" :class="{
                  active: currentVersion === 'V1',
                  highlighted: unlockedConcepts.includes('logic_contract')
                }">
                  <span>⚙️ Logic V1</span>
                  <small>基础订阅功能</small>
                  <ul class="feature-list">
                    <li>✅ createPlan</li>
                    <li>✅ subscribe</li>
                    <li>✅ isSubscribed</li>
                  </ul>
                </div>

                <div class="upgrade-arrow" v-if="upgraded">→</div>

                <div class="logic-v2" :class="{
                  active: currentVersion === 'V2',
                  highlighted: unlockedConcepts.includes('logic_contract')
                }">
                  <span>⚡ Logic V2</span>
                  <small>+ 暂停/恢复功能</small>
                  <ul class="feature-list">
                    <li>✅ 所有 V1 功能</li>
                    <li class="new">✨ pauseSubscription</li>
                    <li class="new">✨ resumeSubscription</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>

          <!-- 说明按钮 -->
          <div class="explanation-buttons">
            <button class="day-action-btn cyan small" @click.stop="showDelegatecallExplanation"
              :disabled="!unlockedConcepts.includes('proxy_pattern')">
              🔄 delegatecall 说明
            </button>
            <button class="day-action-btn magenta small" @click.stop="showStorageLayoutExplanation"
              :disabled="!unlockedConcepts.includes('delegatecall')">
              🔀 存储布局说明
            </button>
          </div>
        </div>

        <!-- 角色切换区 -->
        <div class="section role-switch-section">
          <div class="section-header">
            <h4>🎭 角色切换</h4>
            <span class="current-role">当前: {{ currentRole === 'owner' ? '👑 Owner' : '👤 User' }}</span>
          </div>
          <div class="role-switcher-inline">
            <button class="day-action-btn" :class="currentRole === 'owner' ? 'orange' : 'gray'"
              @click="handleSwitchRole('owner')">
              👑 Owner
            </button>
            <button class="day-action-btn" :class="currentRole === 'user' ? 'cyan' : 'gray'"
              @click="handleSwitchRole('user')">
              👤 User
            </button>
          </div>
        </div>

        <!-- 2. 计划管理区 -->
        <div class="section plan-section">
          <div class="section-header">
            <h4>📋 计划管理</h4>
            <div class="role-badge owner">👑 Owner</div>
          </div>

          <!-- 创建计划表单 -->
          <div class="create-plan-form" v-if="currentRole === 'owner'">
            <div class="input-row">
              <label>计划 ID:</label>
              <input v-model.number="newPlanId" type="number" placeholder="1" min="1" />
            </div>
            <div class="input-row">
              <label>价格 (ETH):</label>
              <input v-model="newPlanPrice" type="number" step="0.01" placeholder="0.1" min="0.01" />
            </div>
            <div class="input-row">
              <label>持续时间 (天):</label>
              <input v-model.number="newPlanDuration" type="number" placeholder="30" min="1" />
            </div>
            <button class="day-action-btn green" @click="handleCreatePlan"
              :disabled="!unlockedConcepts.includes('storage_layout')">
              ➕ 创建计划
            </button>
          </div>

          <!-- 计划列表 -->
          <div class="plan-list">
            <h5>已创建的计划</h5>
            <div v-for="plan in plans" :key="plan.id" class="plan-item">
              <span class="plan-id">计划 {{ plan.id }}</span>
              <span class="plan-price">{{ plan.price }} ETH</span>
              <span class="plan-duration">{{ plan.durationDays }} 天</span>
            </div>
            <div v-if="plans.length === 0" class="empty-state">
              暂无计划，请创建
            </div>
          </div>
        </div>

        <!-- 3. 升级演示区 -->
        <div class="section upgrade-section">
          <div class="section-header">
            <h4>🚀 合约升级演示</h4>
            <div class="version-indicator" :class="currentVersion.toLowerCase()">
              当前: {{ currentVersion }}
            </div>
          </div>

          <!-- 版本切换控制 -->
          <div class="version-switch">
            <button class="day-action-btn" :class="currentVersion === 'V1' ? 'blue' : 'gray'" @click="handleSwitchToV1"
              :disabled="!upgraded && currentVersion !== 'V1'">
              ⚙️ V1
              <span v-if="!upgraded && currentVersion === 'V1'" class="current-badge">当前</span>
            </button>

            <button class="day-action-btn upgrade-btn" :class="upgraded ? 'green' : 'orange'" @click="handleUpgradeToV2"
              :disabled="upgraded || isUpgrading">
              <span v-if="isUpgrading">⏳ 升级中...</span>
              <span v-else-if="plans.length < 2">🔒 需要至少2个计划</span>
              <span v-else-if="!upgraded">↑ 升级到 V2</span>
              <span v-else>✅ 已升级</span>
            </button>

            <button class="day-action-btn" :class="currentVersion === 'V2' ? 'purple' : 'gray'" @click="handleSwitchToV2"
              :disabled="!upgraded">
              ⚡ V2
              <span v-if="upgraded && currentVersion === 'V2'" class="current-badge">当前</span>
            </button>
          </div>

          <!-- 功能对比 -->
          <div class="feature-comparison">
            <div class="v1-features" :class="{ active: currentVersion === 'V1' }">
              <h5>V1 功能</h5>
              <ul>
                <li>✅ createPlan - 创建计划</li>
                <li>✅ subscribe - 订阅</li>
                <li>✅ isSubscribed - 查询状态</li>
              </ul>
            </div>

            <div class="comparison-arrow">→</div>

            <div class="v2-features" :class="{ active: currentVersion === 'V2' }">
              <h5>V2 新增功能</h5>
              <ul>
                <li class="existing">✅ 所有 V1 功能</li>
                <li class="new" :class="{ highlight: currentVersion === 'V2' }">
                  ✨ pauseSubscription - 暂停订阅
                </li>
                <li class="new" :class="{ highlight: currentVersion === 'V2' }">
                  ✨ resumeSubscription - 恢复订阅
                </li>
              </ul>
            </div>
          </div>

          <!-- 升级提示 -->
          <div class="upgrade-hint" v-if="!upgraded">
            <span v-if="plans.length < 2" class="warning">
              💡 需要创建至少 2 个计划才能升级（当前: {{ plans.length }}个）
            </span>
            <span v-else class="ready">
              ✅ 可以升级到 V2 了！
            </span>
          </div>
        </div>

        <!-- 4. 订阅与V2功能区 -->
        <div class="section subscription-section">
          <div class="section-header">
            <h4>💳 订阅管理</h4>
            <div class="role-badge user">👤 User</div>
          </div>

          <!-- 订阅表单 -->
          <div class="subscribe-form" v-if="currentRole === 'user'">
            <div class="version-info">
              <span class="version-badge" :class="currentVersion.toLowerCase()">
                当前逻辑版本: {{ currentVersion }}
              </span>
              <span v-if="currentVersion === 'V2'" class="v2-features-hint">
                ✨ 支持 V2 新功能: 暂停/恢复
              </span>
            </div>

            <div class="input-row">
              <label>选择计划:</label>
              <select v-model.number="selectedPlanId">
                <option v-for="plan in plans" :key="plan.id" :value="plan.id">
                  计划 {{ plan.id }} - {{ plan.price }} ETH
                </option>
              </select>
            </div>
            <button class="day-action-btn cyan" @click="handleSubscribe" :disabled="plans.length === 0">
              💎 订阅 ({{ selectedPlanPrice }} ETH)
              <span v-if="!upgraded" class="version-badge">V1</span>
              <span v-else class="version-badge v2">V2</span>
            </button>
          </div>

          <!-- V2 功能 -->
          <div class="v2-features" v-if="currentVersion === 'V2' && hasSubscription">
            <h5>V2 功能</h5>
            <div class="v2-actions">
              <button class="day-action-btn yellow" @click="handlePauseSubscription"
                :disabled="subscription.paused">
                ⏸️ 暂停订阅
              </button>
              <button class="day-action-btn green" @click="handleResumeSubscription"
                :disabled="!subscription.paused">
                ▶️ 恢复订阅
              </button>
            </div>
            <div class="pause-status" v-if="subscription.paused">
              <span class="paused-badge">⏸️ 已暂停</span>
              <span>剩余时间: {{ remainingTime }} 秒</span>
              <small class="pause-hint">💡 暂停时保存了剩余时间，恢复时会重新计算过期时间</small>
            </div>
          </div>

          <!-- 订阅状态 -->
          <div class="subscription-status">
            <h5>我的订阅</h5>
            <div v-if="hasSubscription" class="status-card">
              <div class="status-item">
                <span>计划:</span>
                <span>计划 {{ subscription.planId }}</span>
              </div>
              <div class="status-item">
                <span>状态:</span>
                <span :class="subscriptionStatusClass">{{ subscriptionStatusText }}</span>
              </div>
              <div class="status-item">
                <span>过期时间:</span>
                <span>{{ formatExpiry(subscription.expiry) }}</span>
              </div>
            </div>
            <div v-else class="empty-state">
              暂无订阅
            </div>
            <button class="day-action-btn blue small" @click="handleCheckSubscription"
              :disabled="!hasSubscription">
              🔍 查询状态
            </button>
          </div>
        </div>

        <!-- 5. 存储状态可视化 -->
        <div class="section storage-section">
          <div class="section-header">
            <h4>💾 存储状态 (数据持久化演示)</h4>
          </div>

          <!-- 存储槽位展示 -->
          <div class="storage-slots">
            <div class="slot" :class="{ 'just-upgraded': justUpgraded }">
              <span class="slot-name">logicContract:</span>
              <span class="slot-value address">{{ formatAddress(logicContractAddress) }}</span>
              <span class="slot-version">({{ currentVersion }})</span>
            </div>

            <div class="slot">
              <span class="slot-name">owner:</span>
              <span class="slot-value address">{{ formatAddress(ownerAddress) }}</span>
            </div>

            <div class="slot">
              <span class="slot-name">subscriptions:</span>
              <span class="slot-value">{{ subscriptionsCount }} 个订阅</span>
            </div>

            <div class="slot">
              <span class="slot-name">planPrices:</span>
              <span class="slot-value">{{ plansCount }} 个计划</span>
            </div>

            <div class="slot">
              <span class="slot-name">planDuration:</span>
              <span class="slot-value">{{ plansCount }} 个持续时间</span>
            </div>
          </div>

          <!-- 升级动画效果 -->
          <div class="upgrade-animation" v-if="isUpgrading">
            <div class="spinner"></div>
            <span>正在部署 V2 逻辑合约...</span>
          </div>

          <!-- 数据持久化证明 -->
          <div class="persistence-proof" v-if="upgraded && hasSubscription">
            <div class="proof-header">
              <span>✅ 数据持久化验证</span>
            </div>
            <div class="proof-content">
              <p>升级前创建的订阅仍然存在：</p>
              <ul>
                <li>计划 ID: {{ subscription.planId }}</li>
                <li>过期时间: {{ formatExpiry(subscription.expiry) }}</li>
                <li>数据完整性: ✓ 验证通过</li>
              </ul>
            </div>
          </div>

          <!-- 存储布局提示 -->
          <div class="layout-hint" v-if="unlockedConcepts.includes('storage_layout')">
            <p>📋 存储布局一致性确保升级后数据位置不变</p>
          </div>
        </div>
      </div>
      </div>

      <!-- 右侧：知识点面板 -->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="17"
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
      title="Day 17 - 可升级合约架构"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useDay17 } from '@/composables/useDay17'
import { useProgressStore } from '@/stores/progressStore'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

const progressStore = useProgressStore()

// 计算属性：已解锁概念
const unlockedConcepts = computed(() =>
  progressStore.getDayProgress(17)?.unlockedConcepts || []
)

// 计算属性：进度百分比
const progressPercentage = computed(() => {
  const progress = progressStore.getDayProgress(17)
  if (!progress || progress.totalConcepts === 0) return 0
  return Math.round((progress.unlockedConcepts.length / progress.totalConcepts) * 100)
})

// 计算属性：完整代码
const fullCode = computed(() => getFullCode(17))

const {
  currentRole,
  currentVersion,
  upgraded,
  isUpgrading,
  justUpgraded,
  plans,
  newPlanId,
  newPlanPrice,
  newPlanDuration,
  selectedPlanId,
  subscription,
  logicContractAddress,
  ownerAddress,
  plansCount,
  subscriptionsCount,
  hasSubscription,
  selectedPlanPrice,
  remainingTime,
  subscriptionStatusText,
  subscriptionStatusClass,
  createPlan,
  upgradeToV2,
  switchToV1,
  switchToV2,
  subscribe,
  pauseSubscription,
  resumeSubscription,
  checkSubscription,
  switchRole,
  realtimeData
} = useDay17()

// 消息提示
const message = ref('')
const isError = ref(false)
const currentHint = ref('')
const showFullCode = ref(false)

// 显示消息
const showMessage = (msg, error = false) => {
  message.value = msg
  isError.value = error
  setTimeout(() => {
    message.value = ''
  }, 5000)
}

// 格式化地址
const formatAddress = (address) => {
  if (!address) return ''
  return address.slice(0, 6) + '...' + address.slice(-4)
}

// 格式化过期时间
const formatExpiry = (expiry) => {
  if (!expiry) return '-'
  if (subscription.value && subscription.value.paused) {
    return `暂停中 (剩余 ${expiry} 秒)`
  }
  const date = new Date(expiry * 1000)
  return date.toLocaleString()
}

// ========== 事件处理 ==========

// 点击架构图
const handleArchitectureClick = () => {
  if (!unlockedConcepts.value.includes('proxy_pattern')) {
    progressStore.unlockConcept(17, 'proxy_pattern')
    currentHint.value = '🔄 代理模式将数据存储与逻辑执行分离！👉 点击 delegatecall 说明来学习如何实现委托调用！'
    showMessage('✅ 已查看合约架构图！🎉 恭喜解锁：代理模式！代理合约持有数据，逻辑合约处理业务逻辑。👉 点击 delegatecall 说明按钮！')
  }
}

// 显示 delegatecall 说明
const showDelegatecallExplanation = () => {
  if (!unlockedConcepts.value.includes('delegatecall')) {
    progressStore.unlockConcept(17, 'delegatecall')
    currentHint.value = '📦 delegatecall 在代理合约存储上下文中执行逻辑代码！👉 点击存储布局说明了解变量顺序的重要性！'
    showMessage('✅ 已学习 delegatecall 机制！🎉 恭喜解锁：委托调用！这是实现可升级合约的核心技术。👉 点击存储布局说明按钮！')
  }
}

// 显示存储布局说明
const showStorageLayoutExplanation = () => {
  if (!unlockedConcepts.value.includes('storage_layout')) {
    progressStore.unlockConcept(17, 'storage_layout')
    currentHint.value = '🔀 存储布局必须保持一致，否则升级后数据错乱！👉 切换到 Owner 身份，创建第一个订阅计划！'
    showMessage('✅ 已了解存储布局！🎉 恭喜解锁：存储布局！变量顺序决定了数据在存储中的位置，升级时必须保持一致。👉 切换到 Owner 身份创建计划！')
  }
}

// 创建计划
const handleCreatePlan = () => {
  const result = createPlan()
  showMessage(result.message, !result.success)
  if (result.nextStep) {
    currentHint.value = result.nextStep
  }
}

// 升级到 V2
const handleUpgradeToV2 = () => {
  const result = upgradeToV2()
  showMessage(result.message, !result.success)
  if (result.hints && result.hints.length > 0) {
    currentHint.value = result.nextStep
  }
}

// 切换到 V1
const handleSwitchToV1 = () => {
  const result = switchToV1()
  if (result.success) {
    showMessage(result.message)
  }
}

// 切换到 V2
const handleSwitchToV2 = () => {
  const result = switchToV2()
  if (result.success) {
    showMessage(result.message)
  }
}

// 订阅
const handleSubscribe = () => {
  const result = subscribe()
  showMessage(result.message, !result.success)
  if (result.hints && result.hints.length > 0) {
    currentHint.value = result.nextStep
  } else if (result.nextStep) {
    currentHint.value = result.nextStep
  }
}

// 暂停订阅
const handlePauseSubscription = () => {
  const result = pauseSubscription()
  showMessage(result.message, !result.success)
  if (result.hints && result.hints.length > 0) {
    currentHint.value = result.nextStep
  }
}

// 恢复订阅
const handleResumeSubscription = () => {
  const result = resumeSubscription()
  showMessage(result.message, !result.success)
  if (result.nextStep) {
    currentHint.value = result.nextStep
  }
}

// 查询订阅状态
const handleCheckSubscription = () => {
  const result = checkSubscription()
  showMessage(result.message, !result.success)
  if (result.hints && result.hints.length > 0) {
    currentHint.value = result.nextStep
  }
}

// 切换角色
const handleSwitchRole = (role) => {
  const result = switchRole(role)
  showMessage(result.message)
  if (result.nextStep) {
    currentHint.value = result.nextStep
  }
}

// 页面加载时自动解锁（如果需要）
onMounted(() => {
  // 可以在这里添加自动解锁逻辑
})
</script>

<style scoped>
/* ========== Day17 特有样式 ========== */
/* 布局相关已使用全局样式，这里只保留 Day17 特有的样式 */

.section {
  background: var(--bg-surface);
  border: 1px solid var(--border-main);
  border-radius: 8px;
  padding: 14px;
  margin-bottom: 12px;
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
  color: var(--text-main);
  font-size: 1rem;
  border-bottom: 1px solid var(--border-main);
  padding-bottom: 8px;
  flex: 1;
}

.hover-hint {
  font-size: 0.75rem;
  color: var(--text-muted);
  font-style: italic;
}

/* 角色徽章 */
.role-badge {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 600;
}

.role-badge.owner {
  background: rgba(249, 115, 22, 0.2);
  color: #f97316;
}

.role-badge.user {
  background: rgba(6, 182, 212, 0.2);
  color: #06b6d4;
}

/* 架构图 */
.architecture-diagram {
  cursor: pointer;
  padding: 16px;
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.1) 0%, rgba(139, 92, 246, 0.1) 100%);
  border: 1px solid var(--border-main);
  border-radius: 10px;
  transition: all 0.3s ease;
  position: relative;
}

.architecture-diagram:hover {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.15) 0%, rgba(139, 92, 246, 0.15) 100%);
  border-color: var(--accent-blue);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.2);
}

.architecture-diagram:active {
  transform: translateY(0);
}

.architecture-flow {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.user-box,
.proxy-box,
.logic-v1,
.logic-v2 {
  padding: 12px 16px;
  border-radius: 8px;
  text-align: center;
  min-width: 120px;
}

.user-box {
  background: rgba(139, 92, 246, 0.15);
  border: 2px solid #8b5cf6;
  color: var(--text-main);
}

.user-box small {
  display: block;
  font-size: 0.7rem;
  margin-top: 4px;
  color: var(--text-secondary);
}

.proxy-box {
  background: rgba(59, 130, 246, 0.15);
  border: 2px solid #3b82f6;
  color: var(--text-main);
  position: relative;
}

.proxy-box.highlighted {
  border-color: #fbbf24;
  box-shadow: 0 0 15px rgba(251, 191, 36, 0.3);
}

.storage-tag {
  position: absolute;
  bottom: -8px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(16, 185, 129, 0.9);
  color: white;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 10px;
  white-space: nowrap;
}

.proxy-box small {
  display: block;
  font-size: 0.7rem;
  margin-top: 4px;
  color: var(--text-secondary);
}

.arrow {
  font-size: 1.2rem;
  color: var(--text-secondary);
  position: relative;
}

.arrow.down::before {
  content: '↓';
}

.delegatecall-label {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(236, 72, 153, 0.9);
  color: white;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 0.7rem;
  white-space: nowrap;
}

.logic-boxes {
  display: flex;
  gap: 12px;
  align-items: center;
  justify-content: center;
  flex-wrap: wrap;
}

.logic-v1,
.logic-v2 {
  flex: 1;
  min-width: 140px;
  border: 2px solid transparent;
  transition: all 0.3s ease;
}

.logic-v1 {
  background: rgba(107, 114, 128, 0.15);
  border-color: rgba(107, 114, 128, 0.4);
  color: var(--text-main);
}

.logic-v1.active {
  background: rgba(59, 130, 246, 0.2);
  border-color: #3b82f6;
}

.logic-v2 {
  background: rgba(107, 114, 128, 0.15);
  border-color: rgba(107, 114, 128, 0.4);
  color: var(--text-main);
}

.logic-v2.active {
  background: rgba(168, 85, 247, 0.2);
  border-color: #a855f7;
}

.logic-v1.highlighted,
.logic-v2.highlighted {
  border-color: #fbbf24;
  box-shadow: 0 0 15px rgba(251, 191, 36, 0.3);
}

.logic-v1 small,
.logic-v2 small {
  display: block;
  font-size: 0.7rem;
  margin-top: 4px;
  color: var(--text-secondary);
}

.feature-list {
  list-style: none;
  padding: 0;
  margin: 8px 0 0;
  font-size: 0.75rem;
  text-align: left;
}

.feature-list li {
  padding: 2px 0;
  color: var(--text-secondary);
}

.feature-list li.new {
  color: #d946ef;
  font-weight: 500;
}

.upgrade-arrow {
  font-size: 1.5rem;
  color: #10b981;
  font-weight: bold;
}

.explanation-buttons {
  display: flex;
  gap: 12px;
  margin-top: 16px;
  justify-content: center;
  flex-wrap: wrap;
}

/* 计划管理 */
.create-plan-form {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--border-main);
}

.input-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.input-row label {
  min-width: 100px;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.input-row input,
.input-row select {
  flex: 1;
  padding: 8px 12px;
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 6px;
  color: var(--text-main);
  font-size: 0.9rem;
}

.input-row input:focus,
.input-row select:focus {
  outline: none;
  border-color: var(--accent-blue);
}

.plan-list h5 {
  margin: 0 0 12px;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.plan-item {
  display: flex;
  justify-content: space-between;
  padding: 8px 12px;
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 6px;
  margin-bottom: 8px;
  font-size: 0.85rem;
}

.plan-id {
  color: #3b82f6;
  font-weight: 500;
}

.plan-price {
  color: #f59e0b;
}

.plan-duration {
  color: var(--text-muted);
}

.empty-state {
  text-align: center;
  color: var(--text-muted);
  padding: 20px;
  font-style: italic;
}

/* 升级演示 */
.version-indicator {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 600;
}

.version-indicator.v1 {
  background: rgba(59, 130, 246, 0.2);
  color: #3b82f6;
}

.version-indicator.v2 {
  background: rgba(168, 85, 247, 0.2);
  color: #a855f7;
}

.version-switch {
  display: flex;
  gap: 12px;
  justify-content: center;
  margin-bottom: 16px;
  flex-wrap: wrap;
}

.current-badge {
  margin-left: 4px;
  font-size: 0.65rem;
  background: rgba(0, 0, 0, 0.1);
  padding: 2px 6px;
  border-radius: 4px;
}

.upgrade-btn {
  min-width: 140px;
}

.feature-comparison {
  display: flex;
  gap: 16px;
  align-items: stretch;
}

.v1-features,
.v2-features {
  flex: 1;
  padding: 14px;
  background: var(--bg-base);
  border-radius: 8px;
  border: 1px solid var(--border-main);
  transition: all 0.3s ease;
}

.v1-features.active {
  border-color: #3b82f6;
  background: rgba(59, 130, 246, 0.1);
}

.v2-features.active {
  border-color: #a855f7;
  background: rgba(168, 85, 247, 0.1);
}

.v1-features h5,
.v2-features h5 {
  margin: 0 0 12px;
  font-size: 0.9rem;
  color: var(--text-main);
}

.v1-features ul,
.v2-features ul {
  list-style: none;
  padding: 0;
  margin: 0;
  font-size: 0.85rem;
}

.v1-features li,
.v2-features li {
  padding: 4px 0;
  color: var(--text-secondary);
}

.v2-features li.existing {
  color: var(--text-secondary);
}

.v2-features li.new {
  color: #d946ef;
  font-weight: 500;
}

.v2-features li.new.highlight {
  font-weight: 600;
}

.comparison-arrow {
  display: flex;
  align-items: center;
  font-size: 1.5rem;
  color: #10b981;
}

.upgrade-hint {
  text-align: center;
  margin-top: 12px;
  padding: 10px;
  border-radius: 6px;
  font-size: 0.85rem;
}

.upgrade-hint .warning {
  color: #f59e0b;
}

.upgrade-hint .ready {
  color: #10b981;
}

/* 订阅区域 */
.version-info {
  display: flex;
  gap: 12px;
  align-items: center;
  margin-bottom: 12px;
  padding: 8px 12px;
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 6px;
}

.version-badge {
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
}

.version-badge.v1 {
  background: rgba(59, 130, 246, 0.2);
  color: #3b82f6;
}

.version-badge.v2 {
  background: rgba(168, 85, 247, 0.2);
  color: #a855f7;
}

.v2-features-hint {
  color: #f59e0b;
  font-size: 0.75rem;
}

.v2-features {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--border-main);
}

.v2-features h5 {
  margin: 0 0 12px;
  color: #a855f7;
  font-size: 0.9rem;
}

.v2-actions {
  display: flex;
  gap: 12px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.pause-status {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 12px;
  background: rgba(251, 191, 36, 0.1);
  border: 1px solid rgba(251, 191, 36, 0.3);
  border-radius: 6px;
}

.paused-badge {
  color: #f59e0b;
  font-weight: 600;
}

.pause-hint {
  color: var(--text-muted);
  font-size: 0.75rem;
}

.subscription-status {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--border-main);
}

.subscription-status h5 {
  margin: 0 0 12px;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.status-card {
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 12px;
}

.status-item {
  display: flex;
  justify-content: space-between;
  padding: 6px 0;
  font-size: 0.85rem;
}

.status-item span:first-child {
  color: var(--text-secondary);
}

.status-active {
  color: #10b981;
  font-weight: 600;
}

.status-paused {
  color: #f59e0b;
  font-weight: 600;
}

.status-expired {
  color: #ef4444;
  font-weight: 600;
}

.status-inactive {
  color: var(--text-muted);
}

/* 存储状态 */
.storage-slots {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.slot {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 6px;
  font-size: 0.85rem;
  transition: all 0.3s ease;
}

.slot.just-upgraded {
  animation: pulse 1s ease;
  border-color: #10b981;
}

@keyframes pulse {
  0% {
    box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7);
  }

  70% {
    box-shadow: 0 0 0 10px rgba(16, 185, 129, 0);
  }

  100% {
    box-shadow: 0 0 0 0 rgba(16, 185, 129, 0);
  }
}

.slot-name {
  min-width: 120px;
  color: var(--text-secondary);
  font-family: monospace;
}

.slot-value {
  flex: 1;
  color: var(--text-main);
}

.slot-value.address {
  font-family: monospace;
  color: #3b82f6;
}

.slot-version {
  padding: 2px 8px;
  background: rgba(168, 85, 247, 0.2);
  color: #a855f7;
  border-radius: 4px;
  font-size: 0.7rem;
}

.upgrade-animation {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 16px;
  margin-top: 12px;
  background: rgba(16, 185, 129, 0.1);
  border: 1px solid rgba(16, 185, 129, 0.3);
  border-radius: 8px;
  color: #10b981;
}

.spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(16, 185, 129, 0.3);
  border-top-color: #10b981;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.persistence-proof {
  margin-top: 12px;
  padding: 14px;
  background: rgba(16, 185, 129, 0.1);
  border: 1px solid rgba(16, 185, 129, 0.3);
  border-radius: 8px;
}

.proof-header {
  color: #10b981;
  font-weight: 600;
  margin-bottom: 12px;
}

.proof-content {
  font-size: 0.85rem;
}

.proof-content p {
  margin: 0 0 8px;
  color: var(--text-secondary);
}

.proof-content ul {
  margin: 0;
  padding-left: 20px;
  color: var(--text-main);
}

.proof-content li {
  padding: 2px 0;
}

.layout-hint {
  margin-top: 12px;
  padding: 12px;
  background: rgba(59, 130, 246, 0.1);
  border: 1px solid rgba(59, 130, 246, 0.3);
  border-radius: 6px;
  text-align: center;
}

.layout-hint p {
  margin: 0;
  color: #3b82f6;
  font-size: 0.85rem;
}

/* 角色切换 - Day17 特有 */
.role-switch-section {
  background: var(--bg-surface);
  border: 1px solid var(--border-main);
  border-radius: 8px;
  padding: 14px;
}

.role-switch-section .current-role {
  font-size: 0.85rem;
  color: var(--text-secondary);
  font-weight: 500;
}

.role-switcher-inline {
  display: flex;
  gap: 12px;
  justify-content: center;
}

.role-switcher-inline .day-action-btn {
  flex: 1;
  max-width: 150px;
}

/* Day17 响应式特有样式 */
@media (max-width: 768px) {
  .feature-comparison {
    flex-direction: column;
  }

  .comparison-arrow {
    transform: rotate(90deg);
  }

  .logic-boxes {
    flex-direction: column;
  }

  .version-switch {
    flex-wrap: wrap;
  }

  .v2-actions {
    flex-direction: column;
  }

  .role-switcher-inline {
    flex-direction: column;
    align-items: stretch;
  }

  .role-switcher-inline .day-action-btn {
    max-width: none;
  }
}
</style>
