<template>
  <div v-if="showUnlockArea" class="right-column">
    <!-- 提示气泡 -->
    <div class="hint-bubble">
      <h4>💡 交互提示</h4>
      <p>{{ hintText || remainingConceptsGuide }}</p>
    </div>

    <!-- 解锁新知识 -->
    <div class="knowledge-unlock">
      <h4>🎉 恭喜解锁新知识！</h4>
      <span class="unlock-badge">{{ unlockBadge }}</span>
      <p>{{ unlockText }}</p>
      <div v-if="currentConceptCode" class="code-snippet">
        <pre>{{ currentConceptCode }}</pre>
      </div>
      
      <!-- 已解锁概念列表 -->
      <div class="concept-list">
        <div
          v-for="conceptKey in unlockedConcepts"
          :key="conceptKey"
          class="concept-badge"
          :class="{ active: selectedConcept === conceptKey }"
          @click="handleConceptClick(conceptKey)"
        >
          <span class="check-icon">✓</span>
          <span class="badge-content">{{ getConceptBadge(conceptKey) }}</span>
        </div>
      </div>
      
      <!-- Day 13 额外学习提示 -->
      <div v-if="currentDay === 13 && allConceptsUnlocked" class="extra-learning-tip">
        <div class="tip-icon">🎯</div>
        <div class="tip-content">
          <div class="tip-title">知识点已解锁，但学习不止于此！</div>
          <div class="tip-desc">
            虽然你已经掌握了 Day 13 的所有核心概念，但建议你继续尝试下方的<strong>授权</strong>和<strong>代转账</strong>操作。
            这些操作能帮助你更深入地理解 ERC20 的授权机制，这在实际 DeFi 应用中非常重要！
          </div>
        </div>
      </div>

      <button v-if="allConceptsUnlocked" class="view-full-code-btn" @click="showFullCode">
        📖 查看完整代码
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useConceptInteraction } from '@/composables/useConceptInteraction'
import { conceptDefinitions, getHint, getConceptExplanationHint, day11ConceptDefinitions, getDay11ExplanationHint, day12ConceptDefinitions, getDay12Hint, getDay12ExplanationHint, day13ConceptDefinitions, getDay13ExplanationHint, day14ConceptDefinitions, getDay14Hint, getDay14ExplanationHint, day15ConceptDefinitions, getDay15Hint, getDay15ExplanationHint, day16ConceptDefinitions, getDay16Hint, getDay16ExplanationHint, day17ConceptDefinitions, getDay17Hint, getDay17ExplanationHint, day18ConceptDefinitions, getDay18Hint, getDay18ExplanationHint, day19ConceptDefinitions, getDay19Hint, getDay19ExplanationHint, day20ConceptDefinitions, getDay20Hint, getDay20ExplanationHint, day21ConceptDefinitions, getDay21Hint, getDay21ExplanationHint } from '@/data/concepts'

const props = defineProps({
  // 当前Day编号
  currentDay: {
    type: Number,
    required: true
  },
  // 已解锁概念列表
  unlockedConcepts: {
    type: Array,
    required: true
  },
  // 进度百分比
  progressPercentage: {
    type: Number,
    default: 0
  },
  // 完整代码内容
  fullCode: {
    type: String,
    default: ''
  },
  // 外部传入的提示文本（可选，优先级高于自动生成的提示）
  customHint: {
    type: String,
    default: ''
  }
})

const emit = defineEmits([
  'show-full-code',
  'concept-change'
])

// 用户手动选择的概念 key（null 表示显示最新解锁的概念）
const manualConceptKey = ref(null)

// 更新当前显示的概念
const updateCurrentConcept = (conceptKey) => {
  manualConceptKey.value = conceptKey
  emit('concept-change', conceptKey)
}

// 使用概念交互 composable
const {
  selectedConcept,
  handleConceptClick,
  getConceptBadge
} = useConceptInteraction(updateCurrentConcept, props.currentDay)

// 是否显示解锁区域
const showUnlockArea = computed(() => props.unlockedConcepts.length > 0 || props.customHint)

// 是否所有概念都已解锁
const allConceptsUnlocked = computed(() => props.progressPercentage === 100)

