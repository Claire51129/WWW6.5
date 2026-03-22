<template>
  <div class="day-9-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <div class="left-column">
        <div class="interaction-area">
          <h3>🎮 交互操作</h3>

          <!-- 区域1: 基础计算器 -->
          <div class="function-block">
            <h4 class="block-title">🧮 基础计算器 (Pure函数)</h4>
            <code class="function-signature">函数：add/subtract/multiply/divide(uint256 a, uint256 b) public pure returns(uint256)</code>
            
            <div class="input-row">
              <div class="input-group">
                <label>输入A:</label>
                <input v-model="inputA" type="number" placeholder="输入数字">
              </div>
              <div class="input-group">
                <label>输入B:</label>
                <input v-model="inputB" type="number" placeholder="输入数字">
              </div>
            </div>

            <div class="operator-buttons">
              <button class="day-action-btn cyan" @click="handleCalculate('add')">+</button>
              <button class="day-action-btn cyan" @click="handleCalculate('subtract')">-</button>
              <button class="day-action-btn cyan" @click="handleCalculate('multiply')">×</button>
              <button class="day-action-btn cyan" @click="handleCalculate('divide')">÷</button>
            </div>

            <div v-if="basicResult !== null" class="result-box">
              <span class="result-label">结果:</span>
              <span class="result-value">{{ basicResult }}</span>
            </div>

            <div class="operation-counter">
              已完成运算: {{ operationCount }}/3 次
              <span v-if="canUnlockPure" class="unlock-hint">🎉 可解锁 pure_function 知识点!</span>
            </div>

            <div v-if="operationHistory.length > 0" class="history-box">
              <h5>运算历史</h5>
              <div v-for="(op, index) in operationHistory" :key="index" class="history-item">
                {{ op.a }} {{ getOperatorSymbol(op.operator) }} {{ op.b }} = {{ op.result }}
              </div>
            </div>
          </div>

          <!-- 区域2: 合约地址设置 -->
          <div class="function-block">
            <h4 class="block-title">🔐 合约地址设置 (onlyOwner)</h4>
            <code class="function-signature">函数：setScientificCalculator(address _address) public onlyOwner</code>

            <div class="identity-toggle-bar">
              <span class="identity-label">🎭 当前身份：</span>
              <div class="toggle-buttons">
                <button :class="{ active: !isOwner }" @click="toggleIdentity">👤 用户/User</button>
                <button :class="{ active: isOwner }" @click="toggleIdentity">👑 管理员/Owner</button>
              </div>
            </div>

            <div class="address-info">
              <div class="address-item">
                <span class="label">Owner地址:</span>
                <span class="value">{{ shortenAddress(owner) }}</span>
              </div>
              <div class="address-item">
                <span class="label">你的地址:</span>
                <span class="value">{{ shortenAddress(userAddress) }}</span>
              </div>
            </div>

            <div class="input-group address-input-group">
              <label>ScientificCalculator合约地址:</label>
              <div class="address-input-row">
                <input v-model="addressInput" type="text" placeholder="0x...">
                <button class="day-action-btn small random-btn" @click="generateRandomAddress">
                  🎲 随机生成
                </button>
              </div>
            </div>

            <button class="day-action-btn green" @click="handleSetAddress" :disabled="!isOwner">
              设置合约地址
            </button>

            <div v-if="errorMessage" class="error-message">{{ errorMessage }}</div>
            <div v-if="isAddressSet" class="success-message">
              ✅ 合约地址已设置: {{ shortenAddress(scientificCalculatorAddress) }}
            </div>
          </div>

          <!-- 区域3: 指数运算 -->
          <div class="function-block" :class="{ 'inactive-block': !isAddressSet }">
            <h4 class="block-title">⚡ 指数运算 (跨合约调用 - View函数)</h4>
            <code class="function-signature">函数：calculatePower(uint256 base, uint256 exponent) public view returns(uint256)</code>

            <div class="input-row">
              <div class="input-group">
                <label>底数:</label>
                <input v-model="baseInput" type="number" placeholder="base">
              </div>
              <div class="input-group">
                <label>指数:</label>
                <input v-model="exponentInput" type="number" placeholder="exponent">
              </div>
            </div>

            <button class="day-action-btn orange" @click="handleCalculatePower" :disabled="!isAddressSet">
              计算指数
            </button>

            <div v-if="powerResult !== null" class="result-box highlight">
              <span class="result-label">{{ baseInput }}^{{ exponentInput }} =</span>
              <span class="result-value">{{ powerResult }}</span>
            </div>

            <div v-if="showPowerFlow" class="flow-visualization">
              <div class="flow-step">
                <div class="contract-box">Calculator</div>
                <span class="arrow">➡️ calculatePower()</span>
              </div>
              <div class="flow-step">
                <span class="arrow down">⬇️ 创建接口实例</span>
              </div>
              <div class="flow-step">
                <div class="contract-box external">ScientificCalculator</div>
                <span class="arrow">➡️ power()</span>
              </div>
              <div class="flow-step">
                <span class="arrow up">⬆️ 返回结果</span>
              </div>
            </div>
          </div>

          <!-- 区域4: 平方根计算 -->
          <div class="function-block" :class="{ 'inactive-block': !isAddressSet }">
            <h4 class="block-title">🔧 平方根计算 (底层call)</h4>
            <code class="function-signature">函数：calculateSquareRoot(uint256 number) public returns(uint256)</code>

            <div class="input-group sqrt-input-group">
              <label>输入数字:</label>
              <input v-model="sqrtInput" type="number" placeholder="输入非负数">
            </div>

            <div class="button-row sqrt-button-row">
              <button class="day-action-btn magenta" @click="handleCalculateSqrt" :disabled="!isAddressSet">
                计算平方根
              </button>
              <button class="day-action-btn blue small" @click="showIteration = !showIteration">
                {{ showIteration ? '隐藏' : '查看' }}迭代过程
              </button>
            </div>

            <div v-if="sqrtResult !== null" class="result-box highlight">
              <span class="result-label">√{{ sqrtInput }} ≈</span>
              <span class="result-value">{{ sqrtResult }}</span>
            </div>

            <div v-if="showCallProcess" class="call-process">
              <h5>底层调用过程</h5>
              <div class="code-block">
                <div class="code-line">// 步骤1: 编码函数签名</div>
                <div class="code-line highlight">bytes memory data = abi.encodeWithSignature("squareRoot(int256)", {{ sqrtInput }});</div>
                <div class="code-line">// 步骤2: 发起底层call</div>
                <div class="code-line highlight">(bool success, bytes memory returnData) = address.call(data);</div>
                <div class="code-line">// 步骤3: 检查调用状态</div>
                <div class="code-line highlight">require(success, "External call failed");</div>
                <div class="code-line">// 步骤4: 解码返回数据</div>
                <div class="code-line highlight">uint256 result = abi.decode(returnData, (uint256));</div>
              </div>
            </div>
          </div>

          <!-- 区域5: 牛顿迭代法可视化 -->
          <div v-if="showIteration" class="function-block iteration-block">
            <h4 class="block-title">📐 牛顿迭代法可视化</h4>
            <code class="function-signature">函数：squareRoot(int256 number) public pure returns(int256) // 牛顿迭代实现</code>

            <div class="formula-box">
              <div class="formula-title">迭代公式</div>
              <div class="formula">result = (result + number/result) / 2</div>
            </div>

            <button class="day-action-btn" @click="handleAutoPlay" :disabled="isIterating">
              {{ isIterating ? '迭代中...' : '▶️ 自动播放迭代过程' }}
            </button>

            <div class="iteration-steps">
              <div v-for="(step, index) in iterationSteps" :key="index" 
                   class="iteration-step" 
                   :class="{ active: currentIterationStep === index + 1 }">
                <div class="step-number">第{{ step.round }}轮</div>
                <div class="step-formula">{{ step.formula }}</div>
                <div class="step-result">= {{ step.value.toFixed(4) }}</div>
              </div>
            </div>

            <div v-if="iterationSteps.length > 0" class="convergence-chart">
              <h5>收敛曲线</h5>
              <div class="chart-container">
                <div v-for="(step, index) in iterationSteps" :key="index" 
                     class="chart-bar"
                     :style="{ height: calculateBarHeight(step.value) + '%' }">
                  <span class="bar-label">{{ step.round }}</span>
                  <span class="bar-value">{{ step.value.toFixed(1) }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 区域6: 合约组合挑战 -->
          <div class="function-block challenge-block">
            <h4 class="block-title">🧩 合约组合挑战</h4>
            <code class="function-signature">// 合约组合 - 区块链的乐高积木</code>

            <div class="challenge-description">
              <p>完成以下4个任务，解锁合约组合知识点！</p>
              <p class="hint">💡 合约可以像乐高积木一样组合复用</p>
            </div>

            <div class="challenge-tasks">
              <div class="task-item" :class="{ completed: challengeTasks.setAddress }">
                <span class="task-checkbox">{{ challengeTasks.setAddress ? '✅' : '⬜' }}</span>
                <span class="task-text">设置合约地址</span>
              </div>
              <div class="task-item" :class="{ completed: challengeTasks.powerCalc }">
                <span class="task-checkbox">{{ challengeTasks.powerCalc ? '✅' : '⬜' }}</span>
                <span class="task-text">完成一次指数运算</span>
              </div>
              <div class="task-item" :class="{ completed: challengeTasks.sqrtCalc }">
                <span class="task-checkbox">{{ challengeTasks.sqrtCalc ? '✅' : '⬜' }}</span>
                <span class="task-text">完成一次平方根计算</span>
              </div>
              <div class="task-item" :class="{ completed: challengeTasks.permissionCheck }">
                <span class="task-checkbox">{{ challengeTasks.permissionCheck ? '✅' : '⬜' }}</span>
                <span class="task-text">验证权限控制</span>
                <button v-if="!challengeTasks.permissionCheck" class="day-action-btn small verify-btn" @click="handleCheckPermission">
                  验证
                </button>
              </div>
            </div>

            <div class="challenge-actions">
              <button class="day-action-btn green" @click="handleCompleteChallenge" :disabled="completedChallengeCount < 4">
                🏆 提交挑战
              </button>
            </div>

            <div v-if="challengeMessage" class="challenge-message" :class="{ success: challengeSuccess, error: !challengeSuccess }">
              {{ challengeMessage }}
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧：知识面板 -->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="9"
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
      title="Calculator & ScientificCalculator 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />

    <!-- 知识点解锁提示 - 仅通过watch触发 -->
    <div v-if="showUnlockModal" class="unlock-modal" @click="showUnlockModal = false">
      <div class="unlock-content" @click.stop>
        <div class="unlock-icon">🎉</div>
        <h3>知识点解锁!</h3>
        <p>{{ unlockedConceptName }}</p>
        <button class="day-action-btn" @click="showUnlockModal = false">太棒了!</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useDay9 } from '@/composables/useDay9'
