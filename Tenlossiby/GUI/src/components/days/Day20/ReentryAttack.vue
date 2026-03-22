<template>
  <div class="day-20-content day-content">
    <!-- 消息提示 -->
    <div v-if="message" :class="['message-toast', { error: isError }]">
      {{ message }}
    </div>

    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <!-- 左栏：交互区域 -->
      <div class="left-column">
        <div class="interaction-area">
          <!-- 攻击原理可视化区 -->
          <div class="section attack-principle-section" @click="handlePrincipleClick">
            <div class="section-header">
              <h4>🔥 重入攻击原理</h4>
              <span class="hover-hint">👆 点击了解重入攻击</span>
            </div>
            <div class="attack-flow-visualization">
              <div class="flow-container">
                <div class="attacker-box">
                  <div class="box-icon">🥷</div>
                  <div class="box-label">GoldThief</div>
                  <div class="box-sublabel">攻击者合约</div>
                </div>
                <div class="flow-arrows">
                  <div class="arrow-line">
                    <span class="arrow-label">1. 调用withdraw</span>
                    <span class="arrow">→</span>
                  </div>
                  <div class="arrow-line return">
                    <span class="arrow-label">2. 发送ETH</span>
                    <span class="arrow">→</span>
                  </div>
                  <div class="arrow-line">
                    <span class="arrow-label">3. receive()回调</span>
                    <span class="arrow">→</span>
                  </div>
                  <div class="arrow-line highlight">
                    <span class="arrow-label">4. 再次withdraw!</span>
                    <span class="arrow">→</span>
                  </div>
                </div>
                <div class="vault-box" :class="{ vulnerable: true }">
                  <div class="box-icon">🏦</div>
                  <div class="box-label">GoldVault</div>
                  <div class="box-sublabel">有漏洞的金库</div>
                  <div class="vulnerability-badge">⚠️ 漏洞</div>
                </div>
              </div>
            </div>
            <div v-if="showPrincipleExplanation" class="principle-explanation">
              <p>💡 重入攻击原理</p>
              <p>攻击者利用合约在发送ETH后、更新余额前的窗口期，通过递归调用重复提款。每次调用都使用相同的余额，直到资金耗尽。</p>
            </div>
          </div>

          <!-- 角色切换系统 -->
          <div class="section role-section">
            <div class="section-header">
              <h4>🎭 角色切换</h4>
            </div>
            <div class="role-toggle-buttons">
              <button
                class="role-btn"
                :class="{ active: currentRole === 'attacker' }"
                @click="switchRole('attacker')"
              >
                🥷 攻击者视角
              </button>
              <button
                class="role-btn"
                :class="{ active: currentRole === 'admin' }"
                @click="switchRole('admin')"
              >
                🏦 金库管理员
              </button>
            </div>
          </div>

          <!-- 金库状态面板 -->
          <div class="section vault-status-section">
            <div class="section-header">
              <h4>💰 金库状态</h4>
              <span class="hover-hint">实时显示合约状态</span>
            </div>
            <div class="status-display">
              <div class="status-row main">
                <span class="label">金库总余额</span>
                <span class="value">{{ vaultBalance }} ETH</span>
              </div>
              <div class="status-row">
                <span class="label">重入锁状态</span>
                <span class="value" :class="reentrancyStatus === 2 ? 'locked' : 'unlocked'">
                  {{ reentrancyStatus === 2 ? '🔒 已锁定' : '🔓 未锁定' }}
                </span>
              </div>
              <div class="status-row">
                <span class="label">攻击次数</span>
                <span class="value attack-count">{{ attackCount }} / 5</span>
              </div>
              <div class="status-row">
                <span class="label">窃取金额</span>
                <span class="value stolen">{{ stolenAmount }} ETH</span>
              </div>
            </div>
            <div class="user-balances-table">
              <div class="table-header">
                <span>用户地址</span>
                <span>余额</span>
                <span>状态</span>
              </div>
              <div class="table-row">
                <span class="user-address">0xAttacker</span>
                <span>{{ userBalances['0xAttacker'] }} ETH</span>
                <span class="status" :class="{ active: currentRole === 'attacker' }">
                  {{ currentRole === 'attacker' ? '当前用户' : '-' }}
                </span>
              </div>
              <div class="table-row">
                <span class="user-address">0xUserA</span>
                <span>{{ userBalances['0xUserA'] }} ETH</span>
                <span class="status">-</span>
              </div>
              <div class="table-row">
                <span class="user-address">0xUserB</span>
                <span>{{ userBalances['0xUserB'] }} ETH</span>
                <span class="status">-</span>
              </div>
            </div>
          </div>

          <!-- 攻击操作区 -->
          <div v-if="currentRole === 'attacker'" class="section attack-section">
            <div class="section-header">
              <h4>⚔️ 攻击操作</h4>
              <span class="hover-hint">尝试攻击金库</span>
            </div>
            
            <!-- 存款操作 -->
            <div class="operation-block">
              <div class="block-title">💰 存入ETH</div>
              <div class="input-row">
                <span class="input-label">存款金额:</span>
                <input
                  v-model.number="depositAmount"
                  type="number"
                  class="day-input small"
                  min="0.1"
                  max="10"
                  step="0.1"
                />
                <span class="unit">ETH</span>
              </div>
              <div class="button-row">
                <button class="day-action-btn cyan" @click="handleDeposit">
                  存入ETH
                </button>
              </div>
            </div>

            <!-- 漏洞版提款 -->
            <div class="operation-block">
              <div class="block-title">🔴 攻击漏洞版本</div>
              <p class="hint">调用有漏洞的withdraw函数，触发重入攻击</p>
              <div class="button-row">
                <button class="day-action-btn red" @click="handleVulnerableAttack" :disabled="isAttacking">
                  {{ isAttacking ? '攻击中...' : '发起重入攻击' }}
                </button>
              </div>
            </div>

            <!-- 安全版提款 -->
            <div class="operation-block">
              <div class="block-title">🟢 攻击安全版本</div>
              <p class="hint">尝试攻击使用重入锁保护的safeWithdraw函数</p>
              <div class="button-row">
                <button class="day-action-btn green" @click="handleSafeAttack" :disabled="isAttacking">
                  {{ isAttacking ? '攻击中...' : '尝试攻击安全版' }}
                </button>
              </div>
            </div>

            <!-- 攻击结果展示 -->
            <div v-if="attackHistory.length > 0" class="attack-result">
              <div class="result-title">📊 攻击记录</div>
              <div class="attack-timeline">
                <div
                  v-for="(record, index) in attackHistory"
                  :key="index"
                  class="timeline-item"
                  :class="{ 'just-added': index === attackHistory.length - 1 && isAttacking }"
                >
                  <span class="round">第{{ record.round }}轮</span>
                  <span class="amount">+{{ record.amount }} ETH</span>
                  <span class="remaining">剩余: {{ record.remaining }} ETH</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 管理员操作区 -->
          <div v-else class="section admin-section">
            <div class="section-header">
              <h4>🏦 管理员操作</h4>
            </div>
            <div class="operation-block">
              <div class="block-title">📊 查看金库详情</div>
              <p class="hint">查看合约部署信息和当前状态</p>
              <div class="button-row">
                <button class="day-action-btn cyan" @click="checkVaultStatus">
                  检查金库状态
                </button>
              </div>
            </div>
            <p class="admin-hint">💡 作为管理员，你可以查看金库状态，但无法阻止正在进行的攻击。这就是智能合约一旦部署就不可篡改的特性！</p>
          </div>

          <!-- 防护演示区 -->
          <div class="section protection-section" @click="handleProtectionClick">
            <div class="section-header">
              <h4>🛡️ 防护机制</h4>
              <span class="hover-hint">👆 点击查看防护原理</span>
            </div>
            
            <!-- CEI模式 -->
            <div class="protection-mode">
              <div class="mode-title">✅ Checks-Effects-Interactions 模式</div>
              <div class="cei-steps">
                <div class="cei-step">
                  <span class="step-num">1️⃣</span>
                  <div class="step-content">
                    <div class="step-title">Checks (检查)</div>
                    <code>require(amount > 0, "Nothing to withdraw");</code>
                  </div>
                </div>
                <div class="cei-step">
                  <span class="step-num">2️⃣</span>
                  <div class="step-content">
                    <div class="step-title">Effects (更新状态)</div>
                    <code>goldBalance[msg.sender] = 0;</code>
                  </div>
                </div>
                <div class="cei-step">
                  <span class="step-num">3️⃣</span>
                  <div class="step-content">
                    <div class="step-title">Interactions (外部调用)</div>
                    <code>(bool sent, ) = msg.sender.call{value: amount}("");</code>
                  </div>
                </div>
              </div>
            </div>

            <!-- 重入锁 -->
            <div class="protection-mode">
              <div class="mode-title">🔒 ReentrancyGuard 重入锁</div>
              <div class="guard-code">
                <pre>modifier nonReentrant() {
    require(_status != _ENTERED, "Reentrant call blocked");
    _status = _ENTERED;
    _;
    _status = _NOT_ENTERED;
}</pre>
              </div>
            </div>
          </div>

          <!-- 代码对比区 -->
          <div class="section code-comparison-section" @click="handleCodeComparisonClick">
            <div class="section-header">
              <h4>📜 代码对比</h4>
              <span class="hover-hint">👆 点击查看代码对比</span>
            </div>
            <div class="code-tabs">
              <button
                class="tab-btn"
                :class="{ active: activeCodeTab === 'vulnerable' }"
                @click.stop="activeCodeTab = 'vulnerable'"
              >
                🔴 漏洞代码
              </button>
              <button
                class="tab-btn"
                :class="{ active: activeCodeTab === 'safe' }"
                @click.stop="activeCodeTab = 'safe'"
              >
                🟢 安全代码
              </button>
            </div>
            <div class="code-display">
              <div v-if="activeCodeTab === 'vulnerable'" class="code-panel vulnerable">
                <div class="panel-header">❌ 有漏洞的提款函数</div>
                <pre>function vulnerableWithdraw() external {
    uint256 amount = goldBalance[msg.sender];
    require(amount > 0, "Nothing to withdraw");
    
    // ❌ 漏洞: 先发送ETH (外部调用)
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "ETH transfer failed");
    
    // 然后更新余额 - 如果外部调用重入，余额还未更新！
    goldBalance[msg.sender] = 0;
}</pre>
                <div class="vulnerability-highlight">
                  ⚠️ 问题：先进行外部调用，后更新状态。攻击者可以在余额更新前递归调用！
                </div>
              </div>
              <div v-else class="code-panel safe">
                <div class="panel-header">✅ 安全的提款函数</div>
                <pre>function safeWithdraw() external nonReentrant {
    // 1. Checks: 验证条件
    uint256 amount = goldBalance[msg.sender];
    require(amount > 0, "Nothing to withdraw");
    
    // 2. Effects: 先更新状态
    goldBalance[msg.sender] = 0;
    
    // 3. Interactions: 最后进行外部调用
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "ETH transfer failed");
}</pre>
                <div class="security-highlight">
                  ✅ 修复：遵循CEI模式，先更新状态再进行外部调用，配合重入锁双重保护！
                </div>
              </div>
            </div>
          </div>

          <!-- 历史案例 -->
          <div class="section history-case-section">
            <div class="section-header">
              <h4>📚 历史案例: The DAO攻击</h4>
            </div>
            <div class="case-content">
              <div class="case-stat">
                <span class="stat-label">攻击时间</span>
                <span class="stat-value">2016年</span>
              </div>
              <div class="case-stat">
                <span class="stat-label">损失金额</span>
                <span class="stat-value highlight">360万 ETH</span>
              </div>
              <div class="case-stat">
                <span class="stat-label">当时价值</span>
                <span class="stat-value highlight">6000万美元</span>
              </div>
              <p class="case-description">
                The DAO是以太坊上最早的DAO项目，因重入攻击漏洞被黑客利用。这次攻击直接导致以太坊硬分叉，分裂为ETH和ETC两条链。这是智能合约安全史上最重要的教训之一。
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- 右栏：知识点面板 -->
      <div class="right-column">
        <KnowledgePanel
          :current-day="20"
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
      v-if="showFullCode"
      :show="true"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useProgressStore } from '@/stores/progressStore'