// 未解锁概念的指引提示（支持 Day 11 和 Day 12）
const remainingConceptsGuide = computed(() => {
  if (props.currentDay === 11) {
    const allConcepts = ['inheritance', 'import_statement', 'event_logging',
                         'constructor', 'private_visibility', 'transfer_ownership',
                         'indexed_parameter', 'onlyOwner_modifier']
    const unlocked = props.unlockedConcepts
    const remaining = allConcepts.filter(c => !unlocked.includes(c))
    
    // 根据剩余概念返回对应的解锁指引
    const guides = []
    if (remaining.includes('onlyOwner_modifier')) {
      guides.push('👉 切换到"用户"身份，尝试提取资金，体验权限控制！')
    }
    if (remaining.includes('transfer_ownership') || remaining.includes('indexed_parameter')) {
      guides.push('👉 以所有者身份转移所有权，学习所有权机制！')
    }
    if (remaining.includes('import_statement') || remaining.includes('event_logging')) {
      guides.push('👉 存入 ETH 来触发事件，了解导入和事件日志！')
    }
    if (remaining.includes('inheritance') || remaining.includes('constructor')) {
      guides.push('👉 点击查看当前所有者，了解合约继承和构造函数！')
    }
    
    return guides.join('\n')
  }
  
  if (props.currentDay === 12) {
    const allConcepts = ['erc20_standard', 'mapping_nested', 'event', 'transfer', 'approve', 'allowance', 'transferFrom']
    const unlocked = props.unlockedConcepts
    const remaining = allConcepts.filter(c => !unlocked.includes(c))
    
    // 根据剩余概念返回对应的解锁指引
    const guides = []
    if (remaining.includes('erc20_standard')) {
      guides.push('👉 点击代币信息区块了解 ERC20 标准！')
    }
    if (remaining.includes('mapping_nested')) {
      guides.push('👉 查询 Alice 余额来学习 mapping 存储机制！')
    }
    if (remaining.includes('event') || remaining.includes('transfer')) {
      guides.push('👉 转账给 Bob 来学习事件和转账函数！')
    }
    if (remaining.includes('approve')) {
      guides.push('👉 授权给 Carol 来学习授权机制！')
    }
    if (remaining.includes('allowance')) {
      guides.push('👉 查询授权额度来学习 allowance 查询！')
    }
    if (remaining.includes('transferFrom')) {
      guides.push('👉 切换到 Carol 执行代转账来学习 transferFrom！')
    }
    
    return guides.join('\n')
  }
  
  // Day 13 剩余概念指引
  if (props.currentDay === 13) {
    const allConcepts = ['constructor_mint', 'zero_address_mint', 'internal_function', 'virtual_function']
    const unlocked = props.unlockedConcepts
    const remaining = allConcepts.filter(c => !unlocked.includes(c))

    const guides = []
    if (remaining.includes('internal_function') || remaining.includes('virtual_function')) {
      guides.push('👉 执行一次转账操作来解锁 internal 和 virtual 函数！')
    }
    if (remaining.includes('constructor_mint') || remaining.includes('zero_address_mint')) {
      guides.push('👉 点击代币信息卡片来了解构造函数铸造和零地址！')
    }

    return guides.join('\n')
  }

  // Day 17 剩余概念指引
  if (props.currentDay === 17) {
    const allConcepts = ['proxy_pattern', 'delegatecall', 'storage_layout',
                         'upgrade_mechanism', 'logic_contract', 'fallback_function',
                         'data_persistence', 'version_control']
    const unlocked = props.unlockedConcepts
    const remaining = allConcepts.filter(c => !unlocked.includes(c))

    const guides = []
    if (remaining.includes('proxy_pattern')) {
      guides.push('👉 点击合约架构图，了解代理模式！')
    }
    if (remaining.includes('delegatecall')) {
      guides.push('👉 点击 delegatecall 说明按钮学习委托调用！')
    }
    if (remaining.includes('storage_layout')) {
      guides.push('👉 点击存储布局说明按钮了解存储布局！')
    }
    if (remaining.includes('upgrade_mechanism') || remaining.includes('logic_contract')) {
      guides.push('👉 创建至少2个计划后升级到 V2 来解锁升级机制！')
    }
    if (remaining.includes('fallback_function')) {
      guides.push('👉 切换到 User 身份执行订阅来解锁回退函数！')
    }
    if (remaining.includes('data_persistence')) {
      guides.push('👉 升级后查询订阅状态来验证数据持久化！')
    }
    if (remaining.includes('version_control')) {
      guides.push('👉 使用 V2 的暂停/恢复功能来体验版本控制！')
    }

    return guides.join('\n')
  }

  return ''
})

