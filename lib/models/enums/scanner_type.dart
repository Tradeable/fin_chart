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
  morningStar,
  dragonflyDoji,

  // Oscillator Scanners
  mfiOverbought,
  mfiOversold,

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
