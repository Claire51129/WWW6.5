import { ref, computed } from 'vue'
import { conceptDefinitions, day11ConceptDefinitions, day12ConceptDefinitions, day13ConceptDefinitions, day14ConceptDefinitions, day15ConceptDefinitions, day16ConceptDefinitions, day17ConceptDefinitions, day18ConceptDefinitions } from '@/data/concepts'

/**
 * 概念徽章点击交互逻辑
 * 用于处理已解锁概念的点击显示详情功能
 */
export function useConceptInteraction(updateCurrentConcept, currentDay = null) {
  // 当前选中的概念 key
  const selectedConcept = ref(null)

  // 获取概念定义（支持 Day 11、Day 12、Day 13、Day 14、Day 15、Day 16、Day 17、Day 18 和其他天数）
  const getConceptDef = (key) => {
    if (currentDay === 11) {
      return day11ConceptDefinitions[key]
    }
    if (currentDay === 12) {
      return day12ConceptDefinitions[key]
    }
    if (currentDay === 13) {
      return day13ConceptDefinitions[key]
    }
    if (currentDay === 14) {
      return day14ConceptDefinitions[key]
    }
    if (currentDay === 15) {
      return day15ConceptDefinitions[key]
    }
    if (currentDay === 16) {
      return day16ConceptDefinitions[key]
    }
    if (currentDay === 17) {
      return day17ConceptDefinitions[key]
    }
    if (currentDay === 18) {
      return day18ConceptDefinitions[key]
    }
    return conceptDefinitions[key]
  }

  // 处理概念徽章点击
  const handleConceptClick = (conceptKey) => {
    if (selectedConcept.value === conceptKey) {
      // 如果点击的是当前选中的概念，则取消选中并恢复显示最新概念
      selectedConcept.value = null
      if (updateCurrentConcept) {
        updateCurrentConcept(null) // null 表示恢复到显示最新概念
      }
    } else {
      // 否则选中该概念并更新显示
      selectedConcept.value = conceptKey
      if (updateCurrentConcept) {
        updateCurrentConcept(conceptKey)
      }
    }
  }

  // 获取概念徽章文本
  const getConceptBadge = (conceptKey) => {
    const concept = getConceptDef(conceptKey)
    return concept ? `${concept.icon} ${concept.name}` : conceptKey
  }

  // 获取选中的概念详情
  const selectedConceptDetail = computed(() => {
    if (!selectedConcept.value) return null
    return getConceptDef(selectedConcept.value)
  })

  // 清除选中状态
  const clearSelectedConcept = () => {
    selectedConcept.value = null
    if (updateCurrentConcept) {
      updateCurrentConcept(null)
    }
  }

  return {
    selectedConcept,
    selectedConceptDetail,
    handleConceptClick,
    getConceptBadge,
    clearSelectedConcept
  }
}
