<template>
  <div class="day-10-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <div class="left-column">
        <!-- 状态指示器 -->
        <div class="status-indicator">
          <span class="status-label">👤 当前状态：</span>
          <span :class="['status-value', isRegistered ? 'registered' : 'unregistered']">
            {{ isRegistered ? `已注册：${userProfile.name}` : '未注册' }}
          </span>
        </div>

        <!-- 未注册状态：注册表单 -->
        <div v-if="!isRegistered" class="registration-phase">
          <div class="welcome-card">
            <h2>👋 欢迎使用健身追踪器</h2>
            <p class="welcome-desc">请先注册以开始记录您的运动历程</p>
            
            <div class="register-form">
              <div class="input-group">
                <label>您的昵称：</label>
                <input 
                  v-model="registerForm.name" 
                  type="text" 
                  placeholder="请输入昵称"
                  @click.stop
                >
              </div>
              <div class="input-group">
                <label>体重（公斤）：</label>
                <input 
                  v-model="registerForm.weight" 
                  type="number" 
                  min="1"
                  placeholder="请输入体重"
                  @click.stop
                >
              </div>
              <button 
                @click.stop="handleRegister" 
                class="day-action-btn green"
                :disabled="!canRegister"
              >
                🎯 开始健身之旅
              </button>
            </div>
          </div>

        </div>

        <!-- 已注册状态：完整功能 -->
        <div v-else class="tracking-phase">
          <!-- 记录运动 -->
          <div class="function-block">
            <h4 class="block-title">🏃 记录运动</h4>
            <code class="function-signature">函数：logWorkout(string _activityType, uint256 _duration, uint256 _distance) public onlyRegistered</code>
            
            <div class="activity-inputs">
              <div class="input-group">
                <label>运动类型：</label>
                <div class="activity-types">
                  <button 
                    v-for="type in activityTypes" 
                    :key="type.value"
                    :class="['activity-btn', { active: selectedActivityType === type.value }]"
                    @click.stop="selectedActivityType = type.value"
                  >
                    {{ type.icon }} {{ type.label }}
                  </button>
                  <button 
                    :class="['activity-btn', { active: isCustomActivity }]"
                    @click.stop="enableCustomActivity"
                  >
                    ✏️ 自定义
                  </button>
                </div>
                <input 
                  v-if="isCustomActivity"
                  v-model="customActivityType"
                  type="text" 
                  placeholder="输入运动类型"
                  class="custom-input"
                  @click.stop
                >
              </div>

              <!-- 时长输入 -->
              <div class="input-group">
                <label>时长：</label>
                <div class="input-with-unit">
                  <input 
                    v-model="workoutForm.duration" 
                    type="number" 
                    min="1"
                    placeholder="请输入时长"
                    @click.stop
                  >
                  <select v-model="durationUnit" @click.stop>
                    <option value="minutes">分钟</option>
                    <option value="hours">小时</option>
                  </select>
                </div>
              </div>

              <!-- 距离输入 -->
              <div class="input-group">
                <label>距离：</label>
                <div class="input-with-unit">
                  <input 
                    v-model="workoutForm.distance" 
                    type="number" 
                    min="1"
                    placeholder="请输入距离"
                    @click.stop
                  >
                  <select v-model="distanceUnit" @click.stop>
                    <option value="meters">米</option>
                    <option value="kilometers">公里</option>
                  </select>
                </div>
              </div>

              <button 
                @click.stop="handleLogWorkout" 
                class="day-action-btn cyan"
                :disabled="!canLogWorkout"
              >
                💾 记录运动
              </button>

              <!-- 里程碑快捷键（仅用于测试） -->
              <div class="shortcut-section">
                <p class="shortcut-title">🚀 里程碑快捷键（测试用）：</p>
                <div class="shortcut-row">
                  <button @click.stop="quickAddWorkouts(9)" class="shortcut-btn blue">+9次</button>
                  <button @click.stop="quickAddWorkouts(49)" class="shortcut-btn magenta">+49次</button>
                  <button @click.stop="quickAddDistance" class="shortcut-btn orange">+100km</button>
                </div>
              </div>
            </div>
          </div>

          <!-- 更新体重 -->
          <div class="function-block">
            <h4 class="block-title">⚖️ 更新体重</h4>
            <code class="function-signature">函数：updateWeight(uint256 _newWeight) public onlyRegistered</code>
            
            <div class="weight-update">
              <div class="current-weight">
                当前体重：<span class="weight-value">{{ userProfile.weight }} 公斤</span>
              </div>
              <div class="input-row">
                <div class="input-group">
                  <label>新体重（公斤）：</label>
                  <input 
                    v-model="newWeight" 
                    type="number" 
                    min="1"
                    placeholder="输入新体重"
                    @click.stop
                  >
                </div>
                <button 
                  @click.stop="handleUpdateWeight" 
                  class="day-action-btn yellow small"
                  :disabled="!canUpdateWeight"
                >
                  更新
                </button>
              </div>
              <p class="hint">💡 减重5%以上将触发里程碑！</p>
            </div>
          </div>

          <!-- 数据统计 -->
          <div class="function-block stats-block" @click="handleViewStatistics">
            <h4 class="block-title">📊 运动统计</h4>
            <div class="stats-grid">
              <div class="stat-item">
                <span class="stat-icon">🔢</span>
                <span class="stat-label">总运动次数</span>
                <span class="stat-value">{{ totalWorkouts }} 次</span>
              </div>
              <div class="stat-item">
                <span class="stat-icon">📏</span>
                <span class="stat-label">总运动距离</span>
                <span class="stat-value">{{ formatDistance(totalDistance) }}</span>
              </div>
            </div>
          </div>

          <!-- 里程碑成就 -->
          <div class="function-block milestones-block">
            <h4 class="block-title">🏆 里程碑成就</h4>
            <div class="milestone-grid">
              <div 
                v-for="(milestone, key) in milestones" 
                :key="key"
                :class="['milestone-card', { achieved: milestone.achieved }]"
              >
                <div class="milestone-icon">{{ milestone.icon }}</div>
                <div class="milestone-title">{{ milestone.title }}</div>
                <div class="milestone-status">
                  {{ milestone.achieved ? '✅ 已达成' : '⬜ 未达成' }}
                </div>
                <div v-if="milestone.achieved" class="milestone-time">
                  {{ formatTime(milestone.timestamp) }}
                </div>
              </div>
            </div>
          </div>

          <!-- 运动历史 -->
          <div class="function-block history-block" @click="handleViewHistory">
            <h4 class="block-title">📜 运动历史</h4>
            
            <!-- 空状态 -->
            <div v-if="workoutHistory.length === 0" class="empty-history">
              <div class="empty-icon">📝</div>
              <p>还没有运动记录</p>
              <p class="sub">开始您的第一次运动吧！</p>
            </div>

            <!-- 时间线 -->
            <div v-else class="history-timeline">
              <div 
                v-for="(workout, index) in workoutHistory" 
                :key="index" 
                class="timeline-item"
              >
                <div class="timeline-icon">{{ getActivityIcon(workout.activityType) }}</div>
                <div class="timeline-content">
                  <div class="activity-title">{{ workout.activityType }}</div>
                  <div class="activity-meta">
                    {{ formatDuration(workout.duration) }} | {{ formatDistance(workout.distance) }}
                  </div>
                  <div class="activity-time">{{ formatTimestamp(workout.timestamp) }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 消息提示 -->
        <div v-if="message" :class="['message-toast', { error: isError }]">
          {{ message }}
        </div>
      </div>

      <!-- 右侧：知识面板 -->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="10"
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
      title="ActivityTracker 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useDay10 } from '@/composables/useDay10'
import { useProgressStore } from '@/stores/progressStore'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

const progressStore = useProgressStore()

// Day10 业务逻辑
const {
  userProfile,
  workoutHistory,
  totalWorkouts,
  totalDistance,
  milestones,
  isRegistered,
  unlockedConcepts,
  progressPercentage,
  registerUser,
  logWorkout,
  updateWeight,
  convertToSeconds,
  convertToMeters,
  formatDuration,
  formatDistance,
  formatTimestamp,
  getActivityIcon,
  viewWorkoutHistory,
  viewStatistics
} = useDay10()

// 完整代码
const fullCode = computed(() => getFullCode(10))

// 弹窗状态
const showFullCode = ref(false)

// 消息提示
const message = ref('')
const isError = ref(false)

// 注册表单
const registerForm = ref({
  name: '',
  weight: ''
})

// 运动类型选项
const activityTypes = [
  { value: '跑步', label: '跑步', icon: '🏃' },
  { value: '骑行', label: '骑行', icon: '🚴' },
  { value: '游泳', label: '游泳', icon: '🏊' },
  { value: '步行', label: '步行', icon: '🚶' },
  { value: '瑜伽', label: '瑜伽', icon: '🧘' },
  { value: '篮球', label: '篮球', icon: '⛹️' }
]

// 运动记录表单
const selectedActivityType = ref('跑步')
const isCustomActivity = ref(false)
const customActivityType = ref('')
const durationUnit = ref('minutes')
const distanceUnit = ref('meters')
const workoutForm = ref({
  duration: '',
  distance: ''
})

// 体重更新
const newWeight = ref('')

// 计算属性：是否可以注册
const canRegister = computed(() => {
  return registerForm.value.name.trim() && registerForm.value.weight > 0
})

// 计算属性：是否可以记录运动
const canLogWorkout = computed(() => {
  const activityType = isCustomActivity.value ? customActivityType.value : selectedActivityType.value
  return activityType.trim() && workoutForm.value.duration > 0 && workoutForm.value.distance > 0
})

// 计算属性：是否可以更新体重
const canUpdateWeight = computed(() => {
  return newWeight.value > 0 && newWeight.value !== userProfile.value.weight
})

// 启用自定义运动类型
const enableCustomActivity = () => {
  isCustomActivity.value = true
  selectedActivityType.value = ''
}

// 处理注册
const handleRegister = () => {
  const result = registerUser(registerForm.value.name, Number(registerForm.value.weight))
  if (result.success) {
    // 显示解锁提示（下一步该做什么）
    if (result.unlockedHints && result.unlockedHints.length > 0) {
      showMessage(result.unlockedHints[0], false)
    } else {
      showMessage('🎉 注册成功！您现在可以使用健身追踪功能了。', false)
    }
    registerForm.value = { name: '', weight: '' }
  } else {
    showMessage('❌ ' + result.error, true)
  }
}

// 处理记录运动
const handleLogWorkout = () => {
  const activityType = isCustomActivity.value ? customActivityType.value : selectedActivityType.value
  const durationInSeconds = convertToSeconds(Number(workoutForm.value.duration), durationUnit.value)
  const distanceInMeters = convertToMeters(Number(workoutForm.value.distance), distanceUnit.value)

  const result = logWorkout(activityType, durationInSeconds, distanceInMeters)
  if (result.success) {
    // 显示解锁提示（下一步该做什么）
    if (result.unlockedHints && result.unlockedHints.length > 0) {
      showMessage(result.unlockedHints[0], false)
    } else {
      showMessage('✅ 运动记录成功！', false)
    }
    workoutForm.value = { duration: '', distance: '' }
    if (isCustomActivity.value) {
      customActivityType.value = ''
      isCustomActivity.value = false
      selectedActivityType.value = '跑步'
    }
  } else {
    showMessage('❌ ' + result.error, true)
  }
}

// 处理更新体重
const handleUpdateWeight = () => {
  const result = updateWeight(Number(newWeight.value))
  if (result.success) {
    // 显示解锁提示（下一步该做什么）
    if (result.unlockedHints && result.unlockedHints.length > 0) {
      showMessage(result.unlockedHints[0], false)
    } else {
      const oldWeight = userProfile.value.weight
      const weightDiff = oldWeight - Number(newWeight.value)
      if (weightDiff > 0) {
        showMessage(`✅ 体重更新成功！减重 ${weightDiff.toFixed(1)} 公斤`, false)
      } else {
        showMessage('✅ 体重更新成功！', false)
      }
    }
    newWeight.value = ''
  } else {
    showMessage('❌ ' + result.error, true)
  }
}

// 查看统计数据
const handleViewStatistics = () => {
  const hint = viewStatistics()
  if (hint) {
    showMessage(hint, false)
  }
}

// 查看运动历史
const handleViewHistory = () => {
  const hint = viewWorkoutHistory()
  if (hint) {
    showMessage(hint, false)
  }
}

// 快捷键：快速添加运动次数
const quickAddWorkouts = (count) => {
  for (let i = 0; i < count; i++) {
    logWorkout('快捷运动', 1800, 1000)
  }
  showMessage(`🚀 已快速添加 ${count} 次运动！`, false)
}

// 快捷键：快速添加距离
const quickAddDistance = () => {
  logWorkout('百公里挑战', 3600, 100000)
  showMessage('🚀 已添加100公里运动记录！', false)
}

// 显示消息
const showMessage = (msg, error = false) => {
  message.value = msg
  isError.value = error
  setTimeout(() => {
    message.value = ''
  }, 3000)
}

// 格式化时间
const formatTime = (timestamp) => {
  if (!timestamp) return ''
  const date = new Date(timestamp)
  return date.toLocaleDateString('zh-CN')
}
</script>

<style scoped>
.day-10-content .status-indicator {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
  padding: 12px 15px;
  background: var(--bg-surface-2);
  border-radius: 8px;
}

.day-10-content .status-label {
  font-weight: bold;
  color: var(--text-muted);
}

.day-10-content .status-value {
  font-weight: bold;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.9em;
}

.day-10-content .status-value.unregistered {
  background: var(--accent-orange);
  color: #fff;
}

.day-10-content .status-value.registered {
  background: var(--accent-green);
  color: #fff;
}

/* 注册阶段 */
.day-10-content .registration-phase {
  animation: fadeIn 0.3s ease;
}

.day-10-content .welcome-card {
  background: var(--bg-surface-1);
  border: 1px solid var(--border-main);
  border-radius: 12px;
  padding: 30px;
  text-align: center;
  margin-bottom: 20px;
}

.day-10-content .welcome-card h2 {
  color: var(--accent-green);
  margin-bottom: 10px;
}

.day-10-content .welcome-desc {
  color: var(--text-muted);
  margin-bottom: 25px;
}

.day-10-content .register-form {
  display: flex;
  flex-direction: column;
  gap: 15px;
  max-width: 300px;
  margin: 0 auto;
}

/* 追踪阶段 */
.day-10-content .tracking-phase {
  animation: fadeIn 0.3s ease;
}

.day-10-content .function-block {
  background: var(--bg-surface-1);
  border: 1px solid var(--border-main);
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 15px;
}

.day-10-content .function-block .block-title {
  color: var(--accent-green);
  margin: 0 0 10px 0;
  font-size: 1.1em;
}

.day-10-content .function-signature {
  display: block;
  background: var(--bg-surface-2);
  padding: 8px 12px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 0.8em;
  color: var(--text-main);
  margin-bottom: 15px;
  border-left: 3px solid var(--accent-yellow);
  line-height: 1.4;
}

.day-10-content .input-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
  margin-bottom: 12px;
}