import { useProgressStore } from '@/stores/progressStore'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

const {
  owner,
  userAddress,
  isOwner,
  scientificCalculatorAddress,
  isAddressSet,
  operationCount,
  operationHistory,
  challengeTasks,
  unlockedConcepts,
  progressPercentage,
  completedChallengeCount,
  toggleIdentity,
  calculate,
  setScientificCalculator,
  calculatePower,
  calculateSquareRoot,
  runNewtonIteration,
  checkPermission,
  completeChallenge
} = useDay9()

// 本地输入状态
const inputA = ref('')
const inputB = ref('')
const baseInput = ref('')
const exponentInput = ref('')
const sqrtInput = ref('')
const addressInput = ref('')

// 本地UI状态
const basicResult = ref(null)
const powerResult = ref(null)
const sqrtResult = ref(null)
const iterationSteps = ref([])
const isIterating = ref(false)
const currentIterationStep = ref(0)
const errorMessage = ref('')
const showPowerFlow = ref(false)
const showCallProcess = ref(false)
const showIteration = ref(false)
const showUnlockModal = ref(false)
const unlockedConceptName = ref('')
const challengeMessage = ref('')
const challengeSuccess = ref(false)
const showFullCode = ref(false)

// 完整代码
const fullCode = computed(() => getFullCode(9))

