<template>
  <div class="center-content">
    <component 
      :is="currentDayComponent" 
      :key="currentDay"
      :day="currentDay"
      @switch-day="handleSwitchDay"
    />
  </div>
</template>

<script setup>
import { computed, defineAsyncComponent } from 'vue'
import ComingSoon from './shared/ComingSoon.vue'

// 使用动态导入，按需加载各Day组件
const dayComponents = {
  1: defineAsyncComponent(() => import('./days/Day1/ClickCounter.vue')),
  2: defineAsyncComponent(() => import('./days/Day2/SaveMyName.vue')),
  3: defineAsyncComponent(() => import('./days/Day3/PollStation.vue')),
  4: defineAsyncComponent(() => import('./days/Day4/AuctionHouse.vue')),
  5: defineAsyncComponent(() => import('./days/Day5/AdminOnly.vue')),
  6: defineAsyncComponent(() => import('./days/Day6/EtherPiggyBank.vue')),
  7: defineAsyncComponent(() => import('./days/Day7/SimpleIOUApp.vue')),
  8: defineAsyncComponent(() => import('./days/Day8/TipJar.vue')),
  9: defineAsyncComponent(() => import('./days/Day9/SmartCalculator.vue')),
  10: defineAsyncComponent(() => import('./days/Day10/ActivityTracker.vue')),
  11: defineAsyncComponent(() => import('./days/Day11/MasterkeyContract.vue')),
  12: defineAsyncComponent(() => import('./days/Day12/ERC20Token.vue')),
  13: defineAsyncComponent(() => import('./days/Day13/MyToken.vue')),
  14: defineAsyncComponent(() => import('./days/Day14/SafeDeposit.vue')),
  15: defineAsyncComponent(() => import('./days/Day15/GasEfficientVoting.vue')),
  16: defineAsyncComponent(() => import('./days/Day16/PluginStore.vue')),
  17: defineAsyncComponent(() => import('./days/Day17/UpgradeHub.vue')),
  18: defineAsyncComponent(() => import('./days/Day18/OracleContract.vue')),
  19: defineAsyncComponent(() => import('./days/Day19/SignThis.vue')),
  20: defineAsyncComponent(() => import('./days/Day20/ReentryAttack.vue')),
  21: defineAsyncComponent(() => import('./days/Day21/SimpleNFT.vue'))
}

const props = defineProps({
  currentDay: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['switchDay'])

const currentDayComponent = computed(() => {
  // 如果请求的 Day 不存在，显示 ComingSoon 组件
  return dayComponents[props.currentDay] || ComingSoon
})

// 处理 ComingSoon 组件发出的切换天数事件
const handleSwitchDay = (day) => {
  emit('switchDay', day)
}
</script>

<style scoped>
.center-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
}
</style>