.day-10-content .input-group label {
  font-weight: bold;
  color: var(--text-main);
  font-size: 0.9em;
}

.day-10-content .input-group input,
.day-10-content .input-group select {
  padding: 10px;
  border: 2px solid var(--border-main);
  border-radius: 6px;
  font-size: 1em;
  background: var(--bg-base);
  color: var(--text-main);
}

.day-10-content .input-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}

.day-10-content .input-with-unit {
  display: flex;
  gap: 8px;
}

.day-10-content .input-with-unit input {
  flex: 1;
}

.day-10-content .input-with-unit select {
  width: 80px;
}

/* 运动类型选择 */
.day-10-content .activity-types {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 10px;
}

.day-10-content .activity-btn {
  padding: 8px 12px;
  border: 2px solid var(--border-main);
  background: var(--bg-surface-2);
  color: var(--text-main);
  border-radius: 20px;
  cursor: pointer;
  font-size: 0.85em;
  transition: all 0.2s;
}

.day-10-content .activity-btn:hover {
  border-color: var(--accent-blue);
}

.day-10-content .activity-btn.active {
  background: var(--accent-blue);
  border-color: var(--accent-blue);
  color: #fff;
}

.day-10-content .custom-input {
  margin-top: 5px;
}

/* 体重更新 */
.day-10-content .weight-update .current-weight {
  margin-bottom: 15px;
  padding: 10px;
  background: var(--bg-surface-2);
  border-radius: 6px;
}