// 是否可以解锁pure知识点
const canUnlockPure = computed(() => operationCount.value >= 3)

// 工具函数
const shortenAddress = (addr) => {
  if (!addr || addr.length < 10) return addr
  return addr.slice(0, 6) + '...' + addr.slice(-4)
}

const getOperatorSymbol = (op) => {
  const symbols = { add: '+', subtract: '-', multiply: '×', divide: '÷' }
  return symbols[op] || op
}

const showError = (msg) => {
  errorMessage.value = msg
  setTimeout(() => { errorMessage.value = '' }, 3000)
}

// 生成随机合约地址
const generateRandomAddress = () => {
  const chars = '0123456789abcdef'
  let addr = '0x'
  for (let i = 0; i < 40; i++) {
    addr += chars[Math.floor(Math.random() * 16)]
  }
  addressInput.value = addr
}

// 处理方法
const handleCalculate = (operator) => {
  errorMessage.value = ''
  try {
    // 检查输入是否为空
    if (!inputA.value || !inputB.value) {
      showError('请输入两个数字')
      return
    }
    const a = parseFloat(inputA.value)
    const b = parseFloat(inputB.value)
    const result = calculate(operator, a, b)
    basicResult.value = result
  } catch (error) {
    showError(error.message)
  }
}

const handleSetAddress = () => {
  errorMessage.value = ''
  try {
    setScientificCalculator(addressInput.value)
    addressInput.value = ''
  } catch (error) {
    showError(error.message)
  }
}

