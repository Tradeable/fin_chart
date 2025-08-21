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
import 'package:fin_chart/models/scanners/pattern_scanner.dart';
import 'package:fin_chart/models/scanners/piercing_line.dart';
import 'package:fin_chart/models/scanners/shooting_star.dart';
import 'package:fin_chart/models/scanners/three_white_soldiers.dart';
import 'package:fin_chart/models/scanners/upside_tasuki_gap.dart';
import 'package:fin_chart/models/scanners/white_marubozu.dart';

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
    }
  }
}
