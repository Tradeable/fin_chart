enum TaskType {
  addData,
  addIndicator,
  addLayer,
  addPrompt,
  addMcq,
  // addLayerOfType,
  waitTask,
  clearTask,
  addOptionChain,
  chooseCorrectOptionChainValue,
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
  showInsightsV2Page
}

// extension TaskTypeExtension on TaskType {
//   String get name {
//     return toString().split('.').last;
//   }
// }
