enum MovingAverageType { sMA, eMA }

enum PriceComparison { above, below }

enum ScannerType {
  // Candlestick Patterns
  hammer,
  whiteMarubozu,
  blackMarubozu,
  bullishHarami,
  bearishHarami,
  bullishHaramiCross,
  bearishHaramiCross,
  bullishEngulfing,
  bearishEngulfing,
  upsideTasukiGap,
  downsideTasukiGap,
  invertedHammer,
  shootingStar,
  threeWhiteSoldiers,
  identicalThreeCrows,
  abandonedBabyBottom,
  abandonedBabyTop,
  piercingLine,
  darkCloudCover,
  hangingMan,
  bullishKicker,
  bearishKicker,
  morningStar,
  dragonflyDoji,
  gravestoneDoji,
  tweezerBottom,
  tweezerTop,
  nr4,
  nr7,
  strongClose,
  weakClose,
  risingWindow,
  fallingWindow,
  marketStructureLow,
  marketStructureHigh,
  goldenCrossover,
  deathCrossover,

  // Oscillator Scanners
  mfiOverbought,
  mfiOversold,
  dualOverboughtRsiMfi,
  dualOversoldRsiMfi,
  macdCrossAboveZero,
  macdCrossBelowZero,
  macdCrossAboveSignal,
  macdCrossBelowSignal,
  rsiBullish,
  rsiBearish,
  rocOversold,
  rocOverbought,
  weakeningTechnicals,

  // Bollinger Band Scanners
  bollingerBandBreakoutBullish,
  bollingerBandBreakoutBearish,

  // Pivot Point Breakouts
  pivotPointR1Breakout,
  pivotPointR2Breakout,
  pivotPointR3Breakout,
  pivotPointS1Breakdown,
  pivotPointS2Breakdown,
  pivotPointS3Breakdown,

  // Price and Volume
  recoveryFrom52WeekLow,
  recoveryFromWeekLow,
  fallFrom52WeekHigh,
  fallFromWeekHigh,

  // SMA Price Above
  priceAbove5SMA,
  priceAbove10SMA,
  priceAbove20SMA,
  priceAbove30SMA,
  priceAbove50SMA,
  priceAbove100SMA,
  priceAbove150SMA,
  priceAbove200SMA,

  // EMA Price Above
  priceAbove5EMA,
  priceAbove10EMA,
  priceAbove12EMA,
  priceAbove20EMA,
  priceAbove26EMA,
  priceAbove50EMA,
  priceAbove100EMA,
  priceAbove200EMA,

  // SMA Price Below
  priceBelow5SMA,
  priceBelow10SMA,
  priceBelow20SMA,
  priceBelow30SMA,
  priceBelow50SMA,
  priceBelow100SMA,
  priceBelow150SMA,
  priceBelow200SMA,

  // EMA Price Below
  priceBelow5EMA,
  priceBelow10EMA,
  priceBelow12EMA,
  priceBelow20EMA,
  priceBelow26EMA,
  priceBelow50EMA,
  priceBelow100EMA,
  priceBelow200EMA,
}
