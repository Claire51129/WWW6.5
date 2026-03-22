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

      <!-- 右侧：知识面板 -->
      <div class="right-column">
        <KnowledgePanel
          v-if="unlockedConcepts.length > 0"
          :current-day="1"
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
      title="ClickCounter 完整代码"
      :code="fullCode"
      @close="showFullCode = false"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useDay1 } from '@/composables/useDay1'
import KnowledgePanel from '@/components/shared/KnowledgePanel.vue'
import FullCodeModal from '@/components/shared/FullCodeModal.vue'

// 使用 Day 1 composable
const {
  counter,
  clickCounter,
  resetCounter,
  unlockedConcepts,
  progressPercentage
} = useDay1()

// 完整代码
const fullCode = `//SPDx-License-Identifier:MIT

// 声明Solidity版本，要求编译器版本在0.8.0或更高（但低于0.9.0）
pragma solidity ^0.8.0;

// 定义一个名为clickcounter的合约（相当于其他语言中的类）
contract clickcounter{
    // 声明一个无符号256位整数类型的状态变量counter
    // public关键字表示这个变量可以被外部访问，编译器会自动生成getter函数
    uint256 public counter;

    // 定义一个名为click的公共函数
    // public表示任何人都可以调用这个函数
    function click() public {
        // 将counter的值加1（自增操作）
        counter++;
    }
}`

// 是否显示完整代码弹窗
const showFullCode = ref(false)
</script>

<style scoped>
/* 继承主样式文件中的样式 */
.day-1-content {
  width: 100%;
}

/* 布局样式已迁移到 day-common.css */

.interaction-area {
  background: var(--bg-surface-1);
  padding: 20px;
  border-radius: 8px;
  border: 2px solid var(--border-main);
}

.interaction-area h3 {
  margin-top: 0;
  color: var(--accent-yellow);
}

.interaction-controls {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 15px;
}

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

@media (max-width: 768px) {
  /* 布局样式已迁移到 day-common.css */
}
</style>
