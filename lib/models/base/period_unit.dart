enum PeriodUnit { day, week, month, year, unknown }

extension PeriodUnitExt on PeriodUnit {
  static PeriodUnit init(final int rawValue) {
    switch (rawValue) {
      case 0:
        return PeriodUnit.day;
      case 1:
        return PeriodUnit.week;
      case 2:
        return PeriodUnit.month;
      case 3:
        return PeriodUnit.year;
      default:
        return PeriodUnit.unknown;
    }
  }

  static Set<PeriodUnit> get validUnits => {
        PeriodUnit.day,
        PeriodUnit.week,
        PeriodUnit.month,
        PeriodUnit.year,
      };

  String get iso8601Symbol {
    switch (this) {
      case PeriodUnit.day:
        return 'D';
      case PeriodUnit.week:
        return 'W';
      case PeriodUnit.month:
        return 'M';
      case PeriodUnit.year:
        return 'Y';
      default:
        return '';
    }
  }

  int get rawValue {
    switch (this) {
      case PeriodUnit.day:
        return 0;
      case PeriodUnit.week:
        return 1;
      case PeriodUnit.month:
        return 2;
      case PeriodUnit.year:
        return 3;
      default:
        return -1;
    }
  }
}