import { getFullCode } from '@/data/days'
import { useDay20 } from '@/composables/useDay20'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

// 使用 Day20 的 composable
const {
  vaultBalance,
  userBalances,
  reentrancyStatus,
  attackCount,
  stolenAmount,
  isAttacking,
  attackHistory,
  deposit,
  vulnerableWithdraw,
  safeWithdraw,
  getVaultStatus,
  realtimeData
} = useDay20()

// 进度存储
const progressStore = useProgressStore()

// 本地状态
const currentRole = ref('attacker')
const depositAmount = ref(1)
const showPrincipleExplanation = ref(false)
const activeCodeTab = ref('vulnerable')
const message = ref('')
const isError = ref(false)
const currentHint = ref('')
const showFullCode = ref(false)

// 计算属性
const unlockedConcepts = computed(() => {
  return progressStore.getDayProgress(20)?.unlockedConcepts || []
})

const progressPercentage = computed(() => {
  const progress = progressStore.getDayProgress(20)
  if (!progress || progress.totalConcepts === 0) return 0
  return Math.floor((progress.unlockedConcepts.length / progress.totalConcepts) * 100)
})

const fullCode = computed(() => getFullCode(20))

// 显示消息
const showMessage = (msg, error = false) => {
  message.value = msg
  isError.value = error
  setTimeout(() => {
    message.value = ''
  }, 5000)
}

