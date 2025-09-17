enum TaskType {
  addData,
  addIndicator,
  addLayer,
  addPrompt,
  addMcq,
  // addLayerOfType,
  waitTask,
  clearTask,
  createOptionChain,
  addOptionChain,
  highlightCorrectOptionChainValue,
  showPayOffGraph,
  addTab,
  removeTab,
  moveTab,
  popUpTask,
  showBottomSheet,
  showInsightsPage,
  chooseBucketRows,
  clearBucketRows,
  tableTask,
  highlightTableRow,
  showInsightsV2Page,
  showSideNav,
  editOptionRow,
  editColumnVisibility
}

// extension TaskTypeExtension on TaskType {
//   String get name {
//     return toString().split('.').last;
//   }
// }
