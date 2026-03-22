<template>
  <div class="day-8-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <div class="left-column">
        <div class="interaction-area">
          <h3>🎮 交互操作</h3>
          
          <div class="identity-toggle-bar">
            <span class="identity-label">🎭 当前身份：</span>
            <div class="toggle-buttons">
              <button 
                :class="{ active: !isAdmin }" 
                @click="toggleAdmin"
              >👤 用户/User</button>
              <button 
                :class="{ active: isAdmin }" 
                @click="toggleAdmin"
              >👑 管理员/Admin</button>
            </div>
          </div>

          <div class="function-block">
            <h4 class="block-title">💹 汇率预览 (Mapping)</h4>
            <code class="function-signature">mapping(string => uint256) public conversionRates;</code>
            <div class="currency-grid">
              <div v-for="(rate, cur) in conversionRates" :key="cur" class="currency-card">
                <span class="cur-name">{{ cur }}</span>
                <span class="cur-val">{{ (rate / 1e18).toFixed(5) }} ETH</span>
              </div>
            </div>
          </div>

          <div class="function-block" :class="{ 'inactive-block': isAdmin }">
            <h4 class="block-title">💰 投币打赏 (Act 2: Payable)</h4>
            <div class="function-signature">
              函数：tipInEth() public payable<br/>
              函数：tipInCurrency(string _currency, uint256 _amount) payable
            </div>
            <div class="input-row">
              <div class="input-group">
                <label>打赏 ETH 数量：</label>
                <input v-model="inputTipEthAmount" type="number" step="0.01" min="0" @click.stop>
              </div>
              <button @click.stop="handleTipInEth" class="day-action-btn cyan">💎 直接打赏 ETH</button>
            </div>
            <div class="divider">或者按法币换算</div>
            <div class="input-row">
              <div class="input-group">
                <label>选择币种：</label>
                <select v-model="selectedCurrency" @click.stop>
                  <option v-for="cur in supportedCurrencies" :key="cur" :value="cur">{{ cur }}</option>
                </select>
              </div>
              <div class="input-group">
                <label>金额：</label>
                <input v-model="inputCurrencyAmount" type="number" min="1" @click.stop>
              </div>
              <button @click.stop="handleTipInCurrency" class="day-action-btn cyan">🔥 按汇率打赏</button>
            </div>
            <p v-if="isAdmin" class="admin-warning">⚠️ 当前是管理员模式，请切回用户进行打赏体验</p>
          </div>

          <div class="function-block admin-only" :class="{ 'inactive-block': !isAdmin }">
            <h4 class="block-title">🏦 金库管理 (Act 3: Admin)</h4>
            <code class="function-signature">函数：withdrawTips() public onlyOwner</code>
            <p class="admin-hint">只有合约拥有者(Owner)可以提取累积的打赏金。</p>
            <button @click.stop="handleWithdrawTips" class="day-action-btn red">🔓 提取全部打赏 (Withdraw)</button>
            <p v-if="!isAdmin" class="admin-warning">⚠️ 只有管理员可以操作此区块</p>
          </div>

          <div v-if="tipMessage" :class="['tip-message', { error: isTipMessageError }]">
            {{ tipMessage }}
          </div>
        </div>

        <div class="result-display">
          <h4>🍯 打赏罐实时状态</h4>
          <div class="jar-status">
            <div class="status-item main">
              <span class="label">金库总余额 (ETH)</span>
              <span class="value">{{ formatBalance(totalTips) }}</span>
            </div>
            <div class="status-item">
              <span class="label">管理员地址：</span>
              <span class="value address-val">{{ owner }}</span>
            </div>
            <div class="status-item">
              <span class="label">你的地址：</span>
              <span class="value address-val">{{ userAddress }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧：知识面板 -->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="8"
          :unlocked-concepts="unlockedConcepts"
          :progress-percentage="progressPercentage"
          :full-code="fullCode"
          @show-full-code="showFullCode = true"
        />
      </div>
    </div>

    <!-- 完整代码弹窗 -->
    <FullCodeModal
      :show="showFullCode"
      title="TipJar 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useDay8 } from '@/composables/useDay8'
import { useProgressStore } from '@/stores/progressStore'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

const progressStore = useProgressStore()

// Day8 业务逻辑
const {
  owner,
  userAddress,
  isAdmin,
  totalTips,
  supportedCurrencies,
  conversionRates,
  tipJarToggleAdmin,
  tipJarTipInEth,
  tipJarTipInCurrency,
  tipJarWithdraw,
  formatBalance
} = useDay8()

// 输入状态
const inputTipEthAmount = ref('')
const selectedCurrency = ref('USD')
const inputCurrencyAmount = ref('')

// 提示消息
const tipMessage = ref('')
const isTipMessageError = ref(false)

// 弹窗状态
const showFullCode = ref(false)

// 完整代码
const fullCode = computed(() => getFullCode(8))

// 已解锁概念
const unlockedConcepts = computed(() => {
  return progressStore.dayProgress[8]?.unlockedConcepts || []
})

// 进度百分比
const progressPercentage = computed(() => {
  const progress = progressStore.dayProgress[8]
  if (!progress || progress.totalConcepts === 0) return 0
  return Math.floor((progress.unlockedConcepts.length / progress.totalConcepts) * 100)
})

// 切换管理员
const toggleAdmin = () => {
  tipJarToggleAdmin()
}

// 处理 ETH 打赏
const handleTipInEth = () => {
  const amount = Number(inputTipEthAmount.value)
  if (!amount || amount <= 0) {
    tipMessage.value = '❌ 请输入有效的打赏数量！'
    isTipMessageError.value = true
    return
  }
  tipJarTipInEth(amount)
  tipMessage.value = '✅ 打赏成功！'
  isTipMessageError.value = false
  inputTipEthAmount.value = ''
  setTimeout(() => { tipMessage.value = '' }, 3000)
}

// 处理法币打赏
const handleTipInCurrency = () => {
  const amount = Number(inputCurrencyAmount.value)
  if (!amount || amount <= 0) {
    tipMessage.value = '❌ 请输入有效的金额！'
    isTipMessageError.value = true
    return
  }
  const success = tipJarTipInCurrency(selectedCurrency.value, amount)
  if (success) {
    tipMessage.value = '✅ 按汇率打赏成功！'
    isTipMessageError.value = false
    inputCurrencyAmount.value = ''
  } else {
    tipMessage.value = '❌ 打赏失败！'
    isTipMessageError.value = true
  }
  setTimeout(() => { tipMessage.value = '' }, 3000)
}

// 处理提现
const handleWithdrawTips = () => {
  const result = tipJarWithdraw()
  if (result === true) {
    tipMessage.value = '✅ 提现成功！'
    isTipMessageError.value = false
  } else {
    tipMessage.value = '❌ ' + result
    isTipMessageError.value = true
  }
  setTimeout(() => { tipMessage.value = '' }, 3000)
}
</script>

<style scoped>
.day-8-content .identity-toggle-bar {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 20px;
  padding: 10px;
  background: var(--bg-surface-2);
  border-radius: 8px;
}

.day-8-content .identity-label {
  font-weight: bold;
  color: var(--text-muted);
}

.day-8-content .toggle-buttons {
  display: flex;
  gap: 10px;
}

.day-8-content .toggle-buttons button {
  padding: 8px 16px;
  border: none;
  background: transparent;
  color: var(--text-muted);
  cursor: pointer;
  font-size: 0.9em;
  border-radius: 6px;
  transition: all 0.2s;
  width: auto;
  margin: 0;
}

.day-8-content .toggle-buttons button.active {
  background: var(--accent-blue);
  color: #fff;
  font-weight: bold;
}

.day-8-content .function-block {
  background: var(--bg-surface-1);
  border: 1px solid var(--border-main);
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 15px;
}

.day-8-content .function-block .block-title {
  color: var(--accent-green);
  margin: 0 0 2px 0;
  font-size: 1.1em;
  line-height: 1.2;
}

.day-8-content .function-signature {
  display: block;
  background: var(--bg-surface-2);
  padding: 4px 12px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 0.85em;
  color: var(--text-main);
  margin: 0 0 25px 0;
  border-left: 3px solid var(--accent-yellow);
  line-height: 1.3;
}

.day-8-content .currency-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 10px;
  margin-top: 10px;
}