.day-10-content .weight-value {
  font-weight: bold;
  color: var(--accent-yellow);
}

.day-10-content .hint {
  font-size: 0.85em;
  color: var(--text-muted);
  margin-top: 10px;
  font-style: italic;
}

/* 里程碑快捷键 */
.day-10-content .shortcut-section {
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px dashed var(--border-main);
}

.day-10-content .shortcut-title {
  font-size: 0.75em;
  color: var(--text-muted);
  margin-bottom: 8px;
}

.day-10-content .shortcut-row {
  display: flex;
  gap: 8px;
}

.day-10-content .shortcut-btn {
  flex: 1;
  padding: 8px 4px;
  border: none;
  border-radius: 6px;
  font-size: 0.8em;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.2s;
  color: #fff;
}

.day-10-content .shortcut-btn:hover {
  opacity: 0.9;
  transform: translateY(-1px);
}

.day-10-content .shortcut-btn.blue {
  background: var(--accent-blue);
}

.day-10-content .shortcut-btn.magenta {
  background: var(--accent-magenta);
}

.day-10-content .shortcut-btn.orange {
  background: var(--accent-orange);
}

/* 统计区块 */
.day-10-content .stats-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}

.day-10-content .stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 15px;
  background: var(--bg-surface-2);
  border-radius: 8px;
  text-align: center;
}

