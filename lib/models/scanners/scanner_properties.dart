import 'package:fin_chart/models/enums/scanner_display_type.dart';
import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:fin_chart/models/indicators/pivot_point.dart';
import 'package:flutter/material.dart';

enum ScannerSentiment { bullish, bearish, neutral }

extension ScannerProperties on ScannerType {
  String get displayName {
    final props = properties;
    return props['name'] as String;
  }

  String get label {
    final props = properties;
    return props['label'] as String;
  }

  ScannerDisplayType get displayType {
    final props = properties;
    return props['displayType'] as ScannerDisplayType? ??
        ScannerDisplayType.labelBox;
  }

  ScannerSentiment get sentiment {
    switch (this) {
      // Bullish Candlestick
      case ScannerType.hammer:
      case ScannerType.whiteMarubozu:
      case ScannerType.bullishHarami:
      case ScannerType.bullishHaramiCross:
      case ScannerType.bullishEngulfing:
      case ScannerType.upsideTasukiGap:
      case ScannerType.invertedHammer:
      case ScannerType.threeWhiteSoldiers:
      case ScannerType.abandonedBabyBottom:
      case ScannerType.piercingLine:
      case ScannerType.bullishKicker:
      case ScannerType.morningStar:
      case ScannerType.dragonflyDoji:
        return ScannerSentiment.bullish;

      // Bearish Candlestick
      case ScannerType.blackMarubozu:
      case ScannerType.bearishHarami:
      case ScannerType.bearishHaramiCross:
      case ScannerType.bearishEngulfing:
      case ScannerType.downsideTasukiGap:
      case ScannerType.shootingStar:
      case ScannerType.identicalThreeCrows:
      case ScannerType.abandonedBabyTop:
      case ScannerType.darkCloudCover:
      case ScannerType.hangingMan:
        return ScannerSentiment.bearish;

      // Bullish Oscillators
      case ScannerType.mfiOversold:
      case ScannerType.dualOversoldRsiMfi:
      case ScannerType.macdCrossAboveZero:
      case ScannerType.macdCrossAboveSignal:
      case ScannerType.rsiBullish:
      case ScannerType.rocOversold:
        return ScannerSentiment.bullish;

      // Bearish Oscillators
      case ScannerType.mfiOverbought:
      case ScannerType.dualOverboughtRsiMfi:
      case ScannerType.macdCrossBelowZero:
      case ScannerType.macdCrossBelowSignal:
      case ScannerType.rsiBearish:
      case ScannerType.rocOverbought:
        return ScannerSentiment.bearish;

      // Bullish Pivots
      case ScannerType.pivotPointR1Breakout:
      case ScannerType.pivotPointR2Breakout:
      case ScannerType.pivotPointR3Breakout:
        return ScannerSentiment.bullish;

      // Bearish Pivots
      case ScannerType.pivotPointS1Breakdown:
      case ScannerType.pivotPointS2Breakdown:
      case ScannerType.pivotPointS3Breakdown:
        return ScannerSentiment.bearish;

      // Price and Volume
      case ScannerType.recoveryFrom52WeekLow:
      case ScannerType.recoveryFromWeekLow:
        return ScannerSentiment.bullish;
      case ScannerType.fallFrom52WeekHigh:
      case ScannerType.fallFromWeekHigh:
        return ScannerSentiment.bearish;

      // SMA/EMA Scanners
      case ScannerType.priceAbove5SMA:
      case ScannerType.priceAbove10SMA:
      case ScannerType.priceAbove20SMA:
      case ScannerType.priceAbove30SMA:
      case ScannerType.priceAbove50SMA:
      case ScannerType.priceAbove100SMA:
      case ScannerType.priceAbove150SMA:
      case ScannerType.priceAbove200SMA:
      case ScannerType.priceAbove5EMA:
      case ScannerType.priceAbove10EMA:
      case ScannerType.priceAbove12EMA:
      case ScannerType.priceAbove20EMA:
      case ScannerType.priceAbove26EMA:
      case ScannerType.priceAbove50EMA:
      case ScannerType.priceAbove100EMA:
      case ScannerType.priceAbove200EMA:
        return ScannerSentiment.bullish;

      case ScannerType.priceBelow5SMA:
      case ScannerType.priceBelow10SMA:
      case ScannerType.priceBelow20SMA:
      case ScannerType.priceBelow30SMA:
      case ScannerType.priceBelow50SMA:
      case ScannerType.priceBelow100SMA:
      case ScannerType.priceBelow150SMA:
      case ScannerType.priceBelow200SMA:
      case ScannerType.priceBelow5EMA:
      case ScannerType.priceBelow10EMA:
      case ScannerType.priceBelow12EMA:
      case ScannerType.priceBelow20EMA:
      case ScannerType.priceBelow26EMA:
      case ScannerType.priceBelow50EMA:
      case ScannerType.priceBelow100EMA:
      case ScannerType.priceBelow200EMA:
        return ScannerSentiment.bearish;
    }
  }

