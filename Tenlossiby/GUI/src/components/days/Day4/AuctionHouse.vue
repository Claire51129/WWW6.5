<template>
  <div class="day-4-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <!-- 左侧：交互区域 -->
      <div class="left-column">
        <div class="interaction-area">
          <h3>🎮 交互操作</h3>
          
          <div v-if="!item" class="interaction-controls">
            <div class="input-group">
              <label for="item-input">拍卖物品名称/Item：</label>
              <input 
                id="item-input"
                v-model="inputItem" 
                type="text" 
                placeholder="请输入拍卖物品名称"
                @click.stop
              >
            </div>
            <div class="input-group">
              <label for="bidding-time-input">拍卖时长（秒）/Duration：</label>
              <input 
                id="bidding-time-input"
                v-model="inputBiddingTime" 
                type="number" 
                min="10"
                placeholder="60"
                @click.stop
              >
            </div>
            <button @click.stop="handleInitializeAuction" class="day-action-btn yellow">🏗️ 初始化拍卖/InitializeAuction</button>
          </div>

          <div v-else class="auction-status">
            <div class="auction-info">
              <h4>📦 拍卖物品：{{ item }}</h4>
              <p>👤 所有者：{{ owner.slice(0, 8) }}...</p>
              <p>⏰ 结束时间：{{ formatTime(auctionEndTime) }}</p>
              <p>🔴 状态：{{ ended ? '已结束' : '进行中' }}</p>
            </div>


            <div v-if="!ended" class="interaction-controls">
              <div class="input-group">
                <label for="bid-amount-input">出价金额（ETH）/Bid Amount：</label>
                <input 
                  id="bid-amount-input"
                  v-model="inputBidAmount" 
                  type="number" 
                  min="0"
                  step="0.1"
                  placeholder="0.1"
                  @click.stop
                >
              </div>
              <div class="input-group">
                <label for="bidder-address-input">竞拍者地址/Bidder Address：</label>
                <input 
                  id="bidder-address-input"
                  v-model="inputBidderAddress" 
                  type="text" 
                  placeholder="0x..."
                  @click.stop
                >
              </div>
              <div class="button-row">
                <button @click.stop="handlePlaceBid" class="day-action-btn yellow">💰 出价/Bid</button>
                <button @click.stop="inputBidderAddress = '0x' + Array(40).fill(0).map(() => Math.floor(Math.random() * 16).toString(16)).join('')" class="day-action-btn blue small">🎲 随机生成</button>
              </div>
              <button @click.stop="handleEndAuction" class="day-action-btn red full-width">🛑 结束拍卖/EndAuction</button>
            </div>

            <div v-else class="winner-section">
              <button @click.stop="handleGetWinner" class="day-action-btn cyan">🏆 获取获胜者/GetWinner</button>
              <div v-if="showWinnerResult && winnerData" class="winner-result">
                <h4>🎉 拍卖获胜者</h4>
                <p>👤 地址：{{ winnerData.winner.slice(0, 12) }}...</p>
                <p>💰 出价：{{ winnerData.bid }} ETH</p>
              </div>
            </div>
          </div>

          <div v-if="Object.keys(bids).length > 0" class="bidders-list">
            <h4>💎 竞拍者列表/Bidders</h4>
            <div v-for="bidder in bidders" :key="bidder" class="bidder-item">
              <span class="bidder-address">{{ bidder.slice(0, 10) }}...</span>
              <span class="bid-amount">{{ bids[bidder] }} ETH</span>
            </div>
          </div>

          <div v-if="highestBid > 0" class="highest-bid-info">
            <h4>🏆 当前最高出价</h4>
            <p>👤 竞拍者：{{ highestBidder.slice(0, 10) }}...</p>
            <p>💰 金额：{{ highestBid }} ETH</p>
          </div>
        </div>
      </div>

      <!-- 右侧：知识面板 -->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="4"
          :unlocked-concepts="unlockedConcepts"
          :progress-percentage="progressPercentage"
          :full-code="fullCode"
          :custom-hint="hintText"
          @show-full-code="showFullCode = true"
        />
      </div>
    </div>

    <!-- 完整代码弹窗 -->
    <FullCodeModal
      :show="showFullCode"
      title="AuctionHouse 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useDay4 } from '@/composables/useDay4'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