const handleCalculatePower = () => {
  errorMessage.value = ''
  showPowerFlow.value = false
  try {
    // 检查输入是否为空
    if (!baseInput.value || !exponentInput.value) {
      showError('请输入底数和指数')
      return
    }
    const base = parseFloat(baseInput.value)
    const exponent = parseFloat(exponentInput.value)
    const result = calculatePower(base, exponent)
    powerResult.value = result
    showPowerFlow.value = true
  } catch (error) {
    showError(error.message)
  }
}

const handleCalculateSqrt = () => {
  errorMessage.value = ''
  showCallProcess.value = false
  try {
    // 检查输入是否为空
    if (!sqrtInput.value) {
      showError('请输入数字')
      return
    }
    const number = parseFloat(sqrtInput.value)
    const { result, steps } = calculateSquareRoot(number)
    sqrtResult.value = result
    iterationSteps.value = steps
    currentIterationStep.value = steps.length
    showCallProcess.value = true
    showIteration.value = true
  } catch (error) {
    showError(error.message)
  }
}

const handleAutoPlay = async () => {
  errorMessage.value = ''
  if (!sqrtInput.value) {
    showError('请先输入数字')
    return
  }
  try {
    isIterating.value = true
    iterationSteps.value = []
    currentIterationStep.value = 0
    const number = parseFloat(sqrtInput.value)
    const steps = await runNewtonIteration(number, true)
    iterationSteps.value = steps
    currentIterationStep.value = steps.length
    isIterating.value = false
  } catch (error) {
    isIterating.value = false
    showError(error.message)
  }
}

const handleCheckPermission = () => {
  errorMessage.value = ''
  challengeMessage.value = ''
  const result = checkPermission(isOwner.value)
  challengeMessage.value = result.message
  challengeSuccess.value = result.success
  if (!result.success) {
    showError('权限验证失败：请切换到 Owner 身份后再试')
  }
}

const handleCompleteChallenge = () => {
  errorMessage.value = ''
  const result = completeChallenge()
  challengeMessage.value = result.message
  challengeSuccess.value = result.success
}