.day-10-content .stat-icon {
  font-size: 1.5em;
  margin-bottom: 5px;
}

.day-10-content .stat-label {
  font-size: 0.85em;
  color: var(--text-muted);
  margin-bottom: 5px;
}

.day-10-content .stat-value {
  font-size: 1.2em;
  font-weight: bold;
  color: var(--accent-green);
}

/* 里程碑 */
.day-10-content .milestone-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
}

.day-10-content .milestone-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 15px;
  background: var(--bg-surface-2);
  border: 2px solid var(--border-main);
  border-radius: 8px;
  text-align: center;
  transition: all 0.3s;
  opacity: 0.6;
}

.day-10-content .milestone-card.achieved {
  opacity: 1;
  border-color: var(--accent-green);
  background: linear-gradient(135deg, var(--bg-surface-2), rgba(74, 222, 128, 0.1));
}

.day-10-content .milestone-icon {
  font-size: 2em;
  margin-bottom: 8px;
}

.day-10-content .milestone-title {
  font-weight: bold;
  font-size: 0.9em;
  margin-bottom: 5px;
}

.day-10-content .milestone-status {
  font-size: 0.8em;
  color: var(--text-muted);
}

.day-10-content .milestone-time {
  font-size: 0.75em;
  color: var(--accent-green);
  margin-top: 5px;
}