const {
  owner,
  item,
  auctionEndTime,
  highestBidder,
  highestBid,
  ended,
  bids,
  bidders,
  progressPercentage,
  unlockedConcepts,
  initializeAuction,
  placeBid,
  endAuction,
  getWinner,
  formatTime
} = useDay4()

// 提示文本
const hintText = ref('💡 提示：输入拍卖物品名称和时长，点击"初始化拍卖"开始学习 constructor 和 block.timestamp')

// 本地状态
const inputItem = ref('')
const inputBiddingTime = ref(60)
const inputBidAmount = ref(0)
const inputBidderAddress = ref('')
const showWinnerResult = ref(false)
const winnerData = ref(null)
const showFullCode = ref(false)

// 完整代码
const fullCode = computed(() => getFullCode(4))

// 处理初始化拍卖
const handleInitializeAuction = () => {
  if (!inputItem.value.trim()) {
    hintText.value = '⚠️ 请先输入拍卖物品名称！'
    return
  }
  
  initializeAuction(inputItem.value, parseInt(inputBiddingTime.value))
  inputItem.value = ''
  inputBiddingTime.value = 60
  updateHintText()
}

// 处理出价
const handlePlaceBid = () => {
  if (!inputBidderAddress.value.trim() || !inputBidderAddress.value.startsWith('0x')) {
    hintText.value = '⚠️ 请先输入有效的竞拍者地址！'
    return
  }
  
  if (inputBidAmount.value <= 0) {
    hintText.value = '⚠️ 出价金额必须大于0！'
    return
  }
  
  const result = placeBid(parseFloat(inputBidAmount.value), inputBidderAddress.value)
  if (result) {
    inputBidAmount.value = 0
    inputBidderAddress.value = ''
  }
  updateHintText()
}

// 处理结束拍卖
const handleEndAuction = () => {
  endAuction()
  updateHintText()
}

// 处理获取获胜者
const handleGetWinner = () => {
  const result = getWinner()
  if (result) {
    showWinnerResult.value = true
    winnerData.value = result
  }
  updateHintText()
}

// 更新提示文本
const updateHintText = () => {
  const concepts = unlockedConcepts.value
  
  // 根据具体解锁的概念来提供下一步操作提示（而不是仅仅看数量）
  if (!concepts.includes('constructor')) {
    hintText.value = '💡 提示：输入拍卖物品名称和时长，点击"初始化拍卖"开始学习 constructor 和 block.timestamp'
  } else if (!concepts.includes('require')) {
    hintText.value = '💡 提示：拍卖已初始化！现在输入竞拍者地址和出价金额，点击"出价"来学习 require 和 msg.sender'
  } else if (!concepts.includes('external')) {
    hintText.value = '💡 提示：第1次出价成功！继续添加不同的竞拍者地址再次出价，来学习 external 函数'
  } else if (!concepts.includes('bool_type')) {
    hintText.value = '⏰ 提示：继续出价或等待拍卖时间结束后，点击"结束拍卖"按钮来学习 bool 类型'
  } else if (!concepts.includes('address_type')) {
    hintText.value = '🏆 提示：拍卖已结束！点击"获取获胜者"来学习 address 类型，查看最高出价者'
  } else {
    hintText.value = '🎉 恭喜！你已解锁 Day 4 所有概念，点击查看完整代码复习吧！'
  }
}
</script>

<style scoped>
.day-4-content .input-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 20px;
}

.day-4-content .input-group label {
  font-weight: bold;
  color: var(--text-main);
}

.day-4-content .input-group input {
  padding: 12px 15px;
  border: 2px solid var(--accent-yellow);
  border-radius: 8px;
  font-size: 1em;
  background: var(--bg-base);
  color: var(--text-main);
  transition: border-color 0.3s ease;
}

.day-4-content .input-group input:focus {
  outline: none;
  border-color: var(--accent-red);
  box-shadow: 0 0 0 3px rgba(220, 50, 47, 0.2);
}