const calculateBarHeight = (value) => {
  if (iterationSteps.value.length === 0) return 20
  const maxValue = Math.max(...iterationSteps.value.map(s => s.value))
  if (maxValue === 0 || !isFinite(maxValue)) return 20
  return (value / maxValue) * 80 + 20
}

// 监听知识点解锁 - 唯一的通知来源
watch(unlockedConcepts, (newVal, oldVal) => {
  if (newVal && oldVal && newVal.length > oldVal.length) {
    const newConceptKey = newVal[newVal.length - 1]
    // 从概念定义中获取名称
    const conceptNames = {
      pure_function: 'Pure 纯函数',
      view_function: 'View 视图函数',
      cross_contract_call: '跨合约调用',
      interface_call: '接口方式调用',
      low_level_call: '底层 Call 调用',
      modifier_onlyOwner: 'onlyOwner 修饰符',
      newton_iteration: '牛顿迭代法',
      contract_composition: '合约组合'
    }
    unlockedConceptName.value = conceptNames[newConceptKey] || newConceptKey
    showUnlockModal.value = true
  }
}, { deep: true })

// 初始化
onMounted(() => {
  // 组件挂载时初始化
})
</script>

<style scoped>
/* 基础布局 - 与Day8保持一致 */

/* 函数块样式 - 圆角矩形淡细线边框 */
.day-9-content .function-block {
  border: 1px solid var(--border-main);
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
  background: var(--bg-surface-1);
}

.day-9-content .function-block:last-child {
  margin-bottom: 0;
}

.day-9-content .identity-toggle-bar {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 20px;
  padding: 10px;
  background: var(--bg-surface-2);
  border-radius: 8px;
}

.day-9-content .identity-label {
  font-weight: bold;
  color: var(--text-muted);
}

.day-9-content .toggle-buttons {
  display: flex;
  gap: 10px;
}

.day-9-content .toggle-buttons button {
  padding: 8px 16px;
  border: none;
  background: transparent;
  color: var(--text-muted);
  cursor: pointer;
  font-size: 0.9em;
  border-radius: 6px;
  transition: all 0.2s;
}

.day-9-content .toggle-buttons button.active {
  background: var(--accent-blue);
  color: white;
}

.day-9-content .address-info {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  margin-bottom: 15px;
  padding: 10px;
  background: var(--bg-surface-2);
  border-radius: 8px;
}

.day-9-content .address-item {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.day-9-content .address-item .label {
  font-size: 0.8em;
  color: var(--text-muted);
}

.day-9-content .address-item .value {
  font-family: monospace;
  font-size: 0.85em;
  color: var(--text-main);
}

.day-9-content .input-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  margin-bottom: 15px;
}

.day-9-content .input-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.day-9-content .input-group label {
  font-size: 0.9em;
  color: var(--text-muted);
}

.day-9-content .input-group input {
  padding: 10px;
  border: 1px solid var(--border-main);
  border-radius: 6px;
  background: var(--bg-surface-1);
  color: var(--text-main);
  font-size: 1em;
}

.day-9-content .operator-buttons {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
}

.day-9-content .operator-buttons button {
  flex: 1;
  font-size: 1.2em;
  font-weight: bold;
}