// 切换角色
const switchRole = (role) => {
  currentRole.value = role
  // KnowledgePanel 会自动显示当前解锁概念的提示
}

// 处理原理图点击
const handlePrincipleClick = () => {
  showPrincipleExplanation.value = !showPrincipleExplanation.value
  progressStore.unlockConcept(20, 'reentrancy_attack')
  showMessage('🎉 恭喜解锁：重入攻击！这是最著名的智能合约漏洞，攻击者通过递归调用窃取资金！')
  // KnowledgePanel 会自动显示下一步提示
}

// 处理存款
const handleDeposit = () => {
  const result = deposit('0xAttacker', depositAmount.value)
  showMessage(result.message, !result.success)
  if (result.success) {
    progressStore.unlockConcept(20, 'deposit_function')
    showMessage('🎉 恭喜解锁：存款函数！用户可以通过deposit()存入ETH到金库！')
    // KnowledgePanel 会自动显示下一步提示
  }
}

// 处理漏洞攻击
const handleVulnerableAttack = () => {
  const result = vulnerableWithdraw('0xAttacker', 5)
  showMessage(result.message, !result.success)
  if (result.success) {
    // 解锁相关概念
    result.hints?.forEach(concept => {
      progressStore.unlockConcept(20, concept)
      const conceptNames = {
        'vulnerable_withdraw': '漏洞提款函数',
        'fallback_receive': 'receive()回退函数'
      }
      showMessage(`🎉 恭喜解锁：${conceptNames[concept] || concept}！`)
    })
    // 保留 composable 返回的 nextStep
    currentHint.value = result.nextStep
  }
}