// 获取概念定义（支持 Day 11、Day 12、Day 13、Day 14、Day 15 和其他天数）
const getConceptDefinition = (key) => {
  if (props.currentDay === 11) {
    return day11ConceptDefinitions[key]
  }
  if (props.currentDay === 12) {
    return day12ConceptDefinitions[key]
  }
  if (props.currentDay === 13) {
    return day13ConceptDefinitions[key]
  }
  if (props.currentDay === 14) {
    return day14ConceptDefinitions[key]
  }
  if (props.currentDay === 15) {
    return day15ConceptDefinitions[key]
  }
  if (props.currentDay === 16) {
    return day16ConceptDefinitions[key]
  }
  if (props.currentDay === 17) {
    return day17ConceptDefinitions[key]
  }
  if (props.currentDay === 18) {
    return day18ConceptDefinitions[key]
  }
  if (props.currentDay === 19) {
    return day19ConceptDefinitions[key]
  }
  if (props.currentDay === 20) {
    return day20ConceptDefinitions[key]
  }
  if (props.currentDay === 21) {
    return day21ConceptDefinitions[key]
  }
  return conceptDefinitions[key]
}

// 当前显示的概念（如果用户手动选择了概念则显示选中的，否则显示最新的）
const currentConcept = computed(() => {
  if (props.unlockedConcepts.length === 0) return null

  // 如果用户手动选择了概念，显示选中的概念
  if (manualConceptKey.value) {
    return {
      key: manualConceptKey.value,
      ...getConceptDefinition(manualConceptKey.value)
    }
  }

  // 否则显示最新解锁的概念
  const latestKey = props.unlockedConcepts[props.unlockedConcepts.length - 1]
  return {
    key: latestKey,
    ...getConceptDefinition(latestKey)
  }
})

// 获取概念解释（支持 Day 11、Day 12、Day 13 和其他天数）
const getConceptHint = (key) => {
  if (props.currentDay === 11) {
    return getDay11ExplanationHint(key)
  }
  if (props.currentDay === 12) {
    return getDay12ExplanationHint(key)
  }
  if (props.currentDay === 13) {
    return getDay13ExplanationHint(key)
  }
  if (props.currentDay === 14) {
    return getDay14ExplanationHint(key)
  }
  if (props.currentDay === 15) {
    return getDay15ExplanationHint(key)
  }
  if (props.currentDay === 16) {
    return getDay16ExplanationHint(key)
  }
  if (props.currentDay === 17) {
    return getDay17ExplanationHint(key)
  }
  if (props.currentDay === 18) {
    return getDay18ExplanationHint(key)
  }
  if (props.currentDay === 19) {
    return getDay19ExplanationHint(key)
  }
  if (props.currentDay === 20) {
    return getDay20ExplanationHint(key)
  }
  return getConceptExplanationHint(key)
}

// 获取下一步提示（仅 Day 11）
const getNextStepHint = (conceptKey) => {
  if (props.currentDay !== 11) return ''
  
  const hints = {
    inheritance: '📦 太棒了！你看到 VaultMaster 继承了 Ownable 的功能！👉 存入 ETH 来学习 import 机制！',
    constructor: '🏗️ 太棒了！你了解了构造函数！👉 存入 ETH 来学习导入语句和私有变量！',
    import_statement: '📥 不错！你了解了导入语句！👉 继续存入 ETH 来学习事件日志和私有变量！',
    event_logging: '📋 很好！你触发了事件日志！👉 尝试转移所有权来解锁更多概念！',
    private_visibility: '🔒 优秀！你学会了 private 变量的使用！👉 尝试转移所有权来学习所有权机制！',
    transfer_ownership: '🔑 很好！你了解了所有权转移！👉 尝试以用户身份提取来学习修饰符！',
    indexed_parameter: '🏷️ 不错！你了解了索引参数！👉 切换到用户身份体验权限控制！',
    onlyOwner_modifier: '🛡️ 太棒了！你了解了 onlyOwner 修饰符！👉 查看完整代码来巩固所有知识！'
  }
  return hints[conceptKey] || ''
}

