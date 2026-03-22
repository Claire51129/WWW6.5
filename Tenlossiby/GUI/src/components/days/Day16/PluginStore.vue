<template>
  <div class="day-16-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <div class="left-column">
        <div class="interaction-area">
          <h3>🎮 交互操作</h3>

          <!-- 合约架构可视化 -->
          <div class="architecture-section" @click="handleArchitectureClick">
            <h4 class="block-title">📦 合约架构可视化</h4>
            <div class="architecture-diagram">
              <div class="core-contract">
                <div class="contract-box core">
                  <span class="contract-name">PluginStore</span>
                  <span class="contract-type">核心合约</span>
                </div>
                <div class="storage-mappings">
                  <div class="mapping-item">
                    <span class="mapping-key">profiles</span>
                    <span class="mapping-arrow">→</span>
                    <span class="mapping-value">PlayerProfile</span>
                  </div>
                  <div class="mapping-item">
                    <span class="mapping-key">plugins</span>
                    <span class="mapping-arrow">→</span>
                    <span class="mapping-value">address</span>
                  </div>
                </div>
              </div>
              <div class="plugin-layer">
                <div 
                  v-for="(address, key) in plugins" 
                  :key="key" 
                  class="plugin-box"
                  :class="{ active: selectedPlugin === key }"
                  @click.stop="selectPlugin(key)"
                >
                  <span class="plugin-name">{{ key }}</span>
                  <span class="plugin-address">{{ shortenAddress(address) }}</span>
                </div>
                <div v-if="Object.keys(plugins).length === 0" class="plugin-placeholder">
                  🔌 暂无注册插件
                </div>
              </div>
            </div>
            <div class="click-prompt">👆 点击了解结构体定义</div>
          </div>

          <!-- 玩家资料管理 -->
          <div class="profile-section">
            <h4 class="block-title">👤 玩家资料管理</h4>
            <div class="current-profile" v-if="currentProfile.name">
              <div class="profile-info">
                <span class="profile-avatar">{{ currentProfile.avatar }}</span>
                <div class="profile-details">
                  <div class="profile-name">{{ currentProfile.name }}</div>
                  <div class="profile-address">{{ shortenAddress(currentUser) }}</div>
                </div>
              </div>
            </div>
            <div class="profile-form">
              <div class="input-row">
                <input
                  v-model="profileName"
                  type="text"
                  placeholder="玩家名称"
                  class="text-input"
                  maxlength="20"
                />
                <input
                  v-model="profileAvatar"
                  type="text"
                  placeholder="头像标识"
                  class="text-input small"
                  maxlength="10"
                />
              </div>
              <div class="button-row">
                <button @click="generateRandomAvatar" class="day-action-btn cyan">
                  🎲 随机头像
                </button>
                <button @click="handleSetProfile" class="day-action-btn blue">
                  💾 保存资料
                </button>
              </div>
            </div>
          </div>

          <!-- 插件管理中心 -->
          <div class="plugin-registry-section">
            <h4 class="block-title">🔌 插件管理中心</h4>
            
            <!-- 注册新插件 -->
            <div class="function-block">
              <code class="function-signature">函数：registerPlugin(string key, address pluginAddress)</code>
              <h5>➕ 注册新插件</h5>
              <div class="input-row spaced">
                <select v-model="newPluginKey" class="select-input">
                  <option value="">选择插件类型</option>
                  <option value="weapon">weapon - 武器插件</option>
                  <option value="achievement">achievement - 成就插件</option>
                  <option value="custom">custom - 自定义</option>
                </select>
                <input
                  v-if="newPluginKey === 'custom'"
                  v-model="customPluginKey"
                  type="text"
                  placeholder="自定义标识"
                  class="text-input"
                />
                <input
                  v-model="newPluginAddress"
                  type="text"
                  placeholder="合约地址 (0x...)"
                  class="text-input"
                />
              </div>
              <div class="button-row">
                <button @click="handleRegisterPlugin" class="day-action-btn green">
                  ➕ 注册插件
                </button>
                <button @click="generateRandomAddress" class="day-action-btn cyan" title="随机生成地址">
                  🎲 随机地址
                </button>
              </div>
            </div>

            <!-- 已注册插件列表 -->
            <div class="registered-plugins" v-if="Object.keys(plugins).length > 0">
              <h5>📋 已注册插件 ({{ Object.keys(plugins).length }}个)</h5>
              <div class="plugin-list">
                <div 
                  v-for="(address, key) in plugins" 
                  :key="key"
                  class="plugin-list-item"
                  :class="{ active: selectedPlugin === key }"
                  @click="selectPlugin(key)"
                >
                  <div class="plugin-info">
                    <span class="plugin-key">{{ key }}</span>
                    <span class="plugin-addr">{{ shortenAddress(address) }}</span>
                  </div>
                  <div class="plugin-actions">
                    <button @click.stop="selectPlugin(key)" class="action-btn" title="选择">
                      ✅
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 插件调用演示 -->
          <div class="plugin-caller-section">
            <h4 class="block-title">⚡ 插件调用演示</h4>
            
            <!-- 调用模式选择 -->
            <div class="call-mode-selector">
              <label class="mode-option">
                <input type="radio" v-model="callMode" value="call" />
                <span class="mode-label">执行调用 (call)</span>
                <span class="mode-desc">可修改状态，消耗 Gas</span>
              </label>
              <label class="mode-option">
                <input type="radio" v-model="callMode" value="staticcall" />
                <span class="mode-label">静态调用 (staticcall)</span>
                <span class="mode-desc">只读查询，不消耗 Gas</span>
              </label>
            </div>

            <!-- 函数调用表单 -->
            <div class="function-block">
              <code class="function-signature">
                函数：{{ callMode === 'call' ? 'runPlugin(string, string, address, string)' : 'runPluginView(string, string, address)' }}
              </code>
              
              <div class="input-group">
                <label>选择插件:</label>
                <select v-model="selectedPlugin" class="select-input">
                  <option value="">选择插件</option>
                  <option v-for="(addr, key) in plugins" :key="key" :value="key">{{ key }}</option>
                </select>
              </div>

              <div class="input-group">
                <label>函数签名:</label>
                <select v-model="functionSignature" class="select-input">
                  <option value="">选择函数</option>
                  <option v-if="selectedPlugin === 'weapon'" value="setWeapon(address,string)">setWeapon(address,string)</option>
                  <option v-if="selectedPlugin === 'weapon'" value="getWeapon(address)">getWeapon(address)</option>
                  <option v-if="selectedPlugin === 'achievement'" value="setAchievement(address,string)">setAchievement(address,string)</option>
                  <option v-if="selectedPlugin === 'achievement'" value="getAchievement(address)">getAchievement(address)</option>
                  <option v-if="selectedPlugin && selectedPlugin !== 'weapon' && selectedPlugin !== 'achievement'" value="setData(address,string)">setData(address,string)</option>
                  <option v-if="selectedPlugin && selectedPlugin !== 'weapon' && selectedPlugin !== 'achievement'" value="getData(address)">getData(address)</option>
                </select>
              </div>

              <div class="input-group">
                <label>用户地址:</label>
                <input v-model="callUser" type="text" class="text-input" placeholder="0x..." />
              </div>

              <div class="input-group" v-if="callMode === 'call' && functionSignature && functionSignature.includes('string)')">
                <label>参数 (string):</label>
                <input v-model="callArgument" type="text" class="text-input" placeholder="输入参数值" />
                <div class="preset-buttons" v-if="selectedPlugin === 'weapon'">
                  <button @click="callArgument = 'Golden Axe'" class="preset-btn">🪓 Golden Axe</button>
                  <button @click="callArgument = 'Silver Sword'" class="preset-btn">⚔️ Silver Sword</button>
                  <button @click="callArgument = 'Magic Staff'" class="preset-btn">🪄 Magic Staff</button>
                </div>
                <div class="preset-buttons" v-if="selectedPlugin === 'achievement'">
                  <button @click="callArgument = 'First Victory'" class="preset-btn">🏆 First Victory</button>
                  <button @click="callArgument = 'Dragon Slayer'" class="preset-btn">🐉 Dragon Slayer</button>
                </div>
              </div>

              <button @click="handleRunPlugin" class="day-action-btn" :class="callMode === 'call' ? 'purple' : 'cyan'">
                {{ callMode === 'call' ? '▶️ 执行调用' : '👁️ 静态调用' }}
              </button>
            </div>

            <!-- ABI 编码可视化 -->
            <div class="abi-visualization" v-if="abiEncodedData">
              <h5 @click="showAbiDetails = !showAbiDetails" class="toggle-header">
                🔍 ABI 编码可视化 {{ showAbiDetails ? '▼' : '▶' }}
              </h5>
              <div v-show="showAbiDetails" class="abi-details">
                <div class="abi-breakdown">
                  <div v-for="(item, index) in abiEncodedData" :key="index" class="abi-item" :class="item.type">
                    <div class="abi-item-header">
                      <span class="abi-type">{{ item.desc }}</span>
                      <span class="abi-detail" v-if="item.detail">{{ item.detail }}</span>
                    </div>
                    <div class="abi-value">{{ item.value }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 操作日志 -->
          <div class="event-log-section">
            <h4 class="block-title">📜 操作日志</h4>
            <div class="log-entries">
              <div v-for="(log, index) in operationLogs" :key="index" class="log-entry" :class="log.type">
                <div class="log-header">
                  <span class="log-time">{{ log.time }}</span>
                  <span class="log-type">{{ log.typeName }}</span>
                </div>
                <div class="log-content">
                  <div class="log-action">
                    <span class="log-icon">{{ getLogTypeIcon(log.type) }}</span>
                    <span class="log-text">{{ log.operation }}</span>
                  </div>
                  <div class="log-details" v-if="log.details">{{ log.details }}</div>
                </div>
              </div>
              <div v-if="operationLogs.length === 0" class="empty-log">
                暂无操作记录
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧：知识面板 -->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="16"
          :unlocked-concepts="unlockedConcepts"
          :progress-percentage="progressPercentage"
          :full-code="fullCode"
          :custom-hint="currentHint"
          @concept-click="handleConceptClick"
          @show-full-code="showFullCode = true"
        />
      </div>
    </div>

    <!-- 消息提示 -->
    <div v-if="message" class="message-toast" :class="{ error: isError }">
      {{ message }}
    </div>

    <!-- 完整代码弹窗 -->
    <FullCodeModal
      :show="showFullCode"
      :code="getFullCode(16)"
      title="Day 16 - 插件存储系统"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'
import { useDay16 } from '@/composables/useDay16'

const progressStore = useProgressStore()
const logStore = useOperationLogStore()

const {
  profiles,
  plugins,
  pluginCounter,
  currentUser,
  pluginData,
  interactedPlugins,
  predefinedPlugins,
  setProfile,
  getProfile,
  registerPlugin,
  getPlugin,
  runPlugin,
  runPluginView,
  getPluginData,
  encodeFunctionCall,
  unlockConcept,
  shortenAddress,
  realtimeData
} = useDay16()

// 本地状态
const profileName = ref('')
const profileAvatar = ref('')
const newPluginKey = ref('')
const customPluginKey = ref('')
const newPluginAddress = ref('')
const selectedPlugin = ref('')
const callMode = ref('call')
const functionSignature = ref('')
const callUser = ref(currentUser.value)
const callArgument = ref('')
const abiEncodedData = ref(null)
const showAbiDetails = ref(false)
const currentHint = ref('')
const message = ref('')
const isError = ref(false)
const showFullCode = ref(false)

// 计算属性
const unlockedConcepts = computed(() =>
  progressStore.getDayProgress(16)?.unlockedConcepts || []
)

const currentProfile = computed(() => {
  return profiles.value[currentUser.value] || { name: '', avatar: '' }
})

const operationLogs = computed(() => {
  return logStore.getDayLogs(16).slice(-10).reverse()
})

// 进度百分比
const progressPercentage = computed(() => {
  const progress = progressStore.getDayProgress(16)
  if (!progress || progress.totalConcepts === 0) return 0
  return Math.round((progress.unlockedConcepts.length / progress.totalConcepts) * 100)
})

// 完整代码
const fullCode = computed(() => getFullCode(16))

// 方法
const showMessage = (msg, error = false) => {
  message.value = msg
  isError.value = error
  setTimeout(() => {
    message.value = ''
  }, 5000)
}

const generateRandomAvatar = () => {
  const avatars = ['🎮', '👾', '🤖', '👽', '🎭', '🎪', '🎯', '🎲', '🎸', '🎺']
  profileAvatar.value = avatars[Math.floor(Math.random() * avatars.length)]
}

const generateRandomAddress = () => {
  const chars = '0123456789abcdef'
  let address = '0x'
  for (let i = 0; i < 40; i++) {
    address += chars[Math.floor(Math.random() * chars.length)]
  }
  newPluginAddress.value = address
}

const handleArchitectureClick = () => {
  if (!unlockedConcepts.value.includes('struct_definition')) {
    unlockConcept('struct_definition')
    currentHint.value = '🏗️ 你发现了 PlayerProfile 结构体！👉 尝试设置玩家资料来解锁映射存储！'
    showMessage('✅ 解锁「结构体定义」知识点！')
  }
}

const handleSetProfile = () => {
  const result = setProfile(profileName.value, profileAvatar.value)
  
  if (result.success) {
    if (result.hints) {
      result.hints.forEach(hint => unlockConcept(hint))
    }
    currentHint.value = result.nextStep
    showMessage(result.message)
    profileName.value = ''
    profileAvatar.value = ''
  } else {
    showMessage(result.message, true)
    currentHint.value = result.nextStep
  }
}

const handleRegisterPlugin = () => {
  const key = newPluginKey.value === 'custom' ? customPluginKey.value : newPluginKey.value
  const address = newPluginAddress.value || predefinedPlugins[newPluginKey.value]
  
  if (!address && newPluginKey.value !== 'custom') {
    // 使用预设地址
    const result = registerPlugin(key, predefinedPlugins[newPluginKey.value])
    handleRegisterResult(result)
  } else {
    const result = registerPlugin(key, address)
    handleRegisterResult(result)
  }
}

const handleRegisterResult = (result) => {
  if (result.success) {
    if (result.hints) {
      result.hints.forEach(hint => unlockConcept(hint))
    }
    currentHint.value = result.nextStep
    showMessage(result.message)
    
    // 将注册的插件地址同步到调用用户地址
    const registeredAddress = result.registeredAddress || newPluginAddress.value
    if (registeredAddress) {
      callUser.value = registeredAddress
    }
    
    newPluginKey.value = ''
    customPluginKey.value = ''
    newPluginAddress.value = ''
  } else {
    showMessage(result.message, true)
    currentHint.value = result.nextStep
  }
}

const selectPlugin = (key) => {
  selectedPlugin.value = key
}

const handleRunPlugin = () => {
  if (callMode.value === 'call') {
    const result = runPlugin(selectedPlugin.value, functionSignature.value, callUser.value, callArgument.value)
    handleRunResult(result)
  } else {
    const result = runPluginView(selectedPlugin.value, functionSignature.value, callUser.value)
    handleRunResult(result)
  }
}

const handleRunResult = (result) => {
  if (result.success) {
    if (result.hints) {
      result.hints.forEach(hint => unlockConcept(hint))
    }
    currentHint.value = result.nextStep
    showMessage(result.message)
    
    // 显示 ABI 编码
    if (result.encoded) {
      abiEncodedData.value = result.encoded
      showAbiDetails.value = true
    }
    
    // 清空参数
    callArgument.value = ''
  } else {
    showMessage(result.message, true)
    currentHint.value = result.nextStep
  }
}

const handleConceptClick = (conceptKey) => {
  // 概念点击处理
}

const getLogTypeIcon = (type) => {
  const icons = {
    'write': '⚡',
    'read': '👁️',
    'register': '🔌'
  }
  return icons[type] || '📝'
}

onMounted(() => {
  // 初始化
  callUser.value = currentUser.value
})
</script>

<style scoped>
.day-16-content {
  padding: 12px;
}

/* 布局样式已迁移到 day-common.css */

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

.block-title {
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 12px 0;
  color: var(--text-primary);
}

/* 架构可视化 */
.architecture-section {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.08) 0%, rgba(139, 92, 246, 0.08) 100%);
  border: 1px solid var(--border-main);
  border-radius: 10px;
  padding: 16px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.architecture-section:hover {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.12) 0%, rgba(139, 92, 246, 0.12) 100%);
  border-color: var(--accent-blue);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
}