// 处理安全攻击
const handleSafeAttack = () => {
  const result = safeWithdraw('0xAttacker')
  showMessage(result.message, !result.success)
  if (result.success) {
    progressStore.unlockConcept(20, 'checks_effects_interactions')
    showMessage('🎉 恭喜解锁：CEI模式！先检查条件，再更新状态，最后进行外部调用，防止重入攻击！')
    // 保留 composable 返回的 nextStep
    currentHint.value = result.nextStep
  }
}

// 检查金库状态
const checkVaultStatus = () => {
  const status = getVaultStatus()
  showMessage(`🏦 金库总余额：${status.balance} ETH`)
  progressStore.unlockConcept(20, 'contract_balance')
  showMessage('🎉 恭喜解锁：合约余额！金库合约存储所有用户的ETH，可通过balance属性查询！')
  // KnowledgePanel 会自动显示下一步提示
}

// 处理防护点击
const handleProtectionClick = () => {
  progressStore.unlockConcept(20, 'checks_effects_interactions')
  showMessage('🎉 恭喜解锁：CEI模式！先检查条件，再更新状态，最后进行外部调用，防止重入攻击！')
  
  progressStore.unlockConcept(20, 'reentrancy_guard')
  showMessage('🎉 恭喜解锁：重入锁！使用nonReentrant修饰符阻止函数被重入调用！')
  // KnowledgePanel 会自动显示最新解锁概念的提示
}

// 处理代码对比点击
const handleCodeComparisonClick = () => {
  progressStore.unlockConcept(20, 'code_comparison')
  showMessage('🎉 恭喜解锁：代码对比！对比漏洞代码和安全代码，理解CEI模式和重入锁的防护原理！')
  // KnowledgePanel 会自动显示下一步提示
}

