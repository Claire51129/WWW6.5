<!-- ClickCounter.vue - 集成实时数据的版本 -->
<template>
  <div class="day-1-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <!-- 左侧：交互区域 -->
      <div class="left-column">
        <div class="interaction-area">
          <h3>🎮 交互操作</h3>
          <div class="interaction-controls">
            <button class="day-action-btn cyan" @click="clickCounter">
              🖱️ 点击计数器/ClickCounter
            </button>
            <button class="day-action-btn red" @click="resetCounter">
              🔄 重置计数器/ResetCounter
            </button>
          </div>
          <div class="result-display">
            <h4>当前计数值：</h4>
            <div class="result-value">{{ counter }}</div>
          </div>
        </div>
      </div>

      <!-- 右侧：知识面板（传入 realtimeData）-->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="1"
          :unlocked-concepts="unlockedConcepts"
          :progress-percentage="progressPercentage"
          :full-code="fullCode"
          :realtime-data="realtimeData"
          @show-full-code="showFullCode = true"
        />
      </div>
    </div>

    <!-- 完整代码弹窗（使用共享组件） -->
    <FullCodeModal
      :show="showFullCode"
      title="ClickCounter 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useDay1 } from '@/composables/useDay1'  // 使用扩展版的 composable
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

// 使用 Day 1 composable（已包含 realtimeData）
const {
  counter,
  clickCounter,
  resetCounter,
  unlockedConcepts,
  progressPercentage,
  realtimeData  // ← 新增：实时数据接口
} = useDay1()

// 完整代码
const fullCode = computed(() => getFullCode(1))

// 是否显示完整代码弹窗
const showFullCode = ref(false)
</script>

<style scoped>
/* Day 1 特有样式 */
.result-display {
  margin-top: 20px;
  padding: 15px;
  background: var(--bg-base);
  border-radius: 6px;
  border: 1px solid var(--border-main);
}

.result-display h4 {
  margin: 0 0 10px 0;
  color: var(--text-muted);
}

.result-value {
  font-size: 2em;
  font-weight: bold;
  color: var(--accent-yellow);
  text-align: center;
}
</style>