.architecture-diagram {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.core-contract {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.contract-box {
  background: rgba(59, 130, 246, 0.15);
  border: 2px solid #3b82f6;
  color: var(--text-primary);
  padding: 16px 32px;
  border-radius: 10px;
  text-align: center;
}

.contract-box.core {
  background: rgba(59, 130, 246, 0.2);
  border-color: #3b82f6;
}

.contract-name {
  display: block;
  font-size: 1.2rem;
  font-weight: bold;
}

.contract-type {
  display: block;
  font-size: 0.8rem;
  opacity: 0.9;
  margin-top: 4px;
}

.storage-mappings {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  justify-content: center;
}

.mapping-item {
  background: var(--bg-base);
  border: 1px solid var(--border-secondary);
  padding: 8px 12px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
}

.mapping-key {
  color: var(--accent-orange);
  font-family: monospace;
}

.mapping-arrow {
  color: var(--text-muted);
}

.mapping-value {
  color: var(--accent-green);
  font-family: monospace;
}

.plugin-layer {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: center;
  padding-top: 16px;
  border-top: 2px dashed var(--border-color);
}

.plugin-box {
  background: var(--bg-base);
  border: 2px solid var(--border-color);
  border-radius: 8px;
  padding: 12px 16px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 120px;
}

.plugin-box:hover,
.plugin-box.active {
  border-color: var(--accent-green);
  background: rgba(16, 185, 129, 0.08);
}

.plugin-name {
  display: block;
  font-weight: 600;
  color: var(--text-primary);
}

.plugin-address {
  display: block;
  font-size: 0.75rem;
  color: var(--text-secondary);
  font-family: monospace;
  margin-top: 4px;
}

.plugin-placeholder {
  color: var(--text-secondary);
  font-style: italic;
  padding: 20px;
}

.click-prompt {
  text-align: center;
  color: #3b82f6;
  font-size: 0.85rem;
  margin-top: 12px;
  font-weight: 500;
}

/* 玩家资料 */
.profile-section {
  background: var(--bg-surface-1);
  border: 1px solid var(--border-main);
  border-radius: 10px;
  padding: 16px;
  margin-bottom: 12px;
}

.current-profile {
  margin-bottom: 16px;
  padding: 12px;
  background: rgba(59, 130, 246, 0.08);
  border-radius: 8px;
}

.profile-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.profile-avatar {
  font-size: 2rem;
}

.profile-details {
  flex: 1;
}

.profile-name {
  font-weight: 600;
  color: var(--text-primary);
}

.profile-address {
  font-size: 0.8rem;
  color: var(--text-secondary);
  font-family: monospace;
}

.profile-form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.input-row {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.input-row.spaced {
  margin-bottom: 16px;
}

.text-input {
  flex: 1;
  min-width: 120px;
  padding: 10px 12px;
  border: 1px solid var(--border-main);
  border-radius: 6px;
  background: var(--bg-base);
  color: var(--text-primary);
  font-size: 0.9rem;
}

.text-input.small {
  flex: 0.5;
  min-width: 80px;
}

.select-input {
  flex: 1;
  min-width: 150px;
  padding: 10px 12px;
  border: 1px solid var(--border-main);
  border-radius: 6px;
  background: var(--bg-base);
  color: var(--text-primary);
  font-size: 0.9rem;
}

/* 插件管理 */
.plugin-registry-section {
  background: var(--bg-surface-1);
  border: 1px solid var(--border-main);
  border-radius: 10px;
  padding: 16px;
  margin-bottom: 12px;
}

.function-block {
  background: var(--bg-base);
  border: 1px solid var(--border-secondary);
  border-radius: 8px;
  padding: 14px;
  margin-bottom: 16px;
}

.function-signature {
  display: block;
  background: var(--bg-surface-2);
  padding: 6px 12px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 0.85em;
  color: var(--text-primary);
  margin: 0 0 15px 0;
  border-left: 3px solid var(--accent-blue);
  line-height: 1.4;
}

.function-block h5 {
  margin: 0 0 12px 0;
  color: var(--text-primary);
}

.input-group {
  margin-bottom: 12px;
}

.input-group label {
  display: block;
  margin-bottom: 6px;
  color: var(--text-secondary);
  font-size: 0.85rem;
}

.registered-plugins {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--border-color);
}

.registered-plugins h5 {
  margin: 0 0 12px 0;
  color: var(--text-primary);
}

.plugin-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.plugin-list-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 12px;
  background: var(--bg-base);
  border: 1px solid var(--border-secondary);
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.plugin-list-item:hover,
.plugin-list-item.active {
  border-color: var(--accent-blue);
  background: rgba(59, 130, 246, 0.08);
}

.plugin-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.plugin-key {
  font-weight: 600;
  color: var(--text-primary);
}

.plugin-addr {
  font-size: 0.8rem;
  color: var(--text-secondary);
  font-family: monospace;
}

.plugin-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  background: transparent;
  border: 1px solid var(--border-color);
  border-radius: 4px;
  padding: 4px 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s ease;
}

.action-btn:hover {
  background: rgba(59, 130, 246, 0.15);
  border-color: var(--accent-blue);
}

/* 插件调用 */
.plugin-caller-section {
  background: var(--bg-surface-1);
  border: 1px solid var(--border-main);
  border-radius: 10px;
  padding: 16px;
  margin-bottom: 12px;
}

.call-mode-selector {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
  flex-wrap: wrap;
}

.mode-option {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  background: var(--bg-base);
  border: 2px solid var(--border-secondary);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  flex: 1;
  min-width: 200px;
}

.mode-option:hover {
  border-color: var(--accent-blue);
}

.mode-option input[type="radio"] {
  margin: 0;
}

.mode-label {
  font-weight: 600;
  color: var(--text-primary);
  display: block;
}

.mode-desc {
  font-size: 0.8rem;
  color: var(--text-secondary);
  display: block;
  margin-top: 2px;
}

.preset-buttons {
  display: flex;
  gap: 8px;
  margin-top: 8px;
  flex-wrap: wrap;
}

.preset-btn {
  background: rgba(59, 130, 246, 0.08);
  border: 1px solid var(--accent-blue);
  border-radius: 4px;
  padding: 4px 10px;
  color: var(--accent-blue);
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.preset-btn:hover {
  background: var(--accent-blue);
  color: white;
}

/* ABI 可视化 */
.abi-visualization {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--border-main);
}

.toggle-header {
  margin: 0;
  padding: 10px;
  background: rgba(139, 92, 246, 0.08);
  border-radius: 6px;
  cursor: pointer;
  color: var(--accent-purple);
  font-weight: 500;
  transition: all 0.2s ease;
}

.toggle-header:hover {
  background: rgba(139, 92, 246, 0.12);
}

.abi-details {
  margin-top: 12px;
}

.abi-breakdown {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.abi-item {
  background: var(--bg-base);
  border-radius: 6px;
  padding: 10px;
  border-left: 3px solid;
}

.abi-item.selector {
  border-left-color: var(--accent-orange);
}

.abi-item.address {
  border-left-color: var(--accent-blue);
}

.abi-item.offset {
  border-left-color: var(--accent-green);
}

.abi-item.length {
  border-left-color: var(--accent-pink);
}

.abi-item.data {
  border-left-color: var(--accent-purple);
}

.abi-item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}

.abi-type {
  font-weight: 600;
  color: var(--text-primary);
  font-size: 0.85rem;
}

.abi-detail {
  font-size: 0.75rem;
  color: var(--text-secondary);
  font-family: monospace;
}

.abi-value {
  font-family: monospace;
  font-size: 0.8rem;
  color: var(--accent-green);
  word-break: break-all;
  background: var(--bg-surface-2);
  padding: 6px;
  border-radius: 4px;
}

/* 事件日志 */
.event-log-section {
  background: var(--bg-surface-1);
  border: 1px solid var(--border-main);
  border-radius: 10px;
  padding: 16px;
}

.log-entries {
  max-height: 300px;
  overflow-y: auto;
}

.log-entry {
  padding: 10px;
  border-bottom: 1px solid var(--border-secondary);
  font-size: 0.85rem;
}

.log-entry:last-child {
  border-bottom: none;
}

.log-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 6px;
}