.day-9-content .result-box {
  padding: 15px;
  background: var(--bg-surface-2);
  border-radius: 8px;
  margin-bottom: 15px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.day-9-content .result-box.highlight {
  background: var(--accent-blue);
  color: white;
}

.day-9-content .result-value {
  font-size: 1.5em;
  font-weight: bold;
}

.day-9-content .operation-counter {
  padding: 10px;
  background: var(--bg-surface-2);
  border-radius: 6px;
  font-size: 0.9em;
  color: var(--text-muted);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.day-9-content .unlock-hint {
  color: var(--accent-green);
  font-weight: bold;
}

.day-9-content .history-box {
  margin-top: 15px;
  padding: 10px;
  background: var(--bg-surface-2);
  border-radius: 6px;
}

.day-9-content .history-box h5 {
  margin: 0 0 10px 0;
  color: var(--text-muted);
  font-size: 0.9em;
}

.day-9-content .history-item {
  padding: 5px 0;
  font-family: monospace;
  font-size: 0.9em;
  border-bottom: 1px solid var(--border-main);
}

.day-9-content .history-item:last-child {
  border-bottom: none;
}

.day-9-content .button-row {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
}

/* 平方根计算块的输入框和按钮间距 */
.day-9-content .sqrt-input-group {
  margin-bottom: 20px;
}

.day-9-content .sqrt-button-row {
  margin-top: 5px;
}

.day-9-content .button-row button.small {
  padding: 8px 16px;
  font-size: 0.85em;
}

.day-9-content .flow-visualization {
  margin-top: 20px;
  padding: 20px;
  background: var(--bg-surface-2);
  border-radius: 8px;
}

.day-9-content .flow-step {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 10px;
}

.day-9-content .contract-box {
  padding: 10px 20px;
  background: var(--accent-blue);
  color: white;
  border-radius: 8px;
  font-weight: bold;
}

.day-9-content .contract-box.external {
  background: var(--accent-green);
}

.day-9-content .arrow {
  font-size: 1.2em;
}

.day-9-content .arrow.down,
.day-9-content .arrow.up {
  margin-left: 30px;
  color: var(--text-muted);
}

.day-9-content .call-process {
  margin-top: 20px;
  padding: 15px;
  background: var(--bg-surface-2);
  border-radius: 8px;
}

.day-9-content .call-process h5 {
  margin: 0 0 10px 0;
  color: var(--text-muted);
}

.day-9-content .code-block {
  font-family: monospace;
  font-size: 0.85em;
}

.day-9-content .code-line {
  padding: 3px 0;
  color: var(--text-muted);
}

.day-9-content .code-line.highlight {
  color: var(--accent-green);
  background: rgba(0, 255, 0, 0.1);
  padding: 5px;
  border-radius: 4px;
  margin: 3px 0;
}

.day-9-content .iteration-block {
  background: var(--bg-surface-2);
}

.day-9-content .formula-box {
  padding: 15px;
  background: var(--bg-surface-1);
  border-radius: 8px;
  margin-bottom: 15px;
  text-align: center;
}

.day-9-content .formula-title {
  font-size: 0.9em;
  color: var(--text-muted);
  margin-bottom: 5px;
}

.day-9-content .formula {
  font-family: monospace;
  font-size: 1.1em;
  color: var(--accent-blue);
}

.day-9-content .iteration-steps {
  margin-top: 20px;
}

.day-9-content .iteration-step {
  padding: 10px;
  margin-bottom: 10px;
  background: var(--bg-surface-1);
  border-radius: 6px;
  border-left: 3px solid transparent;
}

.day-9-content .iteration-step.active {
  border-left-color: var(--accent-blue);
  background: rgba(59, 130, 246, 0.1);
}

.day-9-content .step-number {
  font-weight: bold;
  color: var(--text-muted);
  margin-bottom: 5px;
}

.day-9-content .step-formula {
  font-family: monospace;
  font-size: 0.9em;
  color: var(--text-main);
  margin-bottom: 5px;
}

.day-9-content .step-result {
  font-weight: bold;
  color: var(--accent-green);
}

.day-9-content .convergence-chart {
  margin-top: 20px;
  padding: 15px;
  background: var(--bg-surface-1);
  border-radius: 8px;
}

.day-9-content .convergence-chart h5 {
  margin: 0 0 15px 0;
  color: var(--text-muted);
}

.day-9-content .chart-container {
  display: flex;
  align-items: flex-end;
  justify-content: space-around;
  height: 150px;
  gap: 5px;
}

.day-9-content .chart-bar {
  flex: 1;
  background: var(--accent-blue);
  border-radius: 4px 4px 0 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
  padding-bottom: 5px;
  min-height: 20px;
  transition: height 0.3s;
}

.day-9-content .chart-bar .bar-label {
  font-size: 0.7em;
  color: white;
  margin-bottom: 2px;
}

.day-9-content .chart-bar .bar-value {
  font-size: 0.6em;
  color: rgba(255, 255, 255, 0.8);
}

.day-9-content .challenge-block {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(139, 92, 246, 0.1));
}

.day-9-content .challenge-description {
  margin-bottom: 20px;
}

.day-9-content .challenge-description p {
  margin: 5px 0;
  color: var(--text-main);
}

.day-9-content .challenge-description .hint {
  color: var(--accent-yellow);
  font-size: 0.9em;
}

.day-9-content .challenge-tasks {
  margin-bottom: 20px;
}

.day-9-content .task-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  margin-bottom: 8px;
  background: var(--bg-surface-1);
  border-radius: 6px;
  transition: all 0.2s;
}

