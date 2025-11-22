class ProgressEntry {
  const ProgressEntry({
    required this.id,
    required this.metric,
    required this.percentage,
    required this.trend,
  });

  final String id;
  final String metric;
  final double percentage;
  final Trend trend;
}

enum Trend { up, steady, down }