.log-time {
  color: var(--text-secondary);
  font-size: 0.75rem;
}

.log-type {
  color: var(--accent-blue);
  font-weight: 500;
}

.log-action {
  color: var(--text-primary);
  font-weight: 500;
  margin-bottom: 4px;
}

.log-details {
  padding-left: 12px;
  color: var(--text-secondary);
  font-size: 0.8rem;
  font-family: monospace;
}

.empty-log {
  text-align: center;
  color: var(--text-secondary);
  padding: 20px;
  font-style: italic;
}

/* 消息提示 */
.message-toast {
  position: fixed;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 500;
  z-index: 1000;
  animation: slideUp 0.3s ease;
  background: #10b981;
  color: white;
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

/* 按钮样式 */
.day-action-btn {
  padding: 10px 20px;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 0.9rem;
}

.day-action-btn.blue {
  background: var(--accent-blue);
  color: white;
}

.day-action-btn.blue:hover {
  background: #2563eb;
}

.day-action-btn.green {
  background: var(--accent-green);
  color: white;
}

.day-action-btn.green:hover {
  background: #059669;
}

.day-action-btn.cyan {
  background: #06b6d4;
  color: white;
}

.day-action-btn.cyan:hover {
  background: #0891b2;
}

.day-action-btn.purple {
  background: #a855f7;
  color: white;
}

.day-action-btn.purple:hover {
  background: #9333ea;
}

.day-action-btn.small {
  padding: 6px 12px;
  font-size: 0.85rem;
}

/* 响应式 */
@media (max-width: 768px) {
  /* 响应式布局已迁移到 day-common.css */
}
</style>
