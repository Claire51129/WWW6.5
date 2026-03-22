<template>
  <div class="right-sidebar">
    <div class="sidebar-card">
      <h3>🎓 学习进度</h3>
      <div class="progress-bar">
        <div class="progress-fill" :style="{ width: progressPercentage + '%' }"></div>
      </div>
      <div class="progress-stats">
        <span>完成度 {{ progressPercentage }}%</span>
        <span>已解锁 {{ unlockedCount }}/{{ totalConcepts }}</span>
      </div>
    </div>

    <div class="sidebar-card">
      <h3>✅ 已解锁概念</h3>
      <ul class="unlocked-list">
        <li v-if="currentDayConcepts.length === 0" class="locked">
          <span class="icon">🚧</span> 内容开发中...
        </li>
        <li 
          v-for="concept in currentDayConcepts" 
          :key="concept.key"
          :class="{ locked: !concept.isUnlocked }"
        >
          <span class="icon">{{ concept.icon }}</span>
          {{ concept.name }}
        </li>
      </ul>
    </div>

    <!-- 实时数据（动态显示）-->
    <div class="sidebar-card" v-if="realtimeData">
      <h3>📊 实时数据</h3>
      <div class="realtime-data">
        <!-- Gas 消耗统计 -->
        <div v-if="realtimeData.operationCount > 0">
          <div class="data-row">
            <span class="label">操作次数：</span>
            <span class="value">{{ realtimeData.operationCount }}</span>
          </div>
          <div class="data-row">
            <span class="label">Gas 消耗：</span>
            <span class="value">{{ realtimeData.gasUsage.toLocaleString() }}</span>
          </div>
          <div class="data-row">
            <span class="label">ETH 费用：</span>
            <span class="value">{{ realtimeData.ethCost.toFixed(6) }}</span>
          </div>
        </div>

        <!-- 无操作提示 -->
        <div v-else class="no-operations">
          暂无操作记录
        </div>
      </div>
    </div>

    <!-- 操作日志（简化版）-->
    <div class="sidebar-card">
      <h3>📋 操作日志</h3>
      <div class="operation-log">
        <p v-if="currentDayLogs.length === 0" class="no-operations">暂无操作记录</p>
        <div v-else>
          <div v-for="log in currentDayLogs.slice(0, 10)" :key="log.id" class="log-entry">
            <div class="data-row">
              <span class="timestamp">{{ log.timestamp }}</span>
              <span><strong>{{ log.operation }}</strong> {{ log.details }}</span>
            </div>
            <div v-if="log.gasUsed > 0" class="data-row gas-info">
              <span class="label">Gas:</span>
              <span class="value">{{ log.gasUsed.toLocaleString() }}</span>
              <span class="label" style="margin-left: 15px;">ETH:</span>
              <span class="value">{{ log.ethCost.toFixed(6) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { dayConfigs } from '../data/days'
import { conceptDefinitions, day11ConceptDefinitions, day12ConceptDefinitions, day13ConceptDefinitions, day14ConceptDefinitions, day15ConceptDefinitions, day16ConceptDefinitions, day17ConceptDefinitions, day18ConceptDefinitions, day19ConceptDefinitions, day20ConceptDefinitions, day21ConceptDefinitions } from '../data/concepts'
import { useOperationLogStore } from '@/stores/operationLogStore'

const props = defineProps({
  // 新增：实时数据接口
  realtimeData: {
    type: Object,
    default: null
  },
  // 保留原有的进度数据
  dayProgress: {
    type: Object,
    required: true
  },
  currentDay: {
    type: Number,
    required: true
  }
})

const logStore = useOperationLogStore()

// 获取当前day的日志（最近10条）
const currentDayLogs = computed(() => {
  return logStore.getDayLogs(props.currentDay)
})

const progressPercentage = computed(() => {
  const currentProgress = props.dayProgress[props.currentDay]
  if (!currentProgress || currentProgress.totalConcepts === 0) return 0
  return Math.floor((currentProgress.unlockedConcepts.length / currentProgress.totalConcepts) * 100)
})

const unlockedCount = computed(() => {
  const currentProgress = props.dayProgress[props.currentDay]
  return currentProgress?.unlockedConcepts.length || 0
})

const totalConcepts = computed(() => {
  const currentProgress = props.dayProgress[props.currentDay]
  return currentProgress?.totalConcepts || 0
})

const currentDayConcepts = computed(() => {
  const dayConfig = dayConfigs[props.currentDay]
  if (!dayConfig || !dayConfig.concepts) return []

  const currentProgress = props.dayProgress[props.currentDay]
  const unlockedConcepts = currentProgress?.unlockedConcepts || []

  // 根据 day 选择正确的概念定义对象
  let conceptDefs = conceptDefinitions
  if (props.currentDay === 11) {
    conceptDefs = day11ConceptDefinitions
  } else if (props.currentDay === 12) {
    conceptDefs = day12ConceptDefinitions
  } else if (props.currentDay === 13) {
    conceptDefs = day13ConceptDefinitions
  } else if (props.currentDay === 14) {
    conceptDefs = day14ConceptDefinitions
  } else if (props.currentDay === 15) {
    conceptDefs = day15ConceptDefinitions
  } else if (props.currentDay === 16) {
    conceptDefs = day16ConceptDefinitions
  } else if (props.currentDay === 17) {
    conceptDefs = day17ConceptDefinitions
  } else if (props.currentDay === 18) {
    conceptDefs = day18ConceptDefinitions
  } else if (props.currentDay === 19) {
    conceptDefs = day19ConceptDefinitions
  } else if (props.currentDay === 20) {
    conceptDefs = day20ConceptDefinitions
  } else if (props.currentDay === 21) {
    conceptDefs = day21ConceptDefinitions
  }

  return dayConfig.concepts.map(conceptKey => {
    const concept = conceptDefs[conceptKey]
    return {
      key: conceptKey,
      name: concept?.name || conceptKey,
      icon: unlockedConcepts.includes(conceptKey) ? concept?.icon : '🔒',
      isUnlocked: unlockedConcepts.includes(conceptKey)
    }
  })
})
</script>

<style scoped>
/* 实时数据和操作日志的通用样式 */
.data-row {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 0;
}

.data-row .label {
  color: var(--text-secondary);
  font-size: 0.9em;
  min-width: fit-content;
}

.data-row .value {
  color: var(--text-main);
  font-weight: 500;
}

.no-operations {
  text-align: center;
  color: var(--text-muted);
  padding: 20px;
}

/* 操作日志特有样式 */
.log-entry {
  border-bottom: 1px solid var(--border-main);
}

.log-entry:last-child {
  border-bottom: none;
}

.timestamp {
  color: var(--text-muted);
  font-size: 0.85em;
  min-width: 80px;
}

.gas-info {
  font-size: 0.85em;
  color: var(--text-secondary);
}
</style>
