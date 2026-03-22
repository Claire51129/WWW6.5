<template>
  <div class="day-5-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <div class="left-column">
        <div class="interaction-area">
          <h3>🎮 交互操作</h3>
          <div class="interaction-controls">
            <div class="function-block">
              <h4 class="block-title">💎 添加宝藏</h4>
              <code class="function-signature">函数：addTreasure(uint256 amount)</code>
              <div class="input-group">
                <label for="treasure-input">添加宝藏数量/Amount：</label>
                <input 
                  id="treasure-input"
                  v-model="inputTreasureAmount" 
                  type="number" 
                  placeholder="请输入数量"
                  @click.stop
                >
              </div>
              <button @click.stop="handleAddTreasure" class="day-action-btn yellow">➕ 添加宝藏/AddTreasure</button>
            </div>
            
            <div class="function-block">
              <h4 class="block-title">✅ 批准提款</h4>
              <code class="function-signature">函数：approveWithdrawal(address recipient, uint256 amount)</code>
              <div class="input-group label-input-row">
                <label for="recipient-input">用户地址/Recipient：</label>
                <input 
                  id="recipient-input"
                  v-model="inputRecipient" 
                  type="text" 
                  placeholder="0x..."
                  @click.stop
                >
              </div>
              <button @click.stop="inputRecipient = '0x' + Array(40).fill(0).map(() => Math.floor(Math.random() * 16).toString(16)).join('')" class="day-action-btn blue small" style="margin-bottom: 10px;">🎲 随机生成</button>
              <div class="input-group">
                <label for="allowance-input">提款额度/Allowance：</label>
                <input 
                  id="allowance-input"
                  v-model="inputAllowance" 
                  type="number" 
                  placeholder="请输入额度"
                  @click.stop
                >
              </div>
              <button @click.stop="handleApproveWithdrawal" class="day-action-btn yellow">✅ 批准提款/ApproveWithdrawal</button>
            </div>
            
            <div class="function-block">
              <h4 class="block-title">💰 提取宝藏</h4>
              <code class="function-signature">函数：withdrawTreasure(uint256 amount)</code>
              <div class="input-group">
                <label for="withdraw-input">提取数量/Amount：</label>
                <input 
                  id="withdraw-input"
                  v-model="inputWithdrawAmount" 
                  type="number" 
                  placeholder="请输入数量"
                  @click.stop
                >
              </div>
              <button @click.stop="handleWithdrawTreasure" class="day-action-btn green">💰 提取宝藏/WithdrawTreasure</button>
              <button @click.stop="handleResetWithdrawalStatus" class="day-action-btn orange">🔄 重置提款状态/ResetStatus</button>
              <code class="function-signature">函数：resetWithdrawalStatus(address user)</code>
            </div>
            
            <div class="function-block">
              <h4 class="block-title">🔐 转移所有权</h4>
              <code class="function-signature">函数：transferOwnership(address newOwner)</code>
              <div class="input-group label-input-row">
                <label for="new-owner-input">新所有者地址/New Owner：</label>
                <input 
                  id="new-owner-input"
                  v-model="inputNewOwner" 
                  type="text" 
                  placeholder="0x..."
                  @click.stop
                >
              </div>
              <button @click.stop="inputNewOwner = '0x' + Array(40).fill(0).map(() => Math.floor(Math.random() * 16).toString(16)).join('')" class="day-action-btn blue small">🎲 随机生成</button>
              <button @click.stop="handleTransferOwnership" class="day-action-btn red">🔐 转移所有权/TransferOwnership</button>
            </div>
            
            <div class="function-block query-block">
              <h4 class="block-title">📊 查询操作</h4>
              <code class="function-signature">函数：getTreasureDetails() returns (uint256)</code>
              <button @click.stop="handleGetTreasureDetails" class="day-action-btn cyan">📊 获取宝藏详情/GetDetails</button>
            </div>
          </div>
          <div class="result-display">
            <h4>🏆 宝库状态</h4>
            <div class="result-value">
              <div><strong>所有者/Owner：</strong>{{ owner || '未初始化' }}</div>
              <div><strong>宝藏数量/Treasure：</strong>{{ treasureAmount }}</div>
              <div><strong>当前用户地址/Your Address：</strong>{{ userAddress }}</div>
              <div><strong>提款额度/Allowance：</strong>{{ userAllowance || 0 }}</div>
              <div><strong>已提取/Withdrawn：</strong>{{ hasWithdrawn ? '是/Yes' : '否/No' }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧：知识面板 -->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="5"
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
      title="AdminOnly 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useDay5 } from '@/composables/useDay5'
import { useProgressStore } from '@/stores/progressStore'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

const progressStore = useProgressStore()

// Day5 业务逻辑
const {
  inputTreasureAmount,
  inputRecipient,
  inputAllowance,
  inputWithdrawAmount,
  inputNewOwner,
  owner,
  treasureAmount,
  userAddress,
  userAllowance,
  hasWithdrawn,
  addTreasure,
  approveWithdrawal,
  withdrawTreasure,
  resetWithdrawalStatus,
  transferOwnership,
  getTreasureDetails
} = useDay5()

// 弹窗状态
const showFullCode = ref(false)

// 完整代码
const fullCode = computed(() => getFullCode(5))

// 已解锁概念
const unlockedConcepts = computed(() =>
  progressStore.getDayProgress(5)?.unlockedConcepts || []
)

// 进度百分比
const progressPercentage = computed(() => {
  const progress = progressStore.getDayProgress(5)
  if (!progress || progress.totalConcepts === 0) return 0
  return Math.floor((progress.unlockedConcepts.length / progress.totalConcepts) * 100)
})

// 处理添加宝藏
const handleAddTreasure = () => {
  const amount = Number(inputTreasureAmount.value)
  if (!amount || amount <= 0) {
    alert('请输入有效的宝藏数量！')
    return
  }
  addTreasure(amount)
  inputTreasureAmount.value = ''
}

// 处理批准提款
const handleApproveWithdrawal = () => {
  if (!inputRecipient.value.trim()) {
    alert('请输入用户地址！')
    return
  }
  const amount = Number(inputAllowance.value)
  if (!amount || amount <= 0) {
    alert('请输入有效的提款额度！')
    return
  }
  approveWithdrawal(inputRecipient.value, amount)
  inputRecipient.value = ''
  inputAllowance.value = ''
}

// 处理提取宝藏
const handleWithdrawTreasure = () => {
  const amount = Number(inputWithdrawAmount.value)
  if (!amount || amount <= 0) {
    alert('请输入有效的提取数量！')
    return
  }
  withdrawTreasure(userAddress.value, amount)
  inputWithdrawAmount.value = ''
}

// 处理重置提款状态
const handleResetWithdrawalStatus = () => {
  resetWithdrawalStatus(userAddress.value)
}

// 处理转移所有权
const handleTransferOwnership = () => {
  if (!inputNewOwner.value.trim()) {
    alert('请输入新所有者地址！')
    return
  }
  transferOwnership(inputNewOwner.value)
  inputNewOwner.value = ''
}

// 处理获取宝藏详情
const handleGetTreasureDetails = () => {
  const amount = getTreasureDetails()
  alert(`📊 宝藏详情\n\n当前宝藏数量: ${amount}`)
}
</script>

<style scoped>
/* Day5 特有样式，布局相关已使用全局样式（day-content + content-layout） */

.day-5-content .input-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 15px;
}