/* 运动历史 */
.day-10-content .empty-history {
  text-align: center;
  padding: 30px;
  color: var(--text-muted);
}

.day-10-content .empty-icon {
  font-size: 3em;
  margin-bottom: 10px;
}

.day-10-content .empty-history .sub {
  font-size: 0.9em;
  opacity: 0.7;
}

.day-10-content .history-timeline {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.day-10-content .timeline-item {
  display: flex;
  gap: 12px;
  padding: 12px;
  background: var(--bg-surface-2);
  border-radius: 8px;
  border-left: 3px solid var(--accent-blue);
}

.day-10-content .timeline-icon {
  font-size: 1.5em;
  flex-shrink: 0;
}

.day-10-content .timeline-content {
  flex: 1;
}

.day-10-content .activity-title {
  font-weight: bold;
  margin-bottom: 4px;
}

.day-10-content .activity-meta {
  font-size: 0.85em;
  color: var(--text-muted);
  margin-bottom: 2px;
}

.day-10-content .activity-time {
  font-size: 0.75em;
  color: var(--text-muted);
  opacity: 0.7;
}

/* 消息提示 */
.day-10-content .message-toast {
  position: fixed;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  padding: 12px 24px;
  border-radius: 8px;
  background: var(--accent-green);
  color: #fff;
  font-weight: bold;
  z-index: 1000;
  animation: slideUp 0.3s ease;
}

.day-10-content .message-toast.error {
  background: var(--accent-red);
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideUp {
  from { opacity: 0; transform: translateX(-50%) translateY(20px); }
  to { opacity: 1; transform: translateX(-50%) translateY(0); }
}

/* 夜间模式 - 按钮文字颜色改为深色 */
[data-theme="dark"] .day-10-content .day-action-btn {
  color: #1a1a2e;
}

[data-theme="dark"] .day-10-content .day-action-btn:hover {
  color: #1a1a2e;
}

/* 响应式 */
@media (max-width: 768px) {
  .day-10-content .input-row {
    grid-template-columns: 1fr;
  }
  
  .day-10-content .milestone-grid {
    grid-template-columns: 1fr;
  }
  
  .day-10-content .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .day-10-content .activity-types {
    justify-content: center;
  }
}
</style>
