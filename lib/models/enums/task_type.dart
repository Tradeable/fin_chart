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
  highlightCorrectOptionChainValue
}

// extension TaskTypeExtension on TaskType {
//   String get name {
//     return toString().split('.').last;
//   }
// }