// 提示文本
const hintText = computed(() => {
  // 优先级 1: Day 11 显示最新解锁概念的下一步提示
  if (props.currentDay === 11 && currentConcept.value && !manualConceptKey.value) {
    return getNextStepHint(currentConcept.value.key)
  }
  
  // 优先级 2: Day 12 显示下一步提示
  if (props.currentDay === 12 && currentConcept.value && !manualConceptKey.value) {
    return getDay12Hint(currentConcept.value.key)
  }
  
  // 优先级 3: Day 13 显示下一步提示
  if (props.currentDay === 13 && currentConcept.value && !manualConceptKey.value) {
    const hints = {
      constructor_mint: '🪙 太棒了！你了解了构造函数铸造机制！👉 点击代币信息卡片了解零地址含义！',
      zero_address_mint: '📍 优秀！你了解了零地址的特殊含义！👉 执行转账操作来解锁 internal 和 virtual 函数！',
      internal_function: '🔒 太棒了！你了解了 internal 函数！转账操作同时解锁了 virtual 关键字！👉 点击查看完整代码了解所有知识点！',
      virtual_function: '🧬 恭喜你！你了解了 virtual 关键字！🎉 你已掌握 Day 13 的所有核心概念！点击查看完整代码回顾所有知识！'
    }
    return hints[currentConcept.value.key] || getConceptHint(currentConcept.value.key)
  }

  // 优先级 4: Day 14 显示下一步提示
  if (props.currentDay === 14 && currentConcept.value && !manualConceptKey.value) {
    return getDay14Hint(currentConcept.value.key)
  }

  // 优先级 5: Day 15 显示下一步提示
  if (props.currentDay === 15 && currentConcept.value && !manualConceptKey.value) {
    return getDay15Hint(currentConcept.value.key)
  }

  // 优先级 6: Day 16 显示下一步提示
  if (props.currentDay === 16 && currentConcept.value && !manualConceptKey.value) {
    return getDay16Hint(currentConcept.value.key)
  }

  // 优先级 6: Day 17 显示下一步提示
  if (props.currentDay === 17 && currentConcept.value && !manualConceptKey.value) {
    return getDay17Hint(currentConcept.value.key)
  }

  // 优先级 6: Day 18 显示下一步提示
  if (props.currentDay === 18 && currentConcept.value && !manualConceptKey.value) {
    return getDay18Hint(currentConcept.value.key)
  }

  // 优先级 6: Day 19 显示下一步提示
  if (props.currentDay === 19 && currentConcept.value && !manualConceptKey.value) {
    return getDay19Hint(currentConcept.value.key)
  }

  // 优先级 6: Day 20 显示下一步提示
  if (props.currentDay === 20 && currentConcept.value && !manualConceptKey.value) {
    return getDay20Hint(currentConcept.value.key)
  }

  // 优先级 6: Day 21 显示下一步提示
  if (props.currentDay === 21 && currentConcept.value && !manualConceptKey.value) {
    return getDay21Hint(currentConcept.value.key)
  }

  // 优先级 7: 用户手动点击概念标签，显示详细解释
  if (manualConceptKey.value && currentConcept.value) {
    // Day 11、12、13、14、15、16、17、18、19、20 使用专门的解释提示函数
    if (props.currentDay === 11) return getDay11ExplanationHint(currentConcept.value.key)
    if (props.currentDay === 12) return getDay12ExplanationHint(currentConcept.value.key)
    if (props.currentDay === 13) return getDay13ExplanationHint(currentConcept.value.key)
    if (props.currentDay === 14) return getDay14ExplanationHint(currentConcept.value.key)
    if (props.currentDay === 15) return getDay15ExplanationHint(currentConcept.value.key)
    if (props.currentDay === 16) return getDay16ExplanationHint(currentConcept.value.key)
    if (props.currentDay === 17) return getDay17ExplanationHint(currentConcept.value.key)
    if (props.currentDay === 18) return getDay18ExplanationHint(currentConcept.value.key)
    if (props.currentDay === 19) return getDay19ExplanationHint(currentConcept.value.key)
    if (props.currentDay === 20) return getDay20ExplanationHint(currentConcept.value.key)
    if (props.currentDay === 21) return getDay21ExplanationHint(currentConcept.value.key)
    return getConceptHint(currentConcept.value.key)
  }
  
  // 优先级 6: 外部传入的自定义提示
  if (props.customHint) {
    return props.customHint
  }
  
  // 默认显示当前概念的详细解释
  return currentConcept.value ? getConceptHint(currentConcept.value.key) : ''
})

// 解锁徽章
const unlockBadge = computed(() => {
  if (!currentConcept.value) return ''
  return `${currentConcept.value.icon} ${currentConcept.value.name}`
})

