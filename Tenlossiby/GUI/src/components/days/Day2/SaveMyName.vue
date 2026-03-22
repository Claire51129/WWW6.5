<template>
  <div class="day-2-content day-content">
    <div class="content-layout" :class="{ 'single-column': unlockedConcepts.length === 0 }">
      <!-- 左侧：交互区域 -->
      <div class="left-column">
        <div class="interaction-area">
          <h3>🎮 交互操作</h3>
          <div class="input-group">
            <label>📝 姓名：</label>
            <input
              v-model="inputName"
              type="text"
              placeholder="输入你的名字"
              @keyup.enter="handleStore"
            />
          </div>
          <div class="input-group">
            <label>📄 简介：</label>
            <input
              v-model="inputBio"
              type="text"
              placeholder="介绍一下你自己"
              @keyup.enter="handleStore"
            />
          </div>
          <div class="button-group">
            <button class="day-action-btn green" @click="handleStore">
              💾 保存数据/Store Data
            </button>
            <button class="day-action-btn blue" @click="handleRetrieve" :disabled="!hasStored">
              📤 检索数据/Retrieve Data
            </button>
          </div>

          <!-- 搜索功能 -->
          <div class="search-section">
            <h4>🔍 搜索数据</h4>
            <div class="input-group">
              <input
                v-model="searchKeyword"
                type="text"
                placeholder="输入姓名或简介关键词"
                @keyup.enter="handleSearch"
              />
            </div>
            <button class="day-action-btn cyan" @click="handleSearch" :disabled="!hasStored">
              🔍 搜索/Search
            </button>

            <!-- 搜索结果显示 -->
            <div v-if="searchResult.show" class="search-result-display">
              <h4>🔍 搜索结果：</h4>
              <div v-if="searchResult.found" class="result-success">
                <div class="result-item">
                  <span class="label">姓名：</span>
                  <span class="value">{{ name }}</span>
                </div>
                <div class="result-item">
                  <span class="label">简介：</span>
                  <span class="value">{{ bio }}</span>
                </div>
                <div class="match-info">✅ 在{{ searchResult.matchField }}中找到匹配！</div>
              </div>
              <div v-else class="result-not-found">
                ❌ 未找到包含"{{ searchResult.keyword }}"的数据
              </div>
            </div>
          </div>

          <!-- 检索结果显示 -->
          <div v-if="hasRetrieved && !searchResult.show" class="result-display">
            <h4>📋 全部数据：</h4>
            <div class="result-item">
              <span class="label">姓名：</span>
              <span class="value">{{ name }}</span>
            </div>
            <div class="result-item">
              <span class="label">简介：</span>
              <span class="value">{{ bio }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧：知识面板 -->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="2"
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
      title="SaveMyName 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useDay2 } from '@/composables/useDay2'
import { getFullCode } from '@/data/days'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

// 使用 Day 2 composable
const {
  name,
  bio,
  hasStored,
  hasRetrieved,
  storeData,
  retrieveData,
  unlockedConcepts,
  progressPercentage
} = useDay2()

// 完整代码
const fullCode = computed(() => getFullCode(2))

// 是否显示完整代码弹窗
const showFullCode = ref(false)

// 输入框的临时状态
const inputName = ref('')
const inputBio = ref('')
const searchKeyword = ref('')

// 搜索结果
const searchResult = ref({
  show: false,
  found: false,
  keyword: '',
  matchField: ''
})

// 处理保存操作
const handleStore = () => {
  if (!inputName.value.trim()) {
    alert('请输入姓名')
    return
  }
  storeData(inputName.value, inputBio.value)
  // 重置搜索结果
  searchResult.value = { show: false, found: false, keyword: '', matchField: '' }
}

// 处理检索操作
const handleRetrieve = () => {
  retrieveData()
  // 重置搜索结果
  searchResult.value = { show: false, found: false, keyword: '', matchField: '' }
}

// 处理搜索操作
const handleSearch = () => {
  if (!searchKeyword.value.trim()) {
    alert('请输入搜索关键词')
    return
  }

  const keyword = searchKeyword.value.toLowerCase()
  const nameValue = name.value.toLowerCase()
  const bioValue = bio.value.toLowerCase()

  let found = false
  let matchField = ''

  // 搜索姓名
  if (nameValue.includes(keyword)) {
    found = true
    matchField = '姓名'
  }

  // 搜索简介
  if (bioValue.includes(keyword)) {
    found = true
    matchField = matchField ? '姓名和简介' : '简介'
  }

  searchResult.value = {
    show: true,
    found,
    keyword: searchKeyword.value,
    matchField
  }

  // 只有找到匹配时才调用 retrieveData 显示数据
  if (found) {
    retrieveData()
  }
}
</script>

<style scoped>
/* Day 2 特有样式 */

/* 确保输入框布局为两行：label和input在同一行 */
.day-2-content .input-group {
  display: flex !important;
  flex-direction: row !important;
  align-items: center !important;
  gap: 10px;
  margin-bottom: 15px;
}

.day-2-content .input-group label {
  min-width: 80px;
  white-space: nowrap;
  flex-shrink: 0;
}

.day-2-content .input-group input {
  flex: 1;
}

/* 覆盖响应式样式，始终保持行布局 */
@media (max-width: 768px) {
  .day-2-content .input-group {
    flex-direction: row !important;
  }
}

.button-group {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.button-group .day-action-btn {
  flex: 1;
}

.day-action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 搜索区域样式 */
.search-section {
  margin-top: 20px;
  padding: 15px;
  background: var(--bg-surface-1);
  border-radius: 6px;
  border: 1px solid var(--border-main);
}

.search-section h4 {
  margin: 0 0 15px 0;
  color: var(--accent-yellow);
}

.search-section .day-action-btn {
  width: 100%;
  margin-top: 10px;
}

.search-result-display {
  margin-top: 15px;
  padding: 15px;
  background: var(--bg-base);
  border-radius: 6px;
  border: 1px solid var(--border-main);
}

.search-result-display h4 {
  margin: 0 0 15px 0;
  color: var(--accent-cyan);
}

.result-success {
  color: var(--text-main);
}

.result-not-found {
  color: var(--accent-red);
  text-align: center;
  padding: 10px;
}

.match-info {
  margin-top: 10px;
  padding: 10px;
  background: var(--bg-surface-1);
  border-radius: 4px;
  color: var(--accent-green);
  font-weight: bold;
  text-align: center;
}

.result-display {
  margin-top: 20px;
  padding: 15px;
  background: var(--bg-base);
  border-radius: 6px;
  border: 1px solid var(--border-main);
}

.result-display h4 {
  margin: 0 0 15px 0;
  color: var(--accent-blue);
}

.result-item {
  margin-bottom: 10px;
  padding: 10px;
  background: var(--bg-surface-1);
  border-radius: 4px;
}

.result-item .label {
  font-weight: bold;
  color: var(--text-muted);
  margin-right: 10px;
}

.result-item .value {
  color: var(--text-main);
}
</style>
