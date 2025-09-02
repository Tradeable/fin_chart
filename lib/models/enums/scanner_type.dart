import 'package:fin_chart/models/scanners/abandoned_baby_bottom.dart';
import 'package:fin_chart/models/scanners/abandoned_baby_top.dart';
import 'package:fin_chart/models/scanners/bearish_engulfing.dart';
import 'package:fin_chart/models/scanners/bearish_harami.dart';
import 'package:fin_chart/models/scanners/bearish_harami_cross.dart';
import 'package:fin_chart/models/scanners/black_marubozu.dart';
import 'package:fin_chart/models/scanners/bullish_engulfing.dart';
import 'package:fin_chart/models/scanners/bullish_harami.dart';
import 'package:fin_chart/models/scanners/bullish_harami_cross.dart';
import 'package:fin_chart/models/scanners/bullish_kicker.dart';
import 'package:fin_chart/models/scanners/dark_cloud_cover.dart';
import 'package:fin_chart/models/scanners/downside_tasuki_gap.dart';
import 'package:fin_chart/models/scanners/dragonfly_doji.dart';
import 'package:fin_chart/models/scanners/hammer.dart';
import 'package:fin_chart/models/scanners/hanging_man.dart';
import 'package:fin_chart/models/scanners/identical_three_crows.dart';
import 'package:fin_chart/models/scanners/inverted_hammer.dart';
import 'package:fin_chart/models/scanners/morning_star.dart';
import 'package:fin_chart/models/scanners/moving_average_scanner.dart';
import 'package:fin_chart/models/scanners/oscillator_scanner.dart';
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/scanners/piercing_line.dart';
import 'package:fin_chart/models/scanners/shooting_star.dart';
import 'package:fin_chart/models/scanners/three_white_soldiers.dart';
import 'package:fin_chart/models/scanners/upside_tasuki_gap.dart';
import 'package:fin_chart/models/scanners/white_marubozu.dart';

enum PriceComparison { above, below }

enum ScannerType {
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

  // MFI Scanners
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

  // EMA Pripce Above
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

extension ScannerTypeExtension on ScannerType {
  PatternScanner get instance {
    switch (this) {
      case ScannerType.hammer:
        return HammerScanner();
      case ScannerType.whiteMarubozu:
        return WhiteMarubozuScanner();
      case ScannerType.blackMarubozu:
        return BlackMarubozuScanner();
      case ScannerType.bullishHarami:
        return BullishHaramiScanner();
      case ScannerType.bearishHarami:
        return BearishHaramiScanner();
      case ScannerType.bullishHaramiCross:
        return BullishHaramiCrossScanner();
      case ScannerType.bearishHaramiCross:
        return BearishHaramiCrossScanner();
      case ScannerType.bullishEngulfing:
        return EngulfingPatternScanner();
      case ScannerType.bearishEngulfing:
        return BearishEngulfingScanner();
      case ScannerType.upsideTasukiGap:
        return UpsideTasukiGapScanner();
      case ScannerType.downsideTasukiGap:
        return DownsideTasukiGapScanner();
      case ScannerType.invertedHammer:
        return InvertedHammerScanner();
      case ScannerType.shootingStar:
        return ShootingStarScanner();
      case ScannerType.threeWhiteSoldiers:
        return ThreeWhiteSoldiersScanner();
      case ScannerType.identicalThreeCrows:
        return IdenticalThreeCrowsScanner();
      case ScannerType.abandonedBabyBottom:
        return AbandonedBabyBottomScanner();
      case ScannerType.abandonedBabyTop:
        return AbandonedBabyTopScanner();
      case ScannerType.piercingLine:
        return PiercingLineScanner();
      case ScannerType.darkCloudCover:
        return DarkCloudCoverScanner();
      case ScannerType.hangingMan:
        return HangingManScanner();
      case ScannerType.bullishKicker:
        return BullishKickerScanner();
      case ScannerType.morningStar:
        return MorningStarScanner();
      case ScannerType.dragonflyDoji:
        return DragonflyDojiScanner();

      // MFI Scanners
      case ScannerType.mfiOverbought:
        return OscillatorScanner(
          oscillatorType: OscillatorType.mFI,
          period: 14,
          threshold: 80,
          comparison: PriceComparison.above,
          type: this,
        );
      case ScannerType.mfiOversold:
        return OscillatorScanner(
          oscillatorType: OscillatorType.mFI,
          period: 14,
          threshold: 20,
          comparison: PriceComparison.below,
          type: this,
        );

      // SMA Price Above
      case ScannerType.priceAbove5SMA:
        return MovingAverageScanner(
            period: 5,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove10SMA:
        return MovingAverageScanner(
            period: 10,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove20SMA:
        return MovingAverageScanner(
            period: 20,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove30SMA:
        return MovingAverageScanner(
            period: 30,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove50SMA:
        return MovingAverageScanner(
            period: 50,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove100SMA:
        return MovingAverageScanner(
            period: 100,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove150SMA:
        return MovingAverageScanner(
            period: 150,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove200SMA:
        return MovingAverageScanner(
            period: 200,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.above,
            type: this);

      // EMA Price Above
      case ScannerType.priceAbove5EMA:
        return MovingAverageScanner(
            period: 5,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove10EMA:
        return MovingAverageScanner(
            period: 10,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove12EMA:
        return MovingAverageScanner(
            period: 12,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove20EMA:
        return MovingAverageScanner(
            period: 20,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove26EMA:
        return MovingAverageScanner(
            period: 26,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove50EMA:
        return MovingAverageScanner(
            period: 50,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove100EMA:
        return MovingAverageScanner(
            period: 100,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.above,
            type: this);
      case ScannerType.priceAbove200EMA:
        return MovingAverageScanner(
            period: 200,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.above,
            type: this);

      // SMA Price Below
      case ScannerType.priceBelow5SMA:
        return MovingAverageScanner(
            period: 5,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow10SMA:
        return MovingAverageScanner(
            period: 10,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow20SMA:
        return MovingAverageScanner(
            period: 20,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow30SMA:
        return MovingAverageScanner(
            period: 30,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow50SMA:
        return MovingAverageScanner(
            period: 50,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow100SMA:
        return MovingAverageScanner(
            period: 100,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow150SMA:
        return MovingAverageScanner(
            period: 150,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow200SMA:
        return MovingAverageScanner(
            period: 200,
            maType: MovingAverageType.sMA,
            comparison: PriceComparison.below,
            type: this);

      // EMA Price Below
      case ScannerType.priceBelow5EMA:
        return MovingAverageScanner(
            period: 5,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow10EMA:
        return MovingAverageScanner(
            period: 10,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow12EMA:
        return MovingAverageScanner(
            period: 12,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow20EMA:
        return MovingAverageScanner(
            period: 20,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow26EMA:
        return MovingAverageScanner(
            period: 26,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow50EMA:
        return MovingAverageScanner(
            period: 50,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow100EMA:
        return MovingAverageScanner(
            period: 100,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.below,
            type: this);
      case ScannerType.priceBelow200EMA:
        return MovingAverageScanner(
            period: 200,
            maType: MovingAverageType.eMA,
            comparison: PriceComparison.below,
            type: this);
    }
  }
}