.day-9-content .task-item.completed {
  background: rgba(34, 197, 94, 0.1);
}

.day-9-content .task-checkbox {
  font-size: 1.2em;
}

.day-9-content .task-text {
  flex: 1;
  color: var(--text-main);
}

.day-9-content .task-item.completed .task-text {
  text-decoration: line-through;
  color: var(--text-muted);
}

.day-9-content .challenge-actions {
  display: flex;
  gap: 10px;
}

.day-9-content .challenge-message {
  margin-top: 15px;
  padding: 10px;
  border-radius: 6px;
  text-align: center;
}

.day-9-content .challenge-message.success {
  background: rgba(34, 197, 94, 0.2);
  color: var(--accent-green);
}

.day-9-content .challenge-message.error {
  background: rgba(239, 68, 68, 0.2);
  color: var(--accent-red);
}

.day-9-content .inactive-block {
  opacity: 0.6;
  pointer-events: none;
}

.day-9-content .error-message {
  margin-top: 10px;
  padding: 10px;
  background: rgba(239, 68, 68, 0.1);
  color: var(--accent-red);
  border-radius: 6px;
  font-size: 0.9em;
}

.day-9-content .success-message {
  margin-top: 10px;
  padding: 10px;
  background: rgba(34, 197, 94, 0.1);
  color: var(--accent-green);
  border-radius: 6px;
  font-size: 0.9em;
}

/* 函数签名样式 - Day 7 风格 */
.day-9-content .function-signature {
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

/* 地址输入行样式 */
.day-9-content .address-input-group {
  margin-bottom: 15px;
}

.day-9-content .address-input-row {
  display: flex;
  gap: 10px;
  align-items: stretch;
}

.day-9-content .address-input-row input {
  flex: 1;
}

/* 辅助/次要操作按钮 - 使用青色 */
.day-9-content .day-action-btn.small {
  background: var(--accent-cyan);
  color: white;
  border: 1px solid var(--accent-cyan);
}

.day-9-content .day-action-btn.small:hover {
  background: var(--accent-cyan-hover);
  border-color: var(--accent-cyan-hover);
}

/* 验证按钮样式 - 使用黄色表示警告/注意 */
.day-9-content .verify-btn {
  background: var(--accent-yellow);
  color: var(--bg-main);
  border: 1px solid var(--accent-yellow);
}

.day-9-content .verify-btn:hover {
  background: var(--accent-yellow-hover);
  border-color: var(--accent-yellow-hover);
}

/* 解锁弹窗 */
.unlock-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.unlock-content {
  background: var(--bg-surface-1);
  padding: 30px;
  border-radius: 12px;
  text-align: center;
  max-width: 400px;
  animation: slideIn 0.3s ease;
}

@keyframes slideIn {
  from {
    transform: translateY(-20px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.unlock-icon {
  font-size: 3em;
  margin-bottom: 15px;
}

.unlock-content h3 {
  margin: 0 0 10px 0;
  color: var(--text-main);
}

.unlock-content p {
  margin: 0 0 20px 0;
  color: var(--text-muted);
  font-size: 1.1em;
}
</style>