.day-8-content .currency-card {
  background: var(--bg-surface-2);
  border: 1px solid var(--border-main);
  padding: 8px;
  border-radius: 6px;
  text-align: center;
  display: flex;
  flex-direction: column;
}

.day-8-content .cur-name {
  font-weight: bold;
  color: var(--accent-yellow);
  font-size: 0.9em;
}

.day-8-content .cur-val {
  font-size: 0.8em;
  color: var(--text-muted);
}

.day-8-content .input-row {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 10px;
}

.day-8-content .input-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.day-8-content .input-group label {
  font-weight: bold;
  color: var(--text-main);
}

.day-8-content .input-group input,
.day-8-content .input-group select {
  padding: 10px;
  border: 2px solid var(--border-main);
  border-radius: 6px;
  font-size: 1em;
  background: var(--bg-base);
  color: var(--text-main);
}

/* 按钮样式已迁移到全局 .day-action-btn */

.day-8-content .divider {
  text-align: center;
  color: var(--text-muted);
  margin: 15px 0;
  position: relative;
}

.day-8-content .divider::before,
.day-8-content .divider::after {
  content: '';
  position: absolute;
  top: 50%;
  width: 40%;
  height: 1px;
  background: var(--border-main);
}

.day-8-content .divider::before {
  left: 0;
}

.day-8-content .divider::after {
  right: 0;
}

.day-8-content .admin-only {
  border-color: var(--accent-purple);
}

.day-8-content .inactive-block {
  opacity: 0.5;
  pointer-events: none;
  filter: grayscale(0.5);
}

.day-8-content .admin-warning {
  color: var(--accent-red);
  font-size: 0.85em;
  margin-top: 10px;
  font-weight: bold;
}

.day-8-content .admin-hint {
  font-size: 0.85em;
  color: var(--text-muted);
  font-style: italic;
  margin-bottom: 10px;
}

.day-8-content .tip-message {
  margin-top: 15px;
  padding: 10px;
  border-radius: 6px;
  background: var(--accent-green);
  color: #fff;
  text-align: center;
  font-weight: bold;
}

.day-8-content .tip-message.error {
  background: var(--accent-red);
}

.day-8-content .result-display {
  background: var(--bg-surface-1);
  border: 1px solid var(--border-main);
  border-radius: 8px;
  padding: 15px;
  margin-top: 20px;
  margin-bottom: 20px;
}

.day-8-content .result-display h4 {
  color: var(--accent-green);
  margin-bottom: 10px;
}

.day-8-content .jar-status {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.day-8-content .status-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid var(--border-main);
}

.day-8-content .status-item.main {
  font-size: 1.2em;
  font-weight: bold;
}

.day-8-content .status-item .label {
  color: var(--text-muted);
}

.day-8-content .status-item .value {
  color: var(--accent-yellow);
}

.day-8-content .status-item .address-val {
  font-size: 0.85em;
  font-family: monospace;
}

@media (max-width: 768px) {
  .day-8-content .identity-toggle-bar {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .day-8-content .currency-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
