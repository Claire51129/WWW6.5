<template>
  <div class="day-21-content day-content">
    <!-- 消息提示 -->
    <div v-if="message" :class="['message-toast', { error: isError }]">
      {{ message }}
    </div>

    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <!-- 左栏：交互区域 -->
      <div class="left-column">
        <div class="interaction-area">
          <!-- ERC721架构可视化区 -->
          <div class="section architecture-section" @click="handleArchitectureClick">
            <div class="section-header">
              <h4>📐 ERC721 标准架构</h4>
              <span class="hover-hint">👆 点击了解ERC721标准</span>
            </div>
            <div class="architecture-visualization">
              <div class="arch-container">
                <div class="interface-box">
                  <div class="box-icon">🔌</div>
                  <div class="box-label">IERC721</div>
                  <div class="box-sublabel">标准接口</div>
                </div>
                <div class="arrow">→</div>
                <div class="contract-box">
                  <div class="box-icon">🎨</div>
                  <div class="box-label">SimpleNFT</div>
                  <div class="box-sublabel">合约实现</div>
                </div>
              </div>
              <div class="mappings-row">
                <div class="mapping-box">
                  <div class="mapping-label">_owners</div>
                  <div class="mapping-desc">tokenId → address</div>
                </div>
                <div class="mapping-box">
                  <div class="mapping-label">_balances</div>
                  <div class="mapping-desc">address → count</div>
                </div>
                <div class="mapping-box">
                  <div class="mapping-label">_tokenApprovals</div>
                  <div class="mapping-desc">tokenId → address</div>
                </div>
              </div>
            </div>
          </div>

          <!-- 铸造操作区 -->
          <div class="section mint-section">
            <div class="section-header">
              <h4>🏭 铸造新 NFT</h4>
            </div>
            <div class="mint-form">
              <div class="form-row">
                <label>接收地址:</label>
                <div class="input-with-btn">
                  <input
                    v-model="mintForm.to"
                    type="text"
                    placeholder="0x..."
                    class="form-input"
                  />
                  <button class="icon-btn" @click="fillRandomMintData" title="随机生成">
                    🎲
                  </button>
                </div>
              </div>
              <div class="form-row">
                <label>元数据URI:</label>
                <div class="input-with-btn">
                  <input
                    v-model="mintForm.uri"
                    type="text"
                    placeholder="ipfs://Qm..."
                    class="form-input"
                  />
                  <button class="icon-btn" @click="mintForm.uri = generateRandomURI()" title="随机生成">
                    🎲
                  </button>
                </div>
              </div>
              <button class="action-btn primary" @click="handleMint">
                🎨 铸造 NFT
              </button>
            </div>
          </div>

          <!-- 所有权追踪面板 -->
          <div class="section tracker-section">
            <div class="section-header">
              <h4>📊 所有权追踪</h4>
            </div>
            <div class="tracker-form">
              <div class="form-row">
                <label>查询地址:</label>
                <div class="input-with-btn">
                  <input
                    v-model="queryForm.address"
                    type="text"
                    placeholder="0x..."
                    class="form-input"
                  />
                  <button class="action-btn small" @click="handleQueryBalance">查询</button>
                </div>
              </div>
              <!-- 已有地址选择 -->
              <div v-if="usedAddresses.length > 0" class="address-selector">
                <label class="selector-label">选择已有地址:</label>
                <div class="address-chips">
                  <button
                    v-for="addr in usedAddresses.slice(0, 5)"
                    :key="addr"
                    class="address-chip"
                    @click="selectUsedAddress(addr)"
                  >
                    {{ addr.slice(0, 8) }}...{{ addr.slice(-4) }}
                  </button>
                </div>
              </div>
            </div>
            <div v-if="queryResult" class="tracker-result">
              <div class="result-header">
                <span class="result-address">{{ queryForm.address.slice(0, 10) }}...</span>
                <span class="result-balance">持有 {{ queryResult.balance }} 个NFT</span>
              </div>
              <div v-if="queryResult.tokens.length > 0" class="token-list">
                <div
                  v-for="token in queryResult.tokens"
                  :key="token.tokenId"
                  class="token-item"
                >
                  <span class="token-icon">{{ getNftIcon(token.tokenId) }}</span>
                  <span class="token-id">#{{ token.tokenId }}</span>
                  <span v-if="tokenApprovals[token.tokenId]" class="token-approved">🔑</span>
                </div>
              </div>
            </div>
          </div>

          <!-- NFT画廊展示区 -->
          <div class="section gallery-section">
            <div class="section-header">
              <h4>🖼️ NFT 画廊 (已铸造: {{ nfts.length }})</h4>
              <span class="hover-hint">点击NFT查看详情</span>
            </div>
            <div class="nft-gallery">
              <div
                v-for="nft in nfts"
                :key="nft.tokenId"
                class="nft-card"
                :class="{ 
                  'selected': selectedTokenId === nft.tokenId,
                  'is-approved': tokenApprovals[nft.tokenId]
                }"
                @click="selectNFT(nft.tokenId)"
              >
                <div v-if="tokenApprovals[nft.tokenId]" class="approval-badge">🔑</div>
                <div class="nft-icon">{{ getNftIcon(nft.tokenId) }}</div>
                <div class="nft-id">#{{ nft.tokenId }}</div>
                <div class="nft-owner">{{ nft.owner.slice(0, 6) }}...{{ nft.owner.slice(-4) }}</div>
                <div class="nft-actions">
                  <button class="action-btn small" @click.stop="showNFTDetails(nft)">详情</button>
                </div>
              </div>
              <div v-if="nfts.length === 0" class="empty-gallery">
                <div class="empty-icon">🎨</div>
                <div class="empty-text">还没有NFT</div>
                <div class="empty-subtext">铸造你的第一个NFT！</div>
              </div>
            </div>
          </div>

          <!-- 转移/授权操作区 -->
          <div v-if="selectedTokenId" class="section operation-section">
            <div class="section-header">
              <h4>🔄 NFT 操作 (选中: Token #{{ selectedTokenId }})</h4>
            </div>
            <div class="operation-tabs">
              <button
                class="tab-btn"
                :class="{ active: activeTab === 'transfer' }"
                @click="activeTab = 'transfer'"
              >
                转移
              </button>
              <button
                class="tab-btn"
                :class="{ active: activeTab === 'approve' }"
                @click="activeTab = 'approve'"
              >
                授权
              </button>
              <button
                class="tab-btn"
                :class="{ active: activeTab === 'safeTransfer' }"
                @click="activeTab = 'safeTransfer'"
              >
                安全转移
              </button>
            </div>

            <!-- 转移模式 -->
            <div v-if="activeTab === 'transfer'" class="operation-panel">
              <div class="form-row">
                <label>From:</label>
                <span class="static-value">{{ getSelectedOwner().slice(0, 10) }}...</span>
              </div>
              <div class="form-row">
                <label>To:</label>
                <div class="input-with-btn">
                  <input
                    v-model="transferForm.to"
                    type="text"
                    placeholder="0x..."
                    class="form-input"
                  />
                  <button class="icon-btn" @click="fillRandomTransferTo" title="随机生成">
                    🎲
                  </button>
                </div>
              </div>
              <button class="action-btn" @click="handleTransfer">执行转移</button>
            </div>

            <!-- 授权模式 -->
            <div v-if="activeTab === 'approve'" class="operation-panel">
              <div class="form-row">
                <label>Token ID:</label>
                <span class="static-value">#{{ selectedTokenId }}</span>
              </div>
              <div class="form-row">
                <label>授权给:</label>
                <div class="input-with-btn">
                  <input
                    v-model="approveForm.to"
                    type="text"
                    placeholder="0x..."
                    class="form-input"
                  />
                  <button class="icon-btn" @click="fillRandomApproveTo" title="随机生成">
                    🎲
                  </button>
                </div>
              </div>
              <button class="action-btn" @click="handleApprove">批准授权</button>
              <div v-if="tokenApprovals[selectedTokenId]" class="current-approval">
                当前授权: {{ tokenApprovals[selectedTokenId].slice(0, 10) }}...
              </div>
            </div>

            <!-- 安全转移模式 -->
            <div v-if="activeTab === 'safeTransfer'" class="operation-panel">
              <div class="form-row">
                <label>From:</label>
                <span class="static-value">{{ getSelectedOwner().slice(0, 10) }}...</span>
              </div>
              <div class="form-row">
                <label>To:</label>
                <div class="input-with-btn">
                  <input
                    v-model="transferForm.to"
                    type="text"
                    placeholder="0x..."
                    class="form-input"
                  />
                  <button class="icon-btn" @click="fillRandomTransferTo" title="随机生成">
                    🎲
                  </button>
                </div>
              </div>
              <div class="info-tip">
                💡 安全转移会检查接收方是否支持ERC721
              </div>
              <button class="action-btn safe" @click="handleSafeTransfer">安全转移</button>
            </div>
          </div>

          <!-- 操作员授权 -->
          <div class="section operator-section">
            <div class="section-header">
              <h4>👥 操作员授权</h4>
            </div>
            <div class="operator-form">
              <div class="form-row">
                <label>操作员地址:</label>
                <div class="input-with-btn">
                  <input
                    v-model="operatorForm.operator"
                    type="text"
                    placeholder="0x..."
                    class="form-input"
                  />
                  <button class="icon-btn" @click="fillRandomOperator" title="随机生成">
                    🎲
                  </button>
                </div>
              </div>
              <div class="form-row">
                <label>状态:</label>
                <select v-model="operatorForm.approved" class="form-select">
                  <option :value="true">✅ 授权</option>
                  <option :value="false">❌ 取消</option>
                </select>
              </div>
              <button class="action-btn" @click="handleOperatorApprove">
                {{ operatorForm.approved ? '设置授权' : '取消授权' }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- 右栏：知识面板 -->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="21"
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
      title="SimpleNFT 完整代码"
      @close="showFullCode = false"
    />

    <!-- NFT详情弹窗 -->
    <div v-if="showNFTModal" class="modal-overlay" @click="showNFTModal = false">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>🖼️ NFT 详情</h3>
          <button class="close-btn" @click="showNFTModal = false">×</button>
        </div>
        <div class="nft-details" v-if="selectedNFT">
          <div class="detail-row">
            <span class="detail-label">Token ID:</span>
            <span class="detail-value">#{{ selectedNFT.tokenId }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">所有者:</span>
            <span class="detail-value">{{ selectedNFT.owner }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">元数据URI:</span>
            <span class="detail-value uri">{{ selectedNFT.uri }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">授权状态:</span>
            <span class="detail-value">
              {{ tokenApprovals[selectedNFT.tokenId] || '未授权' }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useProgressStore } from '../../../stores/progressStore'
import { useDay21 } from '../../../composables/useDay21'
import KnowledgePanel from '../../shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'
import { getFullCode } from '../../../data/days'

const progressStore = useProgressStore()

// 获取 Day 21 的解锁概念（安全访问，避免undefined）
const unlockedConcepts = computed(() =>
  progressStore.getDayProgress(21)?.unlockedConcepts || []
)

// 计算 Day 21 的进度百分比
const progressPercentage = computed(() => {
  const progress = progressStore.getDayProgress(21)
  if (!progress || progress.totalConcepts === 0) return 0
  return Math.round((progress.unlockedConcepts.length / progress.totalConcepts) * 100)
})

const {
  nfts,
  tokenApprovals,
  operatorApprovals,
  selectedTokenId,
  mintForm,
  transferForm,
  approveForm,
  operatorForm,
  queryForm,
  message,
  isError,
  showMessage,
  mintNFT,
  balanceOf,
  transferFrom,
  safeTransferFrom,
  approve,
  getTokensByOwner
} = useDay21()

const currentHint = ref('')
const showFullCode = ref(false)
const showNFTModal = ref(false)
const selectedNFT = ref(null)
const activeTab = ref('transfer')
const queryResult = ref(null)

const fullCode = computed(() => getFullCode(21))

// NFT图标映射
const getNftIcon = (tokenId) => {
  const icons = ['🎨', '🎭', '🎪', '🎯', '🎲', '🎸', '🎺', '🎻', '🎮', '🎰']
  return icons[(tokenId - 1) % icons.length]
}

// 获取选中NFT的所有者
const getSelectedOwner = () => {
  const nft = nfts.value.find(n => n.tokenId === selectedTokenId.value)
  return nft ? nft.owner : ''
}

// 选择NFT
const selectNFT = (tokenId) => {
  selectedTokenId.value = tokenId
}

// 显示NFT详情
const showNFTDetails = (nft) => {
  selectedNFT.value = nft
  showNFTModal.value = true
  // 解锁 token_uri
  if (!progressStore.isConceptUnlocked(21, 'token_uri')) {
    progressStore.unlockConcept(21, 'token_uri')
    showMessage('✅ 已查看NFT详情！🎉 恭喜解锁：Token URI！👉 选中一个NFT，尝试转移NFT！')
    currentHint.value = '🔗 Token URI 指向NFT的元数据，通常存储在IPFS上！👉 点击铸造按钮创建你的第一个NFT！'
  }
}

// 处理架构图点击
const handleArchitectureClick = () => {
  if (!progressStore.isConceptUnlocked(21, 'ierc721_interface')) {
    progressStore.unlockConcept(21, 'ierc721_interface')
    showMessage('✅ 已查看ERC721架构！🎉 恭喜解锁：IERC721接口！👉 尝试铸造你的第一个NFT！')
    currentHint.value = '📦 太棒了！你了解了ERC721标准接口定义！👉 点击铸造按钮来创建你的第一个NFT！'
  }
}

// 处理铸造
const handleMint = () => {
  const result = mintNFT(mintForm.value.to, mintForm.value.uri)

  if (result.success) {
    // 铸造成功后解锁 mint_function
    if (!progressStore.isConceptUnlocked(21, 'mint_function')) {
      progressStore.unlockConcept(21, 'mint_function')
      showMessage('✅ 铸造功能已触发！🎉 恭喜解锁：铸造函数！👉 完成铸造查看计数器！')
    }

    // 解锁 token_id_counter
    if (!progressStore.isConceptUnlocked(21, 'token_id_counter')) {
      progressStore.unlockConcept(21, 'token_id_counter')
      showMessage('🎉 NFT铸造成功！🎉 恭喜解锁：代币ID计数器！👉 查询地址余额了解持有情况！')
    }

    currentHint.value = result.nextStep
    // 清空表单
    mintForm.value.to = ''
    mintForm.value.uri = ''
  }
}

// 处理查询余额
const handleQueryBalance = () => {
  const result = balanceOf(queryForm.value.address)

  if (result.success) {
    queryResult.value = {
      balance: result.balance,
      tokens: getTokensByOwner(queryForm.value.address)
    }

    // 解锁 balance_of
    if (!progressStore.isConceptUnlocked(21, 'balance_of')) {
      progressStore.unlockConcept(21, 'balance_of')
      showMessage('✅ 查询成功！🎉 恭喜解锁：BalanceOf！👉 查看代币授权状态！')
      currentHint.value = result.nextStep
    }
  }
}

// 处理转移
const handleTransfer = () => {
  const from = getSelectedOwner()
  const result = transferFrom(from, transferForm.value.to, selectedTokenId.value)

  if (result.success) {
    // 解锁 transfer_from
    if (!progressStore.isConceptUnlocked(21, 'transfer_from')) {
      progressStore.unlockConcept(21, 'transfer_from')
      showMessage('✅ NFT转移成功！🎉 恭喜解锁：TransferFrom！👉 尝试授权其他地址管理你的NFT！')
      currentHint.value = result.nextStep
    }
    transferForm.value.to = ''
  }
}

// 处理安全转移
const handleSafeTransfer = () => {
  const from = getSelectedOwner()
  const result = safeTransferFrom(from, transferForm.value.to, selectedTokenId.value)

  if (result.success) {
    // 解锁 safe_transfer
    if (!progressStore.isConceptUnlocked(21, 'safe_transfer')) {
      progressStore.unlockConcept(21, 'safe_transfer')
      showMessage('🔒 安全转移完成！🎉 恭喜解锁：SafeTransferFrom！👉 尝试授权功能！')
      currentHint.value = result.nextStep
    }
    transferForm.value.to = ''
  }
}

// 处理授权
const handleApprove = () => {
  const result = approve(approveForm.value.to, selectedTokenId.value)

  if (result.success) {
    // 解锁 approve_mechanism
    if (!progressStore.isConceptUnlocked(21, 'approve_mechanism')) {
      progressStore.unlockConcept(21, 'approve_mechanism')
      showMessage('🔑 授权成功！🎉 恭喜解锁：Approve机制！👉 尝试设置操作员授权！')
      currentHint.value = result.nextStep
    }
    approveForm.value.to = ''
  }
}

// 处理操作员授权
const handleOperatorApprove = () => {
  const { setApprovalForAll } = useDay21()
  const result = setApprovalForAll(operatorForm.value.operator, operatorForm.value.approved)

  if (result.success) {
    // 解锁 approval_for_all
    if (!progressStore.isConceptUnlocked(21, 'approval_for_all')) {
      progressStore.unlockConcept(21, 'approval_for_all')
      showMessage('👥 操作员授权已设置！🎉 恭喜解锁：ApprovalForAll！👉 尝试使用安全转移功能！')
      currentHint.value = result.nextStep
    }
    operatorForm.value.operator = ''
  }
}

// 存储所有使用过的地址
const usedAddresses = ref([])

// 生成随机以太坊地址
const generateRandomAddress = () => {
  const chars = '0123456789abcdef'
  let address = '0x'
  for (let i = 0; i < 40; i++) {
    address += chars[Math.floor(Math.random() * 16)]
  }
  // 保存到已使用地址列表
  if (!usedAddresses.value.includes(address)) {
    usedAddresses.value.push(address)
  }
  return address
}

// 生成随机IPFS URI
const generateRandomURI = () => {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789'
  let hash = 'Qm'
  for (let i = 0; i < 44; i++) {
    hash += chars[Math.floor(Math.random() * chars.length)]
  }
  return `ipfs://${hash}`
}

// 填充铸造表单随机值
const fillRandomMintData = () => {
  mintForm.value.to = generateRandomAddress()
  mintForm.value.uri = generateRandomURI()
  showMessage('🎲 已生成随机地址和URI！')
}

// 填充转移目标地址
const fillRandomTransferTo = () => {
  transferForm.value.to = generateRandomAddress()
  showMessage('🎲 已生成随机目标地址！')
}

// 填充授权地址
const fillRandomApproveTo = () => {
  approveForm.value.to = generateRandomAddress()
  showMessage('🎲 已生成随机授权地址！')
}

// 填充操作员地址
const fillRandomOperator = () => {
  operatorForm.value.operator = generateRandomAddress()
  showMessage('🎲 已生成随机操作员地址！')
}

// 选择已有地址
const selectUsedAddress = (address) => {
  queryForm.value.address = address
  showMessage(`✅ 已选择地址: ${address.slice(0, 10)}...`)
}

// 初始提示
onMounted(() => {
  if (unlockedConcepts.value.length === 0) {
    currentHint.value = '👆 欢迎来到 Day 21！点击ERC721架构图了解NFT标准！'
  }
})
</script>

<style scoped>
/* Day 21特有样式 - 布局样式已在全局定义 */

.section {
  background: var(--bg-surface-1);
  border: 1px solid var(--border-main);
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 16px;
  transition: all 0.3s ease;
}

.section:last-child {
  margin-bottom: 0;
}

.section:hover {
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

/* 不同区块的颜色主题 */
.architecture-section {
  background: linear-gradient(135deg, rgba(56, 189, 248, 0.08) 0%, rgba(99, 102, 241, 0.08) 100%);
  border-color: rgba(56, 189, 248, 0.2);
}

.gallery-section {
  background: linear-gradient(135deg, rgba(168, 85, 247, 0.08) 0%, rgba(236, 72, 153, 0.08) 100%);
  border-color: rgba(168, 85, 247, 0.2);
}

.mint-section {
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.08) 0%, rgba(16, 185, 129, 0.08) 100%);
  border-color: rgba(34, 197, 94, 0.2);
}

.operation-section {
  background: linear-gradient(135deg, rgba(249, 115, 22, 0.08) 0%, rgba(245, 158, 11, 0.08) 100%);
  border-color: rgba(249, 115, 22, 0.2);
}

.tracker-section {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.08) 0%, rgba(139, 92, 246, 0.08) 100%);
  border-color: rgba(99, 102, 241, 0.2);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.section-header h4 {
  margin: 0;
  color: var(--text-main);
  font-size: 16px;
}

.hover-hint {
  font-size: 12px;
  color: var(--text-muted);
  opacity: 0;
  transition: opacity 0.3s;
}

.section:hover .hover-hint {
  opacity: 1;
}

/* 架构可视化 */
.architecture-visualization {
  cursor: pointer;
}

.arch-container {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  margin-bottom: 20px;
}

.interface-box, .contract-box {
  background: rgba(56, 189, 248, 0.15);
  border: 2px solid rgba(56, 189, 248, 0.4);
  border-radius: 12px;
  padding: 16px 24px;
  text-align: center;
  transition: all 0.3s ease;
}

.interface-box:hover, .contract-box:hover {
  background: rgba(56, 189, 248, 0.25);
  transform: translateY(-2px);
}

.box-icon {
  font-size: 32px;
  margin-bottom: 8px;
}

.box-label {
  font-weight: bold;
  color: #0ea5e9;
  font-size: 14px;
}

.box-sublabel {
  font-size: 12px;
  color: var(--text-muted);
}

.arrow {
  font-size: 24px;
  color: #0ea5e9;
}

.mappings-row {
  display: flex;
  justify-content: center;
  gap: 16px;
  flex-wrap: wrap;
}

.mapping-box {
  background: rgba(139, 92, 246, 0.15);
  border: 1px solid rgba(139, 92, 246, 0.4);
  border-radius: 8px;
  padding: 12px 16px;
  text-align: center;
  transition: all 0.3s ease;
}

.mapping-box:hover {
  background: rgba(139, 92, 246, 0.25);
  transform: translateY(-2px);
}

.mapping-label {
  font-weight: bold;
  color: #8b5cf6;
  font-size: 14px;
}

.mapping-desc {
  font-size: 11px;
  color: var(--text-muted);
}

/* NFT画廊 */
.nft-gallery {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 16px;
}

.nft-card {
  background: var(--bg-surface-2);
  border: 2px solid var(--border-main);
  border-radius: 12px;
  padding: 16px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  position: relative;
}

.nft-card:hover {
  border-color: rgba(168, 85, 247, 0.5);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(168, 85, 247, 0.15);
}

.nft-card.selected {
  border-color: #a855f7;
  background: rgba(168, 85, 247, 0.1);
}

.nft-card.is-approved {
  border-color: rgba(234, 179, 8, 0.5);
}

.approval-badge {
  position: absolute;
  top: -8px;
  right: -8px;
  background: rgba(234, 179, 8, 0.9);
  border-radius: 50%;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
}

.nft-icon {
  font-size: 48px;
  margin-bottom: 8px;
}

.nft-id {
  font-weight: bold;
  color: var(--text-main);
  margin-bottom: 4px;
}

.nft-owner {
  font-size: 11px;
  color: var(--text-muted);
  margin-bottom: 8px;
}

.empty-gallery {
  grid-column: 1 / -1;
  text-align: center;
  padding: 40px;
  color: var(--text-muted);
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 8px;
}

/* 表单样式 */
.mint-form, .operation-panel, .operator-form, .tracker-form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.form-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.form-row label {
  min-width: 80px;
  color: var(--text-muted);
  font-size: 14px;
}

.input-with-btn {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8px;
}

.input-with-btn .form-input {
  flex: 1;
}

.icon-btn {
  background: rgba(99, 102, 241, 0.2);
  border: 1px solid rgba(99, 102, 241, 0.3);
  border-radius: 6px;
  padding: 8px 10px;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 14px;
}

.icon-btn:hover {
  background: rgba(99, 102, 241, 0.3);
  transform: scale(1.05);
}

.form-input {
  flex: 1;
  background: var(--bg-surface-2);
  border: 1px solid var(--border-main);
  border-radius: 6px;
  padding: 8px 12px;
  color: var(--text-main);
  font-size: 14px;
}

.form-input:focus {
  outline: none;
  border-color: #22c55e;
}

.form-select {
  background: var(--bg-surface-2);
  border: 1px solid var(--border-main);
  border-radius: 6px;
  padding: 8px 12px;
  color: var(--text-main);
  font-size: 14px;
}

.static-value {
  color: #22c55e;
  font-family: monospace;
}

/* 地址选择器 */
.address-selector {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid var(--border-main);
}

.selector-label {
  display: block;
  color: var(--text-muted);
  font-size: 12px;
  margin-bottom: 8px;
}

.address-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.address-chip {
  background: rgba(99, 102, 241, 0.1);
  border: 1px solid rgba(99, 102, 241, 0.2);
  border-radius: 16px;
  padding: 4px 12px;
  font-size: 12px;
  color: var(--text-main);
  cursor: pointer;
  transition: all 0.3s;
  font-family: monospace;
}

.address-chip:hover {
  background: rgba(99, 102, 241, 0.2);
  border-color: rgba(99, 102, 241, 0.4);
  transform: translateY(-1px);
}

/* 操作按钮 */
.action-btn {
  background: rgba(34, 197, 94, 0.2);
  border: 1px solid rgba(34, 197, 94, 0.3);
  border-radius: 6px;
  padding: 10px 20px;
  color: #16a34a;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 14px;
}

.action-btn:hover {
  background: rgba(34, 197, 94, 0.3);
  transform: translateY(-1px);
}

.action-btn.primary {
  background: rgba(34, 197, 94, 0.3);
  font-weight: bold;
}

.action-btn.safe {
  background: rgba(99, 102, 241, 0.2);
  border-color: rgba(99, 102, 241, 0.3);
  color: #6366f1;
}

.action-btn.safe:hover {
  background: rgba(99, 102, 241, 0.3);
}

.action-btn.small {
  padding: 6px 12px;
  font-size: 12px;
}

/* 操作标签页 */
.operation-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

.tab-btn {
  background: var(--bg-surface-2);
  border: 1px solid var(--border-main);
  border-radius: 6px;
  padding: 8px 16px;
  color: var(--text-muted);
  cursor: pointer;
  transition: all 0.3s;
}

.tab-btn:hover {
  background: rgba(249, 115, 22, 0.1);
}

.tab-btn.active {
  background: rgba(249, 115, 22, 0.2);
  border-color: rgba(249, 115, 22, 0.3);
  color: #f97316;
}

.info-tip {
  background: rgba(234, 179, 8, 0.1);
  border: 1px solid rgba(234, 179, 8, 0.3);
  border-radius: 6px;
  padding: 8px 12px;
  font-size: 12px;
  color: #ca8a04;
}

.current-approval {
  font-size: 12px;
  color: var(--text-muted);
  margin-top: 8px;
}

/* 追踪结果 */
.tracker-result {
  margin-top: 16px;
  padding: 16px;
  background: var(--bg-surface-2);
  border-radius: 8px;
  border: 1px solid var(--border-main);
}

.result-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--border-main);
}