.day-4-content .input-group input::placeholder {
  color: var(--text-muted);
}

/* 按钮样式已迁移到全局 .day-action-btn */

.button-row {
  display: flex;
  gap: 10px;
  margin-bottom: 10px;
}

.button-row button {
  flex: 1;
  min-height: 48px;
}

.full-width {
  width: 100%;
  margin-top: 10px;
}

@media (max-width: 768px) {
  .day-4-content .input-group {
    margin-bottom: 15px;
  }
  
  .day-4-content .input-group input {
    font-size: 16px; /* 防止iOS缩放 */
  }
  
  .button-row {
    flex-direction: column;
  }
  
  .button-row button {
    width: 100%;
  }
  
  .bidder-item {
    flex-direction: column;
    gap: 5px;
    align-items: flex-start;
  }
}

/* 按钮hover样式由全局 .day-action-btn 处理 */

.auction-status {
  background: var(--bg-base);
  padding: 15px;
  border-radius: 8px;
  margin-top: 20px;
  border: 1px solid var(--border-main);
}

.auction-info {
  margin-bottom: 20px;
}

.auction-info h4 {
  color: var(--accent-yellow);
  margin-bottom: 10px;
  font-size: 1.1em;
  display: flex;
  align-items: center;
  gap: 8px;
}

.auction-info p {
  margin: 8px 0;
  font-size: 0.95em;
  color: var(--text-main);
  display: flex;
  align-items: center;
  gap: 8px;
}

.winner-section {
  margin-top: 20px;
  text-align: center;
}

.winner-result {
  background: var(--bg-surface-1);
  padding: 15px;
  border-radius: 8px;
  margin-top: 15px;
  border: 2px solid var(--accent-cyan);
}

.winner-result h4 {
  color: var(--accent-cyan);
  margin-bottom: 10px;
  font-size: 1.1em;
}

.winner-result p {
  margin: 8px 0;
  font-size: 0.95em;
  color: var(--text-main);
}

.bidders-list {
  background: var(--bg-base);
  padding: 15px;
  border-radius: 8px;
  margin-top: 20px;
  border: 1px solid var(--border-main);
}

.bidders-list h4 {
  color: var(--accent-yellow);
  margin-bottom: 15px;
  font-size: 1.1em;
  display: flex;
  align-items: center;
  gap: 8px;
}

.bidder-item {
  background: var(--bg-surface-1);
  padding: 10px 15px;
  border-radius: 6px;
  margin-bottom: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border: 1px solid var(--border-main);
  transition: all 0.3s ease;
}

.bidder-item:hover {
  background: var(--bg-base);
  border-color: var(--accent-yellow);
  transform: translateX(5px);
}

.bidder-address {
  font-weight: bold;
  color: var(--text-main);
}

.bid-amount {
  color: var(--accent-green);
  font-weight: bold;
}

.highest-bid-info {
  background: var(--bg-surface-1);
  padding: 15px;
  border-radius: 8px;
  margin-top: 20px;
  border: 2px solid var(--accent-yellow);
}

.highest-bid-info h4 {
  color: var(--accent-yellow);
  margin-bottom: 10px;
  font-size: 1.1em;
  display: flex;
  align-items: center;
  gap: 8px;
}

.highest-bid-info p {
  margin: 8px 0;
  font-size: 0.95em;
  color: var(--text-main);
  display: flex;
  align-items: center;
  gap: 8px;
}

.end-auction-btn {
  background: var(--accent-red) !important;
  margin-top: 10px;
}

.end-auction-btn:hover {
  background: #c0392b !important;
}

.small-btn {
  padding: 8px 16px !important;
  font-size: 0.9em !important;
}

@media (max-width: 768px) {
  .day-4-content .input-group {
    margin-bottom: 15px;
  }
  
  .day-4-content .interaction-controls button {
    width: 100%;
    justify-content: center;
  }
  
  .bidder-item {
    flex-direction: column;
    gap: 5px;
    align-items: flex-start;
  }
}
</style>