// 获取提示
const getHint = (conceptKey) => {
  const hints = {
    reentrancy_attack: "🎯 重入攻击是最著名的智能合约漏洞！👉 存入ETH到金库开始攻击演示！",
    deposit_function: "💰 存款函数允许用户存入ETH！👉 现在尝试攻击漏洞版本！",
    vulnerable_withdraw: "🔴 有漏洞的提款函数先发送ETH后更新余额！👉 查看防护机制了解如何修复！",
    fallback_receive: "⚡ receive()函数在接收ETH时自动触发！👉 查看防护机制了解如何修复！",
    checks_effects_interactions: "✅ CEI模式先更新状态再发送ETH，防止重入！👉 尝试攻击安全版本！",
    reentrancy_guard: "🔒 重入锁阻止函数重入调用！👉 查看代码对比巩固知识！",
    contract_balance: "💵 合约余额存储所有用户的ETH！🎉 恭喜完成Day20学习！",
    code_comparison: "📜 对比漏洞代码和安全代码，理解修复方法！🎉 恭喜完成Day20学习！",
  }
  return hints[conceptKey] || "📖 点击其他概念标签查看更多详细解释！"
}

// 初始化
onMounted(() => {
  if (unlockedConcepts.value.length === 0) {
    currentHint.value = '👆 欢迎来到 Day 20！点击重入攻击原理图了解最著名的智能合约漏洞！'
  }
})

// 导出 realtimeData 供父组件使用
defineExpose({
  realtimeData
})
</script>

<style scoped>
/* 导入通用样式 */
@import '@/styles/day-common.css';

/* 区域通用样式 */
.section {
  background: var(--bg-surface-1);
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
  border: 1px solid var(--border-main);
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
  font-size: 16px;
}

.hover-hint {
  font-size: 12px;
  color: var(--text-muted);
  opacity: 0.7;
}

.section:hover .hover-hint {
  opacity: 1;
}

/* 攻击原理可视化 */
.attack-principle-section {
  cursor: pointer;
  transition: all 0.3s ease;
  background: linear-gradient(135deg, rgba(239, 68, 68, 0.05) 0%, rgba(239, 68, 68, 0.15) 100%);
  border: 1px solid rgba(239, 68, 68, 0.2);
}

.attack-principle-section:hover {
  background: linear-gradient(135deg, rgba(239, 68, 68, 0.08) 0%, rgba(239, 68, 68, 0.2) 100%);
  border-color: rgba(239, 68, 68, 0.3);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.1);
}

.flow-container {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 16px;
  background: var(--bg-surface-1);
  border-radius: 8px;
  flex-wrap: wrap;
}

.attacker-box,
.vault-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16px 20px;
  background: rgba(239, 68, 68, 0.1);
  border: 2px solid #ef4444;
  border-radius: 12px;
  min-width: 100px;
  max-width: 140px;
  flex-shrink: 0;
}

.box-icon {
  font-size: 32px;
  margin-bottom: 8px;
}

.box-label {
  font-weight: bold;
  color: #ef4444;
  font-size: 14px;
}

.box-sublabel {
  font-size: 12px;
  color: var(--text-muted);
}

.vulnerability-badge {
  margin-top: 8px;
  padding: 2px 8px;
  background: #ef4444;
  color: white;
  font-size: 11px;
  border-radius: 4px;
}

.flow-arrows {
  display: flex;
  flex-direction: column;
  gap: 8px;
  flex: 1;
}

.arrow-line {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 6px 12px;
  background: rgba(59, 130, 246, 0.1);
  border-radius: 6px;
  font-size: 12px;
}

.arrow-line.return {
  background: rgba(34, 197, 94, 0.1);
}

