mixin DateExtractor {
  static DateTime? extractDate(final int? timestamp) {
    if (timestamp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}
