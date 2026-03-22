<template>
  <div class="left-sidebar">
    <div class="sidebar-header">
      <h3>📚 学习导航</h3>
      <button class="sort-toggle-btn" @click="toggleSort" :title="isAscending ? '点击切换倒序' : '点击切换正序'">
        {{ isAscending ? '🔼 正序' : '🔽 倒序' }}
      </button>
    </div>
    <div 
      v-for="day in sortedDays" 
      :key="day"
      class="day-nav-item"
      :class="{ active: currentDay === day }"
      @click="$emit('switchDay', day)"
    >
      <div class="day-nav-header">
        <div class="day-title">Day {{ day }}</div>
      </div>
      <div class="day-subtitle">{{ getDaySubtitle(day) }}</div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { dayConfigs } from '../data/days'

const props = defineProps({
  currentDay: {
    type: Number,
    required: true
  }
})

defineEmits(['switchDay'])

// 排序状态：默认正序
const isAscending = ref(true)

// 切换排序
const toggleSort = () => {
  isAscending.value = !isAscending.value
}

// 根据排序状态返回排序后的天数列表
const sortedDays = computed(() => {
  const days = Object.keys(dayConfigs).map(Number)
  return isAscending.value ? days : days.reverse()
})

const getDaySubtitle = (day) => {
  // Day 14 使用自定义标题
  if (day === 14) {
    return '安全存款盒/SafeDeposit'
  }
  return dayConfigs[day]?.subtitle || '待定内容'
}
</script>

<style scoped>
.sidebar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.sidebar-header h3 {
  margin: 0;
  padding: 0;
  border-bottom: none;
}

.sort-toggle-btn {
  background: var(--bg-surface-1);
  border: 1px solid var(--border-main);
  border-radius: 6px;
  padding: 6px 10px;
  font-size: 0.8em;
  cursor: pointer;
  color: var(--text-main);
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 4px;
}

.sort-toggle-btn:hover {
  background: var(--accent-yellow);
  color: var(--bg-base);
  border-color: var(--accent-yellow);
}

.day-nav-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.new-tag {
  background: var(--accent-blue);
  color: var(--bg-base);
  font-size: 0.6em;
  padding: 2px 6px;
  border-radius: 4px;
  font-weight: bold;
}
</style>