.arrow-line.highlight {
  background: rgba(239, 68, 68, 0.2);
  border: 1px solid #ef4444;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

.arrow-label {
  color: var(--text-muted);
}

.arrow {
  font-size: 16px;
  color: var(--text-main);
}

.principle-explanation {
  margin-top: 12px;
  padding: 12px;
  background: rgba(239, 68, 68, 0.1);
  border-left: 3px solid #ef4444;
  border-radius: 0 8px 8px 0;
}

.principle-explanation p {
  margin: 0;
  font-size: 13px;
  color: var(--text-muted);
  line-height: 1.6;
}

.principle-explanation p:first-child {
  color: #ef4444;
  font-weight: 500;
  margin-bottom: 4px;
}

/* 角色切换 */
.role-toggle-buttons {
  display: flex;
  gap: 12px;
}

.role-btn {
  flex: 1;
  padding: 12px 24px;
  border: 2px solid var(--border-main);
  background: var(--bg-surface-1);
  color: var(--text-muted);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
}

.role-btn:hover {
  border-color: #3b82f6;
  color: #3b82f6;
}

.role-btn.active {
  border-color: #3b82f6;
  background: rgba(59, 130, 246, 0.2);
  color: #3b82f6;
}

/* 金库状态 */
.status-display {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  margin-bottom: 16px;
}

.status-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 12px;
  background: var(--bg-surface-1);
  border-radius: 6px;
}

.status-row.main {
  grid-column: span 2;
  background: rgba(59, 130, 246, 0.1);
  border: 1px solid rgba(59, 130, 246, 0.3);
}

.status-row .label {
  font-size: 13px;
  color: var(--text-muted);
}

.status-row .value {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-main);
}

.status-row .value.locked {
  color: #ef4444;
}

.status-row .value.unlocked {
  color: #22c55e;
}

.status-row .value.attack-count {
  color: #ef4444;
}

.status-row .value.stolen {
  color: #ef4444;
  font-size: 16px;
}

/* 用户余额表 */
.user-balances-table {
  border: 1px solid var(--border-main);
  border-radius: 8px;
  overflow: hidden;
}

.table-header,
.table-row {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  padding: 10px 12px;
  font-size: 13px;
}

.table-header {
  background: var(--bg-surface-1);
  font-weight: 600;
  color: var(--text-muted);
}

.table-row {
  border-top: 1px solid var(--border-main);
  color: var(--text-main);
}

.table-row .user-address {
  font-family: monospace;
  font-size: 12px;
}

.table-row .status {
  font-size: 12px;
  color: #ef4444;
}

.table-row .status.active {
  color: #22c55e;
}

/* 操作区 */
.operation-block {
  margin-bottom: 20px;
  padding: 16px;
  background: transparent;
  border: 1px solid var(--border-main);
  border-radius: 8px;
}

.block-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-main);
  margin-bottom: 12px;
}

.input-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.input-label {
  font-size: 13px;
  color: var(--text-muted);
  min-width: 100px;
}

.day-input {
  flex: 1;
  padding: 8px 12px;
  background: var(--bg-base);
  border: 1px solid var(--border-main);
  border-radius: 6px;
  color: var(--text-main);
  font-size: 14px;
}

.day-input.small {
  max-width: 80px;
}

.day-input:focus {
  outline: none;
  border-color: #3b82f6;
}

.unit {
  font-size: 13px;
  color: var(--text-muted);
}

.hint {
  font-size: 12px;
  color: var(--text-muted);
}

.button-row {
  display: flex;
  gap: 12px;
}

.day-action-btn {
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
}