.result-address {
  font-family: monospace;
  color: #6366f1;
}

.result-balance {
  color: #16a34a;
  font-weight: bold;
}

.token-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.token-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px;
  background: rgba(99, 102, 241, 0.05);
  border-radius: 6px;
  border: 1px solid rgba(99, 102, 241, 0.1);
}

.token-icon {
  font-size: 20px;
}

.token-id {
  color: var(--text-main);
  font-weight: bold;
}

/* 弹窗 - 从下方弹出 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: flex-end;
  justify-content: center;
  z-index: 1000;
  padding-bottom: 40px;
}

.modal-content {
  background: var(--bg-surface-1);
  border: 1px solid var(--border-main);
  border-radius: 12px 12px 0 0;
  width: 90%;
  max-width: 500px;
  max-height: 50vh;
  overflow: hidden;
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(100%);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-main);
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(168, 85, 247, 0.1) 100%);
}

.modal-header h3 {
  margin: 0;
  color: var(--text-main);
}

.close-btn {
  background: none;
  border: none;
  color: var(--text-muted);
  font-size: 24px;
  cursor: pointer;
  transition: color 0.2s;
}

.close-btn:hover {
  color: var(--accent-red);
}

.nft-details {
  padding: 20px;
}

.detail-row {
  display: flex;
  margin-bottom: 12px;
  padding: 10px 12px;
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.05) 0%, rgba(168, 85, 247, 0.05) 100%);
  border-radius: 8px;
  border: 1px solid rgba(99, 102, 241, 0.1);
}

.detail-label {
  min-width: 100px;
  color: var(--text-muted);
  font-weight: 500;
}

.detail-value {
  color: var(--text-main);
  word-break: break-all;
  font-family: monospace;
  font-size: 13px;
}

.detail-value.uri {
  color: #6366f1;
}

</style>