.day-5-content .input-group.label-input-row {
  flex-direction: row;
  align-items: center;
  gap: 10px;
}

.day-5-content .input-group.label-input-row label {
  white-space: nowrap;
  min-width: 120px;
}

.day-5-content .input-group label {
  font-weight: bold;
  color: var(--text-main);
}

.day-5-content .input-group input {
  padding: 12px 15px;
  border: 2px solid var(--accent-yellow);
  border-radius: 8px;
  font-size: 1em;
  background: var(--bg-base);
  color: var(--text-main);
  transition: border-color 0.3s ease;
  font-family: inherit;
}

.day-5-content .input-group input:focus {
  outline: none;
  border-color: var(--accent-red);
  box-shadow: 0 0 0 3px rgba(220, 50, 47, 0.2);
}

.day-5-content .input-group input::placeholder {
  color: var(--text-muted);
}

/* 按钮样式已迁移到全局 .day-action-btn */

.day-5-content .function-block {
  background: var(--bg-surface-1);
  border: 1px solid var(--border-main);
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 15px;
}

.day-5-content .function-block .block-title {
  color: var(--accent-blue);
  margin: 0 0 2px 0;
  font-size: 1.1em;
  line-height: 1.2;
}

.day-5-content .function-signature {
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

.day-5-content .query-block {
  background: var(--bg-surface-2);
}

.day-5-content .result-display {
  background: var(--bg-surface-1);
  border: 1px solid var(--border-main);
  border-radius: 8px;
  padding: 15px;
  margin-top: 20px;
}

.day-5-content .result-display h4 {
  color: var(--accent-green);
  margin-bottom: 10px;
}

.day-5-content .result-value {
  color: var(--text-main);
  line-height: 1.8;
}

.day-5-content .result-value div {
  padding: 3px 0;
}

@media (max-width: 768px) {
  .day-5-content .input-group.label-input-row {
    flex-direction: column;
    align-items: flex-start;
  }

  .day-5-content .input-group.label-input-row label {
    min-width: auto;
  }

  .day-5-content .input-group input {
    font-size: 16px;
  }
}
</style>