.day-action-btn.red {
  background: linear-gradient(135deg, #ef4444, #dc2626);
  color: white;
}

.day-action-btn.red:hover {
  background: linear-gradient(135deg, #dc2626, #b91c1c);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

.day-action-btn.green {
  background: linear-gradient(135deg, #22c55e, #16a34a);
  color: white;
}

.day-action-btn.green:hover {
  background: linear-gradient(135deg, #16a34a, #15803d);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.3);
}

.day-action-btn.cyan {
  background: linear-gradient(135deg, #06b6d4, #0891b2);
  color: white;
}

.day-action-btn.cyan:hover {
  background: linear-gradient(135deg, #0891b2, #0e7490);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(6, 182, 212, 0.3);
}

/* 攻击结果 */
.attack-result {
  margin-top: 16px;
  padding: 16px;
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.3);
  border-radius: 8px;
}

.result-title {
  font-size: 14px;
  font-weight: 600;
  color: #ef4444;
  margin-bottom: 12px;
}

.attack-timeline {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.timeline-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 8px 12px;
  background: var(--bg-surface-1);
  border-radius: 6px;
  font-size: 13px;
  transition: all 0.3s ease;
}

.timeline-item.just-added {
  background: rgba(239, 68, 68, 0.2);
  border: 1px solid #ef4444;
  animation: flash 0.5s ease;
}

@keyframes flash {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.timeline-item .round {
  color: #ef4444;
  font-weight: 600;
  min-width: 60px;
}

.timeline-item .amount {
  color: var(--text-main);
  flex: 1;
}

.timeline-item .remaining {
  color: var(--text-muted);
  font-size: 12px;
}

/* 管理员区 */
.admin-section .admin-hint {
  margin-top: 12px;
  font-size: 12px;
  color: var(--text-muted);
}

/* 防护演示区 */
.protection-section {
  cursor: pointer;
  transition: all 0.3s ease;
}

.protection-section:hover {
  border-color: #22c55e;
  box-shadow: 0 0 20px rgba(34, 197, 94, 0.2);
}

.protection-mode {
  margin-bottom: 20px;
}

.protection-mode:last-child {
  margin-bottom: 0;
}

.mode-title {
  font-size: 14px;
  font-weight: 600;
  color: #22c55e;
  margin-bottom: 12px;
}

.cei-steps {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.cei-step {
  display: flex;
  gap: 12px;
  padding: 12px;
  background: var(--bg-surface-1);
  border-radius: 8px;
  border-left: 3px solid #22c55e;
}

.step-num {
  font-size: 20px;
}

.step-content {
  flex: 1;
}

.step-title {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-main);
  margin-bottom: 6px;
}

.step-content code {
  display: block;
  padding: 8px;
  background: var(--bg-base);
  border-radius: 4px;
  font-family: 'Fira Code', monospace;
  font-size: 12px;
  color: #22c55e;
}

.guard-code {
  padding: 12px;
  background: var(--bg-base);
  border-radius: 8px;
  overflow-x: auto;
}

.guard-code pre {
  margin: 0;
  font-family: 'Fira Code', monospace;
  font-size: 12px;
  line-height: 1.6;
  color: var(--text-main);
}

/* 代码对比区 */
.code-comparison-section {
  cursor: pointer;
}

.code-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}

.tab-btn {
  padding: 8px 16px;
  border: 1px solid var(--border-main);
  background: var(--bg-surface-1);
  color: var(--text-muted);
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 13px;
}

.tab-btn:hover {
  border-color: #3b82f6;
  color: #3b82f6;
}

.tab-btn.active {
  background: rgba(59, 130, 246, 0.2);
  border-color: #3b82f6;
  color: #3b82f6;
}

.code-display {
  border-radius: 8px;
  overflow: hidden;
}

.code-panel {
  padding: 16px;
  background: var(--bg-base);
}

.code-panel.vulnerable {
  border: 1px solid rgba(239, 68, 68, 0.3);
}

.code-panel.safe {
  border: 1px solid rgba(34, 197, 94, 0.3);
}

.panel-header {
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--border-main);
}

.code-panel.vulnerable .panel-header {
  color: #ef4444;
}

.code-panel.safe .panel-header {
  color: #22c55e;
}

.code-panel pre {
  margin: 0;
  font-family: 'Fira Code', monospace;
  font-size: 12px;
  line-height: 1.6;
  color: var(--text-main);
  overflow-x: auto;
}

.vulnerability-highlight,
.security-highlight {
  margin-top: 12px;
  padding: 10px;
  border-radius: 6px;
  font-size: 13px;
}

.vulnerability-highlight {
  background: rgba(239, 68, 68, 0.2);
  color: #ef4444;
}

.security-highlight {
  background: rgba(34, 197, 94, 0.2);
  color: #22c55e;
}

/* 历史案例 */
.history-case-section {
  background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.1));
  border-color: rgba(245, 158, 11, 0.3);
}

.history-case-section .section-header h4 {
  color: #f59e0b;
}

.case-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.case-stat {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: var(--bg-surface-1);
  border-radius: 6px;
}

.stat-label {
  font-size: 13px;
  color: var(--text-muted);
}

.stat-value {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-main);
}

.stat-value.highlight {
  color: #ef4444;
  font-size: 16px;
}

.case-description {
  margin: 0;
  padding: 12px;
  background: var(--bg-surface-1);
  border-radius: 6px;
  font-size: 13px;
  color: var(--text-muted);
  line-height: 1.6;
}
</style>