  Map<String, dynamic> get properties {
    switch (this) {
      // Candlestick
      case ScannerType.hammer:
        return {
          'name': 'Hammer',
          'label': 'Hammer',
          'defaultColor': Colors.green
        };
      case ScannerType.whiteMarubozu:
        return {
          'name': 'White Marubozu',
          'label': 'W Maru',
          'defaultColor': Colors.green
        };
      case ScannerType.blackMarubozu:
        return {
          'name': 'Black Marubozu',
          'label': 'B Maru',
          'defaultColor': Colors.red
        };
      case ScannerType.bullishHarami:
        return {
          'name': 'Bullish Harami',
          'label': 'Bu Harami',
          'defaultColor': Colors.green
        };
      case ScannerType.bearishHarami:
        return {
          'name': 'Bearish Harami',
          'label': 'Be Harami',
          'defaultColor': Colors.red
        };
      case ScannerType.bullishHaramiCross:
        return {
          'name': 'Bullish Harami Cross',
          'label': 'Bu Harami+',
          'defaultColor': Colors.green
        };
      case ScannerType.bearishHaramiCross:
        return {
          'name': 'Bearish Harami Cross',
          'label': 'Be Harami+',
          'defaultColor': Colors.red
        };
      case ScannerType.bullishEngulfing:
        return {
          'name': 'Bullish Engulfing',
          'label': 'Bu Engulf',
          'defaultColor': Colors.green
        };
      case ScannerType.bearishEngulfing:
        return {
          'name': 'Bearish Engulfing',
          'label': 'Be Engulf',
          'defaultColor': Colors.red
        };
      case ScannerType.piercingLine:
        return {
          'name': 'Piercing Line',
          'label': 'Piercing',
          'defaultColor': Colors.green
        };
      case ScannerType.darkCloudCover:
        return {
          'name': 'Dark Cloud Cover',
          'label': 'Dark Cloud',
          'defaultColor': Colors.red
        };
      case ScannerType.upsideTasukiGap:
        return {
          'name': 'Upside Tasuki Gap',
          'label': 'Up Tasuki',
          'defaultColor': Colors.green
        };
      case ScannerType.downsideTasukiGap:
        return {
          'name': 'Downside Tasuki Gap',
          'label': 'Down Tasuki',
          'defaultColor': Colors.red
        };
      case ScannerType.invertedHammer:
        return {
          'name': 'Inverted Hammer',
          'label': 'Inv Hammer',
          'defaultColor': Colors.green
        };
      case ScannerType.shootingStar:
        return {
          'name': 'Shooting Star',
          'label': 'Shoot Star',
          'defaultColor': Colors.red
        };
      case ScannerType.threeWhiteSoldiers:
        return {
          'name': 'Three White Soldiers',
          'label': '3 White Sol',
          'defaultColor': Colors.green
        };
      case ScannerType.identicalThreeCrows:
        return {
          'name': 'Identical Three Crows',
          'label': '3 Ident Crows',
          'defaultColor': Colors.red
        };
      case ScannerType.abandonedBabyBottom:
        return {
          'name': 'Abandoned Baby Bottom',
          'label': 'Aban Baby Bot',
          'defaultColor': Colors.green
        };
      case ScannerType.abandonedBabyTop:
        return {
          'name': 'Abandoned Baby Top',
          'label': 'Aban Baby Top',
          'defaultColor': Colors.red
        };
      case ScannerType.hangingMan:
        return {
          'name': 'Hanging Man',
          'label': 'Hang Man',
          'defaultColor': Colors.red
        };
      case ScannerType.bullishKicker:
        return {
          'name': 'Bullish Kicker',
          'label': 'Bu Kicker',
          'defaultColor': Colors.green
        };
      case ScannerType.morningStar:
        return {
          'name': 'Morning Star',
          'label': 'Morning Star',
          'defaultColor': Colors.green
        };

      // Oscillators
      case ScannerType.mfiOverbought:
        return {
          'name': 'MFI Overbought',
          'label': 'MFI > 80',
          'displayType': ScannerDisplayType.areaShade,
          'period': 14,
          'threshold': 80.0,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.red,
        };
      case ScannerType.mfiOversold:
        return {
          'name': 'MFI Oversold',
          'label': 'MFI < 20',
          'displayType': ScannerDisplayType.areaShade,
          'period': 14,
          'threshold': 20.0,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.green,
        };
      case ScannerType.dualOverboughtRsiMfi:
        return {
          'name': 'Dual Overbought (RSI & MFI)',
          'label': 'RSI>70 & MFI>70',
          'displayType': ScannerDisplayType.areaShade,
          'rsiPeriod': 14,
          'mfiPeriod': 14,
          'rsiThreshold': 70.0,
          'mfiThreshold': 70.0,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.red,
        };
      case ScannerType.dualOversoldRsiMfi:
        return {
          'name': 'Dual Oversold (RSI & MFI)',
          'label': 'RSI<30 & MFI<20',
          'displayType': ScannerDisplayType.areaShade,
          'rsiPeriod': 14,
          'mfiPeriod': 14,
          'rsiThreshold': 20.0,
          'mfiThreshold': 20.0,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.green,
        };
      case ScannerType.macdCrossAboveZero:
        return {
          'name': 'MACD Crosses Above Zero',
          'label': 'MACD > 0',
          'displayType': ScannerDisplayType.areaShade,
          'fastPeriod': 12,
          'slowPeriod': 26,
          'signalPeriod': 9,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.macdCrossBelowZero:
        return {
          'name': 'MACD Crosses Below Zero',
          'label': 'MACD < 0',
          'displayType': ScannerDisplayType.areaShade,
          'fastPeriod': 12,
          'slowPeriod': 26,
          'signalPeriod': 9,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.macdCrossAboveSignal:
        return {
          'name': 'MACD Crosses Above Signal',
          'label': 'MACD > Signal',
          'displayType': ScannerDisplayType.areaShade,
          'fastPeriod': 12,
          'slowPeriod': 26,
          'signalPeriod': 9,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.macdCrossBelowSignal:
        return {
          'name': 'MACD Crosses Below Signal',
          'label': 'MACD < Signal',
          'displayType': ScannerDisplayType.areaShade,
          'fastPeriod': 12,
          'slowPeriod': 26,
          'signalPeriod': 9,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.rsiBullish:
        return {
          'name': 'RSI Bullish (Custom)',
          'label': 'RSI>=80 & Vol*Price>1L',
          'displayType': ScannerDisplayType.areaShade,
          'rsiPeriod': 14,
          'volumePeriod': 5, // For "Week Volume Avg"
          'rsiThreshold': 80.0,
          'volumeThreshold': 100000.0,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.rsiBearish:
        return {
          'name': 'RSI Bearish (Custom)',
          'label': 'RSI<=20',
          'displayType': ScannerDisplayType.areaShade,
          'rsiPeriod': 14,
          'rsiThreshold': 20.0,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.rocOversold:
        return {
          'name': 'Oversold by ROC',
          'label': 'ROC Buy Signal',
          'displayType': ScannerDisplayType.areaShade,
          'rocPeriod1': 125,
          'rocPeriod2': 21,
          'smaPeriod': 20,
          'defaultColor': Colors.green,
        };
      case ScannerType.rocOverbought:
        return {
          'name': 'Overbought by ROC',
          'label': 'ROC Sell Signal',
          'displayType': ScannerDisplayType.areaShade,
          'rocPeriod1': 125,
          'rocPeriod2': 21,
          'smaPeriod': 20,
          'defaultColor': Colors.red,
        };

      // --- Pivot Point Scanners ---
      case ScannerType.pivotPointR1Breakout:
        return {
          'name': 'Positive Breakout (LTP > R1)',
          'label': 'LTP > R1',
          'displayType': ScannerDisplayType.areaShade,
          'level': 'r1',
          'comparison': PriceComparison.above,
          'timeframe': PivotTimeframe.daily,
          'defaultColor': Colors.green,
        };
      case ScannerType.pivotPointR2Breakout:
        return {
          'name': 'Positive Breakout (LTP > R2)',
          'label': 'LTP > R2',
          'displayType': ScannerDisplayType.areaShade,
          'level': 'r2',
          'comparison': PriceComparison.above,
          'timeframe': PivotTimeframe.daily,
          'defaultColor': Colors.green,
        };
      case ScannerType.pivotPointR3Breakout:
        return {
          'name': 'Positive Breakout (LTP > R3)',
          'label': 'LTP > R3',
          'displayType': ScannerDisplayType.areaShade,
          'level': 'r3',
          'comparison': PriceComparison.above,
          'timeframe': PivotTimeframe.daily,
          'defaultColor': Colors.green,
        };
      case ScannerType.pivotPointS1Breakdown:
        return {
          'name': 'Negative Breakdown (LTP < S1)',
          'label': 'LTP < S1',
          'displayType': ScannerDisplayType.areaShade,
          'level': 's1',
          'comparison': PriceComparison.below,
          'timeframe': PivotTimeframe.daily,
          'defaultColor': Colors.red,
        };
      case ScannerType.pivotPointS2Breakdown:
        return {
          'name': 'Negative Breakdown (LTP < S2)',
          'label': 'LTP < S2',
          'displayType': ScannerDisplayType.areaShade,
          'level': 's2',
          'comparison': PriceComparison.below,
          'timeframe': PivotTimeframe.daily,
          'defaultColor': Colors.red,
        };
      case ScannerType.pivotPointS3Breakdown:
        return {
          'name': 'Negative Breakdown (LTP < S3)',
          'label': 'LTP < S3',
          'displayType': ScannerDisplayType.areaShade,
          'level': 's3',
          'comparison': PriceComparison.below,
          'timeframe': PivotTimeframe.daily,
          'defaultColor': Colors.red,
        };

      // Price and Volume
      case ScannerType.recoveryFrom52WeekLow:
        return {
          'name': 'Highest Recovery from 52 Week Low',
          'label': '% from 52w Low > 5',
          'displayType': ScannerDisplayType.areaShade,
          'defaultColor': Colors.green,
        };
      case ScannerType.recoveryFromWeekLow:
        return {
          'name': 'Highest Recovery from Week Low',
          'label': '% from Week Low > 10',
          'displayType': ScannerDisplayType.areaShade,
          'defaultColor': Colors.green,
        };
      case ScannerType.fallFrom52WeekHigh:
        return {
          'name': 'Highest Fall from 52 Week High',
          'label': '% from 52w High > 10',
          'displayType': ScannerDisplayType.areaShade,
          'defaultColor': Colors.red,
        };
      case ScannerType.fallFromWeekHigh:
        return {
          'name': 'Highest Fall from Week High',
          'label': '% from Week High > 5',
          'displayType': ScannerDisplayType.areaShade,
          'defaultColor': Colors.red,
        };

      // --- SMA Scanners ---
      case ScannerType.priceAbove5SMA:
        return {
          'name': 'Price > 5 SMA',
          'label': 'P > 5SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 5,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove10SMA:
        return {
          'name': 'Price > 10 SMA',
          'label': 'P > 10SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 10,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove20SMA:
        return {
          'name': 'Price > 20 SMA',
          'label': 'P > 20SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 20,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove30SMA:
        return {
          'name': 'Price > 30 SMA',
          'label': 'P > 30SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 30,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove50SMA:
        return {
          'name': 'Price > 50 SMA',
          'label': 'P > 50SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 50,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove100SMA:
        return {
          'name': 'Price > 100 SMA',
          'label': 'P > 100SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 100,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove150SMA:
        return {
          'name': 'Price > 150 SMA',
          'label': 'P > 150SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 150,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove200SMA:
        return {
          'name': 'Price > 200 SMA',
          'label': 'P > 200SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 200,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };

      case ScannerType.priceBelow5SMA:
        return {
          'name': 'Price < 5 SMA',
          'label': 'P < 5SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 5,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow10SMA:
        return {
          'name': 'Price < 10 SMA',
          'label': 'P < 10SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 10,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow20SMA:
        return {
          'name': 'Price < 20 SMA',
          'label': 'P < 20SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 20,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow30SMA:
        return {
          'name': 'Price < 30 SMA',
          'label': 'P < 30SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 30,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow50SMA:
        return {
          'name': 'Price < 50 SMA',
          'label': 'P < 50SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 50,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow100SMA:
        return {
          'name': 'Price < 100 SMA',
          'label': 'P < 100SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 100,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow150SMA:
        return {
          'name': 'Price < 150 SMA',
          'label': 'P < 150SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 150,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow200SMA:
        return {
          'name': 'Price < 200 SMA',
          'label': 'P < 200SMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 200,
          'maType': MovingAverageType.sMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };

      // --- EMA Scanners ---
      case ScannerType.priceAbove5EMA:
        return {
          'name': 'Price > 5 EMA',
          'label': 'P > 5EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 5,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove10EMA:
        return {
          'name': 'Price > 10 EMA',
          'label': 'P > 10EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 10,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove12EMA:
        return {
          'name': 'Price > 12 EMA',
          'label': 'P > 12EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 12,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove20EMA:
        return {
          'name': 'Price > 20 EMA',
          'label': 'P > 20EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 20,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove26EMA:
        return {
          'name': 'Price > 26 EMA',
          'label': 'P > 26EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 26,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove50EMA:
        return {
          'name': 'Price > 50 EMA',
          'label': 'P > 50EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 50,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove100EMA:
        return {
          'name': 'Price > 100 EMA',
          'label': 'P > 100EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 100,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };
      case ScannerType.priceAbove200EMA:
        return {
          'name': 'Price > 200 EMA',
          'label': 'P > 200EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 200,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.above,
          'defaultColor': Colors.green,
        };

      case ScannerType.priceBelow5EMA:
        return {
          'name': 'Price < 5 EMA',
          'label': 'P < 5EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 5,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow10EMA:
        return {
          'name': 'Price < 10 EMA',
          'label': 'P < 10EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 10,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow12EMA:
        return {
          'name': 'Price < 12 EMA',
          'label': 'P < 12EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 12,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow20EMA:
        return {
          'name': 'Price < 20 EMA',
          'label': 'P < 20EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 20,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow26EMA:
        return {
          'name': 'Price < 26 EMA',
          'label': 'P < 26EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 26,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow50EMA:
        return {
          'name': 'Price < 50 EMA',
          'label': 'P < 50EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 50,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow100EMA:
        return {
          'name': 'Price < 100 EMA',
          'label': 'P < 100EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 100,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };
      case ScannerType.priceBelow200EMA:
        return {
          'name': 'Price < 200 EMA',
          'label': 'P < 200EMA',
          'displayType': ScannerDisplayType.areaShade,
          'period': 200,
          'maType': MovingAverageType.eMA,
          'comparison': PriceComparison.below,
          'defaultColor': Colors.red,
        };

      default:
        return {'name': 'Unknown', 'label': 'N/A'};
    }
  }
}
