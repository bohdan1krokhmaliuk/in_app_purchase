import 'package:in_app_purchase/models/base/period_unit.dart';

/// Example: periodUnit = PeriodUnit.month and numberOfUnits = 3
/// is equal to 3 months period
class Period {
  const Period({required this.numberOfUnits, required this.periodUnit});

  final int numberOfUnits;
  final PeriodUnit periodUnit;

  static Period? fromIso8601(final String iso8601) {
    const _iso8601DurationRegExp =
        r'^(-|\+)?P(?:([-+]?[0-9,.]*)Y)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)W)?(?:([-+]?[0-9,.]*)D)?(?:T(?:([-+]?[0-9,.]*)H)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)S)?)?$';

    if (!RegExp(_iso8601DurationRegExp).hasMatch(iso8601)) {
      // 'iso8601 String does not follow correct format'
      return null;
    }

    for (final unit in PeriodUnitExt.validUnits) {
      final cycle = _parseUnitCycle(iso8601, unit);
      if (cycle != null) return Period(numberOfUnits: cycle, periodUnit: unit);
    }

    return null;
  }

  /// Private helper method for extracting a time value from the ISO8601 string.
  static int? _parseUnitCycle(final String iso8601, final PeriodUnit timeUnit) {
    final matchedStr =
        RegExp(r'\d+' + timeUnit.iso8601Symbol).firstMatch(iso8601)?.group(0);

    if (matchedStr == null) return null;

    return int.parse(matchedStr.substring(0, matchedStr.length - 1));
  }
}
