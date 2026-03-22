<template>
  <div class="day-3-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <!-- 左侧：交互区域 -->
      <div class="left-column">
        <div class="interaction-area">
          <h3>🎮 交互操作</h3>
          <div class="interaction-controls">
            <div class="input-group">
              <label>🗳️ 候选人姓名：</label>
              <input
                v-model="inputCandidate"
                type="text"
                placeholder="请输入候选人姓名"
                @keyup.enter="handleAddCandidate"
              />
            </div>
            <button class="day-action-btn cyan" @click="handleAddCandidate">
              ➕ 添加候选人/AddCandidate
            </button>
          </div>
        </div>

        <!-- 候选人列表 -->
        <div v-if="candidates.length > 0" class="candidates-list">
          <h4>🗳️ 候选人列表/Candidates</h4>
          <div v-for="candidate in candidates" :key="candidate" class="candidate-item">
            <div class="candidate-info">
              <span class="candidate-name">{{ candidate }}</span>
              <span class="vote-count">{{ voteCount[candidate] || 0 }} 票</span>
            </div>
            <button @click="handleVoteCandidate(candidate)" class="day-action-btn green small">
              🗳️ 投票/Vote
            </button>
          </div>
        </div>
      </div>

      <!-- 右侧：知识面板 -->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="3"
          :unlocked-concepts="unlockedConcepts"
          :progress-percentage="progressPercentage"
          :full-code="fullCode"
          @show-full-code="showFullCode = true"
        />
      </div>
    </div>

    <!-- 完整代码弹窗（使用共享组件） -->
    <FullCodeModal
      :show="showFullCode"
      title="PollStation 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useDay3 } from '@/composables/useDay3'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

// 使用 Day 3 composable
const {
  candidates,
  voteCount,
  addCandidate,
  voteCandidate,
  unlockedConcepts,
  progressPercentage
} = useDay3()

// 完整代码
const fullCode = computed(() => getFullCode(3))

// 是否显示完整代码弹窗
const showFullCode = ref(false)

// 输入框的临时状态
const inputCandidate = ref('')

// 处理添加候选人
const handleAddCandidate = () => {
  if (!inputCandidate.value.trim()) {
    alert('请输入候选人姓名')
    return
  }
  addCandidate(inputCandidate.value.trim())
  inputCandidate.value = ''
}

// 处理投票
const handleVoteCandidate = (candidate) => {
  voteCandidate(candidate)
}
</script>

<style scoped>
/* Day 3 特有样式 */
.candidates-list {
  background: var(--bg-surface-1);
  padding: 20px;
  border-radius: 8px;
  border: 2px solid var(--accent-green);
}

.candidates-list h4 {
  margin: 0 0 15px 0;
  color: var(--accent-green);
}

.candidate-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background: var(--bg-base);
  border-radius: 6px;
  margin-bottom: 10px;
  border: 1px solid var(--border-main);
}

.candidate-info {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.candidate-name {
  font-weight: bold;
  color: var(--text-main);
  font-size: 1.1em;
}

.vote-count {
  color: var(--accent-blue);
  font-size: 0.9em;
}

.day-action-btn.small {
  padding: 8px 16px;
  font-size: 0.9em;
}
</style>