// 解锁文本
const unlockText = computed(() => {
  return currentConcept.value?.message || ''
})

// 概念代码
const currentConceptCode = computed(() => {
  return currentConcept.value?.code || ''
})

// 显示完整代码
const showFullCode = () => {
  emit('show-full-code')
}
</script>

<style scoped>
.right-column {
  flex: 5;
  min-width: 0;
}

/* 提示气泡 - 与 main.css 保持一致 */
.hint-bubble {
  background: var(--bg-surface-1);
  border-left: 4px solid var(--accent-orange);
  padding: 15px 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  margin-top: 0;
  animation: slideIn 0.5s ease;
  border: 1px solid var(--border-main);
}

.hint-bubble h4 {
  color: var(--accent-orange);
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.hint-bubble p {
  margin: 0;
  color: var(--text-main);
  line-height: 1.5;
}

/* 解锁知识区域 - 与 main.css 保持一致 */
.knowledge-unlock {
  background: var(--bg-surface-1);
  border-left: 4px solid var(--accent-blue);
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  animation: fadeIn 0.5s ease;
  border: 1px solid var(--border-main);
}

.knowledge-unlock h4 {
  color: var(--accent-blue);
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.knowledge-unlock p {
  color: var(--text-main);
  line-height: 1.6;
  margin: 10px 0;
}

.unlock-badge {
  display: inline-block;
  background: var(--accent-blue);
  color: var(--bg-base);
  padding: 3px 10px;
  border-radius: 12px;
  font-size: 0.75em;
  margin-bottom: 10px;
}

.code-snippet {
  background: var(--code-bg);
  color: var(--text-muted);
  padding: 15px;
  border-radius: 6px;
  font-family: 'Courier New', monospace;
  font-size: 0.85em;
  margin-top: 10px;
  overflow-x: auto;
  line-height: 1.3;
  border: 1px solid var(--code-border);
}

.code-snippet pre {
  margin: 0;
  white-space: pre-wrap;
  word-break: break-word;
  font-family: 'Courier New', monospace;
}

/* 概念列表 - 与 main.css 保持一致 */
.concept-list {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 15px;
}

.concept-badge {
  background: var(--accent-cyan);
  color: var(--bg-base);
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 0.9em;
  display: flex;
  align-items: center;
  gap: 6px;
  animation: popIn 0.3s ease;
  transition: all 0.3s ease;
  cursor: pointer;
  border: 1px solid var(--accent-cyan);
}

.concept-badge:hover {
  background: var(--accent-blue-hover);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px var(--shadow-cyan-4);
  border-color: var(--accent-blue-hover);
}

.concept-badge.active {
  border: 2px solid var(--accent-green);
  background: var(--accent-green);
  box-shadow: 0 4px 15px var(--shadow-green-5);
}

.check-icon {
  font-size: 1.1em;
}

.badge-content {
  color: inherit;
}

/* 额外学习提示 - Day 13 专属 */
.extra-learning-tip {
  background: linear-gradient(135deg, rgba(168, 85, 247, 0.1) 0%, rgba(236, 72, 153, 0.1) 100%);
  border: 1px solid rgba(168, 85, 247, 0.3);
  border-radius: 10px;
  padding: 14px;
  margin-top: 15px;
  display: flex;
  gap: 12px;
  align-items: flex-start;
}

.extra-learning-tip .tip-icon {
  font-size: 1.5em;
  flex-shrink: 0;
}

.extra-learning-tip .tip-content {
  flex: 1;
}

.extra-learning-tip .tip-title {
  font-weight: 600;
  color: #a855f7;
  margin-bottom: 6px;
  font-size: 0.95em;
}

.extra-learning-tip .tip-desc {
  font-size: 0.85em;
  color: var(--text-secondary);
  line-height: 1.5;
}

.extra-learning-tip .tip-desc strong {
  color: #ec4899;
}

/* 查看完整代码按钮 - 与 main.css 保持一致 */
.view-full-code-btn {
  width: 100%;
  padding: 12px 20px;
  background: var(--accent-yellow);
  color: var(--bg-base);
  border: none;
  border-radius: 6px;
  font-size: 1em;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 15px;
}

.view-full-code-btn:hover {
  background: var(--accent-yellow-hover);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px var(--shadow-yellow-3);
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes popIn {
  0% {
    transform: scale(0.8);
    opacity: 0;
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}
</style>
